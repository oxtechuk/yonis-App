import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:younis_app/app/app.dart';
import 'package:younis_app/app/config/app_config.dart';
import 'package:younis_app/app/config/app_environment.dart';
import 'package:younis_app/app/di/dependency_injection.dart';
import 'package:younis_app/app/localization/app_localization.dart';
import 'package:younis_app/app/localization/locale_keys.g.dart';
import 'package:younis_app/features/app_entry/data/models/splash_config_dto.dart';
import 'package:younis_app/features/app_entry/data/sources/splash_remote_data_source.dart';

/// Loads translations straight from disk in a single synchronous read.
class _TestFileAssetLoader extends AssetLoader {
  const _TestFileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = File('assets/locales/${locale.languageCode}.json');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

class FakeSplashRemoteDataSource implements SplashRemoteDataSource {
  const FakeSplashRemoteDataSource([this.dto = defaultDto]);

  static const SplashConfigDto defaultDto = SplashConfigDto(
    isEnabled: true,
    durationSeconds: 3,
    title: 'مرحباً بك في تطبيق عيادة د. يونس المرشدي',
    subtitle: 'احجز استشارتك الطبية والنفسية بكل سهولة وسرية تامة',
    imageUrl:
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1000&q=80',
  );

  final SplashConfigDto dto;

  @override
  Future<SplashConfigDto> getSplashConfig() async => dto;
}

/// Pumps the real application widget tree (EasyLocalization -> YounisApp)
/// exactly as bootstrap composes it, without running bootstrap itself.
Future<void> pumpLocalizedApp(
  WidgetTester tester, {
  SplashRemoteDataSource? splashRemoteDataSource,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await EasyLocalization.ensureInitialized();

  getIt.allowReassignment = true;
  if (!getIt.isRegistered<AppConfig>()) {
    configureDependencies(
      environment: AppEnvironment.development,
      sharedPreferences: await SharedPreferences.getInstance(),
    );
  }

  getIt.registerLazySingleton<SplashRemoteDataSource>(
    () => splashRemoteDataSource ?? const FakeSplashRemoteDataSource(),
  );

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

/// Walks the real entry flow (dynamic splash -> Start Now) so tests
/// land on the main application shell exactly like a user would.
Future<void> enterMainApp(WidgetTester tester) async {
  final startButton = find.text(LocaleKeys.welcome_startNow.tr());
  if (startButton.evaluate().isNotEmpty) {
    await tester.tap(startButton);
    await tester.pumpAndSettle();
  }
}
