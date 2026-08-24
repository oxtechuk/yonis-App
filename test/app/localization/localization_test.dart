import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';

Set<String> _collectLeafKeys(Map<String, dynamic> node, String prefix) {
  final keys = <String>{};
  node.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      keys.addAll(_collectLeafKeys(value, path));
    } else if (value is List) {
      fail('Translation arrays are not supported at "$path"');
    } else {
      keys.add(path);
    }
  });
  return keys;
}

Map<String, dynamic> _readTranslations(String fileName) {
  final file = File('assets/locales/$fileName');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('translation resources', () {
    test('en.json and ar.json have identical key structures', () {
      final en = _collectLeafKeys(_readTranslations('en.json'), '');
      final ar = _collectLeafKeys(_readTranslations('ar.json'), '');

      expect(
        ar.difference(en),
        isEmpty,
        reason: 'ar.json has keys missing from en.json',
      );
      expect(
        en.difference(ar),
        isEmpty,
        reason: 'en.json has keys missing from ar.json',
      );
    });

    test('interpolation placeholders exist in both locales', () {
      final en = _readTranslations('en.json');
      final ar = _readTranslations('ar.json');

      final enPlaceholders = en['placeholders'] as Map<String, dynamic>;
      final arPlaceholders = ar['placeholders'] as Map<String, dynamic>;

      expect(enPlaceholders['counterValue'], contains('{value}'));
      expect(arPlaceholders['counterValue'], contains('{value}'));
      expect(enPlaceholders['itemDetailOf'], contains('{itemId}'));
      expect(arPlaceholders['itemDetailOf'], contains('{itemId}'));
    });
  });

  testWidgets('renders arabic navigation labels by default', (tester) async {
    await pumpLocalizedApp(tester);
    await enterMainApp(tester);

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('خدمتنا'), findsOneWidget);
    expect(find.text('جلساتي'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);
  });

  testWidgets('switching to english translates labels and applies LTR', (
    tester,
  ) async {
    await pumpLocalizedApp(tester);
    await enterMainApp(tester);

    final context = tester.element(find.byType(Scaffold).first);
    await context.setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // Translated bottom-navigation labels.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('الرئيسية'), findsNothing);

    // Home content translated too.
    expect(
      find.text('Psychotherapist\nYounis Al-Murshid'),
      findsOneWidget,
    );

    // LTR applied at the app root.
    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, ui.TextDirection.ltr);
  });
}
