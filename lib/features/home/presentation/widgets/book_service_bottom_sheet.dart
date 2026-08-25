import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../auth/domain/auth_state.dart';
import '../../domain/entities/service.dart';
import '../cubit/services_cubit.dart';
import 'service_option_card.dart';

/// Bottom sheet shown when the user taps "Book Your Consultation".
/// Lists the bookable services fetched from the backend, each with a
/// title, description, "starting from" price, and a CTA button.
class BookServiceBottomSheet extends StatelessWidget {
  const BookServiceBottomSheet({super.key, required this.router});

  final GoRouter router;

  static void show(BuildContext context) {
    // Capture the router from the calling context (which has GoRouter as ancestor)
    // before showing the sheet.
    final router = GoRouter.of(context);
    showModalBottomSheet<void>(
      context: context,
      // Show on the branch navigator so the sheet stays above the
      // navigation bar instead of covering it.
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.31),
      builder: (_) => BlocProvider<ServicesCubit>.value(
        // Shared singleton: the home page already prefetched the services,
        // and load() no-ops while valid data is cached.
        value: getIt<ServicesCubit>()..load(),
        child: BookServiceBottomSheet(router: router),
      ),
    );
  }

  // Both sides of the title get an equal-width slot so it stays
  // optically centered regardless of the button's internal metrics.
  static const double _headerSlotWidth = 40;

  /// Matches online-style service titles (video/chat/voice consultations).
  static final RegExp _onlineTitlePattern = RegExp(
    r'اون ?لاين|أونلاين|فيديو|مرئية|شات|مكالمة|online|video|chat',
    caseSensitive: false,
  );

  /// Called when any service option is tapped.
  /// Closes this sheet then either:
  ///  - opens the booking flow directly (logged-in user), or
  ///  - shows the login page with a guest-booking option.
  void _onServiceTap(BuildContext context) {
    Navigator.of(context).pop();
    if (AuthState.instance.isLoggedIn) {
      router.push(AppRoutes.booking);
    } else {
      router.push(AppRoutes.login, extra: () => router.push(AppRoutes.booking));
    }
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
        return ServiceOptionCard(
          iconType: _onlineTitlePattern.hasMatch(service.title)
              ? ServiceOptionIconType.online
              : ServiceOptionIconType.clinic,
          title: service.title,
          description: service.description,
          price: context.tr(
            LocaleKeys.home_bookService_priceFrom,
            namedArgs: {'price': service.displayPrice},
          ),
          onTap: () => _onServiceTap(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // In Arabic the back direction points left; in English it points right.
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
                  width: _headerSlotWidth,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                    context.tr(LocaleKeys.home_bookService_sheetTitle),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: _headerSlotWidth),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Flexible(
              child: BlocBuilder<ServicesCubit, ServicesState>(
                builder: (context, state) {
                  return switch (state) {
                    ServicesInitial() || ServicesLoading() =>
                      // Fixed height so the sheet visibly slides up with a
                      // skeleton instead of a thin strip while fetching.
                      const SizedBox(
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ServicesError() => _ErrorRetryBody(
                      onRetry: () => context.read<ServicesCubit>().load(
                        forceRefresh: true,
                      ),
                    ),
                    ServicesLoaded(:final services) => _buildServiceList(
                      context,
                      services,
                    ),
                  };
                },
              ),
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
