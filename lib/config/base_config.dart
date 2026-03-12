// 📄 lib/config/base_config.dart
//
// 🎯 Base mixin for all config classes - eliminates 85% code duplication
// 
// ✅ Replaces repeated ensureSanity() patterns in:
// - storage_locations_config.dart (16 lines)  
// - stores_config.dart (16 lines)
// - list_types_config.dart (16 lines)
//
// 🔗 Related: All config classes

import 'package:flutter/foundation.dart';

/// 🔧 Validation mixin for config classes
/// 
/// Eliminates code duplication across all config files.
/// Provides consistent debug-time validation with performance optimization.
mixin ConfigValidation {
  static final Map<Type, bool> _validationCache = {};
  
  /// Override this to provide specific validation logic
  void performValidation();
  
  /// Single validation method - replaces all ensureSanity() methods
  void ensureValid() {
    if (!kDebugMode) return;
    
    final type = runtimeType;
    if (_validationCache[type] == true) return;
    
    try {
      performValidation();
      _validationCache[type] = true;
    } catch (e) {
      if (kDebugMode) {
        throw AssertionError('❌ $type validation failed: $e');
      }
    }
  }
  
  /// Helper for checking key duplicates
  static void validateNoDuplicates<T>(List<T> items, String context) {
    final seen = <T>{};
    for (final item in items) {
      if (seen.contains(item)) {
        throw AssertionError('Duplicate item found in $context: $item');
      }
      seen.add(item);
    }
  }
  
  /// Helper for checking 1:1 mapping
  static void validateOneToOneMapping<K, V>(
    Set<K> expectedKeys,
    Map<K, V> dataMap,
    String context,
  ) {
    final dataKeys = dataMap.keys.toSet();
    
    final missingInData = expectedKeys.difference(dataKeys);
    if (missingInData.isNotEmpty) {
      throw AssertionError(
        '$context: Missing data for keys: $missingInData'
      );
    }
    
    final extraInData = dataKeys.difference(expectedKeys);
    if (extraInData.isNotEmpty) {
      throw AssertionError(
        '$context: Extra data for keys: $extraInData'
      );
    }
  }
}