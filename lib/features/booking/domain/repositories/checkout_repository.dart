import '../../../../core/result/result.dart';
import '../entities/check_user_result.dart';
import '../entities/checkout_result.dart';

abstract interface class CheckoutRepository {
  Future<Result<CheckUserResult>> checkUser({required String phone});

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
  });
}
