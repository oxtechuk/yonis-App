import 'dart:ui';

/// Central configuration of application localization resources.
abstract final class AppLocalization {
  static const String translationsPath = 'assets/locales';

  static const Locale defaultLocale = Locale('ar');

  static const Locale fallbackLocale = Locale('ar');

  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];

  /// Maps a persisted language code back to a supported locale, falling
  /// back to [defaultLocale] for unknown or missing values.
  static Locale localeFromSavedCode(String? code) {
    for (final locale in supportedLocales) {
      if (locale.languageCode == code) {
        return locale;
      }
    }
    return defaultLocale;
  }
}
