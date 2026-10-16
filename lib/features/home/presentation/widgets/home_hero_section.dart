import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_durations.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../domain/entities/home_slider.dart';

class HomeHeroSection extends StatefulWidget {
  const HomeHeroSection({
    super.key,
    required this.sliders,
    this.onBookTap,
    this.onAboutTap,
  });

  final List<HomeSlider> sliders;
  final VoidCallback? onBookTap;
  final VoidCallback? onAboutTap;

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection> {
  static const Duration _autoSlideInterval = Duration(seconds: 5);

  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _syncAutoSlideTimer();
  }

  @override
  void didUpdateWidget(covariant HomeHeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sliders.length != widget.sliders.length) {
      if (_currentIndex >= widget.sliders.length) {
        _currentIndex = 0;
      }
      _syncAutoSlideTimer();
    }
  }

  void _syncAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    if (widget.sliders.length <= 1) return;
    _autoSlideTimer = Timer.periodic(_autoSlideInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentIndex + 1) % widget.sliders.length;
      _pageController.animateToPage(
        nextPage,
        duration: AppDurations.normal,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sliders = widget.sliders;
    if (sliders.isEmpty) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.sizeOf(context);
    // Hero image: 52% of screen height on phones, capped for tablets
    final imageHeight = (size.height * 0.52).clamp(260.0, 480.0);
    // Button height from design token
    final btnHeight = AppSizes.buttonHeight;
    final hasMultipleSliders = sliders.length > 1;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: SizedBox(
                width: double.infinity,
                height: imageHeight,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: sliders.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        final slider = sliders[index];
                        return _HeroSlideItem(
                          imageUrl: slider.imageUrl,
                          title: slider.title,
                          subtitle: slider.subtitle,
                          imageHeight: imageHeight,
                          bottomContentOffset: hasMultipleSliders
                              ? btnHeight / 2 + AppSpacing.xl + AppSpacing.sm
                              : btnHeight / 2 + AppSpacing.lg,
                        );
                      },
                    ),
                    if (hasMultipleSliders)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: btnHeight / 2 + AppSpacing.md,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            sliders.length,
                            (index) {
                              final isSelected = index == _currentIndex;
                              return AnimatedContainer(
                                duration: AppDurations.fast,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: isSelected ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.white.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: -btnHeight / 2,
              height: btnHeight,
              child: FilledButton(
                onPressed: widget.onBookTap,
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
      ],
    );
  }
}

class _HeroSlideItem extends StatelessWidget {
  const _HeroSlideItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.imageHeight,
    required this.bottomContentOffset,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final double imageHeight;
  final double bottomContentOffset;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = imageUrl.trim().isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasNetworkImage)
          Image.network(
            imageUrl,
            width: double.infinity,
            height: imageHeight,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AppColors.primary),
          )
        else
          const ColoredBox(color: AppColors.primary),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.45),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: bottomContentOffset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              if (title.isNotEmpty && subtitle.isNotEmpty)
                const SizedBox(height: AppSpacing.sm),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withValues(alpha: 0.88),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
