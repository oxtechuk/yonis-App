import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import '../logging/app_logger.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Builds the single, environment-configured Dio instance of the app.
///
/// Timeouts, headers and logging policy live here — never scattered across
/// features. When a [SecureStorage] is supplied, an [AuthInterceptor] is
/// attached so every request carries `Authorization: Bearer <token>`
/// whenever a token is persisted.
class DioFactory {
  const DioFactory(this._config, this._logger, {SecureStorage? secureStorage})
    : _secureStorage = secureStorage;

  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(seconds: 20);
  static const Duration _sendTimeout = Duration(seconds: 15);

  final AppConfig _config;
  final AppLogger _logger;
  final SecureStorage? _secureStorage;

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
        // No default contentType here: it must only be set on requests that
        // actually carry a body (see DioApiClient._withJsonContentType).
        // Declaring `Content-Type: application/json` on a bodyless GET
        // confuses some backends into waiting for body data that never
        // arrives, which reads as a hung/slow request client-side.
        headers: <String, String>{'Accept': 'application/json'},
      ),
    );

    // Registered before the logging interceptor so dev logs show whether
    // the Authorization header was attached (its value stays redacted).
    if (_secureStorage != null) {
      dio.interceptors.add(AuthInterceptor(secureStorage: _secureStorage));
    }

    if (_config.enableNetworkLogs) {
      dio.interceptors.add(
        LoggingInterceptor(logger: _logger, logBody: !_config.isProduction),
      );
    }

    return dio;
  }
}
