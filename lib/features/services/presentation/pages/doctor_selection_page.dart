import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_direction.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../booking/presentation/widgets/booking_app_bar.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/presentation/cubit/doctors_cubit.dart';
import '../widgets/doctor_card.dart';

/// Standalone page pushed before opening the booking service selector when
/// multiple doctors exist and none is auto-selected or previously chosen.
class DoctorSelectionPage extends StatefulWidget {
  const DoctorSelectionPage({
    super.key,
    this.onDoctorSelected,
  });

  final VoidCallback? onDoctorSelected;

  @override
  State<DoctorSelectionPage> createState() => _DoctorSelectionPageState();
}

class _DoctorSelectionPageState extends State<DoctorSelectionPage> {
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    final cubit = getIt<DoctorsCubit>();
    cubit.load();
    final state = cubit.state;
    if (state is DoctorsLoaded && state.hasResolvedDoctor) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishSelection());
    }
  }

  void _finishSelection() {
    if (_completed || !mounted) return;
    _completed = true;
    final callback = widget.onDoctorSelected;
    if (context.canPop()) {
      context.pop();
    }
    callback?.call();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsCubit = getIt<DoctorsCubit>();
    return BlocProvider<DoctorsCubit>.value(
      value: doctorsCubit,
      child: BlocListener<DoctorsCubit, DoctorsState>(
        listener: (context, state) {
          if (state is DoctorsLoaded && state.hasResolvedDoctor) {
            _finishSelection();
          }
        },
        child: Directionality(
          textDirection: context.localeTextDirection,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookingAppBar(
                    title: context.tr(LocaleKeys.services_selectDoctorTitle),
                    onBack: () => context.pop(),
                  ),
                  Expanded(
                    child: DoctorSelectionBody(
                      onSelectDoctor: doctorsCubit.selectDoctor,
                    ),
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

/// Reusable doctor selection list used both in [DoctorSelectionPage] and
/// embedded inside [ServicesPage] before a doctor is selected.
class DoctorSelectionBody extends StatelessWidget {
  const DoctorSelectionBody({
    super.key,
    required this.onSelectDoctor,
    this.showHeader = false,
  });

  final ValueChanged<Doctor> onSelectDoctor;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(LocaleKeys.services_selectDoctorTitle),
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.tr(LocaleKeys.services_selectDoctorSubtitle),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Text(
              context.tr(LocaleKeys.services_selectDoctorSubtitle),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: BlocBuilder<DoctorsCubit, DoctorsState>(
            builder: (context, state) {
              return switch (state) {
                DoctorsInitial() || DoctorsLoading() =>
                  const ServiceListSkeleton(),
                DoctorsError(:final failure) => _DoctorsErrorView(
                    message: failure.message,
                    onRetry: () => context
                        .read<DoctorsCubit>()
                        .load(forceRefresh: true),
                  ),
                DoctorsLoaded(:final result) => _DoctorsList(
                    doctors: result.doctors,
                    onRefresh: () => context
                        .read<DoctorsCubit>()
                        .load(forceRefresh: true),
                    onSelectDoctor: onSelectDoctor,
                  ),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _DoctorsList extends StatelessWidget {
  const _DoctorsList({
    required this.doctors,
    required this.onRefresh,
    required this.onSelectDoctor,
  });

  final List<Doctor> doctors;
  final Future<void> Function() onRefresh;
  final ValueChanged<Doctor> onSelectDoctor;

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            context.tr(LocaleKeys.services_noDoctors),
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: doctors.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return DoctorCard(
            doctor: doctor,
            onSelect: () => onSelectDoctor(doctor),
          );
        },
      ),
    );
  }
}

class _DoctorsErrorView extends StatelessWidget {
  const _DoctorsErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: context.tr(LocaleKeys.common_retry),
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
