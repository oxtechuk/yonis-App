import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';

/// TEMPORARY placeholder screen for verifying the navigation shell only.
/// Replace with the real search feature; do not build on this code.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.tr(LocaleKeys.placeholders_searchTabContent)));
  }
}
