import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/locale_direction.dart';
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
    this.serviceName = 'جلسة استشارة',
    this.appointmentDate = '',
    this.appointmentTime = '',
    this.consultantName,
    this.paymentMethod,
    this.amount,
  });

  final String referenceNumber;
  final String serviceName;
  final String appointmentDate;
  final String appointmentTime;
  final String? consultantName;
  final String? paymentMethod;
  final String? amount;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.localeTextDirection,
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
                        context.tr(LocaleKeys.payment_requestReceived),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs + 2),

                      // ── Subtitle ───────────────────────────────
                      Text(
                        context.tr(LocaleKeys.payment_processingNotice),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── E-Ticket details card ───────────────────
                      SuccessDetailsCard(
                        referenceNumber: referenceNumber,
                        serviceName: serviceName,
                        appointmentDate: appointmentDate,
                        appointmentTime: appointmentTime,
                        consultantName: consultantName,
                        paymentMethod: paymentMethod,
                        amount: amount,
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // ── Bottom actions ─────────────────────────────────
              _BottomActions(
                onGoSessions: () => context.go(AppRoutes.sessions),
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
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: AppColors.white, size: 44),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onGoSessions,
    required this.onGoHome,
  });

  final VoidCallback onGoSessions;
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
          // Primary — Go to Sessions
          SizedBox(
            height: AppSizes.buttonHeight,
            child: FilledButton.icon(
              onPressed: onGoSessions,
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
                context.tr(LocaleKeys.payment_viewDashboard),
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
                context.tr(LocaleKeys.payment_closeHome),
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
