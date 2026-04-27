// lib/config/storage_locations.dart — Storage location keys — fridge, freezer, pantry, kitchen, bathroom constants

import '../l10n/app_strings.dart';

/// מידע על מיקום אחסון
class LocationInfo {
  final String id;
  final String emoji;

  /// Getter לשם - מ-AppStrings
  String get name => _getLocalizedName(id);

  const LocationInfo({
    required this.id,
    required this.emoji,
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
      case StorageLocations.kitchen:
        return AppStrings.inventory.locationKitchen;
      case StorageLocations.bathroom:
        return AppStrings.inventory.locationBathroom;
      case StorageLocations.storage:
        return AppStrings.inventory.locationStorage;
      case StorageLocations.servicePorch:
        return AppStrings.inventory.locationServicePorch;
      case StorageLocations.other:
        return AppStrings.inventory.locationOther;
      default:
        return AppStrings.inventory.locationUnknown;
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
  static const String kitchen = 'kitchen';
  static const String bathroom = 'bathroom';
  static const String storage = 'storage';
  static const String servicePorch = 'service_porch';
  static const String other = 'other';

  /// All location IDs (UX order: pantry → fridge → freezer → kitchen → bathroom → storage → porch → other)
  static const List<String> all = [
    mainPantry,
    refrigerator,
    freezer,
    kitchen,
    bathroom,
    storage,
    servicePorch,
    other, // ✅ Always last (fallback)
  ];

  /// Location data mapping
  static const Map<String, LocationInfo> data = {
    mainPantry: LocationInfo(id: mainPantry, emoji: '🗄️'),
    refrigerator: LocationInfo(id: refrigerator, emoji: '🥛'),
    freezer: LocationInfo(id: freezer, emoji: '🧊'),
    kitchen: LocationInfo(id: kitchen, emoji: '🍳'),
    bathroom: LocationInfo(id: bathroom, emoji: '🛁'),
    storage: LocationInfo(id: storage, emoji: '📦'),
    servicePorch: LocationInfo(id: servicePorch, emoji: '🧺'),
    other: LocationInfo(id: other, emoji: '📍'),
  };
}
