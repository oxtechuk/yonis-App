import 'package:flutter/material.dart';

import '../../../../app/styles/app_radius.dart';
import 'welcome_circle_painter.dart';

/// White circular backdrop with the subtle grid pattern.
///
/// Sized by [size] (its full circle diameter); the page positions it so only
/// the bottom arc is visible inside the viewport.
class WelcomeCircleBackdrop extends StatelessWidget {
  const WelcomeCircleBackdrop({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WelcomeCirclePainter(),
      child: SizedBox.square(dimension: size),
    );
  }
}

/// The splash image centered inside the visible part of the white section.
class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({
    super.key,
    required this.width,
    this.imageUrl,
  });

  final double width;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: ClipRRect(
        borderRadius: AppRadius.allLg,
        child: Image.network(
          url,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
