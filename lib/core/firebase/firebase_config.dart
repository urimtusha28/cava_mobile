/// Firebase resource naming conventions for Phase 2 integration.
///
/// Centralizes collection and storage paths so datasources stay consistent.
abstract final class FirebaseConfig {
  /// Set to `true` after `flutterfire configure` and platform setup.
  static const bool enabled = true;

  /// When `true` together with [enabled], products load from Firestore.
  static const bool useFirestoreProducts = true;

  /// When `true` together with [enabled], categories load from Firestore.
  static const bool useFirestoreCategories = true;

  /// When `true` together with [enabled], auth uses Firebase Authentication.
  static const bool useFirebaseAuth = true;

  /// When `true` together with [enabled], orders load from Firestore.
  static const bool useFirestoreOrders = true;

  /// When `true` together with [enabled], addresses load from Firestore.
  static const bool useFirestoreAddresses = true;

  /// When `true`, Firestore category errors fall back to [CategoryMockDataSource].
  static const bool fallbackToMockCategoriesOnError = false;

  /// When `true`, Firestore errors fall back to [ProductMockDataSource].
  static const bool fallbackToMockProductsOnError = false;

  /// In-memory cache TTL for Firestore product/category reads.
  static const Duration firestoreCacheTtl = Duration(minutes: 5);

  /// Cloud Functions region for callable HTTPS (must match deploy).
  /// Default Gen1 callables without `.region()` → `us-central1`.
  static const String functionsRegion = 'us-central1';

  // Firestore collections
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String promotionsCollection = 'promotions';
  static const String bannersCollection = 'banners';
  static const String ordersCollection = 'orders';
  static const String usersCollection = 'users';
  static const String addressesSubcollection = 'addresses';
  static const String wishlistSubcollection = 'wishlist';
  static const String cartSubcollection = 'cart';

  // Firebase Storage paths
  static const String productImagesPath = 'products';
  static const String categoryImagesPath = 'categories';
  static const String bannerImagesPath = 'banners';
  static const String userAvatarsPath = 'users/avatars';
}
