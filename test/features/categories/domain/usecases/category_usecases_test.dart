import 'package:cava_ecommerce/features/categories/domain/usecases/get_categories.dart';
import 'package:cava_ecommerce/features/categories/domain/usecases/get_category_by_id.dart';
import 'package:cava_ecommerce/features/categories/domain/usecases/get_subcategories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCategoryRepository repository;

  setUp(() {
    repository = MockCategoryRepository();
  });

  test('GetCategoriesUseCase returns categories', () async {
    when(() => repository.getAll())
        .thenAnswer((_) async => [testCategoryEntity]);
    final result = await GetCategoriesUseCase(repository)();
    expect(result.dataOrNull, hasLength(1));
  });

  test('GetCategoryByIdUseCase returns category', () async {
    when(() => repository.getById('wines'))
        .thenAnswer((_) async => testCategoryEntity);
    final result = await GetCategoryByIdUseCase(repository)('wines');
    expect(result.dataOrNull?.id, 'wines');
  });

  test('GetSubcategoriesUseCase returns subcategories', () async {
    when(() => repository.getSubcategories('wines'))
        .thenAnswer((_) async => [testSubcategoryEntity]);
    final result = await GetSubcategoriesUseCase(repository)('wines');
    expect(result.dataOrNull?.first.id, 'red');
  });
}
