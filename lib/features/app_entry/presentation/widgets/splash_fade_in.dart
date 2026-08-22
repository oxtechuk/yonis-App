import 'package:flutter/material.dart';

import '../../../../app/styles/app_durations.dart';

/// Fades its child in using [AppDurations.slow].
class SplashFadeIn extends StatefulWidget {
  const SplashFadeIn({super.key, required this.child});

  final Widget child;

  @override
  State<SplashFadeIn> createState() => _SplashFadeInState();
}

class _SplashFadeInState extends State<SplashFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.slow)
      ..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}
