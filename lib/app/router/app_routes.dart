/// Centralized route paths. Never use raw string literals for navigation.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';

  static const String home = '/home';
  static const String services = '/services';
  static const String sessions = '/sessions';
  static const String profile = '/profile';

  static const String homeItemDetail = '/home/items/:itemId';
  static String homeItemDetailLocation(String itemId) => '/home/items/$itemId';
}
