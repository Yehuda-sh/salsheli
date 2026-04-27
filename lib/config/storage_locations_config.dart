// lib/config/storage_locations_config.dart — Storage locations config — Hebrew labels, emoji, and sort order for pantry locations

import 'base_config.dart';
import 'storage_locations.dart';

/// 🗄️ Storage locations configuration API
class StorageLocationsConfig with ConfigValidation {
  StorageLocationsConfig._(); // Private constructor
  static final StorageLocationsConfig _instance = StorageLocationsConfig._();

  /// Default location used as a fallback when creating new pantry items.
  static const String mainPantry = StorageLocations.mainPantry;

  /// All location keys in UI order (used by dropdowns).
  static List<String> get allLocations => StorageLocations.all;

  /// Get full location info — falls back to 'other' if the key is unknown.
  static LocationInfo getLocationInfo(String locationId) {
    _instance.ensureValid();
    return StorageLocations.data[locationId] ??
        StorageLocations.data[StorageLocations.other]!;
  }

  /// Get location display name (convenience wrapper around getLocationInfo).
  static String getName(String locationId) {
    _instance.ensureValid();
    return getLocationInfo(locationId).name;
  }

  /// Check if a location key exists in the registry.
  static bool isValidLocation(String locationId) {
    _instance.ensureValid();
    return StorageLocations.data.containsKey(locationId);
  }

  /// ✅ Validation implementation — runs once on first API call (debug only).
  @override
  void performValidation() {
    // 1. No duplicate keys in the canonical list.
    ConfigValidation.validateNoDuplicates(
      StorageLocations.all,
      'StorageLocations.all',
    );

    // 2. Every key has a matching entry in the data map (1:1).
    ConfigValidation.validateOneToOneMapping(
      StorageLocations.all.toSet(),
      StorageLocations.data,
      'StorageLocations',
    );

    // 3. 'other' must be the last key so dropdowns render it as the fallback option.
    if (StorageLocations.all.isNotEmpty &&
        StorageLocations.all.last != StorageLocations.other) {
      throw AssertionError(
        'StorageLocations: "other" must be last in all list! '
        'Found: "${StorageLocations.all.last}"',
      );
    }
  }
}
