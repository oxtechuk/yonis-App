import '../../../../core/result/result.dart';
import '../entities/checkout_result.dart';
import '../repositories/checkout_repository.dart';

class InitializeCheckoutUseCase {
  const InitializeCheckoutUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Result<CheckoutResult>> call({
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
  }) =>
      _repository.initializeCheckout(
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
}
