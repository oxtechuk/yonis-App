import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

/// Slate-blue bar with merchant/reference details and the amount due.
class MerchantInfoBar extends StatelessWidget {
  const MerchantInfoBar({
    super.key,
    required this.merchantName,
    required this.referenceNumber,
    required this.amount,
  });

  final String merchantName;
  final String referenceNumber;
  final int amount;

  // Gateway-branded slate tone — specific to the Noon payments chrome.
  static const Color _barColor = Color(0xFF6B7A99);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _barColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Merchant (LTR value, left side in RTL layout)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchantName,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'اسم التاجر:',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              // Reference (right side)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    referenceNumber,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'رقم المرجع',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            color: AppColors.white.withValues(alpha: 0.3),
            height: AppSpacing.lg,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ر.س $amount',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'إجمالي المبلغ المستحق',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
