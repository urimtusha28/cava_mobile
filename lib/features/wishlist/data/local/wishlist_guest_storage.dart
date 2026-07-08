import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/stored_wishlist_entry_model.dart';

/// SharedPreferences persistence for guest wishlist entries.
class WishlistGuestStorage {
  static const storageKey = 'guest_wishlist_items_v1';

  Future<List<StoredWishlistEntryModel>> readEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      final entries = <StoredWishlistEntryModel>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final entry = StoredWishlistEntryModel.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (entry.productId.trim().isEmpty) {
          continue;
        }
        entries.add(entry);
      }
      return entries;
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeEntries(List<StoredWishlistEntryModel> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
