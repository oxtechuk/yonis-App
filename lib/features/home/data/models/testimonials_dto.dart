import '../../domain/entities/testimonial.dart';

class TestimonialsResponseDto {
  const TestimonialsResponseDto({
    required this.testimonials,
    required this.total,
    required this.averageRating,
  });

  factory TestimonialsResponseDto.fromJson(Map<String, dynamic> json) {
    final list = json['testimonials'];
    final items = list is List<dynamic>
        ? list
            .whereType<Map<String, dynamic>>()
            .map(TestimonialDto.fromJson)
            .toList(growable: false)
        : const <TestimonialDto>[];
    return TestimonialsResponseDto(
      testimonials: items,
      total: (json['total_reviews'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          items.length,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
    );
  }

  final List<TestimonialDto> testimonials;
  final int total;
  final double averageRating;
}

class TestimonialDto {
  const TestimonialDto({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.review,
    this.nameAr,
    this.nameEn,
    this.contentAr,
    this.contentEn,
    this.createdAt,
  });

  factory TestimonialDto.fromJson(Map<String, dynamic> json) {
    return TestimonialDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _readString(json, 'name') ??
          _readString(json, 'name_ar') ??
          _readString(json, 'name_en') ??
          '',
      nameAr: _readString(json, 'name_ar'),
      nameEn: _readString(json, 'name_en'),
      avatar: _readString(json, 'avatar') ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      review: _readString(json, 'review') ??
          _readString(json, 'content_ar') ??
          _readString(json, 'content_en') ??
          '',
      contentAr: _readString(json, 'content_ar'),
      contentEn: _readString(json, 'content_en'),
      createdAt: _readString(json, 'created_at'),
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
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String avatar;
  final int rating;
  final String review;
  final String? contentAr;
  final String? contentEn;
  final String? createdAt;

  Testimonial toEntity() => Testimonial(
        id: id,
        name: name,
        nameAr: nameAr,
        nameEn: nameEn,
        avatar: avatar,
        rating: rating,
        review: review,
        contentAr: contentAr,
        contentEn: contentEn,
        createdAt: createdAt,
      );
}
