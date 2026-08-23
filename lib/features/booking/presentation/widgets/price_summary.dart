import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../models/booking_models.dart';

/// Session price + total due, shown above the sticky bottom bar.
class PriceSummary extends StatelessWidget {
  const PriceSummary({super.key, required this.sessionType});

  final SessionType sessionType;

  @override
  Widget build(BuildContext context) {
    final price = sessionType.price;
    return Column(
      children: [
        _SummaryRow(label: 'قيمة الجلسة:', value: '$price ر.س', bold: false),
        const Divider(height: AppSpacing.lg, color: AppColors.border),
        _SummaryRow(
          label: 'المطلوب سداده',
          value: '$price ر.س',
          bold: true,
          valueColor: AppColors.primary,
        ),
      ],
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
          value,
          style: AppTextStyles.body.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
