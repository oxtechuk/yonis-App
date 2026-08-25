import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/use_cases/login_use_case.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class LoginError extends LoginState {
  const LoginError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(const LoginInitial());

  final LoginUseCase _loginUseCase;

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    emit(const LoginLoading());
    final result = await _loginUseCase.call(
      identifier: identifier,
      password: password,
    );
    result.fold(
      onFailure: (failure) => emit(LoginError(failure)),
      onSuccess: (session) => emit(LoginSuccess(session.user)),
    );
  }
}
