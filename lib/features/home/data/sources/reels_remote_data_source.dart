import '../../../../core/network/api_client.dart';
import '../models/reels_dto.dart';

abstract interface class ReelsRemoteDataSource {
  Future<ReelsResponseDto> getReels();
}

class ApiReelsRemoteDataSource implements ReelsRemoteDataSource {
  const ApiReelsRemoteDataSource(this._apiClient);

  static const String _reelsPath = '/api/reels';

  final ApiClient _apiClient;

  @override
  Future<ReelsResponseDto> getReels() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_reelsPath);
    return ReelsResponseDto.fromJson(json);
  }
}