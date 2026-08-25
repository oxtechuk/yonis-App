import '../../../../core/network/api_client.dart';
import '../models/login_response_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseDto> login({
    required String identifier,
    required String password,
  });
}

class ApiAuthRemoteDataSource implements AuthRemoteDataSource {
  const ApiAuthRemoteDataSource(this._apiClient);

  static const String _loginPath = '/api/login';

  final ApiClient _apiClient;

  @override
  Future<LoginResponseDto> login({
    required String identifier,
    required String password,
  }) async {
    final json = await _apiClient.post<Map<String, dynamic>>(
      _loginPath,
      data: <String, dynamic>{
        'login': identifier,
        'password': password,
      },
    );
    return LoginResponseDto.fromJson(json);
  }
}
