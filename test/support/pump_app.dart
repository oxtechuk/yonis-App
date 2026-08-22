import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:younis_app/app/app.dart';
import 'package:younis_app/app/localization/app_localization.dart';

/// Pumps the real application widget tree (EasyLocalization -> YounisApp)
/// exactly as bootstrap composes it, without running bootstrap itself.
Future<void> pumpLocalizedApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: AppLocalization.supportedLocales,
      path: AppLocalization.translationsPath,
      fallbackLocale: AppLocalization.fallbackLocale,
      child: YounisApp(),
    ),
  );
  await tester.pumpAndSettle();
}
