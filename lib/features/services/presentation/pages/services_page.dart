import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../home/domain/entities/service.dart';
import '../../../home/presentation/cubit/services_cubit.dart';
import '../../../home/presentation/widgets/service_option_card.dart';

/// "Our Services" tab: online / clinic services from
/// `GET /api/services/online` and `/api/services/clinic`,
/// rendered with the same cards as the booking sheet.
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared singleton with the booking sheet (per-type cache included),
    // so opening the sheet afterwards never refetches.
    return BlocProvider<ServicesCubit>.value(
      value: getIt<ServicesCubit>(),
      child: const _ServicesView(),
    );
  }
}

class _ServicesView extends StatefulWidget {
  const _ServicesView();

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
    // Warm the other tab so switching tabs never shows a skeleton
    // when the data was already fetched this session.
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

  /// Guests go straight into booking — no login gate here. Account
  /// creation / login happens inside [BookingPage] before payment.
  /// A service with several channels passes no preselected channel —
  /// [BookingPage] lists them all.
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
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
              const SizedBox(height: AppSpacing.md),
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
                          onRetry: () =>
                              context.read<ServicesCubit>().load(
                                    _tabTypes[_tabController.index],
                                    forceRefresh: true,
                                  ),
                        ),
                      ServicesLoaded(:final services) => _ServiceList(
                          services: services
                              .where((s) => s.isActive)
                              .toList(growable: false),
                          isOnline:
                              _tabTypes[_tabController.index] == 'online',
                          onRefresh: () =>
                              context.read<ServicesCubit>().load(
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
          ),
        ),
      ),
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
          return ServiceOptionCard(
            iconType: isOnline
                ? ServiceOptionIconType.online
                : ServiceOptionIconType.clinic,
            bootstrapIcon: service.icon,
            iconUrl: service.iconUrl,
            title: service.title,
            description: service.description,
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
