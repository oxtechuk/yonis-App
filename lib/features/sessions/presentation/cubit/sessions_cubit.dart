import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/patient_booking.dart';
import '../../domain/use_cases/get_bookings_use_case.dart';

sealed class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object?> get props => [];
}

final class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

final class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

final class SessionsLoaded extends SessionsState {
  const SessionsLoaded({
    required this.upcoming,
    required this.completed,
    required this.cancelled,
  });

  final List<PatientBooking> upcoming;
  final List<PatientBooking> completed;
  final List<PatientBooking> cancelled;

  @override
  List<Object?> get props => [upcoming, completed, cancelled];
}

/// Emitted when there is no usable token (expired/invalid session, HTTP 401).
/// The page reacts by showing the sign-in gate instead of an error.
final class SessionsUnauthorized extends SessionsState {
  const SessionsUnauthorized();
}

final class SessionsError extends SessionsState {
  const SessionsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit({required GetBookingsUseCase getBookingsUseCase})
      : _getBookingsUseCase = getBookingsUseCase,
        super(const SessionsInitial());

  final GetBookingsUseCase _getBookingsUseCase;

  /// Loads all three tabs (`?tab=upcoming/completed/cancelled`) in
  /// parallel. A 401 on any tab means the session is gone → unauthorized;
  /// any other failure surfaces the first error.
  Future<void> load() async {
    emit(const SessionsLoading());
    final results = await Future.wait([
      _getBookingsUseCase.call(tab: BookingStatus.upcoming.apiTab),
      _getBookingsUseCase.call(tab: BookingStatus.completed.apiTab),
      _getBookingsUseCase.call(tab: BookingStatus.cancelled.apiTab),
    ]);
    Failure? firstError;
    var unauthorized = false;
    final tabs = <List<PatientBooking>>[];
    for (final result in results) {
      result.fold(
        onFailure: (failure) {
          if (failure is UnauthorizedFailure) {
            unauthorized = true;
          } else {
            firstError ??= failure;
          }
        },
        onSuccess: (bookings) => tabs.add(bookings),
      );
    }
    if (unauthorized) {
      emit(const SessionsUnauthorized());
      return;
    }
    final error = firstError;
    if (error != null) {
      emit(SessionsError(error));
      return;
    }
    emit(
      SessionsLoaded(
        upcoming: tabs[0],
        completed: tabs[1],
        cancelled: tabs[2],
      ),
    );
  }
}
