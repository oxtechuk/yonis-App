import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';

/// TEMPORARY placeholder screen.
///
/// Receives a strongly-typed path parameter (no untyped dynamic extras)
/// and exists to verify nested navigation inside the Home branch of the
/// StatefulShellRoute (the stack must survive tab switches). Remove with
/// the home placeholder.
class HomeItemDetailPage extends StatelessWidget {
  const HomeItemDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(LocaleKeys.placeholders_itemDetailTitle))),
      body: Center(
        child: Text(
          context.tr(
            LocaleKeys.placeholders_itemDetailOf,
            namedArgs: {'itemId': itemId},
          ),
        ),
      ),
    );
  }
}
