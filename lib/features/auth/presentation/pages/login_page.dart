import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_images.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../widgets/login_form.dart';
import '../widgets/login_no_account_card.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.onGuestBooking});

  /// Called when the user taps the no-account CTA.
  final VoidCallback? onGuestBooking;

  static void show(
    BuildContext context, {
    VoidCallback? onGuestBooking,
  }) {
    // Capture router before any potential pop that deactivates context
    final router = GoRouter.of(context);
    router.push(
      AppRoutes.login,
      extra: onGuestBooking,
    );
  }

  void _pop(BuildContext context) => context.pop();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                _BackButton(onTap: () => _pop(context)),
                const _Logo(),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  LocaleKeys.auth_loginTitle.tr(),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const LoginForm(),
                const SizedBox(height: AppSpacing.lg),
                LoginNoAccountCard(onTap: onGuestBooking),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Back arrow — aligned to the leading edge (right in RTL).
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: onTap,
        icon: const Icon(
          Icons.arrow_forward,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppImages.mainLogo,
        width: MediaQuery.sizeOf(context).width * 0.50,
        fit: BoxFit.contain,
      ),
    );
  }
}
