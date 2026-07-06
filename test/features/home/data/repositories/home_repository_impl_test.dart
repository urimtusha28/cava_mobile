import 'package:cava_ecommerce/features/home/domain/entities/home_section_entity.dart';
import 'package:cava_ecommerce/features/home/data/models/home_section_model.dart';
import 'package:cava_ecommerce/features/home/data/repositories/home_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockHomeDataSource homeDataSource;
  late MockProductRepository productRepository;
  late HomeRepositoryImpl repository;

  setUp(() {
    homeDataSource = MockHomeDataSource();
    productRepository = MockProductRepository();
    repository = HomeRepositoryImpl(homeDataSource, productRepository);
  });

  test('getSections resolves products per section type', () async {
    when(() => homeDataSource.getSectionConfigs()).thenReturn([
      const HomeSectionModel(
        id: 's1',
        title: 'Rec',
        type: HomeSectionTypeModel.recommended,
        seeAllRoute: '/wines',
      ),
    ]);
    when(() => productRepository.getRecommended())
        .thenAnswer((_) async => [testProductEntity]);

    final sections = await repository.getSections();

    expect(sections, hasLength(1));
    expect(sections.first.products, hasLength(1));
    expect(sections.first.type, HomeSectionType.recommended);
  });
}
