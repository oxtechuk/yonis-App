import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../domain/entities/testimonial.dart';
import '../cubit/testimonials_cubit.dart';

/// Client reviews strip on the home page, backed by `GET /api/reviews`.
///
/// Shows a [TestimonialsSkeleton] while loading, real review cards once the
/// data arrives, and a compact error line with retry on failure. Hidden
/// entirely when the backend returns no reviews.
class HomeTestimonialsSection extends StatelessWidget {
  const HomeTestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final cardWidth =
        (MediaQuery.sizeOf(context).width * 0.60).clamp(180.0, 320.0);
    final cardHeight = (cardWidth * 0.7).clamp(145.0, 250.0);

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
          BlocBuilder<TestimonialsCubit, TestimonialsState>(
            builder: (context, state) {
              return switch (state) {
                TestimonialsInitial() || TestimonialsLoading() =>
                  TestimonialsSkeleton(
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                TestimonialsLoaded(:final testimonials) =>
                  _buildLoaded(context, testimonials, cardWidth, cardHeight),
                TestimonialsError() => _buildError(context, cardHeight),
              };
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    List<Testimonial> testimonials,
    double cardWidth,
    double cardHeight,
  ) {
    if (testimonials.isEmpty) return const SizedBox.shrink();
    final isRtl = context.locale.languageCode == 'ar';
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: isRtl,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: testimonials.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, i) => _TestimonialCard(
          testimonial: testimonials[i],
          width: cardWidth,
          height: cardHeight,
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, double cardHeight) {
    return SizedBox(
      height: cardHeight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(LocaleKeys.errors_general),
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () =>
                    context.read<TestimonialsCubit>().load(),
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                label: Text(
                  context.tr(LocaleKeys.common_retry),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.testimonial,
    required this.width,
    required this.height,
  });

  final Testimonial testimonial;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;
    final name = testimonial.nameFor(languageCode);
    final content = testimonial.contentFor(languageCode);

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(url: testimonial.avatar),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _Stars(rating: testimonial.rating),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: url.isEmpty
            ? Container(
                color: AppColors.cardTint,
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.textSecondary,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: AppColors.border);
                },
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.cardTint,
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.clamp(0, 5);
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: filled ? AppColors.secondary : AppColors.border,
        );
      }),
    );
  }
}
