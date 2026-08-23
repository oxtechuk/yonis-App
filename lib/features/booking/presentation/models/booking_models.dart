/// Session type options for booking.
enum SessionType {
  chat('شات', 150),
  voice('صوت', 250),
  video('فيديو', 350);

  const SessionType(this.label, this.price);

  /// Arabic display label.
  final String label;

  /// Session price in SAR.
  final int price;
}

/// Payment method options.
enum PaymentMethod {
  applePay('ادفع باستخدام Apple Pay'),
  googlePay('ادفع باستخدام Google play'),
  card('ادفع باستخدام البطاقة');

  const PaymentMethod(this.label);

  /// Arabic display label.
  final String label;
}

/// Collected data for a booking.
class BookingData {
  const BookingData({
    required this.sessionType,
    required this.consultationTitle,
    required this.consultationDetails,
    required this.paymentMethod,
    this.guestName,
    this.guestPhone,
  });

  final SessionType sessionType;
  final String consultationTitle;
  final String consultationDetails;
  final PaymentMethod paymentMethod;

  /// Only filled when the user is booking as a guest.
  final String? guestName;
  final String? guestPhone;
}
