// 📄 lib/l10n/locale_manager.dart
//
// 🌐 Locale manager — switches between Hebrew and English strings.
// Usage: AppStrings references work as before (no code changes needed).
// Switch language: LocaleManager.setLocale('en') or LocaleManager.setLocale('he')
//
// Version: 1.0 (13/03/2026)

import 'package:flutter/material.dart';

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
class LocaleManager extends ChangeNotifier {
  LocaleManager._();
  static final LocaleManager instance = LocaleManager._();

  AppLocale _locale = AppLocale.he;

  AppLocale get locale => _locale;
  String get languageCode => _locale.code;
  TextDirection get textDirection => _locale.direction;
  bool get isRtl => _locale.direction == TextDirection.rtl;
  bool get isHebrew => _locale == AppLocale.he;
  bool get isEnglish => _locale == AppLocale.en;

  /// Switch locale and notify listeners
  void setLocale(AppLocale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
  }

  /// Switch by language code string
  void setLocaleByCode(String code) {
    setLocale(AppLocale.fromCode(code));
  }

  /// Toggle between Hebrew and English
  void toggleLocale() {
    setLocale(_locale == AppLocale.he ? AppLocale.en : AppLocale.he);
  }
}
