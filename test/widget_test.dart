import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/app/router/app_navigation_shell.dart';
import 'package:younis_app/app/router/app_routes.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('starts in guest mode on the home tab without login', (
    tester,
  ) async {
    await pumpLocalizedApp(tester);
    await enterMainApp(tester);

    expect(find.byType(AppNavigationShell), findsOneWidget);
    expect(find.text('المعالج النفسي\nيونس المرشد'), findsOneWidget);
  });

  test('route path constants remain stable', () {
    expect(AppRoutes.home, '/home');
    expect(AppRoutes.services, '/services');
    expect(AppRoutes.sessions, '/sessions');
    expect(AppRoutes.profile, '/profile');
    expect(AppRoutes.homeItemDetailLocation('7'), '/home/items/7');
  });
}
