/// Shared application dimensions that are part of the design system
/// (consistent control heights and icon sizes).
///
/// One-off widths/heights of a specific screen stay local to that screen —
/// only genuinely reused dimensions belong here.
abstract final class AppSizes {
  /// Standard interactive control height (buttons).
  static const double buttonHeight = 48;

  /// Standard text-field height.
  static const double inputHeight = 52;

  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;

  /// Height of the persistent bottom navigation bar content
  /// (system gesture inset is added on top by SafeArea).
  static const double bottomBarHeight = 56;
}
