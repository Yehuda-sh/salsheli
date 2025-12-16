import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memozap/models/notification.dart';
import 'package:memozap/repositories/constants/repository_constants.dart';
import 'package:uuid/uuid.dart';

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
/// Version: 2.0 - Subcollection support
/// Created: 04/11/2025
/// Last Updated: 14/12/2025

class NotificationsService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  NotificationsService(this._firestore, [Uuid? uuid])
      : _uuid = uuid ?? const Uuid();

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
  Future<void> createInviteNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String inviterName,
    required String role,
  }) async {
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
  }

  /// ✅ Create request approved notification
  /// Owner/Admin approved Editor's item request
  Future<void> createRequestApprovedNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required String approverName,
  }) async {
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
  }

  /// ❌ Create request rejected notification
  /// Owner/Admin rejected Editor's item request
  Future<void> createRequestRejectedNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required String reviewerName,
    String? reason,
  }) async {
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
  }

  /// 🔄 Create role changed notification
  /// Owner/Admin changed user role
  Future<void> createRoleChangedNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String oldRole,
    required String newRole,
    required String changerName,
  }) async {
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
  }

  /// 🚫 Create user removed notification
  /// Owner/Admin removed user from list
  Future<void> createUserRemovedNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String removerName,
  }) async {
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
  }

  // ============================================================
  // STAGE 6: NEW NOTIFICATION TYPES
  // ============================================================

  /// 👥 Create group invite notification
  /// User invited to a group
  Future<void> createGroupInviteNotification({
    required String userId,
    required String householdId,
    required String groupId,
    required String groupName,
    required String inviterName,
  }) async {
    final notification = AppNotification(
      id: _uuid.v4(),
      userId: userId,
      householdId: householdId,
      type: NotificationType.groupInvite,
      title: 'הזמנה לקבוצה',
      message: '$inviterName הזמין אותך להצטרף לקבוצה "$groupName"',
      actionData: {
        'groupId': groupId,
        'groupName': groupName,
        'inviterName': inviterName,
      },
      createdAt: DateTime.now(),
    );

    await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());
  }

  /// 🙋 Create "who brings" volunteer notification
  /// Someone volunteered to bring an item
  Future<void> createWhoBringsVolunteerNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required String volunteerName,
  }) async {
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
  }

  /// 🗳️ Create new vote notification
  /// Someone voted on an item
  Future<void> createNewVoteNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required String voterName,
    required String voteType, // 'for', 'against', 'abstain'
  }) async {
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
  }

  /// ⚖️ Create vote tie notification (for owners)
  /// Voting ended in a tie
  Future<void> createVoteTieNotification({
    required String userId,
    required String householdId,
    required String listId,
    required String listName,
    required String itemName,
    required int votesFor,
    required int votesAgainst,
  }) async {
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
  }

  /// 👋 Create member left notification (for admins)
  /// A member left the group
  Future<void> createMemberLeftNotification({
    required String userId,
    required String householdId,
    required String groupId,
    required String groupName,
    required String memberName,
  }) async {
    final notification = AppNotification(
      id: _uuid.v4(),
      userId: userId,
      householdId: householdId,
      type: NotificationType.memberLeft,
      title: 'חבר עזב את הקבוצה 👋',
      message: '$memberName עזב את הקבוצה "$groupName"',
      actionData: {
        'groupId': groupId,
        'groupName': groupName,
        'memberName': memberName,
      },
      createdAt: DateTime.now(),
    );

    await _notificationsCollection(userId).doc(notification.id).set(notification.toJson());
  }

  /// 📦 Create low stock notification (for household)
  /// An item is running low
  Future<void> createLowStockNotification({
    required String userId,
    required String householdId,
    required String productName,
    required int currentStock,
    required int minStock,
  }) async {
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
  }

  // ============================================================
  // QUERY NOTIFICATIONS
  // ============================================================

  /// 📋 Get user notifications (ordered by created_at desc)
  Future<List<AppNotification>> getUserNotifications({
    required String userId,
    int limit = 50,
  }) async {
    // 🆕 שימוש ב-subcollection - לא צריך where על user_id
    final snapshot = await _notificationsCollection(userId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => AppNotification.fromJson(doc.data()))
        .toList();
  }

  /// 📬 Get unread notifications
  Future<List<AppNotification>> getUnreadNotifications({
    required String userId,
  }) async {
    // 🆕 שימוש ב-subcollection - לא צריך where על user_id
    final snapshot = await _notificationsCollection(userId)
        .where('is_read', isEqualTo: false)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AppNotification.fromJson(doc.data()))
        .toList();
  }

  /// 🔢 Get unread count (for badge)
  Future<int> getUnreadCount({required String userId}) async {
    // 🆕 שימוש ב-subcollection - לא צריך where על user_id
    final snapshot = await _notificationsCollection(userId)
        .where('is_read', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  /// 📊 Stream unread count (real-time badge)
  Stream<int> watchUnreadCount({required String userId}) {
    // 🆕 שימוש ב-subcollection - לא צריך where על user_id
    return _notificationsCollection(userId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ============================================================
  // UPDATE NOTIFICATIONS
  // ============================================================

  /// ✅ Mark notification as read
  ///
  /// 🆕 נדרש userId כדי לגשת ל-subcollection הנכון
  Future<void> markAsRead({
    required String notificationId,
    required String userId,
  }) async {
    await _notificationsCollection(userId).doc(notificationId).update({
      'is_read': true,
      'read_at': FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Mark all as read (for user)
  Future<void> markAllAsRead({required String userId}) async {
    final batch = _firestore.batch();

    // 🆕 שימוש ב-subcollection - לא צריך where על user_id
    final snapshot = await _notificationsCollection(userId)
        .where('is_read', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'is_read': true,
        'read_at': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // ============================================================
  // DELETE NOTIFICATIONS
  // ============================================================

  /// 🗑️ Delete notification
  ///
  /// 🆕 נדרש userId כדי לגשת ל-subcollection הנכון
  Future<void> deleteNotification({
    required String notificationId,
    required String userId,
  }) async {
    await _notificationsCollection(userId).doc(notificationId).delete();
  }

  /// 🧹 Cleanup old read notifications (30 days)
  /// Call this periodically or on app startup
  Future<int> cleanupOldNotifications({
    required String userId,
    int daysOld = 30,
  }) async {
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
    return snapshot.docs.length; // Return count of deleted notifications
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// 📊 Get notification stats
  Future<Map<String, int>> getNotificationStats({required String userId}) async {
    // 🆕 שימוש ב-subcollection - לא צריך where על user_id
    final allSnapshot = await _notificationsCollection(userId).get();

    final unreadSnapshot = await _notificationsCollection(userId)
        .where('is_read', isEqualTo: false)
        .get();

    return {
      'total': allSnapshot.docs.length,
      'unread': unreadSnapshot.docs.length,
      'read': allSnapshot.docs.length - unreadSnapshot.docs.length,
    };
  }
}
