import 'package:equatable/equatable.dart';

/// A single client review from `GET /api/reviews`.
class Testimonial extends Equatable {
  const Testimonial({
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

  final int id;

  /// Backend display name (usually Arabic).
  final String name;
  final String? nameAr;
  final String? nameEn;

  final String avatar;

  /// Star rating (0-5).
  final int rating;

  /// Raw `review` field from the backend.
  final String review;
  final String? contentAr;
  final String? contentEn;

  final String? createdAt;

  /// Localized display name, falling back to [name].
  String nameFor(String languageCode) {
    if (languageCode == 'ar') {
      final ar = (nameAr ?? '').trim();
      if (ar.isNotEmpty) return ar;
    } else {
      final en = (nameEn ?? '').trim();
      if (en.isNotEmpty) return en;
    }
    return name;
  }

  /// Localized review body, falling back to [review].
  String contentFor(String languageCode) {
    if (languageCode == 'ar') {
      final ar = (contentAr ?? '').trim();
      if (ar.isNotEmpty) return ar;
    } else {
      final en = (contentEn ?? '').trim();
      if (en.isNotEmpty) return en;
    }
    final fallback = review.trim();
    if (fallback.isNotEmpty) return fallback;
    return (contentAr ?? contentEn ?? '').trim();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        nameEn,
        avatar,
        rating,
        review,
        contentAr,
        contentEn,
        createdAt,
      ];
}
