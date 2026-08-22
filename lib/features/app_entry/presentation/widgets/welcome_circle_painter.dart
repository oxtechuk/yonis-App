import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';

/// Paints a filled white circle with a subtle grid pattern on top.
class WelcomeCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Use the smaller dimension so the circle is always a perfect circle
    // and the grid cells are always square.
    final diameter = size.shortestSide;
    final radius = diameter / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    // Fill white circle.
    canvas.drawCircle(center, radius, Paint()..color = AppColors.white);

    // Grid lines clipped to the circle.
    canvas.save();
    canvas.clipPath(circlePath);

    final gridPaint = Paint()
      ..color = const Color(0xFFDDE1EF)
      ..strokeWidth = 0.6;

    const step = 26.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(WelcomeCirclePainter oldDelegate) => false;
}
