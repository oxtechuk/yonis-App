import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/reel.dart';
import '../../domain/use_cases/get_reels_use_case.dart';

sealed class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object?> get props => [];
}

final class ReelsInitial extends ReelsState {
  const ReelsInitial();
}

final class ReelsLoading extends ReelsState {
  const ReelsLoading();
}

final class ReelsLoaded extends ReelsState {
  const ReelsLoaded(this.reels);

  final List<Reel> reels;

  @override
  List<Object?> get props => [reels];
}

final class ReelsError extends ReelsState {
  const ReelsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class ReelsCubit extends Cubit<ReelsState> {
  ReelsCubit({required GetReelsUseCase getReelsUseCase})
      : _getReelsUseCase = getReelsUseCase,
        super(const ReelsInitial());

  final GetReelsUseCase _getReelsUseCase;

  Future<void> load() async {
    emit(const ReelsLoading());
    final result = await _getReelsUseCase.call();
    result.fold(
      onFailure: (failure) => emit(ReelsError(failure)),
      onSuccess: (reels) => emit(ReelsLoaded(reels)),
    );
  }
}