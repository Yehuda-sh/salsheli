// 📄 File: lib/services/prefs_service.dart
//
// 🇮🇱 שירות לניהול SharedPreferences באפליקציה.
//     - מספק API פשוט לשמירת ערכים (String, int, bool, double, List).
//     - בנוי כ-Singleton – מופע יחיד זמין בכל מקום.
//     - מאפשר החלפה עתידית ב-Hive/SQLite בלי לשנות את שאר הקוד.
//
// 🇬🇧 Service for managing SharedPreferences in the app.
//     - Provides simple API for saving values (String, int, bool, double, List).
//     - Implemented as a Singleton – single instance available everywhere.
//     - Can be swapped in future with Hive/SQLite without changing other code.
//

import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final PrefsService _instance = PrefsService._internal();
  late SharedPreferences _prefs;

  /// 🇮🇱 גישה יחידה למופע PrefsService
  /// 🇬🇧 Singleton access to PrefsService instance
  factory PrefsService() => _instance;

  PrefsService._internal();

  /// 🇮🇱 חובה לקרוא לפני שימוש – טוען את SharedPreferences מהמערכת
  /// 🇬🇧 Must be called before usage – loads SharedPreferences from system
  static Future<void> init() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }

  // === String ===
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  // === Bool ===
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  // === Int ===
  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  // === Double ===
  double? getDouble(String key) => _prefs.getDouble(key);
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  // === String List ===
  List<String>? getStringList(String key) => _prefs.getStringList(key);
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  // === Remove & Clear ===
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
