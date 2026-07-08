import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/state/cart_state_notifier.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_summary_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/utils/cart_merge_resolver.dart';
import '../datasources/cart_data_source.dart';
import '../datasources/cart_firestore_datasource.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/stored_cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(
    this._localDataSource,
    this._firestoreDataSource,
    this._authRepository,
  ) {
    _authSubscription = _authRepository.watchAuthState().listen((loggedIn) async {
      if (loggedIn) {
        await _mergeGuestCartIfNeeded();
      } else {
        _mergedForUserId = null;
        _mergeInFlight = null;
        _firestoreDataSource.invalidateCache();
      }
      await _refreshBadge();
    });
  }

  final CartLocalDataSource _localDataSource;
  final CartFirestoreDataSource _firestoreDataSource;
  final AuthRepository _authRepository;

  StreamSubscription<bool>? _authSubscription;
  String? _mergedForUserId;
  Future<void>? _mergeInFlight;

  Future<CartDataSource> _activeDataSource() async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (!loggedIn) {
      return _localDataSource;
    }

    await _mergeGuestCartIfNeeded();
    return _firestoreDataSource;
  }

  Future<void> _mergeGuestCartIfNeeded() async {
    final userId = await _authRepository.getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    if (_mergedForUserId == userId) {
      return;
    }

    final inFlight = _mergeInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final mergeFuture = _runMerge(userId);
    _mergeInFlight = mergeFuture;
    try {
      await mergeFuture;
    } finally {
      if (identical(_mergeInFlight, mergeFuture)) {
        _mergeInFlight = null;
      }
    }
  }

  Future<void> _runMerge(String userId) async {
    // Re-check after awaiting any prior race window.
    if (_mergedForUserId == userId) {
      return;
    }

    final guestEntries = await _localDataSource.readStoredEntries();

    if (guestEntries.isEmpty) {
      // Nothing to merge — mark done so auth events don't rewrite cloud cart.
      _mergedForUserId = userId;
      return;
    }

    final cloudEntries = await _readCloudEntriesForMerge(guestEntries);
    final merged = CartMergeResolver.merge(
      guestEntries: guestEntries,
      cloudEntries: cloudEntries,
    );

    await _firestoreDataSource.replaceAllEntries(merged);
    await _localDataSource.clearAll();
    _mergedForUserId = userId;
  }

  /// Prefers full collection read; if denied, merges using document reads for
  /// guest product ids only so add-to-cart is not blocked by list queries.
  Future<List<StoredCartItemModel>> _readCloudEntriesForMerge(
    List<StoredCartItemModel> guestEntries,
  ) async {
    try {
      return await _firestoreDataSource.readStoredEntries();
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }
      return _firestoreDataSource.readStoredEntriesForProductIds(
        guestEntries.map((entry) => entry.productId),
      );
    }
  }

  Future<void> _refreshBadge() async {
    final dataSource = await _activeDataSource();
    await dataSource.loadPersistedCart();
    CartStateNotifier.update(dataSource.getItemCount());
  }

  void _notifyChange(int count) {
    CartStateNotifier.update(count);
  }

  Future<CartDataSource> _hydratedDataSource() async {
    final dataSource = await _activeDataSource();
    await dataSource.loadPersistedCart();
    return dataSource;
  }

  @override
  Future<void> hydrateFromStorage() async {
    await _refreshBadge();
  }

  @override
  Future<CartSummaryEntity> getSummary() async {
    final dataSource = await _hydratedDataSource();
    _notifyChange(dataSource.getItemCount());
    return CartSummaryEntity(
      items: dataSource.getItems(),
      itemCount: dataSource.getItemCount(),
      subtotal: dataSource.getSubtotal(),
      discount: dataSource.getDiscount(),
      vat: dataSource.getVat(),
      shipping: dataSource.getShipping(),
      total: dataSource.getTotal(),
    );
  }

  @override
  Future<List<CartItemEntity>> getItems() async {
    final dataSource = await _hydratedDataSource();
    final items = dataSource.getItems();
    _notifyChange(dataSource.getItemCount());
    return items;
  }

  @override
  Future<int> getItemCount() async {
    final dataSource = await _hydratedDataSource();
    final count = dataSource.getItemCount();
    _notifyChange(count);
    return count;
  }

  @override
  Future<double> getSubtotal() async {
    final dataSource = await _hydratedDataSource();
    return dataSource.getSubtotal();
  }

  @override
  Future<double> getDiscount() async {
    final dataSource = await _hydratedDataSource();
    return dataSource.getDiscount();
  }

  @override
  Future<double> getVat() async {
    final dataSource = await _hydratedDataSource();
    return dataSource.getVat();
  }

  @override
  Future<double> getShipping() async {
    final dataSource = await _hydratedDataSource();
    return dataSource.getShipping();
  }

  @override
  Future<double> getTotal() async {
    final dataSource = await _hydratedDataSource();
    return dataSource.getTotal();
  }

  @override
  Future<void> addProduct(ProductEntity product, {int quantity = 1}) async {
    final dataSource = await _activeDataSource();
    // Firestore add hydrates the target product document itself — avoid forcing
    // a full collection list that security rules may deny.
    if (dataSource is! CartFirestoreDataSource) {
      await dataSource.loadPersistedCart();
    }
    await dataSource.addProduct(product, quantity: quantity);
    _notifyChange(dataSource.getItemCount());
  }

  @override
  Future<void> updateQuantity(int index, int quantity) async {
    final dataSource = await _hydratedDataSource();
    await dataSource.updateQuantity(index, quantity);
    _notifyChange(dataSource.getItemCount());
  }

  @override
  Future<void> removeAt(int index) async {
    final dataSource = await _hydratedDataSource();
    await dataSource.removeAt(index);
    _notifyChange(dataSource.getItemCount());
  }

  @override
  Future<void> clear() async {
    final dataSource = await _hydratedDataSource();
    await dataSource.clear();
    _notifyChange(0);
  }

  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
  }
}
