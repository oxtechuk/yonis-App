import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/use_cases/get_profile_user_use_case.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Emitted when there is no usable token (expired/invalid session,
/// HTTP 401). The page reacts by showing the sign-in gate.
final class ProfileUnauthorized extends ProfileState {
  const ProfileUnauthorized();
}

final class ProfileError extends ProfileState {
  const ProfileError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required GetProfileUserUseCase getProfileUserUseCase})
      : _getProfileUserUseCase = getProfileUserUseCase,
        super(const ProfileInitial());

  final GetProfileUserUseCase _getProfileUserUseCase;

  Future<void> load() async {
    emit(const ProfileLoading());
    final result = await _getProfileUserUseCase.call();
    result.fold(
      onFailure: (failure) => emit(
        failure is UnauthorizedFailure
            ? const ProfileUnauthorized()
            : ProfileError(failure),
      ),
      onSuccess: (user) => emit(ProfileLoaded(user)),
    );
  }
}
