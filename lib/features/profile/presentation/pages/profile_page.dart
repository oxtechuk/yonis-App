import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';

/// TEMPORARY placeholder screen for verifying the navigation shell only.
/// The profile screen will become an [authenticated] route once the real
/// authentication feature exists (see route_access.dart).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(LocaleKeys.placeholders_profileTabContent.tr()));
  }
}
