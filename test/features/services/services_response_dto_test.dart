import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/features/home/data/models/service_dto.dart';

void main() {
  group('ServicesResponseDto (real /api/services payloads)', () {
    test('parses the clinic payload', () {
      final json = {
        'success': true,
        'type': 'clinic',
        'currency': 'IQD',
        'currency_symbol': 'د.ع',
        'is_enabled': true,
        'total': 4,
        'services': [
          {
            'id': 5,
            'title': 'جلسة استشارة نفسية وتقييم أولي - 30 دقيقة',
            'description': 'جلسة استشارية أولية.',
            'duration': 30,
            'price': 50,
            'clinic_price': 50,
            'booking_type': 'clinic',
            'currency': 'IQD',
            'currency_symbol': 'د.ع',
            'type': 'both',
            'location': 'مقر العيادة - د. يونس المرشد',
          },
          {
            'id': 8,
            'title': 'جلسة دعم نفسي وإرشاد سريع - 15 دقيقة',
            'description': 'استشارة سريعة.',
            'duration': 15,
            'price': 30,
            'clinic_price': 30,
            'booking_type': 'clinic',
            'currency': 'IQD',
            'currency_symbol': 'د.ع',
            'type': 'both',
            'location': 'مقر العيادة - د. يونس المرشد',
          },
        ],
      };

      final response = ServicesResponseDto.fromJson(json);

      expect(response.success, isTrue);
      expect(response.type, 'clinic');
      expect(response.total, 4);
      expect(response.currencySymbol, 'د.ع');
      expect(response.services, hasLength(2));

      final first = response.services.first.toEntity();
      expect(first.id, 5);
      expect(first.duration, 30);
      expect(first.price, 50);
      expect(first.displayPrice, '50');
      expect(first.clinicPrice, 50);
      expect(first.bookingType, 'clinic');
      expect(first.location, 'مقر العيادة - د. يونس المرشد');
      expect(first.isActive, isTrue);
    });

    test('parses the online payload with channels', () {
      final json = {
        'success': true,
        'type': 'online',
        'currency': 'IQD',
        'currency_symbol': 'د.ع',
        'is_enabled': true,
        'channels_enabled': {'video': true, 'voice': true, 'chat': true},
        'total': 4,
        'services': [
          {
            'id': 5,
            'title': 'جلسة استشارة نفسية وتقييم أولي - 30 دقيقة',
            'description': 'جلسة استشارية أولية.',
            'duration': 30,
            'booking_type': 'online',
            'channel_type': 'all',
            'currency': 'IQD',
            'currency_symbol': 'د.ع',
            'type': 'both',
            'price': 50,
            'video_price': 50,
            'voice_price': 45,
            'chat_price': 40,
            'channels': [
              {
                'channel': 'video',
                'name': 'مكالمة فيديو أونلاين',
                'price': 50,
                'currency': 'IQD',
                'currency_symbol': 'د.ع',
                'duration': 30,
                'is_enabled': true,
              },
              {
                'channel': 'voice',
                'name': 'استشارة صوتية',
                'price': 45,
                'currency': 'IQD',
                'currency_symbol': 'د.ع',
                'duration': 30,
                'is_enabled': true,
              },
              {
                'channel': 'chat',
                'name': 'محادثة نصية (شات)',
                'price': 40,
                'currency': 'IQD',
                'currency_symbol': 'د.ع',
                'duration': 30,
                'is_enabled': true,
              },
            ],
          },
        ],
      };

      final response = ServicesResponseDto.fromJson(json);

      expect(response.channelsEnabled,
          {'video': true, 'voice': true, 'chat': true});

      final service = response.services.single.toEntity();
      expect(service.bookingType, 'online');
      expect(service.channelType, 'all');
      expect(service.videoPrice, 50);
      expect(service.voicePrice, 45);
      expect(service.chatPrice, 40);
      expect(service.channels, hasLength(3));
      expect(
        service.channels!.map((c) => c.channel),
        ['video', 'voice', 'chat'],
      );
      expect(
        service.channels!.where((c) => c.isEnabled),
        hasLength(3),
      );
      expect(service.channels!.first.name, 'مكالمة فيديو أونلاين');
    });
  });
}
