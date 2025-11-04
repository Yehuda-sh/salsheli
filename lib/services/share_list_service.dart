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

import 'package:flutter/foundation.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/shared_user.dart';
import 'package:memozap/models/enums/user_role.dart';
import 'package:memozap/services/notifications_service.dart';

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
    NotificationsService? notificationsService,
  }) async {
    if (kDebugMode) {
      debugPrint('👥 ShareListService.inviteUser():');
      debugPrint('   List: ${list.name}');
      debugPrint('   Invited: $invitedUserId');
      debugPrint('   Role: ${role.hebrewName}');
    }

    // בדיקה 1: רק Owner יכול להזמין משתמשים
    if (list.createdBy != currentUserId) {
      if (kDebugMode) {
        debugPrint('   ❌ Permission denied: Only owner can invite users');
      }
      throw Exception('permission_denied');
    }

    // בדיקה 2: לא ניתן להזמין את ה-Owner
    if (invitedUserId == list.createdBy) {
      if (kDebugMode) {
        debugPrint('   ❌ Cannot invite the owner');
      }
      throw Exception('cannot_invite_owner');
    }

    // בדיקה 3: לא ניתן ליצור Owner נוסף
    if (role == UserRole.owner) {
      if (kDebugMode) {
        debugPrint('   ❌ Cannot create additional owner');
      }
      throw Exception('invalid_role');
    }

    // בדיקה 4: האם המשתמש כבר משותף
    final existingUser = list.sharedUsers
        .where((u) => u.userId == invitedUserId)
        .firstOrNull;

    if (existingUser != null) {
      if (kDebugMode) {
        debugPrint('   ⚠️ User already shared with role: ${existingUser.role.hebrewName}');
      }
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

    // עדכון הרשימה
    final updatedSharedUsers = [...list.sharedUsers, newSharedUser];

    if (kDebugMode) {
      debugPrint('   ✅ User invited successfully');
      debugPrint('   Total shared users: ${updatedSharedUsers.length}');
    }

    // שליחת התראה למשתמש המוזמן
    if (notificationsService != null) {
      try {
        await notificationsService.createInviteNotification(
          userId: invitedUserId,
          householdId: list.householdId,
          listId: list.id,
          listName: list.name,
          inviterName: inviterName,
          role: role.hebrewName,
        );
        if (kDebugMode) {
          debugPrint('   📬 Notification sent to $invitedUserId');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ⚠️ Failed to send notification: $e');
        }
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
    NotificationsService? notificationsService,
  }) async {
    if (kDebugMode) {
      debugPrint('🗑️ ShareListService.removeUser():');
      debugPrint('   List: ${list.name}');
      debugPrint('   Removed: $removedUserId');
    }

    // בדיקה 1: רק Owner יכול להסיר משתמשים
    if (list.createdBy != currentUserId) {
      if (kDebugMode) {
        debugPrint('   ❌ Permission denied: Only owner can remove users');
      }
      throw Exception('permission_denied');
    }

    // בדיקה 2: לא ניתן להסיר את ה-Owner
    if (removedUserId == list.createdBy) {
      if (kDebugMode) {
        debugPrint('   ❌ Cannot remove the owner');
      }
      throw Exception('cannot_remove_owner');
    }

    // בדיקה 3: האם המשתמש קיים ברשימה
    final userExists = list.sharedUsers
        .any((u) => u.userId == removedUserId);

    if (!userExists) {
      if (kDebugMode) {
        debugPrint('   ⚠️ User not found in shared users');
      }
      throw Exception('user_not_found');
    }

    // הסרת המשתמש
    final updatedSharedUsers = list.sharedUsers
        .where((u) => u.userId != removedUserId)
        .toList();

    if (kDebugMode) {
      debugPrint('   ✅ User removed successfully');
      debugPrint('   Remaining shared users: ${updatedSharedUsers.length}');
    }

    // שליחת התראה למשתמש שהוסר
    if (notificationsService != null) {
      try {
        await notificationsService.createUserRemovedNotification(
          userId: removedUserId,
          householdId: list.householdId,
          listId: list.id,
          listName: list.name,
          removerName: removerName,
        );
        if (kDebugMode) {
          debugPrint('   📬 Notification sent to $removedUserId');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ⚠️ Failed to send notification: $e');
        }
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
    NotificationsService? notificationsService,
  }) async {
    if (kDebugMode) {
      debugPrint('✏️ ShareListService.updateUserRole():');
      debugPrint('   List: ${list.name}');
      debugPrint('   Target: $targetUserId');
      debugPrint('   New role: ${newRole.hebrewName}');
    }

    // בדיקה 1: רק Owner יכול לשנות תפקידים
    if (list.createdBy != currentUserId) {
      if (kDebugMode) {
        debugPrint('   ❌ Permission denied: Only owner can update roles');
      }
      throw Exception('permission_denied');
    }

    // בדיקה 2: לא ניתן לשנות תפקיד של Owner
    if (targetUserId == list.createdBy) {
      if (kDebugMode) {
        debugPrint('   ❌ Cannot change owner role');
      }
      throw Exception('cannot_change_owner_role');
    }

    // בדיקה 3: לא ניתן ליצור Owner נוסף
    if (newRole == UserRole.owner) {
      if (kDebugMode) {
        debugPrint('   ❌ Cannot create additional owner');
      }
      throw Exception('invalid_role');
    }

    // בדיקה 4: האם המשתמש קיים ברשימה
    final targetUser = list.sharedUsers
        .where((u) => u.userId == targetUserId)
        .firstOrNull;

    if (targetUser == null) {
      if (kDebugMode) {
        debugPrint('   ⚠️ User not found in shared users');
      }
      throw Exception('user_not_found');
    }

    // עדכון התפקיד
    final updatedSharedUsers = list.sharedUsers.map((u) {
      if (u.userId == targetUserId) {
        return u.copyWith(role: newRole);
      }
      return u;
    }).toList();

    if (kDebugMode) {
      debugPrint('   ✅ Role updated successfully');
      debugPrint('   Old role: ${targetUser.role.hebrewName}');
      debugPrint('   New role: ${newRole.hebrewName}');
    }

    // שליחת התראה למשתמש שהתפקיד שלו השתנה
    if (notificationsService != null) {
      try {
        await notificationsService.createRoleChangedNotification(
          userId: targetUserId,
          householdId: list.householdId,
          listId: list.id,
          listName: list.name,
          oldRole: targetUser.role.hebrewName,
          newRole: newRole.hebrewName,
          changerName: changerName,
        );
        if (kDebugMode) {
          debugPrint('   📬 Notification sent to $targetUserId');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ⚠️ Failed to send notification: $e');
        }
      }
    }

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
    if (kDebugMode) {
      debugPrint('👥 ShareListService.getUsersForList():');
      debugPrint('   List: ${list.name}');
      debugPrint('   Include owner: $includeOwner');
    }

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

    // הוספת שאר המשתמשים
    users.addAll(list.sharedUsers);

    if (kDebugMode) {
      debugPrint('   Total users: ${users.length}');
      for (final user in users) {
        debugPrint('   - ${user.userId}: ${user.role.hebrewName} ${user.role.emoji}');
      }
    }

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

  // ---- Statistics & Analysis ----

  /// 🇮🇱 קבלת סטטיסטיקה על משתמשים
  /// 🇬🇧 Get users statistics
  static Map<String, int> getUsersStats(ShoppingList list) {
    final users = getUsersForList(list);

    final stats = <String, int>{
      'total': users.length,
      'owner': 0,
      'admin': 0,
      'editor': 0,
      'viewer': 0,
    };

    for (final user in users) {
      final roleKey = user.role.name;
      stats[roleKey] = (stats[roleKey] ?? 0) + 1;
    }

    if (kDebugMode) {
      debugPrint('📊 Users stats for ${list.name}:');
      stats.forEach((key, value) {
        if (value > 0) {
          debugPrint('   $key: $value');
        }
      });
    }

    return stats;
  }

  /// 🇮🇱 בדיקה אם הרשימה משותפת באמת
  /// 🇬🇧 Check if list is actually shared
  /// 
  /// רשימה נחשבת משותפת אם יש לה לפחות משתמש אחד מלבד ה-Owner
  static bool isListShared(ShoppingList list) {
    return list.sharedUsers.isNotEmpty;
  }

  /// 🇮🇱 קבלת כמות משתמשים פעילים
  /// 🇬🇧 Get count of active users
  static int getActiveUsersCount(ShoppingList list) {
    return getUsersForList(list).length;
  }
}
