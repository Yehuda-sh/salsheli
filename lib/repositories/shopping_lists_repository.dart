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
// 🏗️ Database Structure:
//     - Private lists: /users/{userId}/private_lists/{listId}
//     - Shared lists: /households/{householdId}/shared_lists/{listId}
//
// 📝 Version: 3.0 - Dual collection support (private + shared)
// 📅 Last Updated: 14/12/2025
//

import '../models/shopping_list.dart';

/// === Contract ===
///
/// 🇮🇱 כל מקור נתונים (API, Firebase, Mock) יצטרך לממש את הממשק הזה.
/// 🇬🇧 Any data source (API, Firebase, Mock) must implement this interface.
abstract class ShoppingListsRepository {
  /// טוען את כל רשימות הקניות של המשתמש (פרטיות + משותפות)
  ///
  /// [userId] - מזהה המשתמש (לרשימות פרטיות)
  /// [householdId] - מזהה משק הבית (לרשימות משותפות, אופציונלי)
  ///
  /// Returns: רשימה ממוזגת של רשימות פרטיות + משותפות
  ///
  /// Example:
  /// ```dart
  /// final lists = await repository.fetchLists('user_123', 'house_demo');
  /// print('נטענו ${lists.length} רשימות');
  /// ```
  Future<List<ShoppingList>> fetchLists(String userId, String? householdId);

  /// שומר או מעדכן רשימת קניות
  ///
  /// [list] - הרשימה לשמירה (חדשה או קיימת)
  /// [userId] - מזהה המשתמש (לרשימות פרטיות)
  /// [householdId] - מזהה משק הבית (לרשימות משותפות, אופציונלי)
  ///
  /// הרשימה תישמר ב:
  /// - /users/{userId}/private_lists/ - אם isPrivate == true
  /// - /households/{householdId}/shared_lists/ - אם isPrivate == false
  ///
  /// Returns: הרשימה ששמרנו (עם שדות מעודכנים אם יש)
  ///
  /// Example:
  /// ```dart
  /// final newList = ShoppingList.newList(..., isPrivate: true);
  /// final saved = await repository.saveList(newList, 'user_123', 'house_demo');
  /// ```
  Future<ShoppingList> saveList(ShoppingList list, String userId, String? householdId);

  /// מוחק רשימת קניות
  ///
  /// [id] - מזהה הרשימה למחיקה
  /// [userId] - מזהה המשתמש
  /// [householdId] - מזהה משק הבית (אופציונלי)
  /// [isPrivate] - האם הרשימה פרטית
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteList('list_123', 'user_123', 'house_demo', true);
  /// ```
  Future<void> deleteList(String id, String userId, String? householdId, bool isPrivate);

  /// משתף רשימה פרטית למשק הבית
  ///
  /// מעביר רשימה מ-/users/{userId}/private_lists/ ל-/households/{householdId}/shared_lists/
  ///
  /// [listId] - מזהה הרשימה
  /// [userId] - מזהה המשתמש (בעל הרשימה)
  /// [householdId] - מזהה משק הבית לשיתוף
  ///
  /// Returns: הרשימה המעודכנת (עם isPrivate = false)
  ///
  /// Example:
  /// ```dart
  /// final sharedList = await repository.shareListToHousehold(
  ///   'list_123',
  ///   'user_123',
  ///   'house_demo',
  /// );
  /// ```
  Future<ShoppingList> shareListToHousehold(
    String listId,
    String userId,
    String householdId,
  );

  // ===== 🆕 Sharing & Permissions Methods =====
  // Note: These methods only apply to shared lists (in households collection)

  /// מוסיף משתמש משותף לרשימה
  ///
  /// [householdId] - מזהה משק הבית
  /// [listId] - מזהה הרשימה
  /// [userId] - מזהה המשתמש להוספה
  /// [role] - תפקיד המשתמש (admin/editor/viewer)
  /// [userName] - שם המשתמש (cache)
  /// [userEmail] - אימייל המשתמש (cache)
  ///
  /// Example:
  /// ```dart
  /// await repository.addSharedUser(
  ///   'house_demo',
  ///   'list_123',
  ///   'user_456',
  ///   UserRole.editor,
  ///   'יוסי כהן',
  ///   'yossi@example.com',
  /// );
  /// ```
  Future<void> addSharedUser(
    String householdId,
    String listId,
    String userId,
    String role,
    String? userName,
    String? userEmail,
  );

  /// מסיר משתמש משותף מהרשימה
  ///
  /// [householdId] - מזהה משק הבית
  /// [listId] - מזהה הרשימה
  /// [userId] - מזהה המשתמש להסרה
  ///
  /// Example:
  /// ```dart
  /// await repository.removeSharedUser('house_demo', 'list_123', 'user_456');
  /// ```
  Future<void> removeSharedUser(String householdId, String listId, String userId);

  /// משנה את תפקיד המשתמש ברשימה
  ///
  /// [householdId] - מזהה משק הבית
  /// [listId] - מזהה הרשימה
  /// [userId] - מזהה המשתמש
  /// [newRole] - התפקיד החדש
  ///
  /// Example:
  /// ```dart
  /// await repository.updateUserRole(
  ///   'house_demo',
  ///   'list_123',
  ///   'user_456',
  ///   UserRole.admin,
  /// );
  /// ```
  Future<void> updateUserRole(String householdId, String listId, String userId, String newRole);

  /// מעביר בעלות על הרשימה למשתמש אחר
  ///
  /// [householdId] - מזהה משק הבית
  /// [listId] - מזהה הרשימה
  /// [currentOwnerId] - מזהה הבעלים הנוכחי
  /// [newOwnerId] - מזהה הבעלים החדש
  ///
  /// הבעלים הנוכחי יהפוך ל-Admin אוטומטית
  ///
  /// Example:
  /// ```dart
  /// await repository.transferOwnership(
  ///   'house_demo',
  ///   'list_123',
  ///   'user_old',
  ///   'user_new',
  /// );
  /// ```
  Future<void> transferOwnership(
    String householdId,
    String listId,
    String currentOwnerId,
    String newOwnerId,
  );

  // ===== 🆕 Pending Requests Methods =====
  // Note: These methods only apply to shared lists (in households collection)

  /// יוצר בקשה חדשה להוספה/עריכה/מחיקה
  ///
  /// [householdId] - מזהה משק הבית
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
  ///   'house_demo',
  ///   'list_123',
  ///   'user_456',
  ///   'addItem',
  ///   {'name': 'בלונים', 'quantity': 30},
  ///   'יוסי כהן',
  /// );
  /// ```
  Future<String> createRequest(
    String householdId,
    String listId,
    String requesterId,
    String type,
    Map<String, dynamic> requestData,
    String? requesterName,
  );

  /// מאשר בקשה ומבצע את הפעולה
  ///
  /// [householdId] - מזהה משק הבית
  /// [listId] - מזהה הרשימה
  /// [requestId] - מזהה הבקשה
  /// [reviewerId] - מזהה המאשר
  /// [reviewerName] - שם המאשר (cache)
  ///
  /// Example:
  /// ```dart
  /// await repository.approveRequest(
  ///   'house_demo',
  ///   'list_123',
  ///   'request_789',
  ///   'user_admin',
  ///   'דני מנהל',
  /// );
  /// ```
  Future<void> approveRequest(
    String householdId,
    String listId,
    String requestId,
    String reviewerId,
    String? reviewerName,
  );

  /// דוחה בקשה עם סיבת דחייה
  ///
  /// [householdId] - מזהה משק הבית
  /// [listId] - מזהה הרשימה
  /// [requestId] - מזהה הבקשה
  /// [reviewerId] - מזהה הדוחה
  /// [reason] - סיבת הדחייה
  /// [reviewerName] - שם הדוחה (cache)
  ///
  /// Example:
  /// ```dart
  /// await repository.rejectRequest(
  ///   'house_demo',
  ///   'list_123',
  ///   'request_789',
  ///   'user_admin',
  ///   'יש לנו כבר בלונים בבית',
  ///   'דני מנהל',
  /// );
  /// ```
  Future<void> rejectRequest(
    String householdId,
    String listId,
    String requestId,
    String reviewerId,
    String reason,
    String? reviewerName,
  );

  /// מביא את כל הבקשות הממתינות לרשימה
  ///
  /// [householdId] - מזהה משק הבית
  /// [listId] - מזהה הרשימה
  ///
  /// Returns: רשימת בקשות ממתינות
  ///
  /// Example:
  /// ```dart
  /// final requests = await repository.getPendingRequests('house_demo', 'list_123');
  /// print('יש ${requests.length} בקשות ממתינות');
  /// ```
  Future<List<Map<String, dynamic>>> getPendingRequests(String householdId, String listId);
}
