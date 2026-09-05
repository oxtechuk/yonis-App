import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../home/domain/entities/service.dart';
import '../models/booking_models.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/outlined_card_field.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/price_summary.dart';
import '../widgets/session_type_selector.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
    this.service,
    this.selectedChannelType,
    this.selectedBookingType,
  });

  /// The backend service selected in the booking sheet. Null when the page
  /// is opened without one (legacy/deep-link) — fallback pricing is used.
  final Service? service;

  /// The selected channel type for online services (e.g. 'video', 'voice', 'chat').
  final String? selectedChannelType;

  /// The clinic/online tab the user picked in the booking sheet. Takes
  /// precedence over [Service.bookingType] as the source of truth, since
  /// the backend doesn't always set that field consistently.
  final String? selectedBookingType;

  static void show(
    BuildContext context, {
    Service? service,
    String? selectedChannelType,
  }) {
    context.push(
      AppRoutes.booking,
      extra: service != null
          ? {'service': service, 'channelType': selectedChannelType}
          : null,
    );
  }

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  String? get _bookingType =>
      widget.selectedBookingType ?? widget.service?.bookingType;

  late final List<ConsultationOption> _options =
      ConsultationOptions.fromService(
        widget.service,
        selectedChannelType: widget.selectedChannelType,
        bookingTypeOverride: widget.selectedBookingType,
      );
  int _selectedOptionIndex = 0;

  PaymentMethod _paymentMethod = PaymentMethod.zaincash;

  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  ConsultationOption get _selectedOption => _options[_selectedOptionIndex];

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push(
        AppRoutes.bookingStep2,
        extra: {
          'serviceId': widget.service?.id,
          'bookingType': _bookingType,
          'consultationType': _selectedOption.channel,
          'paymentMethod': _paymentMethod.name,
          'title': _titleController.text.trim(),
          'notes': _detailsController.text.trim(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                BookingAppBar(
                  title:
                      widget.service?.title ??
                      context.tr(LocaleKeys.booking_instantSession),
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Session type (channel selector) — online services only.
                        if (_bookingType != 'clinic') ...[
                          const SizedBox(height: AppSpacing.md),
                          _SectionTitle(
                            title: context.tr(LocaleKeys.booking_durationTitle),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SessionTypeSelector(
                            options: _options,
                            selectedIndex: _selectedOptionIndex,
                            onChanged: (i) =>
                                setState(() => _selectedOptionIndex = i),
                          ),
                        ],

                        // Consultation title
                        const SizedBox(height: AppSpacing.md),
                        _SectionTitle(
                          title: context.tr(
                            LocaleKeys.booking_consultationTitle,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedCardField(
                          controller: _titleController,
                          hintText: context.tr(
                            LocaleKeys.booking_consultationTitleHint,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? context.tr(LocaleKeys.booking_enterTitle)
                              : null,
                        ),

                        // Request details
                        const SizedBox(height: AppSpacing.md),
                        _SectionTitle(
                          title: context.tr(LocaleKeys.booking_detailsTitle),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedCardField(
                          controller: _detailsController,
                          hintText: context.tr(LocaleKeys.booking_detailsHint),
                          maxLines: 5,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? context.tr(LocaleKeys.booking_enterDetails)
                              : null,
                        ),

                        // Payment method
                        const SizedBox(height: AppSpacing.md),
                        _SectionTitle(
                          title: context.tr(LocaleKeys.booking_paymentTitle),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PaymentMethodSelector(
                          selected: _paymentMethod,
                          onChanged: (m) => setState(() => _paymentMethod = m),
                        ),

                        // Price summary
                        const SizedBox(height: AppSpacing.lg),
                        PriceSummary(option: _selectedOption),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                _BottomBar(option: _selectedOption, onConfirm: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: AppTextStyles.title.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.option, required this.onConfirm});
  final ConsultationOption option;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr(LocaleKeys.booking_orderTotal),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${option.displayPrice} ${context.tr(LocaleKeys.booking_currency)}',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: context.tr(LocaleKeys.booking_next),
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}
