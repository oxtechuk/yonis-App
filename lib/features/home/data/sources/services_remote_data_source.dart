import '../../../../core/network/api_client.dart';
import '../models/service_dto.dart';

abstract interface class ServicesRemoteDataSource {
  Future<ServicesResponseDto> getClinicServices();

  Future<ServicesResponseDto> getOnlineServices();
}

class ApiServicesRemoteDataSource implements ServicesRemoteDataSource {
  const ApiServicesRemoteDataSource(this._apiClient);

  static const String _clinicPath = '/api/services/clinic';
  static const String _onlinePath = '/api/services/online';

  final ApiClient _apiClient;

  @override
  Future<ServicesResponseDto> getClinicServices() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_clinicPath);
    return ServicesResponseDto.fromJson(json);
  }

  @override
  Future<ServicesResponseDto> getOnlineServices() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_onlinePath);
    return ServicesResponseDto.fromJson(json);
  }
}
