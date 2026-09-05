import '../../../../core/network/api_client.dart';
import '../models/time_slot_dto.dart';

abstract interface class SlotsRemoteDataSource {
  Future<SlotsResponseDto> getSlots({required int serviceId, required String date});
}

class ApiSlotsRemoteDataSource implements SlotsRemoteDataSource {
  const ApiSlotsRemoteDataSource(this._apiClient);

  static const String _path = '/api/slots';

  final ApiClient _apiClient;

  @override
  Future<SlotsResponseDto> getSlots({
    required int serviceId,
    required String date,
  }) async {
    final json = await _apiClient.get<Map<String, dynamic>>(
      _path,
      queryParameters: {'service_id': serviceId, 'date': date},
    );
    return SlotsResponseDto.fromJson(json);
  }
}
