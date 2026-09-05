import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../cubit/reels_cubit.dart';
import '../../domain/entities/reel.dart';
import 'reel_video_player_dialog.dart';

class HomeReelsSection extends StatelessWidget {
  const HomeReelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final cardWidth =
        (MediaQuery.sizeOf(context).width * 0.35).clamp(120.0, 180.0);
    final cardHeight = cardWidth * 1.7;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              context.tr(LocaleKeys.home_reelsTitle),
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<ReelsCubit, ReelsState>(
            builder: (context, state) {
              if (state is ReelsInitial || state is ReelsLoading) {
                return const ReelsSkeleton();
              }
              if (state is ReelsLoaded) {
                final reels = state.reels;
                if (reels.isEmpty) {
                  return _buildEmptyPlaceholder(cardWidth, cardHeight, isRtl);
                }
                return _buildReelList(reels, cardWidth, cardHeight, isRtl);
              }
              if (state is ReelsError) {
                return _buildErrorPlaceholder(cardWidth, cardHeight, context, isRtl);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(double cardWidth, double cardHeight, bool isRtl) {
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        reverse: isRtl,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, __) => _buildPlaceholderCard(cardWidth, cardHeight),
      ),
    );
  }

  Widget _buildErrorPlaceholder(double cardWidth, double cardHeight, BuildContext context, bool isRtl) {
    return SizedBox(
      height: cardHeight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            context.tr(LocaleKeys.errors_general),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReelList(
    List<Reel> reels,
    double cardWidth,
    double cardHeight,
    bool isRtl,
  ) {
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        reverse: isRtl,
        itemCount: reels.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final reel = reels[index];
          return _ReelCard(reel: reel, width: cardWidth);
        },
      ),
    );
  }

  Widget _buildPlaceholderCard(double cardWidth, double cardHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Container(color: const Color(0xFF2C2C2C)),
      ),
    );
  }
}

class _ReelCard extends StatelessWidget {
  const _ReelCard({required this.reel, required this.width});
  final Reel reel;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('[reels] tap id=${reel.id} url="${reel.videoUrl}"');
        showReelVideoDialog(context, reel);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: const Color(0xFF2C2C2C)),
              if (reel.thumbnailUrl.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    reel.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: const Color(0xFF2C2C2C));
                    },
                  ),
                )
              else
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                left: AppSpacing.sm,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF00E5FF), width: 3),
                        left: BorderSide(color: Color(0xFFFF1744), width: 3),
                      ),
                    ),
                    child: Text(
                      reel.titleEn ?? reel.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: AppSpacing.sm,
                left: AppSpacing.sm,
                child: Row(
                  children: [
                    Text(
                      '${reel.duration}s',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}