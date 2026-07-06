import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_firestore_datasource.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('ProductFirestoreDataSource', () {
    late FakeFirebaseFirestore firestore;
    late ProductFirestoreDataSource dataSource;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      dataSource = ProductFirestoreDataSource(firestore);

      final json = Map<String, dynamic>.from(testProductJson)
        ..remove('id');
      await firestore
          .collection(FirebaseConfig.productsCollection)
          .doc('p1')
          .set(json);
    });

    test('getAllProducts reads from products collection', () async {
      final products = await dataSource.getAllProducts();
      expect(products, hasLength(1));
      expect(products.first.id, 'p1');
      expect(products.first.name, testProductModel.name);
    });

    test('getProductById returns product when document exists', () async {
      final product = await dataSource.getProductById('p1');
      expect(product?.id, 'p1');
    });

    test('getProductById returns null when document missing', () async {
      expect(await dataSource.getProductById('missing'), isNull);
    });

    test('getFeaturedProducts filters by isFeatured', () async {
      final json = Map<String, dynamic>.from(testProductJson)
        ..['id'] = 'p2'
        ..['isFeatured'] = false;
      await firestore
          .collection(FirebaseConfig.productsCollection)
          .doc('p2')
          .set(json);

      final featured = await dataSource.getFeaturedProducts();
      expect(featured, hasLength(1));
      expect(featured.first.id, 'p1');
    });

    test('getProductsByCategory filters by categoryId', () async {
      final products = await dataSource.getProductsByCategory('wines');
      expect(products, hasLength(1));
      expect(products.first.categoryId, 'wines');
    });
  });

  group('ProductFirestoreDataSource.mapDocumentToModel', () {
    test('uses document id when id field is absent', () {
      final json = Map<String, dynamic>.from(testProductJson)..remove('id');
      final model = ProductFirestoreDataSource.mapDocumentToModel(json, 'doc-1');
      expect(model.id, 'doc-1');
    });

    test('preserves id field from document data', () {
      final model = ProductFirestoreDataSource.mapDocumentToModel(
        testProductJson,
        'doc-1',
      );
      expect(model.id, 'p1');
    });
  });
}
