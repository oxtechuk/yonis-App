import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_state.dart';
import '../localization/locale_keys.g.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import 'app_routes.dart';

class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Branch indices that require a signed-in patient (2 = جلساتي,
  /// 3 = حسابي). Home and services are public.
  static const Set<int> _gatedBranches = {2, 3};

  /// Tapping a gated tab while logged out always opens the login page —
  /// on every attempt, not just the first — instead of switching to a
  /// branch that can only render its sign-in gate. On a successful login
  /// the tab is then entered.
  Future<void> _onTap(BuildContext context, int index) async {
    if (_gatedBranches.contains(index) && !AuthState.instance.isLoggedIn) {
      await context.push(AppRoutes.login);
      if (AuthState.instance.isLoggedIn) {
        navigationShell.goBranch(index);
      }
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      // ColoredBox fills the transparent pixels of the rounded top
      // corners with the page background — otherwise the dark surface
      // behind (system/theme background) shows through at the corners.
      bottomNavigationBar: ColoredBox(
        color: AppColors.background,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: math.max(8, MediaQuery.paddingOf(context).bottom),
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: context.tr(LocaleKeys.navigation_profile),
                    selected: current == 3,
                    onTap: () => _onTap(context,3),
                  ),
                  _NavItem(
                    icon: Icons.content_paste_outlined,
                    activeIcon: Icons.content_paste,
                    label: context.tr(LocaleKeys.navigation_services),
                    selected: current == 1,
                    onTap: () => _onTap(context,1),
                  ),
                  _NavItem(
                    icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month,
                    label: context.tr(LocaleKeys.navigation_sessions),
                    selected: current == 2,
                    onTap: () => _onTap(context,2),
                  ),
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: context.tr(LocaleKeys.navigation_home),
                    selected: current == 0,
                    onTap: () => _onTap(context,0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFFADB5BD);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: color,
              size: selected ? 24 : 22,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
