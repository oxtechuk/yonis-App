import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_text_field.dart';
import '../../../../app/widgets/country_code.dart';
import '../../../../app/widgets/phone_country_picker.dart';
import '../../../../app/widgets/primary_button.dart';
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
  CountryCode _country = kCountryCodes.first;

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
            context.tr(LocaleKeys.auth_phoneLabel),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.right,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hint: context.tr(LocaleKeys.auth_phonePlaceholder),
            height: 56,
            prefixWidget: PhoneCountryPicker(
              selected: _country,
              onChanged: (c) => setState(() => _country = c),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.tr(LocaleKeys.auth_phoneRequired)
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            context.tr(LocaleKeys.auth_passwordLabel),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textDirection: ui.TextDirection.ltr,
            hint: context.tr(LocaleKeys.auth_passwordPlaceholder),
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
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: AppSizes.iconMd,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.tr(LocaleKeys.auth_passwordRequired)
                : null,
          ),
          const SizedBox(height: AppSpacing.xl),

          PrimaryButton(
            label: context.tr(LocaleKeys.auth_loginButton),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
