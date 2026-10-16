import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/home_slider.dart';
import '../../domain/use_cases/get_sliders_use_case.dart';

sealed class SlidersState extends Equatable {
  const SlidersState();

  @override
  List<Object?> get props => [];
}

final class SlidersInitial extends SlidersState {
  const SlidersInitial();
}

final class SlidersLoading extends SlidersState {
  const SlidersLoading();
}

final class SlidersLoaded extends SlidersState {
  const SlidersLoaded(this.sliders);

  final List<HomeSlider> sliders;

  @override
  List<Object?> get props => [sliders];
}

final class SlidersError extends SlidersState {
  const SlidersError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class SlidersCubit extends Cubit<SlidersState> {
  SlidersCubit({required GetSlidersUseCase getSlidersUseCase})
      : _getSlidersUseCase = getSlidersUseCase,
        super(const SlidersInitial());

  final GetSlidersUseCase _getSlidersUseCase;

  Future<void> load() async {
    emit(const SlidersLoading());
    final result = await _getSlidersUseCase.call();
    if (isClosed) return;
    result.fold(
      onFailure: (failure) => emit(SlidersError(failure)),
      onSuccess: (sliders) => emit(SlidersLoaded(sliders)),
    );
  }
}
