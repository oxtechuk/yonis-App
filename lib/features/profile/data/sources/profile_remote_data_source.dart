import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/login_response_dto.dart';
import '../../../auth/domain/entities/user.dart';

abstract interface class ProfileRemoteDataSource {
  Future<User> getUser();
}

class ApiProfileRemoteDataSource implements ProfileRemoteDataSource {
  const ApiProfileRemoteDataSource(this._apiClient);

  /// Authenticated endpoint: the access token persisted at login is
  /// attached automatically by [AuthInterceptor] as
  /// `Authorization: Bearer <token>` — callers never pass it manually.
  static const String _path = '/api/user';

  final ApiClient _apiClient;

  @override
  Future<User> getUser() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_path);
    // Login-style nesting: {"user": {...}}.
    final userJson = json['user'];
    if (userJson is Map<String, dynamic>) {
      return UserDto.fromJson(userJson).toEntity();
    }
    // Common API envelope: {"data": {...}}.
    final dataJson = json['data'];
    if (dataJson is Map<String, dynamic>) {
      return UserDto.fromJson(dataJson).toEntity();
    }
    // Standard Laravel `GET /api/user` returns the user object directly.
    if (json.containsKey('id')) {
      return UserDto.fromJson(json).toEntity();
    }
    throw const SerializationException(
      message: 'User response is missing the "user" object.',
    );
  }
}
