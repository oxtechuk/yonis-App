import 'app_environment.dart';

/// Immutable, environment-derived application configuration.
///
/// The single source of truth for environment-specific values (base URL,
/// logging policy). Infrastructure receives it through DI — no URLs or
/// environment booleans scattered across the codebase.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.baseUrl,
    required this.enableNetworkLogs,
    this.reachabilityCheckUrl = defaultReachabilityCheckUrl,
  });

  static const String defaultReachabilityCheckUrl =
      'https://www.gstatic.com/generate_204';

  static const Map<AppEnvironment, String> _baseUrls = {
    AppEnvironment.development: 'https://dev.api.younis.example',
    AppEnvironment.staging: 'https://staging.api.younis.example',
    AppEnvironment.production: 'https://api.younis.example',
  };

  final AppEnvironment environment;
  final String appName;
  final String baseUrl;

  /// Network request/response logging. Production builds never log bodies.
  final bool enableNetworkLogs;

  /// Endpoint used by the connectivity probe to verify real internet
  /// access (expects any 2xx-3xx/`< 500` response).
  ///
  /// PROVISIONAL DEFAULT: an external well-known endpoint is used until the
  /// Younis backend exposes a lightweight health/ping endpoint. Swap the URL
  /// here (per environment if needed) once that exists — no other code may
  /// hard-code reachability endpoints.
  final String reachabilityCheckUrl;

  bool get isProduction => environment.isProduction;

  bool get isDevelopment => environment.isDevelopment;

  factory AppConfig.forEnvironment(AppEnvironment environment) {
    return AppConfig(
      environment: environment,
      appName: 'Yonis',
      baseUrl: _baseUrls[environment]!,
      enableNetworkLogs: !environment.isProduction,
    );
  }

  @override
  String toString() =>
      'AppConfig(environment: ${environment.name}, baseUrl: $baseUrl, '
      'enableNetworkLogs: $enableNetworkLogs)';
}
