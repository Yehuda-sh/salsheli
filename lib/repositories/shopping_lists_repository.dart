// 📄 File: lib/repositories/shopping_lists_repository.dart
//
// 🎯 Purpose: Interface לניהול רשימות קניות (Shopping Lists)
//
// 📋 Features:
//     - תמיכה בטעינה ממוזגת (Merged Fetch/Watch) - פרטיות + משותפות
//     - ניהול הרשאות מתקדם (Roles: owner/admin/editor/viewer)
//     - מערכת בקשות ממתינות (Pending Requests)
//     - תיעוד מלא ל-Intellisense
//
// 🏗️ Database Structure (Dual Collection):
//     - Private lists: `/users/{userId}/private_lists/{listId}`
//     - Shared lists: `/households/{householdId}/shared_lists/{listId}`
//
// 📋 Implementations:
//     - FirebaseShoppingListsRepository - מימוש הייצור (Firestore)
//
// 🔗 Related:
//     - lib/repositories/firebase_shopping_lists_repository.dart - המימוש
//     - lib/providers/shopping_lists_provider.dart - Provider שמשתמש ב-repository
//     - lib/models/shopping_list.dart - מבנה הנתונים
//
// 📜 History:
//     - v1.0: Interface ראשוני
//     - v2.0: הוספת sharing + roles
//     - v3.0 (14/12/2025): Dual collection (private + shared)
//     - v4.0 (22/02/2026): getListById, ארגון לפי קטגוריות, תיעוד מלא
//     - v4.1 (24/03/2026): addSharedUserToPrivateList added to interface
//
// Version: 4.1
// Last Updated: 24/03/2026

import '../models/shopping_list.dart';

/// Interface לניהול רשימות קניות
///
/// מגדיר חוזה לגישה לרשימות קניות עם ארכיטקטורת Dual Collection:
/// - **Private lists** - רשימות אישיות תחת `/users/{userId}/private_lists`
/// - **Shared lists** - רשימות משותפות תחת `/households/{householdId}/shared_lists`
///
/// כל מקור נתונים (Firebase, Mock) חייב לממש את הממשק הזה.
///
/// המתודות מחולקות לארבעה עולמות:
/// - **Fetch & Watch** - טעינה והאזנה לשינויים
/// - **Persistence** - שמירה, מחיקה ושיתוף
/// - **Sharing & Roles** - ניהול משתמשים והרשאות
/// - **Pending Requests** - מערכת בקשות ממתינות
abstract class ShoppingListsRepository {
  // ========================================
  // Fetch & Watch - טעינה והאזנה
  // ========================================

  /// טוען את כל רשימות הקניות של המשתמש (פרטיות + משותפות)
  ///
  /// מבצע טעינה ממוזגת משני מקורות:
  /// - `/users/{userId}/private_lists` - רשימות פרטיות
  /// - `/households/{householdId}/shared_lists` - רשימות משותפות (אם יש household)
  ///
  /// Parameters:
  ///   - [userId]: מזהה המשתמש (לרשימות פרטיות)
  ///   - [householdId]: מזהה משק הבית (לרשימות משותפות, `null` אם אין)
  ///
  /// Returns: רשימה ממוזגת של רשימות פרטיות + משותפות
  ///
  /// Example:
  /// ```dart
  /// final lists = await repository.fetchLists('user_123', 'house_demo');
  /// print('נטענו ${lists.length} רשימות');
  /// ```
  Future<List<ShoppingList>> fetchLists(String userId, String? householdId);

  /// מאזין לשינויים ברשימות בזמן אמת (פרטיות + משותפות)
  ///
  /// מחזיר Stream ממוזג משני מקורות - מתעדכן אוטומטית
  /// כאשר רשימה נוצרת/מתעדכנת/נמחקת (גם ע"י בן משפחה אחר).
  ///
  /// Parameters:
  ///   - [userId]: מזהה המשתמש (לרשימות פרטיות)
  ///   - [householdId]: מזהה משק הבית (לרשימות משותפות, `null` אם אין)
  ///
  /// Returns: Stream של רשימות שמתעדכן בכל שינוי
  ///
  /// Example:
  /// ```dart
  /// repository.watchLists('user_123', 'house_demo').listen((lists) {
  ///   print('קיבלנו ${lists.length} רשימות');
  /// });
  /// ```
  Stream<List<ShoppingList>> watchLists(String userId, String? householdId);

  /// מחזיר רשימה בודדת לפי ID
  ///
  /// מחפש קודם ברשימות פרטיות, אח"כ במשותפות.
  /// שימושי לניווט ישיר (למשל מתוך התראה או deep link).
  ///
  /// Parameters:
  ///   - [listId]: מזהה הרשימה
  ///   - [userId]: מזהה המשתמש (לחיפוש ברשימות פרטיות)
  ///   - [householdId]: מזהה משק הבית (לחיפוש במשותפות, `null` אם אין)
  ///
  /// Returns: הרשימה או `null` אם לא נמצאה
  ///
  /// Example:
  /// ```dart
  /// final list = await repository.getListById('list_123', 'user_123', 'house_demo');
  /// if (list != null) print('נמצאה: ${list.name}');
  /// ```
  Future<ShoppingList?> getListById(String listId, String userId, String? householdId);

  // ========================================
  // Persistence - שמירה, מחיקה ושיתוף
  // ========================================

  /// שומר או מעדכן רשימת קניות
  ///
  /// הרשימה נשמרת לפי `isPrivate`:
  /// - `true` → `/users/{userId}/private_lists/{listId}`
  /// - `false` → `/households/{householdId}/shared_lists/{listId}`
  ///
  /// Parameters:
  ///   - [list]: הרשימה לשמירה (חדשה או קיימת)
  ///   - [userId]: מזהה המשתמש (לרשימות פרטיות)
  ///   - [householdId]: מזהה משק הבית (לרשימות משותפות, `null` אם אין)
  ///
  /// Returns: הרשימה השמורה (עם timestamps מעודכנים מהשרת)
  ///
  /// Example:
  /// ```dart
  /// final saved = await repository.saveList(newList, 'user_123', 'house_demo');
  /// ```
  Future<ShoppingList> saveList(ShoppingList list, String userId, String? householdId);

  /// מוחק רשימת קניות
  ///
  /// Parameters:
  ///   - [id]: מזהה הרשימה למחיקה
  ///   - [userId]: מזהה המשתמש
  ///   - [householdId]: מזהה משק הבית (`null` אם אין)
  ///   - [isPrivate]: האם הרשימה פרטית (קובע מאיזה collection למחוק)
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteList('list_123', 'user_123', 'house_demo', true);
  /// ```
  Future<void> deleteList(String id, String userId, String? householdId, bool isPrivate);

  /// משתף רשימה פרטית למשק הבית
  ///
  /// מעביר רשימה מ-private_lists ל-shared_lists (atomic WriteBatch):
  /// 1. קורא את הרשימה מ-`/users/{userId}/private_lists/{listId}`
  /// 2. כותב ל-`/households/{householdId}/shared_lists/{listId}`
  /// 3. מוחק את המקור
  ///
  /// Parameters:
  ///   - [listId]: מזהה הרשימה
  ///   - [userId]: מזהה המשתמש (בעל הרשימה)
  ///   - [householdId]: מזהה משק הבית לשיתוף
  ///
  /// Returns: הרשימה המעודכנת (עם `isPrivate = false`)
  ///
  /// Example:
  /// ```dart
  /// final shared = await repository.shareListToHousehold(
  ///   'list_123', 'user_123', 'house_demo',
  /// );
  /// ```
  Future<ShoppingList> shareListToHousehold(
    String listId,
    String userId,
    String householdId,
  );

  // ========================================
  // Sharing & Roles - ניהול משתמשים והרשאות
  // ========================================

  /// מוסיף משתמש משותף לרשימה
  ///
  /// חל רק על רשימות משותפות (shared_lists).
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///   - [listId]: מזהה הרשימה
  ///   - [userId]: מזהה המשתמש להוספה
  ///   - [role]: תפקיד המשתמש (`admin` / `editor` / `viewer`)
  ///   - [userName]: שם המשתמש (cache לתצוגה)
  ///   - [userEmail]: אימייל המשתמש (cache לתצוגה)
  ///
  /// Example:
  /// ```dart
  /// await repository.addSharedUser(
  ///   'house_demo', 'list_123', 'user_456',
  ///   'editor', 'יוסי כהן', 'yossi@example.com',
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

  /// הוספת משתמש משותף לרשימה פרטית (לא household)
  ///
  /// משמש כאשר משתף רשימה עם אנשים ספציפיים מחוץ למשפחה.
  Future<void> addSharedUserToPrivateList({
    required String ownerId,
    required String listId,
    required String sharedUserId,
    required String role,
    String? userName,
    String? userEmail,
  });

  /// מסיר משתמש משותף מהרשימה
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///   - [listId]: מזהה הרשימה
  ///   - [userId]: מזהה המשתמש להסרה
  ///
  /// Example:
  /// ```dart
  /// await repository.removeSharedUser('house_demo', 'list_123', 'user_456');
  /// ```
  Future<void> removeSharedUser(String householdId, String listId, String userId);

  /// משנה את תפקיד המשתמש ברשימה
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///   - [listId]: מזהה הרשימה
  ///   - [userId]: מזהה המשתמש
  ///   - [newRole]: התפקיד החדש (`admin` / `editor` / `viewer`)
  ///
  /// Example:
  /// ```dart
  /// await repository.updateUserRole('house_demo', 'list_123', 'user_456', 'admin');
  /// ```
  Future<void> updateUserRole(String householdId, String listId, String userId, String newRole);

  /// מעביר בעלות על הרשימה למשתמש אחר (Transaction)
  ///
  /// הבעלים הנוכחי הופך ל-admin אוטומטית.
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///   - [listId]: מזהה הרשימה
  ///   - [currentOwnerId]: מזהה הבעלים הנוכחי
  ///   - [newOwnerId]: מזהה הבעלים החדש
  ///
  /// Example:
  /// ```dart
  /// await repository.transferOwnership(
  ///   'house_demo', 'list_123', 'user_old', 'user_new',
  /// );
  /// ```
  Future<void> transferOwnership(
    String householdId,
    String listId,
    String currentOwnerId,
    String newOwnerId,
  );

  // ========================================
  // Pending Requests - בקשות ממתינות
  // ========================================

  /// יוצר בקשה חדשה להוספה/עריכה/מחיקה
  ///
  /// חל רק על רשימות משותפות שבהן למבקש אין הרשאת עריכה ישירה.
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///   - [listId]: מזהה הרשימה
  ///   - [requesterId]: מזהה המבקש
  ///   - [type]: סוג הבקשה (`addItem` / `editItem` / `deleteItem`)
  ///   - [requestData]: תוכן הבקשה (פרטי הפריט)
  ///   - [requesterName]: שם המבקש (cache לתצוגה)
  ///
  /// Returns: מזהה הבקשה החדשה
  ///
  /// Example:
  /// ```dart
  /// final requestId = await repository.createRequest(
  ///   'house_demo', 'list_123', 'user_456',
  ///   'addItem', {'name': 'בלונים', 'quantity': 30}, 'יוסי כהן',
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

  /// מאשר בקשה ומבצע את הפעולה (Transaction)
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///   - [listId]: מזהה הרשימה
  ///   - [requestId]: מזהה הבקשה
  ///   - [reviewerId]: מזהה המאשר
  ///   - [reviewerName]: שם המאשר (cache לתצוגה)
  ///
  /// Example:
  /// ```dart
  /// await repository.approveRequest(
  ///   'house_demo', 'list_123', 'request_789', 'user_admin', 'דני מנהל',
  /// );
  /// ```
  Future<void> approveRequest(
    String householdId,
    String listId,
    String requestId,
    String reviewerId,
    String? reviewerName,
  );

  /// דוחה בקשה עם סיבת דחייה (Transaction)
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///   - [listId]: מזהה הרשימה
  ///   - [requestId]: מזהה הבקשה
  ///   - [reviewerId]: מזהה הדוחה
  ///   - [reason]: סיבת הדחייה
  ///   - [reviewerName]: שם הדוחה (cache לתצוגה)
  ///
  /// Example:
  /// ```dart
  /// await repository.rejectRequest(
  ///   'house_demo', 'list_123', 'request_789',
  ///   'user_admin', 'יש לנו כבר בלונים', 'דני מנהל',
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
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///   - [listId]: מזהה הרשימה
  ///
  /// Returns: רשימת בקשות ממתינות (כ-Map עם פרטי הבקשה)
  ///
  /// Example:
  /// ```dart
  /// final requests = await repository.getPendingRequests('house_demo', 'list_123');
  /// print('${requests.length} בקשות ממתינות');
  /// ```
  Future<List<Map<String, dynamic>>> getPendingRequests(String householdId, String listId);
}
