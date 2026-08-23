import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.welcome_title.tr(),
            textAlign: TextAlign.center,
            // Use headline token directly — no fontSize override
            style: AppTextStyles.headline.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LocaleKeys.welcome_subtitle.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.headline.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
