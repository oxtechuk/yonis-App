import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const ProfileHeader(),
              const SizedBox(height: AppSpacing.sm),
              const ProfileMenu(),
            ],
          ),
        ),
      ),
    );
  }
}
