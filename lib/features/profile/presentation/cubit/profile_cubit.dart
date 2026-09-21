import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/app_config_links.dart';
import '../../domain/use_cases/get_app_config_links_use_case.dart';
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
  const ProfileLoaded(this.user, [this.configLinks = const AppConfigLinks()]);

  final User user;

  /// Remote links from `GET /api/config`. Empty when the config fetch
  /// failed — the menu then disables/hides those entries instead of
  /// failing the whole profile.
  final AppConfigLinks configLinks;

  @override
  List<Object?> get props => [user, configLinks];
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
  ProfileCubit({
    required GetProfileUserUseCase getProfileUserUseCase,
    required GetAppConfigLinksUseCase getAppConfigLinksUseCase,
  })  : _getProfileUserUseCase = getProfileUserUseCase,
        _getAppConfigLinksUseCase = getAppConfigLinksUseCase,
        super(const ProfileInitial());

  final GetProfileUserUseCase _getProfileUserUseCase;
  final GetAppConfigLinksUseCase _getAppConfigLinksUseCase;

  Future<void> load() async {
    emit(const ProfileLoading());
    final userResult = await _getProfileUserUseCase.call();
    final userFailure = userResult.failureOrNull;
    if (userFailure != null) {
      emit(
        userFailure is UnauthorizedFailure
            ? const ProfileUnauthorized()
            : ProfileError(userFailure),
      );
      return;
    }
    final user = userResult.dataOrNull;
    if (user == null) {
      // Unreachable: Result is either Success(data) or FailureResult.
      return;
    }
    // Config is best-effort: a failure falls back to the last-known
    // links so the menu never ends up with dead entries.
    final configResult = await _getAppConfigLinksUseCase.call();
    final configFailure = configResult.failureOrNull;
    if (configFailure != null) {
      debugPrint('[profile] config failed: $configFailure');
    }
    // Use the remote links when present, but backfill any missing field
    // from the last-known-good set so a partial `/api/config` response
    // never leaves a menu entry pointing at an empty URL.
    final links = (configResult.dataOrNull ?? AppConfigLinks.fallback)
        .withFallback(AppConfigLinks.fallback);
    debugPrint('[profile] config links: $links');
    emit(ProfileLoaded(user, links));
  }
}
