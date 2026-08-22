import 'package:flutter/material.dart';

/// Semantic typography scale.
///
/// Styles intentionally carry NO color: AppTheme applies them as the app
/// TextTheme so Material keeps them brightness-aware in light/dark modes.
/// Feature code needing an explicit color combines a style with a token,
/// e.g. `AppTextStyles.body.copyWith(color: AppColors.textSecondary)`.
///
/// Screen-specific styles (e.g. loginSmallTextStyle) must not be added
/// here — they belong to their feature.
abstract final class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
}

/// The application TextTheme built exclusively from [AppTextStyles].
const TextTheme kAppTextTheme = TextTheme(
  displayLarge: AppTextStyles.display,
  headlineMedium: AppTextStyles.headline,
  titleLarge: AppTextStyles.title,
  bodyMedium: AppTextStyles.body,
  bodySmall: AppTextStyles.bodySmall,
  labelMedium: AppTextStyles.label,
  labelLarge: AppTextStyles.button,
  labelSmall: AppTextStyles.caption,
);
