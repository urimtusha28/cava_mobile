class ProductEntity {
  const ProductEntity({
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
    required this.stock,
    required this.isFeatured,
    this.placeholderColor,
    this.variants = const [],
    this.foodPairing,
    this.tastingNotes,
    this.winery,
    this.servingTemp,
    this.imageUrl,
    this.detailImageUrl,
  });

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

  /// Available units from inventory (Firestore `stock`).
  final int stock;

  final bool isFeatured;
  final int? placeholderColor;
  final List<String> variants;
  final String? foodPairing;
  final String? tastingNotes;
  final String? winery;
  final String? servingTemp;
  final String? imageUrl;
  final String? detailImageUrl;

  /// Sellable when inventory has at least one unit.
  bool get inStock => stock > 0;
}
