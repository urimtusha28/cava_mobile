import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and notifies the app [Locale]. Default is Albanian (`sq`).
class LocaleController extends ChangeNotifier {
  LocaleController();

  static const _prefsKey = 'app_locale_code_v1';
  static const supported = [Locale('sq'), Locale('en')];
  static const defaultLocale = Locale('sq');

  Locale _locale = defaultLocale;
  bool _loaded = false;

  Locale get locale => _locale;
  bool get isLoaded => _loaded;
  bool get isAlbanian => _locale.languageCode == 'sq';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == 'en' || code == 'sq') {
      _locale = Locale(code!);
    } else {
      _locale = defaultLocale;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final supportedCode = switch (locale.languageCode) {
      'en' => 'en',
      _ => 'sq',
    };
    final next = Locale(supportedCode);
    if (_locale == next) return;
    _locale = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, supportedCode);
  }
}
