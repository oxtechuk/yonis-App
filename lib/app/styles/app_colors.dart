import 'package:flutter/material.dart';

/// Application color tokens.
///
/// The single source of truth for reusable application colors. Feature code
/// must not declare raw Color(0xFF...) values that belong to the design
/// system; one-off colors genuinely specific to a single screen may stay
/// local to that screen.
///
/// Keep this palette minimal — extend only when a real design requirement
/// appears.
abstract final class AppColors {
  /// Brand primary (drives the Material color scheme seed).
  static const Color primary = Color(0xFF4055A5);

  /// Brand secondary accent (gold) — part of the official brand palette.
  static const Color secondary = Color(0xFFCCA830);

  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Brand white — surfaces that must stay white regardless of theme.
  static const Color white = Color(0xFFFFFFFF);

  /// Neutral scaffold background (light mode).
  static const Color background = Color(0xFFF6F7FB);

  /// Card/sheet surface (light mode).
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  static const Color border = Color(0xFFE5E7EB);

  /// Tinted fill behind filled text fields (light mode).
  static const Color fieldFill = Color(0xFFF3F4F6);

  /// Soft indigo tint used by informational cards (light mode).
  static const Color cardTint = Color(0xFFEAECF8);
}
