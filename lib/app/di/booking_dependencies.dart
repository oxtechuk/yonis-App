import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../features/booking/data/repositories/checkout_repository_impl.dart';
import '../../features/booking/data/repositories/slots_repository_impl.dart';
import '../../features/booking/data/sources/checkout_remote_data_source.dart';
import '../../features/booking/data/sources/slots_remote_data_source.dart';
import '../../features/booking/domain/repositories/checkout_repository.dart';
import '../../features/booking/domain/repositories/slots_repository.dart';
import '../../features/booking/domain/use_cases/check_user_use_case.dart';
import '../../features/booking/domain/use_cases/get_slots_use_case.dart';
import '../../features/booking/domain/use_cases/initialize_checkout_use_case.dart';
import '../../features/booking/presentation/cubit/check_user_cubit.dart';
import '../../features/booking/presentation/cubit/checkout_cubit.dart';
import '../../features/booking/presentation/cubit/slots_cubit.dart';

void registerBookingDependencies(GetIt getIt) {
  getIt.registerLazySingleton<SlotsRemoteDataSource>(
    () => ApiSlotsRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<SlotsRepository>(
    () => SlotsRepositoryImpl(remoteDataSource: getIt<SlotsRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GetSlotsUseCase>(
    () => GetSlotsUseCase(getIt<SlotsRepository>()),
  );

  getIt.registerFactory<SlotsCubit>(
    () => SlotsCubit(getSlotsUseCase: getIt<GetSlotsUseCase>()),
  );

  getIt.registerLazySingleton<CheckoutRemoteDataSource>(
    () => ApiCheckoutRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(
      remoteDataSource: getIt<CheckoutRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<CheckUserUseCase>(
    () => CheckUserUseCase(getIt<CheckoutRepository>()),
  );

  getIt.registerFactory<CheckUserCubit>(
    () => CheckUserCubit(checkUserUseCase: getIt<CheckUserUseCase>()),
  );

  getIt.registerLazySingleton<InitializeCheckoutUseCase>(
    () => InitializeCheckoutUseCase(getIt<CheckoutRepository>()),
  );

  getIt.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(initializeCheckoutUseCase: getIt<InitializeCheckoutUseCase>()),
  );
}
