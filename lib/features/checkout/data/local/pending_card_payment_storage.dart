import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/quipu_payment_entities.dart';

/// Persists the in-flight card payment (mobile counterpart of the website's
/// sessionStorage transaction id) so verification can resume after the app is
/// backgrounded during the HPP redirect or restarted.
class PendingCardPaymentStorage {
  static const storageKey = 'pending_card_payment_v1';

  Future<PendingCardPayment?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return PendingCardPayment.fromMap(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> write(PendingCardPayment payment) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(payment.toMap()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
