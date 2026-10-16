import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../home/presentation/cubit/services_cubit.dart';
import '../../domain/entities/splash_config.dart';
import '../cubit/splash_cubit.dart';
import '../widgets/welcome_logo_section.dart';
import '../widgets/welcome_message.dart';
import '../widgets/welcome_start_button.dart';

/// Dynamic splash screen powered by `GET /api/splash`.
///
/// - When `is_enabled` is `false` (or the request fails), immediately replaces
///   itself with [AppRoutes.home].
/// - When `is_enabled` is `true`, renders the API `image_url`, `title`,
///   `subtitle`, and the "Start Now" CTA, and auto-navigates to [AppRoutes.home]
///   after `duration` seconds.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashCubit _splashCubit;
  StreamSubscription<SplashState>? _subscription;
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Warm the services cache so the home hero "Book" sheet usually opens
    // to a cache hit instead of racing the network on first tap.
    unawaited(getIt<ServicesCubit>().load('online'));
    unawaited(getIt<ServicesCubit>().preload('clinic'));

    _splashCubit = getIt<SplashCubit>();
    _subscription = _splashCubit.stream.listen(_onSplashStateChanged);
    unawaited(_splashCubit.load());
  }

  void _goToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _timer?.cancel();
    context.go(AppRoutes.home);
  }

  void _onSplashStateChanged(SplashState state) {
    if (!mounted) return;
    if (state is SplashLoaded) {
      if (!state.config.isEnabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _goToHome());
        return;
      }
      _timer?.cancel();
      _timer = Timer(state.config.duration, _goToHome);
    } else if (state is SplashError) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToHome());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _splashCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>.value(
      value: _splashCubit,
      child: BlocBuilder<SplashCubit, SplashState>(
        builder: (context, state) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: switch (state) {
                SplashLoaded(:final config) when config.isEnabled =>
                  _SplashContent(
                    config: config,
                    onStartNow: _goToHome,
                  ),
                _ => const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
              },
            ),
          );
        },
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.config,
    required this.onStartNow,
  });

  final SplashConfig config;
  final VoidCallback onStartNow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenH = constraints.maxHeight;
        final screenW = constraints.maxWidth;

        final circleDiameter = screenW * 1.3;
        final circleBotEdge = screenH * 0.5;
        final circleTopEdge = circleBotEdge - circleDiameter;

        return Stack(
          children: [
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
              height: circleBotEdge - circleDiameter * 0.0009,
              child: WelcomeLogo(
                width: screenW * 0.70,
                imageUrl: config.imageUrl,
              ),
            ),
            Positioned(
              top: circleBotEdge,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -AppSpacing.md),
                        child: WelcomeMessage(
                          title: config.title,
                          subtitle: config.subtitle,
                        ),
                      ),
                    ),
                  ),
                  WelcomeStartButton(onPressed: onStartNow),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
