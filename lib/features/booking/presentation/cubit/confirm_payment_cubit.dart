import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/confirm_payment_result.dart';
import '../../domain/use_cases/confirm_payment_use_case.dart';

sealed class ConfirmPaymentState extends Equatable {
  const ConfirmPaymentState();

  @override
  List<Object?> get props => [];
}

final class ConfirmPaymentInitial extends ConfirmPaymentState {
  const ConfirmPaymentInitial();
}

final class ConfirmPaymentSubmitting extends ConfirmPaymentState {
  const ConfirmPaymentSubmitting();
}

/// Reached for both an accepted proof (`result.success == true`) and a
/// business-rejected one (`result.success == false` with `result.message`).
final class ConfirmPaymentLoaded extends ConfirmPaymentState {
  const ConfirmPaymentLoaded(this.result);

  final ConfirmPaymentResult result;

  @override
  List<Object?> get props => [result];
}

final class ConfirmPaymentFailure extends ConfirmPaymentState {
  const ConfirmPaymentFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class ConfirmPaymentCubit extends Cubit<ConfirmPaymentState> {
  ConfirmPaymentCubit({required ConfirmPaymentUseCase confirmPaymentUseCase})
      : _confirmPaymentUseCase = confirmPaymentUseCase,
        super(const ConfirmPaymentInitial());

  final ConfirmPaymentUseCase _confirmPaymentUseCase;

  Future<void> submit({
    required String bookingRef,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    required String receiptImagePath,
  }) async {
    emit(const ConfirmPaymentSubmitting());
    final result = await _confirmPaymentUseCase.call(
      bookingRef: bookingRef,
      paymentMethod: paymentMethod,
      transferNumber: transferNumber,
      transactionReference: transactionReference,
      receiptImagePath: receiptImagePath,
    );
    result.fold(
      onFailure: (failure) => emit(ConfirmPaymentFailure(failure)),
      onSuccess: (data) => emit(ConfirmPaymentLoaded(data)),
    );
  }
}
