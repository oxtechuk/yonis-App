import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../widgets/payment_success_details_card.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({
    super.key,
    this.referenceNumber = 'REF-8492',
    this.serviceName = 'جلسة استشارة نفسية',
    this.appointmentDate = '١٥ أكتوبر ٢٠٢٣',
    this.appointmentTime = '٤:٠٠ مساء - ٥:٠٠ مساء',
    this.consultantName = 'د. أحمد محمود',
  });

  final String referenceNumber;
  final String serviceName;
  final String appointmentDate;
  final String appointmentTime;
  final String consultantName;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // ── Success icon ───────────────────────────
                      const _SuccessIcon(),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Title ──────────────────────────────────
                      Text(
                        context.tr(LocaleKeys.payment_confirmedTitle),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // ── Subtitle ───────────────────────────────
                      Text(
                        context.tr(LocaleKeys.payment_confirmedSubtitle),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Booking details card ───────────────────
                      SuccessDetailsCard(
                        referenceNumber: referenceNumber,
                        serviceName: serviceName,
                        appointmentDate: appointmentDate,
                        appointmentTime: appointmentTime,
                        consultantName: consultantName,
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // ── Bottom actions ─────────────────────────────────
              _BottomActions(
                onStartConsultation: () {
                  // TODO: navigate to session/chat screen
                },
                onGoHome: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: AppColors.white, size: 48),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onStartConsultation,
    required this.onGoHome,
  });

  final VoidCallback onStartConsultation;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary — start consultation
          SizedBox(
            height: AppSizes.buttonHeight,
            child: FilledButton.icon(
              onPressed: onStartConsultation,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.white,
                size: 20,
              ),
              label: Text(
                context.tr(LocaleKeys.payment_startConsultation),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Secondary — go home
          SizedBox(
            height: AppSizes.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: onGoHome,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.home_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),
              label: Text(
                context.tr(LocaleKeys.payment_backHome),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
