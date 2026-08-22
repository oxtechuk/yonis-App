import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/app/router/app_routes.dart';
import 'package:younis_app/features/home/presentation/pages/home_item_detail_page.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('starts in guest mode on the home tab without login', (
    tester,
  ) async {
    await pumpLocalizedApp(tester);

    expect(find.text('Home tab content'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('switching tabs preserves each branch stack and state', (
    tester,
  ) async {
    await pumpLocalizedApp(tester);

    // Home branch local state.
    await tester.tap(find.text('Increment'));
    await tester.pumpAndSettle();
    expect(find.text('Counter: 1'), findsOneWidget);

    // Nested navigation inside the Home branch.
    await tester.tap(find.text('Open item details'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeItemDetailPage), findsOneWidget);
    expect(find.text('Item detail: demo-42'), findsOneWidget);

    // Switch to Search.
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search tab content'), findsOneWidget);

    // Switch to Profile.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile tab content'), findsOneWidget);

    // Return to Home: the pushed detail page must still be on its stack.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeItemDetailPage), findsOneWidget);
    expect(find.text('Item detail: demo-42'), findsOneWidget);

    // Popping inside the branch returns to the preserved home state.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomeItemDetailPage), findsNothing);
    expect(find.text('Home tab content'), findsOneWidget);
    expect(find.text('Counter: 1'), findsOneWidget);
  });

  test('route path constants remain stable', () {
    expect(AppRoutes.home, '/home');
    expect(AppRoutes.search, '/search');
    expect(AppRoutes.profile, '/profile');
    expect(AppRoutes.homeItemDetailLocation('7'), '/home/items/7');
  });
}
