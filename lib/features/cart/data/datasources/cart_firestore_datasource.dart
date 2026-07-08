import 'dart:async';

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

  Future<void> replaceAllEntries(List<StoredCartItemModel> entries) async {
    final userId = await _requireUserId();
    final mergedIds = entries.map((entry) => entry.productId).toSet();
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
    invalidateCache();
  }

  void invalidateCache() {
    _items.clear();
    _metadataByProductId.clear();
    _isHydrated = false;
  }

  @override
  Future<void> loadPersistedCart() async {
    if (_isHydrated) {
      return;
    }

    final userId = await _requireUserId();
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
  }

  @override
  List<CartItemEntity> getItems() => List<CartItemEntity>.unmodifiable(_items);

  @override
  int getItemCount() => _items.fold(0, (sum, item) => sum + item.quantity);

  @override
  double getSubtotal() => _items.fold(0, (sum, item) => sum + item.lineTotal);

  @override
  double getDiscount() => 0;

  @override
  double getVat() => 0;

  @override
  double getShipping() => 0;

  @override
  double getTotal() => getSubtotal() + getVat() + getShipping();

  @override
  void addProduct(ProductEntity product, {int quantity = 1}) {
    if (quantity <= 0) {
      return;
    }

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
    unawaited(_persistProduct(product.id));
  }

  @override
  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= _items.length) {
      return;
    }

    if (quantity <= 0) {
      removeAt(index);
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

    unawaited(_persistProduct(productId));
  }

  @override
  void removeAt(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final productId = _items[index].product.id;
    _items.removeAt(index);
    _metadataByProductId.remove(productId);
    unawaited(_deleteProduct(productId));
  }

  @override
  void clear() {
    final productIds = _items.map((item) => item.product.id).toList();
    _items.clear();
    _metadataByProductId.clear();
    _isHydrated = true;
    unawaited(_clearAll(productIds));
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
