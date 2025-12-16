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
// 📝 Version: 3.0 - Added user/group inventory support
// 📅 Last Updated: 16/12/2025
//
// 📜 History:
// - v1.0 (06/10/2025): Interface + MockInventoryRepository
// - v2.0 (09/10/2025): הוסר Mock אחרי מעבר מלא ל-Firebase
// - v3.0 (16/12/2025): תמיכה במזווה אישי (/users) ומשותף (/groups)
//

import '../models/inventory_item.dart';

/// סוג מיקום המזווה
enum InventoryLocation {
  /// מזווה אישי - /users/{userId}/inventory
  user,
  /// מזווה משותף (קבוצה/משפחה) - /groups/{groupId}/inventory
  group,
  /// מזווה תחת household (legacy) - /households/{householdId}/inventory
  household,
}

/// Interface לניהול מלאי - מגדיר methods חובה לכל Repository
///
/// כל מקור נתונים (Firebase, Mock, SQLite) חייב לממש את הממשק הזה
abstract class InventoryRepository {
  /// טוען את כל פריטי המלאי של משק בית (legacy - backwards compatible)
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

  /// טוען את כל פריטי המזווה האישי של משתמש
  ///
  /// [userId] - מזהה המשתמש
  ///
  /// Returns: רשימת כל פריטי המזווה האישי
  ///
  /// Example:
  /// ```dart
  /// final items = await repository.fetchUserItems('user_123');
  /// ```
  Future<List<InventoryItem>> fetchUserItems(String userId);

  /// טוען את כל פריטי המזווה המשותף של קבוצה
  ///
  /// [groupId] - מזהה הקבוצה
  ///
  /// Returns: רשימת כל פריטי המזווה המשותף
  ///
  /// Example:
  /// ```dart
  /// final items = await repository.fetchGroupItems('group_family_123');
  /// ```
  Future<List<InventoryItem>> fetchGroupItems(String groupId);

  /// שומר או מעדכן פריט מלאי (legacy)
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

  /// שומר פריט למזווה אישי
  ///
  /// [item] - הפריט לשמירה
  /// [userId] - מזהה המשתמש
  Future<InventoryItem> saveUserItem(InventoryItem item, String userId);

  /// שומר פריט למזווה קבוצתי
  ///
  /// [item] - הפריט לשמירה
  /// [groupId] - מזהה הקבוצה
  Future<InventoryItem> saveGroupItem(InventoryItem item, String groupId);

  /// מוחק פריט מלאי (legacy)
  ///
  /// [id] - מזהה הפריט למחיקה
  /// [householdId] - מזהה משק הבית (לבדיקת הרשאות)
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteItem('item_123', 'house_demo');
  /// ```
  Future<void> deleteItem(String id, String householdId);

  /// מוחק פריט ממזווה אישי
  ///
  /// [itemId] - מזהה הפריט
  /// [userId] - מזהה המשתמש
  Future<void> deleteUserItem(String itemId, String userId);

  /// מוחק פריט ממזווה קבוצתי
  ///
  /// [itemId] - מזהה הפריט
  /// [groupId] - מזהה הקבוצה
  Future<void> deleteGroupItem(String itemId, String groupId);

  /// מעביר פריטים ממזווה אישי למזווה קבוצתי
  ///
  /// [userId] - מזהה המשתמש (מקור)
  /// [groupId] - מזהה הקבוצה (יעד)
  /// [itemIds] - רשימת מזהי הפריטים להעברה (null = הכל)
  ///
  /// Returns: מספר הפריטים שהועברו
  Future<int> transferUserItemsToGroup(
    String userId,
    String groupId, [
    List<String>? itemIds,
  ]);

  /// מוחק את כל פריטי המזווה האישי
  ///
  /// [userId] - מזהה המשתמש
  ///
  /// Returns: מספר הפריטים שנמחקו
  Future<int> deleteAllUserItems(String userId);
}
