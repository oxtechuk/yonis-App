import '../../domain/entities/service.dart';

class ServicesResponseDto {
  const ServicesResponseDto({
    required this.success,
    required this.type,
    required this.services,
    this.channelsEnabled,
    this.isEnabled = true,
    this.total = 0,
    this.currency = 'IQD',
    this.currencySymbol = 'د.ع',
  });

  factory ServicesResponseDto.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'all';
    final services = _parseServiceList(json['services']);
    return ServicesResponseDto(
      success: json['success'] as bool? ?? false,
      type: type,
      services: services,
      channelsEnabled: (json['channels_enabled'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as bool)),
      isEnabled: json['is_enabled'] as bool? ?? true,
      total: (json['total'] as num?)?.toInt() ?? 0,
      currency: _readString(json, 'currency') ?? 'IQD',
      currencySymbol: _readString(json, 'currency_symbol') ?? 'د.ع',
    );
  }

  static List<ServiceDto> _parseServiceList(dynamic jsonList) {
    final list = jsonList;
    if (list is! List<dynamic>) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ServiceDto.fromJson)
        .toList(growable: false);
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  final bool success;
  final String type;
  final List<ServiceDto> services;
  final Map<String, bool>? channelsEnabled;
  final bool isEnabled;
  final int total;
  final String currency;
  final String currencySymbol;
}

class ServiceDto {
  const ServiceDto({
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

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    // New API shape carries `title_ar` / `title_en` (same for description
    // and channel labels). Legacy payloads only sent `title` /
    // `description` — keep reading those as fallback.
    final titleAr = _readString(json, 'title_ar') ?? '';
    final titleEn = _readString(json, 'title_en') ?? '';
    final legacyTitle = _readString(json, 'title') ?? '';
    final descriptionAr = _readString(json, 'description_ar') ?? '';
    final descriptionEn = _readString(json, 'description_en') ?? '';
    final legacyDescription = _readString(json, 'description') ?? '';
    return ServiceDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: legacyTitle.isNotEmpty
          ? legacyTitle
          : (titleAr.isNotEmpty ? titleAr : titleEn),
      description: legacyDescription.isNotEmpty
          ? legacyDescription
          : (descriptionAr.isNotEmpty ? descriptionAr : descriptionEn),
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      channelLabelAr: _readString(json, 'channel_label_ar') ?? '',
      channelLabelEn: _readString(json, 'channel_label_en') ?? '',
      type: _readString(json, 'type') ?? 'both',
      price: _readDouble(json, 'price') ?? 0,
      duration: (json['duration'] as num?)?.toInt(),
      clinicPrice: _readDouble(json, 'clinic_price'),
      chatPrice: _readDouble(json, 'chat_price'),
      voicePrice: _readDouble(json, 'voice_price'),
      videoPrice: _readDouble(json, 'video_price'),
      channelType: _readString(json, 'channel_type'),
      channels: _parseChannels(json['channels']),
      isActive: json['is_active'] as bool? ?? true,
      location: _readString(json, 'location'),
      bookingType: _readString(json, 'booking_type'),
      currency: _readString(json, 'currency'),
      currencySymbol: _readString(json, 'currency_symbol'),
      icon: _readString(json, 'icon'),
      iconUrl: _readString(json, 'icon_url'),
    );
  }

  static List<ChannelDto> _parseChannels(dynamic jsonList) {
    final list = jsonList;
    if (list is! List<dynamic>) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ChannelDto.fromJson)
        .toList(growable: false);
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  final int id;
  final String title;
  final String description;
  final String type;
  final double price;
  final int? duration;
  final double? clinicPrice;
  final double? chatPrice;
  final double? voicePrice;
  final double? videoPrice;
  final String? channelType;
  final List<ChannelDto>? channels;
  final bool isActive;
  final String? location;
  final String? bookingType;
  final String? currency;
  final String? currencySymbol;
  final String? icon;
  final String? iconUrl;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String channelLabelAr;
  final String channelLabelEn;

  /// Falls back to the response-level currency when the service item
  /// (or its channels) omit their own — the backend sends `currency` /
  /// `currency_symbol` at the top level (e.g. USD/$) and only sometimes
  /// repeats them per service/channel.
  Service toEntity({String? fallbackCurrency, String? fallbackCurrencySymbol}) {
    final resolvedCurrency = currency ?? fallbackCurrency;
    final resolvedSymbol = currencySymbol ?? fallbackCurrencySymbol;
    return Service(
      id: id,
      title: title,
      description: description,
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      channelLabelAr: channelLabelAr,
      channelLabelEn: channelLabelEn,
      type: type,
      price: price,
      duration: duration,
      clinicPrice: clinicPrice,
      chatPrice: chatPrice,
      voicePrice: voicePrice,
      videoPrice: videoPrice,
      serviceType: type,
      channelType: channelType,
      channels: channels
          ?.map(
            (c) => c.toEntity(
              fallbackCurrency: resolvedCurrency,
              fallbackCurrencySymbol: resolvedSymbol,
            ),
          )
          .toList(),
      isActive: isActive,
      location: location,
      bookingType: bookingType,
      currency: resolvedCurrency,
      currencySymbol: resolvedSymbol,
      icon: icon,
      iconUrl: iconUrl,
    );
  }

  ServiceDto copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    double? price,
    int? duration,
    double? clinicPrice,
    double? chatPrice,
    double? voicePrice,
    double? videoPrice,
    String? channelType,
    List<ChannelDto>? channels,
    bool? isActive,
    String? location,
    String? bookingType,
    String? currency,
    String? currencySymbol,
    String? icon,
    String? iconUrl,
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    String? channelLabelAr,
    String? channelLabelEn,
  }) {
    return ServiceDto(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      clinicPrice: clinicPrice ?? this.clinicPrice,
      chatPrice: chatPrice ?? this.chatPrice,
      voicePrice: voicePrice ?? this.voicePrice,
      videoPrice: videoPrice ?? this.videoPrice,
      channelType: channelType ?? this.channelType,
      channels: channels ?? this.channels,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      bookingType: bookingType ?? this.bookingType,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      icon: icon ?? this.icon,
      iconUrl: iconUrl ?? this.iconUrl,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      channelLabelAr: channelLabelAr ?? this.channelLabelAr,
      channelLabelEn: channelLabelEn ?? this.channelLabelEn,
    );
  }
}

class ChannelDto {
  const ChannelDto({
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

  factory ChannelDto.fromJson(Map<String, dynamic> json) {
    final nameAr = _readString(json, 'name_ar') ?? '';
    final nameEn = _readString(json, 'name_en') ?? '';
    final legacyName = _readString(json, 'name') ?? '';
    return ChannelDto(
      channel: _readString(json, 'channel') ?? '',
      name: legacyName.isNotEmpty
          ? legacyName
          : (nameAr.isNotEmpty ? nameAr : nameEn),
      nameAr: nameAr,
      nameEn: nameEn,
      price: _readDouble(json, 'price') ?? 0,
      duration: (json['duration'] as num?)?.toInt(),
      isEnabled: json['is_enabled'] as bool? ?? true,
      currency: _readString(json, 'currency'),
      currencySymbol: _readString(json, 'currency_symbol'),
    );
  }

  ServiceChannel toEntity(
          {String? fallbackCurrency, String? fallbackCurrencySymbol}) =>
      ServiceChannel(
        channel: channel,
        name: name,
        nameAr: nameAr,
        nameEn: nameEn,
        price: price,
        duration: duration,
        isEnabled: isEnabled,
        currency: currency ?? fallbackCurrency,
        currencySymbol: currencySymbol ?? fallbackCurrencySymbol,
      );

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  final String channel;
  final String name;
  final double price;
  final int? duration;
  final bool isEnabled;
  final String? currency;
  final String? currencySymbol;
  final String nameAr;
  final String nameEn;
}

