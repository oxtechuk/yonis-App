import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../config/app_environment.dart';
import 'core_dependencies.dart';
import 'home_dependencies.dart';

/// The ONE composition root of the application.
///
/// Only files under `lib/app/di/` and the bootstrap may import this file.
/// Business classes must receive dependencies through constructors instead
/// of locating them here.
final GetIt getIt = GetIt.instance;

void configureDependencies({
  required AppEnvironment environment,
  required SharedPreferences sharedPreferences,
}) {
  if (getIt.isRegistered<AppConfig>()) {
    throw StateError('Dependencies were already configured.');
  }

  final config = AppConfig.forEnvironment(environment);

  registerCoreDependencies(
    getIt: getIt,
    config: config,
    sharedPreferences: sharedPreferences,
  );

  registerHomeDependencies(getIt);
}
