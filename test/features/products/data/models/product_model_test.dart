import 'package:cava_ecommerce/features/products/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('ProductModel', () {
    test('fromEntity round-trips fields', () {
      final model = ProductModel.fromEntity(testProductEntity);
      expect(model.id, testProductEntity.id);
      expect(model.name, testProductEntity.name);
      expect(model.price, testProductEntity.price);
    });

    test('legacy fromJson round-trips core fields', () {
      final model = ProductModel.fromJson(testProductJson);
      expect(model.id, 'p1');
      expect(model.oldPrice, 30.0);
      expect(model.isFeatured, isTrue);
    });

    test('legacy fromJson handles optional fields', () {
      final json = Map<String, dynamic>.from(testProductJson)..remove('oldPrice');
      final model = ProductModel.fromJson(json);
      expect(model.oldPrice, isNull);
      expect(model.inStock, isTrue);
    });

    group('web schema fromJson', () {
      test('parses web Firebase product fields', () {
        final model = ProductModel.fromJson(testWebProductJson);
        expect(model.id, 'web-p1');
        expect(model.originalPrice, 21.0);
        expect(model.stock, 12);
        expect(model.productStatus, 'active');
        expect(model.category, 'Wines');
        expect(model.subCategory, 'Merlot');
        expect(model.brandProducer, 'Stone Castle');
        expect(model.origin, 'North Macedonia');
        expect(model.topPick, isTrue);
      });

      test('parses nested images and details', () {
        final model = ProductModel.fromJson(testWebProductJson);
        expect(model.images?.thumb, 'https://cdn.example.com/p1-thumb.jpg');
        expect(model.images?.medium, 'https://cdn.example.com/p1-medium.jpg');
        expect(model.details?.volume, '750ml');
        expect(ProductModel.parseAbv(model.details?.abv), 13.5);
      });

      test('cardImageUrl prefers thumb', () {
        final model = ProductModel.fromJson(testWebProductJson);
        expect(model.cardImageUrl, 'https://cdn.example.com/p1-thumb.jpg');
      });

      test('detailImageUrl prefers medium', () {
        final model = ProductModel.fromJson(testWebProductJson);
        expect(model.detailImageUrl, 'https://cdn.example.com/p1-medium.jpg');
      });

      test('isActiveProductStatus excludes draft and hidden', () {
        expect(ProductModel.isActiveProductStatus('active'), isTrue);
        expect(ProductModel.isActiveProductStatus(null), isTrue);
        expect(ProductModel.isActiveProductStatus('draft'), isFalse);
        expect(ProductModel.isActiveProductStatus('hidden'), isFalse);
      });
    });
  });
}
