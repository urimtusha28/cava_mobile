import 'package:cava_ecommerce/features/home/data/mappers/home_section_mapper.dart';
import 'package:cava_ecommerce/features/home/data/models/home_section_model.dart';
import 'package:cava_ecommerce/features/home/domain/entities/home_section_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('HomeSectionMapper', () {
    test('toEntityType maps all variants', () {
      expect(
        HomeSectionMapper.toEntityType(HomeSectionTypeModel.recommended),
        HomeSectionType.recommended,
      );
      expect(
        HomeSectionMapper.toEntityType(HomeSectionTypeModel.bestSellers),
        HomeSectionType.bestSellers,
      );
      expect(
        HomeSectionMapper.toEntityType(HomeSectionTypeModel.offers),
        HomeSectionType.offers,
      );
    });

    test('toEntity attaches products', () {
      final entity = HomeSectionMapper.toEntity(
        testHomeSectionModel,
        products: [testProductEntity],
      );
      expect(entity.title, 'Të rekomanduara');
      expect(entity.products, hasLength(1));
    });
  });
}
