import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/app_entry/presentation/pages/splash_page.dart';
import '../../features/app_entry/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/booking_step2_page.dart';
import '../../features/booking/presentation/pages/checkout_payment_page.dart';
import '../../features/booking/presentation/pages/payment_success_page.dart';
import '../../features/home/domain/entities/service.dart';
import '../../features/home/presentation/pages/home_item_detail_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/services/presentation/pages/services_page.dart';
import '../../features/sessions/presentation/pages/sessions_page.dart';
import 'app_navigation_shell.dart';
import 'app_routes.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, state) => LoginPage(
          onGuestBooking: state.extra is VoidCallback
              ? state.extra as VoidCallback
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.booking,
        builder: (_, state) {
          final extra = state.extra;
          Service? service;
          String? channelType;
          String? bookingType;
          if (extra is Map) {
            service = extra['service'] as Service?;
            channelType = extra['channelType'] as String?;
            bookingType = extra['bookingType'] as String?;
          } else if (extra is Service) {
            service = extra;
          }
          return BookingPage(
            service: service,
            selectedChannelType: channelType,
            selectedBookingType: bookingType,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingStep2,
        builder: (_, state) {
          final extra = state.extra;
          return BookingStep2Page(
            serviceId: extra is Map ? extra['serviceId'] as int? : null,
            bookingType: extra is Map ? extra['bookingType'] as String? : null,
            consultationType:
                extra is Map ? extra['consultationType'] as String? : null,
            paymentMethod:
                extra is Map ? extra['paymentMethod'] as String? : null,
            title: extra is Map ? extra['title'] as String? : null,
            notes: extra is Map ? extra['notes'] as String? : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CheckoutPaymentPage(
            bookingReference: extra?['bookingReference'] as String? ?? '',
            serviceTitle: extra?['serviceTitle'] as String? ?? '',
            date: extra?['date'] as String? ?? '',
            time: extra?['time'] as String? ?? '',
            paymentMethod: extra?['paymentMethod'] as String? ?? 'zaincash',
            amount: extra?['amount'] as num? ?? 0,
            currencySymbol: extra?['currencySymbol'] as String? ?? 'د.ع',
            qrCode: extra?['qrCode'] as String?,
            paymentInstructions: extra?['paymentInstructions'] as String?,
            whatsappUrl: extra?['whatsappUrl'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentSuccess,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentSuccessPage(
            referenceNumber:
                extra?['referenceNumber'] as String? ?? 'REF-8492',
            serviceName:
                extra?['serviceName'] as String? ?? 'جلسة استشارة نفسية',
            appointmentDate:
                extra?['appointmentDate'] as String? ?? '١٥ أكتوبر ٢٠٢٣',
            appointmentTime:
                extra?['appointmentTime'] as String? ?? '٤:٠٠ مساء - ٥:٠٠ مساء',
            consultantName:
                extra?['consultantName'] as String? ?? 'د. أحمد محمود',
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            AppNavigationShell(navigationShell: navigationShell),
        branches: [
          // 0 — الرئيسية
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const HomePage(),
              ),
              GoRoute(
                path: AppRoutes.homeItemDetail,
                builder: (_, state) =>
                    HomeItemDetailPage(itemId: state.pathParameters['itemId']!),
              ),
            ],
          ),
          // 1 — خدمتنا
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.services,
                builder: (_, __) => const ServicesPage(),
              ),
            ],
          ),
          // 2 — جلساتي
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sessions,
                builder: (_, __) => const SessionsPage(),
              ),
            ],
          ),
          // 3 — حسابي
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
