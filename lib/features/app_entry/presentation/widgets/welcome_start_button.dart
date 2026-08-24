import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

/// Full-width white CTA that enters the guest-first main shell.
class WelcomeStartButton extends StatelessWidget {
  const WelcomeStartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeight,
        child: FilledButton(
          onPressed: () => context.go(AppRoutes.home),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            shape: const StadiumBorder(),
            textStyle: AppTextStyles.button.copyWith(fontSize: 16),
          ),
          child: Text(context.tr(LocaleKeys.welcome_startNow)),
        ),
      ),
    );
  }
}
