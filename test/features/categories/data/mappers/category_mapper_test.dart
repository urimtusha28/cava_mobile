import 'package:cava_ecommerce/features/categories/data/mappers/category_mapper.dart';
import 'package:cava_ecommerce/features/categories/data/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CategoryMapper', () {
    test('toEntity maps legacy mock fields', () {
      final entity = CategoryMapper.toEntity(testCategoryModel);
      expect(entity.id, 'wines');
      expect(entity.label, 'Verërat');
    });

    test('toModel round-trips entity', () {
      final model = CategoryMapper.toModel(testCategoryEntity);
      expect(model.id, testCategoryEntity.id);
    });

    test('maps web schema slug to entity id for routing', () {
      final model = CategoryModel.fromJson(testWebCategoryJson);
      final entity = CategoryMapper.toEntity(model);
      expect(entity.id, 'wines');
      expect(entity.label, 'Wines');
      expect(entity.name, 'Wines');
    });
  });
}
