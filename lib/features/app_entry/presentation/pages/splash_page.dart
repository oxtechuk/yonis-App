import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_durations.dart';
import '../../../home/presentation/cubit/services_cubit.dart';
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
    // Warm the services cache here (2s splash + welcome dwell) so the
    // home hero "Book" sheet usually opens to a cache hit instead of
    // racing the network on first tap. Fire-and-forget: failures just
    // leave the cache empty and the sheet falls back to skeleton+retry.
    unawaited(getIt<ServicesCubit>().load('online'));
    unawaited(getIt<ServicesCubit>().preload('clinic'));
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(child: SplashFadeIn(child: const SplashLogo())),
      ),
    );
  }
}
