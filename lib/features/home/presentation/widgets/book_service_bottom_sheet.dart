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
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../auth/domain/auth_state.dart';
import '../../domain/entities/service.dart';
import '../cubit/services_cubit.dart';
import 'service_option_card.dart';

enum ServiceType { clinic, online }

extension ServiceTypeExt on ServiceType {
  String localizedName(BuildContext context) => switch (this) {
        ServiceType.clinic => context.tr(LocaleKeys.home_bookService_clinicTab),
        ServiceType.online => context.tr(LocaleKeys.home_bookService_onlineTab),
      };
}

/// Bottom sheet shown when the user taps "Book Your Consultation".
/// First lets the user choose between clinic and online, then lists
/// the available services for that type.
class BookServiceBottomSheet extends StatefulWidget {
  const BookServiceBottomSheet({super.key, required this.router});

  final GoRouter router;

  static void show(BuildContext context) {
    final router = GoRouter.of(context);
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.31),
      builder: (_) => BlocProvider<ServicesCubit>.value(
        value: getIt<ServicesCubit>()..load('clinic'),
        child: BookServiceBottomSheet(router: router),
      ),
    );
  }

  static const double headerSlotWidth = 40;

  @override
  State<BookServiceBottomSheet> createState() => _BookServiceBottomSheetState();
}

class _BookServiceBottomSheetState extends State<BookServiceBottomSheet> {
  ServiceType _selectedType = ServiceType.clinic;
  Service? _channelSelectionService;

  void _selectType(ServiceType type) {
    setState(() {
      _selectedType = type;
      _channelSelectionService = null;
    });
    context.read<ServicesCubit>().load(type == ServiceType.clinic ? 'clinic' : 'online');
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header row: close arrow + centered title
            Row(
              children: [
                SizedBox(
                  width: BookServiceBottomSheet.headerSlotWidth,
                  child: IconButton(
                    onPressed: () {
                      if (_channelSelectionService != null) {
                        setState(() => _channelSelectionService = null);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(
                      isArabic ? Icons.arrow_back : Icons.arrow_forward,
                      color: AppColors.textPrimary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Expanded(
                  child: Text(
                    context.tr(
                      _channelSelectionService != null
                          ? LocaleKeys.home_bookService_onlineTitle
                          : LocaleKeys.home_bookService_sheetTitle,
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: BookServiceBottomSheet.headerSlotWidth),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Type selector tabs (hidden when selecting channel)
            if (_channelSelectionService == null) ...[
              _buildTypeSelector(context),
              const SizedBox(height: AppSpacing.md),
            ],

            // Service list or channel selector
            Flexible(
              child: _channelSelectionService != null
                  ? _buildChannelSelector(_channelSelectionService!)
                  : BlocBuilder<ServicesCubit, ServicesState>(
                      builder: (context, state) {
                        return switch (state) {
                          ServicesInitial() || ServicesLoading() =>
                            const SizedBox(
                              height: 220,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ServicesError() => _ErrorRetryBody(
                              onRetry: () {
                                context.read<ServicesCubit>().load(
                                      _selectedType == ServiceType.clinic
                                          ? 'clinic'
                                          : 'online',
                                    );
                              },
                            ),
                          ServicesLoaded(:final services) =>
                            _buildServiceList(context, services),
                        };
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeTab(
            label: context.tr(LocaleKeys.home_bookService_clinicTab),
            isSelected: _selectedType == ServiceType.clinic,
            onTap: () => _selectType(ServiceType.clinic),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TypeTab(
            label: context.tr(LocaleKeys.home_bookService_onlineTab),
            isSelected: _selectedType == ServiceType.online,
            onTap: () => _selectType(ServiceType.online),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceList(BuildContext context, List<Service> services) {
    final bookable = services
        .where((service) => service.isActive)
        .toList(growable: false);
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: bookable.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final service = bookable[index];
        final isOnline = service.bookingType == 'online' ||
            (service.channels != null && service.channels!.isNotEmpty) ||
            service.serviceType == 'online';
        return ServiceOptionCard(
          iconType: isOnline
              ? ServiceOptionIconType.online
              : ServiceOptionIconType.clinic,
          title: service.title,
          description: service.description,
          price: context.tr(
            LocaleKeys.home_bookService_priceFrom,
            namedArgs: {'price': service.displayPrice},
          ),
          onTap: () => _onServiceTap(context, service),
        );
      },
);
  }

  Widget _buildChannelSelector(Service service) {
    final channels = (service.channels ?? [])
        .where((c) => c.isEnabled)
        .toList(growable: false);
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: channels.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return _ChannelOptionCard(
          channel: channel,
          onTap: () => _onChannelTap(service, channel.channel),
        );
      },
    );
  }

  void _onServiceTap(BuildContext context, Service service) {
    final enabledChannels = (service.channels ?? [])
        .where((c) => c.isEnabled)
        .toList(growable: false);
    // Service with multiple channels -> show channel selector
    if (enabledChannels.length > 1) {
      setState(() => _channelSelectionService = service);
      return;
    }
    // Single channel -> auto-select it
    String? channelType;
    if (enabledChannels.length == 1) {
      channelType = enabledChannels.first.channel;
    }
    _navigateToBooking(service, channelType);
  }

  void _onChannelTap(Service service, String channelType) {
    _navigateToBooking(service, channelType);
  }

  void _navigateToBooking(Service service, String? channelType) {
    Navigator.of(context).pop();
    final extra = {
      'service': service,
      'channelType': channelType,
      // The tab the user picked is the source of truth for clinic vs.
      // online — not service.bookingType, which the backend doesn't
      // always set consistently.
      'bookingType': _selectedType == ServiceType.clinic ? 'clinic' : 'online',
    };
    if (AuthState.instance.isLoggedIn) {
      widget.router.push(AppRoutes.booking, extra: extra);
    } else {
      widget.router.push(
        AppRoutes.login,
        extra: () => widget.router.push(AppRoutes.booking, extra: extra),
      );
    }
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: AppRadius.allXl,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChannelOptionCard extends StatelessWidget {
  const _ChannelOptionCard({required this.channel, required this.onTap});

  final ServiceChannel channel;
  final VoidCallback onTap;

  String _channelIcon(String channel) {
    switch (channel) {
      case 'video':
        return '🎥';
      case 'voice':
        return '🎙️';
      case 'chat':
        return '💬';
      default:
        return '📞';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceText = channel.price == channel.price.truncateToDouble()
        ? channel.price.truncate().toString()
        : channel.price.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Row(
          textDirection: ui.TextDirection.rtl,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Center(
                child: Text(_channelIcon(channel.channel), style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    channel.name,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (channel.duration != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      context.tr(
                        LocaleKeys.home_bookService_minutesShort,
                        namedArgs: {'count': '${channel.duration}'},
                      ),
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$priceText ${channel.currencySymbol ?? context.tr(LocaleKeys.booking_currency)}',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.tr(LocaleKeys.home_bookService_selectButton),
                    style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetryBody extends StatelessWidget {
  const _ErrorRetryBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.tr(LocaleKeys.errors_general),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: AppSizes.buttonHeight,
          child: FilledButton.icon(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(
              context.tr(LocaleKeys.common_retry),
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }
}
