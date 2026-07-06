import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';

abstract final class ProductMapper {
  static ProductEntity toEntity(ProductModel model) {
    final categoryLabel = model.category ?? model.categoryName ?? '';
    final categorySlug = model.categoryId?.isNotEmpty == true
        ? model.categoryId!
        : ProductModel.categorySlug(categoryLabel);
    final volume = model.details?.volume ?? model.volume ?? '';
    final abv = ProductModel.parseAbv(model.details?.abv) ??
        model.alcoholPercentage;
    final brand = model.brandProducer ?? model.brand ?? '';
    final oldPrice = model.originalPrice ?? model.oldPrice;
    final featured = model.topPick || model.isFeatured;
    final inStock = model.stock > 0 || model.inStock;

    return ProductEntity(
      id: model.id,
      name: model.name,
      brand: brand,
      categoryId: categorySlug,
      categoryName: categoryLabel,
      price: model.price,
      oldPrice: oldPrice,
      description: model.description,
      volume: volume,
      alcoholPercentage: abv,
      country: model.origin ?? model.country,
      type: model.subCategory ?? model.type ?? '',
      rating: model.rating,
      reviewCount: model.reviewCount,
      inStock: inStock,
      isFeatured: featured,
      placeholderColor: model.placeholderColor,
      variants: model.variants,
      foodPairing: model.foodPairing,
      tastingNotes: model.tastingNotes,
      winery: model.winery ?? model.brandProducer,
      servingTemp: model.servingTemp,
      imageUrl: model.cardImageUrl,
      detailImageUrl: model.detailImageUrl,
    );
  }

  static ProductModel toModel(ProductEntity entity) {
    return ProductModel.fromEntity(entity);
  }

  static List<ProductEntity> toEntityList(List<ProductModel> models) {
    return models.map(toEntity).toList(growable: false);
  }
}
