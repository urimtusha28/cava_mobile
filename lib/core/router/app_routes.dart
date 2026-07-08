abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String messages = '/messages';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String addresses = '/addresses';
  static const String help = '/help';
  static const String about = '/about';
  static const String language = '/language';
  static const String currency = '/currency';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String search = '/search';

  static String category(String id) => '/category/$id';
  static String product(String id) => '/product/$id';
}
