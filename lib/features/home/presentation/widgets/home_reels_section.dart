import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

/// Placeholder reel model — replace with real data from your API.
/// [titleKey] is a localization key resolved via `.tr()` at render time.
class _Reel {
  const _Reel({required this.titleKey, required this.views});
  final String titleKey;
  final String views;
}

class HomeReelsSection extends StatelessWidget {
  const HomeReelsSection({super.key});

  static const _reels = [
    _Reel(titleKey: LocaleKeys.home_reelStress, views: '13.2K'),
    _Reel(titleKey: LocaleKeys.home_reelTrustInGod, views: '8405'),
    _Reel(titleKey: LocaleKeys.home_reelGriefStages, views: '7248'),
    _Reel(titleKey: LocaleKeys.home_reelStress, views: '13.2K'),
    _Reel(titleKey: LocaleKeys.home_reelTrustInGod, views: '8405'),
  ];

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              LocaleKeys.home_reelsTitle.tr(),
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              // RTL list scrolls from right; reverse so first item is rightmost
              reverse: isRtl,
              itemCount: _reels.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) =>
                  _ReelCard(reel: _reels[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelCard extends StatelessWidget {
  const _ReelCard({required this.reel});
  final _Reel reel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 130,
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder background (replace with real thumbnail)
            Container(color: const Color(0xFF2C2C2C)),

            // Gradient overlay at bottom
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Title badge (TikTok-style)
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              left: AppSpacing.sm,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF00E5FF), width: 3),
                      left: BorderSide(color: Color(0xFFFF1744), width: 3),
                    ),
                  ),
                  child: Text(
                    reel.titleKey.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

            // Views count at bottom
            Positioned(
              bottom: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Row(
                children: [
                  Text(
                    reel.views,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
