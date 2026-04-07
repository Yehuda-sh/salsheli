// 📄 File: lib/services/share_list_service.dart
//
// 🇮🇱 שירות שיתוף רשימות:
//     - ניהול משתמשים משותפים (הזמנה, הסרה, עדכון תפקיד)
//     - אכיפת הרשאות (רק Owner יכול לנהל)
//     - סנכרון עם Firebase
//     - תמיכה ב-4 רמות הרשאה (Owner, Admin, Editor, Viewer)
//
// 🔒 אבטחה:
//     - רק Owner יכול להזמין/להסיר/לשנות תפקידים
//     - Owner לא ניתן להסרה
//     - בדיקת הרשאות לפני כל פעולה
//
// 🔁 תהליך עבודה:
//     1. inviteUser() - הזמנת משתמש חדש עם תפקיד
//     2. removeUser() - הסרת משתמש מהרשימה
//     3. updateUserRole() - שינוי תפקיד משתמש
//     4. getUsersForList() - קבלת כל המשתמשים ברשימה
//
// 🇬🇧 Share list service:
//     - Manage shared users (invite, remove, update role)
//     - Enforce permissions (only Owner can manage)
//     - Sync with Firebase
//     - Support 4 permission levels (Owner, Admin, Editor, Viewer)

import 'dart:async';

import '../models/activity_event.dart';
import '../models/enums/user_role.dart';
import '../models/shared_user.dart';
import '../models/shopping_list.dart';
import '../services/activity_log_service.dart';
import '../services/notifications_service.dart';

/// 🇮🇱 שירות שיתוף רשימות
/// 🇬🇧 Share list service
class ShareListService {
  /// 🇮🇱 הזמנת משתמש חדש לרשימה
  /// 🇬🇧 Invite a new user to the list
  /// 
  /// פרמטרים:
  /// - list: הרשימה המשותפת
  /// - currentUserId: מזהה המשתמש הנוכחי (חייב להיות Owner)
  /// - invitedUserId: מזהה המשתמש המוזמן
  /// - role: תפקיד למשתמש החדש (Admin/Editor/Viewer)
  /// - userName: שם המשתמש (אופציונלי, לcache)
  /// - userEmail: אימייל המשתמש (אופציונלי, לcache)
  /// - userAvatar: תמונה של המשתמש (אופציונלי, לcache)
  /// 
  /// מחזיר: רשימה מעודכנת או זורק שגיאה
  /// 
  /// זורק:
  /// - 'permission_denied' אם המשתמש הנוכחי לא Owner
  /// - 'user_already_shared' אם המשתמש כבר משותף
  /// - 'cannot_invite_owner' אם מנסים להזמין את ה-Owner
  /// - 'invalid_role' אם מנסים ליצור Owner נוסף
  static Future<ShoppingList> inviteUser({
    required ShoppingList list,
    required String currentUserId,
    required String invitedUserId,
    required UserRole role,
    String? userName,
    String? userEmail,
    String? userAvatar,
    required String inviterName,
    required String householdId,
    NotificationsService? notificationsService,
  }) async {

    // בדיקה 1: רק Owner יכול להזמין משתמשים
    if (list.createdBy != currentUserId) {
      throw Exception('permission_denied');
    }

    // בדיקה 2: לא ניתן להזמין את ה-Owner
    if (invitedUserId == list.createdBy) {
      throw Exception('cannot_invite_owner');
    }

    // בדיקה 3: לא ניתן ליצור Owner נוסף
    if (role == UserRole.owner) {
      throw Exception('invalid_role');
    }

    // בדיקה 4: האם המשתמש כבר משותף
    // 🆕 Map lookup - O(1)
    final existingUser = list.sharedUsers[invitedUserId];

    if (existingUser != null) {
      throw Exception('user_already_shared');
    }

    // יצירת משתמש משותף חדש
    final newSharedUser = SharedUser(
      userId: invitedUserId,
      role: role,
      sharedAt: DateTime.now(),
      userName: userName,
      userEmail: userEmail,
      userAvatar: userAvatar,
    );

    // 🆕 עדכון המפה (Map)
    final updatedSharedUsers = Map<String, SharedUser>.from(list.sharedUsers)
      ..[invitedUserId] = newSharedUser;


    // שליחת התראה למשתמש המוזמן
    if (notificationsService != null) {
      try {
        await notificationsService.createInviteNotification(
          userId: invitedUserId,
          householdId: householdId,
          listId: list.id,
          listName: list.name,
          inviterName: inviterName,
          role: role.hebrewName,
        );
      } catch (e) {
      }
    }

    return list.copyWith(
      sharedUsers: updatedSharedUsers,
      updatedDate: DateTime.now(),
      isShared: true, // מעכשיו הרשימה משותפת
    );
  }

  /// 🇮🇱 הסרת משתמש מהרשימה
  /// 🇬🇧 Remove a user from the list
  /// 
  /// פרמטרים:
  /// - list: הרשימה המשותפת
  /// - currentUserId: מזהה המשתמש הנוכחי (חייב להיות Owner)
  /// - removedUserId: מזהה המשתמש להסרה
  /// 
  /// מחזיר: רשימה מעודכנת או זורק שגיאה
  /// 
  /// זורק:
  /// - 'permission_denied' אם המשתמש הנוכחי לא Owner
  /// - 'cannot_remove_owner' אם מנסים להסיר את ה-Owner
  /// - 'user_not_found' אם המשתמש לא נמצא ברשימה
  static Future<ShoppingList> removeUser({
    required ShoppingList list,
    required String currentUserId,
    required String removedUserId,
    required String removerName,
    required String householdId,
    NotificationsService? notificationsService,
  }) async {

    // בדיקה 1: רק Owner יכול להסיר משתמשים
    if (list.createdBy != currentUserId) {
      throw Exception('permission_denied');
    }

    // בדיקה 2: לא ניתן להסיר את ה-Owner
    if (removedUserId == list.createdBy) {
      throw Exception('cannot_remove_owner');
    }

    // בדיקה 3: האם המשתמש קיים ברשימה
    // 🆕 Map lookup - O(1)
    final userExists = list.sharedUsers.containsKey(removedUserId);

    if (!userExists) {
      throw Exception('user_not_found');
    }

    // 🆕 הסרת המשתמש מהמפה
    final updatedSharedUsers = Map<String, SharedUser>.from(list.sharedUsers)
      ..remove(removedUserId);


    // שליחת התראה למשתמש שהוסר
    if (notificationsService != null) {
      try {
        await notificationsService.createUserRemovedNotification(
          userId: removedUserId,
          householdId: householdId,
          listId: list.id,
          listName: list.name,
          removerName: removerName,
        );
      } catch (e) {
      }
    }

    return list.copyWith(
      sharedUsers: updatedSharedUsers,
      updatedDate: DateTime.now(),
      isShared: updatedSharedUsers.isNotEmpty, // אם אין יותר משתמשים, לא משותף
    );
  }

  /// 🇮🇱 עדכון תפקיד משתמש
  /// 🇬🇧 Update user role
  /// 
  /// פרמטרים:
  /// - list: הרשימה המשותפת
  /// - currentUserId: מזהה המשתמש הנוכחי (חייב להיות Owner)
  /// - targetUserId: מזהה המשתמש לעדכון
  /// - newRole: תפקיד חדש (Admin/Editor/Viewer)
  /// 
  /// מחזיר: רשימה מעודכנת או זורק שגיאה
  /// 
  /// זורק:
  /// - 'permission_denied' אם המשתמש הנוכחי לא Owner
  /// - 'cannot_change_owner_role' אם מנסים לשנות תפקיד של Owner
  /// - 'invalid_role' אם מנסים ליצור Owner נוסף
  /// - 'user_not_found' אם המשתמש לא נמצא ברשימה
  static Future<ShoppingList> updateUserRole({
    required ShoppingList list,
    required String currentUserId,
    required String targetUserId,
    required UserRole newRole,
    required String changerName,
    required String householdId,
    NotificationsService? notificationsService,
  }) async {

    // בדיקה 1: רק Owner יכול לשנות תפקידים
    if (list.createdBy != currentUserId) {
      throw Exception('permission_denied');
    }

    // בדיקה 2: לא ניתן לשנות תפקיד של Owner
    if (targetUserId == list.createdBy) {
      throw Exception('cannot_change_owner_role');
    }

    // בדיקה 3: לא ניתן ליצור Owner נוסף
    if (newRole == UserRole.owner) {
      throw Exception('invalid_role');
    }

    // בדיקה 4: האם המשתמש קיים ברשימה
    // 🆕 Map lookup - O(1)
    final targetUser = list.sharedUsers[targetUserId];

    if (targetUser == null) {
      throw Exception('user_not_found');
    }

    // 🆕 עדכון התפקיד במפה
    final updatedSharedUsers = Map<String, SharedUser>.from(list.sharedUsers)
      ..[targetUserId] = targetUser.copyWith(role: newRole);


    // שליחת התראה למשתמש שהתפקיד שלו השתנה
    if (notificationsService != null) {
      try {
        await notificationsService.createRoleChangedNotification(
          userId: targetUserId,
          householdId: householdId,
          listId: list.id,
          listName: list.name,
          oldRole: targetUser.role.hebrewName,
          newRole: newRole.hebrewName,
          changerName: changerName,
        );
      } catch (e) {
      }
    }

    // 📝 Activity log
    unawaited(ActivityLogService().log(
      householdId: householdId,
      type: ActivityType.roleChanged,
      actorId: currentUserId,
      actorName: changerName,
      data: {
        'target_name': targetUser.userName ?? '',
        'new_role': newRole.name,
        'list_id': list.id,
        'list_name': list.name,
      },
    ));

    return list.copyWith(
      sharedUsers: updatedSharedUsers,
      updatedDate: DateTime.now(),
    );
  }

  /// 🇮🇱 קבלת כל המשתמשים ברשימה
  /// 🇬🇧 Get all users for the list
  /// 
  /// מחזיר רשימה של SharedUser שכוללת גם את ה-Owner
  /// 
  /// פרמטרים:
  /// - list: הרשימה
  /// - includeOwner: האם לכלול את ה-Owner (ברירת מחדל: true)
  /// 
  /// מחזיר: רשימת כל המשתמשים (Owner + שותפים)
  static List<SharedUser> getUsersForList(
    ShoppingList list, {
    bool includeOwner = true,
  }) {

    final users = <SharedUser>[];

    // הוספת Owner (תמיד בתור הראשון)
    if (includeOwner) {
      final owner = SharedUser(
        userId: list.createdBy,
        role: UserRole.owner,
        sharedAt: list.createdDate,
      );
      users.add(owner);
    }

    // 🆕 הוספת שאר המשתמשים מהמפה
    users.addAll(list.sharedUsers.values);

    return users;
  }

  /// 🇮🇱 בדיקה אם המשתמש יכול לערוך את הרשימה
  /// 🇬🇧 Check if user can edit the list
  /// 
  /// פרמטרים:
  /// - list: הרשימה
  /// - userId: מזהה המשתמש
  /// 
  /// מחזיר: true אם המשתמש הוא Owner או Admin
  static bool canUserEdit(ShoppingList list, String userId) {
    final role = list.getUserRole(userId);
    return role == UserRole.owner || role == UserRole.admin;
  }

  /// 🇮🇱 בדיקה אם המשתמש יכול לאשר בקשות
  /// 🇬🇧 Check if user can approve requests
  /// 
  /// פרמטרים:
  /// - list: הרשימה
  /// - userId: מזהה המשתמש
  /// 
  /// מחזיר: true אם המשתמש הוא Owner או Admin
  static bool canUserApprove(ShoppingList list, String userId) {
    final role = list.getUserRole(userId);
    return role == UserRole.owner || role == UserRole.admin;
  }

  /// 🇮🇱 בדיקה אם המשתמש יכול לנהל משתמשים
  /// 🇬🇧 Check if user can manage users
  /// 
  /// פרמטרים:
  /// - list: הרשימה
  /// - userId: מזהה המשתמש
  /// 
  /// מחזיר: true רק אם המשתמש הוא Owner
  static bool canUserManage(ShoppingList list, String userId) {
    return list.createdBy == userId;
  }

  /// 🇮🇱 בדיקה אם המשתמש צריך לשלוח בקשה
  /// 🇬🇧 Check if user needs to send request
  /// 
  /// פרמטרים:
  /// - list: הרשימה
  /// - userId: מזהה המשתמש
  /// 
  /// מחזיר: true אם המשתמש הוא Editor (צריך אישור)
  static bool shouldUserRequest(ShoppingList list, String userId) {
    final role = list.getUserRole(userId);
    return role == UserRole.editor;
  }

}
