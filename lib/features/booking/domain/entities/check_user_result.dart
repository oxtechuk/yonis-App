import 'package:equatable/equatable.dart';

import 'checkout_user.dart';

/// Result of checking whether a phone number belongs to an existing
/// account, from `/api/checkout/check-user`.
class CheckUserResult extends Equatable {
  const CheckUserResult({
    required this.isRegistered,
    required this.requiresAccount,
    required this.requiresPassword,
    this.accountPrompt,
    this.message,
    this.user,
  });

  final bool isRegistered;
  final bool requiresAccount;
  final bool requiresPassword;
  final String? accountPrompt;
  final String? message;

  /// The matched account when [isRegistered] is true.
  final CheckoutUser? user;

  @override
  List<Object?> get props => [
        isRegistered,
        requiresAccount,
        requiresPassword,
        accountPrompt,
        message,
        user,
      ];
}
