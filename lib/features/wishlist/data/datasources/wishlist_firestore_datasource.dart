import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import 'wishlist_data_source.dart';

/// Firestore wishlist at `users/{uid}/wishlist/{productId}`.
class WishlistFirestoreDataSource implements WishlistDataSource {
  WishlistFirestoreDataSource(
    this._firestore,
    this._authRepository,
    this._productRepository,
  );

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final ProductRepository _productRepository;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .collection(FirebaseConfig.wishlistSubcollection);
  }

  Future<String> _requireUserId() async {
    final userId = await _authRepository.getCurrentUserId();
    if (userId == null || userId.trim().isEmpty) {
      throw StateError('Wishlist requires an authenticated user.');
    }
    return userId;
  }

  Future<void> addEntry({
    required String productId,
    DateTime? createdAt,
  }) async {
    final userId = await _requireUserId();
    final timestamp = createdAt ?? DateTime.now().toUtc();

    await _collection(userId).doc(productId).set(
      {
        'productId': productId,
        'createdAt': Timestamp.fromDate(timestamp),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> add(ProductEntity product) async {
    await addEntry(productId: product.id);
  }

  @override
  Future<void> remove(String productId) async {
    final userId = await _requireUserId();
    await _collection(userId).doc(productId).delete();
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    final userId = await _requireUserId();
    final doc = await _collection(userId).doc(productId).get();
    return doc.exists;
  }

  @override
  Future<int> getCount() async {
    final userId = await _requireUserId();
    final snapshot = await _collection(userId).get();
    return snapshot.docs.length;
  }

  @override
  Future<List<ProductEntity>> getItems() async {
    final userId = await _requireUserId();
    final snapshot = await _collection(userId).get();

    final products = <ProductEntity>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final productId = (data['productId'] as String?)?.trim();
      final resolvedId =
          productId != null && productId.isNotEmpty ? productId : doc.id;

      final product = await _productRepository.getById(resolvedId);
      if (product == null) {
        await _collection(userId).doc(doc.id).delete();
        continue;
      }
      products.add(product);
    }

    return products;
  }

  @override
  Future<void> toggle(ProductEntity product) async {
    if (await isInWishlist(product.id)) {
      await remove(product.id);
    } else {
      await add(product);
    }
  }
}
