import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_spacing.dart';

/// TEMPORARY placeholder screen.
///
/// Exists only to verify the StatefulShellRoute.indexedStack foundation
/// (tab state preservation + nested navigation inside a branch). Replace
/// with the real home feature; do not build on this code.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(LocaleKeys.placeholders_homeTabContent.tr()),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LocaleKeys.placeholders_counterValue.tr(
              namedArgs: {'value': '$_counter'},
            ),
          ),
          FilledButton(
            onPressed: () => setState(() => _counter++),
            child: Text(LocaleKeys.placeholders_increment.tr()),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonal(
            onPressed: () =>
                context.push(AppRoutes.homeItemDetailLocation('demo-42')),
            child: Text(LocaleKeys.placeholders_openItemDetails.tr()),
          ),
        ],
      ),
    );
  }
}
