/// Lightweight guest wishlist entry persisted locally (no full product payload).
class StoredWishlistEntryModel {
  const StoredWishlistEntryModel({
    required this.productId,
    required this.addedAt,
  });

  final String productId;
  final String addedAt;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'addedAt': addedAt,
      };

  factory StoredWishlistEntryModel.fromJson(Map<String, dynamic> json) {
    return StoredWishlistEntryModel(
      productId: json['productId'] as String? ?? '',
      addedAt: json['addedAt'] as String? ?? '',
    );
  }
}
