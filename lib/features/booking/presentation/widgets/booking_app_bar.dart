import 'package:flutter/material.dart';

import '../../../../app/localization/locale_direction.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

/// White flow header with a leading back arrow (pointing per locale) and a
/// centered [title].
///
/// Shared by every step of the booking flow so the chrome stays identical.
class BookingAppBar extends StatelessWidget {
  const BookingAppBar({
    super.key,
    required this.title,
    required this.onBack,
    this.titleFontWeight,
  });

  final String title;
  final VoidCallback onBack;

  /// Overrides the default title weight when a step needs a bolder title.
  final FontWeight? titleFontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              context.isRtl ? Icons.arrow_forward : Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: titleFontWeight,
              ),
            ),
          ),
          // Balances the back arrow so the title stays optically centered.
          const SizedBox(width: AppSizes.iconMd),
        ],
      ),
    );
  }
}
