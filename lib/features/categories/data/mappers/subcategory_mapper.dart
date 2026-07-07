import '../../domain/entities/subcategory_entity.dart';
import '../models/subcategory_model.dart';

abstract final class SubcategoryMapper {
  static SubcategoryEntity toEntity(SubcategoryModel model) {
    return SubcategoryEntity(
      id: model.id,
      label: model.label,
      matchTypes: model.matchTypes,
      matchKeywords: model.matchKeywords,
      badgeColor: model.badgeColor,
    );
  }

  static SubcategoryModel toModel(SubcategoryEntity entity) {
    return SubcategoryModel.fromEntity(entity);
  }

  static List<SubcategoryEntity> toEntityList(List<SubcategoryModel> models) {
    return models.map(toEntity).toList(growable: false);
  }
}
