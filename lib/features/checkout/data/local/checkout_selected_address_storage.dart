import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last delivery address selected during checkout.
class CheckoutSelectedAddressStorage {
  static const storageKey = 'checkout_selected_address_id_v1';

  Future<String?> readAddressId() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(storageKey);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> writeAddressId(String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, addressId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
