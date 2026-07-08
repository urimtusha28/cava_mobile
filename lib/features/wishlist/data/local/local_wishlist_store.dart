import '../models/stored_wishlist_entry_model.dart';

/// In-memory guest wishlist entries (product ids only) until persisted/synced.
abstract final class LocalWishlistStore {
  static final List<StoredWishlistEntryModel> _entries =
      <StoredWishlistEntryModel>[];

  static List<StoredWishlistEntryModel> snapshot() =>
      List<StoredWishlistEntryModel>.unmodifiable(_entries);

  static int get count => _entries.length;

  static void clear() => _entries.clear();

  static void replaceAll(List<StoredWishlistEntryModel> entries) {
    _entries
      ..clear()
      ..addAll(entries);
  }

  static bool contains(String productId) =>
      _entries.any((entry) => entry.productId == productId);

  static void addEntry(StoredWishlistEntryModel entry) {
    if (contains(entry.productId)) {
      return;
    }
    _entries.add(entry);
  }

  static void remove(String productId) {
    _entries.removeWhere((entry) => entry.productId == productId);
  }
}
