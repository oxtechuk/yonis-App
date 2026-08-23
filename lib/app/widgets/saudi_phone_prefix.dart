import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';
import '../styles/app_text_styles.dart';

/// Country-code adornment (🇸🇦 +966) for Saudi phone number fields.
class SaudiPhonePrefix extends StatelessWidget {
  const SaudiPhonePrefix({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: AppSpacing.sm),
          const Text('🇸🇦', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '+966',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }
}
