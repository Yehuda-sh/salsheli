// 📄 File: lib/services/pending_invites_service.dart
//
// 🎯 Purpose: שירות לניהול הזמנות ממתינות לרשימות/משפחה
//
// 📋 Features:
// - יצירת הזמנה ממתינה
// - אישור הזמנה (המוזמן מאשר)
// - דחיית הזמנה
// - שליפת הזמנות ממתינות למשתמש
//
// 🔗 Related:
// - share_list_service.dart - שירות שיתוף
// - notifications_service.dart - התראות
// - pending_request.dart - מודל בקשה ממתינה
//
// Version: 1.0
// Created: 30/11/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/request_status.dart';
import '../models/enums/request_type.dart';
import '../models/enums/user_role.dart';
import '../models/pending_request.dart';
import '../models/shared_user.dart';
import '../models/shopping_list.dart';

/// שירות לניהול הזמנות ממתינות
///
/// כאשר בעלים מזמין משתמש לרשימה, נוצרת הזמנה ממתינה.
/// המוזמן צריך לאשר או לדחות את ההזמנה.
class PendingInvitesService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  /// Collection name for pending invites
  static const String _collectionName = 'pending_invites';

  PendingInvitesService({FirebaseFirestore? firestore, Uuid? uuid})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  /// Reference to invites collection
  CollectionReference<Map<String, dynamic>> get _invitesRef =>
      _firestore.collection(_collectionName);

  // ============================================================
  // CREATE INVITE
  // ============================================================

  /// יצירת הזמנה ממתינה חדשה
  ///
  /// נקראת כאשר בעלים מזמין משתמש לרשימה.
  /// ההזמנה נשמרת וממתינה לאישור מצד המוזמן.
  Future<PendingRequest> createInvite({
    required String listId,
    required String listName,
    required String inviterId,
    required String inviterName,
    required String invitedUserId,
    required String invitedUserEmail,
    String? invitedUserName,
    required UserRole role,
    required String householdId,
  }) async {
    if (kDebugMode) {
      debugPrint('📨 PendingInvitesService.createInvite():');
      debugPrint('   List: $listName ($listId)');
      debugPrint('   Inviter: $inviterName ($inviterId)');
      debugPrint('   Invited: $invitedUserEmail ($invitedUserId)');
      debugPrint('   Role: ${role.hebrewName}');
    }

    // בדיקה אם כבר יש הזמנה ממתינה לאותו משתמש ורשימה
    final existingInvite = await _getExistingInvite(
      listId: listId,
      invitedUserId: invitedUserId,
    );

    if (existingInvite != null) {
      if (kDebugMode) {
        debugPrint('   ⚠️ Invite already exists');
      }
      throw Exception('invite_already_pending');
    }

    final invite = PendingRequest(
      id: _uuid.v4(),
      listId: listId,
      requesterId: inviterId, // המזמין הוא ה"מבקש"
      type: RequestType.inviteToList,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      requesterName: inviterName,
      requestData: {
        'invited_user_id': invitedUserId,
        'invited_user_email': invitedUserEmail,
        'invited_user_name': invitedUserName,
        'list_name': listName,
        'role': role.name,
        'household_id': householdId,
      },
    );

    await _invitesRef.doc(invite.id).set(invite.toJson());

    if (kDebugMode) {
      debugPrint('   ✅ Invite created: ${invite.id}');
    }

    return invite;
  }

  // ============================================================
  // GET INVITES
  // ============================================================

  /// שליפת הזמנות ממתינות למשתמש (הזמנות שהוא קיבל)
  Future<List<PendingRequest>> getPendingInvitesForUser(String userId) async {
    if (kDebugMode) {
      debugPrint('📋 PendingInvitesService.getPendingInvitesForUser():');
      debugPrint('   User: $userId');
    }

    final snapshot = await _invitesRef
        .where('request_data.invited_user_id', isEqualTo: userId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .orderBy('created_at', descending: true)
        .get();

    final invites = snapshot.docs
        .map((doc) => PendingRequest.fromJson(doc.data()))
        .toList();

    if (kDebugMode) {
      debugPrint('   Found ${invites.length} pending invites');
    }

    return invites;
  }

  /// Stream של הזמנות ממתינות (real-time)
  Stream<List<PendingRequest>> watchPendingInvitesForUser(String userId) {
    return _invitesRef
        .where('request_data.invited_user_id', isEqualTo: userId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PendingRequest.fromJson(doc.data()))
            .toList());
  }

  /// מספר הזמנות ממתינות (לbadge)
  Future<int> getPendingInvitesCount(String userId) async {
    final snapshot = await _invitesRef
        .where('request_data.invited_user_id', isEqualTo: userId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .get();

    return snapshot.docs.length;
  }

  /// Stream של מספר הזמנות ממתינות (real-time badge)
  Stream<int> watchPendingInvitesCount(String userId) {
    return _invitesRef
        .where('request_data.invited_user_id', isEqualTo: userId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ============================================================
  // ACCEPT / DECLINE
  // ============================================================

  /// אישור הזמנה - המוזמן מאשר להצטרף
  ///
  /// מחזיר את ה-SharedUser החדש שנוצר
  Future<SharedUser> acceptInvite({
    required String inviteId,
    required String acceptingUserId,
    String? acceptingUserName,
    String? acceptingUserAvatar,
  }) async {
    if (kDebugMode) {
      debugPrint('✅ PendingInvitesService.acceptInvite():');
      debugPrint('   Invite: $inviteId');
      debugPrint('   User: $acceptingUserId');
    }

    // קבלת ההזמנה
    final inviteDoc = await _invitesRef.doc(inviteId).get();
    if (!inviteDoc.exists) {
      throw Exception('invite_not_found');
    }

    final invite = PendingRequest.fromJson(inviteDoc.data()!);

    // בדיקות
    if (invite.status != RequestStatus.pending) {
      throw Exception('invite_already_processed');
    }

    final invitedUserId = invite.requestData['invited_user_id'] as String;
    if (invitedUserId != acceptingUserId) {
      throw Exception('not_authorized');
    }

    // עדכון ההזמנה לאושרה
    await _invitesRef.doc(inviteId).update({
      'status': RequestStatus.approved.name,
      'reviewer_id': acceptingUserId,
      'reviewer_name': acceptingUserName,
      'reviewed_at': FieldValue.serverTimestamp(),
    });

    // יצירת SharedUser להוספה לרשימה
    final role = UserRole.values.firstWhere(
      (r) => r.name == invite.requestData['role'],
      orElse: () => UserRole.editor,
    );

    final sharedUser = SharedUser(
      userId: acceptingUserId,
      role: role,
      sharedAt: DateTime.now(),
      userName: acceptingUserName ?? invite.requestData['invited_user_name'],
      userEmail: invite.requestData['invited_user_email'],
      userAvatar: acceptingUserAvatar,
    );

    // הוספת המשתמש לרשימה
    await _addUserToList(
      listId: invite.listId,
      sharedUser: sharedUser,
    );

    if (kDebugMode) {
      debugPrint('   ✅ Invite accepted, user added to list');
    }

    return sharedUser;
  }

  /// דחיית הזמנה
  Future<void> declineInvite({
    required String inviteId,
    required String decliningUserId,
    String? decliningUserName,
    String? reason,
  }) async {
    if (kDebugMode) {
      debugPrint('❌ PendingInvitesService.declineInvite():');
      debugPrint('   Invite: $inviteId');
      debugPrint('   User: $decliningUserId');
    }

    // קבלת ההזמנה
    final inviteDoc = await _invitesRef.doc(inviteId).get();
    if (!inviteDoc.exists) {
      throw Exception('invite_not_found');
    }

    final invite = PendingRequest.fromJson(inviteDoc.data()!);

    // בדיקות
    if (invite.status != RequestStatus.pending) {
      throw Exception('invite_already_processed');
    }

    final invitedUserId = invite.requestData['invited_user_id'] as String;
    if (invitedUserId != decliningUserId) {
      throw Exception('not_authorized');
    }

    // עדכון ההזמנה לנדחתה
    await _invitesRef.doc(inviteId).update({
      'status': RequestStatus.rejected.name,
      'reviewer_id': decliningUserId,
      'reviewer_name': decliningUserName,
      'reviewed_at': FieldValue.serverTimestamp(),
      if (reason != null) 'rejection_reason': reason,
    });

    if (kDebugMode) {
      debugPrint('   ❌ Invite declined');
    }
  }

  /// ביטול הזמנה (על ידי המזמין)
  Future<void> cancelInvite({
    required String inviteId,
    required String cancellingUserId,
  }) async {
    if (kDebugMode) {
      debugPrint('🗑️ PendingInvitesService.cancelInvite():');
      debugPrint('   Invite: $inviteId');
    }

    final inviteDoc = await _invitesRef.doc(inviteId).get();
    if (!inviteDoc.exists) {
      throw Exception('invite_not_found');
    }

    final invite = PendingRequest.fromJson(inviteDoc.data()!);

    // רק המזמין יכול לבטל
    if (invite.requesterId != cancellingUserId) {
      throw Exception('not_authorized');
    }

    await _invitesRef.doc(inviteId).delete();

    if (kDebugMode) {
      debugPrint('   🗑️ Invite cancelled');
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  /// בדיקה אם יש הזמנה ממתינה קיימת
  Future<PendingRequest?> _getExistingInvite({
    required String listId,
    required String invitedUserId,
  }) async {
    final snapshot = await _invitesRef
        .where('list_id', isEqualTo: listId)
        .where('request_data.invited_user_id', isEqualTo: invitedUserId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return PendingRequest.fromJson(snapshot.docs.first.data());
  }

  /// הוספת משתמש לרשימה לאחר אישור ההזמנה
  Future<void> _addUserToList({
    required String listId,
    required SharedUser sharedUser,
  }) async {
    final listRef = _firestore.collection('shopping_lists').doc(listId);

    await _firestore.runTransaction((transaction) async {
      final listDoc = await transaction.get(listRef);
      if (!listDoc.exists) {
        throw Exception('list_not_found');
      }

      final listData = listDoc.data()!;
      final list = ShoppingList.fromJson({...listData, 'id': listId});

      // בדיקה שהמשתמש לא כבר שותף
      if (list.sharedUsers.any((u) => u.userId == sharedUser.userId)) {
        throw Exception('user_already_shared');
      }

      // הוספת המשתמש
      final updatedSharedUsers = [...list.sharedUsers, sharedUser];

      transaction.update(listRef, {
        'shared_users': updatedSharedUsers.map((u) => u.toJson()).toList(),
        'is_shared': true,
        'updated_date': FieldValue.serverTimestamp(),
      });
    });
  }

  /// ניקוי הזמנות ישנות (מעל 30 יום)
  Future<int> cleanupOldInvites({int daysOld = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

    final snapshot = await _invitesRef
        .where('created_at', isLessThan: Timestamp.fromDate(cutoffDate))
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    return snapshot.docs.length;
  }
}
