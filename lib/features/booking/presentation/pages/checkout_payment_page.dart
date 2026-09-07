import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../../../app/widgets/app_toast.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/cubit/login_cubit.dart';
import '../../../home/domain/entities/service.dart';
import '../cubit/check_user_cubit.dart';
import '../cubit/checkout_cubit.dart';
import '../models/booking_models.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/booking_create_account_section.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/price_summary.dart';

/// Second (and final) step of the booking flow: account check (phone lookup /
/// create account or login — skipped when a stored login token already
/// identifies the user) + payment method selection + QR on one page.
///
/// Receives details + schedule from [BookingPage]. Confirming a payment
/// method sends the checkout (`/api/checkout/initialize`) and the QR code /
/// booking reference appear inline underneath — there is no third page.
class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({
    super.key,
    // ── Booking inputs (from step 1) ──
    this.serviceId,
    this.service,
    this.bookingType,
    this.consultationType,
    this.title,
    this.notes,
    this.date,
    this.startTime,
    this.timeDisplay,
    this.serviceTitle,
    this.isRegistered,
    this.name,
    this.phone,
    this.email,
    this.password,
    this.optionLabel,
    this.optionPrice,
    this.optionDuration,
    this.optionChannel,
    // ── Ticket / payment (legacy direct display) ──
    this.bookingReference = '',
    this.paymentMethod = 'zaincash',
    this.amount = 0,
    this.currencySymbol = 'د.ع',
    this.qrCode,
    this.paymentInstructions,
    this.whatsappUrl,
  });

  final int? serviceId;
  final Service? service;
  final String? bookingType;
  final String? consultationType;
  final String? title;
  final String? notes;
  final String? date;
  final String? startTime;
  final String? timeDisplay;
  final String? serviceTitle;
  final bool? isRegistered;
  final String? name;
  final String? phone;
  final String? email;
  final String? password;
  final String? optionLabel;
  final double? optionPrice;
  final int? optionDuration;
  final String? optionChannel;

  final String bookingReference;
  final String paymentMethod;
  final num amount;
  final String currencySymbol;
  final String? qrCode;
  final String? paymentInstructions;
  final String? whatsappUrl;

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  final _accountFormKey = GlobalKey<FormState>();

  late final CheckoutCubit _checkoutCubit;
  late final CheckUserCubit _checkUserCubit;
  late final LoginCubit _loginCubit;

  /// Nothing pre-selected: checkout is only sent after the user taps
  /// a payment method.
  PaymentMethod? _paymentMethod;

  // Account form controllers (guests only — hidden when a stored login
  // token already identifies the user).
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Login password — used only when check-user finds an existing account.
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;

  /// The full E.164 phone (dial code + digits) last sent to check-user —
  /// captured here since [CreateAccountSection] owns the country picker.
  String? _checkedPhone;

  @override
  void initState() {
    super.initState();
    _checkoutCubit = getIt<CheckoutCubit>();
    _checkUserCubit = getIt<CheckUserCubit>();
    _loginCubit = getIt<LoginCubit>();
  }

  @override
  void dispose() {
    _checkoutCubit.close();
    _checkUserCubit.close();
    _loginCubit.close();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  /// Legacy entry: opened with a ticket already (no booking inputs) — just
  /// display it, nothing to send.
  bool get _isLegacyTicket =>
      widget.bookingReference.isNotEmpty &&
      (widget.serviceId == null || widget.date == null);

  ConsultationOption get _option => ConsultationOption(
    label:
        widget.optionLabel ??
        widget.serviceTitle ??
        widget.service?.title ??
        widget.title ??
        '',
    price: (widget.optionPrice ?? widget.amount).toDouble(),
    durationMinutes: widget.optionDuration,
    channel: widget.optionChannel ?? widget.consultationType,
    currencySymbol: widget.currencySymbol.isNotEmpty
        ? widget.currencySymbol
        : widget.service?.currencySymbol,
  );

  void _onPhoneChecked(String fullPhone) {
    _checkedPhone = fullPhone;
    _loginCubit.reset();
    _loginPasswordController.clear();
    _checkUserCubit.check(fullPhone);
  }

  void _onChangePhone() {
    _checkUserCubit.reset();
    _loginCubit.reset();
    _loginPasswordController.clear();
  }

  void _onLogin(String password) {
    final phone = _checkedPhone;
    if (phone == null) return;
    _loginCubit.login(identifier: phone, password: password);
  }

  void _onLoginStateChanged(BuildContext context, LoginState state) {
    if (state is LoginSuccess) {
      AuthState.instance.login();
    }
  }

  /// Account must be resolved before any checkout: guests verify their
  /// phone first (and log in when the number is recognized).
  bool _isAccountReady() {
    // A persisted login token already identifies the user on the backend
    // (sent as `Authorization: Bearer`) — no phone check needed.
    if (AuthState.instance.isLoggedIn) return true;
    final checkState = _checkUserCubit.state;
    if (checkState is! CheckUserLoaded) {
      AppToast.show(context, context.tr(LocaleKeys.booking_verifyPhoneFirst));
      return false;
    }
    // A recognized account must actually log in first — that's what gets
    // the auth token the checkout call is identified by.
    if (checkState.result.isRegistered && _loginCubit.state is! LoginSuccess) {
      AppToast.show(context, context.tr(LocaleKeys.booking_loginFirst));
      return false;
    }
    if (!checkState.result.isRegistered) {
      if (!(_accountFormKey.currentState?.validate() ?? false)) return false;
    }
    return true;
  }

  void _submitFor(PaymentMethod method) {
    if (_checkoutCubit.state is CheckoutSubmitting) return;
    final serviceId = widget.serviceId;
    final date = widget.date;
    final startTime = widget.startTime;
    if (serviceId == null || date == null || startTime == null) {
      AppToast.show(context, context.tr(LocaleKeys.booking_selectDateTime));
      return;
    }
    if (!_isAccountReady()) return;

    // New flow: account payload comes from this step's account section.
    // Legacy callers may still pass it via extras — fall back to those.
    final bool isRegistered;
    final String? name;
    final String? phone;
    final String? email;
    final String? password;
    if (AuthState.instance.isLoggedIn) {
      isRegistered = true;
      name = phone = email = password = null;
    } else if (_checkedPhone != null) {
      final checkState = _checkUserCubit.state;
      isRegistered =
          checkState is CheckUserLoaded && checkState.result.isRegistered;
      name = isRegistered ? null : _nameController.text.trim();
      phone = isRegistered ? null : _checkedPhone;
      email = isRegistered ? null : _emailController.text.trim();
      password = isRegistered ? null : _passwordController.text;
    } else {
      isRegistered = widget.isRegistered ?? false;
      name = isRegistered ? null : widget.name;
      phone = isRegistered ? null : widget.phone;
      email = isRegistered ? null : widget.email;
      password = isRegistered ? null : widget.password;
    }

    _checkoutCubit.submit(
      serviceId: serviceId,
      bookingType: widget.bookingType ?? 'online',
      consultationType: widget.consultationType ?? 'video',
      paymentMethod: method.name,
      date: date,
      startTime: startTime,
      title: widget.title ?? '',
      notes: widget.notes,
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }

  Future<void> _onMethodSelected(PaymentMethod? method) async {
    // Tapping the selected method again removes the selection and
    // clears any checkout result shown underneath (unlocks the others).
    if (method == null) {
      if (_checkoutCubit.state is CheckoutSubmitting) return;
      setState(() => _paymentMethod = null);
      _checkoutCubit.reset();
      return;
    }
    if (_checkoutCubit.state is CheckoutSubmitting) return;
    // Account first: no confirm dialog until the phone is verified
    // (and recognized accounts are logged in).
    if (!_isAccountReady()) return;
    // Confirm before locking the other methods and sending checkout.
    final confirmed = await _confirmMethod(context, method);
    if (!confirmed || !mounted) return;
    setState(() => _paymentMethod = method);
    _submitFor(method);
  }

  /// Confirmation dialog shown before a payment method locks the others
  /// and triggers checkout.
  Future<bool> _confirmMethod(
    BuildContext context,
    PaymentMethod method,
  ) async {
    final label = method.localizedLabel(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr(LocaleKeys.payment_confirmTitle)),
        content: Text(
          dialogContext.tr(
            LocaleKeys.payment_confirmMessage,
            namedArgs: {'method': label},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr(LocaleKeys.common_cancel)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const StadiumBorder(),
            ),
            child: Text(
              dialogContext.tr(LocaleKeys.payment_confirmButton),
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _retryLastMethod() {
    final method = _paymentMethod;
    if (method != null) _submitFor(method);
  }

  void _onCheckoutChanged(BuildContext context, CheckoutState state) {
    // Success renders inline below with a button to My Sessions — no
    // automatic navigation. Only failures toast here.
    switch (state) {
      case CheckoutLoaded(:final result) when !result.success:
        AppToast.show(
          context,
          result.message ?? context.tr(LocaleKeys.booking_bookingFailed),
        );
      case CheckoutLoaded(:final result) when result.success:
        // The backend returns an access token for the patient account
        // (already persisted by the repository) — treat them as logged in
        // so account-gated tabs unlock immediately.
        if (result.token != null && result.token!.trim().isNotEmpty) {
          AuthState.instance.login();
        }
      case CheckoutError(:final failure):
        AppToast.show(context, failure.message);
      case CheckoutInitial() ||
          CheckoutSubmitting() ||
          CheckoutLoaded():
        break;
    }
  }

  String _paymentMethodLabel(BuildContext context, String method) =>
      switch (method) {
        'zaincash' => context.tr(LocaleKeys.payment_zaincashLabel),
        'superki' => 'SuperKI',
        _ => method,
      };

  static String _formatAmount(num amount) =>
      amount == amount.round() ? amount.round().toString() : amount.toString();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CheckoutCubit, CheckoutState>(
          bloc: _checkoutCubit,
          listener: _onCheckoutChanged,
        ),
        BlocListener<LoginCubit, LoginState>(
          bloc: _loginCubit,
          listener: _onLoginStateChanged,
        ),
      ],
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                BookingAppBar(
                  title: context.tr(LocaleKeys.booking_paymentTitle),
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Account check / creation (hidden when a stored
                        // token already identifies the user) ──────────────
                        if (!AuthState.instance.isLoggedIn) ...[
                          Form(
                            key: _accountFormKey,
                            child: BlocBuilder<CheckUserCubit, CheckUserState>(
                              bloc: _checkUserCubit,
                              builder: (context, checkState) {
                                return BlocBuilder<LoginCubit, LoginState>(
                                  bloc: _loginCubit,
                                  builder: (context, loginState) {
                                    return CreateAccountSection(
                                      nameController: _nameController,
                                      phoneController: _phoneController,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      obscurePassword: _obscurePassword,
                                      onTogglePassword: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      checkState: checkState,
                                      onCheckPhone: _onPhoneChecked,
                                      onChangePhone: _onChangePhone,
                                      loginPasswordController:
                                          _loginPasswordController,
                                      obscureLoginPassword:
                                          _obscureLoginPassword,
                                      onToggleLoginPassword: () => setState(
                                        () => _obscureLoginPassword =
                                            !_obscureLoginPassword,
                                      ),
                                      loginState: loginState,
                                      onLogin: _onLogin,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const RememberAccountCard(),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        Text(
                          context.tr(LocaleKeys.booking_paymentTitle),
                          textAlign: TextAlign.right,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PaymentMethodSelector(
                          selected: _paymentMethod,
                          onChanged: _onMethodSelected,
                          locked: _paymentMethod != null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PriceSummary(option: _option),
                        const SizedBox(height: AppSpacing.md),
                        // ── QR + booking result, inline under payment ──
                        if (_isLegacyTicket)
                          _LegacyTicketSection(
                            bookingReference: widget.bookingReference,
                            paymentMethodLabel: _paymentMethodLabel(
                              context,
                              widget.paymentMethod,
                            ),
                            amountLabel:
                                '${_formatAmount(widget.amount)} ${widget.currencySymbol}',
                            qrCode: widget.qrCode,
                            paymentInstructions: widget.paymentInstructions,
                          )
                        else
                          BlocBuilder<CheckoutCubit, CheckoutState>(
                            bloc: _checkoutCubit,
                            builder: (context, state) {
                              return switch (state) {
                                CheckoutSubmitting() =>
                                  const _SubmittingSection(),
                                CheckoutLoaded(:final result)
                                    when result.success =>
                                  _SuccessSection(
                                    bookingReference:
                                        result.bookingReference ?? '',
                                    paymentMethodLabel: _paymentMethodLabel(
                                      context,
                                      result.paymentMethod ??
                                          _paymentMethod?.name ??
                                          widget.paymentMethod,
                                    ),
                                    amountLabel:
                                        '${_formatAmount(result.amount ?? widget.optionPrice ?? widget.amount)} ${result.currencySymbol ?? widget.currencySymbol}',
                                    qrCode: result.qrCode,
                                    paymentInstructions:
                                        result.paymentInstructions,
                                  ),
                                CheckoutLoaded() => _FailureSection(
                                  onRetry: _retryLastMethod,
                                ),
                                CheckoutError(:final failure) =>
                                  _FailureSection(
                                    message: failure.message,
                                    onRetry: _retryLastMethod,
                                  ),
                                CheckoutInitial() => const SizedBox.shrink(),
                              };
                            },
                          ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading placeholder shown under the payment methods while checkout runs.
class _SubmittingSection extends StatelessWidget {
  const _SubmittingSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonPulse(
          child: SkeletonBox(width: 220, height: 220, borderRadius: 8),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ],
    );
  }
}

/// Inline success: QR code + reference + amount + a button to My Sessions,
/// all under the payment methods — no separate page, no auto-navigation.
class _SuccessSection extends StatelessWidget {
  const _SuccessSection({
    required this.bookingReference,
    required this.paymentMethodLabel,
    required this.amountLabel,
    this.qrCode,
    this.paymentInstructions,
  });

  final String bookingReference;
  final String paymentMethodLabel;
  final String amountLabel;
  final String? qrCode;
  final String? paymentInstructions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (paymentInstructions != null) ...[
          _InstructionsCard(text: paymentInstructions!),
          const SizedBox(height: AppSpacing.md),
        ],
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.allLg,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailRow(
                label: context.tr(LocaleKeys.payment_eTicket),
                value: '#$bookingReference',
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: context.tr(LocaleKeys.payment_paymentMethod),
                value: paymentMethodLabel,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: context.tr(LocaleKeys.payment_amountDue),
                value: amountLabel,
              ),
            ],
          ),
        ),
        if (qrCode != null) ...[
          const SizedBox(height: AppSpacing.md),
          _QrCodeCard(url: qrCode!),
        ],
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: context.tr(LocaleKeys.navigation_sessions),
          onPressed: () => context.go(AppRoutes.sessions),
        ),
      ],
    );
  }
}

/// Legacy ticket display (opened with a reference, nothing to send).
class _LegacyTicketSection extends StatelessWidget {
  const _LegacyTicketSection({
    required this.bookingReference,
    required this.paymentMethodLabel,
    required this.amountLabel,
    this.qrCode,
    this.paymentInstructions,
  });

  final String bookingReference;
  final String paymentMethodLabel;
  final String amountLabel;
  final String? qrCode;
  final String? paymentInstructions;

  @override
  Widget build(BuildContext context) {
    return _SuccessSection(
      bookingReference: bookingReference,
      paymentMethodLabel: paymentMethodLabel,
      amountLabel: amountLabel,
      qrCode: qrCode,
      paymentInstructions: paymentInstructions,
    );
  }
}

/// Inline failure with retry — stays on the same page.
class _FailureSection extends StatelessWidget {
  const _FailureSection({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message ?? context.tr(LocaleKeys.booking_bookingFailed),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          label: context.tr(LocaleKeys.common_retry),
          onPressed: onRetry,
        ),
      ],
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.text});
  final String text;

  static const Color _amber = Color(0xFFF2A20C);
  static const Color _amberTint = Color(0xFFFFF9EC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _amberTint,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: _amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(left: AppSpacing.sm),
            decoration: const BoxDecoration(
              color: _amber,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.white,
              size: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _QrCodeCard extends StatelessWidget {
  const _QrCodeCard({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            context.tr(LocaleKeys.payment_scanQr),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.allMd,
            child: Image.network(
              url,
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SkeletonPulse(
                  child: SkeletonBox(width: 220, height: 220, borderRadius: 8),
                );
              },
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
