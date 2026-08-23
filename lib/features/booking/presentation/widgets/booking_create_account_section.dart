import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/saudi_phone_prefix.dart';

/// Guest account creation fields shown during booking (name/phone/password).
class CreateAccountSection extends StatelessWidget {
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
        const SizedBox(height: AppSpacing.xs),
        _AccountField(
          controller: nameController,
          hintText: 'الاسم الكامل',
          prefixIcon: Icons.person_outline,
          textDirection: ui.TextDirection.rtl,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'أدخل اسمك الكامل' : null,
        ),
        const SizedBox(height: AppSpacing.md),

        // Phone
        const _FieldLabel(label: 'رقم الوتساب لتواصل'),
        const SizedBox(height: AppSpacing.xs),
        _PhoneField(controller: phoneController),
        const SizedBox(height: AppSpacing.md),

        // Password
        const _FieldLabel(label: 'كلمة المرور'),
        const SizedBox(height: AppSpacing.xs),
        _AccountField(
          controller: passwordController,
          hintText: 'كلمة المرور',
          prefixIcon: Icons.mail_outline,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: AppSizes.iconMd,
            ),
            onPressed: onTogglePassword,
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

/// Filled rounded text field with a leading icon.
class _AccountField extends StatelessWidget {
  const _AccountField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.textDirection,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final ui.TextDirection? textDirection;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textDirection: textDirection,
      obscureText: obscureText,
      validator: validator,
      decoration: _filledDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.textSecondary,
          size: AppSizes.iconMd,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.right,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'أدخل رقم الهاتف' : null,
      decoration: _filledDecoration(
        hintText: '051 234 5678',
        prefixIcon: const SaudiPhonePrefix(),
      ),
    );
  }
}

InputDecoration _filledDecoration({
  required String hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  final outline = OutlineInputBorder(
    borderRadius: AppRadius.allLg,
    borderSide: BorderSide.none,
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.fieldFill,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    border: outline,
    enabledBorder: outline,
    focusedBorder: outline.copyWith(
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: outline.copyWith(
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: outline.copyWith(
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
  );
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
              crossAxisAlignment: CrossAxisAlignment.end,
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
