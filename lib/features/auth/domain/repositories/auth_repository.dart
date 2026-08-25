import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  /// Authenticates with [identifier] (phone number) and [password].
  /// Persists the returned access token on success.
  Future<Result<AuthSession>> login({
    required String identifier,
    required String password,
  });
}
