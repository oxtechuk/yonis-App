import '../../domain/entities/payment_method_option.dart';

class PaymentMethodsConfigDto {
  const PaymentMethodsConfigDto({
    required this.methods,
    this.defaultMethod,
    this.whatsappNumber,
  });

  factory PaymentMethodsConfigDto.fromJson(Map<String, dynamic> json) {
    final rawList = json['payment_methods'] ?? json['data'] ?? json['methods'];
    final methods = <PaymentMethodOptionDto>[
      if (rawList is List)
        for (final item in rawList)
          if (item is Map<String, dynamic>)
            PaymentMethodOptionDto.fromJson(item),
    ];
    return PaymentMethodsConfigDto(
      methods: methods,
      defaultMethod: _str(json['default_method']),
      whatsappNumber: _str(json['whatsapp_number']),
    );
  }

  final List<PaymentMethodOptionDto> methods;
  final String? defaultMethod;
  final String? whatsappNumber;

  PaymentMethodsConfig toEntity() => PaymentMethodsConfig(
        methods: [
          for (final m in methods) m.toEntity(),
        ],
        defaultMethod: defaultMethod,
        whatsappNumber: whatsappNumber,
      );

  static String? _str(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }
}

class PaymentMethodOptionDto {
  const PaymentMethodOptionDto({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.logo,
    this.image,
    this.qrImage,
    this.instructions,
    this.badge,
    this.iconClass,
    this.color,
    this.isEnabled = true,
  });

  factory PaymentMethodOptionDto.fromJson(Map<String, dynamic> json) {
    return PaymentMethodOptionDto(
      id: (json['id'] ?? json['key'] ?? '').toString(),
      name: (json['name'] ?? json['id'] ?? '').toString(),
      nameAr: PaymentMethodsConfigDto._str(json['name_ar']),
      nameEn: PaymentMethodsConfigDto._str(json['name_en']),
      logo: PaymentMethodsConfigDto._str(json['logo']),
      image: PaymentMethodsConfigDto._str(json['image']),
      qrImage: PaymentMethodsConfigDto._str(
        json['qr_image'] ?? json['qr_code'] ?? json['qr_image_url'],
      ),
      instructions: PaymentMethodsConfigDto._str(json['instructions']),
      badge: PaymentMethodsConfigDto._str(json['badge']),
      iconClass: PaymentMethodsConfigDto._str(
        json['icon_class'] ?? json['icon'],
      ),
      color: PaymentMethodsConfigDto._str(json['color']),
      isEnabled: json['is_enabled'] as bool? ?? true,
    );
  }

  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String? logo;
  final String? image;
  final String? qrImage;
  final String? instructions;
  final String? badge;
  final String? iconClass;
  final String? color;
  final bool isEnabled;

  PaymentMethodOption toEntity() => PaymentMethodOption(
        id: id,
        name: name,
        nameAr: nameAr,
        nameEn: nameEn,
        logo: logo,
        image: image,
        qrImage: qrImage,
        instructions: instructions,
        badge: badge,
        iconClass: iconClass,
        color: color,
        isEnabled: isEnabled,
      );
}
