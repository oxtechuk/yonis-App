import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../app/widgets/saudi_phone_prefix.dart';
import '../../domain/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: replace with real auth call
      AuthState.instance.login();
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.auth_phoneLabel.tr(),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.right,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration(
              hintText: LocaleKeys.auth_phonePlaceholder.tr(),
              prefix: const SaudiPhonePrefix(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? LocaleKeys.auth_phoneRequired.tr()
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Password ───────────────────────────────────────────────
          Text(
            LocaleKeys.auth_passwordLabel.tr(),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textDirection: ui.TextDirection.ltr,
            decoration: _inputDecoration(
              hintText: LocaleKeys.auth_passwordPlaceholder.tr(),
              prefix: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  Icons.mail_outline,
                  color: AppColors.textSecondary,
                  size: AppSizes.iconMd,
                ),
              ),
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: AppSizes.iconMd,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? LocaleKeys.auth_passwordRequired.tr()
                : null,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Submit ─────────────────────────────────────────────────
          PrimaryButton(
            label: LocaleKeys.auth_loginButton.tr(),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? prefix,
    Widget? suffix,
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
      prefixIcon: prefix,
      suffixIcon: suffix,
    );
  }
}
