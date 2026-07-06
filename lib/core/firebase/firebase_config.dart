/// Firebase resource naming conventions for Phase 2 integration.
///
/// Centralizes collection and storage paths so datasources stay consistent.
abstract final class FirebaseConfig {
  /// Set to `true` after `flutterfire configure` and platform setup.
  static const bool enabled = false;

  /// When `true` together with [enabled], products load from Firestore.
  /// Default remains mock — do not enable until Firebase is initialized.
  static const bool useFirestoreProducts = false;

  // Firestore collections
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String promotionsCollection = 'promotions';
  static const String bannersCollection = 'banners';
  static const String ordersCollection = 'orders';
  static const String usersCollection = 'users';

  // Firebase Storage paths
  static const String productImagesPath = 'products';
  static const String categoryImagesPath = 'categories';
  static const String bannerImagesPath = 'banners';
  static const String userAvatarsPath = 'users/avatars';
}
