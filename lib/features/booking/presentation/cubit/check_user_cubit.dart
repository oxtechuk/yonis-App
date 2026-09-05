import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/check_user_result.dart';
import '../../domain/use_cases/check_user_use_case.dart';

sealed class CheckUserState extends Equatable {
  const CheckUserState();

  @override
  List<Object?> get props => [];
}

/// Phone not checked yet — show the phone entry step.
final class CheckUserInitial extends CheckUserState {
  const CheckUserInitial();
}

final class CheckUserLoading extends CheckUserState {
  const CheckUserLoading();
}

final class CheckUserLoaded extends CheckUserState {
  const CheckUserLoaded(this.result);

  final CheckUserResult result;

  @override
  List<Object?> get props => [result];
}

final class CheckUserError extends CheckUserState {
  const CheckUserError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class CheckUserCubit extends Cubit<CheckUserState> {
  CheckUserCubit({required CheckUserUseCase checkUserUseCase})
      : _checkUserUseCase = checkUserUseCase,
        super(const CheckUserInitial());

  final CheckUserUseCase _checkUserUseCase;

  Future<void> check(String phone) async {
    emit(const CheckUserLoading());
    final result = await _checkUserUseCase.call(phone: phone);
    result.fold(
      onFailure: (failure) => emit(CheckUserError(failure)),
      onSuccess: (data) => emit(CheckUserLoaded(data)),
    );
  }

  /// Returns to the phone entry step, e.g. when the user taps "not you?".
  void reset() => emit(const CheckUserInitial());
}
