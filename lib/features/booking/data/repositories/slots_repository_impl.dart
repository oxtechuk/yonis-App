import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/slots_repository.dart';
import '../sources/slots_remote_data_source.dart';

class SlotsRepositoryImpl implements SlotsRepository {
  const SlotsRepositoryImpl({required SlotsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final SlotsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<TimeSlot>>> getSlots({
    required int serviceId,
    required String date,
  }) async {
    try {
      final dto = await _remoteDataSource.getSlots(serviceId: serviceId, date: date);
      return Success(dto.slots.map((s) => s.toEntity()).toList(growable: false));
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
