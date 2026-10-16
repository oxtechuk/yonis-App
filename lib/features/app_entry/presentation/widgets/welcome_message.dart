import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({
    super.key,
    this.title,
    this.subtitle,
  });

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = (title != null && title!.trim().isNotEmpty)
        ? title!.trim()
        : context.tr(LocaleKeys.welcome_title);
    final resolvedSubtitle = (subtitle != null && subtitle!.trim().isNotEmpty)
        ? subtitle!.trim()
        : context.tr(LocaleKeys.welcome_subtitle);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            resolvedTitle,
            textAlign: TextAlign.center,
            // Use headline token directly — no fontSize override
            style: AppTextStyles.headline.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            resolvedSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
