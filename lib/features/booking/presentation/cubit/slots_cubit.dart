import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/use_cases/get_slots_use_case.dart';

sealed class SlotsState extends Equatable {
  const SlotsState();

  @override
  List<Object?> get props => [];
}

final class SlotsInitial extends SlotsState {
  const SlotsInitial();
}

final class SlotsLoading extends SlotsState {
  const SlotsLoading();
}

final class SlotsLoaded extends SlotsState {
  const SlotsLoaded(this.slots);

  final List<TimeSlot> slots;

  @override
  List<Object?> get props => [slots];
}

final class SlotsError extends SlotsState {
  const SlotsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class SlotsCubit extends Cubit<SlotsState> {
  SlotsCubit({required GetSlotsUseCase getSlotsUseCase})
      : _getSlotsUseCase = getSlotsUseCase,
        super(const SlotsInitial());

  final GetSlotsUseCase _getSlotsUseCase;

  /// The (serviceId, date) this cubit last fetched for or is fetching now.
  /// A stale in-flight response for a previously requested date is dropped
  /// so a fast date switch can't clobber the currently selected day's slots.
  (int, String)? _requestedFor;

  Future<void> load({required int serviceId, required String date}) async {
    final request = (serviceId, date);
    _requestedFor = request;
    emit(const SlotsLoading());
    final result = await _getSlotsUseCase.call(serviceId: serviceId, date: date);
    if (_requestedFor != request) return;
    result.fold(
      onFailure: (failure) => emit(SlotsError(failure)),
      onSuccess: (slots) => emit(SlotsLoaded(slots)),
    );
  }
}
