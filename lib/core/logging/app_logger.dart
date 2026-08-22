import 'dart:developer' as developer;

/// Tiny centralized logger.
///
/// - Verbose output (`d`, `i`) is disabled outside development.
/// - Warnings and errors are always recorded.
/// - Callers must never pass secrets (tokens, passwords) in messages;
///   network logging additionally redacts sensitive values centrally
///   (see LoggingInterceptor).
class AppLogger {
  AppLogger({bool verboseEnabled = true}) : _verboseEnabled = verboseEnabled;

  static const String _name = 'younis_app';

  final bool _verboseEnabled;

  void d(String message, {Object? error, StackTrace? stackTrace}) {
    if (_verboseEnabled) {
      _log(message, level: 500, error: error, stackTrace: stackTrace);
    }
  }

  void i(String message, {Object? error, StackTrace? stackTrace}) {
    if (_verboseEnabled) {
      _log(message, level: 800, error: error, stackTrace: stackTrace);
    }
  }

  void w(String message, {Object? error, StackTrace? stackTrace}) {
    _log(message, level: 900, error: error, stackTrace: stackTrace);
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    _log(message, level: 1000, error: error, stackTrace: stackTrace);
  }

  void _log(
    String message, {
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _name,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
