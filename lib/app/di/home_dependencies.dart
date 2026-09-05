import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../features/home/data/repositories/doctor_profile_repository_impl.dart';
import '../../features/home/data/repositories/reels_repository_impl.dart';
import '../../features/home/data/repositories/services_repository_impl.dart';
import '../../features/home/data/sources/doctor_profile_remote_data_source.dart';
import '../../features/home/data/sources/reels_remote_data_source.dart';
import '../../features/home/data/sources/services_remote_data_source.dart';
import '../../features/home/domain/repositories/doctor_profile_repository.dart';
import '../../features/home/domain/repositories/reels_repository.dart';
import '../../features/home/domain/repositories/services_repository.dart';
import '../../features/home/domain/use_cases/get_doctor_profile_use_case.dart';
import '../../features/home/domain/use_cases/get_reels_use_case.dart';
import '../../features/home/domain/use_cases/get_services_use_case.dart';
import '../../features/home/presentation/cubit/doctor_profile_cubit.dart';
import '../../features/home/presentation/cubit/reels_cubit.dart';
import '../../features/home/presentation/cubit/services_cubit.dart';

void registerHomeDependencies(GetIt getIt) {
  getIt.registerLazySingleton<DoctorProfileRemoteDataSource>(
    () => ApiDoctorProfileRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<DoctorProfileRepository>(
    () => DoctorProfileRepositoryImpl(
      remoteDataSource: getIt<DoctorProfileRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetDoctorProfileUseCase>(
    () => GetDoctorProfileUseCase(getIt<DoctorProfileRepository>()),
  );

  getIt.registerFactory<DoctorProfileCubit>(
    () => DoctorProfileCubit(
      getDoctorProfileUseCase: getIt<GetDoctorProfileUseCase>(),
    ),
  );

  getIt.registerLazySingleton<ServicesRemoteDataSource>(
    () => ApiServicesRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ServicesRepository>(
    () => ServicesRepositoryImpl(
      remoteDataSource: getIt<ServicesRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetServicesUseCase>(
    () => GetServicesUseCase(getIt<ServicesRepository>()),
  );

  getIt.registerLazySingleton<ServicesCubit>(
    () => ServicesCubit(getServicesUseCase: getIt<GetServicesUseCase>()),
  );

  getIt.registerLazySingleton<ReelsRemoteDataSource>(
    () => ApiReelsRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ReelsRepository>(
    () => ReelsRepositoryImpl(
      remoteDataSource: getIt<ReelsRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetReelsUseCase>(
    () => GetReelsUseCase(getIt<ReelsRepository>()),
  );

  getIt.registerFactory<ReelsCubit>(
    () => ReelsCubit(getReelsUseCase: getIt<GetReelsUseCase>()),
  );
}
