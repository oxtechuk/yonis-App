/// Spacing scale for layout paddings, gaps and margins.
///
/// Use semantic steps instead of magic numbers. Values are in logical
/// pixels. Extend only when a genuine design token is needed — no
/// arbitrary values such as spacing17.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
