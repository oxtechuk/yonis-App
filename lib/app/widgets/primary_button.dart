import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_sizes.dart';
import '../styles/app_text_styles.dart';

/// Pill-shaped brand-primary CTA shared across features.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
