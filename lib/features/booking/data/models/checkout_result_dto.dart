import '../../domain/entities/checkout_result.dart';

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
      );
}
