import 'package:equatable/equatable.dart';

/// Result of `POST /api/booking/{booking_ref}/confirm-payment`.
///
/// [success] `false` is a normal business outcome (e.g. the proof was
/// rejected) carried in [message] — it is NOT a transport error, so it
/// arrives as a [Success] at the repository boundary.
class ConfirmPaymentResult extends Equatable {
  const ConfirmPaymentResult({
    required this.success,
    this.message,
    this.status,
  });

  final bool success;
  final String? message;

  /// Booking status after the proof was submitted (e.g.
  /// `PendingPaymentReview`).
  final String? status;

  @override
  List<Object?> get props => [success, message, status];
}
