import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../../../app/widgets/primary_button.dart';
import '../widgets/booking_app_bar.dart';

/// Shown right after `/api/checkout/initialize` succeeds. The booking is
/// created but not yet paid (ZainCash today) — this screen carries the
/// reference, the amount due, and the QR code to scan.
class CheckoutPaymentPage extends StatelessWidget {
  const CheckoutPaymentPage({
    super.key,
    required this.bookingReference,
    required this.serviceTitle,
    required this.date,
    required this.time,
    required this.paymentMethod,
    required this.amount,
    this.currencySymbol = 'د.ع',
    this.qrCode,
    this.paymentInstructions,
    this.whatsappUrl,
  });

  final String bookingReference;
  final String serviceTitle;
  final String date;
  final String time;
  final String paymentMethod;
  final num amount;
  final String currencySymbol;
  final String? qrCode;
  final String? paymentInstructions;
  final String? whatsappUrl;

  String get _displayAmount => amount == amount.round()
      ? amount.round().toString()
      : amount.toString();

  String _paymentMethodLabel(BuildContext context) => switch (paymentMethod) {
        'zaincash' => context.tr(LocaleKeys.payment_zaincashLabel),
        'superki' => 'SuperKI',
        _ => paymentMethod,
      };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              BookingAppBar(title: context.tr(LocaleKeys.payment_title), onBack: () => context.pop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _StatusBadge(),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        context.tr(LocaleKeys.payment_bookedSuccessfully),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (paymentInstructions != null)
                        _InstructionsCard(text: paymentInstructions!),
                      const SizedBox(height: AppSpacing.md),
                      _TicketCard(
                        bookingReference: bookingReference,
                        serviceTitle: serviceTitle,
                        date: date,
                        time: time,
                        paymentMethodLabel: _paymentMethodLabel(context),
                        amountLabel: '$_displayAmount $currencySymbol',
                      ),
                      if (qrCode != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _QrCodeCard(url: qrCode!),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: context.tr(LocaleKeys.payment_backHome),
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  static const Color _amber = Color(0xFFF2A20C);
  static const Color _amberTint = Color(0xFFFFF4DD);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(color: _amberTint, shape: BoxShape.circle),
          child: const Icon(Icons.hourglass_top_rounded, color: _amber, size: 34),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: _amberTint, borderRadius: AppRadius.allXl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.watch_later_outlined, color: _amber, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.tr(LocaleKeys.payment_waitingPayment),
                style: AppTextStyles.body.copyWith(color: _amber, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.text});
  final String text;

  static const Color _amber = Color(0xFFF2A20C);
  static const Color _amberTint = Color(0xFFFFF9EC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _amberTint,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: _amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(left: AppSpacing.sm),
            decoration: const BoxDecoration(color: _amber, shape: BoxShape.circle),
            child: const Icon(Icons.info_outline, color: AppColors.white, size: 14),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.bookingReference,
    required this.serviceTitle,
    required this.date,
    required this.time,
    required this.paymentMethodLabel,
    required this.amountLabel,
  });

  final String bookingReference;
  final String serviceTitle;
  final String date;
  final String time;
  final String paymentMethodLabel;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  color: AppColors.textSecondary, size: AppSizes.iconMd),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  context.tr(LocaleKeys.payment_eTicket),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardTint,
                  borderRadius: AppRadius.allMd,
                ),
                child: Text(
                  '#$bookingReference',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(label: context.tr(LocaleKeys.payment_service), value: serviceTitle),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(label: context.tr(LocaleKeys.payment_appointment), value: '$date  |  $time'),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(label: context.tr(LocaleKeys.payment_paymentMethod), value: paymentMethodLabel),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF9EF),
              borderRadius: AppRadius.allMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr(LocaleKeys.payment_amountDue),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  amountLabel,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _QrCodeCard extends StatelessWidget {
  const _QrCodeCard({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            context.tr(LocaleKeys.payment_scanQr),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.allMd,
            child: Image.network(
              url,
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SkeletonPulse(
                  child: SkeletonBox(
                    width: 220,
                    height: 220,
                    borderRadius: 8,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Icon(Icons.broken_image_outlined,
                      color: AppColors.textSecondary, size: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
