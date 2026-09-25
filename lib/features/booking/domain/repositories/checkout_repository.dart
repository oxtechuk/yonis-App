import '../../../../core/result/result.dart';
import '../entities/check_user_result.dart';
import '../entities/checkout_result.dart';
import '../entities/confirm_payment_result.dart';

abstract interface class CheckoutRepository {
  Future<Result<CheckUserResult>> checkUser({required String phone});

  /// Submits the payment proof (screenshot + transfer details) for a
  /// booking created by [initializeCheckout].
  Future<Result<ConfirmPaymentResult>> confirmPayment({
    required String bookingRef,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    required String receiptImagePath,
  });

  /// Final local-payment confirmation (`/api/payment/confirm-local`):
  /// a plain-JSON declaration of the transfer, submitted after the receipt
  /// image in [confirmPayment].
  Future<Result<ConfirmPaymentResult>> confirmLocalPayment({
    required String bookingReference,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    String? notes,
  });

  /// Starts a booking + payment session.
  ///
  /// [name]/[phone]/[email]/[password] are only sent for a guest who was
  /// NOT found by `checkUser` — pass them all null for a recognized
  /// account, which is instead identified by the auth token the API client
  /// already attaches to every request when one is persisted.
  Future<Result<CheckoutResult>> initializeCheckout({
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
    String? transferNumber,
    String? receiptImagePath,
  });
}
