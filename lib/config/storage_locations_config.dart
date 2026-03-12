// 📄 lib/config/storage_locations_config.dart
//
// 🗄️ Storage locations API - slim config class using shared validation
// 
// ✅ Extracted from 262-line oversized file
// ✅ Uses ConfigValidation mixin (eliminates code duplication)
// ✅ Delegates data to storage_locations.dart
//
// 🔗 Related: storage_locations.dart, base_config.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'base_config.dart';
import 'storage_locations.dart';

/// 🗄️ Storage locations configuration API
class StorageLocationsConfig with ConfigValidation {
  StorageLocationsConfig._(); // Private constructor
  static final StorageLocationsConfig _instance = StorageLocationsConfig._();

  // ========================================
  // 🔄 Backward compatibility - delegates to StorageLocations
  // ========================================
  
  /// Delegate constants for backward compatibility
  static const String mainPantry = StorageLocations.mainPantry;
  static const String refrigerator = StorageLocations.refrigerator;
  static const String freezer = StorageLocations.freezer;
  static const String other = StorageLocations.other;
  
  /// Delegate list for backward compatibility
  static List<String> get allLocations => StorageLocations.all;

  /// ✅ Safe resolve - fallback to 'other'
  static String resolve(String? locationId) {
    _instance.ensureValid();
    if (locationId == null) return StorageLocations.other;
    if (StorageLocations.data.containsKey(locationId)) return locationId;
    
    if (kDebugMode) {
      debugPrint('⚠️ Unknown location "$locationId", falling back to "other"');
    }
    return StorageLocations.other;
  }

  /// Get location name
  static String getName(String locationId) {
    _instance.ensureValid();
    return getLocationInfo(locationId).name;
  }

  /// Get location icon
  static IconData getIcon(String locationId) {
    return getLocationInfo(locationId).icon;
  }

  /// Get full location info (main API)
  static LocationInfo getLocationInfo(String locationId) {
    return StorageLocations.data[locationId] ?? StorageLocations.data[StorageLocations.other]!;
  }

  /// Check if location is valid
  static bool isValidLocation(String locationId) {
    return StorageLocations.data.containsKey(locationId);
  }

  /// Get all location info
  static List<LocationInfo> getAllLocationInfo() {
    return StorageLocations.all.map(getLocationInfo).toList();
  }

  /// ✅ Validation implementation - replaces old ensureSanity()
  @override
  void performValidation() {
    // 1. Check for duplicates
    ConfigValidation.validateNoDuplicates(
      StorageLocations.all, 
      'StorageLocations.all'
    );

    // 2. Check 1:1 mapping
    ConfigValidation.validateOneToOneMapping(
      StorageLocations.all.toSet(),
      StorageLocations.data,
      'StorageLocations'
    );

    // 3. Check 'other' is last
    if (StorageLocations.all.isNotEmpty && StorageLocations.all.last != StorageLocations.other) {
      throw AssertionError(
        'StorageLocations: "other" must be last in all list! '
        'Found: "${StorageLocations.all.last}"'
      );
    }
  }
}