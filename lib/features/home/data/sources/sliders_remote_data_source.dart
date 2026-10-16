import '../../../../core/network/api_client.dart';
import '../models/sliders_dto.dart';

abstract interface class SlidersRemoteDataSource {
  Future<SlidersResponseDto> getSliders();
}

class ApiSlidersRemoteDataSource implements SlidersRemoteDataSource {
  const ApiSlidersRemoteDataSource(this._apiClient);

  static const String _slidersPath = '/api/sliders';

  final ApiClient _apiClient;

  @override
  Future<SlidersResponseDto> getSliders() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_slidersPath);
    return SlidersResponseDto.fromJson(json);
  }
}
