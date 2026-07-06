import 'package:cava_ecommerce/features/categories/data/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CategoryModel', () {
    test('fromEntity round-trips fields', () {
      final model = CategoryModel.fromEntity(testCategoryEntity);
      expect(model.id, testCategoryEntity.id);
      expect(model.emoji, testCategoryEntity.emoji);
    });

    test('fromJson and toJson round-trip', () {
      final model = CategoryModel.fromJson(testCategoryJson);
      expect(model.toJson(), testCategoryJson);
    });
  });
}
