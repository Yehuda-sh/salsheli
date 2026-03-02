// 📄 File: lib/repositories/inventory_repository.dart
//
// 🎯 Purpose: Interface לניהול מלאי (Inventory)
//
// 📋 Features:
//     - תמיכה במזווה אישי (/users/{userId}/inventory)
//     - תמיכה במזווה משק בית (/households/{householdId}/inventory) - Legacy
//     - תמיכה במעבר חלק בין מזווה אישי למשק בית (Legacy)
//     - תיעוד מלא ל-Intellisense
//
// 📋 Implementations:
//     - FirebaseInventoryRepository - מימוש הייצור הרשמי (Firestore)
//
// 🔗 Related:
//     - lib/repositories/firebase_inventory_repository.dart - המימוש
//     - lib/providers/inventory_provider.dart - Provider שמשתמש ב-repository
//     - lib/models/inventory_item.dart - מבנה הנתונים
//
// 📜 History:
//     - v1.0 (06/10/2025): Interface + MockInventoryRepository
//     - v2.0 (09/10/2025): הוסר Mock אחרי מעבר מלא ל-Firebase
//     - v3.0 (16/12/2025): תמיכה במזווה אישי (/users) ומשותף (/groups)
//     - v3.1 (27/01/2026): הוסר תמיכה בקבוצות (Groups feature removed)
//     - v4.0 (22/02/2026): תיעוד מלא, יישור עם שכבת הנתונים החדשה
//
// Version: 4.0
// Last Updated: 22/02/2026

import '../models/inventory_item.dart';

/// סוג מיקום המזווה - קובע את נתיב ה-Firestore לקריאה/כתיבה
///
/// המערכת בוחרת אוטומטית לפי הקשר המשתמש:
/// - משתמש ללא household → [user] (מזווה אישי)
/// - משתמש עם household → [household] (מזווה משותף, legacy)
enum InventoryLocation {
  /// מזווה אישי: `/users/{userId}/inventory`
  ///
  /// נתיב ברירת מחדל - כל משתמש מנהל מזווה עצמאי
  user,

  /// מזווה משק בית (legacy): `/households/{householdId}/inventory`
  ///
  /// נתיב ישן - משותף לכל חברי משק הבית
  household,
}

/// Interface לניהול מלאי - מגדיר methods חובה לכל Repository
///
/// כל מקור נתונים (Firebase, Mock, SQLite) חייב לממש את הממשק הזה.
///
/// המתודות מחולקות לשני עולמות:
/// - **Personal** (`*UserItem*`) - מזווה אישי תחת `/users/{userId}/inventory`
/// - **Legacy** (ללא `User` בשם) - מזווה משק בית תחת `/households/{householdId}/inventory`
abstract class InventoryRepository {
  // ========================================
  // Fetch - טעינת פריטים
  // ========================================

  /// [Legacy/Household] טוען את כל פריטי המלאי של משק בית
  ///
  /// Path: `/households/{householdId}/inventory`
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: רשימת פריטים ממוינת לפי שם מוצר
  ///
  /// Example:
  /// ```dart
  /// final items = await repository.fetchItems('house_demo');
  /// print('נטענו ${items.length} פריטים במלאי');
  /// ```
  Future<List<InventoryItem>> fetchItems(String householdId);

  /// [Personal/User] טוען את כל פריטי המזווה האישי של משתמש
  ///
  /// Path: `/users/{userId}/inventory`
  ///
  /// Parameters:
  ///   - [userId]: מזהה המשתמש
  ///
  /// Returns: רשימת פריטים ממוינת לפי שם מוצר
  ///
  /// Example:
  /// ```dart
  /// final items = await repository.fetchUserItems('user_123');
  /// print('נטענו ${items.length} פריטים במזווה האישי');
  /// ```
  Future<List<InventoryItem>> fetchUserItems(String userId);

  // ========================================
  // Save - שמירת פריטים
  // ========================================

  /// [Legacy/Household] שומר או מעדכן פריט מלאי של משק בית
  ///
  /// Path: `/households/{householdId}/inventory/{item.id}`
  ///
  /// Parameters:
  ///   - [item]: הפריט לשמירה (חדש או קיים)
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: הפריט ששמרנו
  ///
  /// Example:
  /// ```dart
  /// final saved = await repository.saveItem(item, 'house_demo');
  /// ```
  Future<InventoryItem> saveItem(InventoryItem item, String householdId);

  /// [Personal/User] שומר או מעדכן פריט במזווה אישי
  ///
  /// Path: `/users/{userId}/inventory/{item.id}`
  ///
  /// Parameters:
  ///   - [item]: הפריט לשמירה (חדש או קיים)
  ///   - [userId]: מזהה המשתמש
  ///
  /// Returns: הפריט ששמרנו
  ///
  /// Example:
  /// ```dart
  /// final saved = await repository.saveUserItem(item, 'user_123');
  /// ```
  Future<InventoryItem> saveUserItem(InventoryItem item, String userId);

  // ========================================
  // Delete - מחיקת פריטים
  // ========================================

  /// [Legacy/Household] מוחק פריט מלאי ממשק בית
  ///
  /// Path: `/households/{householdId}/inventory/{id}`
  ///
  /// Parameters:
  ///   - [id]: מזהה הפריט למחיקה
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteItem('item_123', 'house_demo');
  /// ```
  Future<void> deleteItem(String id, String householdId);

  /// [Personal/User] מוחק פריט ממזווה אישי
  ///
  /// Path: `/users/{userId}/inventory/{itemId}`
  ///
  /// Parameters:
  ///   - [itemId]: מזהה הפריט למחיקה
  ///   - [userId]: מזהה המשתמש
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteUserItem('item_123', 'user_123');
  /// ```
  Future<void> deleteUserItem(String itemId, String userId);

  /// [Personal/User] מוחק את כל פריטי המזווה האישי
  ///
  /// Path: `/users/{userId}/inventory/*`
  ///
  /// Parameters:
  ///   - [userId]: מזהה המשתמש
  ///
  /// Returns: מספר הפריטים שנמחקו
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.deleteAllUserItems('user_123');
  /// print('נמחקו $count פריטים');
  /// ```
  Future<int> deleteAllUserItems(String userId);
}
