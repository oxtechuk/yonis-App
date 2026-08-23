import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_text_field.dart';

/// White card containing card number, expiry/CVV row and save-card toggle.
class PaymentCardForm extends StatelessWidget {
  const PaymentCardForm({
    super.key,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.saveCard,
    required this.onSaveCardChanged,
  });

  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final bool saveCard;
  final ValueChanged<bool> onSaveCardChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Card number ──────────────────────────────────────
          Text(
            'رقم البطاقة',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: cardNumberController,
            hint: '1234 1234 1234 1234',
            keyboardType: TextInputType.number,
            textDirection: ui.TextDirection.ltr,
            fillColor: AppColors.white,
            height: 56,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            suffixWidget: const Icon(
              Icons.credit_card_outlined,
              color: AppColors.textSecondary,
            ),
            validator: (v) {
              final digits = v?.replaceAll(' ', '') ?? '';
              if (digits.length < 16) return 'أدخل رقم البطاقة';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Expiry + CVV ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CVV — right side (RTL)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.help,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'CVV',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: cvvController,
                      hint: '1234',
                      keyboardType: TextInputType.number,
                      textDirection: ui.TextDirection.ltr,
                      obscureText: true,
                      fillColor: AppColors.white,
                      height: 56,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (v) {
                        if ((v?.length ?? 0) < 3) return 'CVV غير صحيح';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Expiry — left side (RTL)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ انتهاء الصلاحية',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: expiryController,
                      hint: 'MM/YY',
                      keyboardType: TextInputType.number,
                      textDirection: ui.TextDirection.ltr,
                      fillColor: AppColors.white,
                      height: 56,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryFormatter(),
                      ],
                      validator: (v) {
                        if ((v?.length ?? 0) < 5) return 'تاريخ غير صحيح';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Save card checkbox ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'حفظ البطاقة',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => onSaveCardChanged(!saveCard),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: saveCard ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: saveCard ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: saveCard
                      ? const Icon(Icons.check, color: AppColors.white, size: 16)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Formats card number as "1234 1234 1234 1234".
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 16) return oldValue;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats expiry as "MM/YY".
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) return oldValue;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
