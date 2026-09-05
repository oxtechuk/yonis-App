import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../features/sessions/data/repositories/bookings_repository_impl.dart';
import '../../features/sessions/data/sources/bookings_remote_data_source.dart';
import '../../features/sessions/domain/repositories/bookings_repository.dart';
import '../../features/sessions/domain/use_cases/cancel_booking_use_case.dart';
import '../../features/sessions/domain/use_cases/get_bookings_use_case.dart';
import '../../features/sessions/presentation/cubit/cancel_booking_cubit.dart';
import '../../features/sessions/presentation/cubit/sessions_cubit.dart';

void registerSessionsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<BookingsRemoteDataSource>(
    () => ApiBookingsRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<BookingsRepository>(
    () => BookingsRepositoryImpl(
      remoteDataSource: getIt<BookingsRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetBookingsUseCase>(
    () => GetBookingsUseCase(getIt<BookingsRepository>()),
  );

  getIt.registerFactory<SessionsCubit>(
    () => SessionsCubit(getBookingsUseCase: getIt<GetBookingsUseCase>()),
  );

  getIt.registerLazySingleton<CancelBookingUseCase>(
    () => CancelBookingUseCase(getIt<BookingsRepository>()),
  );

  getIt.registerFactory<CancelBookingCubit>(
    () => CancelBookingCubit(
      cancelBookingUseCase: getIt<CancelBookingUseCase>(),
    ),
  );
}
