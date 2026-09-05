import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_images.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    this.onBookTap,
    this.onAboutTap,
    this.heroImageUrl,
  });

  final VoidCallback? onBookTap;
  final VoidCallback? onAboutTap;
  final String? heroImageUrl;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Hero image: 52% of screen height on phones, capped for tablets
    final imageHeight = (size.height * 0.52).clamp(260.0, 480.0);
    // Button height from design token
    final btnHeight = AppSizes.buttonHeight;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: Stack(
                children: [
                  heroImageUrl != null
                      ? Image.network(
                          heroImageUrl!,
                          width: double.infinity,
                          height: imageHeight,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          AppImages.homeHero,
                          width: double.infinity,
                          height: imageHeight,
                          fit: BoxFit.contain,
                        ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        // Full-image dark scrim so white title/subtitle
                        // stay readable on any photo from the API.
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.10),
                            Colors.black.withValues(alpha: 0.40),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: btnHeight / 2 + AppSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          context.tr(LocaleKeys.home_heroTitle),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.tr(LocaleKeys.home_heroSubtitle),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: -btnHeight / 2,
              height: btnHeight,
              child: FilledButton(
                onPressed: onBookTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr(LocaleKeys.home_bookConsultation),
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: AppSizes.iconMd,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: btnHeight / 2 + AppSpacing.sm),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            height: btnHeight,
            child: ElevatedButton(
              onPressed: onAboutTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                elevation: 2,
                shadowColor: Colors.black12,
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr(LocaleKeys.home_getToKnowYounis),
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.person_outline, size: AppSizes.iconMd),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
