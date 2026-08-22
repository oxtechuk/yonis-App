import 'dart:ui';

/// Central configuration of application localization resources.
abstract final class AppLocalization {
  static const String translationsPath = 'assets/locales';

  static const Locale fallbackLocale = Locale('en');

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];
}
