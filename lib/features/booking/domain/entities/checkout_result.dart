import 'package:equatable/equatable.dart';

import 'checkout_user.dart';

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
    this.transactionReference,
    this.transferNumber,
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

  final bool success;
  final String? message;
  final String? bookingReference;

  /// Payment-gateway transaction reference echoed back to
  /// `/api/booking/{ref}/confirm-payment`.
  final String? transactionReference;

  /// The doctor's wallet / transfer destination number shown to the user.
  final String? transferNumber;

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

  /// Access token for the (possibly newly created) patient account.
  /// Persisted to secure storage by the repository, mirroring login.
  final String? token;
  final String? tokenType;

  /// Patient profile returned alongside the token.
  final CheckoutUser? user;

  @override
  List<Object?> get props => [
        success,
        message,
        bookingReference,
        transactionReference,
        transferNumber,
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
        token,
        tokenType,
        user,
      ];
}
