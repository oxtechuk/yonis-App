import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/core/error/app_exception.dart';
import 'package:younis_app/core/network/api_client.dart';
import 'package:younis_app/features/profile/data/sources/profile_remote_data_source.dart';

class _FakeApiClient implements ApiClient {
  _FakeApiClient(this.response);

  final dynamic response;
  String? lastPath;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPath = path;
    return response as T;
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      throw UnimplementedError();

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
  group('ApiProfileRemoteDataSource', () {
    test('requests /api/user and parses the real payload', () async {
      final client = _FakeApiClient({
        'success': true,
        'user': {
          'id': 11,
          'name': 'علي حيدر كاظم',
          'email': 'alisss.haider@example.com',
          'phone': '+96647719998877',
          'role': 'patient',
        },
      });
      final source = ApiProfileRemoteDataSource(client);

      final user = await source.getUser();

      expect(client.lastPath, '/api/user');
      expect(user.id, 11);
      expect(user.name, 'علي حيدر كاظم');
      expect(user.email, 'alisss.haider@example.com');
      expect(user.phone, '+96647719998877');
      expect(user.role, 'patient');
    });

    test('throws SerializationException when "user" is missing', () async {
      final client = _FakeApiClient({'success': true});
      final source = ApiProfileRemoteDataSource(client);

      expect(source.getUser(), throwsA(isA<SerializationException>()));
    });
  });
}
