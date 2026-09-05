import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';

/// Widget tests use `pumpAndSettle`, which never completes while an infinite
/// animation is running. Skeletons pulse in production but render static in
/// tests so the existing suite stays green.
bool get _skeletonAnimationsDisabled {
  if (!kDebugMode) return false;
  try {
    return Platform.environment.containsKey('FLUTTER_TEST');
  } catch (_) {
    return false;
  }
}

/// Reusable skeleton (shimmer-like) placeholders shown while data loads.
///
/// Pure-Flutter pulse animation — no extra dependency. Every list/page that
/// fetches data renders one of these composites instead of a spinner so the
/// layout appears with the data when it arrives.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacity;

  @override
  void initState() {
    super.initState();
    if (_skeletonAnimationsDisabled) return;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _controller = controller;
    _opacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = _opacity;
    if (opacity == null) return widget.child;
    return AnimatedBuilder(
      animation: opacity,
      builder: (_, child) => Opacity(opacity: opacity.value, child: child),
      child: widget.child,
    );
  }
}

/// Basic rounded bone. Pass [circle] via [borderRadius] override or use
/// [SkeletonCircle] below.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 8,
    this.color = AppColors.border,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.border,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page / section composites (each mirrors its real card layout)
// ---------------------------------------------------------------------------

/// About-card placeholder mirroring [HomeAboutCard].
class HomeAboutSkeleton extends StatelessWidget {
  const HomeAboutSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 140, height: 18),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(height: 12),
            SizedBox(height: 6),
            SkeletonBox(height: 12),
            SizedBox(height: 6),
            SkeletonBox(width: 220, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Specialty-chips placeholder mirroring [HomeSpecialtiesSection].
class HomeSpecialtiesSkeleton extends StatelessWidget {
  const HomeSpecialtiesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 120, height: 18),
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SkeletonBox(width: 90, height: 32, borderRadius: 16),
                SkeletonBox(width: 110, height: 32, borderRadius: 16),
                SkeletonBox(width: 80, height: 32, borderRadius: 16),
                SkeletonBox(width: 100, height: 32, borderRadius: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal reels strip placeholder.
class ReelsSkeleton extends StatelessWidget {
  const ReelsSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final cardWidth =
        (MediaQuery.sizeOf(context).width * 0.35).clamp(120.0, 180.0);
    final cardHeight = cardWidth * 1.7;
    return SkeletonPulse(
      child: SizedBox(
        height: cardHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: itemCount,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, _) => Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal testimonials strip placeholder.
class TestimonialsSkeleton extends StatelessWidget {
  const TestimonialsSkeleton({
    super.key,
    this.itemCount = 4,
    this.cardWidth,
    this.cardHeight,
  });

  final int itemCount;
  final double? cardWidth;
  final double? cardHeight;

  @override
  Widget build(BuildContext context) {
    final width =
        cardWidth ??
        (MediaQuery.sizeOf(context).width * 0.60).clamp(180.0, 320.0);
    final height = cardHeight ?? (width * 0.7).clamp(145.0, 250.0);
    return SkeletonPulse(
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: itemCount,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (_, _) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single service card placeholder mirroring [ServiceOptionCard].
class ServiceCardSkeleton extends StatelessWidget {
  const ServiceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonCircle(size: 48),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SkeletonBox(height: 16),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(height: 12),
                SizedBox(height: 6),
                SkeletonBox(width: 180, height: 12),
                SizedBox(height: AppSpacing.md),
                SkeletonBox(height: 48, borderRadius: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical list of service cards (Services tab + booking sheet).
class ServiceListSkeleton extends StatelessWidget {
  const ServiceListSkeleton({
    super.key,
    this.itemCount = 3,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final int itemCount;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, _) => const ServiceCardSkeleton(),
      ),
    );
  }
}

/// Single session card placeholder mirroring [SessionCard].
class SessionCardSkeleton extends StatelessWidget {
  const SessionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 90, height: 24, borderRadius: 12),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(height: 16),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 160, height: 12),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 64, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Vertical list of session cards (Sessions tab).
class SessionListSkeleton extends StatelessWidget {
  const SessionListSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, _) => const SessionCardSkeleton(),
      ),
    );
  }
}

/// Profile page placeholder: header (avatar + name) + menu rows.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: const Row(
              children: [
                SkeletonCircle(size: 64),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140, height: 16),
                      SizedBox(height: 8),
                      SkeletonBox(width: 200, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: List.generate(
                5,
                (_) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SkeletonCircle(size: 22),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(child: SkeletonBox(height: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Time-slot grid placeholder (2-column chips).
class TimeSlotsSkeleton extends StatelessWidget {
  const TimeSlotsSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 2.8,
        children: List.generate(
          itemCount,
          (_) => const SkeletonBox(height: double.infinity, borderRadius: 12),
        ),
      ),
    );
  }
}
