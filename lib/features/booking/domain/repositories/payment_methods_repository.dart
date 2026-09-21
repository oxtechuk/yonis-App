import '../../../../core/result/result.dart';
import '../entities/payment_method_option.dart';

abstract interface class PaymentMethodsRepository {
  Future<Result<PaymentMethodsConfig>> getPaymentMethods({
    bool activeOnly = true,
  });
}
