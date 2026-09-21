import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/payment_method_option.dart';
import '../../domain/use_cases/get_payment_methods_use_case.dart';

sealed class PaymentMethodsState extends Equatable {
  const PaymentMethodsState();

  @override
  List<Object?> get props => [];
}

final class PaymentMethodsInitial extends PaymentMethodsState {
  const PaymentMethodsInitial();
}

final class PaymentMethodsLoading extends PaymentMethodsState {
  const PaymentMethodsLoading();
}

final class PaymentMethodsLoaded extends PaymentMethodsState {
  const PaymentMethodsLoaded(this.config);

  final PaymentMethodsConfig config;

  /// Only the methods the UI should offer (enabled ones).
  List<PaymentMethodOption> get methods =>
      config.methods.where((m) => m.isEnabled).toList();

  @override
  List<Object?> get props => [config];
}

final class PaymentMethodsError extends PaymentMethodsState {
  const PaymentMethodsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  PaymentMethodsCubit({
    required GetPaymentMethodsUseCase getPaymentMethodsUseCase,
  })  : _getPaymentMethodsUseCase = getPaymentMethodsUseCase,
        super(const PaymentMethodsInitial());

  final GetPaymentMethodsUseCase _getPaymentMethodsUseCase;

  Future<void> load() async {
    if (state is PaymentMethodsLoading) return;
    emit(const PaymentMethodsLoading());
    final result = await _getPaymentMethodsUseCase.call(activeOnly: true);
    result.fold(
      onFailure: (failure) => emit(PaymentMethodsError(failure)),
      onSuccess: (data) => emit(PaymentMethodsLoaded(data)),
    );
  }
}
