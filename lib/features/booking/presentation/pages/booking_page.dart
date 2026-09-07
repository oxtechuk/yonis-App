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
import '../../../home/domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../cubit/slots_cubit.dart';
import '../models/booking_models.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/booking_calendar_card.dart';
import '../widgets/booking_time_slots_section.dart';
import '../widgets/outlined_card_field.dart';
import '../widgets/session_type_selector.dart';

/// Step 1 of the booking flow: consultation details (session type, title,
/// notes) + schedule (calendar, time slots).
///
/// Account check (phone lookup / create account or login) and payment live
/// on the next step ([CheckoutPaymentPage] at [AppRoutes.payment]).
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

  ConsultationOption get _selectedOption => _options[_selectedOptionIndex];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _slotsCubit = getIt<SlotsCubit>();
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
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final date = _selectedDate;
    final time = _selectedTime;
    if (date == null || time == null) {
      AppToast.show(context, context.tr(LocaleKeys.booking_selectDateTime));
      return;
    }

    // Account check + creation happen on the next step (CheckoutPaymentPage)
    // — this step only carries details, schedule and the price snapshot.
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
        'timeDisplay': time.start,
        'serviceTitle': widget.service?.title,
        // Price snapshot for the summary on the next step.
        'optionLabel': _selectedOption.label,
        'optionPrice': _selectedOption.price,
        'optionDuration': _selectedOption.durationMinutes,
        'optionChannel': _selectedOption.channel,
        'currencySymbol': _selectedOption.currencySymbol ??
            widget.service?.currencySymbol ??
            context.tr(LocaleKeys.booking_currency),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
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
                            title: context.tr(LocaleKeys.booking_durationTitle),
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
                '${option.displayPrice} ${option.currencySymbol ?? context.tr(LocaleKeys.booking_currency)}',
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
