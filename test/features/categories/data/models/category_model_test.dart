import 'package:cava_ecommerce/features/categories/data/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CategoryModel', () {
    test('fromEntity round-trips fields', () {
      final model = CategoryModel.fromEntity(testCategoryEntity);
      expect(model.id, testCategoryEntity.id);
      expect(model.emoji, testCategoryEntity.emoji);
      expect(model.badgeColor, testCategoryEntity.badgeColor);
    });

    test('legacy fromJson round-trips core fields', () {
      final model = CategoryModel.fromJson(testCategoryJson);
      expect(model.id, 'wines');
      expect(model.label, 'Verërat');
    });

    group('web schema fromJson', () {
      test('parses web Firebase category fields', () {
        final model = CategoryModel.fromJson(testWebCategoryJson);
        expect(model.id, 'cat-wines');
        expect(model.name, 'Wines');
        expect(model.slug, 'wines');
        expect(model.type, 'main');
        expect(model.order, 1);
        expect(model.isActive, isTrue);
        expect(model.isMainCategory, isTrue);
        expect(model.badgeColor, '#6B1D2A');
      });

      test('parses subcategory fields', () {
        final model = CategoryModel.fromJson(testWebSubcategoryJson);
        expect(model.isSubCategory, isTrue);
        expect(model.parentId, 'cat-wines');
        expect(model.badgeColor, '#6B1D2A');
      });
    });
  });
}
