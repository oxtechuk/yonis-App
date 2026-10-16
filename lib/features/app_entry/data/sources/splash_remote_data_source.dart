import '../../../../core/network/api_client.dart';
import '../models/splash_config_dto.dart';

abstract interface class SplashRemoteDataSource {
  Future<SplashConfigDto> getSplashConfig();
}

class ApiSplashRemoteDataSource implements SplashRemoteDataSource {
  const ApiSplashRemoteDataSource(this._apiClient);

  static const String _splashPath = '/api/splash';

  final ApiClient _apiClient;

  @override
  Future<SplashConfigDto> getSplashConfig() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_splashPath);
    return SplashConfigDto.fromResponseJson(json);
  }
}
