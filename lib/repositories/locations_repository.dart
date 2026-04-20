// lib/repositories/locations_repository.dart — Locations repository interface — abstract CRUD + stream for custom locations

import '../models/custom_location.dart';

/// Interface למאגר מיקומי אחסון מותאמים
///
/// מגדיר חוזה לגישת נתונים למיקומים שהמשתמש יצר
/// (למשל: "מקרר עליון", "מזווה מרתף", "מקפיא גדול").
///
/// כל מקור נתונים (Firebase, Mock, SQLite) חייב לממש את הממשק הזה.
abstract class LocationsRepository {
  // ========================================
  // Fetch - טעינת מיקומים
  // ========================================

  /// טוען את כל המיקומים המותאמים של משק בית
  ///
  /// Path: `/households/{householdId}/custom_locations`
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: רשימת מיקומים מותאמים
  ///
  /// Throws: Exception אם הטעינה נכשלה
  ///
  /// Example:
  /// ```dart
  /// final locations = await repository.fetchLocations('house_demo');
  /// print('נטענו ${locations.length} מיקומים');
  /// ```
  Future<List<CustomLocation>> fetchLocations(String householdId);

  /// מאזין לשינויים במיקומים בזמן אמת
  ///
  /// Path: `/households/{householdId}/custom_locations`
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: Stream של רשימת מיקומים - מתעדכן אוטומטית
  /// כאשר בן משפחה אחר מוסיף/מעדכן/מוחק מיקום
  ///
  /// Example:
  /// ```dart
  /// repository.watchLocations('house_demo').listen((locations) {
  ///   print('מיקומים עודכנו: ${locations.length}');
  /// });
  /// ```
  Stream<List<CustomLocation>> watchLocations(String householdId);

  // ========================================
  // Save - שמירת מיקומים
  // ========================================

  /// שומר מיקום מותאם חדש או מעדכן קיים
  ///
  /// Path: `/households/{householdId}/custom_locations/{location.key}`
  ///
  /// Parameters:
  ///   - [location]: המיקום לשמירה (חדש או קיים)
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Throws: Exception אם השמירה נכשלה
  ///
  /// Example:
  /// ```dart
  /// await repository.saveLocation(location, 'house_demo');
  /// ```
  Future<void> saveLocation(CustomLocation location, String householdId);

  // ========================================
  // Delete - מחיקת מיקומים
  // ========================================

  /// מוחק מיקום מותאם
  ///
  /// Path: `/households/{householdId}/custom_locations/{key}`
  ///
  /// Parameters:
  ///   - [key]: מפתח המיקום למחיקה
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Throws: Exception אם המחיקה נכשלה
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteLocation('fridge_top', 'house_demo');
  /// ```
  Future<void> deleteLocation(String key, String householdId);
}
