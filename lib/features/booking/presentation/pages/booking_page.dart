import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/primary_button.dart';
import '../models/booking_models.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/outlined_card_field.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/price_summary.dart';
import '../widgets/session_type_selector.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  static void show(BuildContext context) {
    context.push(AppRoutes.booking);
  }

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  SessionType _sessionType = SessionType.chat;
  PaymentMethod _paymentMethod = PaymentMethod.card;

  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

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
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                BookingAppBar(
                  title: 'جلسة فورية',
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
                          selected: _sessionType,
                          onChanged: (t) => setState(() => _sessionType = t),
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
                          hintText:
                              '* فضلاً اكتب التفاصيل بشكل واضح، وباختصار',
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
                          onChanged: (m) =>
                              setState(() => _paymentMethod = m),
                        ),

                        // Price summary
                        const SizedBox(height: AppSpacing.lg),
                        PriceSummary(sessionType: _sessionType),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                _BottomBar(
                  sessionType: _sessionType,
                  onConfirm: _submit,
                ),
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
  const _BottomBar({required this.sessionType, required this.onConfirm});
  final SessionType sessionType;
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
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اجمالي الطلب',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${sessionType.price} ر.س',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: PrimaryButton(label: 'التالي', onPressed: onConfirm),
          ),
        ],
      ),
    );
  }
}
