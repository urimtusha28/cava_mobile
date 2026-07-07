/// JSON shape persisted for guest cart lines (no full [ProductEntity]).
class StoredCartItemModel {
  const StoredCartItemModel({
    required this.productId,
    required this.quantity,
    this.selectedVariant,
    required this.addedAt,
  });

  factory StoredCartItemModel.fromJson(Map<String, dynamic> json) {
    return StoredCartItemModel(
      productId: json['productId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      selectedVariant: json['selectedVariant'] as String?,
      addedAt: json['addedAt'] as String,
    );
  }

  final String productId;
  final int quantity;
  final String? selectedVariant;
  final String addedAt;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        if (selectedVariant != null) 'selectedVariant': selectedVariant,
        'addedAt': addedAt,
      };
}
