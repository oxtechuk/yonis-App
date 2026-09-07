import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../../../app/widgets/login_required_view.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _checkingAuth = true;
  bool _loggedIn = false;
  bool _loginPushing = false;
  bool _autoLoginAttempted = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  /// Same gate as the sessions tab: without a persisted token there is
  /// nothing `GET /api/user` could return, so the sign-in view is shown
  /// instead of firing an unauthenticated request.
  Future<void> _checkAuthAndLoad() async {
    // Fast path: already logged in this run — no storage read, no flash.
    if (AuthState.instance.isLoggedIn) {
      if (!mounted) return;
      setState(() {
        _checkingAuth = false;
        _loggedIn = true;
      });
      if (mounted) context.read<ProfileCubit>().load();
      return;
    }
    String? token;
    try {
      token = await getIt<SecureStorage>().read(
        SecureStorageKeys.accessToken,
      );
    } catch (_) {
      token = null;
    }
    if (!mounted) return;
    final loggedIn = token != null && token.trim().isNotEmpty;
    setState(() {
      _checkingAuth = false;
      _loggedIn = loggedIn;
    });
    if (loggedIn) {
      AuthState.instance.login();
      if (mounted) context.read<ProfileCubit>().load();
    } else if (!_autoLoginAttempted) {
      // First unauthenticated visit: open login directly from here so we
      // don't flash the profile skeleton in _buildBody first.
      _autoLoginAttempted = true;
      _redirectToLogin();
    }
  }

  Future<void> _goToLogin({bool leaveOnCancel = false}) async {
    // Push login on top of this tab. On success LoginForm pops back here,
    // then we re-check auth + reload profile.
    await context.push(AppRoutes.login);
    if (!mounted) return;
    // Auto-push was cancelled (back button): pop this gated tab as well so
    // the user lands back on the screen they came from (home) instead of
    // an empty gate. Manual logins from the gate button stay put.
    if (leaveOnCancel && !AuthState.instance.isLoggedIn) {
      String? token;
      try {
        token = await getIt<SecureStorage>().read(
          SecureStorageKeys.accessToken,
        );
      } catch (_) {
        token = null;
      }
      if (!mounted) return;
      if (token == null || token.trim().isEmpty) {
        context.go(AppRoutes.home);
        return;
      }
    }
    setState(() => _checkingAuth = true);
    await _checkAuthAndLoad();
  }

  /// Auto login push for the first unauthenticated visit. On cancel it
  /// leaves this tab (pop back to the previous screen) instead of showing
  /// the gate.
  void _redirectToLogin() {
    if (_loginPushing) return;
    _loginPushing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted) return;
        await _goToLogin(leaveOnCancel: true);
      } finally {
        // Plain bool (no setState): must reset even when unmounted or on
        // error, otherwise the next visit sticks on the empty SizedBox
        // (white page) instead of the gate.
        _loginPushing = false;
      }
    });
  }

  Future<void> _logout() async {
    final storage = getIt<SecureStorage>();
    try {
      await storage.delete(SecureStorageKeys.accessToken);
    } catch (_) {}
    try {
      await storage.delete(SecureStorageKeys.refreshToken);
    } catch (_) {}
    AuthState.instance.logout();
    if (!mounted) return;
    setState(() => _loggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_checkingAuth) {
      // Token lookup, not profile loading: neutral loader so it doesn't
      // look like profile content flashing before the login redirect.
      return const Center(child: CircularProgressIndicator());
    }
    if (!_loggedIn) {
      // The auto-push of the login route (first visit) covers this while
      // open; if it is dismissed the gate stays visible so the tab never
      // renders blank.
      return LoginRequiredView(
        icon: Icons.person_outline,
        message: context.tr(LocaleKeys.profile_loginRequired),
        loginLabel: context.tr(LocaleKeys.auth_loginButton),
        onLogin: _goToLogin,
      );
    }
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return switch (state) {
          ProfileInitial() || ProfileLoading() => const ProfileSkeleton(),
          ProfileUnauthorized() => LoginRequiredView(
            icon: Icons.person_outline,
            message: context.tr(LocaleKeys.profile_loginRequired),
            loginLabel: context.tr(LocaleKeys.auth_loginButton),
            onLogin: _goToLogin,
          ),
          ProfileError(:final failure) => _ProfileErrorView(
              message: failure.message,
              onRetry: () => context.read<ProfileCubit>().load(),
            ),
          ProfileLoaded(:final user) => _buildProfile(context, user),
        };
      },
    );
  }

  Widget _buildProfile(BuildContext context, User user) {
    final subtitle = user.email.isNotEmpty
        ? user.email
        : user.phone.isNotEmpty
            ? user.phone
            : context.tr(LocaleKeys.profile_accountDetails);
    return Column(
      children: [
        ProfileHeader(name: user.name, subtitle: subtitle),
        const SizedBox(height: AppSpacing.sm),
        ProfileMenu(onLogout: _logout),
      ],
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: context.tr(LocaleKeys.common_retry),
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
