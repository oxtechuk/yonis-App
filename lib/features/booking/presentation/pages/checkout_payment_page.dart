import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../../../app/widgets/app_toast.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../home/domain/entities/service.dart';
import '../cubit/checkout_cubit.dart';
import '../models/booking_models.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/price_summary.dart';

/// Second (and final) step of the booking flow: payment + QR on one page.
///
/// Receives everything collected on [BookingPage] (details, schedule,
/// account). Selecting a payment method immediately sends the checkout
/// (`/api/checkout/initialize`) and the QR code / booking reference appear
/// inline underneath the payment methods — there is no third page.
class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({
    super.key,
    // ── Booking inputs (from step 1) ──
    this.serviceId,
    this.service,
    this.bookingType,
    this.consultationType,
    this.title,
    this.notes,
    this.date,
    this.startTime,
    this.timeDisplay,
    this.serviceTitle,
    this.isRegistered,
    this.name,
    this.phone,
    this.email,
    this.password,
    this.optionLabel,
    this.optionPrice,
    this.optionDuration,
    this.optionChannel,
    // ── Ticket / payment (legacy direct display) ──
    this.bookingReference = '',
    this.paymentMethod = 'zaincash',
    this.amount = 0,
    this.currencySymbol = 'د.ع',
    this.qrCode,
    this.paymentInstructions,
    this.whatsappUrl,
  });

  final int? serviceId;
  final Service? service;
  final String? bookingType;
  final String? consultationType;
  final String? title;
  final String? notes;
  final String? date;
  final String? startTime;
  final String? timeDisplay;
  final String? serviceTitle;
  final bool? isRegistered;
  final String? name;
  final String? phone;
  final String? email;
  final String? password;
  final String? optionLabel;
  final double? optionPrice;
  final int? optionDuration;
  final String? optionChannel;

  final String bookingReference;
  final String paymentMethod;
  final num amount;
  final String currencySymbol;
  final String? qrCode;
  final String? paymentInstructions;
  final String? whatsappUrl;

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  late final CheckoutCubit _checkoutCubit;

  /// Nothing pre-selected: checkout is only sent after the user taps
  /// a payment method.
  PaymentMethod? _paymentMethod;

  @override
  void initState() {
    super.initState();
    _checkoutCubit = getIt<CheckoutCubit>();
  }

  @override
  void dispose() {
    _checkoutCubit.close();
    super.dispose();
  }

  /// Legacy entry: opened with a ticket already (no booking inputs) — just
  /// display it, nothing to send.
  bool get _isLegacyTicket =>
      widget.bookingReference.isNotEmpty &&
      (widget.serviceId == null || widget.date == null);

  ConsultationOption get _option => ConsultationOption(
    label:
        widget.optionLabel ??
        widget.serviceTitle ??
        widget.service?.title ??
        widget.title ??
        '',
    price: (widget.optionPrice ?? widget.amount).toDouble(),
    durationMinutes: widget.optionDuration,
    channel: widget.optionChannel ?? widget.consultationType,
  );

  void _submitFor(PaymentMethod method) {
    if (_checkoutCubit.state is CheckoutSubmitting) return;
    final serviceId = widget.serviceId;
    final date = widget.date;
    final startTime = widget.startTime;
    if (serviceId == null || date == null || startTime == null) {
      AppToast.show(context, context.tr(LocaleKeys.booking_selectDateTime));
      return;
    }
    _checkoutCubit.submit(
      serviceId: serviceId,
      bookingType: widget.bookingType ?? 'online',
      consultationType: widget.consultationType ?? 'video',
      paymentMethod: method.name,
      date: date,
      startTime: startTime,
      title: widget.title ?? '',
      notes: widget.notes,
      name: (widget.isRegistered ?? false) ? null : widget.name,
      phone: (widget.isRegistered ?? false) ? null : widget.phone,
      email: (widget.isRegistered ?? false) ? null : widget.email,
      password: (widget.isRegistered ?? false) ? null : widget.password,
    );
  }

  void _onMethodSelected(PaymentMethod method) {
    setState(() => _paymentMethod = method);
    _submitFor(method);
  }

  void _retryLastMethod() {
    final method = _paymentMethod;
    if (method != null) _submitFor(method);
  }

  void _onCheckoutChanged(BuildContext context, CheckoutState state) {
    // Success renders inline below with a button to My Sessions — no
    // automatic navigation. Only failures toast here.
    switch (state) {
      case CheckoutLoaded(:final result) when !result.success:
        AppToast.show(
          context,
          result.message ?? context.tr(LocaleKeys.booking_bookingFailed),
        );
      case CheckoutError(:final failure):
        AppToast.show(context, failure.message);
      case CheckoutInitial() || CheckoutSubmitting() || CheckoutLoaded():
        break;
    }
  }

  String _paymentMethodLabel(BuildContext context, String method) =>
      switch (method) {
        'zaincash' => context.tr(LocaleKeys.payment_zaincashLabel),
        'superki' => 'SuperKI',
        _ => method,
      };

  static String _formatAmount(num amount) =>
      amount == amount.round() ? amount.round().toString() : amount.toString();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
      bloc: _checkoutCubit,
      listener: _onCheckoutChanged,
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                BookingAppBar(
                  title: context.tr(LocaleKeys.booking_paymentTitle),
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr(LocaleKeys.booking_paymentTitle),
                          textAlign: TextAlign.right,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PaymentMethodSelector(
                          selected: _paymentMethod,
                          onChanged: _onMethodSelected,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PriceSummary(option: _option),
                        const SizedBox(height: AppSpacing.md),
                        // ── QR + booking result, inline under payment ──
                        if (_isLegacyTicket)
                          _LegacyTicketSection(
                            bookingReference: widget.bookingReference,
                            paymentMethodLabel: _paymentMethodLabel(
                              context,
                              widget.paymentMethod,
                            ),
                            amountLabel:
                                '${_formatAmount(widget.amount)} ${widget.currencySymbol}',
                            qrCode: widget.qrCode,
                            paymentInstructions: widget.paymentInstructions,
                          )
                        else
                          BlocBuilder<CheckoutCubit, CheckoutState>(
                            bloc: _checkoutCubit,
                            builder: (context, state) {
                              return switch (state) {
                                CheckoutSubmitting() =>
                                  const _SubmittingSection(),
                                CheckoutLoaded(:final result)
                                    when result.success =>
                                  _SuccessSection(
                                    bookingReference:
                                        result.bookingReference ?? '',
                                    paymentMethodLabel: _paymentMethodLabel(
                                      context,
                                      result.paymentMethod ??
                                          _paymentMethod?.name ??
                                          widget.paymentMethod,
                                    ),
                                    amountLabel:
                                        '${_formatAmount(result.amount ?? widget.optionPrice ?? widget.amount)} ${result.currencySymbol ?? widget.currencySymbol}',
                                    qrCode: result.qrCode,
                                    paymentInstructions:
                                        result.paymentInstructions,
                                  ),
                                CheckoutLoaded() => _FailureSection(
                                  onRetry: _retryLastMethod,
                                ),
                                CheckoutError(:final failure) =>
                                  _FailureSection(
                                    message: failure.message,
                                    onRetry: _retryLastMethod,
                                  ),
                                CheckoutInitial() => const SizedBox.shrink(),
                              };
                            },
                          ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading placeholder shown under the payment methods while checkout runs.
class _SubmittingSection extends StatelessWidget {
  const _SubmittingSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonPulse(
          child: SkeletonBox(width: 220, height: 220, borderRadius: 8),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ],
    );
  }
}

/// Inline success: QR code + reference + amount + a button to My Sessions,
/// all under the payment methods — no separate page, no auto-navigation.
class _SuccessSection extends StatelessWidget {
  const _SuccessSection({
    required this.bookingReference,
    required this.paymentMethodLabel,
    required this.amountLabel,
    this.qrCode,
    this.paymentInstructions,
  });

  final String bookingReference;
  final String paymentMethodLabel;
  final String amountLabel;
  final String? qrCode;
  final String? paymentInstructions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (paymentInstructions != null) ...[
          _InstructionsCard(text: paymentInstructions!),
          const SizedBox(height: AppSpacing.md),
        ],
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.allLg,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailRow(
                label: context.tr(LocaleKeys.payment_eTicket),
                value: '#$bookingReference',
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: context.tr(LocaleKeys.payment_paymentMethod),
                value: paymentMethodLabel,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: context.tr(LocaleKeys.payment_amountDue),
                value: amountLabel,
              ),
            ],
          ),
        ),
        if (qrCode != null) ...[
          const SizedBox(height: AppSpacing.md),
          _QrCodeCard(url: qrCode!),
        ],
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: context.tr(LocaleKeys.navigation_sessions),
          onPressed: () => context.go(AppRoutes.sessions),
        ),
      ],
    );
  }
}

/// Legacy ticket display (opened with a reference, nothing to send).
class _LegacyTicketSection extends StatelessWidget {
  const _LegacyTicketSection({
    required this.bookingReference,
    required this.paymentMethodLabel,
    required this.amountLabel,
    this.qrCode,
    this.paymentInstructions,
  });

  final String bookingReference;
  final String paymentMethodLabel;
  final String amountLabel;
  final String? qrCode;
  final String? paymentInstructions;

  @override
  Widget build(BuildContext context) {
    return _SuccessSection(
      bookingReference: bookingReference,
      paymentMethodLabel: paymentMethodLabel,
      amountLabel: amountLabel,
      qrCode: qrCode,
      paymentInstructions: paymentInstructions,
    );
  }
}

/// Inline failure with retry — stays on the same page.
class _FailureSection extends StatelessWidget {
  const _FailureSection({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message ?? context.tr(LocaleKeys.booking_bookingFailed),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          label: context.tr(LocaleKeys.common_retry),
          onPressed: onRetry,
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
            decoration: const BoxDecoration(
              color: _amber,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.white,
              size: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
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
                  child: SkeletonBox(width: 220, height: 220, borderRadius: 8),
                );
              },
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
