import 'package:flutter/material.dart';

import '../../../../app/styles/app_images.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Logo: 55% of screen width, capped for tablets
    final logoWidth = (size.width * 0.55).clamp(160.0, 360.0);
    // Top offset: 18% of screen height so it stays proportional
    final topOffset = size.height * 0.18;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: topOffset),
        child: Image.asset(
          AppImages.splashLogo,
          width: logoWidth,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
