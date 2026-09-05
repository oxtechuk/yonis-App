import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/patient_booking.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../sources/bookings_remote_data_source.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  const BookingsRepositoryImpl({required BookingsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final BookingsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<PatientBooking>>> getBookings({String? tab}) async {
    try {
      final dtos = await _remoteDataSource.getBookings(tab: tab);
      return Success(
        dtos.map((dto) => dto.toEntity()).toList(growable: false),
      );
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }

  @override
  Future<Result<String?>> cancelBooking({required String bookingId}) async {
    try {
      final message = await _remoteDataSource.cancelBooking(
        bookingId: bookingId,
      );
      return Success(message);
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
