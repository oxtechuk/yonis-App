import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../cubit/doctor_profile_cubit.dart';
import '../cubit/reels_cubit.dart';
import '../cubit/services_cubit.dart';
import '../cubit/testimonials_cubit.dart';
import '../widgets/book_service_bottom_sheet.dart';
import '../widgets/home_about_card.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_reels_section.dart';
import '../widgets/home_specialties_section.dart';
import '../widgets/home_testimonials_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DoctorProfileCubit>(
          create: (_) => getIt<DoctorProfileCubit>()..load(),
        ),
        BlocProvider<ServicesCubit>(
          create: (_) => getIt<ServicesCubit>()..load('clinic'),
        ),
        BlocProvider<ReelsCubit>(
          create: (_) => getIt<ReelsCubit>()..load(),
        ),
        BlocProvider<TestimonialsCubit>(
          create: (_) => getIt<TestimonialsCubit>()..load(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Builder(
            builder: (innerContext) => SingleChildScrollView(
              child: Column(
                children: [
                  // Hero is static (localized strings + fallback asset), so it
                  // renders instantly. The network image swaps in with the
                  // data; only bio/specialties wait behind skeletons.
                  BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
                    builder: (context, state) {
                      final heroImage = state is DoctorProfileLoaded
                          ? state.profile.heroImage
                          : null;
                      return HomeHeroSection(
                        heroImageUrl: heroImage,
                        onBookTap: () =>
                            BookServiceBottomSheet.show(innerContext),
                        onAboutTap: () {
                          // TODO: navigate to about
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
                    builder: (context, state) {
                      return switch (state) {
                        DoctorProfileInitial() || DoctorProfileLoading() =>
                          const HomeAboutSkeleton(),
                        DoctorProfileLoaded(:final profile) =>
                          HomeAboutCard(bio: profile.bio),
                        DoctorProfileError() => const HomeAboutCard(),
                      };
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
                    builder: (context, state) {
                      return switch (state) {
                        DoctorProfileInitial() || DoctorProfileLoading() =>
                          const HomeSpecialtiesSkeleton(),
                        DoctorProfileLoaded(:final profile) =>
                          HomeSpecialtiesSection(
                            specialties: profile.specialties,
                          ),
                        DoctorProfileError() =>
                          const HomeSpecialtiesSection(),
                      };
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const HomeReelsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  const HomeTestimonialsSection(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
