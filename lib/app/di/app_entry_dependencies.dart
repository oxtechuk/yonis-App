import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../features/app_entry/data/repositories/splash_repository_impl.dart';
import '../../features/app_entry/data/sources/splash_remote_data_source.dart';
import '../../features/app_entry/domain/repositories/splash_repository.dart';
import '../../features/app_entry/domain/use_cases/get_splash_config_use_case.dart';
import '../../features/app_entry/presentation/cubit/splash_cubit.dart';

void registerAppEntryDependencies(GetIt getIt) {
  getIt.registerLazySingleton<SplashRemoteDataSource>(
    () => ApiSplashRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<SplashRepository>(
    () => SplashRepositoryImpl(
      remoteDataSource: getIt<SplashRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<GetSplashConfigUseCase>(
    () => GetSplashConfigUseCase(getIt<SplashRepository>()),
  );

  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(
      getSplashConfigUseCase: getIt<GetSplashConfigUseCase>(),
    ),
  );
}
