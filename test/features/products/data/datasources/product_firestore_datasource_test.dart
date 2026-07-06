import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_firestore_datasource.dart';
import 'package:cava_ecommerce/features/products/data/mappers/product_mapper.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('ProductFirestoreDataSource', () {
    late FakeFirebaseFirestore firestore;
    late ProductFirestoreDataSource dataSource;

    Future<void> seedWebProduct(
      String docId,
      Map<String, dynamic> json,
    ) async {
      final payload = Map<String, dynamic>.from(json)..remove('id');
      await firestore
          .collection(FirebaseConfig.productsCollection)
          .doc(docId)
          .set(payload);
    }

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      dataSource = ProductFirestoreDataSource(firestore);
      await seedWebProduct('web-p1', testWebProductJson);
    });

    test('getAllProducts reads active web products only', () async {
      await seedWebProduct('web-draft', testWebDraftProductJson);
      await seedWebProduct('web-hidden', testWebHiddenProductJson);

      final products = await dataSource.getAllProducts();

      expect(products, hasLength(1));
      expect(products.first.id, 'web-p1');
      expect(products.first.topPick, isTrue);
    });

    test('getProductById returns active product', () async {
      final product = await dataSource.getProductById('web-p1');
      expect(product?.name, 'Stone Castle Merlot');
    });

    test('getProductById returns null for draft product', () async {
      await seedWebProduct('web-draft', testWebDraftProductJson);
      expect(await dataSource.getProductById('web-draft'), isNull);
    });

    test('getProductById returns null when document missing', () async {
      expect(await dataSource.getProductById('missing'), isNull);
    });

    test('getFeaturedProducts uses topPick', () async {
      final notFeatured = Map<String, dynamic>.from(testWebProductJson)
        ..['topPick'] = false;
      await seedWebProduct('web-p2', notFeatured);

      final featured = await dataSource.getFeaturedProducts();

      expect(featured, hasLength(1));
      expect(featured.first.id, 'web-p1');
    });

    test('getFeaturedProducts excludes draft topPick products', () async {
      await seedWebProduct('web-draft-top', {
        ...testWebProductJson,
        'id': 'web-draft-top',
        'productStatus': 'draft',
        'topPick': true,
      });

      final featured = await dataSource.getFeaturedProducts();
      expect(featured.every((p) => p.id != 'web-draft-top'), isTrue);
    });

    test('getProductsByCategory matches category string', () async {
      final products = await dataSource.getProductsByCategory('Wines');
      expect(products, hasLength(1));
      expect(products.first.category, 'Wines');
    });

    test('getProductsByCategory matches category slug', () async {
      final products = await dataSource.getProductsByCategory('wines');
      expect(products, hasLength(1));
    });

    test('maps images for card and detail via mapper', () async {
      final product = await dataSource.getProductById('web-p1');
      final entity = ProductMapper.toEntity(product!);
      expect(entity.imageUrl, (testWebProductJson['images'] as Map)['thumb']);
      expect(entity.detailImageUrl, (testWebProductJson['images'] as Map)['medium']);
    });
  });

  group('ProductFirestoreDataSource.mapDocumentToModel', () {
    test('uses document id when id field is absent', () {
      final json = Map<String, dynamic>.from(testWebProductJson)..remove('id');
      final model = ProductFirestoreDataSource.mapDocumentToModel(json, 'doc-1');
      expect(model.id, 'doc-1');
    });
  });
}
