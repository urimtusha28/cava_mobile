import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/stored_cart_item_model.dart';

/// SharedPreferences persistence for guest cart lines.
class CartLocalStorage {
  static const storageKey = 'guest_cart_items_v1';

  Future<List<StoredCartItemModel>> readItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(StoredCartItemModel.fromJson)
        .toList(growable: false);
  }

  Future<void> writeItems(List<StoredCartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
