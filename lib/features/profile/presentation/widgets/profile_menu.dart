import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import 'language_switcher_sheet.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.star_border_rounded,
            label: context.tr(LocaleKeys.profile_rateApp),
            onTap: () {},
          ),
          const _MenuDivider(),
          _MenuItem(
            icon: Icons.article_outlined,
            label: context.tr(LocaleKeys.profile_privacyPolicy),
            onTap: () {},
          ),
          const _MenuDivider(),
          _MenuItem(
            icon: Icons.menu_book_outlined,
            label: context.tr(LocaleKeys.profile_dataPrivacy),
            onTap: () {},
          ),
          const _MenuDivider(),
          _MenuItem(
            icon: Icons.language_rounded,
            label: context.tr(LocaleKeys.settings_language),
            onTap: () => showLanguageSwitcherSheet(context),
          ),
          const _MenuDivider(),
          _MenuItem(
            icon: Icons.logout_rounded,
            label: context.tr(LocaleKeys.profile_logout),
            labelColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? AppColors.textPrimary;
    final iColor = iconColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        child: Row(
          children: [
            // Leading icon — right side visually (first child in RTL)
            Icon(icon, color: iColor, size: 22),
            const SizedBox(width: AppSpacing.sm),
            // Label
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            // Trailing chevron — left side visually, flipped for RTL
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: AppSpacing.lg,
      endIndent: AppSpacing.lg,
    );
  }
}
