import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/data/sources/profile_remote_data_source.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/use_cases/get_profile_user_use_case.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

void registerProfileDependencies(GetIt getIt) {
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ApiProfileRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetProfileUserUseCase>(
    () => GetProfileUserUseCase(getIt<ProfileRepository>()),
  );

  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getProfileUserUseCase: getIt<GetProfileUserUseCase>(),
    ),
  );
}
