import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class OnboardingStorage {
  static const _key = 'onboarding_complete';

  static Future<bool> isComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (e, stack) {
      debugPrint('OnboardingStorage.isComplete failed: $e\n$stack');
      return false;
    }
  }

  static Future<void> markComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (e, stack) {
      debugPrint('OnboardingStorage.markComplete failed: $e\n$stack');
    }
  }
}
