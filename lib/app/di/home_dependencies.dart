import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../features/home/data/repositories/doctor_profile_repository_impl.dart';
import '../../features/home/data/sources/doctor_profile_remote_data_source.dart';
import '../../features/home/domain/repositories/doctor_profile_repository.dart';
import '../../features/home/domain/use_cases/get_doctor_profile_use_case.dart';
import '../../features/home/presentation/cubit/doctor_profile_cubit.dart';

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
}
