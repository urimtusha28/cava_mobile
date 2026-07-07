import '../../domain/entities/category_entity.dart';
import '../models/category_model.dart';

abstract final class CategoryMapper {
  static CategoryEntity toEntity(CategoryModel model) {
    final routeId =
        model.slug.isNotEmpty ? model.slug : model.id;
    return CategoryEntity(
      id: routeId,
      name: model.name,
      label: model.label.isNotEmpty ? model.label : model.name,
      emoji: model.emoji,
      badgeColor: model.badgeColor,
    );
  }

  static CategoryModel toModel(CategoryEntity entity) {
    return CategoryModel.fromEntity(entity);
  }

  static List<CategoryEntity> toEntityList(List<CategoryModel> models) {
    return models.map(toEntity).toList(growable: false);
  }
}
