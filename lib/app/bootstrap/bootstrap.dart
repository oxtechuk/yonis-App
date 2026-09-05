import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logging/app_logger.dart';
import '../../core/storage/preferences_storage.dart';
import '../app.dart';
import '../config/app_environment.dart';
import '../di/dependency_injection.dart';
import '../localization/app_localization.dart';

/// The single initialization path of the application.
///
/// Environment is selected with `--dart-define=APP_ENV=production|staging|development`
/// (default: development).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final environment = AppEnvironment.fromName(
    const String.fromEnvironment('APP_ENV'),
  );
  final sharedPreferences = await SharedPreferences.getInstance();

  configureDependencies(
    environment: environment,
    sharedPreferences: sharedPreferences,
  );

  final logger = getIt<AppLogger>();

  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(
      'Flutter framework error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    logger.e('Uncaught platform error', error: error, stackTrace: stack);
    return true;
  };

  logger.i('Starting app in ${environment.name} environment');

  final startLocale = AppLocalization.localeFromSavedCode(
    sharedPreferences.getString(PreferencesKeys.languageCode),
  );

  // Device preview (device frames, sizes, dark-mode toggle) is a development
  // aid: it is compiled out of release builds and never wraps the app in
  // widget tests.
  final Widget app = kReleaseMode
      ? YounisApp()
      : DevicePreview(
          enabled: !true,
          builder: (_) => YounisApp(appBuilder: DevicePreview.appBuilder),
        );

  runApp(
    EasyLocalization(
      supportedLocales: AppLocalization.supportedLocales,
      path: AppLocalization.translationsPath,
      fallbackLocale: AppLocalization.fallbackLocale,
      startLocale: startLocale,
      child: app,
    ),
  );
}
