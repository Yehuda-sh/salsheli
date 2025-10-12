// 📄 File: lib/config/pantry_config.dart
//
// 🎯 מטרה: תצורה מרכזית לניהול מזווה - יחידות, קטגוריות, מיקומים
//
// 📋 כולל:
// - יחידות מדידה (ק"ג, ליטר, יחידות...)
// - קטגוריות מוצרים (פסטה, ירקות, חלב...)
// - מיקומי אחסון (מזווה, מקרר, מקפיא...)
//
// 🔗 Dependencies:
// - storage_locations_config.dart - מיקומי אחסון
//
// 🎯 שימוש:
// ```dart
// import '../config/pantry_config.dart';
// 
// // יחידות
// items: PantryConfig.unitOptions.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList()
// 
// // קטגוריות
// items: PantryConfig.categoryOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList()
// 
// // מיקומים (משתמש ב-StorageLocationsConfig)
// items: PantryConfig.locationOptions.map((loc) => ...).toList()
// ```
//
// 📝 הערות:
// - i18n ready - כל המחרוזות מוכנות למעבר ל-AppStrings
// - Keys באנגלית (pasta_rice), Values בעברית (פסטה ואורז)
// - מיקומים מגיעים מ-StorageLocationsConfig (single source of truth)
//
// Version: 1.0
// Last Updated: 10/10/2025

import '../config/storage_locations_config.dart';

/// תצורה מרכזית לניהול מזווה
class PantryConfig {
  const PantryConfig._();

  // ========================================
  // יחידות מדידה
  // ========================================

  /// רשימת יחידות מדידה זמינות
  /// 
  /// כולל: יחידות, משקל (ק"ג, גרם), נפח (ליטר, מ"ל)
  static const List<String> unitOptions = [
    "יחידות",
    "ק\"ג",
    "גרם",
    "ליטר",
    "מ\"ל",
  ];

  /// יחידת ברירת מחדל
  static const String defaultUnit = "יחידות";

  // ========================================
  // קטגוריות מוצרים
  // ========================================

  /// מיפוי קטגוריות: key (באנגלית) → value (בעברית)
  /// 
  /// Keys משמשים ב-Firestore/DB
  /// Values מוצגים ב-UI
  /// 
  /// 💡 עתיד: להעביר ל-AppStrings.pantry.category* לתמיכה ב-i18n
  static const Map<String, String> categoryOptions = {
    "pasta_rice": "פסטה ואורז",
    "vegetables": "ירקות",
    "fruits": "פירות",
    "meat": "בשר",
    "dairy": "מוצרי חלב",
    "bakery": "מאפים",
    "other": "אחר",
  };

  /// קטגוריית ברירת מחדל
  static const String defaultCategory = "pasta_rice";

  /// קבלת שם קטגוריה לפי key
  /// 
  /// אם ה-key לא קיים, מחזיר את ה-key עצמו
  static String getCategoryName(String key) {
    return categoryOptions[key] ?? key;
  }

  /// בדיקה אם קטגוריה תקינה
  static bool isValidCategory(String key) {
    return categoryOptions.containsKey(key);
  }

  /// קבלת key קטגוריה בטוח (עם fallback)
  static String getCategorySafe(String? key) {
    if (key == null || !isValidCategory(key)) {
      return defaultCategory;
    }
    return key;
  }

  // ========================================
  // מיקומי אחסון
  // ========================================

  /// רשימת מיקומי אחסון ראשיים
  /// 
  /// מקור: StorageLocationsConfig.primaryLocations
  /// 
  /// 💡 Single Source of Truth - אל תשכפל מיקומים!
  static List<String> get locationOptions => 
      StorageLocationsConfig.primaryLocations;

  /// מיקום ברירת מחדל
  static String get defaultLocation => 
      StorageLocationsConfig.mainPantry;

  /// קבלת שם מיקום
  static String getLocationName(String locationId) {
    return StorageLocationsConfig.getName(locationId);
  }

  /// בדיקה אם מיקום תקין
  static bool isValidLocation(String locationId) {
    return StorageLocationsConfig.isValidLocation(locationId);
  }

  /// קבלת מיקום בטוח (עם fallback)
  static String getLocationSafe(String? locationId) {
    if (locationId == null || !isValidLocation(locationId)) {
      return defaultLocation;
    }
    return locationId;
  }

  // ========================================
  // Helpers
  // ========================================

  /// קבלת כל הקטגוריות כרשימה
  static List<String> get allCategoryKeys => categoryOptions.keys.toList();

  /// קבלת כל שמות הקטגוריות
  static List<String> get allCategoryNames => categoryOptions.values.toList();
}
