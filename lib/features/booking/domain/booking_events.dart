import 'package:flutter/foundation.dart';

/// Lightweight app-wide event bus for booking lifecycle events.
class BookingEvents {
  BookingEvents._();

  /// Fired whenever a new booking is created or payment is confirmed.
  /// Carries a timestamp in milliseconds so listeners are notified every time.
  static final ValueNotifier<int> bookingCreated = ValueNotifier<int>(0);

  static void notifyBookingCreated() {
    bookingCreated.value = DateTime.now().millisecondsSinceEpoch;
  }
}
