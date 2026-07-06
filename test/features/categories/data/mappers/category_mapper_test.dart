import 'package:cava_ecommerce/features/categories/data/mappers/category_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CategoryMapper', () {
    test('toEntity maps fields', () {
      final entity = CategoryMapper.toEntity(testCategoryModel);
      expect(entity.id, 'wines');
      expect(entity.label, 'Verërat');
    });

    test('toModel round-trips entity', () {
      final model = CategoryMapper.toModel(testCategoryEntity);
      expect(model.name, testCategoryEntity.name);
    });
  });
}
