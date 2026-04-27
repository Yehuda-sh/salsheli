// lib/l10n/locale_manager.dart — Locale manager — persist language preference, switch between Hebrew/English

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app locales
enum AppLocale {
  he('he', TextDirection.rtl),
  en('en', TextDirection.ltr);

  const AppLocale(this.code, this.direction);
  final String code;
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

  String get languageCode => _locale.code;
  TextDirection get textDirection => _locale.direction;
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

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _locale.code);
  }
}
