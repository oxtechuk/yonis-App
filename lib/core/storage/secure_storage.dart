import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/app_exception.dart';

/// Storage for SENSITIVE values only: access/refresh tokens and other
/// credentials. Ordinary settings belong in PreferencesStorage.
abstract interface class SecureStorage {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<void> clear();
}

/// Centralized keys for secure storage. Do not scatter raw strings.
abstract final class SecureStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}

class FlutterSecureStorageImpl implements SecureStorage {
  FlutterSecureStorageImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (error) {
      throw CacheStorageException(
        message: 'Failed to read "$key" from secure storage.',
      );
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (error) {
      throw CacheStorageException(
        message: 'Failed to write "$key" to secure storage.',
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (error) {
      throw CacheStorageException(
        message: 'Failed to delete "$key" from secure storage.',
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (error) {
      throw const CacheStorageException(
        message: 'Failed to clear secure storage.',
      );
    }
  }
}
