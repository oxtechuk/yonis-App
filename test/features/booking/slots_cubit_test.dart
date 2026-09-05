import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/core/error/failure.dart';
import 'package:younis_app/core/result/result.dart';
import 'package:younis_app/features/booking/domain/entities/time_slot.dart';
import 'package:younis_app/features/booking/domain/repositories/slots_repository.dart';
import 'package:younis_app/features/booking/domain/use_cases/get_slots_use_case.dart';
import 'package:younis_app/features/booking/presentation/cubit/slots_cubit.dart';

class _FakeSlotsRepository implements SlotsRepository {
  _FakeSlotsRepository(this._resultsByDate);

  final Map<String, Result<List<TimeSlot>>> _resultsByDate;
  final List<String> requestedDates = [];

  @override
  Future<Result<List<TimeSlot>>> getSlots({
    required int serviceId,
    required String date,
  }) async {
    requestedDates.add(date);
    return _resultsByDate[date] ?? const Success([]);
  }
}

void main() {
  test('load emits loading then loaded with the fetched slots', () async {
    final repo = _FakeSlotsRepository({
      '2026-10-15': const Success([
        TimeSlot(start: '09:00', end: '09:30'),
        TimeSlot(start: '09:15', end: '09:45'),
      ]),
    });
    final cubit = SlotsCubit(getSlotsUseCase: GetSlotsUseCase(repo));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const SlotsLoading(),
        isA<SlotsLoaded>().having((s) => s.slots.length, 'length', 2),
      ]),
    );

    await cubit.load(serviceId: 1, date: '2026-10-15');
    await expectation;
    await cubit.close();
  });

  test('load emits an error state on failure', () async {
    final repo = _FakeSlotsRepository({
      '2026-10-15': const FailureResult(NetworkFailure()),
    });
    final cubit = SlotsCubit(getSlotsUseCase: GetSlotsUseCase(repo));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([const SlotsLoading(), isA<SlotsError>()]),
    );

    await cubit.load(serviceId: 1, date: '2026-10-15');
    await expectation;
    await cubit.close();
  });

  test('a stale response for a previous date does not overwrite the '
      'latest request', () async {
    final repo = _FakeSlotsRepository({
      '2026-10-15': const Success([TimeSlot(start: '09:00', end: '09:30')]),
      '2026-10-16': const Success([TimeSlot(start: '10:00', end: '10:30')]),
    });
    final cubit = SlotsCubit(getSlotsUseCase: GetSlotsUseCase(repo));

    // Fire both without awaiting the first — simulates a fast date switch.
    final first = cubit.load(serviceId: 1, date: '2026-10-15');
    final second = cubit.load(serviceId: 1, date: '2026-10-16');
    await Future.wait([first, second]);

    final state = cubit.state;
    expect(state, isA<SlotsLoaded>());
    expect(
      (state as SlotsLoaded).slots.single.start,
      '10:00',
      reason: 'the later request (2026-10-16) must win',
    );

    await cubit.close();
  });

  test('TimeSlot formats 24h times as Arabic 12h labels', () {
    expect(const TimeSlot(start: '09:00', end: '09:30').displayStart, '٩:٠٠ ص');
    expect(const TimeSlot(start: '13:15', end: '13:45').displayStart, '١:١٥ م');
    expect(const TimeSlot(start: '00:00', end: '00:30').displayStart, '١٢:٠٠ ص');
  });

  test('TimeSlot.displayRange joins the start and end labels', () {
    expect(
      const TimeSlot(start: '09:00', end: '09:30').displayRange,
      '٩:٠٠ ص - ٩:٣٠ ص',
    );
  });
}
