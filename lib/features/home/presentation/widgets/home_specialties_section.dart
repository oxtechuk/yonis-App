import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class HomeSpecialtiesSection extends StatelessWidget {
  const HomeSpecialtiesSection({super.key});

  static const _specialtyKeys = [
    LocaleKeys.home_specialties_administrativeCases,
    LocaleKeys.home_specialties_anxietyDisorder,
    LocaleKeys.home_specialties_awareness,
    LocaleKeys.home_specialties_addiction,
    LocaleKeys.home_specialties_generalRights,
    LocaleKeys.home_specialties_medicalErrors,
    LocaleKeys.home_specialties_labor,
    LocaleKeys.home_specialties_commercial,
    LocaleKeys.home_specialties_hyperactivity,
    LocaleKeys.home_specialties_traffic,
    LocaleKeys.home_specialties_realEstate,
    LocaleKeys.home_specialties_enforcementCases,
    LocaleKeys.home_specialties_semiJudicialCommittees,
  ];

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children:
              _specialtyKeys.map((key) => _Chip(label: key.tr())).toList(),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Use bodySmall from design tokens — no fontSize override
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
