import 'package:equatable/equatable.dart';

class Service extends Equatable {
  const Service({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    this.duration,
    this.clinicPrice,
    this.chatPrice,
    this.voicePrice,
    this.videoPrice,
    this.serviceType,
    this.channelType,
    this.channels,
    this.isActive = true,
    this.location,
    this.bookingType,
    this.currency,
    this.currencySymbol,
  });

  final int id;
  final String title;
  final String description;

  /// Where the service can be delivered: `clinic`, `online` or `both`.
  final String type;

  /// Base price used for the "starting from" label in the booking sheet.
  final double price;

  /// Session length in minutes.
  final int? duration;

  /// Per-delivery-channel pricing. Null means the channel is not offered
  /// for this service.
  final double? clinicPrice;
  final double? chatPrice;
  final double? voicePrice;
  final double? videoPrice;

  /// The type of service: `clinic`, `online`, or `both`.
  final String? serviceType;

  /// The channel type for online services: `all`, `video`, etc.
  final String? channelType;

  /// Available channels for online services (video, voice, chat).
  final List<ServiceChannel>? channels;

  final bool isActive;

  /// Location for clinic services.
  final String? location;

  /// The booking type from the API.
  final String? bookingType;

  /// Currency code (e.g. IQD).
  final String? currency;

  /// Currency symbol (e.g. د.ع).
  final String? currencySymbol;

  /// Trims trailing zeros from the API price ("50.00" -> "50").
  String get displayPrice {
    if (price == price.truncateToDouble()) {
      return price.truncate().toString();
    }
    final fixed = price.toStringAsFixed(2);
    return fixed
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        price,
        duration,
        clinicPrice,
        chatPrice,
        voicePrice,
        videoPrice,
        serviceType,
        channelType,
        channels,
        isActive,
        location,
        bookingType,
        currency,
        currencySymbol,
      ];
}

class ServiceChannel {
  const ServiceChannel({
    required this.channel,
    required this.name,
    required this.price,
    required this.duration,
    required this.isEnabled,
    this.currency,
    this.currencySymbol,
  });

  final String channel;
  final String name;
  final double price;
  final int? duration;
  final bool isEnabled;
  final String? currency;
  final String? currencySymbol;
}
