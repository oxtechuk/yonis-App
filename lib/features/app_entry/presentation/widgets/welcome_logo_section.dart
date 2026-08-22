import 'package:flutter/material.dart';

import '../../../../app/styles/app_images.dart';
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

/// The brand logo centered inside the visible part of the white section.
class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(AppImages.mainLogo, width: width, fit: BoxFit.contain),
    );
  }
}
