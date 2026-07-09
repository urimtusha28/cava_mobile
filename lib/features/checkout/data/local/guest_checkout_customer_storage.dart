import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/guest_checkout_customer.dart';

class GuestCheckoutCustomerStorage {
  static const storageKey = 'guest_checkout_customer_v1';

  Future<GuestCheckoutCustomer?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) {
        return null;
      }
      return GuestCheckoutCustomer.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(GuestCheckoutCustomer customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(customer.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
