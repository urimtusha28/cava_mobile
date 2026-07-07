import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/categories/data/datasources/category_firestore_datasource.dart';
import 'package:cava_ecommerce/features/categories/data/models/category_model.dart';
import 'package:cava_ecommerce/features/categories/data/utils/category_collection_utils.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CategoryFirestoreDataSource', () {
    late FakeFirebaseFirestore firestore;
    late CategoryFirestoreDataSource dataSource;

    Future<void> seed(
      String docId,
      Map<String, dynamic> json,
    ) async {
      final payload = Map<String, dynamic>.from(json)..remove('id');
      await firestore
          .collection(FirebaseConfig.categoriesCollection)
          .doc(docId)
          .set(payload);
    }

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      dataSource = CategoryFirestoreDataSource(firestore);
      await seed('cat-wines', testWebCategoryJson);
      await seed('cat-red', testWebSubcategoryJson);
    });

    test('getAllCategories returns only active main categories', () async {
      await seed('cat-inactive', testWebInactiveCategoryJson);

      final categories = await dataSource.getAllCategories();

      expect(categories, hasLength(1));
      expect(categories.first.slug, 'wines');
    });

    test('getAllCategories sorts by order', () async {
      await seed('cat-spirits', {
        ...testWebCategoryJson,
        'id': 'cat-spirits',
        'slug': 'spirits',
        'name': 'Spirits',
        'order': 2,
      });

      final categories = await dataSource.getAllCategories();
      expect(categories.first.slug, 'wines');
      expect(categories.last.slug, 'spirits');
    });

    test('getCategoryById resolves slug', () async {
      final category = await dataSource.getCategoryById('wines');
      expect(category?.name, 'Wines');
    });

    test('getCategoryById returns null for inactive category', () async {
      await seed('cat-inactive', testWebInactiveCategoryJson);
      expect(await dataSource.getCategoryById('inactive'), isNull);
    });

    test('getSubcategories returns subs by parentId with All chip', () async {
      final subs = await dataSource.getSubcategories('wines');

      expect(subs.first.id, 'all');
      expect(subs, hasLength(2));
      expect(subs.last.label, 'Red Wine');
      expect(subs.last.matchTypes, ['Red Wine']);
    });

    test('skips malformed documents without crashing', () async {
      await firestore
          .collection(FirebaseConfig.categoriesCollection)
          .doc('bad')
          .set({'isActive': true, 'type': 'main'});

      final categories = await dataSource.getAllCategories();
      expect(categories, isNotEmpty);
    });
  });

  group('sortCategoriesByOrder', () {
    test('places missing order at end', () {
      final sorted = sortCategoriesByOrder([
        CategoryModel.fromJson({...testWebCategoryJson, 'order': 0}),
        CategoryModel.fromJson({
          ...testWebCategoryJson,
          'id': 'cat-2',
          'slug': 'spirits',
          'order': 1,
        }),
      ]);

      expect(sorted.first.slug, 'spirits');
      expect(sorted.last.order, 0);
    });
  });
}
