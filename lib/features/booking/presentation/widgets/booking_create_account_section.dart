import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_text_field.dart';
import '../../../../app/widgets/country_code.dart';
import '../../../../app/widgets/phone_country_picker.dart';

/// Guest account creation fields shown during booking (name/phone/password).
class CreateAccountSection extends StatefulWidget {
  const CreateAccountSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  @override
  State<CreateAccountSection> createState() => _CreateAccountSectionState();
}

class _CreateAccountSectionState extends State<CreateAccountSection> {
  CountryCode _country = kCountryCodes.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'انشاء حسابك',
          textAlign: TextAlign.right,
          style: AppTextStyles.headline.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Name
        const _FieldLabel(label: 'أكتب اسمك بالكامل'),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: widget.nameController,
          hint: 'الاسم الكامل',
          textDirection: ui.TextDirection.rtl,
          height: 56,
          prefixWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(
              Icons.person_outline,
              color: AppColors.textSecondary,
              size: AppSizes.iconMd,
            ),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'أدخل اسمك الكامل' : null,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Phone
        const _FieldLabel(label: 'رقم الوتساب لتواصل'),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: widget.phoneController,
          hint: '051 234 5678',
          keyboardType: TextInputType.phone,
          textDirection: ui.TextDirection.ltr,
          textAlign: TextAlign.right,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          height: 56,
          suffixWidget: PhoneCountryPicker(
            selected: _country,
            onChanged: (c) => setState(() => _country = c),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'أدخل رقم الهاتف' : null,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Password
        const _FieldLabel(label: 'كلمة المرور'),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: widget.passwordController,
          hint: 'كلمة المرور',
          obscureText: widget.obscurePassword,
          height: 56,
          prefixWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(
              Icons.mail_outline,
              color: AppColors.textSecondary,
              size: AppSizes.iconMd,
            ),
          ),
          suffixWidget: IconButton(
            icon: Icon(
              widget.obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: AppSizes.iconMd,
            ),
            onPressed: widget.onTogglePassword,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'أدخل كلمة المرور' : null,
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.right,
      style: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Reminder card encouraging users to remember their auto-created account.
class RememberAccountCard extends StatelessWidget {
  const RememberAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardTint,
        borderRadius: AppRadius.allXl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.white,
              size: AppSizes.iconMd,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لا تنسا حاسبك لدخول مرة اخرة',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'بعد ان تقوم بحجز جلساتك يقوم الطبيق بانشاء الحساب الخاص بك',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
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
