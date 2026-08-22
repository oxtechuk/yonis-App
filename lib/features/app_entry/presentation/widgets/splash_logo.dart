import 'package:flutter/material.dart';

import '../../../../app/styles/app_images.dart';

/// The splash brand logo: pinned below the safe area, responsive width.
class SplashLogo extends StatelessWidget {
  /// Screen-local layout logic (not shared design tokens): the logo scales
  /// with available width but never grows beyond the cap.
  static const double _maxLogoWidth = 420;
  static const double _widthFactor = 0.8;

  /// Distance between the safe area's top edge and the logo.
  static const double _topOffset = 140;

  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: _topOffset),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double logoWidth = (constraints.maxWidth * _widthFactor)
                .clamp(0.0, _maxLogoWidth);
            return Image.asset(
              AppImages.splashLogo,
              width: logoWidth,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}
