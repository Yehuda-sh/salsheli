// 📄 File: lib/config/storage_locations_config.dart
// Version: 2.0
// Last Updated: 29/10/2025
//
// 🎯 Purpose:
//   מגדיר את מיקומי האחסון האפשריים במזווה
//   שימושי ל-InventoryItem ו-ProductLocationProvider
//
// 🏠 Storage Locations:
//   1. mainPantry - מזווה ראשי
//   2. refrigerator - מקרר
//   3. freezer - מקפיא
//   4. countertop - משטח מטבח
//   5. other - אחר
//
// 📝 Features:
//   - getName(): שם בעברית
//   - getIcon(): אייקון מתאים
//   - getLocationInfo(): כל המידע ביחד
//   - isValidLocation(): בדיקת תקינות

import 'package:flutter/material.dart';

/// מידע על מיקום אחסון
class LocationInfo {
  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final String description;

  const LocationInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.description,
  });
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
  static const String countertop = 'countertop';
  static const String other = 'other';

  // ========================================
  // רשימת כל המיקומים
  // ========================================

  static const List<String> allLocations = [
    mainPantry,
    refrigerator,
    freezer,
    countertop,
    other,
  ];

  // ========================================
  // מיפוי למידע מלא
  // ========================================

  static const Map<String, LocationInfo> _locationData = {
    mainPantry: LocationInfo(
      id: mainPantry,
      name: 'מזווה',
      emoji: '🏠',
      icon: Icons.kitchen,
      description: 'מזווה ראשי - מוצרים יבשים',
    ),
    refrigerator: LocationInfo(
      id: refrigerator,
      name: 'מקרר',
      emoji: '❄️',
      icon: Icons.kitchen,
      description: 'מקרר - מוצרים טריים',
    ),
    freezer: LocationInfo(
      id: freezer,
      name: 'מקפיא',
      emoji: '🧊',
      icon: Icons.ac_unit,
      description: 'מקפיא - מוצרים קפואים',
    ),
    countertop: LocationInfo(
      id: countertop,
      name: 'ארון מטבח',
      emoji: '🗄️',
      icon: Icons.door_sliding,
      description: 'ארון מטבח - מוצרים כלליים',
    ),
    other: LocationInfo(
      id: other,
      name: 'אחר',
      emoji: '📦',
      icon: Icons.inventory_2,
      description: 'מיקום אחר',
    ),
  };

  // ========================================
  // Getters
  // ========================================

  /// מחזיר את שם המיקום בעברית
  /// 
  /// Example:
  /// ```dart
  /// final name = StorageLocationsConfig.getName('refrigerator');
  /// // 'מקרר'
  /// ```
  static String getName(String locationId) {
    return _locationData[locationId]?.name ?? 'לא ידוע';
  }

  /// מחזיר את האייקון של המיקום
  /// 
  /// Example:
  /// ```dart
  /// final icon = StorageLocationsConfig.getIcon('freezer');
  /// // Icons.ac_unit
  /// ```
  static IconData getIcon(String locationId) {
    return _locationData[locationId]?.icon ?? Icons.help_outline;
  }

  /// מחזיר את המידע המלא על המיקום
  /// 
  /// Example:
  /// ```dart
  /// final info = StorageLocationsConfig.getLocationInfo('main_pantry');
  /// print(info.emoji); // 🏠
  /// print(info.name);  // מזווה
  /// ```
  static LocationInfo getLocationInfo(String locationId) {
    return _locationData[locationId] ??
        const LocationInfo(
          id: 'unknown',
          name: 'לא ידוע',
          emoji: '❓',
          icon: Icons.help_outline,
          description: 'מיקום לא מוכר',
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
    return allLocations
        .map((id) => getLocationInfo(id))
        .toList();
  }
}
