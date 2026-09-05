import 'package:equatable/equatable.dart';

class Reel extends Equatable {
  const Reel({
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

  final int id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String platform;
  final int duration;
  final int sortOrder;
  final bool isActive;
  final String? titleEn;

  @override
  List<Object?> get props => [
        id,
        title,
        thumbnailUrl,
        videoUrl,
        platform,
        duration,
        sortOrder,
        isActive,
        titleEn,
      ];
}