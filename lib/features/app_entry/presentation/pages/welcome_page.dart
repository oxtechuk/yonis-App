import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../widgets/welcome_logo_section.dart';
import '../widgets/welcome_message.dart';
import '../widgets/welcome_start_button.dart';

/// Welcome / intro screen.
///
/// Layout: blue scaffold background. A large white circle (wider than the
/// screen, anchored to the top) creates the curved white logo section. The
/// bottom arc of that circle produces the elliptical boundary seen in the
/// design. Text and CTA sit below in the blue area.
///
/// The page owns only the shared geometry (circle size/position); visuals
/// live in the composed widgets under `presentation/widgets/`.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: LayoutBuilder(
        builder: (context, constraints) {
          final screenH = constraints.maxHeight;
          final screenW = constraints.maxWidth;

          // The white circle diameter is ~1.3× the screen width so the arc
          // extends well past both sides, matching the reference image.
          final circleDiameter = screenW * 1.3;
          // How far down the circle's bottom edge sits — exactly mid-screen,
          // so the white logo section and the blue content section are two
          // equal-size halves of the viewport.
          final circleBotEdge = screenH * 0.5;
          final circleTopEdge = circleBotEdge - circleDiameter;

          return Stack(
            children: [
              // White fill covering everything above the circle's centre so
              // no blue corners can ever show on any screen size / ratio.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: circleBotEdge - circleDiameter * 0.5,
                child: const ColoredBox(color: AppColors.white),
              ),
              Positioned(
                top: circleTopEdge,
                left: (screenW - circleDiameter) / 2,
                width: circleDiameter,
                height: circleDiameter,
                child: WelcomeCircleBackdrop(size: circleDiameter),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: circleBotEdge - circleDiameter * 0.08,
                child: WelcomeLogo(width: screenW * 0.60),
              ),
              Positioned(
                top: 300,
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0, -AppSpacing.md),
                          child: WelcomeMessage(),
                        ),
                      ),
                    ),
                    const WelcomeStartButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}
