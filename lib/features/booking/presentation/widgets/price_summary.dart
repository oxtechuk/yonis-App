import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../models/booking_models.dart';

/// Session price + total due, shown above the sticky bottom bar.
class PriceSummary extends StatelessWidget {
  const PriceSummary({super.key, required this.option});

  final ConsultationOption option;

  @override
  Widget build(BuildContext context) {
    final price = option.displayPrice;
    final currency = context.tr(LocaleKeys.booking_currency);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardTint,
        borderRadius: AppRadius.allLg,
      ),
      child: Column(
        children: [
          _SummaryRow(label: context.tr(LocaleKeys.priceSummary_sessionValue), value: '$price $currency', bold: false),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: context.tr(LocaleKeys.priceSummary_totalDue),
            value: '$price $currency',
            bold: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.bold,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: (bold ? AppTextStyles.title : AppTextStyles.body).copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
