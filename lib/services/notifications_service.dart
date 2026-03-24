// 📄 lib/services/notifications_service.dart
//
// 📬 שירות התראות In-App - ניהול התראות ב-Firestore
//     - יצירת התראות (invite, approve, reject, role change, etc.)
//     - שאילתות (getUserNotifications, getUnreadCount)
//     - עדכון (markAsRead, markAllAsRead)
//     - מחיקה (deleteNotification, cleanupOldNotifications)
//
// ✅ תיקונים:
//    - try-catch לכל פעולות Firestore
//    - logging גם ב-release mode (dart:developer log)
//    - NotificationQueryResult typed result לשאילתות
//    - פעולות Create מחזירות Future<bool>
//
// 🔗 Related: AppNotification, FirestoreCollections

import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:memozap/models/notification.dart';
import 'package:memozap/repositories/constants/repository_constants.dart';
import 'package:uuid/uuid.dart';

// ========================================
// 🆕 Typed Result for Notification Queries
// ========================================

/// סוגי תוצאות לשאילתות התראות
enum NotificationQueryResultType {
  /// הצלחה - יש תוצאות
  success,

  /// רשימה ריקה (לא שגיאה)
  empty,

  /// שגיאת Firestore
  error,
}

/// תוצאת שאילתת התראות - Type-Safe!
///
/// **Usage:**
/// ```dart
/// final result = await notificationsService.getUserNotificationsResult(userId: '...');
/// if (result.isSuccess) {
///   for (final notification in result.notifications!) {
///     // ...
///   }
/// } else if (result.type == NotificationQueryResultType.error) {
///   print('Error: ${result.errorMessage}');
/// }
/// ```
class NotificationQueryResult {
  final NotificationQueryResultType type;
  final List<AppNotification>? notifications;
  final int? count;
  final String? errorMessage;

  const NotificationQueryResult._({
    required this.type,
    this.notifications,
    this.count,
    this.errorMessage,
  });

  /// הצלחה עם רשימת התראות
  factory NotificationQueryResult.success(List<AppNotification> notifications) {
    return NotificationQueryResult._(
      type: notifications.isEmpty
          ? NotificationQueryResultType.empty
          : NotificationQueryResultType.success,
      notifications: notifications,
      count: notifications.length,
    );
  }

  /// הצלחה עם ספירה בלבד
  factory NotificationQueryResult.count(int count) {
    return NotificationQueryResult._(
      type: count == 0
          ? NotificationQueryResultType.empty
          : NotificationQueryResultType.success,
      count: count,
    );
  }

  /// שגיאה
  factory NotificationQueryResult.error(String message) {
    return NotificationQueryResult._(
      type: NotificationQueryResultType.error,
      errorMessage: message,
    );
  }

  /// האם הצליח
  bool get isSuccess =>
      type == NotificationQueryResultType.success ||
      type == NotificationQueryResultType.empty;

  /// האם יש התראות
  bool get hasNotifications => notifications != null && notifications!.isNotEmpty;
}

/// 📬 Notifications Service
///
/// Manages in-app notifications for Phase 3B User Sharing System
///
/// Features:
/// - Create notifications for invite/approve/reject/role change
/// - Mark as read
/// - Get unread count (for badge)
/// - Query user notifications
/// - Auto-cleanup old read notifications (30 days)
///
/// 🏗️ Database Structure:
///     - /users/{userId}/notifications/{notificationId}
///
/// Version: 2.1 - Release-mode logging via dart:developer
/// Created: 04/11/2025
/// Last Updated: 15/03/2026

class NotificationsService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  NotificationsService(this._firestore, [Uuid? uuid])
      : _uuid = uuid ?? const Uuid();

  // ========================================
  // Logging Helper
  // ========================================

  /// לוג שגיאה — פעיל גם ב-release mode (dart:developer)
  ///
  /// ב-debug: debugPrintStack מלא
  /// ב-release: developer.log עם שם הפעולה והשגיאה
  void _logError(String operation, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ NotificationsService.$operation: $error');
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace);
      }
    } else {
      developer.log(
        '$operation failed: $error',
        name: 'NotificationsService',
        error: error,
        stackTrace: stackTrace,
        level: 900, // WARNING level
      );
    }
  }

  // ========================================
  // Collection Reference
  // ========================================

  /// מחזיר reference לקולקציית ההתראות של משתמש
  /// Path: /users/{userId}/notifications
  CollectionReference<Map<String, dynamic>> _notificationsCollection(String userId) =>
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.notifications);

  // ============================================================
  // CREATE NOTIFICATIONS
  // ============================================================

  /// ✉️ Create invite notification
  /// Owner/Admin invites user to shared list
  ///
  /// ✅ מחזיר `true` אם ההתראה נוצרה בהצלחה
  Future<bool> createInviteNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String inviterName,
    required String role,
  }) async {
    try {
      final notification = AppNotification(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: NotificationType.invite,
        title: 'הזמנה לרשימה משותפת',
        message: '$inviterName הזמין אותך לרשימה "$listName" בתפקיד $role',
        actionData: {
          'listId': listId,
          'listName': listName,
          'inviterName': inviterName,
          'role': role,
        },
        createdAt: DateTime.now(),
      );

      // 🆕 שימוש ב-subcollection - הבעלות מאומתת דרך הנתיב
      await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());

      return true;
    } catch (e, stackTrace) {
      _logError('createInviteNotification', e, stackTrace);
      return false;
    }
  }

  /// ✅ Create request approved notification
  /// Owner/Admin approved Editor's item request
  ///
  /// ✅ מחזיר `true` אם ההתראה נוצרה בהצלחה
  Future<bool> createRequestApprovedNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required String approverName,
  }) async {
    try {
      final notification = AppNotification(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: NotificationType.requestApproved,
        title: 'בקשה אושרה ✅',
        message: '$approverName אישר את הבקשה להוספת "$itemName" לרשימה "$listName"',
        actionData: {
          'listId': listId,
          'listName': listName,
          'itemName': itemName,
          'approverName': approverName,
        },
        createdAt: DateTime.now(),
      );

      // 🆕 שימוש ב-subcollection
      await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());

      return true;
    } catch (e, stackTrace) {
      _logError('createRequestApprovedNotification', e, stackTrace);
      return false;
    }
  }

  /// ❌ Create request rejected notification
  /// Owner/Admin rejected Editor's item request
  ///
  /// ✅ מחזיר `true` אם ההתראה נוצרה בהצלחה
  Future<bool> createRequestRejectedNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required String reviewerName,
    String? reason,
  }) async {
    try {
      final message = reason != null && reason.isNotEmpty
          ? '$reviewerName דחה את הבקשה להוספת "$itemName": $reason'
          : '$reviewerName דחה את הבקשה להוספת "$itemName"';

      final notification = AppNotification(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: NotificationType.requestRejected,
        title: 'בקשה נדחתה ❌',
        message: message,
        actionData: {
          'listId': listId,
          'listName': listName,
          'itemName': itemName,
          'reviewerName': reviewerName,
          if (reason != null) 'reason': reason,
        },
        createdAt: DateTime.now(),
      );

      // 🆕 שימוש ב-subcollection
      await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());

      return true;
    } catch (e, stackTrace) {
      _logError('createRequestRejectedNotification', e, stackTrace);
      return false;
    }
  }

  /// 🔄 Create role changed notification
  /// Owner/Admin changed user role
  ///
  /// ✅ מחזיר `true` אם ההתראה נוצרה בהצלחה
  Future<bool> createRoleChangedNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String oldRole,
    required String newRole,
    required String changerName,
  }) async {
    try {
      final notification = AppNotification(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: NotificationType.roleChanged,
        title: 'תפקיד השתנה',
        message: '$changerName שינה את תפקידך ברשימה "$listName" מ-$oldRole ל-$newRole',
        actionData: {
          'listId': listId,
          'listName': listName,
          'oldRole': oldRole,
          'newRole': newRole,
          'changerName': changerName,
        },
        createdAt: DateTime.now(),
      );

      // 🆕 שימוש ב-subcollection
      await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());

      return true;
    } catch (e, stackTrace) {
      _logError('createRoleChangedNotification', e, stackTrace);
      return false;
    }
  }

  /// 🚫 Create user removed notification
  /// Owner/Admin removed user from list
  ///
  /// ✅ מחזיר `true` אם ההתראה נוצרה בהצלחה
  Future<bool> createUserRemovedNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String removerName,
  }) async {
    try {
      final notification = AppNotification(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: NotificationType.userRemoved,
        title: 'הוסרת מרשימה',
        message: '$removerName הסיר אותך מהרשימה "$listName"',
        actionData: {
          'listId': listId,
          'listName': listName,
          'removerName': removerName,
        },
        createdAt: DateTime.now(),
      );

      // 🆕 שימוש ב-subcollection
      await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());

      return true;
    } catch (e, stackTrace) {
      _logError('createUserRemovedNotification', e, stackTrace);
      return false;
    }
  }

  // ============================================================
  // STAGE 6: NEW NOTIFICATION TYPES
  // ============================================================

  /// 🙋 Create "who brings" volunteer notification
  /// Someone volunteered to bring an item
  ///
  /// ✅ מחזיר `true` אם ההתראה נוצרה בהצלחה
  Future<bool> createWhoBringsVolunteerNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required String volunteerName,
  }) async {
    try {
      final notification = AppNotification(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: NotificationType.whoBringsVolunteer,
        title: 'התנדבות חדשה 🙋',
        message: '$volunteerName התנדב להביא "$itemName" לרשימה "$listName"',
        actionData: {
          'listId': listId,
          'listName': listName,
          'itemName': itemName,
          'volunteerName': volunteerName,
        },
        createdAt: DateTime.now(),
      );

      await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());

      return true;
    } catch (e, stackTrace) {
      _logError('createWhoBringsVolunteerNotification', e, stackTrace);
      return false;
    }
  }

  /// 🗳️ Create new vote notification
  /// Someone voted on an item
  ///
  /// ✅ מחזיר `true` אם ההתראה נוצרה בהצלחה
  Future<bool> createNewVoteNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required String voterName,
    required String voteType, // 'for', 'against', 'abstain'
  }) async {
    try {
      final voteEmoji = voteType == 'for' ? '👍' : (voteType == 'against' ? '👎' : '🤷');
      final voteHebrew = voteType == 'for' ? 'בעד' : (voteType == 'against' ? 'נגד' : 'נמנע');

      final notification = AppNotification(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: NotificationType.newVote,
        title: 'הצבעה חדשה $voteEmoji',
        message: '$voterName הצביע $voteHebrew ב"$itemName" ברשימה "$listName"',
        actionData: {
          'listId': listId,
          'listName': listName,
          'itemName': itemName,
          'voterName': voterName,
          'voteType': voteType,
        },
        createdAt: DateTime.now(),
      );

      await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());

      return true;
    } catch (e, stackTrace) {
      _logError('createNewVoteNotification', e, stackTrace);
      return false;
    }
  }

  /// ⚖️ Create vote tie notification (for owners)
  /// Voting ended in a tie
  ///
  /// ✅ מחזיר `true` אם ההתראה נוצרה בהצלחה
  Future<bool> createVoteTieNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required int votesFor,
    required int votesAgainst,
  }) async {
    try {
      final notification = AppNotification(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: NotificationType.voteTie,
        title: 'תיקו בהצבעה ⚖️',
        message: 'ההצבעה על "$itemName" ברשימה "$listName" הסתיימה בתיקו ($votesFor-$votesAgainst). נדרשת החלטת בעלים.',
        actionData: {
          'listId': listId,
          'listName': listName,
          'itemName': itemName,
          'votesFor': votesFor,
          'votesAgainst': votesAgainst,
        },
        createdAt: DateTime.now(),
      );

      await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());

      return true;
    } catch (e, stackTrace) {
      _logError('createVoteTieNotification', e, stackTrace);
      return false;
    }
  }

  /// 📦 Create low stock notification (for household)
  /// An item is running low
  ///
  /// ✅ מחזיר `true` אם ההתראה נוצרה בהצלחה
  Future<bool> createLowStockNotification({
    required String userId,
    required String householdId,
    required String productName,
    required int currentStock,
    required int minStock,
  }) async {
    try {
      final notification = AppNotification(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: NotificationType.lowStock,
        title: 'מלאי נמוך 📦',
        message: 'המלאי של "$productName" נמוך ($currentStock יחידות). מומלץ להוסיף לרשימת קניות.',
        actionData: {
          'productName': productName,
          'currentStock': currentStock,
          'minStock': minStock,
        },
        createdAt: DateTime.now(),
      );

      await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());

      return true;
    } catch (e, stackTrace) {
      _logError('createLowStockNotification', e, stackTrace);
      return false;
    }
  }

  // ============================================================
  // QUERY NOTIFICATIONS
  // ============================================================

  /// 📋 Get user notifications (ordered by created_at desc)
  ///
  /// ✅ מחזיר [NotificationQueryResult] עם סוג תוצאה ברור
  Future<NotificationQueryResult> getUserNotificationsResult({
    required String userId,
    int limit = 50,
  }) async {
    try {

      final snapshot = await _notificationsCollection(userId)
          .orderBy(FirestoreFields.createdAt, descending: true)
          .limit(limit)
          .get();

      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data()))
          .toList();


      return NotificationQueryResult.success(notifications);
    } catch (e, stackTrace) {
      _logError('getUserNotificationsResult', e, stackTrace);
      return NotificationQueryResult.error(e.toString());
    }
  }

  // ✅ REMOVED: getUserNotifications() — use getUserNotificationsResult() instead

  /// 📬 Get unread notifications
  ///
  /// ✅ מחזיר [NotificationQueryResult] עם סוג תוצאה ברור
  Future<NotificationQueryResult> getUnreadNotificationsResult({
    required String userId,
  }) async {
    try {

      final snapshot = await _notificationsCollection(userId)
          .where('is_read', isEqualTo: false)
          .orderBy(FirestoreFields.createdAt, descending: true)
          .get();

      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data()))
          .toList();


      return NotificationQueryResult.success(notifications);
    } catch (e, stackTrace) {
      _logError('getUnreadNotificationsResult', e, stackTrace);
      return NotificationQueryResult.error(e.toString());
    }
  }

  // ✅ REMOVED: getUnreadNotifications() — use getUnreadNotificationsResult() instead

  /// 🔢 Get unread count (for badge)
  ///
  /// ✅ מחזיר [NotificationQueryResult] עם סוג תוצאה ברור
  Future<NotificationQueryResult> getUnreadCountResult({required String userId}) async {
    try {
      final snapshot = await _notificationsCollection(userId)
          .where('is_read', isEqualTo: false)
          .get();

      final count = snapshot.docs.length;


      return NotificationQueryResult.count(count);
    } catch (e, stackTrace) {
      _logError('getUnreadCountResult', e, stackTrace);
      return NotificationQueryResult.error(e.toString());
    }
  }

  // ✅ REMOVED: getUnreadCount() — use getUnreadCountResult() instead

  /// 📊 Stream unread count (real-time badge)
  ///
  /// Note: Streams לא מחזירים typed result - שגיאות מועברות דרך onError
  Stream<int> watchUnreadCount({required String userId}) {

    return _notificationsCollection(userId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final count = snapshot.docs.length;
          return count;
        });
  }

  // ============================================================
  // UPDATE NOTIFICATIONS
  // ============================================================

  /// ✅ Mark notification as read
  ///
  /// 🆕 נדרש userId כדי לגשת ל-subcollection הנכון
  /// ✅ מחזיר `true` אם העדכון הצליח
  Future<bool> markAsRead({
    required String notificationId,
    required String userId,
  }) async {
    try {
      await _notificationsCollection(userId).doc(notificationId).update({
        'is_read': true,
        'read_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e, stackTrace) {
      _logError('markAsRead', e, stackTrace);
      return false;
    }
  }

  /// ✅ Mark all as read (for user)
  ///
  /// ✅ מחזיר מספר ההתראות שעודכנו, או -1 בשגיאה
  /// ✅ Chunked into batches of 500 (Firestore batch limit)
  Future<int> markAllAsRead({required String userId}) async {
    try {
      // 🆕 שימוש ב-subcollection - לא צריך where על user_id
      final snapshot = await _notificationsCollection(userId)
          .where('is_read', isEqualTo: false)
          .get();

      final docs = snapshot.docs;

      // Firestore batch limit is 500 operations
      const batchLimit = 500;
      for (var i = 0; i < docs.length; i += batchLimit) {
        final batch = _firestore.batch();
        final end = (i + batchLimit < docs.length) ? i + batchLimit : docs.length;
        for (var j = i; j < end; j++) {
          batch.update(docs[j].reference, {
            'is_read': true,
            'read_at': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }

      return docs.length;
    } catch (e, stackTrace) {
      _logError('markAllAsRead', e, stackTrace);
      return -1;
    }
  }

  // ============================================================
  // DELETE NOTIFICATIONS
  // ============================================================

  /// 🗑️ Delete notification
  ///
  /// 🆕 נדרש userId כדי לגשת ל-subcollection הנכון
  /// ✅ מחזיר `true` אם המחיקה הצליחה
  Future<bool> deleteNotification({
    required String notificationId,
    required String userId,
  }) async {
    try {
      await _notificationsCollection(userId).doc(notificationId).delete();

      return true;
    } catch (e, stackTrace) {
      _logError('deleteNotification', e, stackTrace);
      return false;
    }
  }

  /// 🧹 Cleanup old read notifications (30 days)
  /// Call this periodically or on app startup
  ///
  /// ✅ מחזיר מספר ההתראות שנמחקו, או -1 בשגיאה
  Future<int> cleanupOldNotifications({
    required String userId,
    int daysOld = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));


      // 🆕 שימוש ב-subcollection - לא צריך where על user_id
      final snapshot = await _notificationsCollection(userId)
          .where('is_read', isEqualTo: true)
          .where('read_at', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      return snapshot.docs.length;
    } catch (e, stackTrace) {
      _logError('cleanupOldNotifications', e, stackTrace);
      return -1;
    }
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// 📊 Get notification stats
  ///
  /// ✅ מחזיר מפה עם סטטיסטיקות, או מפה ריקה בשגיאה
  Future<Map<String, int>> getNotificationStats({required String userId}) async {
    try {

      // 🆕 שימוש ב-subcollection - לא צריך where על user_id
      final allSnapshot = await _notificationsCollection(userId).get();

      final unreadSnapshot = await _notificationsCollection(userId)
          .where('is_read', isEqualTo: false)
          .get();

      final stats = {
        'total': allSnapshot.docs.length,
        'unread': unreadSnapshot.docs.length,
        'read': allSnapshot.docs.length - unreadSnapshot.docs.length,
      };


      return stats;
    } catch (e, stackTrace) {
      _logError('getNotificationStats', e, stackTrace);
      return {'total': 0, 'unread': 0, 'read': 0};
    }
  }
}
