import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/core/network/api_client.dart';
import 'package:younis_app/features/sessions/data/sources/bookings_remote_data_source.dart';

class _FakeApiClient implements ApiClient {
  _FakeApiClient(this.response);

  final dynamic response;
  String? lastPath;
  Map<String, dynamic>? lastQueryParameters;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPath = path;
    lastQueryParameters = queryParameters;
    return response as T;
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPath = path;
    return response as T;
  }

  @override
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      throw UnimplementedError();

  @override
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      throw UnimplementedError();

  @override
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      throw UnimplementedError();
}

void main() {
  group('ApiBookingsRemoteDataSource', () {
    test('requests /api/patient/bookings with ?tab=upcoming', () async {
      final client = _FakeApiClient({
        'success': true,
        'bookings': [
          {'id': 30, 'status': 'AwaitingPayment'},
        ],
      });
      final source = ApiBookingsRemoteDataSource(client);

      final dtos = await source.getBookings(tab: 'upcoming');

      expect(client.lastPath, '/api/patient/bookings');
      expect(client.lastQueryParameters, {'tab': 'upcoming'});
      expect(dtos, hasLength(1));
      expect(dtos.first.id, '30');
    });

    test('sends no query parameters when tab is null', () async {
      final client = _FakeApiClient([
        {'id': 1, 'status': 'pending'},
      ]);
      final source = ApiBookingsRemoteDataSource(client);

      await source.getBookings();

      expect(client.lastPath, '/api/patient/bookings');
      expect(client.lastQueryParameters, isNull);
    });

    test('posts to /api/booking/{id}/cancel and returns the message',
        () async {
      final client = _FakeApiClient({
        'success': true,
        'message': 'Booking cancelled.',
      });
      final source = ApiBookingsRemoteDataSource(client);

      final message = await source.cancelBooking(bookingId: '30');

      expect(client.lastPath, '/api/booking/30/cancel');
      expect(message, 'Booking cancelled.');
    });

    test('cancel returns null when the body carries no message', () async {
      final client = _FakeApiClient({'success': true});
      final source = ApiBookingsRemoteDataSource(client);

      expect(await source.cancelBooking(bookingId: '30'), isNull);
    });
  });
}
