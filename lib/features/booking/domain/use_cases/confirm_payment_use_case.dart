import '../../../../core/result/result.dart';
import '../entities/confirm_payment_result.dart';
import '../repositories/checkout_repository.dart';

class ConfirmPaymentUseCase {
  const ConfirmPaymentUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Result<ConfirmPaymentResult>> call({
    required String bookingRef,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    required String receiptImagePath,
  }) =>
      _repository.confirmPayment(
        bookingRef: bookingRef,
        paymentMethod: paymentMethod,
        transferNumber: transferNumber,
        transactionReference: transactionReference,
        receiptImagePath: receiptImagePath,
      );
}
