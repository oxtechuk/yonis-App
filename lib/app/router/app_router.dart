import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/app_entry/presentation/pages/splash_page.dart';
import '../../features/app_entry/presentation/pages/welcome_page.dart';
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
