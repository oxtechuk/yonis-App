import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/core/network/api_client.dart';

class _FakeHttpAdapter implements HttpClientAdapter {
  _FakeHttpAdapter(this.onRequest);

  final void Function(RequestOptions options) onRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequest(options);
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  test(
    'a bodyless GET never declares a JSON content type '
    '(some backends stall waiting for a body promised by the header)',
    () async {
      String? sentContentType;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = _FakeHttpAdapter(
          (options) => sentContentType = options.contentType,
        );
      final api = DioApiClient(dio);

      await api.get<Map<String, dynamic>>('/slots');

      expect(sentContentType, isNull);
    },
  );

  test('a POST with a body declares application/json', () async {
    String? sentContentType;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeHttpAdapter(
        (options) => sentContentType = options.contentType,
      );
    final api = DioApiClient(dio);

    await api.post<Map<String, dynamic>>('/checkout/check-user', data: {'phone': '+9647701234567'});

    expect(sentContentType, contains('application/json'));
  });

  test('an explicit caller-supplied contentType is not overridden', () async {
    String? sentContentType;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeHttpAdapter(
        (options) => sentContentType = options.contentType,
      );
    final api = DioApiClient(dio);

    await api.post<Map<String, dynamic>>(
      '/upload',
      data: 'raw',
      options: Options(contentType: 'text/plain'),
    );

    expect(sentContentType, 'text/plain');
  });
}
