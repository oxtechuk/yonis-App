import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:younis_app/app/app.dart';
import 'package:younis_app/app/localization/app_localization.dart';
import 'package:younis_app/app/localization/locale_keys.g.dart';
import 'package:younis_app/app/styles/app_durations.dart';

/// Loads translations straight from disk in a single synchronous read.
///
/// The default [RootBundleAssetLoader] goes through real platform-channel IO,
/// which fake-async widget tests cannot await; that makes translation loads
/// race against pumpAndSettle. Reading the file synchronously resolves every
/// load (initial and on setLocale) as a microtask instead.
class _TestFileAssetLoader extends AssetLoader {
  const _TestFileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = File('assets/locales/${locale.languageCode}.json');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

/// Pumps the real application widget tree (EasyLocalization -> YounisApp)
/// exactly as bootstrap composes it, without running bootstrap itself.
Future<void> pumpLocalizedApp(WidgetTester tester) async {
  // easy_localization keeps device/saved locale in static late fields that
  // are only initialized by ensureInitialized() (normally called in main),
  // so tests must call it explicitly before pumping the app.
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await EasyLocalization.ensureInitialized();
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: AppLocalization.supportedLocales,
      path: AppLocalization.translationsPath,
      fallbackLocale: AppLocalization.fallbackLocale,
      startLocale: AppLocalization.defaultLocale,
      assetLoader: const _TestFileAssetLoader(),
      child: YounisApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Walks the real entry flow (splash timer -> welcome -> Start Now) so tests
/// land on the main application shell exactly like a user would.
Future<void> enterMainApp(WidgetTester tester) async {
  // Fires the splash Timer in fake time; no real waiting.
  await tester.pump(AppDurations.splash);
  await tester.pumpAndSettle();

  await tester.tap(find.text(LocaleKeys.welcome_startNow.tr()));
  await tester.pumpAndSettle();
}
