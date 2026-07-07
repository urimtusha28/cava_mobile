import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebaseConfig.categoriesCollection);

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
              ),
            )
            .toList(growable: false);

        return [
          const SubcategoryModel(id: 'all', label: 'All'),
          ...models,
        ];
      },
      fallback: () => _mockFallback.getSubcategories(categoryId),
    );
  }

  Future<List<CategoryModel>> _loadActiveCategories() async {
    final snapshot = await _collection.get();
    final categories = <CategoryModel>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['isActive'] == false) {
        continue;
      }
      final model = _tryMapDocument(data, doc.id);
      if (model != null) {
        categories.add(model);
      }
    }

    return categories;
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
