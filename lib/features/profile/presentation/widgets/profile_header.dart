import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Avatar — right side visually (first child in RTL)
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.border,
            child: Icon(Icons.person, size: 36, color: Color(0xFFBDBDBD)),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name + subtitle
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'احمد الخميسي',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'تفاصيل الحساب',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Back chevron — left side visually, flipped for RTL
          const Spacer(),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 28,
          ),
        ],
      ),
    );
  }
}
