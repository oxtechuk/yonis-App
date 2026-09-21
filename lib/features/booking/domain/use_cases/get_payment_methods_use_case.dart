import '../../../../core/result/result.dart';
import '../entities/payment_method_option.dart';
import '../repositories/payment_methods_repository.dart';

class GetPaymentMethodsUseCase {
  const GetPaymentMethodsUseCase(this._repository);

  final PaymentMethodsRepository _repository;

  Future<Result<PaymentMethodsConfig>> call({bool activeOnly = true}) =>
      _repository.getPaymentMethods(activeOnly: activeOnly);
}
