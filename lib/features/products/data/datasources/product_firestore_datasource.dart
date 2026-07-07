import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/cache/ttl_memory_cache.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../models/product_model.dart';
import 'product_data_source.dart';
import 'product_mock_datasource.dart';

/// Firestore implementation for [ProductDataSource].
///
/// Reads web Firebase `products` sales schema only — no CMS/homepage fields.
/// Wired in DI only when [FirebaseConfig.enabled] and
/// [FirebaseConfig.useFirestoreProducts] are both `true`.
class ProductFirestoreDataSource implements ProductDataSource {
  ProductFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const ProductMockDataSource _mockFallback =
      ProductMockDataSource();

  final TtlMemoryCache<List<ProductModel>> _allProductsCache =
      TtlMemoryCache(ttl: FirebaseConfig.firestoreCacheTtl);
  final TtlMemoryCache<List<ProductModel>> _featuredProductsCache =
      TtlMemoryCache(ttl: FirebaseConfig.firestoreCacheTtl);
  final TtlMemoryMapCache<List<ProductModel>> _productsByCategoryCache =
      TtlMemoryMapCache(ttl: FirebaseConfig.firestoreCacheTtl);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebaseConfig.productsCollection);

  /// Clears all in-memory product caches.
  void clearCache() {
    _allProductsCache.clear();
    _featuredProductsCache.clear();
    _productsByCategoryCache.clear();
    if (kDebugMode) {
      debugPrint('ProductFirestoreDataSource: cache cleared');
    }
  }

  /// Clears cache and preloads all active products from Firestore.
  Future<void> refreshCache() async {
    clearCache();
    await getAllProducts();
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final cached = _allProductsCache.valueIfValid;
    if (cached != null) {
      _logCacheHit('getAllProducts', cached.length);
      return cached;
    }

    return _safeList(
      operation: 'getAllProducts',
      request: () async {
        final products = await _fetchAllProductsFromFirestore();
        return products;
      },
      fallback: () => _mockFallback.getAllProducts(),
    );
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final cachedAll = _allProductsCache.valueIfValid;
    if (cachedAll != null) {
      for (final product in cachedAll) {
        if (product.id == id) {
          _logCacheHit('getProductById', 1);
          return product;
        }
      }
    }

    return _safeValue(
      operation: 'getProductById',
      request: () async {
        final snapshot = await _collection.doc(id).get();
        if (!snapshot.exists) {
          return null;
        }
        final data = snapshot.data()!;
        if (!ProductModel.isActiveProductStatus(
          data['productStatus'] as String?,
        )) {
          return null;
        }
        return _tryMapDocument(data, snapshot.id);
      },
      fallback: () => _mockFallback.getProductById(id),
    );
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final cachedAll = _allProductsCache.valueIfValid;
    if (cachedAll != null) {
      final featured = _filterFeatured(cachedAll);
      _logCacheHit('getFeaturedProducts', featured.length);
      return featured;
    }

    final cachedFeatured = _featuredProductsCache.valueIfValid;
    if (cachedFeatured != null) {
      _logCacheHit('getFeaturedProducts', cachedFeatured.length);
      return cachedFeatured;
    }

    return _safeList(
      operation: 'getFeaturedProducts',
      request: () async {
        try {
          final snapshot =
              await _collection.where('topPick', isEqualTo: true).get();
          final products = List<ProductModel>.unmodifiable(
            _mapActiveDocuments(snapshot.docs),
          );
          _featuredProductsCache.put(products);
          return products;
        } catch (error) {
          _logQueryFallback('getFeaturedProducts', error);
          final all = await getAllProducts();
          return _filterFeatured(all);
        }
      },
      fallback: () => _mockFallback.getFeaturedProducts(),
    );
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final cacheKey = _categoryCacheKey(category);
    final cachedAll = _allProductsCache.valueIfValid;
    if (cachedAll != null) {
      final filtered = _filterByCategory(cachedAll, category);
      _logCacheHit('getProductsByCategory', filtered.length);
      return filtered;
    }

    final cachedCategory = _productsByCategoryCache.get(cacheKey);
    if (cachedCategory != null) {
      _logCacheHit('getProductsByCategory', cachedCategory.length);
      return cachedCategory;
    }

    return _safeList(
      operation: 'getProductsByCategory',
      request: () async {
        final all = await getAllProducts();
        final filtered = _filterByCategory(all, category);
        _productsByCategoryCache.put(cacheKey, filtered);
        return filtered;
      },
      fallback: () => _mockFallback.getProductsByCategory(category),
    );
  }

  Future<List<ProductModel>> _fetchAllProductsFromFirestore() async {
    final snapshot = await _collection.get();
    final products = List<ProductModel>.unmodifiable(
      _mapActiveDocuments(snapshot.docs),
    );
    _allProductsCache.put(products);
    return products;
  }

  List<ProductModel> _filterFeatured(List<ProductModel> products) {
    return products.where((product) => product.topPick).toList(growable: false);
  }

  List<ProductModel> _filterByCategory(
    List<ProductModel> products,
    String category,
  ) {
    return products
        .where((product) => _matchesCategory(product, category))
        .toList(growable: false);
  }

  bool _matchesCategory(ProductModel product, String category) {
    final docCategory = product.category ?? product.categoryName;
    if (docCategory == null || docCategory.isEmpty) {
      return false;
    }
    final normalizedCategory = category.toLowerCase();
    return docCategory == category ||
        docCategory.toLowerCase() == normalizedCategory ||
        ProductModel.categorySlug(docCategory) ==
            ProductModel.categorySlug(category);
  }

  String _categoryCacheKey(String category) => category.trim().toLowerCase();

  void _logCacheHit(String operation, int count) {
    if (kDebugMode) {
      debugPrint(
        'ProductFirestoreDataSource: cache hit $operation ($count items)',
      );
    }
  }

  List<ProductModel> _mapActiveDocuments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final products = <ProductModel>[];
    for (final doc in docs) {
      if (!ProductModel.isActiveProductStatus(
        doc.data()['productStatus'] as String?,
      )) {
        continue;
      }
      final model = _tryMapDocument(doc.data(), doc.id);
      if (model != null) {
        products.add(model);
      }
    }
    if (kDebugMode && products.isNotEmpty) {
      debugPrint(
        'ProductFirestoreDataSource: mapped ${products.length} active products',
      );
    }
    return products;
  }

  ProductModel? _tryMapDocument(Map<String, dynamic> data, String documentId) {
    try {
      return mapDocumentToModel(data, documentId);
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'ProductFirestoreDataSource: skipped $documentId — $error',
        );
      }
      return null;
    }
  }

  Future<List<ProductModel>> _safeList({
    required String operation,
    required Future<List<ProductModel>> Function() request,
    required Future<List<ProductModel>> Function() fallback,
  }) async {
    try {
      return await request();
    } catch (error, stackTrace) {
      _logError(operation, error, stackTrace);
      if (FirebaseConfig.fallbackToMockProductsOnError) {
        return fallback();
      }
      return const [];
    }
  }

  Future<ProductModel?> _safeValue({
    required String operation,
    required Future<ProductModel?> Function() request,
    required Future<ProductModel?> Function() fallback,
  }) async {
    try {
      return await request();
    } catch (error, stackTrace) {
      _logError(operation, error, stackTrace);
      if (FirebaseConfig.fallbackToMockProductsOnError) {
        return fallback();
      }
      return null;
    }
  }

  void _logQueryFallback(String operation, Object error) {
    if (kDebugMode) {
      debugPrint(
        'ProductFirestoreDataSource: $operation query fallback — $error',
      );
    }
  }

  void _logError(String operation, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('ProductFirestoreDataSource: $operation failed — $error');
      debugPrint('$stackTrace');
    }
  }

  /// Maps Firestore document data to [ProductModel].
  ///
  /// Uses document id when `id` is absent from stored fields.
  static ProductModel mapDocumentToModel(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final json = Map<String, dynamic>.from(data);
    json.putIfAbsent('id', () => documentId);
    return ProductModel.fromJson(json);
  }
}
