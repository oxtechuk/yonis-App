import '../../domain/entities/splash_config.dart';

/// DTO for `GET /api/splash`.
class SplashConfigDto {
  const SplashConfigDto({
    required this.isEnabled,
    required this.durationSeconds,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  final bool isEnabled;
  final int durationSeconds;
  final String title;
  final String subtitle;
  final String? imageUrl;

  factory SplashConfigDto.fromResponseJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return SplashConfigDto.fromJson(data);
    }
    return SplashConfigDto.fromJson(json);
  }

  factory SplashConfigDto.fromJson(Map<String, dynamic> json) {
    return SplashConfigDto(
      isEnabled: _readBool(json, 'is_enabled', defaultValue: true),
      durationSeconds: _readInt(json, 'duration', defaultValue: 3),
      title: _readString(json, 'title') ?? '',
      subtitle: _readString(json, 'subtitle') ?? '',
      imageUrl: _readString(json, 'image_url'),
    );
  }

  static bool _readBool(
    Map<String, dynamic> json,
    String key, {
    required bool defaultValue,
  }) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return defaultValue;
  }

  static int _readInt(
    Map<String, dynamic> json,
    String key, {
    required int defaultValue,
  }) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    return defaultValue;
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  SplashConfig toEntity() => SplashConfig(
        isEnabled: isEnabled,
        durationSeconds: durationSeconds,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
      );
}
