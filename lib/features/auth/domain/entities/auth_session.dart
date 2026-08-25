import 'user.dart';

/// Result of a successful login: the access token plus the profile it
/// belongs to.
class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;
}
