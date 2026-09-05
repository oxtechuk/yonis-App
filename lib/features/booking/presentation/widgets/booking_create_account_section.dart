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
import '../../../../app/widgets/app_text_field.dart';
import '../../../../app/widgets/country_code.dart';
import '../../../../app/widgets/phone_country_picker.dart';
import '../../../auth/presentation/cubit/login_cubit.dart';
import '../../domain/entities/check_user_result.dart';
import '../cubit/check_user_cubit.dart';

/// Guest account section shown during booking.
///
/// First asks for the phone number and checks it against
/// `/api/checkout/check-user`:
/// - an existing account is shown read-only, nothing else to fill in;
/// - a new number unlocks the rest of the sign-up form (name/email/password)
///   with the checked phone locked in as read-only.
class CreateAccountSection extends StatefulWidget {
  const CreateAccountSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.checkState,
    required this.onCheckPhone,
    required this.onChangePhone,
    required this.loginPasswordController,
    required this.obscureLoginPassword,
    required this.onToggleLoginPassword,
    required this.loginState,
    required this.onLogin,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  /// Current state of the phone lookup.
  final CheckUserState checkState;

  /// Called with the full E.164 phone (dial code + digits) when the user
  /// taps the check button.
  final ValueChanged<String> onCheckPhone;

  /// Called when the user wants to re-enter a different phone number.
  final VoidCallback onChangePhone;

  /// Password field used only when logging into a recognized account.
  final TextEditingController loginPasswordController;
  final bool obscureLoginPassword;
  final VoidCallback onToggleLoginPassword;

  /// Current state of the login attempt for a recognized account.
  final LoginState loginState;

  /// Called with the entered password when the user taps "تسجيل الدخول".
  final ValueChanged<String> onLogin;

  @override
  State<CreateAccountSection> createState() => _CreateAccountSectionState();
}

class _CreateAccountSectionState extends State<CreateAccountSection> {
  CountryCode _country = kCountryCodes.first;

  String get _fullPhone => '${_country.dialCode}${widget.phoneController.text.trim()}';

  @override
  Widget build(BuildContext context) {
    final state = widget.checkState;
    final isRegistered = state is CheckUserLoaded && state.result.isRegistered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isRegistered) ...[
          Text(
            context.tr(LocaleKeys.bookingAccount_createTitle),
            textAlign: TextAlign.right,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (state is CheckUserLoaded)
          state.result.isRegistered
              ? _RecognizedAccountCard(
                  result: state.result,
                  onChangePhone: widget.onChangePhone,
                  passwordController: widget.loginPasswordController,
                  obscurePassword: widget.obscureLoginPassword,
                  onTogglePassword: widget.onToggleLoginPassword,
                  loginState: widget.loginState,
                  onLogin: widget.onLogin,
                )
              : _NewAccountForm(
                  phoneController: widget.phoneController,
                  nameController: widget.nameController,
                  emailController: widget.emailController,
                  passwordController: widget.passwordController,
                  obscurePassword: widget.obscurePassword,
                  onTogglePassword: widget.onTogglePassword,
                  country: _country,
                  onChangePhone: widget.onChangePhone,
                )
        else
          _PhoneCheckStep(
            phoneController: widget.phoneController,
            country: _country,
            onCountryChanged: (c) => setState(() => _country = c),
            isChecking: state is CheckUserLoading,
            errorMessage:
                state is CheckUserError ? context.tr(LocaleKeys.bookingAccount_checkError) : null,
            onCheck: () => widget.onCheckPhone(_fullPhone),
          ),
      ],
    );
  }
}

class _PhoneCheckStep extends StatelessWidget {
  const _PhoneCheckStep({
    required this.phoneController,
    required this.country,
    required this.onCountryChanged,
    required this.isChecking,
    required this.errorMessage,
    required this.onCheck,
  });

  final TextEditingController phoneController;
  final CountryCode country;
  final ValueChanged<CountryCode> onCountryChanged;
  final bool isChecking;
  final String? errorMessage;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label: context.tr(LocaleKeys.bookingAccount_whatsappLabel)),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: phoneController,
          hint: context.tr(LocaleKeys.auth_phonePlaceholder),
          keyboardType: TextInputType.phone,
          textDirection: ui.TextDirection.ltr,
          textAlign: TextAlign.right,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          height: 56,
          enabled: !isChecking,
          suffixWidget: PhoneCountryPicker(
            selected: country,
            onChanged: onCountryChanged,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? context.tr(LocaleKeys.bookingAccount_enterPhone) : null,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorMessage!,
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: AppSizes.buttonHeight,
          child: OutlinedButton(
            onPressed: isChecking
                ? null
                : () {
                    if (phoneController.text.trim().isEmpty) return;
                    onCheck();
                  },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: const StadiumBorder(),
            ),
            child: isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    context.tr(LocaleKeys.bookingAccount_checkNumber),
                    style: AppTextStyles.button.copyWith(color: AppColors.primary),
                  ),
          ),
        ),
      ],
    );
  }
}

class _RecognizedAccountCard extends StatelessWidget {
  const _RecognizedAccountCard({
    required this.result,
    required this.onChangePhone,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.loginState,
    required this.onLogin,
  });

  final CheckUserResult result;
  final VoidCallback onChangePhone;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final LoginState loginState;
  final ValueChanged<String> onLogin;

  String? get _errorMessage => switch (loginState) {
        LoginError(:final failure) => failure.message,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final user = result.user;
    final isLoggingIn = loginState is LoginLoading;
    final isLoggedIn = loginState is LoginSuccess;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardTint,
            borderRadius: AppRadius.allLg,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection: ui.TextDirection.rtl,
                children: [
                  Icon(
                    isLoggedIn ? Icons.check_circle_rounded : Icons.verified_rounded,
                    color: isLoggedIn ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      isLoggedIn
                          ? context.tr(LocaleKeys.bookingAccount_loginSuccess)
                          : result.message ?? context.tr(LocaleKeys.errors_general),
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (user != null) ...[
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(icon: Icons.person_outline, value: user.name),
                _InfoRow(icon: Icons.phone_outlined, value: user.phone),
                if (user.email?.isNotEmpty ?? false)
                  _InfoRow(icon: Icons.mail_outline, value: user.email!),
              ],
              if (!isLoggedIn) ...[
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: AppSpacing.sm),
                _FieldLabel(label: context.tr(LocaleKeys.bookingAccount_loginToBook)),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: passwordController,
                  hint: context.tr(LocaleKeys.bookingAccount_passwordLabel),
                  obscureText: obscurePassword,
                  enabled: !isLoggingIn,
                  height: 56,
                  fillColor: AppColors.white,
                  prefixWidget: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconMd,
                    ),
                  ),
                  suffixWidget: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconMd,
                    ),
                    onPressed: onTogglePassword,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: AppSizes.buttonHeight,
                  child: FilledButton(
                    onPressed: isLoggingIn
                        ? null
                        : () {
                            if (passwordController.text.trim().isEmpty) return;
                            onLogin(passwordController.text);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                    ),
                    child: isLoggingIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            context.tr(LocaleKeys.bookingAccount_loginButton),
                            style: AppTextStyles.button.copyWith(color: AppColors.white),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onChangePhone,
            child: Text(
              context.tr(LocaleKeys.bookingAccount_notYouChange),
              style: AppTextStyles.body.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        textDirection: ui.TextDirection.rtl,
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewAccountForm extends StatelessWidget {
  const _NewAccountForm({
    required this.phoneController,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.country,
    required this.onChangePhone,
  });

  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final CountryCode country;
  final VoidCallback onChangePhone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone — locked to the number that was just checked.
        Row(
          children: [
            Expanded(child: _FieldLabel(label: context.tr(LocaleKeys.bookingAccount_whatsappLabel))),
            TextButton(
              onPressed: onChangePhone,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                context.tr(LocaleKeys.bookingAccount_change),
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: phoneController,
          readOnly: true,
          enabled: false,
          textDirection: ui.TextDirection.ltr,
          textAlign: TextAlign.right,
          height: 56,
          prefixWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              country.dialCode,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Name
        _FieldLabel(label: context.tr(LocaleKeys.bookingAccount_fullNameLabel)),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: nameController,
          hint: context.tr(LocaleKeys.bookingAccount_fullNameHint),
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
              (v == null || v.trim().isEmpty) ? context.tr(LocaleKeys.bookingAccount_enterName) : null,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Email
        _FieldLabel(label: context.tr(LocaleKeys.bookingAccount_emailLabel)),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: emailController,
          hint: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
          textDirection: ui.TextDirection.ltr,
          textAlign: TextAlign.right,
          height: 56,
          prefixWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(
              Icons.mail_outline,
              color: AppColors.textSecondary,
              size: AppSizes.iconMd,
            ),
          ),
          validator: (v) {
            final value = v?.trim() ?? '';
            if (value.isEmpty) return context.tr(LocaleKeys.bookingAccount_enterEmail);
            if (!value.contains('@') || !value.contains('.')) {
              return context.tr(LocaleKeys.bookingAccount_invalidEmail);
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.sm),

        // Password
        _FieldLabel(label: context.tr(LocaleKeys.bookingAccount_passwordLabel)),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: passwordController,
          hint: context.tr(LocaleKeys.bookingAccount_passwordLabel),
          obscureText: obscurePassword,
          height: 56,
          prefixWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(
              Icons.lock_outline,
              color: AppColors.textSecondary,
              size: AppSizes.iconMd,
            ),
          ),
          suffixWidget: IconButton(
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
              (v == null || v.trim().isEmpty) ? context.tr(LocaleKeys.bookingAccount_enterPassword) : null,
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
                  context.tr(LocaleKeys.bookingAccount_rememberTitle),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.tr(LocaleKeys.bookingAccount_rememberDesc),
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
