import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_durations.dart';
import '../widgets/splash_fade_in.dart';
import '../widgets/splash_logo.dart';

/// Brand splash: primary background with the white logo near the top.
///
/// Automatically replaces itself with the welcome screen after
/// [AppDurations.splash]. No AppBar, no controls, no stack residue.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppDurations.splash, _goToWelcome);
  }

  void _goToWelcome() {
    if (!mounted) return;
    // Replacement-style navigation: splash must not stay on the stack.
    context.go(AppRoutes.welcome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(child: SplashFadeIn(child: const SplashLogo())),
    );
  }
}
