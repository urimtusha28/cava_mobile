abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String messages = '/messages';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String checkout = '/checkout';
  static const String cardPayment = '/card-payment';
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

  /// Owner shell (protected by role redirect).
  static const String owner = '/owner';
  static const String ownerDashboard = '/owner';
  static const String ownerOrders = '/owner/orders';
  static const String ownerAnalytics = '/owner/analytics';
  static const String ownerProducts = '/owner/products';
  static const String ownerSupport = '/owner/support';
  static const String ownerProfile = '/owner/profile';
  static const String ownerSettingsUsers = '/owner/settings/users';
  static const String ownerSettingsStoreBanner = '/owner/settings/store-banner';
  static const String ownerSettingsLegal = '/owner/settings/legal';

  static String category(String id) => '/category/$id';
  static String product(String id) => '/product/$id';
  static String ownerSupportChat(String id) => '/owner/support/$id';

  static bool isOwnerPath(String location) =>
      location == owner || location.startsWith('$owner/');
}
