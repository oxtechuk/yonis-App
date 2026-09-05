import '../../../../core/result/result.dart';
import '../entities/patient_booking.dart';
import '../repositories/bookings_repository.dart';

class GetBookingsUseCase {
  const GetBookingsUseCase(this._repository);

  final BookingsRepository _repository;

  Future<Result<List<PatientBooking>>> call({String? tab}) =>
      _repository.getBookings(tab: tab);
}
