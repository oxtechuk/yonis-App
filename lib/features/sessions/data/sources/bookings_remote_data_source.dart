import '../../../../core/network/api_client.dart';
import '../models/patient_booking_dto.dart';

abstract interface class BookingsRemoteDataSource {
  /// Fetches one tab (`upcoming`/`completed`/`cancelled`). A null [tab]
  /// fetches everything (no query parameter).
  Future<List<PatientBookingDto>> getBookings({String? tab});

  /// Cancels one booking. Returns the backend message, if any.
  Future<String?> cancelBooking({required String bookingId});
}

class ApiBookingsRemoteDataSource implements BookingsRemoteDataSource {
  const ApiBookingsRemoteDataSource(this._apiClient);

  /// Authenticated endpoint: the access token persisted at login is
  /// attached automatically by [AuthInterceptor] as
  /// `Authorization: Bearer <token>` — callers never pass it manually.
  static const String _path = '/api/patient/bookings';

  final ApiClient _apiClient;

  @override
  Future<List<PatientBookingDto>> getBookings({String? tab}) async {
    final json = await _apiClient.get<dynamic>(
      _path,
      queryParameters: tab == null ? null : {'tab': tab},
    );
    return PatientBookingDto.listFromJson(json);
  }

  @override
  Future<String?> cancelBooking({required String bookingId}) async {
    final json = await _apiClient.post<dynamic>(
      '/api/booking/$bookingId/cancel',
    );
    if (json is Map<String, dynamic>) {
      final message = json['message'];
      return message is String ? message : null;
    }
    return null;
  }
}
