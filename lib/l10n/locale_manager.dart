// 📄 lib/l10n/locale_manager.dart
//
// 🌐 Locale manager — switches between Hebrew and English strings.
// Persists choice in SharedPreferences.
//
// Version: 1.1 (13/03/2026)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app locales
enum AppLocale {
  he('he', 'עברית', TextDirection.rtl),
  en('en', 'English', TextDirection.ltr);

  const AppLocale(this.code, this.displayName, this.direction);
  final String code;
  final String displayName;
  final TextDirection direction;

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocale.he,
    );
  }
}

/// 🌐 Global locale manager
/// Controls which language strings are used throughout the app.
/// Persists locale choice in SharedPreferences.
class LocaleManager extends ChangeNotifier {
  LocaleManager._();
  static final LocaleManager instance = LocaleManager._();

  static const _prefKey = 'app_locale';

  AppLocale _locale = AppLocale.he;

  AppLocale get locale => _locale;
  String get languageCode => _locale.code;
  TextDirection get textDirection => _locale.direction;
  bool get isRtl => _locale.direction == TextDirection.rtl;
  bool get isHebrew => _locale == AppLocale.he;
  bool get isEnglish => _locale == AppLocale.en;

  /// Load saved locale from SharedPreferences.
  /// Call once at app startup (before runApp or in main).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null) {
      _locale = AppLocale.fromCode(code);
    }
  }

  /// Switch locale, notify listeners, and persist.
  void setLocale(AppLocale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
    _persist();
  }

  /// Switch by language code string.
  void setLocaleByCode(String code) {
    setLocale(AppLocale.fromCode(code));
  }

  /// Toggle between Hebrew and English.
  void toggleLocale() {
    setLocale(_locale == AppLocale.he ? AppLocale.en : AppLocale.he);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _locale.code);
  }
}
