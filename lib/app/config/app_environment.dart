import 'package:flutter/foundation.dart';

/// Application environment.
///
/// Selected at startup via `--dart-define=APP_ENV=production|staging|development`
/// (defaults to development in debug, production in release mode).
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromName(String? name) =>
      switch (name?.toLowerCase().trim()) {
        'staging' || 'stage' || 'stg' => staging,
        'production' || 'prod' => production,
        'development' || 'dev' => development,
        _ => kReleaseMode ? production : development,
      };

  bool get isProduction => this == production;

  bool get isDevelopment => this == development;
}

