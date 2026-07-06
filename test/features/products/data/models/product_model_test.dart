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

    test('fromJson and toJson round-trip', () {
      final model = ProductModel.fromJson(testProductJson);
      expect(model.toJson(), testProductJson);
    });

    test('fromJson handles optional fields', () {
      final json = Map<String, dynamic>.from(testProductJson)..remove('oldPrice');
      final model = ProductModel.fromJson(json);
      expect(model.oldPrice, isNull);
      expect(model.inStock, isTrue);
    });
  });
}
