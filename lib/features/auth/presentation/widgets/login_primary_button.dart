import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_text_styles.dart';

/// Pill-shaped primary CTA shared by the login screen sections.
class LoginPrimaryButton extends StatelessWidget {
  const LoginPrimaryButton({super.key, required this.label, this.onPressed});

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
