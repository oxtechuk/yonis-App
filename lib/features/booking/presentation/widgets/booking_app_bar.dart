import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

/// White flow header with a leading (RTL) back arrow and centered [title].
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
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          Text(
            title,
            style: AppTextStyles.title.copyWith(
              color: AppColors.textPrimary,
              fontWeight: titleFontWeight,
            ),
          ),
          const Spacer(),
          // Balances the back arrow so the title stays optically centered.
          const SizedBox(width: AppSizes.iconMd),
        ],
      ),
    );
  }
}
