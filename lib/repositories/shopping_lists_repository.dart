// 📄 File: lib/repositories/shopping_lists_repository.dart
//
// 🇮🇱 Repository לניהול רשימות קניות.
//     - משמש כשכבת ביניים בין Providers ↔ מקור הנתונים (API / Firebase / Mock).
//     - מאפשר להחליף בקלות מקור נתונים ע"י מימוש שונה.
//     - עוזר לשמור את ShoppingListsProvider נקי מהלוגיקה של אחסון/טעינה.
//
// 🇬🇧 Repository for managing shopping lists.
//     - Acts as a bridge between Providers ↔ data source (API / Firebase / Mock).
//     - Makes it easy to swap data source by changing the implementation.
//     - Keeps ShoppingListsProvider clean from storage/fetching logic.
//
// 📝 Version: 2.0 - Added docstrings + naming consistency
// 📅 Last Updated: 09/10/2025
//

import '../models/shopping_list.dart';

/// === Contract ===
///
/// 🇮🇱 כל מקור נתונים (API, Firebase, Mock) יצטרך לממש את הממשק הזה.
/// 🇬🇧 Any data source (API, Firebase, Mock) must implement this interface.
abstract class ShoppingListsRepository {
  /// טוען את כל רשימות הקניות של משק בית
  ///
  /// [householdId] - מזהה משק הבית
  ///
  /// Returns: רשימת כל ה-ShoppingList שייכים ל-household
  ///
  /// Example:
  /// ```dart
  /// final lists = await repository.fetchLists('house_demo');
  /// print('נטענו ${lists.length} רשימות');
  /// ```
  Future<List<ShoppingList>> fetchLists(String householdId);

  /// שומר או מעדכן רשימת קניות
  ///
  /// [list] - הרשימה לשמירה (חדשה או קיימת)
  /// [householdId] - מזהה משק הבית (יתווסף אוטומטית ל-Firestore)
  ///
  /// Returns: הרשימה ששמרנו (עם שדות מעודכנים אם יש)
  ///
  /// Example:
  /// ```dart
  /// final newList = ShoppingList.newList(...);
  /// final saved = await repository.saveList(newList, 'house_demo');
  /// ```
  Future<ShoppingList> saveList(ShoppingList list, String householdId);

  /// מוחק רשימת קניות
  ///
  /// [id] - מזהה הרשימה למחיקה
  /// [householdId] - מזהה משק הבית (לבדיקת הרשאות)
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteList('list_123', 'house_demo');
  /// ```
  Future<void> deleteList(String id, String householdId);
}
