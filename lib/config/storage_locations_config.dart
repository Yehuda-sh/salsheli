// 📄 lib/config/storage_locations_config.dart
//
// הגדרות מיקומי אחסון במזווה - 4 מיקומים (מזווה, מקרר, מקפיא, אחר).
// כולל אמוג'י, אייקון, ופונקציות לקבלת שם/תיאור מ-AppStrings.
//
// 📌 API מרכזי:
//    - StorageLocationsConfig.getLocationInfo(id) - מחזיר LocationInfo מלא
//    - StorageLocationsConfig.getName(id) - קיצור ל-getLocationInfo(id).name
//    - StorageLocationsConfig.getIcon(id) - קיצור ל-getLocationInfo(id).icon
//
// ✅ תיקונים:
//    - טקסטים מ-AppStrings (i18n ready)
//    - אייקונים ייחודיים לכל מיקום (תוקן: מזווה ≠ מקרר)
//    - הוסר "משטח מטבח" - לא מיקום אחסון אמיתי
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

  static const List<String> allLocations = [
    mainPantry,
    refrigerator,
    freezer,
    other,
  ];

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
    _ensureNoDuplicateIds();
    return _locationData[locationId]?.name ?? AppStrings.inventory.locationUnknown;
  }

  /// מחזיר את האייקון של המיקום
  /// 📌 קיצור ל-getLocationInfo(id).icon
  static IconData getIcon(String locationId) {
    return _locationData[locationId]?.icon ?? Icons.help_outline;
  }

  /// מחזיר את המידע המלא על המיקום (API מרכזי)
  ///
  /// Example:
  /// ```dart
  /// final info = StorageLocationsConfig.getLocationInfo('main_pantry');
  /// print(info.emoji); // 🗄️
  /// print(info.name);  // מזווה
  /// ```
  static LocationInfo getLocationInfo(String locationId) {
    return _locationData[locationId] ??
        const LocationInfo(
          id: 'unknown',
          emoji: '❓',
          icon: Icons.help_outline,
        );
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

  static bool _idsValidated = false;

  /// 🔍 בדיקת ייחודיות IDs (רצה פעם אחת בדיבאג)
  static void _ensureNoDuplicateIds() {
    if (_idsValidated) return;
    _idsValidated = true;

    final ids = <String>{};
    for (final id in allLocations) {
      if (ids.contains(id)) {
        assert(false, 'כפילות ID במיקומי אחסון! ID: "$id"');
      }
      ids.add(id);
    }

    // ודא שכל מיקום ב-allLocations קיים ב-_locationData
    for (final id in allLocations) {
      if (!_locationData.containsKey(id)) {
        assert(false, 'מיקום "$id" נמצא ב-allLocations אך חסר ב-_locationData!');
      }
    }

    if (kDebugMode) {
      debugPrint('✅ StorageLocationsConfig: ${allLocations.length} מיקומים, כל ה-IDs ייחודיים');
    }
  }
}
