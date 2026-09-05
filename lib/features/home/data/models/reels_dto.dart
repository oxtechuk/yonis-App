import '../../domain/entities/reel.dart';

class ReelsResponseDto {
  const ReelsResponseDto({
    required this.reels,
  });

  factory ReelsResponseDto.fromJson(Map<String, dynamic> json) {
    final reels = _parseReelList(json['reels']);
    return ReelsResponseDto(reels: reels);
  }

  static List<ReelDto> _parseReelList(dynamic jsonList) {
    final list = jsonList;
    if (list is! List<dynamic>) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ReelDto.fromJson)
        .toList(growable: false);
  }

  final List<ReelDto> reels;
}

class ReelDto {
  const ReelDto({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.platform,
    required this.duration,
    required this.sortOrder,
    required this.isActive,
    this.titleEn,
  });

  factory ReelDto.fromJson(Map<String, dynamic> json) {
    return ReelDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: _readString(json, 'title') ?? '',
      thumbnailUrl: _readString(json, 'thumbnail_url') ?? '',
      videoUrl: _readString(json, 'video_url') ?? '',
      platform: _readString(json, 'platform') ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      titleEn: _readString(json, 'title_en'),
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  final int id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String platform;
  final int duration;
  final int sortOrder;
  final bool isActive;
  final String? titleEn;

  Reel toEntity() => Reel(
        id: id,
        title: title,
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
        platform: platform,
        duration: duration,
        sortOrder: sortOrder,
        isActive: isActive,
        titleEn: titleEn,
      );
}