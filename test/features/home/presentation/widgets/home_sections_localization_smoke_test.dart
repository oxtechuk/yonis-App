import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/pump_app.dart';

void main() {
  testWidgets('home sections render localized strings (ar default)',
      (tester) async {
    await pumpLocalizedApp(tester);
    await enterMainApp(tester);

    expect(find.text('المعالج النفسي\nيونس المرشد'), findsOneWidget);
    expect(find.text('احجز استشارتك'), findsOneWidget);
    expect(find.text('تابعنا عبر منصات التواصل'), findsOneWidget);
    expect(find.text('آراء العملاء'), findsOneWidget);
  });

  testWidgets('home sections render english strings after locale switch',
      (tester) async {
    await pumpLocalizedApp(tester);
    await enterMainApp(tester);

    final context = tester.element(find.byType(Scaffold).first);
    await context.setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    expect(find.text('Psychotherapist\nYounis Al-Murshid'), findsOneWidget);
    expect(find.text('Book Your Consultation'), findsOneWidget);
    expect(find.text('Follow Us on Social Media'), findsOneWidget);
    expect(find.text('Customer Testimonials'), findsOneWidget);

    // No Arabic home strings remain.
    expect(find.text('تابعنا عبر منصات التواصل'), findsNothing);
  });
}
