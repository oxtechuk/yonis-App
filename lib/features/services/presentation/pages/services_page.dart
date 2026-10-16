import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_direction.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/service.dart';
import '../../../home/presentation/cubit/doctors_cubit.dart';
import '../../../home/presentation/cubit/services_cubit.dart';
import '../../../home/presentation/widgets/service_option_card.dart';
import 'doctor_selection_page.dart';

/// "Our Services" tab:
/// - First requires selecting a doctor from `GET /api/doctors` unless
///   `is_single_doctor == true`, `auto_selected_doctor != null`, only 1 doctor
///   exists, or a doctor was already selected.
/// - Once a doctor is resolved, displays online / clinic services from
///   `GET /api/services/online` and `/api/services/clinic`.
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DoctorsCubit>.value(
          value: getIt<DoctorsCubit>()..load(),
        ),
        BlocProvider<ServicesCubit>.value(
          value: getIt<ServicesCubit>(),
        ),
      ],
      child: Directionality(
        textDirection: context.localeTextDirection,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: BlocBuilder<DoctorsCubit, DoctorsState>(
              builder: (context, doctorsState) {
                if (doctorsState is DoctorsInitial ||
                    doctorsState is DoctorsLoading) {
                  return const ServiceListSkeleton();
                }
                if (doctorsState is DoctorsLoaded &&
                    !doctorsState.hasResolvedDoctor) {
                  return DoctorSelectionBody(
                    showHeader: true,
                    onSelectDoctor: (doctor) {
                      context.read<DoctorsCubit>().selectDoctor(doctor);
                    },
                  );
                }
                final selectedDoctor = doctorsState is DoctorsLoaded
                    ? doctorsState.activeDoctor
                    : null;
                final canChangeDoctor = doctorsState is DoctorsLoaded &&
                    !doctorsState.result.shouldSkipSelection;
                return _ServicesView(
                  selectedDoctor: selectedDoctor,
                  canChangeDoctor: canChangeDoctor,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ServicesView extends StatefulWidget {
  const _ServicesView({
    this.selectedDoctor,
    this.canChangeDoctor = false,
  });

  final Doctor? selectedDoctor;
  final bool canChangeDoctor;

  @override
  State<_ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<_ServicesView>
    with SingleTickerProviderStateMixin {
  static const _tabTypes = ['online', 'clinic'];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    final servicesCubit = context.read<ServicesCubit>();
    servicesCubit.load(_tabTypes[_tabController.index]);
    servicesCubit.preload(
      _tabTypes[(_tabController.index + 1) % _tabTypes.length],
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<ServicesCubit>().load(_tabTypes[_tabController.index]);
  }

  void _book(Service service) {
    final bookingType = _tabTypes[_tabController.index];
    final enabled = (service.channels ?? [])
        .where((c) => c.isEnabled)
        .toList(growable: false);
    final extra = <String, dynamic>{
      'service': service,
      'channelType': enabled.length == 1 ? enabled.first.channel : null,
      'bookingType': bookingType,
    };
    GoRouter.of(context).push(AppRoutes.booking, extra: extra);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final doctor = widget.selectedDoctor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Text(
            context.tr(LocaleKeys.services_title),
            style: AppTextStyles.display.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (doctor != null && widget.canChangeDoctor)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.allMd,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      doctor.nameFor(isArabic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<DoctorsCubit>().clearSelectedDoctor();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      context.tr(LocaleKeys.services_changeDoctor),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTextStyles.body,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabs: [
            Tab(
              text: context.tr(
                LocaleKeys.home_bookService_onlineTab,
              ),
            ),
            Tab(
              text: context.tr(
                LocaleKeys.home_bookService_clinicTab,
              ),
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<ServicesCubit, ServicesState>(
            builder: (context, state) {
              return switch (state) {
                ServicesInitial() || ServicesLoading() =>
                  const ServiceListSkeleton(),
                ServicesError(:final failure) => _ServicesErrorView(
                    message: failure.message,
                    onRetry: () => context.read<ServicesCubit>().load(
                          _tabTypes[_tabController.index],
                          forceRefresh: true,
                        ),
                  ),
                ServicesLoaded(:final services) => _ServiceList(
                    services: services
                        .where((s) => s.isActive)
                        .toList(growable: false),
                    isOnline: _tabTypes[_tabController.index] == 'online',
                    onRefresh: () => context.read<ServicesCubit>().load(
                          _tabTypes[_tabController.index],
                          forceRefresh: true,
                        ),
                    onBook: _book,
                  ),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList({
    required this.services,
    required this.isOnline,
    required this.onRefresh,
    required this.onBook,
  });

  final List<Service> services;
  final bool isOnline;
  final Future<void> Function() onRefresh;
  final ValueChanged<Service> onBook;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            context.tr(LocaleKeys.services_empty),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final service = services[index];
          final isArabic = context.locale.languageCode == 'ar';
          return ServiceOptionCard(
            iconType: isOnline
                ? ServiceOptionIconType.online
                : ServiceOptionIconType.clinic,
            bootstrapIcon: service.icon,
            iconUrl: service.iconUrl,
            title: service.titleFor(isArabic),
            description: service.descriptionFor(isArabic),
            price: context.tr(
              LocaleKeys.home_bookService_priceFrom,
              namedArgs: {
                'price': service.displayPrice,
                'currency': service.currencySymbol ??
                    context.tr(LocaleKeys.booking_currency),
              },
            ),
            onTap: () => onBook(service),
          );
        },
      ),
    );
  }
}

class _ServicesErrorView extends StatelessWidget {
  const _ServicesErrorView({required this.message, required this.onRetry});

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
