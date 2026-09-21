import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_direction.dart';
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
import '../../domain/entities/payment_method_option.dart';
import '../cubit/check_user_cubit.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/confirm_local_payment_cubit.dart';
import '../cubit/confirm_payment_cubit.dart';
import '../cubit/payment_methods_cubit.dart';
import '../models/booking_models.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/booking_create_account_section.dart';
import '../widgets/outlined_card_field.dart';
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
  late final PaymentMethodsCubit _paymentMethodsCubit;

  /// Nothing pre-selected: checkout is only sent after the user taps
  /// a payment method.
  PaymentMethodOption? _paymentMethod;

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
    _paymentMethodsCubit = getIt<PaymentMethodsCubit>()..load();
  }

  @override
  void dispose() {
    _checkoutCubit.close();
    _checkUserCubit.close();
    _loginCubit.close();
    _paymentMethodsCubit.close();
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

  ConsultationOption _optionFor(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return ConsultationOption(
      label:
          widget.optionLabel ??
          widget.serviceTitle ??
          widget.service?.titleFor(isArabic) ??
          widget.title ??
          '',
      price: (widget.optionPrice ?? widget.amount).toDouble(),
      durationMinutes: widget.optionDuration,
      channel: widget.optionChannel ?? widget.consultationType,
      currencySymbol: widget.currencySymbol.isNotEmpty
          ? widget.currencySymbol
          : widget.service?.currencySymbol,
    );
  }

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

  void _submitFor(PaymentMethodOption method) {
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
      paymentMethod: method.id,
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

  /// Tapping a payment method sends `/api/checkout/initialize` for it right
  /// away and its QR / booking reference render below. The list stays
  /// switchable: picking another method re-sends for that one and replaces
  /// the QR. Tapping the selected method again clears the selection.
  void _onMethodSelected(PaymentMethodOption? method) {
    // Ignore taps while a request is in flight to avoid overlapping
    // checkouts.
    if (_checkoutCubit.state is CheckoutSubmitting) return;

    if (method == null) {
      setState(() => _paymentMethod = null);
      _checkoutCubit.reset();
      return;
    }

    setState(() => _paymentMethod = method);
    _submitFor(method);
  }

  /// The method list is only frozen while a checkout request is actually in
  /// flight — otherwise the user may keep switching methods.
  bool _selectionLocked(CheckoutState state) => state is CheckoutSubmitting;

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
      case CheckoutInitial() || CheckoutSubmitting() || CheckoutLoaded():
        break;
    }
  }

  /// Resolves a payment-method id to its localized display name using the
  /// list already loaded from `/api/payment-methods`, falling back to the
  /// currently selected method or a humanized id.
  String _paymentMethodLabel(BuildContext context, String methodId) {
    final isArabic = context.locale.languageCode == 'ar';
    final state = _paymentMethodsCubit.state;
    if (state is PaymentMethodsLoaded) {
      for (final m in state.config.methods) {
        if (m.id == methodId) return m.nameFor(isArabic);
      }
    }
    if (_paymentMethod?.id == methodId) {
      return _paymentMethod!.nameFor(isArabic);
    }
    return methodId.isEmpty ? '' : methodId;
  }

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
        textDirection: context.localeTextDirection,
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
                          textAlign: TextAlign.start,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        BlocBuilder<CheckoutCubit, CheckoutState>(
                          bloc: _checkoutCubit,
                          builder: (context, checkoutState) {
                            final locked = _selectionLocked(checkoutState);
                            return BlocBuilder<PaymentMethodsCubit,
                                PaymentMethodsState>(
                              bloc: _paymentMethodsCubit,
                              builder: (context, state) {
                                return switch (state) {
                                  PaymentMethodsLoaded(:final methods)
                                      when methods.isNotEmpty =>
                                    PaymentMethodSelector(
                                      methods: methods,
                                      selected: _paymentMethod,
                                      onChanged: _onMethodSelected,
                                      locked: locked,
                                    ),
                                  PaymentMethodsError() => _PaymentMethodsError(
                                    onRetry: _paymentMethodsCubit.load,
                                  ),
                                  PaymentMethodsLoaded() => _PaymentMethodsError(
                                    onRetry: _paymentMethodsCubit.load,
                                  ),
                                  _ => const _PaymentMethodsLoading(),
                                };
                              },
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PriceSummary(option: _optionFor(context)),
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
                                    paymentMethod:
                                        result.paymentMethod ??
                                        _paymentMethod?.id ??
                                        widget.paymentMethod,
                                    paymentMethodLabel: _paymentMethodLabel(
                                      context,
                                      result.paymentMethod ??
                                          _paymentMethod?.id ??
                                          widget.paymentMethod,
                                    ),
                                    amountLabel:
                                        '${_formatAmount(result.amount ?? widget.optionPrice ?? widget.amount)} ${result.currencySymbol ?? widget.currencySymbol}',
                                    qrCode: result.qrCode,
                                    paymentInstructions:
                                        result.paymentInstructions,
                                    transactionReference:
                                        result.transactionReference,
                                    transferNumber: result.transferNumber,
                                    showConfirmPayment:
                                        (result.bookingReference ?? '')
                                            .isNotEmpty,
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

/// Skeleton rows while `/api/payment-methods` loads.
class _PaymentMethodsLoading extends StatelessWidget {
  const _PaymentMethodsLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonPulse(
          child: SkeletonBox(
            width: double.infinity,
            height: 72,
            borderRadius: 16,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        SkeletonPulse(
          child: SkeletonBox(
            width: double.infinity,
            height: 72,
            borderRadius: 16,
          ),
        ),
      ],
    );
  }
}

/// Inline error + retry when the payment-method list can't be loaded.
class _PaymentMethodsError extends StatelessWidget {
  const _PaymentMethodsError({required this.onRetry});
  final VoidCallback onRetry;

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
            context.tr(LocaleKeys.payment_methodsError),
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onRetry,
            child: Text(context.tr(LocaleKeys.common_retry)),
          ),
        ],
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

/// Inline success: QR code + reference + amount + (for a real booking) a
/// payment-proof upload form, all under the payment methods — no separate
/// page, no auto-navigation.
class _SuccessSection extends StatefulWidget {
  const _SuccessSection({
    required this.bookingReference,
    required this.paymentMethodLabel,
    required this.amountLabel,
    this.paymentMethod,
    this.qrCode,
    this.paymentInstructions,
    this.transactionReference,
    this.transferNumber,
    this.showConfirmPayment = false,
  });

  final String bookingReference;
  final String? paymentMethod;
  final String paymentMethodLabel;
  final String amountLabel;
  final String? qrCode;
  final String? paymentInstructions;
  final String? transactionReference;
  final String? transferNumber;

  /// Whether to show the receipt-upload / confirm-payment form (only for a
  /// freshly created booking, never the legacy ticket display).
  final bool showConfirmPayment;

  @override
  State<_SuccessSection> createState() => _SuccessSectionState();
}

class _SuccessSectionState extends State<_SuccessSection> {
  final _formKey = GlobalKey<FormState>();
  final _transferNumberController = TextEditingController();
  final _picker = ImagePicker();

  // Final "confirm-local" step (shown after the receipt upload succeeds).
  final _localFormKey = GlobalKey<FormState>();
  final _localTransferNumberController = TextEditingController();
  final _txReferenceController = TextEditingController();
  final _notesController = TextEditingController();

  ConfirmPaymentCubit? _confirmCubit;
  ConfirmLocalPaymentCubit? _localCubit;
  File? _receiptImage;
  bool _localFieldsPrefilled = false;

  @override
  void initState() {
    super.initState();
    if (widget.showConfirmPayment) {
      _confirmCubit = getIt<ConfirmPaymentCubit>();
      _localCubit = getIt<ConfirmLocalPaymentCubit>();
    }
  }

  @override
  void dispose() {
    _confirmCubit?.close();
    _localCubit?.close();
    _transferNumberController.dispose();
    _localTransferNumberController.dispose();
    _txReferenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(sheetContext.tr(LocaleKeys.payment_pickFromGallery)),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(sheetContext.tr(LocaleKeys.payment_pickFromCamera)),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked == null || !mounted) return;
    setState(() => _receiptImage = File(picked.path));
  }

  void _submitProof() {
    final cubit = _confirmCubit;
    if (cubit == null || cubit.state is ConfirmPaymentSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_receiptImage == null) {
      AppToast.show(context, context.tr(LocaleKeys.payment_receiptRequired));
      return;
    }
    cubit.submit(
      bookingRef: widget.bookingReference,
      paymentMethod: widget.paymentMethod ?? 'zaincash',
      transferNumber: _transferNumberController.text.trim(),
      transactionReference: widget.transactionReference,
      receiptImagePath: _receiptImage!.path,
    );
  }

  void _onConfirmStateChanged(BuildContext context, ConfirmPaymentState state) {
    switch (state) {
      case ConfirmPaymentLoaded(:final result) when !result.success:
        AppToast.show(
          context,
          result.message ?? context.tr(LocaleKeys.payment_confirmPaymentFailed),
        );
      case ConfirmPaymentLoaded(:final result) when result.success:
        // Step 1 done — seed the final "confirm-local" form once with what
        // the user already provided / what checkout returned.
        if (!_localFieldsPrefilled) {
          _localFieldsPrefilled = true;
          _localTransferNumberController.text =
              _transferNumberController.text.trim();
          if (widget.transactionReference != null) {
            _txReferenceController.text = widget.transactionReference!;
          }
        }
      case ConfirmPaymentFailure(:final failure):
        AppToast.show(context, failure.message);
      case ConfirmPaymentInitial() ||
          ConfirmPaymentSubmitting() ||
          ConfirmPaymentLoaded():
        break;
    }
  }

  void _submitLocal() {
    final cubit = _localCubit;
    if (cubit == null || cubit.state is ConfirmLocalPaymentSubmitting) return;
    if (!(_localFormKey.currentState?.validate() ?? false)) return;
    cubit.submit(
      bookingReference: widget.bookingReference,
      paymentMethod: widget.paymentMethod ?? 'zaincash',
      transferNumber: _localTransferNumberController.text.trim(),
      transactionReference: _txReferenceController.text.trim(),
      notes: _notesController.text.trim(),
    );
  }

  void _onLocalStateChanged(
    BuildContext context,
    ConfirmLocalPaymentState state,
  ) {
    switch (state) {
      case ConfirmLocalPaymentLoaded(:final result) when !result.success:
        AppToast.show(
          context,
          result.message ?? context.tr(LocaleKeys.payment_confirmPaymentFailed),
        );
      case ConfirmLocalPaymentFailure(:final failure):
        AppToast.show(context, failure.message);
      case ConfirmLocalPaymentInitial() ||
          ConfirmLocalPaymentSubmitting() ||
          ConfirmLocalPaymentLoaded():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.paymentInstructions != null) ...[
          _InstructionsCard(text: widget.paymentInstructions!),
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
                value: '#${widget.bookingReference}',
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: context.tr(LocaleKeys.payment_paymentMethod),
                value: widget.paymentMethodLabel,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: context.tr(LocaleKeys.payment_amountDue),
                value: widget.amountLabel,
              ),
              if (widget.transferNumber != null &&
                  widget.transferNumber!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _DetailRow(
                  label: context.tr(LocaleKeys.payment_transferToNumber),
                  value: widget.transferNumber!,
                ),
              ],
            ],
          ),
        ),
        if (widget.qrCode != null) ...[
          const SizedBox(height: AppSpacing.md),
          _QrCodeCard(url: widget.qrCode!),
        ],
        if (widget.showConfirmPayment && _confirmCubit != null) ...[
          const SizedBox(height: AppSpacing.md),
          // ── Step 1: receipt-image upload ──
          BlocConsumer<ConfirmPaymentCubit, ConfirmPaymentState>(
            bloc: _confirmCubit,
            listener: _onConfirmStateChanged,
            builder: (context, state) {
              if (state is ConfirmPaymentLoaded && state.result.success) {
                return const _ProofSubmittedCard();
              }
              final submitting = state is ConfirmPaymentSubmitting;
              return _ConfirmPaymentForm(
                formKey: _formKey,
                transferNumberController: _transferNumberController,
                receiptImage: _receiptImage,
                submitting: submitting,
                onPickImage: _pickImage,
                onSubmit: _submitProof,
              );
            },
          ),
          // ── Step 2: confirm-local payment (only after step 1 succeeds) ──
          BlocBuilder<ConfirmPaymentCubit, ConfirmPaymentState>(
            bloc: _confirmCubit,
            builder: (context, proofState) {
              final proofDone = proofState is ConfirmPaymentLoaded &&
                  proofState.result.success;
              if (!proofDone || _localCubit == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: BlocConsumer<ConfirmLocalPaymentCubit,
                    ConfirmLocalPaymentState>(
                  bloc: _localCubit,
                  listener: _onLocalStateChanged,
                  builder: (context, state) {
                    if (state is ConfirmLocalPaymentLoaded &&
                        state.result.success) {
                      return const _LocalPaymentConfirmedCard();
                    }
                    return _ConfirmLocalPaymentForm(
                      formKey: _localFormKey,
                      transferNumberController: _localTransferNumberController,
                      transactionReferenceController: _txReferenceController,
                      notesController: _notesController,
                      submitting: state is ConfirmLocalPaymentSubmitting,
                      onSubmit: _submitLocal,
                    );
                  },
                ),
              );
            },
          ),
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

/// Receipt-upload form posted to `/api/booking/{ref}/confirm-payment`.
class _ConfirmPaymentForm extends StatelessWidget {
  const _ConfirmPaymentForm({
    required this.formKey,
    required this.transferNumberController,
    required this.receiptImage,
    required this.submitting,
    required this.onPickImage,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController transferNumberController;
  final File? receiptImage;
  final bool submitting;
  final VoidCallback onPickImage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr(LocaleKeys.payment_confirmPaymentTitle),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.tr(LocaleKeys.payment_transferNumberLabel),
              textAlign: TextAlign.start,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            OutlinedCardField(
              controller: transferNumberController,
              hintText: context.tr(LocaleKeys.payment_transferNumberHint),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? context.tr(LocaleKeys.validation_required)
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.tr(LocaleKeys.payment_receiptImageLabel),
              textAlign: TextAlign.start,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _ReceiptPicker(image: receiptImage, onTap: onPickImage),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: submitting
                  ? context.tr(LocaleKeys.booking_submitting)
                  : context.tr(LocaleKeys.payment_submitProof),
              onPressed: submitting ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  const _ReceiptPicker({required this.image, required this.onTap});

  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.allMd,
      child: Container(
        height: image == null ? 96 : 180,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.allMd,
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        clipBehavior: Clip.antiAlias,
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.tr(LocaleKeys.payment_pickImage),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(image!, fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.tr(LocaleKeys.payment_changeImage),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProofSubmittedCard extends StatelessWidget {
  const _ProofSubmittedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.tr(LocaleKeys.payment_confirmPaymentSuccess),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Final confirmation form posted as JSON to `/api/payment/confirm-local`.
class _ConfirmLocalPaymentForm extends StatelessWidget {
  const _ConfirmLocalPaymentForm({
    required this.formKey,
    required this.transferNumberController,
    required this.transactionReferenceController,
    required this.notesController,
    required this.submitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController transferNumberController;
  final TextEditingController transactionReferenceController;
  final TextEditingController notesController;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    String? required(String? value) => (value == null || value.trim().isEmpty)
        ? context.tr(LocaleKeys.validation_required)
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr(LocaleKeys.payment_confirmLocalTitle),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr(LocaleKeys.payment_confirmLocalSubtitle),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FieldLabel(text: context.tr(LocaleKeys.payment_transferNumberLabel)),
            OutlinedCardField(
              controller: transferNumberController,
              hintText: context.tr(LocaleKeys.payment_transferNumberHint),
              validator: required,
            ),
            const SizedBox(height: AppSpacing.md),
            _FieldLabel(
              text: context.tr(LocaleKeys.payment_transactionReferenceLabel),
            ),
            OutlinedCardField(
              controller: transactionReferenceController,
              hintText: context.tr(
                LocaleKeys.payment_transactionReferenceHint,
              ),
              validator: required,
            ),
            const SizedBox(height: AppSpacing.md),
            _FieldLabel(text: context.tr(LocaleKeys.payment_notesLabel)),
            OutlinedCardField(
              controller: notesController,
              hintText: context.tr(LocaleKeys.payment_notesHint),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: submitting
                  ? context.tr(LocaleKeys.booking_submitting)
                  : context.tr(LocaleKeys.payment_confirmLocalCta),
              onPressed: submitting ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _LocalPaymentConfirmedCard extends StatelessWidget {
  const _LocalPaymentConfirmedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.allLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.tr(LocaleKeys.payment_confirmLocalSuccess),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
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
              textAlign: TextAlign.start,
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
            textAlign: TextAlign.end,
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
