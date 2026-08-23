/// Simple in-memory auth state. Replace with your real auth provider later.
class AuthState {
  AuthState._();
  static final AuthState instance = AuthState._();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() => _isLoggedIn = true;
  void logout() => _isLoggedIn = false;
}
