import 'package:cava_ecommerce/features/products/data/mappers/product_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('ProductMapper', () {
    test('toEntity maps all fields', () {
      final entity = ProductMapper.toEntity(testProductModel);
      expect(entity.id, testProductModel.id);
      expect(entity.name, testProductModel.name);
      expect(entity.price, testProductModel.price);
    });

    test('toModel round-trips entity', () {
      final model = ProductMapper.toModel(testProductEntity);
      expect(model.id, testProductEntity.id);
    });

    test('toEntityList maps list', () {
      final entities = ProductMapper.toEntityList([testProductModel]);
      expect(entities, hasLength(1));
      expect(entities.first.id, 'p1');
    });
  });
}
