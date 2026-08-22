/// Reusable animation/interaction durations.
///
/// Network/storage timeouts are NOT UI durations — they live in the network
/// configuration (DioFactory) and must not be duplicated here.
abstract final class AppDurations {
  static const Duration splash = Duration(seconds: 2);

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
