import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/splash_config.dart';
import '../../domain/use_cases/get_splash_config_use_case.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashLoaded extends SplashState {
  const SplashLoaded(this.config);

  final SplashConfig config;

  @override
  List<Object?> get props => [config];
}

final class SplashError extends SplashState {
  const SplashError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required GetSplashConfigUseCase getSplashConfigUseCase})
      : _getSplashConfigUseCase = getSplashConfigUseCase,
        super(const SplashInitial());

  final GetSplashConfigUseCase _getSplashConfigUseCase;

  Future<void> load() async {
    emit(const SplashLoading());
    final result = await _getSplashConfigUseCase.call();
    if (isClosed) return;
    result.fold(
      onFailure: (failure) => emit(SplashError(failure)),
      onSuccess: (config) => emit(SplashLoaded(config)),
    );
  }
}
