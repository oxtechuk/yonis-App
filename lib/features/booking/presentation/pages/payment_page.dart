import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/payment_card_form.dart';
import '../widgets/payment_merchant_info_bar.dart';
import '../widgets/payment_noon_header.dart';

/// Noon Payments-style card entry page.
class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    this.merchantName = 'Baeynh',
    this.referenceNumber = '12345',
    this.amount = 1500,
  });

  final String merchantName;
  final String referenceNumber;
  final int amount;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _saveCard = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: call payment API — navigate to success on confirmation
      context.push(
        AppRoutes.paymentSuccess,
        extra: <String, dynamic>{
          'referenceNumber': 'REF-8492',
          'serviceName': 'جلسة استشارة نفسية',
          'appointmentDate': '١٥ أكتوبر ٢٠٢٣',
          'appointmentTime': '٤:٠٠ مساء - ٥:٠٠ مساء',
          'consultantName': 'د. أحمد محمود',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEF0F5),
        body: SafeArea(
          child: Column(
            children: [
              BookingAppBar(
                title: 'الدفع',
                titleFontWeight: FontWeight.w700,
                onBack: () => context.pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NoonPaymentsHeader(onCancel: () => context.pop()),
                        MerchantInfoBar(
                          merchantName: widget.merchantName,
                          referenceNumber: widget.referenceNumber,
                          amount: widget.amount,
                        ),
                        const _PaymentMethodTab(),
                        const SizedBox(height: AppSpacing.md),
                        PaymentCardForm(
                          cardNumberController: _cardNumberController,
                          expiryController: _expiryController,
                          cvvController: _cvvController,
                          saveCard: _saveCard,
                          onSaveCardChanged: (v) =>
                              setState(() => _saveCard = v),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: _PayButton(onTap: _submit),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
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

class _PaymentMethodTab extends StatelessWidget {
  const _PaymentMethodTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDDE1EA),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'البطاقة',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1E2D6B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'ادفع الان',
          style: AppTextStyles.button.copyWith(
            color: AppColors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
