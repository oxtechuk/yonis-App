import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_radius.dart';
import '../styles/app_sizes.dart';
import '../styles/app_text_styles.dart';

/// Application theme assembled ONLY from centralized design tokens
/// (AppColors, AppTextStyles, AppRadius, AppSizes). No visual values are
/// redefined here.
abstract final class AppTheme {
  static ThemeData light() => _theme(Brightness.light);

  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? AppColors.background
          : null,
      textTheme: kAppTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: brightness == Brightness.light
            ? AppColors.textPrimary
            : null,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, AppSizes.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        constraints: BoxConstraints.tight(
          const Size.fromHeight(AppSizes.inputHeight),
        ),
        border: const OutlineInputBorder(borderRadius: AppRadius.allMd),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSizes.bottomBarHeight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTextStyles.label.copyWith(color: colorScheme.onSurface)
              : AppTextStyles.label.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
