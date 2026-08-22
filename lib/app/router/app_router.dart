import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/app_entry/presentation/pages/splash_page.dart';
import '../../features/app_entry/presentation/pages/welcome_page.dart';
import '../../features/home/presentation/pages/home_item_detail_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import 'app_navigation_shell.dart';
import 'app_routes.dart';

/// The ONE centralized GoRouter of the application.
///
/// Guest-first: no route requires a session today. When the authentication
/// feature lands, a global redirect will consult the session state and the
/// [RouteAccess] policy, and support "login -> return to originally
/// requested destination" (see route_access.dart).
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Entry flow — outside the navigation shell (no bottom bar).
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (BuildContext context, GoRouterState state) =>
            const WelcomePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => AppNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomePage(),
              ),
              GoRoute(
                path: AppRoutes.homeItemDetail,
                builder: (BuildContext context, GoRouterState state) =>
                    HomeItemDetailPage(itemId: state.pathParameters['itemId']!),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (BuildContext context, GoRouterState state) =>
                    const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
