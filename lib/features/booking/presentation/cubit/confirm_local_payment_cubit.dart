import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/confirm_payment_result.dart';
import '../../domain/use_cases/confirm_local_payment_use_case.dart';

sealed class ConfirmLocalPaymentState extends Equatable {
  const ConfirmLocalPaymentState();

  @override
  List<Object?> get props => [];
}

final class ConfirmLocalPaymentInitial extends ConfirmLocalPaymentState {
  const ConfirmLocalPaymentInitial();
}

final class ConfirmLocalPaymentSubmitting extends ConfirmLocalPaymentState {
  const ConfirmLocalPaymentSubmitting();
}

/// Reached for both an accepted confirmation (`result.success == true`) and a
/// business-rejected one (`result.success == false` with `result.message`).
final class ConfirmLocalPaymentLoaded extends ConfirmLocalPaymentState {
  const ConfirmLocalPaymentLoaded(this.result);

  final ConfirmPaymentResult result;

  @override
  List<Object?> get props => [result];
}

final class ConfirmLocalPaymentFailure extends ConfirmLocalPaymentState {
  const ConfirmLocalPaymentFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class ConfirmLocalPaymentCubit extends Cubit<ConfirmLocalPaymentState> {
  ConfirmLocalPaymentCubit({
    required ConfirmLocalPaymentUseCase confirmLocalPaymentUseCase,
  })  : _confirmLocalPaymentUseCase = confirmLocalPaymentUseCase,
        super(const ConfirmLocalPaymentInitial());

  final ConfirmLocalPaymentUseCase _confirmLocalPaymentUseCase;

  Future<void> submit({
    required String bookingReference,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    String? notes,
  }) async {
    emit(const ConfirmLocalPaymentSubmitting());
    final result = await _confirmLocalPaymentUseCase.call(
      bookingReference: bookingReference,
      paymentMethod: paymentMethod,
      transferNumber: transferNumber,
      transactionReference: transactionReference,
      notes: notes,
    );
    result.fold(
      onFailure: (failure) => emit(ConfirmLocalPaymentFailure(failure)),
      onSuccess: (data) => emit(ConfirmLocalPaymentLoaded(data)),
    );
  }
}
