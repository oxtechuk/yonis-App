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
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_toast.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/cubit/login_cubit.dart';
import '../../../home/domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../cubit/check_user_cubit.dart';
import '../cubit/slots_cubit.dart';
import '../models/booking_models.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/booking_calendar_card.dart';
import '../widgets/booking_create_account_section.dart';
import '../widgets/booking_time_slots_section.dart';
import '../widgets/outlined_card_field.dart';
import '../widgets/session_type_selector.dart';

/// Step 1 of the booking flow: consultation details (session type, title,
/// notes) + schedule (calendar, time slots) + account check (phone lookup /
/// create account or login — skipped entirely when a stored login token
/// already identifies the user).
///
/// Payment selection and the actual checkout live on the last step
/// ([CheckoutPaymentPage] at [AppRoutes.payment]).
class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
    this.service,
    this.selectedChannelType,
    this.selectedBookingType,
  });

  /// The backend service selected in the booking sheet. Null when the page
  /// is opened without one (legacy/deep-link) — fallback pricing is used.
  final Service? service;

  /// The selected channel type for online services (e.g. 'video', 'voice', 'chat').
  final String? selectedChannelType;

  /// The clinic/online tab the user picked in the booking sheet. Takes
  /// precedence over [Service.bookingType] as the source of truth, since
  /// the backend doesn't always set that field consistently.
  final String? selectedBookingType;

  static void show(
    BuildContext context, {
    Service? service,
    String? selectedChannelType,
  }) {
    context.push(
      AppRoutes.booking,
      extra: service != null
          ? {'service': service, 'channelType': selectedChannelType}
          : null,
    );
  }

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  late final SlotsCubit _slotsCubit;
  late final CheckUserCubit _checkUserCubit;
  late final LoginCubit _loginCubit;

  String? get _bookingType =>
      widget.selectedBookingType ?? widget.service?.bookingType;

  late final List<ConsultationOption> _options =
      ConsultationOptions.fromService(
        widget.service,
        selectedChannelType: widget.selectedChannelType,
        bookingTypeOverride: widget.selectedBookingType,
      );
  int _selectedOptionIndex = 0;

  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  // Calendar state
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  TimeSlot? _selectedTime;

  // Account form controllers
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

  ConsultationOption get _selectedOption => _options[_selectedOptionIndex];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _slotsCubit = getIt<SlotsCubit>();
    _checkUserCubit = getIt<CheckUserCubit>();
    _loginCubit = getIt<LoginCubit>();
    _loadSlots();
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  void _loadSlots() {
    final serviceId = widget.service?.id;
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
    _loginCubit.close();
    _titleController.dispose();
    _detailsController.dispose();
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

  void _onLoginStateChanged(BuildContext context, LoginState state) {
    if (state is LoginSuccess) {
      AuthState.instance.login();
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // A persisted login token already identifies the user on the backend
    // (sent as `Authorization: Bearer`), so skip the phone check and the
    // password prompt entirely — name/phone/email/password go as null.
    final bool isRegistered;
    if (AuthState.instance.isLoggedIn) {
      isRegistered = true;
    } else {
      final checkState = _checkUserCubit.state;
      if (checkState is! CheckUserLoaded) {
        AppToast.show(context, context.tr(LocaleKeys.booking_verifyPhoneFirst));
        return;
      }
      isRegistered = checkState.result.isRegistered;

      // A recognized account must actually log in first — that's what gets
      // the auth token the checkout call is identified by (name/phone/email/
      // password are sent as null for it).
      if (isRegistered && _loginCubit.state is! LoginSuccess) {
        AppToast.show(context, context.tr(LocaleKeys.booking_loginFirst));
        return;
      }
    }

    final date = _selectedDate;
    final time = _selectedTime;
    if (date == null || time == null) {
      AppToast.show(context, context.tr(LocaleKeys.booking_selectDateTime));
      return;
    }

    context.push(
      AppRoutes.payment,
      extra: <String, dynamic>{
        'serviceId': widget.service?.id,
        'service': widget.service,
        'bookingType': _bookingType,
        'consultationType': _selectedOption.channel,
        'title': _titleController.text.trim(),
        'notes': _detailsController.text.trim(),
        'date': _formatDate(date),
        'startTime': time.apiStartTime,
        'timeDisplay': time.displayRange,
        'serviceTitle': widget.service?.title,
        // Account payload for the checkout call on the last step.
        'isRegistered': isRegistered,
        'name': isRegistered ? null : _nameController.text.trim(),
        'phone': isRegistered ? null : _checkedPhone,
        'email': isRegistered ? null : _emailController.text.trim(),
        'password': isRegistered ? null : _passwordController.text,
        // Price snapshot for the summary on the last step.
        'optionLabel': _selectedOption.label,
        'optionPrice': _selectedOption.price,
        'optionDuration': _selectedOption.durationMinutes,
        'optionChannel': _selectedOption.channel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
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
                    title:
                        widget.service?.title ??
                        context.tr(LocaleKeys.booking_instantSession),
                    onBack: () => context.pop(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Session type (channel selector) — online services only.
                          if (_bookingType != 'clinic') ...[
                            _SectionTitle(
                              title:
                                  context.tr(LocaleKeys.booking_durationTitle),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SessionTypeSelector(
                              options: _options,
                              selectedIndex: _selectedOptionIndex,
                              onChanged: (i) =>
                                  setState(() => _selectedOptionIndex = i),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],

                          // Consultation title
                          _SectionTitle(
                            title: context.tr(
                              LocaleKeys.booking_consultationTitle,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedCardField(
                            controller: _titleController,
                            hintText: context.tr(
                              LocaleKeys.booking_consultationTitleHint,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.tr(LocaleKeys.booking_enterTitle)
                                : null,
                          ),

                          // Request details
                          const SizedBox(height: AppSpacing.sm),
                          _SectionTitle(
                            title: context.tr(LocaleKeys.booking_detailsTitle),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedCardField(
                            controller: _detailsController,
                            hintText: context.tr(LocaleKeys.booking_detailsHint),
                            maxLines: 5,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.tr(LocaleKeys.booking_enterDetails)
                                : null,
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // ── Calendar ────────────────────────────────
                          BookingCalendarCard(
                            focusedMonth: _focusedMonth,
                            selectedDate: _selectedDate,
                            onDaySelected: _onDaySelected,
                          ),

                          const SizedBox(height: AppSpacing.lg),

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

                          const SizedBox(height: AppSpacing.md),

                          // ── Create account (hidden when a stored token
                          // already identifies the user — no phone check,
                          // no password prompt) ──────────────────────────
                          if (!AuthState.instance.isLoggedIn) ...[
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

                            const SizedBox(height: AppSpacing.sm),

                            // ── Info card ────────────────────────────────
                            const RememberAccountCard(),
                          ],

                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                  _BottomBar(option: _selectedOption, onConfirm: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: AppTextStyles.title.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.option, required this.onConfirm});
  final ConsultationOption option;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr(LocaleKeys.booking_orderTotal),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${option.displayPrice} ${context.tr(LocaleKeys.booking_currency)}',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: context.tr(LocaleKeys.booking_next),
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}
