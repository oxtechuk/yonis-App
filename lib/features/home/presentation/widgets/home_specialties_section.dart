import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class HomeSpecialtiesSection extends StatelessWidget {
  const HomeSpecialtiesSection({super.key, this.specialties});

  /// Specialties from the doctor profile API. Falls back to the localized
  /// placeholder chips while loading or when the API provides none.
  final List<String>? specialties;

  static const _fallbackKeys = [
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
    final labels = (specialties != null && specialties!.isNotEmpty)
        ? specialties!
        : _fallbackKeys.map(context.tr).toList();

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(LocaleKeys.home_specialtiesTitle),
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: labels.map((label) => _Chip(label: label)).toList(),
            ),
          ],
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
        color: AppColors.fieldFill,
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
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
