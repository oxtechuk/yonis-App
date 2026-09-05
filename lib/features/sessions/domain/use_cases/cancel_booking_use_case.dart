import '../../../../core/result/result.dart';
import '../repositories/bookings_repository.dart';

class CancelBookingUseCase {
  const CancelBookingUseCase(this._repository);

  final BookingsRepository _repository;

  Future<Result<String?>> call({required String bookingId}) =>
      _repository.cancelBooking(bookingId: bookingId);
}
