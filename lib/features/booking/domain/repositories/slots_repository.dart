import '../../../../core/result/result.dart';
import '../entities/time_slot.dart';

abstract interface class SlotsRepository {
  Future<Result<List<TimeSlot>>> getSlots({
    required int serviceId,
    required String date,
  });
}
