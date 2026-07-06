import '../../domain/entities/category_entity.dart';
import '../models/category_model.dart';

abstract final class CategoryMapper {
  static CategoryEntity toEntity(CategoryModel model) {
    return CategoryEntity(
      id: model.id,
      name: model.name,
      label: model.label,
      emoji: model.emoji,
    );
  }

  static CategoryModel toModel(CategoryEntity entity) {
    return CategoryModel.fromEntity(entity);
  }

  static List<CategoryEntity> toEntityList(List<CategoryModel> models) {
    return models.map(toEntity).toList(growable: false);
  }
}
