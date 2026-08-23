import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../widgets/home_about_card.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_reels_section.dart';
import '../widgets/home_specialties_section.dart';
import '../widgets/home_testimonials_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeHeroSection(
                onBookTap: () {
                  // TODO: navigate to booking
                },
                onAboutTap: () {
                  // TODO: navigate to about
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              const HomeAboutCard(),
              const SizedBox(height: AppSpacing.lg),
              const HomeSpecialtiesSection(),
              const SizedBox(height: AppSpacing.lg),
              const HomeReelsSection(),
              const SizedBox(height: AppSpacing.lg),
              const HomeTestimonialsSection(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
