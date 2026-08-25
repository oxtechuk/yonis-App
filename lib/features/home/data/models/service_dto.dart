import '../../../../core/error/app_exception.dart';
import '../../domain/entities/service.dart';

class ServicesResponseDto {
  const ServicesResponseDto({required this.services});

  factory ServicesResponseDto.fromJson(Map<String, dynamic> json) {
    final list = json['services'];
    if (list is! List<dynamic>) {
      throw const SerializationException(
        message: 'Services response is missing the "services" array.',
      );
    }
    return ServicesResponseDto(
      services: list
          .whereType<Map<String, dynamic>>()
          .map(ServiceDto.fromJson)
          .toList(growable: false),
    );
  }

  final List<ServiceDto> services;
}

class ServiceDto {
  const ServiceDto({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    this.duration,
    this.isActive = true,
  });

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    return ServiceDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: _readString(json, 'title') ?? '',
      description: _readString(json, 'description') ?? '',
      type: _readString(json, 'type') ?? 'both',
      price: _readDouble(json, 'price') ?? 0,
      duration: (json['duration'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  /// The API serializes prices as JSON strings ("50.00"), but tolerate
  /// raw numbers too.
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
  final bool isActive;

  Service toEntity() => Service(
        id: id,
        title: title,
        description: description,
        type: type,
        price: price,
        duration: duration,
        isActive: isActive,
      );
}
