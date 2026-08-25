import '../../../../core/error/app_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';

class LoginResponseDto {
  const LoginResponseDto({required this.token, required this.user});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token is! String || token.trim().isEmpty) {
      throw const SerializationException(
        message: 'Login response is missing the "token".',
      );
    }
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const SerializationException(
        message: 'Login response is missing the "user" object.',
      );
    }
    return LoginResponseDto(
      token: token.trim(),
      user: UserDto.fromJson(userJson),
    );
  }

  final String token;
  final UserDto user;

  AuthSession toEntity() =>
      AuthSession(token: token, user: user.toEntity());
}

class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _readString(json, 'name') ?? '',
      email: _readString(json, 'email') ?? '',
      phone: _readString(json, 'phone') ?? '',
      role: _readString(json, 'role') ?? 'patient',
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: role,
      );
}
