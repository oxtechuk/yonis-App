import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/app/config/app_config.dart';
import 'package:younis_app/app/config/app_environment.dart';
import 'package:younis_app/core/logging/app_logger.dart';
import 'package:younis_app/core/network/dio_factory.dart';
import 'package:younis_app/core/network/interceptors/logging_interceptor.dart';

class _RecordingLogger extends AppLogger {
  final List<String> messages = <String>[];

  @override
  void d(String message, {Object? error, StackTrace? stackTrace}) =>
      messages.add(message);

  @override
  void i(String message, {Object? error, StackTrace? stackTrace}) =>
      messages.add(message);

  @override
  void w(String message, {Object? error, StackTrace? stackTrace}) =>
      messages.add(message);

  @override
  void e(String message, {Object? error, StackTrace? stackTrace}) =>
      messages.add(message);
}

class _FakeHttpAdapter implements HttpClientAdapter {
  _FakeHttpAdapter(this._handler);

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

void main() {
  group('LoggingInterceptor redaction', () {
    test(
      'sensitive headers and body fields are redacted even in dev',
      () async {
        final logger = _RecordingLogger();

        final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
        dio.httpClientAdapter = _FakeHttpAdapter(
          (_) async => ResponseBody.fromString(
            jsonEncode({
              'user': {'name': 'amir'},
              'access_token': 'response-secret-token-42',
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        );
        dio.interceptors.add(LoggingInterceptor(logger: logger, logBody: true));

        await dio.get<Map<String, dynamic>>(
          '/me',
          options: Options(
            headers: {
              'Authorization': 'Bearer super-secret-bearer-123',
              'X-Api-Key': 'secret-api-key-999',
            },
          ),
          data: {
            'password': 'hunter2-password',
            'username': 'amir',
            'session': {'refreshToken': 'nested-refresh-token-777'},
          },
        );

        final logged = logger.messages.join('\n');

        expect(logged.contains('<redacted>'), isTrue);

        expect(
          logged.contains('super-secret-bearer-123'),
          isFalse,
          reason: 'Authorization header value must be redacted',
        );
        expect(
          logged.contains('secret-api-key-999'),
          isFalse,
          reason: 'API key header value must be redacted',
        );
        expect(
          logged.contains('hunter2-password'),
          isFalse,
          reason: 'password body field must be redacted',
        );
        expect(
          logged.contains('nested-refresh-token-777'),
          isFalse,
          reason: 'nested token fields must be redacted',
        );
        expect(
          logged.contains('response-secret-token-42'),
          isFalse,
          reason: 'tokens in response bodies must be redacted',
        );

        expect(
          logged.contains('amir'),
          isTrue,
          reason: 'non-sensitive values stay visible in dev logs',
        );
        expect(logged.contains('/me'), isTrue);
      },
    );
  });

  group('environment-aware network logging policy', () {
    test('production config disables network logging entirely', () {
      final production = AppConfig.forEnvironment(AppEnvironment.production);

      expect(production.isProduction, isTrue);
      expect(production.enableNetworkLogs, isFalse);
    });

    test('development config enables safe (body-redacting) logging', () {
      final development = AppConfig.forEnvironment(AppEnvironment.development);

      expect(development.isProduction, isFalse);
      expect(development.enableNetworkLogs, isTrue);
    });

    test('DioFactory attaches the interceptor only when config allows it', () {
      final logger = _RecordingLogger();

      final productionDio = DioFactory(
        AppConfig.forEnvironment(AppEnvironment.production),
        logger,
      ).create();
      expect(
        productionDio.interceptors.whereType<LoggingInterceptor>(),
        isEmpty,
        reason: 'production must not log network traffic',
      );

      final developmentDio = DioFactory(
        AppConfig.forEnvironment(AppEnvironment.development),
        logger,
      ).create();
      expect(
        developmentDio.interceptors.whereType<LoggingInterceptor>(),
        hasLength(1),
      );
    });
  });
}
