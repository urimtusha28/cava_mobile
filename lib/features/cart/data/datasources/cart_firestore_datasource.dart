import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../mappers/cart_firestore_mapper.dart';
import '../models/stored_cart_item_model.dart';
import 'cart_data_source.dart';

/// Firestore cart at `users/{uid}/cart/{productId}`.
///
/// Mutations use **document-scoped** reads/writes so add/update succeed even when
/// a full collection list query is denied by security rules (same class of issue
/// as categories `collection.get()` without matching filters).
class CartFirestoreDataSource implements CartDataSource {
  CartFirestoreDataSource(
    this._firestore,
    this._authRepository,
    this._productRepository,
  );

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final ProductRepository _productRepository;

  final List<CartItemEntity> _items = [];
  final Map<String, StoredCartItemModel> _metadataByProductId = {};
  bool _isHydrated = false;
  bool _collectionHydrated = false;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .collection(FirebaseConfig.cartSubcollection);
  }

  Future<String> _requireUserId() async {
    final userId = await _authRepository.getCurrentUserId();
    if (userId == null || userId.trim().isEmpty) {
      throw StateError('Cart requires an authenticated user.');
    }
    return userId;
  }

  Future<List<StoredCartItemModel>> readStoredEntries() async {
    final userId = await _requireUserId();
    final snapshot = await _collection(userId).get();
    final entries = <StoredCartItemModel>[];

    for (final doc in snapshot.docs) {
      final entry = CartFirestoreMapper.fromDocument(doc.id, doc.data());
      if (entry != null) {
        entries.add(entry);
      }
    }

    return entries;
  }

  /// Reads only the given product docs (no collection list query).
  Future<List<StoredCartItemModel>> readStoredEntriesForProductIds(
    Iterable<String> productIds,
  ) async {
    final userId = await _requireUserId();
    final entries = <StoredCartItemModel>[];

    for (final productId in productIds) {
      if (productId.trim().isEmpty) {
        continue;
      }
      final doc = await _collection(userId).doc(productId).get();
      if (!doc.exists) {
        continue;
      }
      final data = doc.data();
      if (data == null) {
        continue;
      }
      final entry = CartFirestoreMapper.fromDocument(doc.id, data);
      if (entry != null) {
        entries.add(entry);
      }
    }

    return entries;
  }

  Future<void> replaceAllEntries(List<StoredCartItemModel> entries) async {
    final userId = await _requireUserId();
    final mergedIds = entries.map((entry) => entry.productId).toSet();

    // Prefer document deletes for known ids to avoid collection list when possible.
    // Collection list is still used to prune orphan cloud-only docs.
    try {
      final snapshot = await _collection(userId).get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        if (!mergedIds.contains(doc.id)) {
          batch.delete(doc.reference);
        }
      }

      for (final entry in entries) {
        batch.set(
          _collection(userId).doc(entry.productId),
          CartFirestoreMapper.toFirestore(entry),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }
      // Fallback: upsert guest/merged docs by id without listing the collection.
      for (final entry in entries) {
        await _collection(userId).doc(entry.productId).set(
              CartFirestoreMapper.toFirestore(entry),
              SetOptions(merge: true),
            );
      }
    }

    invalidateCache();
  }

  void invalidateCache() {
    _items.clear();
    _metadataByProductId.clear();
    _isHydrated = false;
    _collectionHydrated = false;
  }

  Future<void> _hydrateDocument(String productId) async {
    if (_metadataByProductId.containsKey(productId)) {
      return;
    }

    final userId = await _requireUserId();
    final doc = await _collection(userId).doc(productId).get();
    if (!doc.exists) {
      return;
    }

    final data = doc.data();
    if (data == null) {
      return;
    }

    final entry = CartFirestoreMapper.fromDocument(doc.id, data);
    if (entry == null) {
      await _collection(userId).doc(doc.id).delete();
      return;
    }

    final product = await _productRepository.getById(entry.productId);
    if (product == null) {
      await _collection(userId).doc(doc.id).delete();
      return;
    }

    _items.removeWhere((item) => item.product.id == productId);
    _items.add(CartItemEntity(product: product, quantity: entry.quantity));
    _metadataByProductId[entry.productId] = entry;
  }

  @override
  Future<void> loadPersistedCart() async {
    if (_isHydrated && _collectionHydrated) {
      return;
    }

    final userId = await _requireUserId();

    try {
      final snapshot = await _collection(userId).get();
      final rebuilt = <CartItemEntity>[];
      final validEntries = <StoredCartItemModel>[];

      for (final doc in snapshot.docs) {
        final entry = CartFirestoreMapper.fromDocument(doc.id, doc.data());
        if (entry == null) {
          await _collection(userId).doc(doc.id).delete();
          continue;
        }

        final product = await _productRepository.getById(entry.productId);
        if (product == null) {
          await _collection(userId).doc(doc.id).delete();
          continue;
        }

        rebuilt.add(CartItemEntity(product: product, quantity: entry.quantity));
        validEntries.add(entry);
        _metadataByProductId[entry.productId] = entry;
      }

      _items
        ..clear()
        ..addAll(rebuilt);
      _isHydrated = true;
      _collectionHydrated = true;
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }
      // Collection list denied — keep any document-scoped cache; mark hydrated
      // so mutate paths that use document reads can proceed.
      _isHydrated = true;
      _collectionHydrated = false;
    }
  }

  @override
  List<CartItemEntity> getItems() => List<CartItemEntity>.unmodifiable(_items);

  @override
  int getItemCount() =>
      _items.fold(0, (total, item) => total + item.quantity);

  @override
  double getSubtotal() =>
      _items.fold(0, (total, item) => total + item.lineTotal);

  @override
  double getDiscount() => 0;

  @override
  double getVat() => 0;

  @override
  double getShipping() => 0;

  @override
  double getTotal() => getSubtotal() + getVat() + getShipping();

  @override
  Future<void> addProduct(ProductEntity product, {int quantity = 1}) async {
    if (quantity <= 0) {
      return;
    }

    // Document-scoped hydrate — no collection list required for a successful add.
    await _hydrateDocument(product.id);

    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final nextQuantity = _items[index].quantity + quantity;
      _items[index] = CartItemEntity(product: product, quantity: nextQuantity);
      _metadataByProductId[product.id] = StoredCartItemModel(
        productId: product.id,
        quantity: nextQuantity,
        selectedVariant: _metadataByProductId[product.id]?.selectedVariant,
        addedAt: _metadataByProductId[product.id]?.addedAt ??
            DateTime.now().toUtc().toIso8601String(),
      );
    } else {
      _items.add(CartItemEntity(product: product, quantity: quantity));
      _metadataByProductId[product.id] = StoredCartItemModel(
        productId: product.id,
        quantity: quantity,
        selectedVariant: null,
        addedAt: DateTime.now().toUtc().toIso8601String(),
      );
    }

    _isHydrated = true;
    await _persistProduct(product.id);
  }

  @override
  Future<void> updateQuantity(int index, int quantity) async {
    if (index < 0 || index >= _items.length) {
      return;
    }

    if (quantity <= 0) {
      await removeAt(index);
      return;
    }

    final productId = _items[index].product.id;
    _items[index] = CartItemEntity(
      product: _items[index].product,
      quantity: quantity,
    );
    final meta = _metadataByProductId[productId];
    _metadataByProductId[productId] = StoredCartItemModel(
      productId: productId,
      quantity: quantity,
      selectedVariant: meta?.selectedVariant,
      addedAt: meta?.addedAt ?? DateTime.now().toUtc().toIso8601String(),
    );

    await _persistProduct(productId);
  }

  @override
  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final productId = _items[index].product.id;
    _items.removeAt(index);
    _metadataByProductId.remove(productId);
    await _deleteProduct(productId);
  }

  @override
  Future<void> clear() async {
    final productIds = _items.map((item) => item.product.id).toList();
    _items.clear();
    _metadataByProductId.clear();
    _isHydrated = true;
    await _clearAll(productIds);
  }

  Future<void> _persistProduct(String productId) async {
    final entry = _metadataByProductId[productId];
    if (entry == null) {
      return;
    }

    final userId = await _requireUserId();
    await _collection(userId).doc(productId).set(
          CartFirestoreMapper.toFirestore(entry),
          SetOptions(merge: true),
        );
  }

  Future<void> _deleteProduct(String productId) async {
    final userId = await _requireUserId();
    await _collection(userId).doc(productId).delete();
  }

  Future<void> _clearAll(List<String> productIds) async {
    final userId = await _requireUserId();
    final batch = _firestore.batch();
    for (final productId in productIds) {
      batch.delete(_collection(userId).doc(productId));
    }
    await batch.commit();
  }
}
