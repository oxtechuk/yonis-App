import '../../../../core/network/api_client.dart';
import '../models/doctor_profile_dto.dart';

abstract interface class DoctorProfileRemoteDataSource {
  Future<DoctorProfileDto> getDoctorProfile();
}

class ApiDoctorProfileRemoteDataSource implements DoctorProfileRemoteDataSource {
  const ApiDoctorProfileRemoteDataSource(this._apiClient);

  static const String _profilePath = 'api/doctor/profile';

  final ApiClient _apiClient;

  @override
  Future<DoctorProfileDto> getDoctorProfile() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_profilePath);
    return DoctorProfileDto.fromResponseJson(json);
  }
}
