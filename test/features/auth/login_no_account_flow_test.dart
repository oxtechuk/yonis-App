import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:younis_app/app/config/app_config.dart';
import 'package:younis_app/app/config/app_environment.dart';
import 'package:younis_app/app/di/dependency_injection.dart';
import 'package:younis_app/app/localization/locale_keys.g.dart';
import 'package:younis_app/app/router/app_routes.dart';
import 'package:younis_app/features/auth/presentation/pages/login_page.dart';
import 'package:younis_app/features/booking/presentation/pages/booking_page.dart';

/// Reads translations straight from disk so the load resolves as a
/// microtask instead of racing pumpAndSettle (same approach as
/// test/support/pump_app.dart).
class _TestFileAssetLoader extends AssetLoader {
  const _TestFileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = File('assets/locales/${locale.languageCode}.json');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

void main() {
  testWidgets(
    'tapping the no-account card on login navigates to the booking page',
    (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await EasyLocalization.ensureInitialized();
      if (!getIt.isRegistered<AppConfig>()) {
        configureDependencies(
          environment: AppEnvironment.development,
          sharedPreferences: await SharedPreferences.getInstance(),
        );
      }

      // Simulates the extra a real caller (the booking sheet) passes when
      // it pushes /login for a signed-out guest.
      late final GoRouter router;
      router = GoRouter(
        initialLocation: AppRoutes.login,
        initialExtra: () => router.push(AppRoutes.booking),
        routes: [
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
            builder: (_, state) => const BookingPage(),
          ),
        ],
      );

      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('ar'), Locale('en')],
          path: 'assets/locales',
          startLocale: const Locale('ar'),
          fallbackLocale: const Locale('ar'),
          assetLoader: const _TestFileAssetLoader(),
          child: Builder(
            builder: (context) => MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(BookingPage), findsNothing);

      await tester.tap(find.text(LocaleKeys.auth_startSessions.tr()));
      await tester.pumpAndSettle();

      expect(find.byType(BookingPage), findsOneWidget);
    },
  );
}
