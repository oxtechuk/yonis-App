import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class HomeTestimonialsSection extends StatelessWidget {
  const HomeTestimonialsSection({super.key});

  /// Add your testimonial image paths here.
  static const _images = <String>[
    // 'assets/images/testimonial_1.png',
    // 'assets/images/testimonial_2.png',
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
              LocaleKeys.home_testimonialsTitle.tr(),
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: _images.isEmpty
                ? _buildPlaceholderList(reverse: isRtl)
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: isRtl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: _images.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (_, i) =>
                        _TestimonialCard(imagePath: _images[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderList({required bool reverse}) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      reverse: reverse,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (_, _) => const _TestimonialCard(imagePath: null),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.imagePath});
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 220,
        height: 200,
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
