/// Centralized route paths. Never use raw string literals for navigation.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';

  static const String home = '/home';
  static const String search = '/search';
  static const String profile = '/profile';

  static const String homeItemDetail = '/home/items/:itemId';

  static String homeItemDetailLocation(String itemId) => '/home/items/$itemId';
}
