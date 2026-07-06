import '../../domain/entities/product_entity.dart';

/// Data transfer object for Firestore/JSON serialization.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.oldPrice,
    required this.description,
    required this.volume,
    this.alcoholPercentage,
    this.country,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.isFeatured,
    this.placeholderColor,
    this.variants = const [],
    this.foodPairing,
    this.tastingNotes,
    this.winery,
    this.servingTemp,
    this.imageUrl,
  });

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      brand: entity.brand,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      price: entity.price,
      oldPrice: entity.oldPrice,
      description: entity.description,
      volume: entity.volume,
      alcoholPercentage: entity.alcoholPercentage,
      country: entity.country,
      type: entity.type,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      inStock: entity.inStock,
      isFeatured: entity.isFeatured,
      placeholderColor: entity.placeholderColor,
      variants: entity.variants,
      foodPairing: entity.foodPairing,
      tastingNotes: entity.tastingNotes,
      winery: entity.winery,
      servingTemp: entity.servingTemp,
      imageUrl: entity.imageUrl,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      price: (json['price'] as num).toDouble(),
      oldPrice: json['oldPrice'] != null
          ? (json['oldPrice'] as num).toDouble()
          : null,
      description: json['description'] as String? ?? '',
      volume: json['volume'] as String? ?? '',
      alcoholPercentage: json['alcoholPercentage'] != null
          ? (json['alcoholPercentage'] as num).toDouble()
          : null,
      country: json['country'] as String?,
      type: json['type'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      inStock: json['inStock'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      placeholderColor: json['placeholderColor'] as int?,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      foodPairing: json['foodPairing'] as String?,
      tastingNotes: json['tastingNotes'] as String?,
      winery: json['winery'] as String?,
      servingTemp: json['servingTemp'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final String categoryName;
  final double price;
  final double? oldPrice;
  final String description;
  final String volume;
  final double? alcoholPercentage;
  final String? country;
  final String type;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final bool isFeatured;
  final int? placeholderColor;
  final List<String> variants;
  final String? foodPairing;
  final String? tastingNotes;
  final String? winery;
  final String? servingTemp;
  final String? imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'price': price,
      'oldPrice': oldPrice,
      'description': description,
      'volume': volume,
      'alcoholPercentage': alcoholPercentage,
      'country': country,
      'type': type,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'isFeatured': isFeatured,
      'placeholderColor': placeholderColor,
      'variants': variants,
      'foodPairing': foodPairing,
      'tastingNotes': tastingNotes,
      'winery': winery,
      'servingTemp': servingTemp,
      'imageUrl': imageUrl,
    };
  }
}
