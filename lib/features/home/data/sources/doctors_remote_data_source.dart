import '../../../../core/network/api_client.dart';
import '../models/doctors_dto.dart';

abstract interface class DoctorsRemoteDataSource {
  Future<DoctorsResponseDto> getDoctors();
}

class ApiDoctorsRemoteDataSource implements DoctorsRemoteDataSource {
  const ApiDoctorsRemoteDataSource(this._apiClient);

  static const String _doctorsPath = '/api/doctors';

  final ApiClient _apiClient;

  @override
  Future<DoctorsResponseDto> getDoctors() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_doctorsPath);
    return DoctorsResponseDto.fromJson(json);
  }
}
