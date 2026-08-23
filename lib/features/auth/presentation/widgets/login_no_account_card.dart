import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import 'login_primary_button.dart';

/// Screen-local card tint and corner radius (not part of the shared palette).
const Color _cardColor = Color(0xFFEAECF8);
const double _cardRadius = 16;

/// Card inviting users to book sessions without an account.
class LoginNoAccountCard extends StatelessWidget {
  const LoginNoAccountCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.white,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  LocaleKeys.auth_noAccountTitle.tr(),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LocaleKeys.auth_noAccountDesc.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LoginPrimaryButton(
            label: LocaleKeys.auth_startSessions.tr(),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
