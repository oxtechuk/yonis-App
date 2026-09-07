/// Simple in-memory auth state. Replace with your real auth provider later.
class AuthState {
  AuthState._();
  static final AuthState instance = AuthState._();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() => _isLoggedIn = true;
  void logout() => _isLoggedIn = false;

  /// Hydrates login state from a previously persisted token (e.g. the
  /// `token` returned by login and kept in secure storage), so a returning
  /// user is not asked to log in again while their token exists.
  void restoreFromToken(String? token) {
    _isLoggedIn = token != null && token.trim().isNotEmpty;
  }
}
