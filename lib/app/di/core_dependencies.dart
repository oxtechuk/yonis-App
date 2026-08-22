import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logging/app_logger.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dio_factory.dart';
import '../../core/network/network_info.dart';
import '../../core/storage/preferences_storage.dart';
import '../../core/storage/secure_storage.dart';
import '../config/app_config.dart';

void registerCoreDependencies({
  required GetIt getIt,
  required AppConfig config,
  required SharedPreferences sharedPreferences,
}) {
  getIt.registerSingleton<AppConfig>(config);

  getIt.registerLazySingleton<AppLogger>(
    () => AppLogger(verboseEnabled: !config.isProduction),
  );

  getIt.registerLazySingleton<DioFactory>(
    () => DioFactory(config, getIt<AppLogger>()),
  );

  getIt.registerLazySingleton<Dio>(() => getIt<DioFactory>().create());

  getIt.registerLazySingleton<ApiClient>(() => DioApiClient(getIt<Dio>()));

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  getIt.registerLazySingleton<NetworkInfo>(
    () => ConnectivityNetworkInfo(
      connectivity: getIt<Connectivity>(),
      logger: getIt<AppLogger>(),
      reachabilityUrl: Uri.parse(config.reachabilityCheckUrl),
    ),
  );

  getIt.registerLazySingleton<SecureStorage>(() => FlutterSecureStorageImpl());

  getIt.registerSingleton<PreferencesStorage>(
    SharedPreferencesStorage(sharedPreferences),
  );
}
