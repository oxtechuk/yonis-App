import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/use_cases/cancel_booking_use_case.dart';

sealed class CancelBookingState extends Equatable {
  const CancelBookingState();

  @override
  List<Object?> get props => [];
}

final class CancelBookingInitial extends CancelBookingState {
  const CancelBookingInitial();
}

final class CancelBookingInProgress extends CancelBookingState {
  const CancelBookingInProgress(this.bookingId);

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

final class CancelBookingSuccess extends CancelBookingState {
  const CancelBookingSuccess({required this.bookingId, this.message});

  final String bookingId;
  final String? message;

  @override
  List<Object?> get props => [bookingId, message];
}

final class CancelBookingFailure extends CancelBookingState {
  const CancelBookingFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// One-shot action cubit for `POST /api/booking/{id}/cancel`.
///
/// Kept separate from [SessionsCubit] so the list state is untouched
/// while a cancel is in flight; the page refreshes the lists on success.
/// The in-flight [bookingId] lets the owning card show its own spinner.
class CancelBookingCubit extends Cubit<CancelBookingState> {
  CancelBookingCubit({required CancelBookingUseCase cancelBookingUseCase})
      : _cancelBookingUseCase = cancelBookingUseCase,
        super(const CancelBookingInitial());

  final CancelBookingUseCase _cancelBookingUseCase;

  Future<void> cancel({required String bookingId}) async {
    if (state is CancelBookingInProgress) return;
    emit(CancelBookingInProgress(bookingId));
    final result = await _cancelBookingUseCase.call(bookingId: bookingId);
    result.fold(
      onFailure: (failure) => emit(CancelBookingFailure(failure)),
      onSuccess: (message) => emit(
        CancelBookingSuccess(bookingId: bookingId, message: message),
      ),
    );
  }
}
