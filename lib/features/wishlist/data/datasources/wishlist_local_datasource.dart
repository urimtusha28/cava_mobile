import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../local/local_wishlist_store.dart';
import '../local/wishlist_guest_storage.dart';
import '../models/stored_wishlist_entry_model.dart';
import 'wishlist_data_source.dart';

/// Guest wishlist backed by SharedPreferences and hydrated via [ProductRepository].
class WishlistLocalDataSource implements WishlistDataSource {
  WishlistLocalDataSource(this._storage, this._productRepository);

  final WishlistGuestStorage _storage;
  final ProductRepository _productRepository;

  bool _isHydrated = false;

  Future<void> _ensureHydrated() async {
    if (_isHydrated) {
      return;
    }

    final stored = await _storage.readEntries();
    LocalWishlistStore.replaceAll(stored);
    _isHydrated = true;
  }

  Future<void> _persist() async {
    await _storage.writeEntries(LocalWishlistStore.snapshot());
  }

  Future<List<StoredWishlistEntryModel>> readStoredEntries() async {
    await _ensureHydrated();
    return LocalWishlistStore.snapshot();
  }

  Future<void> clearAll() async {
    LocalWishlistStore.clear();
    _isHydrated = true;
    await _storage.clear();
  }

  @override
  Future<List<ProductEntity>> getItems() async {
    await _ensureHydrated();

    final entries = LocalWishlistStore.snapshot();
    final products = <ProductEntity>[];
    final invalidIds = <String>[];

    for (final entry in entries) {
      final product = await _productRepository.getById(entry.productId);
      if (product == null) {
        invalidIds.add(entry.productId);
        continue;
      }
      products.add(product);
    }

    if (invalidIds.isNotEmpty) {
      for (final productId in invalidIds) {
        LocalWishlistStore.remove(productId);
      }
      await _persist();
    }

    return products;
  }

  @override
  Future<int> getCount() async {
    await _ensureHydrated();
    return LocalWishlistStore.count;
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    await _ensureHydrated();
    return LocalWishlistStore.contains(productId);
  }

  @override
  Future<void> add(ProductEntity product) async {
    await _ensureHydrated();
    if (LocalWishlistStore.contains(product.id)) {
      return;
    }

    LocalWishlistStore.addEntry(
      StoredWishlistEntryModel(
        productId: product.id,
        addedAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    await _persist();
  }

  @override
  Future<void> remove(String productId) async {
    await _ensureHydrated();
    LocalWishlistStore.remove(productId);
    await _persist();
  }

  @override
  Future<void> toggle(ProductEntity product) async {
    if (await isInWishlist(product.id)) {
      await remove(product.id);
    } else {
      await add(product);
    }
  }

  /// Test helper — resets hydration and in-memory state.
  void resetForTests() {
    LocalWishlistStore.clear();
    _isHydrated = false;
  }
}
