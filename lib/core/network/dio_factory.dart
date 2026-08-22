import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import '../logging/app_logger.dart';
import 'interceptors/logging_interceptor.dart';

/// Builds the single, environment-configured Dio instance of the app.
///
/// Timeouts, headers and logging policy live here — never scattered across
/// features. Authentication headers/interceptors will be added here once
/// the authentication feature exists.
class DioFactory {
  const DioFactory(this._config, this._logger);

  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(seconds: 20);
  static const Duration _sendTimeout = Duration(seconds: 15);

  final AppConfig _config;
  final AppLogger _logger;

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
        contentType: 'application/json',
        headers: <String, String>{'Accept': 'application/json'},
      ),
    );

    if (_config.enableNetworkLogs) {
      dio.interceptors.add(
        LoggingInterceptor(logger: _logger, logBody: !_config.isProduction),
      );
    }

    return dio;
  }
}
