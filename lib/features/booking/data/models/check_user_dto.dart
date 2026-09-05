import '../../domain/entities/check_user_result.dart';
import '../../domain/entities/checkout_user.dart';

class CheckUserResultDto {
  const CheckUserResultDto({
    required this.success,
    required this.isRegistered,
    required this.requiresAccount,
    required this.requiresPassword,
    this.accountPrompt,
    this.message,
    this.user,
  });

  factory CheckUserResultDto.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return CheckUserResultDto(
      success: json['success'] as bool? ?? false,
      isRegistered: json['is_registered'] as bool? ?? false,
      requiresAccount: json['requires_account'] as bool? ?? false,
      requiresPassword: json['requires_password'] as bool? ?? false,
      accountPrompt: json['account_prompt'] as String?,
      message: json['message'] as String?,
      user: userJson is Map<String, dynamic>
          ? CheckoutUserDto.fromJson(userJson)
          : null,
    );
  }

  final bool success;
  final bool isRegistered;
  final bool requiresAccount;
  final bool requiresPassword;
  final String? accountPrompt;
  final String? message;
  final CheckoutUserDto? user;

  CheckUserResult toEntity() => CheckUserResult(
        isRegistered: isRegistered,
        requiresAccount: requiresAccount,
        requiresPassword: requiresPassword,
        accountPrompt: accountPrompt,
        message: message,
        user: user?.toEntity(),
      );
}

class CheckoutUserDto {
  const CheckoutUserDto({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  factory CheckoutUserDto.fromJson(Map<String, dynamic> json) {
    return CheckoutUserDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
    );
  }

  final int id;
  final String name;
  final String phone;
  final String? email;

  CheckoutUser toEntity() =>
      CheckoutUser(id: id, name: name, phone: phone, email: email);
}
