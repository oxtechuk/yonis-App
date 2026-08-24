import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/app/localization/locale_keys.g.dart';
import 'package:younis_app/app/router/app_navigation_shell.dart';
import 'package:younis_app/app/styles/app_durations.dart';
import 'package:younis_app/features/app_entry/presentation/pages/splash_page.dart';
import 'package:younis_app/features/app_entry/presentation/pages/welcome_page.dart';

import '../../support/pump_app.dart';

void main() {
  testWidgets('app starts on splash and auto-navigates to welcome', (
    tester,
  ) async {
    await pumpLocalizedApp(tester);

    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.byType(WelcomePage), findsNothing);

    // Advance fake time past the splash duration; no real waiting.
    await tester.pump(AppDurations.splash);
    await tester.pumpAndSettle();

    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('welcome renders arabic copy by default', (tester) async {
    await pumpLocalizedApp(tester);
    await tester.pump(AppDurations.splash);
    await tester.pumpAndSettle();

    expect(
      find.text('احجز استشارتك النفسية الآن'),
      findsOneWidget,
    );
    expect(find.text('من جميع أنحاء العالم'), findsOneWidget);
    expect(find.text('ابدأ الآن'), findsOneWidget);

    // RTL applied at the app root.
    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, ui.TextDirection.rtl);
  });

  testWidgets('welcome renders english copy after switching to english', (
    tester,
  ) async {
    await pumpLocalizedApp(tester);
    await tester.pump(AppDurations.splash);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(WelcomePage));
    await context.setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    expect(
      find.text('Book your psychological consultation now'),
      findsOneWidget,
    );
    expect(find.text('from anywhere in the world'), findsOneWidget);
    expect(find.text('Start Now'), findsOneWidget);
  });

  testWidgets('start now enters the main application shell as guest', (
    tester,
  ) async {
    await pumpLocalizedApp(tester);
    await tester.pump(AppDurations.splash);
    await tester.pumpAndSettle();

    await tester.tap(find.text(LocaleKeys.welcome_startNow.tr()));
    await tester.pumpAndSettle();

    // Main shell with bottom navigation — not login.
    expect(find.byType(AppNavigationShell), findsOneWidget);
    expect(find.byType(WelcomePage), findsNothing);
  });
}
