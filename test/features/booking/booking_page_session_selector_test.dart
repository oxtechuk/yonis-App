import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/app/localization/app_localization.dart';
import 'package:younis_app/features/booking/presentation/pages/booking_page.dart';
import 'package:younis_app/features/booking/presentation/widgets/session_type_selector.dart';
import 'package:younis_app/features/home/domain/entities/service.dart';

class _TestFileAssetLoader extends AssetLoader {
  const _TestFileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = File('assets/locales/${locale.languageCode}.json');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

Future<void> _pump(
  WidgetTester tester,
  Service service, {
  String? selectedBookingType,
}) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: AppLocalization.supportedLocales,
      path: AppLocalization.translationsPath,
      fallbackLocale: AppLocalization.fallbackLocale,
      startLocale: AppLocalization.defaultLocale,
      assetLoader: const _TestFileAssetLoader(),
      child: Builder(
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: BookingPage(
              service: service,
              selectedBookingType: selectedBookingType,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('hides the session type selector for clinic services', (
    tester,
  ) async {
    const service = Service(
      id: 5,
      title: 'جلسة عيادة',
      description: 'وصف',
      type: 'both',
      price: 50,
      bookingType: 'clinic',
      clinicPrice: 50,
    );

    await _pump(tester, service);

    expect(find.byType(SessionTypeSelector), findsNothing);
  });

  testWidgets('shows the session type selector for online services', (
    tester,
  ) async {
    const service = Service(
      id: 5,
      title: 'جلسة أونلاين',
      description: 'وصف',
      type: 'both',
      price: 50,
      bookingType: 'online',
      chatPrice: 40,
      voicePrice: 45,
      videoPrice: 50,
    );

    await _pump(tester, service);

    expect(find.byType(SessionTypeSelector), findsOneWidget);
  });

  testWidgets(
    'the clicked clinic tab hides the selector even if service.bookingType '
    'disagrees',
    (tester) async {
      // Same shape the "both" services in the sample payloads have: the
      // backend's own bookingType says 'online', but the user tapped the
      // clinic tab in the booking sheet.
      const service = Service(
        id: 5,
        title: 'جلسة',
        description: 'وصف',
        type: 'both',
        price: 50,
        bookingType: 'online',
        chatPrice: 40,
        voicePrice: 45,
        videoPrice: 50,
      );

      await _pump(tester, service, selectedBookingType: 'clinic');

      expect(find.byType(SessionTypeSelector), findsNothing);
    },
  );
}
