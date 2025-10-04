// 📄 File: lib/services/local_storage_service.dart
//
// 🇮🇱 שירות לאחסון מקומי של נתונים גדולים/מורכבים.
//     - מיועד לשמירת רשימות, קבלות, מלאי וכו' בצורה מאורגנת.
//     - כרגע משתמש ב-SharedPreferences (פשוט), בעתיד אפשר להחליף ל-Hive/SQLite.
//     - מספק API אחיד לשמירה/שליפה/מחיקה.
//
// 🇬🇧 Service for local storage of structured/large data.
//     - Designed for storing lists, receipts, inventory, etc.
//     - Currently uses SharedPreferences (simple), can be swapped to Hive/SQLite.
//     - Provides unified API for save/load/delete.
//

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// שמירה של אובייקט JSON (Map/List) לפי מפתח
  Future<void> saveJson(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(value);
    await prefs.setString(key, encoded);
  }

  /// טעינת אובייקט JSON לפי מפתח
  Future<dynamic> loadJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// מחיקת ערך לפי מפתח
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// בדיקה אם קיים ערך
  Future<bool> contains(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
