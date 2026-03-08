// 📄 lib/config/storage_locations_config.dart
//
// הגדרות מיקומי אחסון במזווה - 4 מיקומים (מזווה, מקרר, מקפיא, אחר).
// כולל אמוג'י, אייקון, ופונקציות לקבלת שם/תיאור מ-AppStrings.
//
// 📌 API מרכזי:
//    - StorageLocationsConfig.getLocationInfo(id) - מחזיר LocationInfo מלא
//    - StorageLocationsConfig.resolve(id) - מחזיר id תקין (fallback ל-other)
//    - StorageLocationsConfig.getName(id) - קיצור ל-getLocationInfo(id).name
//    - StorageLocationsConfig.getIcon(id) - קיצור ל-getLocationInfo(id).icon
//
// 📜 חוקי עבודה:
// - IDs הם חוזה נתונים: לא משנים IDs לעולם, רק מוסיפים
// - id לא מוכר → fallback ל-other
// - allLocations = סדר UX (מזווה → מקרר → מקפיא → אחר)
// - other חייב להיות אחרון
//
// 🔗 Related: InventoryItem, LocationsProvider, AppStrings.inventory

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

/// מידע על מיקום אחסון
class LocationInfo {
  final String id;
  final String emoji;
  final IconData icon;

  /// Getter לשם - מ-AppStrings
  String get name => _getLocalizedName(id);

  /// Getter לתיאור - מ-AppStrings
  String get description => _getLocalizedDescription(id);

  const LocationInfo({
    required this.id,
    required this.emoji,
    required this.icon,
  });

  /// שם מתורגם לפי id
  static String _getLocalizedName(String id) {
    switch (id) {
      case StorageLocationsConfig.mainPantry:
        return AppStrings.inventory.locationMainPantry;
      case StorageLocationsConfig.refrigerator:
        return AppStrings.inventory.locationRefrigerator;
      case StorageLocationsConfig.freezer:
        return AppStrings.inventory.locationFreezer;
      case StorageLocationsConfig.other:
        return AppStrings.inventory.locationOther;
      default:
        return AppStrings.inventory.locationUnknown;
    }
  }

  /// תיאור מתורגם לפי id
  static String _getLocalizedDescription(String id) {
    switch (id) {
      case StorageLocationsConfig.mainPantry:
        return AppStrings.inventory.locationMainPantryDesc;
      case StorageLocationsConfig.refrigerator:
        return AppStrings.inventory.locationRefrigeratorDesc;
      case StorageLocationsConfig.freezer:
        return AppStrings.inventory.locationFreezerDesc;
      case StorageLocationsConfig.other:
        return AppStrings.inventory.locationOtherDesc;
      default:
        return AppStrings.inventory.locationUnknownDesc;
    }
  }
}

/// תצורת מיקומי אחסון במזווה
class StorageLocationsConfig {
  StorageLocationsConfig._(); // Private constructor

  // ========================================
  // מיקומים זמינים
  // ========================================

  static const String mainPantry = 'main_pantry';
  static const String refrigerator = 'refrigerator';
  static const String freezer = 'freezer';
  static const String other = 'other';

  // ========================================
  // רשימת כל המיקומים
  // ========================================

  /// סדר UX: מזווה → מקרר → מקפיא → אחר
  /// ✅ other חייב להיות אחרון (fallback)
  static const List<String> allLocations = [
    mainPantry,
    refrigerator,
    freezer,
    other, // ✅ תמיד אחרון (fallback)
  ];

  /// ✅ מחזיר id תקין - fallback ל-other
  ///
  /// API בטוח שלא יפיל UI:
  /// - id לא מוכר → מחזיר other
  /// - id == null → מחזיר other
  static String resolve(String? locationId) {
    if (locationId == null) return other;
    if (_locationData.containsKey(locationId)) return locationId;

    if (kDebugMode) {
    }
    return other;
  }

  // ========================================
  // מיפוי למידע מלא
  // ========================================

  // ✅ אייקונים ייחודיים לכל מיקום (תוקן: מזווה ≠ מקרר)
  static const Map<String, LocationInfo> _locationData = {
    mainPantry: LocationInfo(
      id: mainPantry,
      emoji: '🗄️',
      icon: Icons.shelves, // ✅ מדפים - מתאים למזווה
    ),
    refrigerator: LocationInfo(
      id: refrigerator,
      emoji: '🥛', // חלב = מקרר (יותר אינטואיטיבי מ-🧊)
      icon: Icons.kitchen,
    ),
    freezer: LocationInfo(
      id: freezer,
      emoji: '🧊', // קרח = מקפיא
      icon: Icons.ac_unit,
    ),
    other: LocationInfo(
      id: other,
      emoji: '📦',
      icon: Icons.inventory_2, // קופסה
    ),
  };

  // ========================================
  // 🔍 Lookup API
  // ========================================

  /// מחזיר את שם המיקום בעברית (מ-AppStrings)
  /// 📌 קיצור ל-getLocationInfo(id).name
  static String getName(String locationId) {
    // ✅ בדיקת תקינות בזמן פיתוח בלבד
    if (kDebugMode) {
      ensureSanity();
    }
    return getLocationInfo(locationId).name;
  }

  /// מחזיר את האייקון של המיקום
  /// 📌 קיצור ל-getLocationInfo(id).icon
  static IconData getIcon(String locationId) {
    return getLocationInfo(locationId).icon;
  }

  /// מחזיר את המידע המלא על המיקום (API מרכזי)
  ///
  /// ✅ id לא מוכר → fallback ל-other (לא "unknown")
  ///
  /// Example:
  /// ```dart
  /// final info = StorageLocationsConfig.getLocationInfo('main_pantry');
  /// print(info.emoji); // 🗄️
  /// print(info.name);  // מזווה
  /// ```
  static LocationInfo getLocationInfo(String locationId) {
    return _locationData[locationId] ?? _locationData[other]!;
  }

  /// בודק אם מיקום תקין
  /// 
  /// Example:
  /// ```dart
  /// final isValid = StorageLocationsConfig.isValidLocation('refrigerator');
  /// // true
  /// 
  /// final isInvalid = StorageLocationsConfig.isValidLocation('garage');
  /// // false
  /// ```
  static bool isValidLocation(String locationId) {
    return _locationData.containsKey(locationId);
  }

  /// מחזיר רשימת כל המיקומים עם המידע שלהם
  ///
  /// Example:
  /// ```dart
  /// final locations = StorageLocationsConfig.getAllLocationInfo();
  /// for (var info in locations) {
  ///   print('${info.emoji} ${info.name}');
  /// }
  /// ```
  static List<LocationInfo> getAllLocationInfo() {
    return allLocations.map(getLocationInfo).toList();
  }

  // ========================================
  // 🔧 Debug Validation
  // ========================================

  static bool _sanityChecked = false;

  /// 🔍 Sanity check - בדיקת פיתוח בלבד
  ///
  /// מוודא:
  /// 1. אין כפילויות IDs ב-allLocations
  /// 2. התאמה 1:1 בין allLocations ל-_locationData
  /// 3. other הוא אחרון (סדר UX)
  static void ensureSanity() {
    if (!kDebugMode) return;
    if (_sanityChecked) return;
    _sanityChecked = true;

    // 1️⃣ בדיקת כפילויות
    final ids = <String>{};
    for (final id in allLocations) {
      if (ids.contains(id)) {
        assert(false, '❌ StorageLocationsConfig: כפילות ID! "$id"');
      }
      ids.add(id);
    }

    // 2️⃣ בדיקת התאמה 1:1 בין allLocations ל-_locationData
    final listKeys = allLocations.toSet();
    final dataKeys = _locationData.keys.toSet();

    // בדיקת IDs חסרים ב-_locationData
    final missingInData = listKeys.difference(dataKeys);
    if (missingInData.isNotEmpty) {
      assert(false,
        '❌ StorageLocationsConfig: חסר LocationInfo עבור: $missingInData\n'
        'הוסף LocationInfo ל-_locationData',
      );
    }

    // בדיקת IDs מיותרים ב-_locationData
    final extraInData = dataKeys.difference(listKeys);
    if (extraInData.isNotEmpty) {
      assert(false,
        '❌ StorageLocationsConfig: יש LocationInfo ללא הגדרה ב-allLocations: $extraInData\n'
        'הוסף את ה-IDs ל-allLocations או הסר מ-_locationData',
      );
    }

    // 3️⃣ בדיקה ש-other הוא אחרון
    if (allLocations.isNotEmpty && allLocations.last != other) {
      assert(false,
        '❌ StorageLocationsConfig: "$other" חייב להיות אחרון ב-allLocations! '
        'נמצא: "${allLocations.last}"',
      );
    }

  }
}
