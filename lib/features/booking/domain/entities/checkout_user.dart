import 'package:equatable/equatable.dart';

/// An existing account found by `/api/checkout/check-user`.
class CheckoutUser extends Equatable {
  const CheckoutUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  final int id;
  final String name;
  final String phone;
  final String? email;

  @override
  List<Object?> get props => [id, name, phone, email];
}
