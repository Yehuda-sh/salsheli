// 📄 File: lib/repositories/locations_repository.dart
//
// 🎯 Purpose: Interface למאגר מיקומי אחסון מותאמים - מגדיר חוזה לגישת נתונים
//
// 🏗️ Architecture: Repository Pattern
//     - Interface מופשט
//     - מאפשר החלפת מימוש (Firebase / Local / Mock)
//     - הפרדה בין Provider ל-Data Source
//
// 📦 Usage:
//     class FirebaseLocationsRepository implements LocationsRepository { ... }
//     class MockLocationsRepository implements LocationsRepository { ... }
//
// Version: 1.0
// Created: 13/10/2025

import '../models/custom_location.dart';

/// Interface למאגר מיקומי אחסון מותאמים
abstract class LocationsRepository {
  /// טוען את כל המיקומים המותאמים של household
  /// 
  /// Parameters:
  /// - householdId: מזהה משק הבית
  /// 
  /// Returns: רשימת מיקומים מותאמים
  /// 
  /// Throws: Exception אם הטעינה נכשלה
  Future<List<CustomLocation>> fetchLocations(String householdId);

  /// שומר מיקום מותאם חדש או מעדכן קיים
  /// 
  /// Parameters:
  /// - location: המיקום לשמירה
  /// - householdId: מזהה משק הבית
  /// 
  /// Throws: Exception אם השמירה נכשלה
  Future<void> saveLocation(CustomLocation location, String householdId);

  /// מחיק מיקום מותאם
  /// 
  /// Parameters:
  /// - key: מפתח המיקום למחיקה
  /// - householdId: מזהה משק הבית
  /// 
  /// Throws: Exception אם המחיקה נכשלה
  Future<void> deleteLocation(String key, String householdId);
}
