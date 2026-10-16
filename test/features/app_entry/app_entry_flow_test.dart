import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/app/localization/locale_keys.g.dart';
import 'package:younis_app/app/router/app_navigation_shell.dart';
import 'package:younis_app/features/app_entry/data/models/splash_config_dto.dart';
import 'package:younis_app/features/app_entry/presentation/pages/splash_page.dart';

import '../../support/pump_app.dart';

void main() {
  test('SplashConfigDto parses /api/splash JSON payload accurately', () {
    final json = <String, dynamic>{
      'success': true,
      'is_enabled': true,
      'duration': 3,
      'title': 'مرحباً بك في تطبيق عيادة د. يونس المرشدي',
      'subtitle': 'احجز استشارتك الطبية والنفسية بكل سهولة وسرية تامة',
      'image_url':
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1000&q=80',
    };

    final entity = SplashConfigDto.fromResponseJson(json).toEntity();

    expect(entity.isEnabled, isTrue);
    expect(entity.durationSeconds, 3);
    expect(entity.duration, const Duration(seconds: 3));
    expect(entity.title, 'مرحباً بك في تطبيق عيادة د. يونس المرشدي');
    expect(
      entity.subtitle,
      'احجز استشارتك الطبية والنفسية بكل سهولة وسرية تامة',
    );
    expect(
      entity.imageUrl,
      'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1000&q=80',
    );
  });

  testWidgets(
    'displays dynamic splash content and auto-navigates to home after duration',
    (tester) async {
      await pumpLocalizedApp(tester);

      expect(find.byType(SplashPage), findsOneWidget);
      expect(
        find.text('مرحباً بك في تطبيق عيادة د. يونس المرشدي'),
        findsOneWidget,
      );
      expect(
        find.text('احجز استشارتك الطبية والنفسية بكل سهولة وسرية تامة'),
        findsOneWidget,
      );
      expect(find.text('ابدأ الآن'), findsOneWidget);

      // Advance fake time past the API duration (3 seconds).
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(SplashPage), findsNothing);
      expect(find.byType(AppNavigationShell), findsOneWidget);
    },
  );

  testWidgets('tapping Start Now navigates immediately to home', (
    tester,
  ) async {
    await pumpLocalizedApp(tester);

    expect(find.byType(SplashPage), findsOneWidget);

    await tester.tap(find.text(LocaleKeys.welcome_startNow.tr()));
    await tester.pumpAndSettle();

    expect(find.byType(AppNavigationShell), findsOneWidget);
    expect(find.byType(SplashPage), findsNothing);
  });

  testWidgets('skips splash and navigates directly to home when is_enabled is false', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      splashRemoteDataSource: const FakeSplashRemoteDataSource(
        SplashConfigDto(
          isEnabled: false,
          durationSeconds: 3,
          title: 'مرحباً بك في تطبيق عيادة د. يونس المرشدي',
          subtitle: 'احجز استشارتك الطبية والنفسية بكل سهولة وسرية تامة',
        ),
      ),
    );

    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(AppNavigationShell), findsOneWidget);
  });
}
