import '../../../../core/result/result.dart';
import '../entities/confirm_payment_result.dart';
import '../repositories/checkout_repository.dart';

class ConfirmLocalPaymentUseCase {
  const ConfirmLocalPaymentUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Result<ConfirmPaymentResult>> call({
    required String bookingReference,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    String? notes,
  }) =>
      _repository.confirmLocalPayment(
        bookingReference: bookingReference,
        paymentMethod: paymentMethod,
        transferNumber: transferNumber,
        transactionReference: transactionReference,
        notes: notes,
      );
}
