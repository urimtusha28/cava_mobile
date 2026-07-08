import 'dart:async';

import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../local/cart_local_storage.dart';
import '../models/stored_cart_item_model.dart';
import 'cart_data_source.dart';

/// Guest cart held in memory and persisted locally (product ids + quantities).
class CartLocalDataSource implements CartDataSource {
  CartLocalDataSource(this._storage, this._productRepository);

  final CartLocalStorage _storage;
  final ProductRepository _productRepository;

  final List<CartItemEntity> _items = [];
  final Map<String, StoredCartItemModel> _metadataByProductId = {};
  bool _isHydrated = false;

  @override
  Future<void> loadPersistedCart() async {
    if (_isHydrated) {
      return;
    }

    if (_items.isNotEmpty) {
      _isHydrated = true;
      await _persistAsync();
      return;
    }

    final stored = await _storage.readItems();
    final rebuilt = <CartItemEntity>[];
    final validStored = <StoredCartItemModel>[];

    for (final entry in stored) {
      if (entry.quantity <= 0) {
        continue;
      }

      final product = await _productRepository.getById(entry.productId);
      if (product == null) {
        continue;
      }

      rebuilt.add(CartItemEntity(product: product, quantity: entry.quantity));
      validStored.add(entry);
      _metadataByProductId[entry.productId] = entry;
    }

    _items
      ..clear()
      ..addAll(rebuilt);

    if (validStored.length != stored.length) {
      await _storage.writeItems(validStored);
    }

    _isHydrated = true;
  }

  @override
  List<CartItemEntity> getItems() =>
      List<CartItemEntity>.unmodifiable(_items);

  @override
  int getItemCount() =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  @override
  double getSubtotal() =>
      _items.fold(0, (sum, item) => sum + item.lineTotal);

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
      final current = _items[index];
      final nextQuantity = current.quantity + quantity;
      _items[index] = CartItemEntity(
        product: product,
        quantity: nextQuantity,
      );
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
    unawaited(_persistAsync());
  }

  @override
  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= _items.length) {
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

    unawaited(_persistAsync());
  }

  @override
  void removeAt(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final productId = _items[index].product.id;
    _items.removeAt(index);
    _metadataByProductId.remove(productId);
    unawaited(_persistAsync());
  }

  @override
  void clear() {
    _items.clear();
    _metadataByProductId.clear();
    _isHydrated = true;
    unawaited(_persistAsync(clearStorage: true));
  }

  Future<void> _persistAsync({bool clearStorage = false}) async {
    if (clearStorage && _items.isEmpty) {
      await _storage.clear();
      return;
    }

    final stored = _items.map((item) {
      final meta = _metadataByProductId[item.product.id];
      return StoredCartItemModel(
        productId: item.product.id,
        quantity: item.quantity,
        selectedVariant: meta?.selectedVariant,
        addedAt: meta?.addedAt ?? DateTime.now().toUtc().toIso8601String(),
      );
    }).toList(growable: false);

    await _storage.writeItems(stored);
  }

  Future<void> clearAll() async {
    _items.clear();
    _metadataByProductId.clear();
    _isHydrated = true;
    await _storage.clear();
  }

  Future<List<StoredCartItemModel>> readStoredEntries() async {
    if (_isHydrated) {
      return _items
          .map((item) {
            final meta = _metadataByProductId[item.product.id];
            return StoredCartItemModel(
              productId: item.product.id,
              quantity: item.quantity,
              selectedVariant: meta?.selectedVariant,
              addedAt: meta?.addedAt ??
                  DateTime.now().toUtc().toIso8601String(),
            );
          })
          .toList(growable: false);
    }

    return _storage.readItems();
  }

  /// Test helper — resets hydration and in-memory state.
  void resetForTests() {
    _items.clear();
    _metadataByProductId.clear();
    _isHydrated = false;
  }
}
