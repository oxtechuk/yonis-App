import '../../domain/entities/checkout_result.dart';
import '../../domain/entities/checkout_user.dart';

class CheckoutResultDto {
  const CheckoutResultDto({
    required this.success,
    this.message,
    this.bookingReference,
    this.stripeEnabled = false,
    this.clientSecret,
    this.amount,
    this.currency,
    this.currencySymbol,
    this.paymentMethod,
    this.qrCode,
    this.paymentInstructions,
    this.whatsappUrl,
    this.paymentUrl,
    this.redirectUrl,
    this.token,
    this.tokenType,
    this.user,
  });

  factory CheckoutResultDto.fromJson(Map<String, dynamic> json) {
    return CheckoutResultDto(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      bookingReference: json['booking_reference'] as String?,
      stripeEnabled: json['stripe_enabled'] as bool? ?? false,
      clientSecret: json['client_secret'] as String?,
      amount: _readDouble(json['amount']),
      currency: json['currency'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
      paymentMethod: json['payment_method'] as String?,
      qrCode: json['qr_code'] as String?,
      paymentInstructions: json['payment_instructions'] as String?,
      whatsappUrl: json['whatsapp_url'] as String?,
      paymentUrl: json['payment_url'] as String?,
      redirectUrl: json['redirect_url'] as String?,
      token: _readString(json['token']),
      tokenType: _readString(json['token_type']),
      user: _readUser(json['user']),
    );
  }

  static String? _readString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static CheckoutUserDto? _readUser(dynamic value) {
    if (value is! Map<String, dynamic>) return null;
    final id = value['id'];
    final name = _readString(value['name']);
    final phone = _readString(value['phone']);
    if (id is! num || name == null || phone == null) return null;
    return CheckoutUserDto(
      id: id.toInt(),
      name: name,
      phone: phone,
      email: _readString(value['email']),
    );
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  final bool success;
  final String? message;
  final String? bookingReference;
  final bool stripeEnabled;
  final String? clientSecret;
  final double? amount;
  final String? currency;
  final String? currencySymbol;
  final String? paymentMethod;
  final String? qrCode;
  final String? paymentInstructions;
  final String? whatsappUrl;
  final String? paymentUrl;
  final String? redirectUrl;
  final String? token;
  final String? tokenType;
  final CheckoutUserDto? user;

  CheckoutResult toEntity() => CheckoutResult(
        success: success,
        message: message,
        bookingReference: bookingReference,
        stripeEnabled: stripeEnabled,
        clientSecret: clientSecret,
        amount: amount,
        currency: currency,
        currencySymbol: currencySymbol,
        paymentMethod: paymentMethod,
        qrCode: qrCode,
        paymentInstructions: paymentInstructions,
        whatsappUrl: whatsappUrl,
        paymentUrl: paymentUrl,
        redirectUrl: redirectUrl,
        token: token,
        tokenType: tokenType,
        user: user?.toEntity(),
      );
}

/// Minimal patient profile carried by `/api/checkout/initialize`.
class CheckoutUserDto {
  const CheckoutUserDto({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  final int id;
  final String name;
  final String phone;
  final String? email;

  CheckoutUser toEntity() =>
      CheckoutUser(id: id, name: name, phone: phone, email: email);
}
