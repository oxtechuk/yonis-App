import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';

/// Attaches the persisted access token to outgoing requests as
/// `Authorization: Bearer <token>` (Laravel Sanctum style).
///
/// Authentication endpoints are excluded so a stale token from a previous
/// session is never sent with a fresh login attempt.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SecureStorage secureStorage})
    : _secureStorage = secureStorage;

  static const String _authorizationHeader = 'Authorization';
  static const List<String> _excludedPaths = ['/api/login'];

  final SecureStorage _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isExcluded =
        _excludedPaths.any((path) => options.path.startsWith(path));
    if (!isExcluded) {
      final token = await _secureStorage.read(SecureStorageKeys.accessToken);
      if (token != null && token.trim().isNotEmpty) {
        options.headers[_authorizationHeader] = 'Bearer ${token.trim()}';
      }
    }
    handler.next(options);
  }
}
