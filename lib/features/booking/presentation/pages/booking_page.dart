import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  const BookingPage({super.key, this.service});

  /// The backend service selected in the booking sheet. Null when the page
  /// is opened without one (legacy/deep-link) — fallback pricing is used.
  final Service? service;

  static void show(BuildContext context) {
    context.push(AppRoutes.booking);
  }

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  late final List<ConsultationOption> _options =
      ConsultationOptions.fromService(widget.service);
  int _selectedOptionIndex = 0;

  PaymentMethod _paymentMethod = PaymentMethod.card;

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
      context.push(AppRoutes.bookingStep2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                BookingAppBar(
                  title: widget.service?.title ?? 'جلسة فورية',
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
                        // Session type
                        const SizedBox(height: AppSpacing.md),
                        const _SectionTitle(title: 'مدة الاستشارة'),
                        const SizedBox(height: AppSpacing.sm),
                        SessionTypeSelector(
                          options: _options,
                          selectedIndex: _selectedOptionIndex,
                          onChanged: (i) =>
                              setState(() => _selectedOptionIndex = i),
                        ),

                        // Consultation title
                        const SizedBox(height: AppSpacing.md),
                        const _SectionTitle(title: 'عنوان الاستشارة'),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedCardField(
                          controller: _titleController,
                          hintText:
                              '* عنوان الاستشارة (يرجي كتابة موضوع مختصر للطلب)',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'أدخل عنوان الاستشارة'
                              : null,
                        ),

                        // Request details
                        const SizedBox(height: AppSpacing.md),
                        const _SectionTitle(title: 'تفاصيل الطلب'),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedCardField(
                          controller: _detailsController,
                          hintText: '* فضلاً اكتب التفاصيل بشكل واضح، وباختصار',
                          maxLines: 5,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'أدخل تفاصيل الطلب'
                              : null,
                        ),

                        // Payment method
                        const SizedBox(height: AppSpacing.md),
                        const _SectionTitle(title: 'طريقة الدفع'),
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
                'اجمالي الطلب',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${option.displayPrice} ر.س',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'التالي', onPressed: onConfirm),
        ],
      ),
    );
  }
}
