import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/features/sessions/data/models/patient_booking_dto.dart';
import 'package:younis_app/features/sessions/domain/entities/patient_booking.dart';

void main() {
  group('PatientBookingDto.listFromJson', () {
    test('accepts a bare list', () {
      final dtos = PatientBookingDto.listFromJson([
        {'id': 7, 'service_title': 'استشارة', 'status': 'confirmed'},
      ]);
      expect(dtos, hasLength(1));
      expect(dtos.first.id, '7');
    });

    test('accepts {data: [...]} and paginated {data: {data: [...]}}', () {
      expect(
        PatientBookingDto.listFromJson({
          'data': [
            {'id': 1, 'status': 'pending'},
          ],
        }),
        hasLength(1),
      );
      expect(
        PatientBookingDto.listFromJson({
          'data': {
            'data': [
              {'id': 2, 'status': 'completed'},
            ],
          },
        }),
        hasLength(1),
      );
    });

    test('throws SerializationException on unknown shapes', () {
      expect(
        () => PatientBookingDto.listFromJson({'unexpected': 1}),
        throwsA(isA<Object>()),
      );
    });
  });

  group('status normalization', () {
    test('maps backend strings onto tabs', () {
      expect(
        PatientBookingDto.normalizeStatus('pending'),
        BookingStatus.upcoming,
      );
      expect(
        PatientBookingDto.normalizeStatus('confirmed'),
        BookingStatus.upcoming,
      );
      expect(
        PatientBookingDto.normalizeStatus('completed'),
        BookingStatus.completed,
      );
      expect(
        PatientBookingDto.normalizeStatus('cancelled'),
        BookingStatus.cancelled,
      );
      expect(
        PatientBookingDto.normalizeStatus('canceled'),
        BookingStatus.cancelled,
      );
    });
  });

  group('field aliases', () {
    test('reads nested service/doctor and ISO datetime', () {
      final dto = PatientBookingDto.fromJson({
        'booking_reference': 'REF-1',
        'service': {'name': 'خدمة'},
        'doctor': {'name': 'د. يونس'},
        'scheduled_at': '2024-05-01T10:30:00',
        'status': 'pending',
      });
      final entity = dto.toEntity();
      expect(entity.id, 'REF-1');
      expect(entity.title, 'خدمة');
      expect(entity.doctorName, 'د. يونس');
      expect(entity.date, '2024-05-01');
      expect(entity.time, '10:30');
      expect(entity.status, BookingStatus.upcoming);
    });

    test('parses the real /api/patient/bookings payload', () {
      final json = {
        'success': true,
        'bookings': [
          {
            'id': 30,
            'booking_reference': 'BK-OE87M9DK',
            'patient_id': 11,
            'service_id': 5,
            'booking_type': 'online',
            'consultation_type': 'video',
            'price': '50.00',
            'date': '2026-10-15T00:00:00.000000Z',
            'start_time': '10:00:00',
            'end_time': '10:30:00',
            'title': 'استشارة نفسية متخصصة',
            'notes': 'مريض مسجل بالفعل',
            'temp_user_data': null,
            'status': 'AwaitingPayment',
            'service': {
              'id': 5,
              'title': 'جلسة استشارة نفسية وتقييم أولي - 30 دقيقة',
              'duration': 30,
            },
            'payment': {'status': 'Pending', 'amount': '50.00'},
          },
          {
            'id': 36,
            'booking_reference': 'BK-FIMJJYAC',
            'booking_type': 'clinic',
            'consultation_type': 'clinic',
            'date': '2026-09-05T00:00:00.000000Z',
            'start_time': '16:15:00',
            'end_time': '16:45:00',
            'title': 'ddddd',
            'status': 'AwaitingPayment',
            'service': {'id': 5, 'title': 'جلسة', 'duration': 30},
          },
        ],
      };

      final dtos = PatientBookingDto.listFromJson(json);
      expect(dtos, hasLength(2));

      final first = dtos.first.toEntity();
      expect(first.id, '30');
      expect(first.title, 'استشارة نفسية متخصصة');
      expect(first.date, '2026-10-15');
      expect(first.time, '10:00 - 10:30');
      expect(first.duration, '30');
      expect(first.status, BookingStatus.upcoming);
      expect(first.rawStatus, 'AwaitingPayment');

      final second = dtos[1].toEntity();
      expect(second.time, '16:15 - 16:45');
      expect(second.status, BookingStatus.upcoming);
    });
  });
}
