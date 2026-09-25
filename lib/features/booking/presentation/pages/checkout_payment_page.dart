import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_direction.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../../../app/widgets/app_toast.dart';
import '../../../../app/widgets/bootstrap_icon_mapper.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/cubit/login_cubit.dart';
import '../../../home/domain/entities/service.dart';
import '../../domain/entities/payment_method_option.dart';
import '../cubit/check_user_cubit.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/payment_methods_cubit.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/booking_create_account_section.dart';
import '../widgets/payment_success_details_card.dart';

/// Second (and final) step of the booking flow matching the website experience:
/// - Order & pricing summary banner (with duration and booking type)
/// - Guest account check & registration (skipped when already logged in)
/// - Dynamic payment method selection (ZainCash, SuperKi, Card) with immediate QR & instructions display
/// - Sender transfer/wallet number field
/// - Receipt screenshot drop/upload target with camera/gallery picker and preview
/// - Terms and conditions agreement checkbox
/// - Sticky bottom action bar with total price & "تأكيد الحجز النهائي" button
/// - Immediate transition to E-Ticket [PaymentSuccessPage] on completion.
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

  PaymentMethodOption? _selectedMethod;

  // Account form controllers (guests only)
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Login password (if check-user finds an existing account)
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;

  String? _checkedPhone;

  // Payment proof details (Transfer Number & Receipt Screenshot)
  final _transferNumberController = TextEditingController();
  File? _receiptImage;
  final _picker = ImagePicker();
  bool _termsAccepted = true;

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
    _transferNumberController.dispose();
    super.dispose();
  }

  bool get _isLegacyTicket =>
      widget.bookingReference.isNotEmpty &&
      (widget.serviceId == null || widget.date == null);

  static String _formatAmount(num amount) =>
      amount == amount.round() ? amount.round().toString() : amount.toString();

  String get _displayPrice {
    final price = widget.optionPrice ?? widget.amount;
    final sym = widget.currencySymbol.isNotEmpty
        ? widget.currencySymbol
        : widget.service?.currencySymbol ?? 'د.ع';
    return '${_formatAmount(price)} $sym';
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

  bool _isAccountReady() {
    if (AuthState.instance.isLoggedIn) return true;
    final checkState = _checkUserCubit.state;
    if (checkState is! CheckUserLoaded) {
      AppToast.show(context, context.tr(LocaleKeys.booking_verifyPhoneFirst));
      return false;
    }
    if (checkState.result.isRegistered && _loginCubit.state is! LoginSuccess) {
      AppToast.show(context, context.tr(LocaleKeys.booking_loginFirst));
      return false;
    }
    if (!checkState.result.isRegistered) {
      if (!(_accountFormKey.currentState?.validate() ?? false)) return false;
    }
    return true;
  }

  Future<void> _pickReceiptImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  sheetContext.tr(LocaleKeys.payment_pickFromGallery),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  sheetContext.tr(LocaleKeys.payment_pickFromCamera),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null || !mounted) return;
    setState(() => _receiptImage = File(picked.path));
  }

  void _removeReceiptImage() {
    setState(() => _receiptImage = null);
  }

  void _submitFinalBooking() {
    if (_checkoutCubit.state is CheckoutSubmitting) return;

    if (!_termsAccepted) {
      AppToast.show(
        context,
        context.tr(LocaleKeys.payment_termsRequired),
      );
      return;
    }

    final serviceId = widget.serviceId;
    final date = widget.date;
    final startTime = widget.startTime;
    if (serviceId == null || date == null || startTime == null) {
      AppToast.show(context, context.tr(LocaleKeys.booking_selectDateTime));
      return;
    }

    if (!_isAccountReady()) return;

    final isRegistered = AuthState.instance.isLoggedIn
        ? true
        : (_checkedPhone != null
            ? (_checkUserCubit.state is CheckUserLoaded &&
                (_checkUserCubit.state as CheckUserLoaded).result.isRegistered)
            : (widget.isRegistered ?? false));

    final String? name = isRegistered
        ? null
        : (_checkedPhone != null
            ? _nameController.text.trim()
            : widget.name);
    final String? phone = isRegistered
        ? null
        : (_checkedPhone ?? widget.phone);
    final String? email = isRegistered
        ? null
        : (_checkedPhone != null
            ? _emailController.text.trim()
            : widget.email);
    final String? password = isRegistered
        ? null
        : (_checkedPhone != null
            ? _passwordController.text
            : widget.password);

    final selectedMethodId = _selectedMethod?.id ?? 'zaincash';

    _checkoutCubit.submit(
      serviceId: serviceId,
      bookingType: widget.bookingType ?? 'online',
      consultationType: widget.consultationType ?? 'video',
      paymentMethod: selectedMethodId,
      date: date,
      startTime: startTime,
      title: widget.title ?? widget.serviceTitle ?? '',
      notes: widget.notes,
      name: name,
      phone: phone,
      email: email,
      password: password,
      transferNumber: _transferNumberController.text.trim(),
      receiptImagePath: _receiptImage?.path,
    );
  }

  void _onCheckoutChanged(BuildContext context, CheckoutState state) {
    final isArabic = context.locale.languageCode == 'ar';
    switch (state) {
      case CheckoutLoaded(:final result) when result.success:
        if (result.token != null && result.token!.trim().isNotEmpty) {
          AuthState.instance.login();
        }
        // Navigate immediately to the E-Ticket success screen matching the website
        final methodLabel = _selectedMethod?.nameFor(isArabic) ??
            result.paymentMethod ??
            widget.paymentMethod;
        final serviceName = widget.serviceTitle ??
            widget.service?.titleFor(isArabic) ??
            widget.title ??
            context.tr(LocaleKeys.booking_instantSession);
        final date = widget.date ?? '';
        final time = widget.timeDisplay ?? widget.startTime ?? '';
        final amountLabel =
            '${_formatAmount(result.amount ?? widget.optionPrice ?? widget.amount)} ${result.currencySymbol ?? widget.currencySymbol}';

        context.go(
          AppRoutes.paymentSuccess,
          extra: <String, dynamic>{
            'referenceNumber': result.bookingReference ?? '',
            'serviceName': serviceName,
            'appointmentDate': date,
            'appointmentTime': time,
            'paymentMethod': methodLabel,
            'amount': amountLabel,
          },
        );
      case CheckoutLoaded(:final result) when !result.success:
        AppToast.show(
          context,
          result.message ?? context.tr(LocaleKeys.booking_bookingFailed),
        );
      case CheckoutLoaded():
        break;
      case CheckoutError(:final failure):
        AppToast.show(context, failure.message);
      case CheckoutInitial() || CheckoutSubmitting():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

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
                  title: context.tr(LocaleKeys.payment_title),
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
                        // ── Step 2: Account Check/Creation (Guests only) ──
                        if (!AuthState.instance.isLoggedIn &&
                            !_isLegacyTicket) ...[
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
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // ── Legacy Ticket Direct View ──
                        if (_isLegacyTicket) ...[
                          SuccessDetailsCard(
                            referenceNumber: widget.bookingReference,
                            serviceName: widget.serviceTitle ??
                                widget.title ??
                                'جلسة استشارة',
                            appointmentDate: widget.date ?? '',
                            appointmentTime:
                                widget.timeDisplay ?? widget.startTime ?? '',
                            paymentMethod: widget.paymentMethod,
                            amount: _displayPrice,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ] else ...[
                          // ── Step 3: Order Summary Banner (Website layout) ──
                          _OrderSummaryBanner(
                            priceText: _displayPrice,
                            isClinic: widget.bookingType == 'clinic',
                            durationMinutes: widget.optionDuration,
                            isArabic: isArabic,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // ── Payment Method Selector ──
                          _SectionHeading(
                            icon: Icons.account_balance_wallet_outlined,
                            title: context.tr(LocaleKeys.payment_paymentMethod),
                          ),
                          const SizedBox(height: AppSpacing.xs + 2),

                          BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
                            bloc: _paymentMethodsCubit,
                            builder: (context, state) {
                              return switch (state) {
                                PaymentMethodsLoaded(:final methods)
                                    when methods.isNotEmpty =>
                                  _PaymentMethodsView(
                                    methods: methods,
                                    selected: _selectedMethod ??
                                        (_selectedMethod = methods.firstWhere(
                                          (m) => m.id == widget.paymentMethod,
                                          orElse: () => methods.first,
                                        )),
                                    onChanged: (method) {
                                      setState(() => _selectedMethod = method);
                                    },
                                    isArabic: isArabic,
                                  ),
                                PaymentMethodsError() => _PaymentMethodsError(
                                    onRetry: _paymentMethodsCubit.load,
                                  ),
                                _ => const _PaymentMethodsLoading(),
                              };
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // ── Transfer Details & Receipt Proof Box ──
                          _ProofUploadCard(
                            transferNumberController:
                                _transferNumberController,
                            receiptImage: _receiptImage,
                            onPickImage: _pickReceiptImage,
                            onRemoveImage: _removeReceiptImage,
                            isArabic: isArabic,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // ── Terms & Policy Agreement Checkbox ──
                          _TermsCheckboxRow(
                            value: _termsAccepted,
                            onChanged: (v) =>
                                setState(() => _termsAccepted = v ?? false),
                          ),
                          const SizedBox(height: 90), // Spacing for bottom bar
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Sticky Bottom Action Bar matching Website ──
                if (!_isLegacyTicket)
                  BlocBuilder<CheckoutCubit, CheckoutState>(
                    bloc: _checkoutCubit,
                    builder: (context, checkoutState) {
                      final submitting = checkoutState is CheckoutSubmitting;
                      return _StickyBottomBar(
                        priceText: _displayPrice,
                        submitting: submitting,
                        onSubmit: _submitFinalBooking,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER SUMMARY BANNER (Matching .order-summary-card in booking_modal.blade.php)
// ─────────────────────────────────────────────────────────────────────────────
class _OrderSummaryBanner extends StatelessWidget {
  const _OrderSummaryBanner({
    required this.priceText,
    required this.isClinic,
    this.durationMinutes,
    required this.isArabic,
  });

  final String priceText;
  final bool isClinic;
  final int? durationMinutes;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allXl,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    context.tr(LocaleKeys.payment_orderTotal),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  priceText,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _FeatureBullet(
                label: isClinic
                    ? context.tr(LocaleKeys.payment_clinicVisit)
                    : context.tr(LocaleKeys.payment_onlineConsultation),
              ),
              if (durationMinutes != null && durationMinutes! > 0)
                _FeatureBullet(
                  label: '$durationMinutes ${isArabic ? 'دقيقة' : 'min'}',
                ),
              _FeatureBullet(
                label: context.tr(LocaleKeys.payment_directBooking),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 15,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT METHODS SWITCHER & PANELS (Website segmented switcher + QR)
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentMethodsView extends StatelessWidget {
  const _PaymentMethodsView({
    required this.methods,
    required this.selected,
    required this.onChanged,
    required this.isArabic,
  });

  final List<PaymentMethodOption> methods;
  final PaymentMethodOption selected;
  final ValueChanged<PaymentMethodOption> onChanged;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Segmented Switcher / Tabs ──
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: methods.map((method) {
              final isSelected = method.id == selected.id;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(method),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (method.logo != null && method.logo!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              method.logo!,
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  _FallbackIcon(method: method),
                            ),
                          )
                        else
                          _FallbackIcon(method: method),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            method.nameFor(isArabic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Active Method Display Panel ──
        _ActiveMethodPanel(method: selected, isArabic: isArabic),
      ],
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.method});
  final PaymentMethodOption method;

  @override
  Widget build(BuildContext context) {
    if (method.iconClass != null && method.iconClass!.isNotEmpty) {
      return Icon(
        bootstrapIconToMaterial(method.iconClass, isClinic: false),
        size: 16,
        color: AppColors.primary,
      );
    }
    return const Icon(
      Icons.account_balance_wallet_outlined,
      size: 16,
      color: AppColors.primary,
    );
  }
}

class _ActiveMethodPanel extends StatelessWidget {
  const _ActiveMethodPanel({
    required this.method,
    required this.isArabic,
  });

  final PaymentMethodOption method;
  final bool isArabic;

  Future<void> _openCardLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCard = method.id == 'card';
    final hasQr = method.qrImage != null && method.qrImage!.trim().isNotEmpty;
    final instructions = method.instructions ??
        (isArabic
            ? 'امسح رمز الـ QR لإتمام الدفع، ثم أرفق سكرين شوت الإيصال بالأسفل.'
            : 'Scan the QR code to complete payment, then attach receipt below.');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: AppRadius.allXl,
        border: Border.all(color: AppColors.border),
      ),
      child: isCard
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.security_outlined,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          method.badge ??
                              context.tr(LocaleKeys.payment_secureOnline),
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _CardBadge(label: 'VISA', color: AppColors.primary),
                        const SizedBox(width: 4),
                        _CardBadge(
                          label: 'MasterCard',
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  instructions,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (method.link != null && method.link!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm + 2),
                  OutlinedButton.icon(
                    onPressed: () => _openCardLink(method.link!.trim()),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      context.tr(LocaleKeys.payment_openPaymentLink),
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            )
          : Column(
              children: [
                if (hasQr) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        method.qrImage!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                          width: 140,
                          height: 140,
                          child: Icon(
                            Icons.qr_code_2_rounded,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ] else ...[
                  const Icon(
                    Icons.qr_code_scanner_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  instructions,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSFER DETAILS & RECEIPT PROOF (Matching website proof upload box)
// ─────────────────────────────────────────────────────────────────────────────
class _ProofUploadCard extends StatelessWidget {
  const _ProofUploadCard({
    required this.transferNumberController,
    required this.receiptImage,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.isArabic,
  });

  final TextEditingController transferNumberController;
  final File? receiptImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allXl,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Transfer Number Input ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.phone_android_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.tr(LocaleKeys.payment_transferNumberLabel),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  context.tr(LocaleKeys.payment_optional),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),

          Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: transferNumberController,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.tag_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                hintText: context.tr(LocaleKeys.payment_transferNumberHint),
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Receipt Screenshot Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.image_outlined,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.tr(LocaleKeys.payment_receiptImageLabel),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  context.tr(LocaleKeys.payment_fastConfirm),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),

          // ── Dashed Receipt Drop Box ──
          GestureDetector(
            onTap: onPickImage,
            child: CustomPaint(
              painter: const _DashedRectPainter(
                color: Color(0xFFCBD5E1),
                strokeWidth: 1.5,
                radius: 12,
                dash: 5,
                gap: 4,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: receiptImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            color: AppColors.primary,
                            size: 36,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr(
                              LocaleKeys.payment_clickToUploadReceipt,
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr(LocaleKeys.payment_supportedFormats),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              receiptImage!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  receiptImage!.path
                                      .split(RegExp(r'[/\\]'))
                                      .last,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.success,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.tr(
                                        LocaleKeys.payment_receiptAttached,
                                      ),
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: onRemoveImage,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TERMS & AGREEMENT CHECKBOX ROW
// ─────────────────────────────────────────────────────────────────────────────
class _TermsCheckboxRow extends StatelessWidget {
  const _TermsCheckboxRow({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              context.tr(LocaleKeys.payment_termsAgreement),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STICKY BOTTOM ACTION BAR (Matching website .modal-bottom-bar-fixed)
// ─────────────────────────────────────────────────────────────────────────────
class _StickyBottomBar extends StatelessWidget {
  const _StickyBottomBar({
    required this.priceText,
    required this.submitting,
    required this.onSubmit,
  });

  final String priceText;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                priceText,
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
              Text(
                context.tr(LocaleKeys.payment_orderTotal),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: SizedBox(
              height: AppSizes.buttonHeight,
              child: FilledButton.icon(
                onPressed: submitting ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                label: Text(
                  context.tr(LocaleKeys.payment_confirmFinalBooking),
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
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

// ─────────────────────────────────────────────────────────────────────────────
// DASHED RECTANGLE CUSTOM PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
    this.dash = 5.0,
    this.radius = 12.0,
  });

  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final length = draw ? dash : gap;
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      radius != oldDelegate.radius;
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADING & SKELETONS
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodsLoading extends StatelessWidget {
  const _PaymentMethodsLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonPulse(child: SkeletonBox(height: 48, borderRadius: 14)),
        SizedBox(height: AppSpacing.sm),
        SkeletonPulse(child: SkeletonBox(height: 120, borderRadius: 16)),
      ],
    );
  }
}

class _PaymentMethodsError extends StatelessWidget {
  const _PaymentMethodsError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allXl,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            context.tr(LocaleKeys.payment_methodsError),
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(context.tr(LocaleKeys.common_retry)),
          ),
        ],
      ),
    );
  }
}
