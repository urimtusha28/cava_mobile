import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchStorage {
  static const String _storageKey = 'recent_searches_v1';
  static const int _maxEntries = 8;

  Future<List<String>> readQueries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<String>().toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> addQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await readQueries();
    final sanitized = query.trim();
    if (sanitized.isEmpty) {
      return;
    }

    final updated = <String>[sanitized, ...current.where((q) => q != sanitized)];
    if (updated.length > _maxEntries) {
      updated.removeRange(_maxEntries, updated.length);
    }

    await prefs.setString(_storageKey, jsonEncode(updated));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

