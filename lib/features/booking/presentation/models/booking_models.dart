import '../../../home/domain/entities/service.dart';

/// A selectable consultation option shown on the booking page.
///
/// Options are derived from the backend [Service] the user picked in the
/// booking sheet: one entry per offered delivery channel (chat/voice/video)
/// with its own price, or a single fallback option priced at the service's
/// base price when no per-channel pricing exists.
class ConsultationOption {
  const ConsultationOption({
    required this.label,
    required this.price,
    this.durationMinutes,
  });

  /// Arabic display label (the booking flow is Arabic-only for now).
  final String label;

  /// Session price in SAR.
  final double price;

  /// Session length in minutes, when provided by the backend.
  final int? durationMinutes;

  /// Trims trailing zeros ("50.00" -> "50") for display.
  String get displayPrice {
    if (price == price.truncateToDouble()) {
      return price.truncate().toString();
    }
    return price
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

abstract final class ConsultationOptions {
  /// Legacy defaults used only when no backend service is available
  /// (e.g. opening /booking directly without passing an extra).
  static const List<ConsultationOption> _fallback = [
    ConsultationOption(label: 'شات', price: 150),
    ConsultationOption(label: 'صوت', price: 250),
    ConsultationOption(label: 'فيديو', price: 350),
  ];

  static List<ConsultationOption> fromService(Service? service) {
    if (service == null) return _fallback;

    final options = <ConsultationOption>[
      if (service.chatPrice != null)
        ConsultationOption(
          label: 'شات',
          price: service.chatPrice!,
          durationMinutes: service.duration,
        ),
      if (service.voicePrice != null)
        ConsultationOption(
          label: 'صوت',
          price: service.voicePrice!,
          durationMinutes: service.duration,
        ),
      if (service.videoPrice != null)
        ConsultationOption(
          label: 'فيديو',
          price: service.videoPrice!,
          durationMinutes: service.duration,
        ),
    ];

    if (options.isNotEmpty) return options;

    // No per-channel pricing: single option from the base price.
    return [
      ConsultationOption(
        label: service.title,
        price: service.price,
        durationMinutes: service.duration,
      ),
    ];
  }
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
    required this.serviceId,
    required this.selectedOption,
    required this.consultationTitle,
    required this.consultationDetails,
    required this.paymentMethod,
    this.guestName,
    this.guestPhone,
  });

  /// Backend id of the booked service.
  final int serviceId;
  final ConsultationOption selectedOption;
  final String consultationTitle;
  final String consultationDetails;
  final PaymentMethod paymentMethod;

  /// Only filled when the user is booking as a guest.
  final String? guestName;
  final String? guestPhone;
}
