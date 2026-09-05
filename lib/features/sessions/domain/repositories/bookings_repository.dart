import '../../../../core/result/result.dart';
import '../../domain/entities/patient_booking.dart';

abstract interface class BookingsRepository {
  Future<Result<List<PatientBooking>>> getBookings({String? tab});

  /// Cancels one booking; success carries the backend message, if any.
  Future<Result<String?>> cancelBooking({required String bookingId});
}
