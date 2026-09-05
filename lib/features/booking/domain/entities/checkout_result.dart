import 'package:equatable/equatable.dart';

/// Result of `POST /api/checkout/initialize`.
///
/// [success] `false` is a normal business outcome (e.g. the slot was just
/// taken by someone else) carried in [message] — it is NOT a transport
/// error, so it arrives as a [Success] at the repository boundary. Payment
/// details below are only populated when [success] is true.
class CheckoutResult extends Equatable {
  const CheckoutResult({
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

  @override
  List<Object?> get props => [
        success,
        message,
        bookingReference,
        stripeEnabled,
        clientSecret,
        amount,
        currency,
        currencySymbol,
        paymentMethod,
        qrCode,
        paymentInstructions,
        whatsappUrl,
        paymentUrl,
        redirectUrl,
      ];
}
