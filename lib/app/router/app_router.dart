import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/app_entry/presentation/pages/splash_page.dart';
import '../../features/app_entry/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/booking_step2_page.dart';
import '../../features/booking/presentation/pages/payment_page.dart';
import '../../features/booking/presentation/pages/payment_success_page.dart';
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
        builder: (_, __) => const BookingPage(),
      ),
      GoRoute(
        path: AppRoutes.bookingStep2,
        builder: (_, __) => const BookingStep2Page(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentPage(
            merchantName: extra?['merchantName'] as String? ?? 'Baeynh',
            referenceNumber:
                extra?['referenceNumber'] as String? ?? '12345',
            amount: extra?['amount'] as int? ?? 1500,
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
