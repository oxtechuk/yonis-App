import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';

/// Environment-aware network logging.
///
/// - Added to Dio only when AppConfig.enableNetworkLogs is true.
/// - Request/response bodies are logged only when `logBody` is true
///   (non-production builds), so production never prints payload contents.
/// - Authorization/cookie-style headers and known secret-bearing body keys
///   are redacted even in development. Never log raw secrets.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required AppLogger logger, required bool logBody})
    : _logger = logger,
      _logBody = logBody;

  static const String _redactedValue = '<redacted>';
  static const String _sentAtExtraKey = 'logging_interceptor.sent_at';

  static const Set<String> _sensitiveHeaderNames = {
    'authorization',
    'proxy-authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'api-key',
  };

  static const List<String> _sensitiveBodyKeyParts = [
    'password',
    'token',
    'secret',
    'authorization',
    'credential',
  ];

  final AppLogger _logger;
  final bool _logBody;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_sentAtExtraKey] = DateTime.now();
    _logger.i('[HTTP] --> ${options.method} ${options.uri}');
    if (_logBody) {
      _logger.d('[HTTP] headers: ${_redactHeaders(options.headers)}');
      _logger.d('[HTTP] body: ${_redact(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.i(
      '[HTTP] <-- ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri} (${_elapsedMs(response.requestOptions)}ms)',
    );
    if (_logBody) {
      _logger.d('[HTTP] response body: ${_redact(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.w(
      '[HTTP] <-- ERROR ${err.response?.statusCode ?? 'N/A'} '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '(${err.type.name}) (${_elapsedMs(err.requestOptions)}ms)',
      error: err.message,
    );
    if (_logBody) {
      _logger.d('[HTTP] error body: ${_redact(err.response?.data)}');
    }
    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final sentAt = options.extra[_sentAtExtraKey];
    if (sentAt is! DateTime) return -1;
    return DateTime.now().difference(sentAt).inMilliseconds;
  }

  Map<String, Object?> _redactHeaders(Map<String, Object?> headers) =>
      <String, Object?>{
        for (final entry in headers.entries)
          entry.key: _isSensitiveHeaderName(entry.key)
              ? _redactedValue
              : entry.value,
      };

  bool _isSensitiveHeaderName(String name) =>
      _sensitiveHeaderNames.contains(name.toLowerCase().trim());

  Object? _redact(Object? value) {
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries)
          entry.key.toString(): _isSensitiveKey(entry.key.toString())
              ? _redactedValue
              : _redact(entry.value),
      };
    }
    if (value is List) {
      return <Object?>[for (final item in value) _redact(item)];
    }
    return value;
  }

  bool _isSensitiveKey(String key) =>
      _sensitiveBodyKeyParts.any(key.toLowerCase().contains);
}
