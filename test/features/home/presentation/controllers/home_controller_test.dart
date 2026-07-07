import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/categories/domain/entities/category_entity.dart';
import 'package:cava_ecommerce/features/categories/domain/usecases/get_categories.dart';
import 'package:cava_ecommerce/features/home/domain/entities/home_section_entity.dart';
import 'package:cava_ecommerce/features/home/domain/usecases/get_home_sections.dart';
import 'package:cava_ecommerce/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetHomeSectionsUseCase extends Mock implements GetHomeSectionsUseCase {}

void main() {
  late MockGetCategoriesUseCase getCategories;
  late MockGetHomeSectionsUseCase getHomeSections;
  late HomeController controller;

  setUp(() {
    getCategories = MockGetCategoriesUseCase();
    getHomeSections = MockGetHomeSectionsUseCase();
    controller = HomeController(getCategories, getHomeSections);
  });

  test('load populates categories and sections', () async {
    when(() => getCategories())
        .thenAnswer((_) async => Success([testCategoryEntity]));
    when(() => getHomeSections())
        .thenAnswer((_) async => Success([testHomeSectionEntity]));

    await controller.load();

    expect(controller.categories, hasLength(1));
    expect(controller.categories.first.id, 'wines');
    expect(controller.sections, hasLength(1));
    expect(
      controller.sectionByType(HomeSectionType.recommended)?.id,
      'sec1',
    );
  });

  test('load puts wines before other categories on home', () async {
    const spirits = CategoryEntity(
      id: 'spirits',
      name: 'Spirits',
      label: 'Spirits',
      emoji: '🥃',
    );
    when(() => getCategories())
        .thenAnswer((_) async => Success([spirits, testCategoryEntity]));
    when(() => getHomeSections())
        .thenAnswer((_) async => Success([testHomeSectionEntity]));

    await controller.load();

    expect(controller.categories.map((c) => c.id).toList(), ['wines', 'spirits']);
  });

  test('sectionByType returns null when missing', () async {
    when(() => getCategories()).thenAnswer((_) async => Success([]));
    when(() => getHomeSections()).thenAnswer((_) async => Success([]));

    await controller.load();

    expect(controller.sectionByType(HomeSectionType.offers), isNull);
  });
}
