import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../../../app/localization/locale_keys.g.dart';
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
    this.channel,
  });

  /// Arabic display label (the booking flow is Arabic-only for now).
  final String label;

  /// Session price in IQD.
  final double price;

  /// Session length in minutes, when provided by the backend.
  final int? durationMinutes;

  /// Delivery channel ('chat', 'voice', 'video' or 'clinic'), used to pick
  /// the matching icon. Null when the backend didn't specify one.
  final String? channel;

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
    ConsultationOption(label: 'شات', price: 150, channel: 'chat'),
    ConsultationOption(label: 'صوت', price: 250, channel: 'voice'),
    ConsultationOption(label: 'فيديو', price: 350, channel: 'video'),
  ];

  static List<ConsultationOption> fromService(
    Service? service, {
    String? selectedChannelType,
    String? bookingTypeOverride,
  }) {
    if (service == null) return _fallback;

    // The tab the caller picked (clinic/online) takes precedence over the
    // service's own bookingType, which the backend doesn't always set
    // consistently.
    final bookingType = bookingTypeOverride ?? service.bookingType;

    // Clinic services: single حضوري option from backend clinic_price/location.
    if (bookingType == 'clinic') {
      final price = service.clinicPrice ?? service.price;
      return [
        ConsultationOption(
          label: 'حضوري في العيادة',
          price: price,
          durationMinutes: service.duration,
          channel: 'clinic',
        ),
      ];
    }

    // If a specific channel is selected, use only that channel's price.
    if (selectedChannelType != null && service.channels != null) {
      final channel = service.channels!.firstWhere(
        (c) => c.channel == selectedChannelType,
        orElse: () => service.channels!.first,
      );
      return [
        ConsultationOption(
          label: channel.name,
          price: channel.price,
          durationMinutes: channel.duration ?? service.duration,
          channel: channel.channel,
        ),
      ];
    }

    // If service has channels and no specific channel selected, show all available channels.
    if (service.channels != null && service.channels!.isNotEmpty) {
      return service.channels!
          .where((c) => c.isEnabled)
          .map((c) => ConsultationOption(
                label: c.name,
                price: c.price,
                durationMinutes: c.duration ?? service.duration,
                channel: c.channel,
              ))
          .toList();
    }

    final options = <ConsultationOption>[
      if (service.chatPrice != null)
        ConsultationOption(
          label: 'شات',
          price: service.chatPrice!,
          durationMinutes: service.duration,
          channel: 'chat',
        ),
      if (service.voicePrice != null)
        ConsultationOption(
          label: 'صوت',
          price: service.voicePrice!,
          durationMinutes: service.duration,
          channel: 'voice',
        ),
      if (service.videoPrice != null)
        ConsultationOption(
          label: 'فيديو',
          price: service.videoPrice!,
          durationMinutes: service.duration,
          channel: 'video',
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
  zaincash,
  superki;

  /// Localized display label (requires [BuildContext] for the locale).
  String localizedLabel(BuildContext context) => switch (this) {
        PaymentMethod.zaincash => context.tr(LocaleKeys.booking_payZain),
        PaymentMethod.superki => context.tr(LocaleKeys.booking_paySuper),
      };
}

/// Localizes backend/Arabic fallback consultation labels.
String localizedOptionLabel(BuildContext context, String label) {
  return switch (label) {
    'شات' => context.tr(LocaleKeys.booking_chatOption),
    'صوت' => context.tr(LocaleKeys.booking_voiceOption),
    'فيديو' => context.tr(LocaleKeys.booking_videoOption),
    'حضوري في العيادة' => context.tr(LocaleKeys.booking_clinicOption),
    _ => label,
  };
}
