import '../../data/models/stored_cart_item_model.dart';

abstract final class CartMergeResolver {
  static List<StoredCartItemModel> merge({
    required List<StoredCartItemModel> guestEntries,
    required List<StoredCartItemModel> cloudEntries,
  }) {
    final merged = <String, StoredCartItemModel>{};

    for (final entry in cloudEntries) {
      if (entry.quantity <= 0) {
        continue;
      }
      merged[entry.productId] = entry;
    }

    for (final guest in guestEntries) {
      if (guest.quantity <= 0) {
        continue;
      }

      final existing = merged[guest.productId];
      if (existing == null) {
        merged[guest.productId] = guest;
        continue;
      }

      merged[guest.productId] = StoredCartItemModel(
        productId: guest.productId,
        quantity: existing.quantity + guest.quantity,
        selectedVariant: guest.selectedVariant ?? existing.selectedVariant,
        addedAt: _earlierAddedAt(existing.addedAt, guest.addedAt),
      );
    }

    return merged.values.toList(growable: false);
  }

  static String _earlierAddedAt(String first, String second) {
    try {
      final firstDate = DateTime.parse(first);
      final secondDate = DateTime.parse(second);
      return firstDate.isBefore(secondDate) ? first : second;
    } catch (_) {
      return first.isNotEmpty ? first : second;
    }
  }
}
