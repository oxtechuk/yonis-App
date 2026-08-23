import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import 'service_option_card.dart';

/// Bottom sheet shown when the user taps "Book Your Consultation".
/// Matches the design: two option cards (clinic & online) each with a
/// title, description, price, and a CTA button.
class BookServiceBottomSheet extends StatelessWidget {
  const BookServiceBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.31),
      builder: (_) => const BookServiceBottomSheet(),
    );
  }

  // Both sides of the title get an equal-width slot so it stays
  // optically centered regardless of the button's internal metrics.
  static const double _headerSlotWidth = 40;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header row: close arrow + centered title
            Row(
              children: [
                SizedBox(
                  width: _headerSlotWidth,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.textPrimary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Expanded(
                  child: Text(
                    LocaleKeys.home_bookService_sheetTitle.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: _headerSlotWidth),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Clinic card
            ServiceOptionCard.clinic(
              title: LocaleKeys.home_bookService_clinicTitle.tr(),
              description: LocaleKeys.home_bookService_clinicDesc.tr(),
              price: LocaleKeys.home_bookService_clinicPrice.tr(),
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),

            // Online card
            ServiceOptionCard.online(
              title: LocaleKeys.home_bookService_onlineTitle.tr(),
              description: LocaleKeys.home_bookService_onlineDesc.tr(),
              price: LocaleKeys.home_bookService_onlinePrice.tr(),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
