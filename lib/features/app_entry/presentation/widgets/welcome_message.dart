import 'package:flutter/material.dart';

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
    final resolvedTitle = title?.trim() ?? '';
    final resolvedSubtitle = subtitle?.trim() ?? '';

    if (resolvedTitle.isEmpty && resolvedSubtitle.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resolvedTitle.isNotEmpty)
            Text(
              resolvedTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(color: AppColors.white),
            ),
          if (resolvedTitle.isNotEmpty && resolvedSubtitle.isNotEmpty)
            const SizedBox(height: AppSpacing.sm),
          if (resolvedSubtitle.isNotEmpty)
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
