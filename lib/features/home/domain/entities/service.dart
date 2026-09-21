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
    this.icon,
    this.iconUrl,
    this.titleAr = '',
    this.titleEn = '',
    this.descriptionAr = '',
    this.descriptionEn = '',
    this.channelLabelAr = '',
    this.channelLabelEn = '',
  });

  final int id;

  /// Legacy resolved title (kept for backward compat). Prefer
  /// [titleFor] so English mode shows `title_en` and Arabic `title_ar`.
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

  /// Bootstrap icon name from the API (e.g. "bi-hospital").
  final String? icon;

  /// Optional absolute icon image URL from the API.
  final String? iconUrl;

  /// Localized titles from `title_ar` / `title_en` (`GET /api/services/*`).
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;

  /// Localized channel labels (`channel_label_ar` / `channel_label_en`).
  final String channelLabelAr;
  final String channelLabelEn;

  /// Title for the current locale. Falls back to [title] (then the other
  /// language) when the requested translation is missing.
  String titleFor(bool isArabic) {
    if (isArabic) {
      if (titleAr.isNotEmpty) return titleAr;
      if (title.isNotEmpty) return title;
      return titleEn;
    }
    if (titleEn.isNotEmpty) return titleEn;
    if (title.isNotEmpty) return title;
    return titleAr;
  }

  String descriptionFor(bool isArabic) {
    if (isArabic) {
      if (descriptionAr.isNotEmpty) return descriptionAr;
      if (description.isNotEmpty) return description;
      return descriptionEn;
    }
    if (descriptionEn.isNotEmpty) return descriptionEn;
    if (description.isNotEmpty) return description;
    return descriptionAr;
  }

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
        titleAr,
        titleEn,
        descriptionAr,
        descriptionEn,
        channelLabelAr,
        channelLabelEn,
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
        icon,
        iconUrl,
      ];
}

class ServiceChannel extends Equatable {
  const ServiceChannel({
    required this.channel,
    required this.name,
    required this.price,
    required this.duration,
    required this.isEnabled,
    this.currency,
    this.currencySymbol,
    this.nameAr = '',
    this.nameEn = '',
  });

  final String channel;

  /// Legacy resolved name. Prefer [nameFor] for locale-aware display.
  final String name;
  final double price;
  final int? duration;
  final bool isEnabled;
  final String? currency;
  final String? currencySymbol;

  /// Localized names from `name_ar` / `name_en`.
  final String nameAr;
  final String nameEn;

  String nameFor(bool isArabic) {
    if (isArabic) {
      if (nameAr.isNotEmpty) return nameAr;
      if (name.isNotEmpty) return name;
      return nameEn;
    }
    if (nameEn.isNotEmpty) return nameEn;
    if (name.isNotEmpty) return name;
    return nameAr;
  }

  @override
  List<Object?> get props => [channel, name, nameAr, nameEn, price];
}
