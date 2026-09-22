import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/login_response_dto.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/app_config_links.dart';
import '../models/app_config_links_dto.dart';

abstract interface class ProfileRemoteDataSource {
  Future<User> getUser();

  Future<AppConfigLinks> getConfigLinks();

  Future<void> deleteAccount();
}

class ApiProfileRemoteDataSource implements ProfileRemoteDataSource {
  const ApiProfileRemoteDataSource(this._apiClient);

  /// Authenticated endpoint: the access token persisted at login is
  /// attached automatically by [AuthInterceptor] as
  /// `Authorization: Bearer <token>` — callers never pass it manually.
  static const String _userPath = '/api/user';

  /// Public remote-config endpoint serving store/policy/terms links.
  static const String _configPath = '/api/config';

  final ApiClient _apiClient;

  @override
  Future<User> getUser() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_userPath);
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

  @override
  Future<AppConfigLinks> getConfigLinks() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_configPath);
    // Flat shape: {"success": true, "app_rating_url": ..., ...}.
    // Tolerates a nested {"data": {...}} envelope just in case.
    final dataJson = json['data'];
    if (dataJson is Map<String, dynamic>) {
      return AppConfigLinksDto.fromJson(dataJson).toEntity();
    }
    return AppConfigLinksDto.fromJson(json).toEntity();
  }

  @override
  Future<void> deleteAccount() async {
    // Authenticated RESTful user account deletion request.
    try {
      await _apiClient.delete<dynamic>(_userPath);
    } catch (_) {
      await _apiClient.post<dynamic>('$_userPath/delete');
    }
  }
}
