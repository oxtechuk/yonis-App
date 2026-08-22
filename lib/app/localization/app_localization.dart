import 'dart:ui';

/// Central configuration of application localization resources.
abstract final class AppLocalization {
  static const String translationsPath = 'assets/locales';

  static const Locale defaultLocale = Locale('ar');

  static const Locale fallbackLocale = Locale('ar');

  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];
}
