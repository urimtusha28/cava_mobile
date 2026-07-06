import 'package:cava_ecommerce/features/categories/data/models/subcategory_model.dart';
import 'package:cava_ecommerce/features/categories/data/repositories/category_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCategoryDataSource dataSource;
  late CategoryRepositoryImpl repository;

  setUp(() {
    dataSource = MockCategoryDataSource();
    repository = CategoryRepositoryImpl(dataSource);
  });

  test('getAll returns mapped categories', () async {
    when(() => dataSource.getAllCategories()).thenReturn([testCategoryModel]);
    final result = await repository.getAll();
    expect(result.first.id, 'wines');
  });

  test('getById returns null when missing', () async {
    when(() => dataSource.getCategoryById('x')).thenReturn(null);
    expect(await repository.getById('x'), isNull);
  });

  test('getSubcategories maps models', () async {
    const model = SubcategoryModel(id: 'red', label: 'Red Wine');
    when(() => dataSource.getSubcategories('wines')).thenReturn([model]);
    final result = await repository.getSubcategories('wines');
    expect(result.first.label, 'Red Wine');
  });
}
