// 📄 File: lib/repositories/inventory_repository.dart
//
// 🎯 Purpose: Interface לניהול מלאי (Inventory)
//
// 📋 Implementations:
// - FirebaseInventoryRepository - מימוש הייצור הרשמי (Firestore)
//
// 🔗 Related:
// - lib/repositories/firebase_inventory_repository.dart - המימוש
// - lib/providers/inventory_provider.dart - Provider שמשתמש ב-repository
// - lib/models/inventory_item.dart - מבנה הנתונים
// - lib/main.dart - רישום ב-main()
//
// 📝 Version: 2.0 - Removed MockInventoryRepository + Added docstrings
// 📅 Last Updated: 09/10/2025
//
// 📜 History:
// - v1.0 (06/10/2025): Interface + MockInventoryRepository
// - v2.0 (09/10/2025): הוסר Mock אחרי מעבר מלא ל-Firebase
//

import '../models/inventory_item.dart';

/// Interface לניהול מלאי - מגדיר methods חובה לכל Repository
///
/// כל מקור נתונים (Firebase, Mock, SQLite) חייב לממש את הממשק הזה
abstract class InventoryRepository {
  /// טוען את כל פריטי המלאי של משק בית
  ///
  /// [householdId] - מזהה משק הבית
  ///
  /// Returns: רשימת כל פריטי המלאי שייכים ל-household
  ///
  /// Example:
  /// ```dart
  /// final items = await repository.fetchItems('house_demo');
  /// print('נטענו ${items.length} פריטים במלאי');
  /// ```
  Future<List<InventoryItem>> fetchItems(String householdId);

  /// שומר או מעדכן פריט מלאי
  ///
  /// [item] - הפריט לשמירה (חדש או קיים)
  /// [householdId] - מזהה משק הבית (יתווסף אוטומטית ל-Firestore)
  ///
  /// Returns: הפריט ששמרנו (עם שדות מעודכנים אם יש)
  ///
  /// Example:
  /// ```dart
  /// final item = InventoryItem(
  ///   id: 'item_123',
  ///   productName: 'חלב',
  ///   quantity: 2,
  ///   location: 'refrigerator',
  /// );
  /// final saved = await repository.saveItem(item, 'house_demo');
  /// ```
  Future<InventoryItem> saveItem(InventoryItem item, String householdId);

  /// מוחק פריט מלאי
  ///
  /// [id] - מזהה הפריט למחיקה
  /// [householdId] - מזהה משק הבית (לבדיקת הרשאות)
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteItem('item_123', 'house_demo');
  /// ```
  Future<void> deleteItem(String id, String householdId);
}
