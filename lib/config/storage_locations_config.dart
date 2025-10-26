// 📄 File: lib/config/storage_locations_config.dart
//
// 🎯 מטרה: הגדרות מיקומי אחסון במזווה
//
// 📋 כולל:
// - 10 מיקומי אחסון מוגדרים מראש: מקרר, מקפיא, מזווה ראשי, מחסן,
//   ארון מטבח עליון, ארון מטבח תחתון, מתחת לכיור, ארון אמבטיה, מדפים פתוחים, אחר
// - מידע עבור כל מיקום: שם, אימוג'י, צבע
// - Helper methods לגישה למידע
//
// 🔗 Dependencies:
// - flutter/material.dart: Colors
// - ../l10n/app_strings.dart: i18n strings (עתידי)
//
// 🎯 שימוש:
// ```dart
// final locations = StorageLocationsConfig.locations;
// final emoji = StorageLocationsConfig.getEmoji('refrigerator');
// final name = StorageLocationsConfig.getName('refrigerator');
// final color = StorageLocationsConfig.getColor('refrigerator');
// final isValid = StorageLocationsConfig.isValidLocation('refrigerator');
// ```
//
// 📝 הערות:
// - המיקומים מוגדרים כ-constants עם IDs (refrigerator, freezer, וכו')
// - ניתן להרחיב בעתיד עם מיקומים מותאמים אישית
// - i18n ready - קל להחליף את השמות ב-AppStrings
//
// Version: 1.0
// Last Updated: 10/10/2025

import 'package:flutter/material.dart';

/// מידע על מיקום אחסון
class LocationInfo {
  final String id;
  final String name;
  final String emoji;
  final Color color;

  const LocationInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });
}

/// תצורת מיקומי אחסון במזווה
class StorageLocationsConfig {
  const StorageLocationsConfig._();

  // ========================================
  // Location IDs (Constants)
  // ========================================

  static const String refrigerator = 'refrigerator';
  static const String freezer = 'freezer';
  static const String mainPantry = 'main_pantry';
  static const String secondaryStorage = 'secondary_storage';
  static const String upperCabinet = 'upper_cabinet';
  static const String lowerCabinet = 'lower_cabinet';
  static const String underSink = 'under_sink';
  static const String bathroomCabinet = 'bathroom_cabinet';
  static const String openShelves = 'open_shelves';
  static const String other = 'other';

  // ========================================
  // Locations Map
  // ========================================

  /// מיקומי אחסון מוגדרים מראש
  static const Map<String, LocationInfo> locations = {
    refrigerator: LocationInfo(
      id: refrigerator,
      name: 'מקרר',
      emoji: '❄️',
      color: Colors.blue,
    ),
    freezer: LocationInfo(
      id: freezer,
      name: 'מקפיא',
      emoji: '🧊',
      color: Colors.cyan,
    ),
    mainPantry: LocationInfo(
      id: mainPantry,
      name: 'מזווה ראשי',
      emoji: '🏠',
      color: Colors.amber,
    ),
    secondaryStorage: LocationInfo(
      id: secondaryStorage,
      name: 'מחסן',
      emoji: '📦',
      color: Colors.brown,
    ),
    upperCabinet: LocationInfo(
      id: upperCabinet,
      name: 'ארון מטבח עליון',
      emoji: '🚪',
      color: Colors.orange,
    ),
    lowerCabinet: LocationInfo(
      id: lowerCabinet,
      name: 'ארון מטבח תחתון',
      emoji: '🗄️',
      color: Colors.deepOrange,
    ),
    underSink: LocationInfo(
      id: underSink,
      name: 'מתחת לכיור',
      emoji: '🚿',
      color: Colors.teal,
    ),
    bathroomCabinet: LocationInfo(
      id: bathroomCabinet,
      name: 'ארון אמבטיה',
      emoji: '🛁',
      color: Colors.lightBlue,
    ),
    openShelves: LocationInfo(
      id: openShelves,
      name: 'מדפים פתוחים',
      emoji: '📏',
      color: Colors.indigo,
    ),
    other: LocationInfo(
      id: other,
      name: 'אחר',
      emoji: '📍',
      color: Colors.grey,
    ),
  };

  // ========================================
  // Helper Methods
  // ========================================

  /// מחזיר שם מיקום לפי ID
  ///
  /// דוגמה:
  /// ```dart
  /// final name = StorageLocationsConfig.getName('refrigerator');
  /// // מחזיר: "מקרר"
  /// ```
  static String getName(String locationId) {
    return locations[locationId]?.name ?? locations[other]!.name;
  }

  /// מחזיר אימוג'י מיקום לפי ID
  ///
  /// דוגמה:
  /// ```dart
  /// final emoji = StorageLocationsConfig.getEmoji('freezer');
  /// // מחזיר: "🧊"
  /// ```
  static String getEmoji(String locationId) {
    return locations[locationId]?.emoji ?? locations[other]!.emoji;
  }

  /// מחזיר צבע מיקום לפי ID
  ///
  /// דוגמה:
  /// ```dart
  /// final color = StorageLocationsConfig.getColor('main_pantry');
  /// // מחזיר: Colors.amber
  /// ```
  static Color getColor(String locationId) {
    return locations[locationId]?.color ?? locations[other]!.color;
  }

  /// מחזיר LocationInfo מלא לפי ID
  ///
  /// דוגמה:
  /// ```dart
  /// final info = StorageLocationsConfig.getLocationInfo('refrigerator');
  /// print(info.name);  // "מקרר"
  /// print(info.emoji); // "❄️"
  /// ```
  static LocationInfo getLocationInfo(String locationId) {
    return locations[locationId] ?? locations[other]!;
  }

  /// בדיקה האם מיקום תקין
  ///
  /// דוגמה:
  /// ```dart
  /// final isValid = StorageLocationsConfig.isValidLocation('refrigerator');
  /// // מחזיר: true
  /// ```
  static bool isValidLocation(String locationId) {
    return locations.containsKey(locationId);
  }

  /// רשימת כל ה-IDs
  ///
  /// דוגמה:
  /// ```dart
  /// final allIds = StorageLocationsConfig.allLocationIds;
  /// // מחזיר: ['refrigerator', 'freezer', 'main_pantry', 'secondary_storage',
  /// //          'upper_cabinet', 'lower_cabinet', 'under_sink', 'bathroom_cabinet',
  /// //          'open_shelves', 'other']
  /// ```
  static List<String> get allLocationIds => locations.keys.toList();

  /// רשימת כל המיקומים (ללא 'other')
  ///
  /// דוגמה:
  /// ```dart
  /// final primary = StorageLocationsConfig.primaryLocations;
  /// // מחזיר את כל המיקומים מלבד 'other'
  /// ```
  static List<String> get primaryLocations {
    return locations.keys.where((id) => id != other).toList();
  }
}
