import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/features/home/data/models/testimonials_dto.dart';

void main() {
  group('TestimonialsResponseDto (real /api/reviews payload)', () {
    test('parses testimonials with localized names and content', () {
      final json = {
        'success': true,
        'total': 7,
        'total_reviews': 7,
        'average_rating': 5,
        'testimonials': [
          {
            'id': 2,
            'name': 'محمد السعدي',
            'name_ar': 'محمد السعدي',
            'name_en': 'Mohammed Al-Saadi',
            'avatar': 'https://images.unsplash.com/photo-1?w=200',
            'rating': 5,
            'review': 'تجربة متميزة جداً.',
            'content_ar': 'تجربة متميزة جداً.',
            'content_en': 'Exceptional experience.',
            'created_at': '2026-09-04T15:37:11+00:00',
          },
          {
            'id': 1,
            'name': 'امل ماهر',
            'name_ar': 'امل ماهر',
            'name_en': null,
            'avatar': 'https://younis-almurshid.com/storage/testimonials/x.png',
            'rating': 5,
            'review': 'امل ماهرامل ماهر',
            'content_ar': 'امل ماهرامل ماهر',
            'content_en': null,
            'created_at': '2026-09-04T15:24:50+00:00',
          },
        ],
      };

      final response = TestimonialsResponseDto.fromJson(json);

      expect(response.total, 7);
      expect(response.averageRating, 5);
      expect(response.testimonials, hasLength(2));

      final first = response.testimonials.first.toEntity();
      expect(first.id, 2);
      expect(first.rating, 5);
      expect(first.avatar, contains('unsplash'));
      expect(first.nameFor('ar'), 'محمد السعدي');
      expect(first.nameFor('en'), 'Mohammed Al-Saadi');
      expect(first.contentFor('ar'), 'تجربة متميزة جداً.');
      expect(first.contentFor('en'), 'Exceptional experience.');

      // Null English fields fall back to Arabic/raw values.
      final second = response.testimonials[1].toEntity();
      expect(second.nameFor('en'), 'امل ماهر');
      expect(second.contentFor('en'), 'امل ماهرامل ماهر');
    });

    test('handles missing testimonials list', () {
      final response = TestimonialsResponseDto.fromJson({'success': true});

      expect(response.testimonials, isEmpty);
      expect(response.total, 0);
      expect(response.averageRating, 0);
    });
  });
}
