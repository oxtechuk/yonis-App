import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../features/home/data/repositories/doctor_profile_repository_impl.dart';
import '../../features/home/data/repositories/doctors_repository_impl.dart';
import '../../features/home/data/repositories/reels_repository_impl.dart';
import '../../features/home/data/repositories/services_repository_impl.dart';
import '../../features/home/data/repositories/sliders_repository_impl.dart';
import '../../features/home/data/repositories/testimonials_repository_impl.dart';
import '../../features/home/data/sources/doctor_profile_remote_data_source.dart';
import '../../features/home/data/sources/doctors_remote_data_source.dart';
import '../../features/home/data/sources/reels_remote_data_source.dart';
import '../../features/home/data/sources/services_remote_data_source.dart';
import '../../features/home/data/sources/sliders_remote_data_source.dart';
import '../../features/home/data/sources/testimonials_remote_data_source.dart';
import '../../features/home/domain/repositories/doctor_profile_repository.dart';
import '../../features/home/domain/repositories/doctors_repository.dart';
import '../../features/home/domain/repositories/reels_repository.dart';
import '../../features/home/domain/repositories/services_repository.dart';
import '../../features/home/domain/repositories/sliders_repository.dart';
import '../../features/home/domain/repositories/testimonials_repository.dart';
import '../../features/home/domain/use_cases/get_doctor_profile_use_case.dart';
import '../../features/home/domain/use_cases/get_doctors_use_case.dart';
import '../../features/home/domain/use_cases/get_reels_use_case.dart';
import '../../features/home/domain/use_cases/get_services_use_case.dart';
import '../../features/home/domain/use_cases/get_sliders_use_case.dart';
import '../../features/home/domain/use_cases/get_testimonials_use_case.dart';
import '../../features/home/presentation/cubit/doctor_profile_cubit.dart';
import '../../features/home/presentation/cubit/doctors_cubit.dart';
import '../../features/home/presentation/cubit/reels_cubit.dart';
import '../../features/home/presentation/cubit/services_cubit.dart';
import '../../features/home/presentation/cubit/sliders_cubit.dart';
import '../../features/home/presentation/cubit/testimonials_cubit.dart';

void registerHomeDependencies(GetIt getIt) {
  getIt.registerLazySingleton<DoctorsRemoteDataSource>(
    () => ApiDoctorsRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<DoctorsRepository>(
    () => DoctorsRepositoryImpl(
      remoteDataSource: getIt<DoctorsRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<GetDoctorsUseCase>(
    () => GetDoctorsUseCase(getIt<DoctorsRepository>()),
  );

  getIt.registerLazySingleton<DoctorsCubit>(
    () => DoctorsCubit(getDoctorsUseCase: getIt<GetDoctorsUseCase>()),
  );

  getIt.registerLazySingleton<SlidersRemoteDataSource>(
    () => ApiSlidersRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<SlidersRepository>(
    () => SlidersRepositoryImpl(
      remoteDataSource: getIt<SlidersRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<GetSlidersUseCase>(
    () => GetSlidersUseCase(getIt<SlidersRepository>()),
  );

  getIt.registerFactory<SlidersCubit>(
    () => SlidersCubit(getSlidersUseCase: getIt<GetSlidersUseCase>()),
  );

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

  getIt.registerLazySingleton<TestimonialsRemoteDataSource>(
    () => ApiTestimonialsRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<TestimonialsRepository>(
    () => TestimonialsRepositoryImpl(
      remoteDataSource: getIt<TestimonialsRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetTestimonialsUseCase>(
    () => GetTestimonialsUseCase(getIt<TestimonialsRepository>()),
  );

  getIt.registerFactory<TestimonialsCubit>(
    () => TestimonialsCubit(
      getTestimonialsUseCase: getIt<GetTestimonialsUseCase>(),
    ),
  );
}
