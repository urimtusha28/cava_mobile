import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';

abstract final class ProductMapper {
  static ProductEntity toEntity(ProductModel model) {
    return ProductEntity(
      id: model.id,
      name: model.name,
      brand: model.brand,
      categoryId: model.categoryId,
      categoryName: model.categoryName,
      price: model.price,
      oldPrice: model.oldPrice,
      description: model.description,
      volume: model.volume,
      alcoholPercentage: model.alcoholPercentage,
      country: model.country,
      type: model.type,
      rating: model.rating,
      reviewCount: model.reviewCount,
      inStock: model.inStock,
      isFeatured: model.isFeatured,
      placeholderColor: model.placeholderColor,
      variants: model.variants,
      foodPairing: model.foodPairing,
      tastingNotes: model.tastingNotes,
      winery: model.winery,
      servingTemp: model.servingTemp,
      imageUrl: model.imageUrl,
    );
  }

  static ProductModel toModel(ProductEntity entity) {
    return ProductModel.fromEntity(entity);
  }

  static List<ProductEntity> toEntityList(List<ProductModel> models) {
    return models.map(toEntity).toList(growable: false);
  }
}
