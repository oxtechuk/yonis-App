import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_images.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

/// Full-width hero image with the primary CTA button straddling its
/// bottom edge (half inside the image, half outside).
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    this.onBookTap,
    this.onAboutTap,
  });

  final VoidCallback? onBookTap;
  final VoidCallback? onAboutTap;

  static const double _btnHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.sizeOf(context).height * 0.52;

    return Column(
      children: [
        // ── Image + straddling button ─────────────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Hero image — extra bottom padding so button doesn't cover text
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
                  // Title + subtitle — bottom offset leaves room for button
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: _btnHeight / 2 + AppSpacing.lg,
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
            // Button centered on the image bottom edge
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: -_btnHeight / 2,
              height: _btnHeight,
              child: FilledButton.icon(
                onPressed: onBookTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_outlined, size: 20),
                label: Text(
                  LocaleKeys.home_bookConsultation.tr(),
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Space for the half of the button that hangs below the image
        const SizedBox(height: _btnHeight / 2 + AppSpacing.sm),

        // ── Secondary button ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            height: _btnHeight,
            child: ElevatedButton.icon(
              onPressed: onAboutTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              icon: const Icon(Icons.person_outline, size: 20),
              label: Text(
                LocaleKeys.home_getToKnowYounis.tr(),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
