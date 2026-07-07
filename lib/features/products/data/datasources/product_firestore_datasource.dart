import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebaseConfig.productsCollection);

  @override
  Future<List<ProductModel>> getAllProducts() async {
    return _safeList(
      operation: 'getAllProducts',
      request: () async {
        final snapshot = await _collection.get();
        return _mapActiveDocuments(snapshot.docs);
      },
      fallback: () => _mockFallback.getAllProducts(),
    );
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
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
    return _safeList(
      operation: 'getFeaturedProducts',
      request: () async {
        try {
          final snapshot =
              await _collection.where('topPick', isEqualTo: true).get();
          return _mapActiveDocuments(snapshot.docs);
        } catch (error) {
          _logQueryFallback('getFeaturedProducts', error);
          final all = await getAllProducts();
          return all.where((product) => product.topPick).toList(growable: false);
        }
      },
      fallback: () => _mockFallback.getFeaturedProducts(),
    );
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    return _safeList(
      operation: 'getProductsByCategory',
      request: () async {
        final snapshot = await _collection.get();
        return _mapActiveDocuments(
          snapshot.docs.where((doc) {
            final docCategory = doc.data()['category'] as String?;
            if (docCategory == null) {
              return false;
            }
            final normalizedCategory = category.toLowerCase();
            return docCategory == category ||
                docCategory.toLowerCase() == normalizedCategory ||
                ProductModel.categorySlug(docCategory) ==
                    ProductModel.categorySlug(category);
          }).toList(growable: false),
        );
      },
      fallback: () => _mockFallback.getProductsByCategory(category),
    );
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
