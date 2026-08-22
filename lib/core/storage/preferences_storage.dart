import 'package:shared_preferences/shared_preferences.dart';

/// Storage for simple, non-sensitive application settings (theme, language,
/// onboarding flags). Not a database — no arbitrary structured payloads.
abstract interface class PreferencesStorage {
  String? getString(String key);
  Future<void> setString(String key, String value);

  int? getInt(String key);
  Future<void> setInt(String key, int value);

  bool? getBool(String key);
  Future<void> setBool(String key, bool value);

  double? getDouble(String key);
  Future<void> setDouble(String key, double value);

  List<String>? getStringList(String key);
  Future<void> setStringList(String key, List<String> value);

  Future<void> remove(String key);

  Future<void> clear();
}

/// Centralized keys for preferences storage. Do not scatter raw strings.
abstract final class PreferencesKeys {
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String onboardingCompleted = 'onboarding_completed';
}

class SharedPreferencesStorage implements PreferencesStorage {
  const SharedPreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}
