import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/cache/ttl_memory_cache.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../utils/category_collection_utils.dart';
import 'category_data_source.dart';
import 'category_mock_datasource.dart';

/// Firestore implementation for [CategoryDataSource].
///
/// Reads web Firebase `categories` sales schema only.
class CategoryFirestoreDataSource implements CategoryDataSource {
  CategoryFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const CategoryMockDataSource _mockFallback =
      CategoryMockDataSource();

  final TtlMemoryCache<List<CategoryModel>> _allCategoriesCache =
      TtlMemoryCache(ttl: FirebaseConfig.firestoreCacheTtl);
  final TtlMemoryMapCache<List<SubcategoryModel>> _subcategoriesCache =
      TtlMemoryMapCache(ttl: FirebaseConfig.firestoreCacheTtl);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebaseConfig.categoriesCollection);

  /// Clears all in-memory category caches.
  void clearCache() {
    _allCategoriesCache.clear();
    _subcategoriesCache.clear();
    if (kDebugMode) {
      debugPrint('CategoryFirestoreDataSource: cache cleared');
    }
  }

  /// Clears cache and preloads active categories from Firestore.
  Future<void> refreshCache() async {
    clearCache();
    await getAllCategories();
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return _safeList(
      operation: 'getAllCategories',
      request: () async {
        final categories = await _loadActiveCategories();
        final mains = categories
            .where((category) => category.isMainCategory)
            .toList(growable: false);
        final sorted = sortCategoriesByOrder(mains);
        if (kDebugMode && sorted.isNotEmpty) {
          debugPrint(
            'CategoryFirestoreDataSource: mapped ${sorted.length} main categories',
          );
        }
        return sorted;
      },
      fallback: () => _mockFallback.getAllCategories(),
    );
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    return _safeValue(
      operation: 'getCategoryById',
      request: () async {
        final categories = await _loadActiveCategories();
        for (final category in categories) {
          if (category.id == id || category.slug == id) {
            return category.isMainCategory ? category : null;
          }
        }
        return null;
      },
      fallback: () => _mockFallback.getCategoryById(id),
    );
  }

  @override
  Future<List<SubcategoryModel>> getSubcategories(String categoryId) async {
    final cacheKey = categoryId.trim().toLowerCase();
    final cached = _subcategoriesCache.get(cacheKey);
    if (cached != null) {
      _logCacheHit('getSubcategories', cached.length);
      return cached;
    }

    return _safeSubcategories(
      operation: 'getSubcategories',
      request: () async {
        final categories = await _loadActiveCategories();
        final parentDocId =
            resolveCategoryDocumentId(categories, categoryId) ?? categoryId;

        final subs = categories
            .where(
              (category) =>
                  category.isSubCategory && category.parentId == parentDocId,
            )
            .toList(growable: false);

        final sorted = sortCategoriesByOrder(subs);
        final models = sorted
            .map(
              (category) => SubcategoryModel(
                id: category.slug.isNotEmpty ? category.slug : category.id,
                label: category.name,
                matchTypes: [category.name],
                badgeColor: category.badgeColor,
              ),
            )
            .toList(growable: false);

        final result = List<SubcategoryModel>.unmodifiable([
          const SubcategoryModel(id: 'all', label: 'All'),
          ...models,
        ]);
        _subcategoriesCache.put(cacheKey, result);
        return result;
      },
      fallback: () => _mockFallback.getSubcategories(categoryId),
    );
  }

  Future<List<CategoryModel>> _loadActiveCategories() async {
    final cached = _allCategoriesCache.valueIfValid;
    if (cached != null) {
      _logCacheHit('_loadActiveCategories', cached.length);
      return cached;
    }

    final snapshot = await _collection
        .where('isActive', isEqualTo: true)
        .get();
    final categories = <CategoryModel>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final model = _tryMapDocument(data, doc.id);
      if (model != null) {
        categories.add(model);
      }
    }

    final result = List<CategoryModel>.unmodifiable(categories);
    _allCategoriesCache.put(result);
    return result;
  }

  void _logCacheHit(String operation, int count) {
    if (kDebugMode) {
      debugPrint(
        'CategoryFirestoreDataSource: cache hit $operation ($count items)',
      );
    }
  }

  CategoryModel? _tryMapDocument(Map<String, dynamic> data, String documentId) {
    try {
      final json = Map<String, dynamic>.from(data);
      json.putIfAbsent('id', () => documentId);
      return CategoryModel.fromJson(json);
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'CategoryFirestoreDataSource: skipped $documentId — $error',
        );
      }
      return null;
    }
  }

  Future<List<CategoryModel>> _safeList({
    required String operation,
    required Future<List<CategoryModel>> Function() request,
    required Future<List<CategoryModel>> Function() fallback,
  }) async {
    try {
      return await request();
    } catch (error, stackTrace) {
      _logError(operation, error, stackTrace);
      if (FirebaseConfig.fallbackToMockCategoriesOnError) {
        return fallback();
      }
      return const [];
    }
  }

  Future<CategoryModel?> _safeValue({
    required String operation,
    required Future<CategoryModel?> Function() request,
    required Future<CategoryModel?> Function() fallback,
  }) async {
    try {
      return await request();
    } catch (error, stackTrace) {
      _logError(operation, error, stackTrace);
      if (FirebaseConfig.fallbackToMockCategoriesOnError) {
        return fallback();
      }
      return null;
    }
  }

  Future<List<SubcategoryModel>> _safeSubcategories({
    required String operation,
    required Future<List<SubcategoryModel>> Function() request,
    required Future<List<SubcategoryModel>> Function() fallback,
  }) async {
    try {
      return await request();
    } catch (error, stackTrace) {
      _logError(operation, error, stackTrace);
      if (FirebaseConfig.fallbackToMockCategoriesOnError) {
        return fallback();
      }
      return const [];
    }
  }

  void _logError(String operation, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('CategoryFirestoreDataSource: $operation failed — $error');
      debugPrint('$stackTrace');
    }
  }
}
