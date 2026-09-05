import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/widgets/app_toast.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/cubit/login_cubit.dart';
import '../../domain/entities/time_slot.dart';
import '../cubit/check_user_cubit.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/slots_cubit.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/booking_calendar_card.dart';
import '../widgets/booking_create_account_section.dart';
import '../widgets/booking_time_slots_section.dart';

class BookingStep2Page extends StatefulWidget {
  const BookingStep2Page({
    super.key,
    this.serviceId,
    this.bookingType,
    this.consultationType,
    this.paymentMethod,
    this.title,
    this.notes,
  });

  /// The service being booked. Slots are fetched per service + date;
  /// without an id (legacy/deep-link entry) the time picker stays empty.
  final int? serviceId;

  /// 'clinic' or 'online', carried over from step 1.
  final String? bookingType;

  /// The selected channel ('video'/'voice'/'chat') or 'clinic'.
  final String? consultationType;

  /// 'zaincash' or 'superki', carried over from step 1.
  final String? paymentMethod;

  /// Consultation title entered on step 1.
  final String? title;

  /// Consultation details entered on step 1.
  final String? notes;

  static void show(BuildContext context, {int? serviceId}) {
    context.push(AppRoutes.bookingStep2, extra: {'serviceId': serviceId});
  }

  @override
  State<BookingStep2Page> createState() => _BookingStep2PageState();
}

class _BookingStep2PageState extends State<BookingStep2Page> {
  final _formKey = GlobalKey<FormState>();
  late final SlotsCubit _slotsCubit;
  late final CheckUserCubit _checkUserCubit;
  late final CheckoutCubit _checkoutCubit;
  late final LoginCubit _loginCubit;

  // Calendar state
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  TimeSlot? _selectedTime;

  // Form controllers
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
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _slotsCubit = getIt<SlotsCubit>();
    _checkUserCubit = getIt<CheckUserCubit>();
    _checkoutCubit = getIt<CheckoutCubit>();
    _loginCubit = getIt<LoginCubit>();
    _loadSlots();
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  void _loadSlots() {
    final serviceId = widget.serviceId;
    final date = _selectedDate;
    if (serviceId == null || date == null) return;
    _slotsCubit.load(serviceId: serviceId, date: _formatDate(date));
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
    });
    _loadSlots();
  }

  @override
  void dispose() {
    _slotsCubit.close();
    _checkUserCubit.close();
    _checkoutCubit.close();
    _loginCubit.close();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
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

  void _submit(BuildContext context) {
    final checkState = _checkUserCubit.state;
    if (checkState is! CheckUserLoaded) {
      AppToast.show(context, context.tr(LocaleKeys.booking_verifyPhoneFirst));
      return;
    }
    final isRegistered = checkState.result.isRegistered;

    // A recognized account must actually log in first — that's what gets
    // the auth token the checkout call is identified by (name/phone/email/
    // password are sent as null for it).
    if (isRegistered && _loginCubit.state is! LoginSuccess) {
      AppToast.show(context, context.tr(LocaleKeys.booking_loginFirst));
      return;
    }

    final serviceId = widget.serviceId;
    final date = _selectedDate;
    final time = _selectedTime;
    if (serviceId == null || date == null || time == null) {
      AppToast.show(context, context.tr(LocaleKeys.booking_selectDateTime));
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _checkoutCubit.submit(
      serviceId: serviceId,
      bookingType: widget.bookingType ?? 'online',
      consultationType: widget.consultationType ?? 'video',
      paymentMethod: widget.paymentMethod ?? 'zaincash',
      date: _formatDate(date),
      startTime: time.apiStartTime,
      title: widget.title ?? '',
      notes: widget.notes,
      name: isRegistered ? null : _nameController.text.trim(),
      phone: isRegistered ? null : _checkedPhone,
      email: isRegistered ? null : _emailController.text.trim(),
      password: isRegistered ? null : _passwordController.text,
    );
  }

  void _onLoginStateChanged(BuildContext context, LoginState state) {
    // The inline error text in CreateAccountSection already surfaces
    // LoginError — this listener only needs to react to success.
    if (state is LoginSuccess) {
      AuthState.instance.login();
    }
  }

  void _onCheckoutStateChanged(BuildContext context, CheckoutState state) {
    switch (state) {
      case CheckoutLoaded(:final result) when result.success:
        context.push(
          AppRoutes.payment,
          extra: <String, dynamic>{
            'bookingReference': result.bookingReference ?? '',
            'serviceTitle': widget.title ?? context.tr(LocaleKeys.booking_defaultTitle),
            'date': _selectedDate != null ? _formatDate(_selectedDate!) : '',
            'time': _selectedTime?.displayStart ?? '',
            'paymentMethod': result.paymentMethod ?? widget.paymentMethod ?? 'zaincash',
            'amount': result.amount ?? 0,
            'currencySymbol': result.currencySymbol ?? context.tr(LocaleKeys.booking_currency),
            'qrCode': result.qrCode,
            'paymentInstructions': result.paymentInstructions,
            'whatsappUrl': result.whatsappUrl,
          },
        );
      case CheckoutLoaded(:final result):
        AppToast.show(context, result.message ?? context.tr(LocaleKeys.booking_bookingFailed));
      case CheckoutError(:final failure):
        AppToast.show(context, failure.message);
      case CheckoutInitial() || CheckoutSubmitting():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CheckoutCubit, CheckoutState>(
          bloc: _checkoutCubit,
          listener: _onCheckoutStateChanged,
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  BookingAppBar(
                    title: context.tr(LocaleKeys.booking_instantSession),
                    onBack: () => context.pop(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Calendar ────────────────────────────────
                          BookingCalendarCard(
                            focusedMonth: _focusedMonth,
                            selectedDate: _selectedDate,
                            onDaySelected: _onDaySelected,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // ── Time slots ──────────────────────────────
                          BlocBuilder<SlotsCubit, SlotsState>(
                            bloc: _slotsCubit,
                            builder: (context, state) {
                              return BookingTimeSlotsSection(
                                slots: switch (state) {
                                  SlotsLoaded(:final slots) => slots,
                                  _ => const [],
                                },
                                isLoading: state is SlotsLoading,
                                errorMessage: state is SlotsError
                                    ? context.tr(LocaleKeys.booking_slotsError)
                                    : null,
                                onRetry: _loadSlots,
                                selected: _selectedTime,
                                onSelected: (t) =>
                                    setState(() => _selectedTime = t),
                              );
                            },
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // ── Create account ──────────────────────────
                          BlocBuilder<CheckUserCubit, CheckUserState>(
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
                                      () => _obscurePassword = !_obscurePassword,
                                    ),
                                    checkState: checkState,
                                    onCheckPhone: _onPhoneChecked,
                                    onChangePhone: _onChangePhone,
                                    loginPasswordController: _loginPasswordController,
                                    obscureLoginPassword: _obscureLoginPassword,
                                    onToggleLoginPassword: () => setState(
                                      () => _obscureLoginPassword = !_obscureLoginPassword,
                                    ),
                                    loginState: loginState,
                                    onLogin: _onLogin,
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ── Info card ────────────────────────────────
                          const RememberAccountCard(),

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<CheckoutCubit, CheckoutState>(
                    bloc: _checkoutCubit,
                    builder: (context, state) {
                      return _BottomBar(
                        isSubmitting: state is CheckoutSubmitting,
                        onConfirm: () => _submit(context),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onConfirm, this.isSubmitting = false});
  final VoidCallback onConfirm;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final nextLabel = context.tr(LocaleKeys.booking_next);
    final submittingLabel = context.tr(LocaleKeys.booking_submitting);
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: PrimaryButton(
          label: isSubmitting ? submittingLabel : nextLabel,
          onPressed: isSubmitting ? null : onConfirm,
        ),
      ),
    );
  }
}
