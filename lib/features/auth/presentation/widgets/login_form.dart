import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_text_field.dart';
import '../../../../app/widgets/app_toast.dart';
import '../../../../app/widgets/country_code.dart';
import '../../../../app/widgets/phone_country_picker.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/auth_state.dart';
import '../cubit/login_cubit.dart';

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

  void _submit(BuildContext cubitContext) {
    if (_formKey.currentState?.validate() ?? false) {
      // Backend expects the full international number, e.g. "+9647712345678".
      final identifier = '${_country.dialCode}${_phoneController.text.trim()}';
      // Must use a context BELOW the BlocProvider (the builder's), not the
      // State's own context, which sits above it.
      cubitContext.read<LoginCubit>().login(
        identifier: identifier,
        password: _passwordController.text,
      );
    }
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    switch (state) {
      case LoginSuccess():
        AuthState.instance.login();
        Navigator.of(context, rootNavigator: true).pop();
      case LoginError(:final failure):
        AppToast.show(context, _localizedFailure(context, failure));
      case LoginInitial() || LoginLoading():
        break;
    }
  }

  /// User-facing copy for a [Failure]. Connectivity problems get localized
  /// copy; everything else carries the backend-provided message
  /// (e.g. "بيانات الدخول غير صحيحة..."), falling back to the typed default.
  String _localizedFailure(BuildContext context, Failure failure) =>
      switch (failure) {
        OfflineFailure() => context.tr(LocaleKeys.errors_offline),
        NetworkFailure() => context.tr(LocaleKeys.errors_network),
        TimeoutFailure() => context.tr(LocaleKeys.errors_timeout),
        ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty =>
          fieldErrors.values.first.first,
        _ => failure.message,
      };

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => getIt<LoginCubit>(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: _onStateChanged,
        builder: (context, state) {
          final isLoading = state is LoginLoading;
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
                  enabled: !isLoading,
                  // Suffix renders on the visual left under the RTL direction.
                  suffixWidget: PhoneCountryPicker(
                    selected: _country,
                    onChanged: (c) => setState(() => _country = c),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.tr(LocaleKeys.auth_phoneRequired)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),

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
                  enabled: !isLoading,
                  prefixWidget: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
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
                  onPressed: isLoading ? null : () => _submit(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
