import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class HomeTestimonialsSection extends StatelessWidget {
  const HomeTestimonialsSection({super.key});

  static const _images = <String>[];

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    // Card width ~60% of screen, height by ratio; capped for tablets
    final cardWidth =
        (MediaQuery.sizeOf(context).width * 0.60).clamp(180.0, 320.0);
    final cardHeight = cardWidth * 0.75;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              context.tr(LocaleKeys.home_testimonialsTitle),
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: cardHeight,
            child: _images.isEmpty
                ? _buildPlaceholderList(
                    reverse: isRtl,
                    cardWidth: cardWidth,
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: isRtl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    itemCount: _images.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (_, i) => _TestimonialCard(
                      imagePath: _images[i],
                      width: cardWidth,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderList(
      {required bool reverse, required double cardWidth}) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      reverse: reverse,
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (_, __) =>
          _TestimonialCard(imagePath: null, width: cardWidth),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.imagePath, required this.width});
  final String? imagePath;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: width,
        child: imagePath != null
            ? Image.asset(imagePath!, fit: BoxFit.cover)
            : Container(
                color: const Color(0xFFE5E7EB),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
              ),
      ),
    );
  }
}
