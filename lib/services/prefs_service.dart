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
import 'package:flutter/foundation.dart';

/// 🔐 שירות לניהול SharedPreferences באפליקציה
/// 
/// **תפקידים:**
/// - ספקת API פשוט לשמירת ערכים (String, int, bool, double, List)
/// - Singleton pattern - מופע יחיד לכל האפליקציה
/// - מאפשר החלפה עתידית ב-Hive/SQLite ללא שינוי בקוד אחר
/// 
/// **שימוש:**
/// ```dart
/// // בInitialization
/// await PrefsService.init();
/// 
/// // בכל מקום באפליקציה
/// final prefs = PrefsService();
/// await prefs.setString('user_id', '123');
/// final userId = prefs.getString('user_id');
/// ```
/// 
/// **Features:**
/// - Type-safe getters/setters (String, Bool, Int, Double, StringList)
/// - Remove & Clear operations
/// - No throw exceptions - returns null/false on errors
/// - Singleton ensures single SharedPreferences instance
class PrefsService {
  static final PrefsService _instance = PrefsService._internal();
  late SharedPreferences _prefs;

  /// 🔐 גישה יחידה למופע PrefsService (Singleton pattern)
  /// 
  /// מחזיר את המופע היחיד של PrefsService.
  /// **חובה:** קרא ל-init() קודם ב-main()!
  factory PrefsService() {
    debugPrint('💾 PrefsService: גישה למופע');
    return _instance;
  }

  PrefsService._internal();

  /// אתחול SharedPreferences - **חובה לקרוא בתחילת main()**
  /// 
  /// טוען את SharedPreferences מהמערכת.
  /// אם זה נכשל, זורק exception - **אל תתעלם**!
  /// 
  /// Example:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await PrefsService.init(); // חובה!
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> init() async {
    debugPrint('💾 PrefsService.init(): מתחיל אתחול');
    try {
      _instance._prefs = await SharedPreferences.getInstance();
      debugPrint('✅ PrefsService.init(): אתחול הושלם בהצלחה');
    } catch (e, stackTrace) {
      debugPrint('❌ PrefsService.init(): שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow; // זרוק הלאה - זה critical!
    }
  }

  // === String ===
  
  /// קבלת ערך String
  String? getString(String key) => _prefs.getString(key);
  
  /// שמירת ערך String
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  // === Bool ===
  
  /// קבלת ערך Bool
  bool? getBool(String key) => _prefs.getBool(key);
  
  /// שמירת ערך Bool
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  // === Int ===
  
  /// קבלת ערך Int
  int? getInt(String key) => _prefs.getInt(key);
  
  /// שמירת ערך Int
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  // === Double ===
  
  /// קבלת ערך Double
  double? getDouble(String key) => _prefs.getDouble(key);
  
  /// שמירת ערך Double
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  // === String List ===
  
  /// קבלת רשימת Strings
  List<String>? getStringList(String key) => _prefs.getStringList(key);
  
  /// שמירת רשימת Strings
  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  // === Remove & Clear ===
  
  /// הסרת ערך יחיד לפי מפתח
  Future<bool> remove(String key) => _prefs.remove(key);
  
  /// מחיקת כל הנתונים בPreferences
  /// 
  /// ⚠️ זה מחק הכל - בדר"כ נעשה רק ב-logout
  Future<bool> clear() => _prefs.clear();
}
