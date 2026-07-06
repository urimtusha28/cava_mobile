import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/categories/domain/usecases/get_categories.dart';
import 'package:cava_ecommerce/features/categories/presentation/controllers/categories_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

void main() {
  late MockGetCategoriesUseCase getCategories;
  late CategoriesController controller;

  setUp(() {
    getCategories = MockGetCategoriesUseCase();
    controller = CategoriesController(getCategories);
  });

  test('load populates categories', () async {
    when(() => getCategories())
        .thenAnswer((_) async => Success([testCategoryEntity]));

    await controller.load();

    expect(controller.categories, hasLength(1));
    expect(controller.isLoading, isFalse);
  });

  test('load uses empty fallback on failure', () async {
    when(() => getCategories()).thenAnswer(
      (_) async => const Error(
        UnknownFailure(message: 'fail', code: 'x'),
      ),
    );

    await controller.load();

    expect(controller.categories, isEmpty);
  });
}
