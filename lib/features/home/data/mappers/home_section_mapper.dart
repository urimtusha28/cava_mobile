import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/home_section_entity.dart';
import '../models/home_section_model.dart';

abstract final class HomeSectionMapper {
  static HomeSectionType toEntityType(HomeSectionTypeModel modelType) {
    return switch (modelType) {
      HomeSectionTypeModel.recommended => HomeSectionType.recommended,
      HomeSectionTypeModel.bestSellers => HomeSectionType.bestSellers,
      HomeSectionTypeModel.offers => HomeSectionType.offers,
    };
  }

  static HomeSectionEntity toEntity(
    HomeSectionModel model, {
    required List<ProductEntity> products,
  }) {
    return HomeSectionEntity(
      id: model.id,
      title: model.title,
      type: toEntityType(model.type),
      seeAllRoute: model.seeAllRoute,
      products: products,
    );
  }
}
