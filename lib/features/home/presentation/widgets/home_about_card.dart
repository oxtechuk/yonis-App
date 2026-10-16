import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class HomeAboutCard extends StatelessWidget {
  const HomeAboutCard({
    super.key,
    this.title,
    this.bio,
  });

  /// Doctor title from the profile API.
  final String? title;

  /// Doctor bio from the profile API.
  final String? bio;

  @override
  Widget build(BuildContext context) {
    final headerText = title?.trim() ?? '';
    final bodyText = bio?.trim() ?? '';
    if (headerText.isEmpty && bodyText.isEmpty) {
      return const SizedBox.shrink();
    }

    final isRtl = context.locale.languageCode == 'ar';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
                child: Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (headerText.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  headerText,
                                  style: AppTextStyles.title.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (bodyText.isNotEmpty)
                            const SizedBox(height: AppSpacing.sm),
                        ],
                        if (bodyText.isNotEmpty)
                          Text(
                            bodyText,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.8,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 6, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
