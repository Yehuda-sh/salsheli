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

  // ===== 🆕 Sharing & Permissions Methods =====

  /// מוסיף משתמש משותף לרשימה
  ///
  /// [listId] - מזהה הרשימה
  /// [userId] - מזהה המשתמש להוספה
  /// [role] - תפקיד המשתמש (admin/editor/viewer)
  /// [userName] - שם המשתמש (cache)
  /// [userEmail] - אימייל המשתמש (cache)
  ///
  /// Example:
  /// ```dart
  /// await repository.addSharedUser(
  ///   'list_123',
  ///   'user_456',
  ///   UserRole.editor,
  ///   'יוסי כהן',
  ///   'yossi@example.com',
  /// );
  /// ```
  Future<void> addSharedUser(
    String listId,
    String userId,
    String role,
    String? userName,
    String? userEmail,
  );

  /// מסיר משתמש משותף מהרשימה
  ///
  /// [listId] - מזהה הרשימה
  /// [userId] - מזהה המשתמש להסרה
  ///
  /// Example:
  /// ```dart
  /// await repository.removeSharedUser('list_123', 'user_456');
  /// ```
  Future<void> removeSharedUser(String listId, String userId);

  /// משנה את תפקיד המשתמש ברשימה
  ///
  /// [listId] - מזהה הרשימה
  /// [userId] - מזהה המשתמש
  /// [newRole] - התפקיד החדש
  ///
  /// Example:
  /// ```dart
  /// await repository.updateUserRole(
  ///   'list_123',
  ///   'user_456',
  ///   UserRole.admin,
  /// );
  /// ```
  Future<void> updateUserRole(String listId, String userId, String newRole);

  /// מעביר בעלות על הרשימה למשתמש אחר
  ///
  /// [listId] - מזהה הרשימה
  /// [currentOwnerId] - מזהה הבעלים הנוכחי
  /// [newOwnerId] - מזהה הבעלים החדש
  ///
  /// הבעלים הנוכחי יהפוך ל-Admin אוטומטית
  ///
  /// Example:
  /// ```dart
  /// await repository.transferOwnership(
  ///   'list_123',
  ///   'user_old',
  ///   'user_new',
  /// );
  /// ```
  Future<void> transferOwnership(
    String listId,
    String currentOwnerId,
    String newOwnerId,
  );

  // ===== 🆕 Pending Requests Methods =====

  /// יוצר בקשה חדשה להוספה/עריכה/מחיקה
  ///
  /// [listId] - מזהה הרשימה
  /// [requesterId] - מזהה המבקש
  /// [type] - סוג הבקשה (addItem/editItem/deleteItem)
  /// [requestData] - תוכן הבקשה
  /// [requesterName] - שם המבקש (cache)
  ///
  /// Returns: מזהה הבקשה החדשה
  ///
  /// Example:
  /// ```dart
  /// final requestId = await repository.createRequest(
  ///   'list_123',
  ///   'user_456',
  ///   'addItem',
  ///   {'name': 'בלונים', 'quantity': 30},
  ///   'יוסי כהן',
  /// );
  /// ```
  Future<String> createRequest(
    String listId,
    String requesterId,
    String type,
    Map<String, dynamic> requestData,
    String? requesterName,
  );

  /// מאשר בקשה ומבצע את הפעולה
  ///
  /// [listId] - מזהה הרשימה
  /// [requestId] - מזהה הבקשה
  /// [reviewerId] - מזהה המאשר
  /// [reviewerName] - שם המאשר (cache)
  ///
  /// Example:
  /// ```dart
  /// await repository.approveRequest(
  ///   'list_123',
  ///   'request_789',
  ///   'user_admin',
  ///   'דני מנהל',
  /// );
  /// ```
  Future<void> approveRequest(
    String listId,
    String requestId,
    String reviewerId,
    String? reviewerName,
  );

  /// דוחה בקשה עם סיבת דחייה
  ///
  /// [listId] - מזהה הרשימה
  /// [requestId] - מזהה הבקשה
  /// [reviewerId] - מזהה הדוחה
  /// [reason] - סיבת הדחייה
  /// [reviewerName] - שם הדוחה (cache)
  ///
  /// Example:
  /// ```dart
  /// await repository.rejectRequest(
  ///   'list_123',
  ///   'request_789',
  ///   'user_admin',
  ///   'יש לנו כבר בלונים בבית',
  ///   'דני מנהל',
  /// );
  /// ```
  Future<void> rejectRequest(
    String listId,
    String requestId,
    String reviewerId,
    String reason,
    String? reviewerName,
  );

  /// מביא את כל הבקשות הממתינות לרשימה
  ///
  /// [listId] - מזהה הרשימה
  ///
  /// Returns: רשימת בקשות ממתינות
  ///
  /// Example:
  /// ```dart
  /// final requests = await repository.getPendingRequests('list_123');
  /// print('יש ${requests.length} בקשות ממתינות');
  /// ```
  Future<List<Map<String, dynamic>>> getPendingRequests(String listId);
}
