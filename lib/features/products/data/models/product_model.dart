import '../../domain/entities/product_entity.dart';

/// Nested image URLs from web Firebase `products.images`.
class ProductImagesModel {
  const ProductImagesModel({
    this.thumb,
    this.medium,
    this.original,
  });

  factory ProductImagesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProductImagesModel();
    }
    return ProductImagesModel(
      thumb: json['thumb'] as String?,
      medium: json['medium'] as String?,
      original: json['original'] as String?,
    );
  }

  final String? thumb;
  final String? medium;
  final String? original;

  Map<String, dynamic> toJson() => {
        if (thumb != null) 'thumb': thumb,
        if (medium != null) 'medium': medium,
        if (original != null) 'original': original,
      };
}

/// Nested product details from web Firebase `products.details`.
class ProductDetailsModel {
  const ProductDetailsModel({
    this.abv,
    this.volume,
    this.region,
    this.vintageYear,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProductDetailsModel();
    }
    return ProductDetailsModel(
      abv: json['abv'],
      volume: json['volume'] as String?,
      region: json['region'] as String?,
      vintageYear: json['vintageYear'],
    );
  }

  final Object? abv;
  final String? volume;
  final String? region;
  final Object? vintageYear;

  Map<String, dynamic> toJson() => {
        if (abv != null) 'abv': abv,
        if (volume != null) 'volume': volume,
        if (region != null) 'region': region,
        if (vintageYear != null) 'vintageYear': vintageYear,
      };
}

/// Data transfer object aligned with web Firebase `products` sales schema.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.stock = 0,
    this.status,
    this.productStatus,
    this.category,
    this.subCategory,
    this.imageUrl,
    this.images,
    this.brandProducer,
    this.origin,
    this.originCode,
    this.details,
    this.topPick = false,
    // Legacy mock/mobile fields — populated from mock or as fallbacks.
    this.brand,
    this.categoryId,
    this.categoryName,
    this.oldPrice,
    this.volume,
    this.alcoholPercentage,
    this.country,
    this.type,
    this.rating = 0,
    this.reviewCount = 0,
    this.inStock = true,
    this.isFeatured = false,
    this.placeholderColor,
    this.variants = const [],
    this.foodPairing,
    this.tastingNotes,
    this.winery,
    this.servingTemp,
  });

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      originalPrice: entity.oldPrice,
      oldPrice: entity.oldPrice,
      stock: entity.inStock ? 1 : 0,
      category: entity.categoryName,
      subCategory: entity.type,
      imageUrl: entity.imageUrl,
      brandProducer: entity.brand,
      brand: entity.brand,
      origin: entity.country,
      country: entity.country,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      volume: entity.volume,
      alcoholPercentage: entity.alcoholPercentage,
      type: entity.type,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      inStock: entity.inStock,
      topPick: entity.isFeatured,
      isFeatured: entity.isFeatured,
      placeholderColor: entity.placeholderColor,
      variants: entity.variants,
      foodPairing: entity.foodPairing,
      tastingNotes: entity.tastingNotes,
      winery: entity.winery,
      servingTemp: entity.servingTemp,
    );
  }

  /// Parses web Firebase schema or legacy mock JSON.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final imagesJson = json['images'];
    final detailsJson = json['details'];

    final isWebSchema = !json.containsKey('categoryId') &&
        (json.containsKey('brandProducer') ||
            json.containsKey('topPick') ||
            json.containsKey('originalPrice') ||
            json.containsKey('productStatus') ||
            imagesJson is Map<String, dynamic> ||
            detailsJson is Map<String, dynamic>);

    if (isWebSchema) {
      return ProductModel(
        id: id,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: _readDouble(json['price']),
        originalPrice: _readNullableDouble(json['originalPrice']),
        stock: _readInt(json['stock']),
        status: json['status'] as String?,
        productStatus: json['productStatus'] as String?,
        category: json['category'] as String?,
        subCategory: json['subCategory'] as String?,
        imageUrl: json['imageUrl'] as String?,
        images: imagesJson is Map<String, dynamic>
            ? ProductImagesModel.fromJson(imagesJson)
            : null,
        brandProducer: json['brandProducer'] as String?,
        origin: json['origin'] as String?,
        originCode: json['originCode'] as String?,
        details: detailsJson is Map<String, dynamic>
            ? ProductDetailsModel.fromJson(detailsJson)
            : null,
        topPick: json['topPick'] as bool? ?? false,
      );
    }

    return ProductModel(
      id: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _readDouble(json['price']),
      originalPrice: _readNullableDouble(json['oldPrice']),
      oldPrice: _readNullableDouble(json['oldPrice']),
      stock: (json['inStock'] as bool? ?? true) ? 1 : 0,
      category: json['categoryName'] as String?,
      subCategory: json['type'] as String?,
      imageUrl: json['imageUrl'] as String?,
      brandProducer: json['brand'] as String?,
      brand: json['brand'] as String?,
      origin: json['country'] as String?,
      country: json['country'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      volume: json['volume'] as String? ?? '',
      alcoholPercentage: _readNullableDouble(json['alcoholPercentage']),
      type: json['type'] as String? ?? '',
      rating: _readDouble(json['rating']),
      reviewCount: _readInt(json['reviewCount']),
      inStock: json['inStock'] as bool? ?? true,
      topPick: json['isFeatured'] as bool? ?? false,
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
    );
  }

  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int stock;
  final String? status;
  final String? productStatus;
  final String? category;
  final String? subCategory;
  final String? imageUrl;
  final ProductImagesModel? images;
  final String? brandProducer;
  final String? origin;
  final String? originCode;
  final ProductDetailsModel? details;
  final bool topPick;

  // Legacy mock/mobile fields.
  final String? brand;
  final String? categoryId;
  final String? categoryName;
  final double? oldPrice;
  final String? volume;
  final double? alcoholPercentage;
  final String? country;
  final String? type;
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

  /// Card/list image: `images.thumb ?? imageUrl`.
  String? get cardImageUrl => images?.thumb ?? imageUrl;

  /// Detail hero image: `images.medium ?? images.original ?? imageUrl`.
  String? get detailImageUrl =>
      images?.medium ?? images?.original ?? imageUrl;

  /// Whether the product is sellable/visible on mobile.
  bool get isActiveForSale => ProductModel.isActiveProductStatus(productStatus);

  /// Whether the product has available stock.
  bool get hasStock => stock > 0;

  static bool isActiveProductStatus(String? productStatus) {
    if (productStatus == null || productStatus.isEmpty) {
      return true;
    }
    switch (productStatus.toLowerCase()) {
      case 'draft':
      case 'hidden':
        return false;
      case 'active':
        return true;
      default:
        return true;
    }
  }

  static String categorySlug(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  static double? parseAbv(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final normalized = value.replaceAll('%', '').trim();
      return double.tryParse(normalized);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      if (oldPrice != null) 'oldPrice': oldPrice,
      'stock': stock,
      if (status != null) 'status': status,
      if (productStatus != null) 'productStatus': productStatus,
      if (category != null) 'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (images != null) 'images': images!.toJson(),
      if (brandProducer != null) 'brandProducer': brandProducer,
      if (brand != null) 'brand': brand,
      if (origin != null) 'origin': origin,
      if (originCode != null) 'originCode': originCode,
      if (details != null) 'details': details!.toJson(),
      'topPick': topPick || isFeatured,
      if (categoryId != null) 'categoryId': categoryId,
      if (categoryName != null) 'categoryName': categoryName,
      if (volume != null) 'volume': volume,
      if (alcoholPercentage != null) 'alcoholPercentage': alcoholPercentage,
      if (country != null) 'country': country,
      if (type != null) 'type': type,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'isFeatured': isFeatured,
      if (placeholderColor != null) 'placeholderColor': placeholderColor,
      'variants': variants,
      if (foodPairing != null) 'foodPairing': foodPairing,
      if (tastingNotes != null) 'tastingNotes': tastingNotes,
      if (winery != null) 'winery': winery,
      if (servingTemp != null) 'servingTemp': servingTemp,
    };
  }

  static double _readDouble(Object? value, [double fallback = 0]) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  static double? _readNullableDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static int _readInt(Object? value, [int fallback = 0]) {
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }
}
