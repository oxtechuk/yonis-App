import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/checkout_result.dart';
import '../../domain/use_cases/initialize_checkout_use_case.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

final class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting();
}

/// Reached for both a successful booking (`result.success == true`) and a
/// business-rejected one (e.g. slot just taken — `result.success == false`
/// with `result.message` set). Neither is a transport error.
final class CheckoutLoaded extends CheckoutState {
  const CheckoutLoaded(this.result);

  final CheckoutResult result;

  @override
  List<Object?> get props => [result];
}

final class CheckoutError extends CheckoutState {
  const CheckoutError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({required InitializeCheckoutUseCase initializeCheckoutUseCase})
      : _initializeCheckoutUseCase = initializeCheckoutUseCase,
        super(const CheckoutInitial());

  final InitializeCheckoutUseCase _initializeCheckoutUseCase;

  Future<void> submit({
    required int serviceId,
    required String bookingType,
    required String consultationType,
    required String paymentMethod,
    required String date,
    required String startTime,
    required String title,
    String? notes,
    String? name,
    String? phone,
    String? email,
    String? password,
  }) async {
    emit(const CheckoutSubmitting());
    final result = await _initializeCheckoutUseCase.call(
      serviceId: serviceId,
      bookingType: bookingType,
      consultationType: consultationType,
      paymentMethod: paymentMethod,
      date: date,
      startTime: startTime,
      title: title,
      notes: notes,
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
    result.fold(
      onFailure: (failure) => emit(CheckoutError(failure)),
      onSuccess: (data) => emit(CheckoutLoaded(data)),
    );
  }
}
