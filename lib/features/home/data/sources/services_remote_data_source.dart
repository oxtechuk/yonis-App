import '../../../../core/network/api_client.dart';
import '../models/service_dto.dart';

abstract interface class ServicesRemoteDataSource {
  Future<ServicesResponseDto> getServices();
}

class ApiServicesRemoteDataSource implements ServicesRemoteDataSource {
  const ApiServicesRemoteDataSource(this._apiClient);

  static const String _servicesPath = '/api/services';

  final ApiClient _apiClient;

  @override
  Future<ServicesResponseDto> getServices() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_servicesPath);
    return ServicesResponseDto.fromJson(json);
  }
}
