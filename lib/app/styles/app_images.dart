/// Centralized asset path constants.
///
/// Feature code must never inline `assets/...` paths inside pages; reference
/// these constants instead so renames happen in exactly one place.
abstract final class AppImages {
  /// White brand artwork, designed to sit on the primary blue background.
  static const String splashLogo = 'assets/images/white_logo.png';

  /// Full-color brand lockup, designed for light/white surfaces.
  static const String mainLogo = 'assets/images/colored_logo.png';
}
