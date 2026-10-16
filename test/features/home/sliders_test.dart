import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/features/home/data/models/sliders_dto.dart';
import 'package:younis_app/features/home/data/sources/sliders_remote_data_source.dart';
import 'package:younis_app/features/home/presentation/widgets/home_hero_section.dart';
import 'package:younis_app/app/di/dependency_injection.dart';

import '../../support/pump_app.dart';

class _FakeSlidersRemoteDataSource implements SlidersRemoteDataSource {
  const _FakeSlidersRemoteDataSource(this.response);

  final SlidersResponseDto response;

  @override
  Future<SlidersResponseDto> getSliders() async => response;
}

void main() {
  const samplePayload = <String, dynamic>{
    'success': true,
    'total': 2,
    'sliders': [
      {
        'id': 1,
        'title': 'استشارات تخصصية وسرية تامة',
        'subtitle': 'احجز موعدك الآن مع نخبة الأطباء والاستشاريين',
        'image_url':
            'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
        'action_type': 'doctor',
        'action_value': '1',
        'sort_order': 1,
      },
      {
        'id': 2,
        'title': 'جلسات حضورية وأونلاين',
        'subtitle': 'استشارة فيديو، صوت، أو زيارة مباشرة لمقر العيادة',
        'image_url':
            'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=1200&q=80',
        'action_type': 'service',
        'action_value': '1',
        'sort_order': 2,
      },
    ],
  };

  test('SlidersResponseDto parses /api/sliders payload and sorts by sort_order', () {
    final dto = SlidersResponseDto.fromJson(samplePayload);
    expect(dto.sliders, hasLength(2));

    final first = dto.sliders[0].toEntity();
    expect(first.id, 1);
    expect(first.title, 'استشارات تخصصية وسرية تامة');
    expect(first.subtitle, 'احجز موعدك الآن مع نخبة الأطباء والاستشاريين');
    expect(first.actionType, 'doctor');
    expect(first.actionValue, '1');
    expect(first.sortOrder, 1);

    final second = dto.sliders[1].toEntity();
    expect(second.id, 2);
    expect(second.title, 'جلسات حضورية وأونلاين');
    expect(second.subtitle, 'استشارة فيديو، صوت، أو زيارة مباشرة لمقر العيادة');
    expect(second.actionType, 'service');
    expect(second.actionValue, '1');
    expect(second.sortOrder, 2);
  });

  testWidgets('HomeHeroSection renders dynamic sliders and swipes between slides', (
    tester,
  ) async {
    await pumpLocalizedApp(tester);
    getIt.registerLazySingleton<SlidersRemoteDataSource>(
      () => _FakeSlidersRemoteDataSource(
        SlidersResponseDto.fromJson(samplePayload),
      ),
    );

    await enterMainApp(tester);

    expect(find.byType(HomeHeroSection), findsOneWidget);
    expect(find.text('استشارات تخصصية وسرية تامة'), findsOneWidget);
    expect(
      find.text('احجز موعدك الآن مع نخبة الأطباء والاستشاريين'),
      findsOneWidget,
    );

    // Swipe PageView to the second slide (RTL: drag right >50% of 800px viewport).
    await tester.drag(find.byType(PageView), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(find.text('جلسات حضورية وأونلاين'), findsOneWidget);
    expect(
      find.text('استشارة فيديو، صوت، أو زيارة مباشرة لمقر العيادة'),
      findsOneWidget,
    );
  });
}
