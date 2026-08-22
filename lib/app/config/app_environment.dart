/// Application environment.
///
/// Selected at startup via `--dart-define=APP_ENV=production|staging|development`
/// (defaults to development). Flutter flavors are intentionally not used yet.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromName(String? name) =>
      switch (name?.toLowerCase().trim()) {
        'staging' || 'stage' || 'stg' => staging,
        'production' || 'prod' => production,
        _ => development,
      };

  bool get isProduction => this == production;

  bool get isDevelopment => this == development;
}
