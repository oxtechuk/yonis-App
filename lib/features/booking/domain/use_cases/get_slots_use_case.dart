import '../../../../core/result/result.dart';
import '../entities/time_slot.dart';
import '../repositories/slots_repository.dart';

class GetSlotsUseCase {
  const GetSlotsUseCase(this._repository);

  final SlotsRepository _repository;

  Future<Result<List<TimeSlot>>> call({
    required int serviceId,
    required String date,
  }) =>
      _repository.getSlots(serviceId: serviceId, date: date);
}
