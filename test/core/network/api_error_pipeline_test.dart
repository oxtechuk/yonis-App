import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/core/error/app_exception.dart';
import 'package:younis_app/core/error/failure.dart';
import 'package:younis_app/core/error/failure_mapper.dart';
import 'package:younis_app/core/network/api_client.dart';

class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }
}

final RequestOptions _requestOptions = RequestOptions(
  baseUrl: 'https://api.test',
  path: '/things',
);

DioApiClient clientFor(FakeHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
  dio.httpClientAdapter = adapter;
  return DioApiClient(dio);
}

FakeHttpAdapter respondWith(Object? body, int statusCode) => FakeHttpAdapter(
  (_) async => ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  ),
);

void main() {
  group('success responses', () {
    test('200 returns decoded JSON map', () async {
      final api = clientFor(respondWith({'id': 'x-1', 'name': 'Thing'}, 200));

      final result = await api.get<Map<String, dynamic>>('/things/x-1');

      expect(result, {'id': 'x-1', 'name': 'Thing'});
    });

    test('201 created is success', () async {
      final api = clientFor(respondWith({'id': 'new-1'}, 201));

      final result = await api.post<Map<String, dynamic>>('/things');

      expect(result, {'id': 'new-1'});
    });

    test('202 accepted is success', () async {
      final api = clientFor(respondWith({'queued': true}, 202));

      final result = await api.get<Map<String, dynamic>>('/jobs');

      expect(result, {'queued': true});
    });

    test('204 no content returns null without throwing', () async {
      final api = clientFor(
        FakeHttpAdapter((_) async => ResponseBody.fromString('', 204)),
      );

      // void-typed request must simply not throw.
      await api.get<void>('/things/x-1');

      final result = await api.get<dynamic>('/things/x-1');

      expect(result, isNull);
    });

    test(
      '204 with non-nullable expected shape raises SerializationException',
      () async {
        final api = clientFor(
          FakeHttpAdapter((_) async => ResponseBody.fromString('', 204)),
        );

        await expectLater(
          api.get<Map<String, dynamic>>('/things/x-1'),
          throwsA(isA<SerializationException>()),
        );
      },
    );

    test('2xx with unexpected JSON shape raises SerializationException '
        '(not a transport/server error)', () async {
      // Server returned an array where a JSON object was expected.
      final api = clientFor(
        respondWith([
          {'id': 'x-1'},
        ], 200),
      );

      await expectLater(
        api.get<Map<String, dynamic>>('/things'),
        throwsA(isA<SerializationException>()),
      );
    });
  });

  group('http error classification', () {
    test('401 -> UnauthorizedException -> UnauthorizedFailure', () async {
      final api = clientFor(respondWith({'message': 'Token expired'}, 401));

      final AppException exception;
      try {
        await api.get<Map<String, dynamic>>('/me');
        fail('should have thrown');
      } on AppException catch (error) {
        exception = error;
      }

      expect(exception, isA<UnauthorizedException>());
      expect(exception.message, 'Token expired');

      final failure = FailureMapper.map(exception);
      expect(failure, isA<UnauthorizedFailure>());
      expect((failure as UnauthorizedFailure).message, 'Token expired');
    });

    test('403 -> ForbiddenException -> ForbiddenFailure', () async {
      final api = clientFor(respondWith({'message': 'Not allowed'}, 403));
      await expectLater(
        api.get<Map<String, dynamic>>('/admin'),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('404 -> NotFoundException -> NotFoundFailure', () async {
      final api = clientFor(respondWith({'message': 'Missing'}, 404));
      await expectLater(
        api.get<Map<String, dynamic>>('/things/nope'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('422 with structured errors preserves field errors', () async {
      final api = clientFor(
        respondWith({
          'message': 'Validation failed',
          'errors': {
            'email': ['Email is required'],
            'tags': ['Too many', 'Duplicated'],
          },
        }, 422),
      );

      final ValidationException exception;
      try {
        await api.post<Map<String, dynamic>>('/register');
        fail('should have thrown');
      } on ValidationException catch (error) {
        exception = error;
      } on AppException catch (error) {
        fail('expected ValidationException but got $error');
      }

      expect(exception.statusCode, 422);
      expect(exception.fieldErrors?['email'], ['Email is required']);
      expect(exception.fieldErrors?['tags'], ['Too many', 'Duplicated']);

      final failure = FailureMapper.map(exception);
      expect(failure, isA<ValidationFailure>());
      final validation = failure as ValidationFailure;
      expect(validation.fieldErrors['email'], ['Email is required']);
      expect(validation.fieldErrors['tags'], hasLength(2));
    });

    test('400 WITH structured field errors becomes validation', () async {
      final api = clientFor(
        respondWith({
          'errors': {'name': 'Name is required'},
        }, 400),
      );

      final ValidationException exception;
      try {
        await api.post<Map<String, dynamic>>('/things');
        fail('should have thrown');
      } on ValidationException catch (error) {
        exception = error;
      } on AppException catch (error) {
        fail('expected ValidationException but got $error');
      }

      expect(exception.statusCode, 400);
      expect(exception.fieldErrors?['name'], ['Name is required']);
    });

    test(
      '400 WITHOUT field structure is NOT classified as validation',
      () async {
        final api = clientFor(respondWith({'message': 'Bad request'}, 400));

        final AppException exception;
        try {
          await api.post<Map<String, dynamic>>('/things');
          fail('should have thrown');
        } on AppException catch (error) {
          exception = error;
        }

        expect(exception, isNot(isA<ValidationException>()));
        expect(exception, isA<ServerException>());

        final failure = FailureMapper.map(exception);
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).statusCode, 400);
      },
    );

    test(
      '500 -> ServerException -> ServerFailure preserving status code',
      () async {
        final api = clientFor(respondWith({'message': 'Internal error'}, 500));

        final AppException exception;
        try {
          await api.get<Map<String, dynamic>>('/things');
          fail('should have thrown');
        } on AppException catch (error) {
          exception = error;
        }

        expect(exception, isA<ServerException>());
        expect((exception as ServerException).statusCode, 500);
        expect(exception.message, 'Internal error');

        final failure = FailureMapper.map(exception);
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).statusCode, 500);
      },
    );
  });

  group('transport errors', () {
    test(
      'connection timeout -> RequestTimeoutException -> TimeoutFailure',
      () async {
        final api = clientFor(
          FakeHttpAdapter(
            (_) => throw DioException.connectionTimeout(
              timeout: const Duration(seconds: 15),
              requestOptions: _requestOptions,
            ),
          ),
        );

        final AppException exception;
        try {
          await api.get<Map<String, dynamic>>('/things');
          fail('should have thrown');
        } on AppException catch (error) {
          exception = error;
        }

        expect(exception, isA<RequestTimeoutException>());

        final failure = FailureMapper.map(exception);
        expect(failure, isA<TimeoutFailure>());
      },
    );

    test('connection error with SocketException -> NetworkException '
        '-> NetworkFailure', () async {
      final api = clientFor(
        FakeHttpAdapter(
          (_) => throw DioException(
            requestOptions: _requestOptions,
            type: DioExceptionType.connectionError,
            error: const SocketException('Network unreachable'),
          ),
        ),
      );

      final AppException exception;
      try {
        await api.get<Map<String, dynamic>>('/things');
        fail('should have thrown');
      } on AppException catch (error) {
        exception = error;
      }

      expect(exception, isA<NetworkException>());
      expect((exception as NetworkException).cause, isA<SocketException>());

      final failure = FailureMapper.map(exception);
      expect(failure, isA<NetworkFailure>());
    });

    test(
      'cancelled request stays typed and does not leak DioException',
      () async {
        final api = clientFor(
          FakeHttpAdapter(
            (_) => throw DioException(
              requestOptions: _requestOptions,
              type: DioExceptionType.cancel,
            ),
          ),
        );

        await expectLater(
          api.get<Map<String, dynamic>>('/things'),
          throwsA(isA<AppException>()),
        );
      },
    );
  });

  group('parsing failures are distinguishable', () {
    test(
      'SerializationException maps to ParsingFailure, never ServerFailure',
      () {
        final failure = FailureMapper.map(
          const SerializationException(message: 'bad json'),
        );

        expect(failure, isA<ParsingFailure>());
        expect(failure, isNot(isA<ServerFailure>()));
        expect(failure, isNot(isA<TimeoutFailure>()));
        expect(failure, isNot(isA<NetworkFailure>()));
      },
    );

    test(
      '200 with wrong shape surfaces as ParsingFailure end-to-end',
      () async {
        final api = clientFor(respondWith(['unexpected-array'], 200));

        final AppException exception;
        try {
          await api.get<Map<String, dynamic>>('/things');
          fail('should have thrown');
        } on AppException catch (error) {
          exception = error;
        }

        expect(FailureMapper.map(exception), isA<ParsingFailure>());
      },
    );
  });

  test('raw DioException can never reach the caller boundary', () async {
    final api = clientFor(
      FakeHttpAdapter(
        (_) => throw DioException(
          requestOptions: _requestOptions,
          type: DioExceptionType.unknown,
        ),
      ),
    );

    Object? thrown;
    try {
      await api.get<Map<String, dynamic>>('/things');
    } catch (error) {
      thrown = error;
    }

    expect(thrown, isNotNull);
    expect(thrown, isNot(isA<DioException>()));
    expect(thrown, isA<AppException>());
  });
}
