/// Authenticated user as returned by the backend.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
}
