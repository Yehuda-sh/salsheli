// 📄 lib/config/storage_locations.dart
//
// 🗄️ Storage locations data only - extracted from oversized config file
// 
// ✅ Single responsibility: location data and info classes
// ❌ No API methods here - see storage_locations_config.dart
//
// 🔗 Related: storage_locations_config.dart, InventoryItem

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
      case StorageLocations.mainPantry:
        return AppStrings.inventory.locationMainPantry;
      case StorageLocations.refrigerator:
        return AppStrings.inventory.locationRefrigerator;
      case StorageLocations.freezer:
        return AppStrings.inventory.locationFreezer;
      case StorageLocations.other:
        return AppStrings.inventory.locationOther;
      default:
        return AppStrings.inventory.locationUnknown;
    }
  }

  /// תיאור מתורגם לפי id
  static String _getLocalizedDescription(String id) {
    switch (id) {
      case StorageLocations.mainPantry:
        return AppStrings.inventory.locationMainPantryDesc;
      case StorageLocations.refrigerator:
        return AppStrings.inventory.locationRefrigeratorDesc;
      case StorageLocations.freezer:
        return AppStrings.inventory.locationFreezerDesc;
      case StorageLocations.other:
        return AppStrings.inventory.locationOtherDesc;
      default:
        return AppStrings.inventory.locationUnknownDesc;
    }
  }
}

/// 🗄️ Storage location constants and data
class StorageLocations {
  StorageLocations._(); // Private constructor

  // Location IDs
  static const String mainPantry = 'main_pantry';
  static const String refrigerator = 'refrigerator';
  static const String freezer = 'freezer';
  static const String other = 'other';

  /// All location IDs (UX order: pantry → fridge → freezer → other)
  static const List<String> all = [
    mainPantry,
    refrigerator,
    freezer,
    other, // ✅ Always last (fallback)
  ];

  /// Location data mapping
  static const Map<String, LocationInfo> data = {
    mainPantry: LocationInfo(
      id: mainPantry,
      emoji: '🗄️',
      icon: Icons.shelves, // ✅ Shelves for pantry
    ),
    refrigerator: LocationInfo(
      id: refrigerator,
      emoji: '🥛', // Milk = fridge (more intuitive than 🧊)
      icon: Icons.kitchen,
    ),
    freezer: LocationInfo(
      id: freezer,
      emoji: '🧊', // Ice = freezer
      icon: Icons.ac_unit,
    ),
    other: LocationInfo(
      id: other,
      emoji: '📦',
      icon: Icons.inventory_2,
    ),
  };
}