import 'dart:async';

import '../../../../core/state/wishlist_state_notifier.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_data_source.dart';
import '../datasources/wishlist_firestore_datasource.dart';
import '../datasources/wishlist_local_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(
    this._localDataSource,
    this._firestoreDataSource,
    this._authRepository,
  ) {
    _authSubscription = _authRepository.watchAuthState().listen((loggedIn) async {
      if (loggedIn) {
        await _mergeGuestWishlistIfNeeded();
      } else {
        _mergedForUserId = null;
        _mergeInFlight = null;
      }
      await _refreshBadge();
    });
  }

  final WishlistLocalDataSource _localDataSource;
  final WishlistFirestoreDataSource _firestoreDataSource;
  final AuthRepository _authRepository;

  StreamSubscription<bool>? _authSubscription;
  String? _mergedForUserId;
  Future<void>? _mergeInFlight;

  Future<WishlistDataSource> _activeDataSource() async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (!loggedIn) {
      return _localDataSource;
    }

    await _mergeGuestWishlistIfNeeded();
    return _firestoreDataSource;
  }

  Future<void> _mergeGuestWishlistIfNeeded() async {
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
    if (_mergedForUserId == userId) {
      return;
    }

    final guestEntries = await _localDataSource.readStoredEntries();
    if (guestEntries.isEmpty) {
      _mergedForUserId = userId;
      return;
    }

    for (final entry in guestEntries) {
      DateTime? createdAt;
      try {
        createdAt = DateTime.parse(entry.addedAt).toUtc();
      } catch (_) {
        createdAt = null;
      }

      // Deterministic doc id = productId + merge:true → no duplicates.
      await _firestoreDataSource.addEntry(
        productId: entry.productId,
        createdAt: createdAt,
      );
    }

    await _localDataSource.clearAll();
    _mergedForUserId = userId;
  }

  Future<void> _refreshBadge() async {
    final dataSource = await _activeDataSource();
    WishlistStateNotifier.update(await dataSource.getCount());
  }

  void _notifyChange(int count) {
    WishlistStateNotifier.update(count);
  }

  @override
  Future<List<ProductEntity>> getItems() async {
    final dataSource = await _activeDataSource();
    final items = await dataSource.getItems();
    _notifyChange(items.length);
    return items;
  }

  @override
  Future<int> getCount() async {
    final dataSource = await _activeDataSource();
    final count = await dataSource.getCount();
    _notifyChange(count);
    return count;
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    final dataSource = await _activeDataSource();
    return dataSource.isInWishlist(productId);
  }

  @override
  Future<void> add(ProductEntity product) async {
    final dataSource = await _activeDataSource();
    await dataSource.add(product);
    _notifyChange(await dataSource.getCount());
  }

  @override
  Future<void> remove(String productId) async {
    final dataSource = await _activeDataSource();
    await dataSource.remove(productId);
    _notifyChange(await dataSource.getCount());
  }

  @override
  Future<void> toggle(ProductEntity product) async {
    final dataSource = await _activeDataSource();
    await dataSource.toggle(product);
    _notifyChange(await dataSource.getCount());
  }

  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
  }
}
