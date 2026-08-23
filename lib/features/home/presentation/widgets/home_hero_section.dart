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
  });

  final VoidCallback? onBookTap;
  final VoidCallback? onAboutTap;

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
                  Image.asset(
                    AppImages.homeHero,
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          stops: const [0.45, 1.0],
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
                          LocaleKeys.home_heroTitle.tr(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          LocaleKeys.home_heroSubtitle.tr(),
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
              child: FilledButton.icon(
                onPressed: onBookTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.calendar_month_outlined,
                    size: AppSizes.iconMd),
                label: Text(
                  LocaleKeys.home_bookConsultation.tr(),
                  style: AppTextStyles.button.copyWith(color: AppColors.white),
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
            child: ElevatedButton.icon(
              onPressed: onAboutTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                elevation: 2,
                shadowColor: Colors.black12,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.person_outline, size: AppSizes.iconMd),
              label: Text(
                LocaleKeys.home_getToKnowYounis.tr(),
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
