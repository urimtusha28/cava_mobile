import 'package:cava_ecommerce/features/products/data/mappers/product_mapper.dart';
import 'package:cava_ecommerce/features/products/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('ProductMapper', () {
    test('toEntity maps legacy mock fields', () {
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

    test('maps web schema to mobile entity fields', () {
      final model = ProductModel.fromJson(testWebProductJson);
      final entity = ProductMapper.toEntity(model);

      expect(entity.oldPrice, 21.0);
      expect(entity.categoryName, 'Wines');
      expect(entity.categoryId, 'wines');
      expect(entity.brand, 'Stone Castle');
      expect(entity.country, 'North Macedonia');
      expect(entity.alcoholPercentage, 13.5);
      expect(entity.volume, '750ml');
      expect(entity.type, 'Merlot');
      expect(entity.isFeatured, isTrue);
      expect(entity.inStock, isTrue);
      expect(entity.imageUrl, 'https://cdn.example.com/p1-thumb.jpg');
      expect(entity.detailImageUrl, 'https://cdn.example.com/p1-medium.jpg');
    });
  });
}
