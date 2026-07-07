import 'package:cava_ecommerce/features/categories/data/mappers/subcategory_mapper.dart';
import 'package:cava_ecommerce/features/categories/data/models/subcategory_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('SubcategoryMapper', () {
    test('maps badgeColor to entity', () {
      final model = SubcategoryModel.fromEntity(testSubcategoryEntity);
      final entity = SubcategoryMapper.toEntity(model);
      expect(entity.badgeColor, '#AA0000');
    });

    test('round-trips entity through model', () {
      final model = SubcategoryModel.fromEntity(testSubcategoryEntity);
      expect(model.badgeColor, testSubcategoryEntity.badgeColor);
    });
  });
}
