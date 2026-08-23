import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/widgets/primary_button.dart';
import '../widgets/booking_app_bar.dart';
import '../widgets/booking_calendar_card.dart';
import '../widgets/booking_create_account_section.dart';
import '../widgets/booking_time_slots_section.dart';

class BookingStep2Page extends StatefulWidget {
  const BookingStep2Page({super.key});

  static void show(BuildContext context) {
    context.push(AppRoutes.bookingStep2);
  }

  @override
  State<BookingStep2Page> createState() => _BookingStep2PageState();
}

class _BookingStep2PageState extends State<BookingStep2Page> {
  final _formKey = GlobalKey<FormState>();

  // Calendar state
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  // Time slots
  static const _timeSlots = [
    '09:00 ص', '10:00 ص', '11:30 ص',
    '01:00 م', '02:30 م', '04:00 م',
  ];
  String? _selectedTime;

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push(
        AppRoutes.payment,
        extra: <String, dynamic>{
          'merchantName': 'Baeynh',
          'referenceNumber': '12345',
          'amount': 1500,
        },
      );
    }
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
                BookingAppBar(title: 'جلسة فورية', onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.md),

                        // ── Calendar ──────────────────────────────────
                        BookingCalendarCard(
                          focusedMonth: _focusedMonth,
                          selectedDate: _selectedDate,
                          onDaySelected: (d) =>
                              setState(() => _selectedDate = d),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Time slots ────────────────────────────────
                        BookingTimeSlotsSection(
                          slots: _timeSlots,
                          selected: _selectedTime,
                          onSelected: (t) =>
                              setState(() => _selectedTime = t),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Create account ────────────────────────────
                        CreateAccountSection(
                          nameController: _nameController,
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // ── Info card ─────────────────────────────────
                        const RememberAccountCard(),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                _BottomBar(onConfirm: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onConfirm});
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
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: PrimaryButton(label: 'التالي', onPressed: onConfirm),
    );
  }
}
