// 📄 File: lib/features/household/services/household_service.dart
// 🎯 Purpose: שירות לניהול משפחה (Household)
//
// 📋 Features:
// - יצירת קוד הזמנה למשפחה
// - אימות קוד הזמנה
// - שליחת בקשת הצטרפות
// - אישור/דחיית בקשות
// - ניהול חברי משפחה
//
// 📝 Version: 1.0
// 📅 Created: 04/12/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../models/enums/user_role.dart';
import '../models/household_invite.dart';
import '../models/household_join_request.dart';
import '../models/household_member.dart';

/// 🏠 שירות לניהול משפחה
class HouseholdService {
  final FirebaseFirestore _firestore;

  // Collection names
  static const String _invitesCollection = 'household_invites';
  static const String _requestsCollection = 'household_join_requests';
  static const String _membersCollection = 'household_members';
  static const String _usersCollection = 'users';

  HouseholdService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // INVITE MANAGEMENT
  // ============================================================

  /// 🔑 יצירת קוד הזמנה חדש
  ///
  /// יוצר קוד הזמנה ייחודי (6 תווים) שמאפשר הצטרפות למשפחה.
  /// הקוד בתוקף ל-7 ימים.
  Future<HouseholdInvite> createInviteCode({
    required String householdId,
    required String createdBy,
    required String createdByName,
    int expirationDays = 7,
  }) async {
    if (kDebugMode) {
      debugPrint('🔑 HouseholdService.createInviteCode():');
      debugPrint('   Household: $householdId');
      debugPrint('   Created by: $createdByName');
    }

    // בטל קודים קודמים שעדיין פעילים (רק קוד אחד פעיל בכל רגע)
    await _deactivateExistingInvites(householdId);

    // צור קוד חדש
    final invite = HouseholdInvite.create(
      householdId: householdId,
      createdBy: createdBy,
      createdByName: createdByName,
      expirationDays: expirationDays,
    );

    await _firestore
        .collection(_invitesCollection)
        .doc(invite.id)
        .set(invite.toJson());

    if (kDebugMode) {
      debugPrint('   ✅ Invite code created: ${invite.code}');
      debugPrint('   Expires: ${invite.expiresAt}');
    }

    return invite;
  }

  /// 🔍 אימות קוד הזמנה
  ///
  /// בודק אם הקוד תקין ומחזיר את פרטי ההזמנה.
  /// מחזיר null אם הקוד לא קיים, פג תוקף, או כבר נוצל.
  Future<HouseholdInvite?> validateInviteCode(String code) async {
    if (kDebugMode) {
      debugPrint('🔍 HouseholdService.validateInviteCode():');
      debugPrint('   Code: $code');
    }

    final snapshot = await _firestore
        .collection(_invitesCollection)
        .where('code', isEqualTo: code.toUpperCase())
        .where('status', isEqualTo: InviteStatus.active.name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('   ❌ Code not found or not active');
      }
      return null;
    }

    final invite = HouseholdInvite.fromJson(snapshot.docs.first.data());

    // בדיקת תוקף
    if (!invite.isValid) {
      if (kDebugMode) {
        debugPrint('   ❌ Code expired');
      }
      // עדכן סטטוס לפג תוקף
      await _firestore
          .collection(_invitesCollection)
          .doc(invite.id)
          .update({'status': InviteStatus.expired.name});
      return null;
    }

    if (kDebugMode) {
      debugPrint('   ✅ Code valid');
      debugPrint('   Household: ${invite.householdId}');
      debugPrint('   Created by: ${invite.createdByName}');
    }

    return invite;
  }

  /// 📋 קבלת קוד הזמנה פעיל
  Future<HouseholdInvite?> getActiveInvite(String householdId) async {
    final snapshot = await _firestore
        .collection(_invitesCollection)
        .where('household_id', isEqualTo: householdId)
        .where('status', isEqualTo: InviteStatus.active.name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final invite = HouseholdInvite.fromJson(snapshot.docs.first.data());

    // בדיקת תוקף
    if (!invite.isValid) {
      await _firestore
          .collection(_invitesCollection)
          .doc(invite.id)
          .update({'status': InviteStatus.expired.name});
      return null;
    }

    return invite;
  }

  /// ❌ ביטול קוד הזמנה
  Future<void> cancelInviteCode(String inviteId) async {
    await _firestore
        .collection(_invitesCollection)
        .doc(inviteId)
        .update({'status': InviteStatus.cancelled.name});

    if (kDebugMode) {
      debugPrint('❌ Invite code cancelled: $inviteId');
    }
  }

  // ============================================================
  // JOIN REQUEST MANAGEMENT
  // ============================================================

  /// 📨 שליחת בקשת הצטרפות
  ///
  /// נקראת כאשר משתמש מזין קוד הזמנה תקין ומבקש להצטרף.
  Future<HouseholdJoinRequest> submitJoinRequest({
    required String inviteCode,
    required String householdId,
    required String requesterId,
    required String requesterName,
    required String requesterEmail,
    String? requesterAvatar,
  }) async {
    if (kDebugMode) {
      debugPrint('📨 HouseholdService.submitJoinRequest():');
      debugPrint('   Requester: $requesterName ($requesterEmail)');
      debugPrint('   Household: $householdId');
    }

    // בדיקה שאין כבר בקשה ממתינה
    final existingRequest = await _getExistingRequest(
      householdId: householdId,
      requesterId: requesterId,
    );

    if (existingRequest != null) {
      if (kDebugMode) {
        debugPrint('   ⚠️ Request already exists');
      }
      throw Exception('request_already_pending');
    }

    // בדיקה שהמשתמש לא כבר חבר
    final isAlreadyMember = await _isUserMemberOfHousehold(
      householdId: householdId,
      userId: requesterId,
    );

    if (isAlreadyMember) {
      if (kDebugMode) {
        debugPrint('   ⚠️ User already member of household');
      }
      throw Exception('already_member');
    }

    // יצירת הבקשה
    final request = HouseholdJoinRequest.create(
      inviteCode: inviteCode,
      householdId: householdId,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterEmail: requesterEmail,
      requesterAvatar: requesterAvatar,
    );

    await _firestore
        .collection(_requestsCollection)
        .doc(request.id)
        .set(request.toJson());

    if (kDebugMode) {
      debugPrint('   ✅ Join request submitted: ${request.id}');
    }

    return request;
  }

  /// 📋 קבלת בקשות ממתינות ל-household
  Future<List<HouseholdJoinRequest>> getPendingRequests(
      String householdId) async {
    final snapshot = await _firestore
        .collection(_requestsCollection)
        .where('household_id', isEqualTo: householdId)
        .where('status', isEqualTo: JoinRequestStatus.pending.name)
        .orderBy('requested_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HouseholdJoinRequest.fromJson(doc.data()))
        .toList();
  }

  /// 🔔 Stream של בקשות ממתינות (real-time)
  Stream<List<HouseholdJoinRequest>> watchPendingRequests(String householdId) {
    return _firestore
        .collection(_requestsCollection)
        .where('household_id', isEqualTo: householdId)
        .where('status', isEqualTo: JoinRequestStatus.pending.name)
        .orderBy('requested_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HouseholdJoinRequest.fromJson(doc.data()))
            .toList());
  }

  /// ✅ אישור בקשת הצטרפות
  Future<void> approveJoinRequest({
    required String requestId,
    required String reviewerId,
    required UserRole assignedRole,
    String? message,
  }) async {
    if (kDebugMode) {
      debugPrint('✅ HouseholdService.approveJoinRequest():');
      debugPrint('   Request: $requestId');
      debugPrint('   Role: ${assignedRole.name}');
    }

    // קבלת הבקשה
    final requestDoc = await _firestore
        .collection(_requestsCollection)
        .doc(requestId)
        .get();

    if (!requestDoc.exists) {
      throw Exception('request_not_found');
    }

    final request = HouseholdJoinRequest.fromJson(requestDoc.data()!);

    if (!request.isPending) {
      throw Exception('request_already_processed');
    }

    // Transaction: עדכון הבקשה + הוספת המשתמש להousehold
    await _firestore.runTransaction((transaction) async {
      // עדכון הבקשה
      transaction.update(
        _firestore.collection(_requestsCollection).doc(requestId),
        request.approve(
          reviewerId: reviewerId,
          role: assignedRole,
          message: message,
        ).toJson(),
      );

      // עדכון ה-householdId של המשתמש
      transaction.update(
        _firestore.collection(_usersCollection).doc(request.requesterId),
        {
          'household_id': request.householdId,
          'is_admin': false, // לא admin, מצטרף למשפחה קיימת
        },
      );

      // יצירת רשומת חבר משפחה
      final member = HouseholdMember.invited(
        userId: request.requesterId,
        name: request.requesterName,
        email: request.requesterEmail,
        avatarUrl: request.requesterAvatar,
        role: assignedRole,
        invitedBy: reviewerId,
      );

      transaction.set(
        _firestore
            .collection(_membersCollection)
            .doc('${request.householdId}_${request.requesterId}'),
        {
          ...member.toJson(),
          'household_id': request.householdId,
        },
      );
    });

    if (kDebugMode) {
      debugPrint('   ✅ Request approved, user added to household');
    }
  }

  /// ❌ דחיית בקשת הצטרפות
  Future<void> rejectJoinRequest({
    required String requestId,
    required String reviewerId,
    String? message,
  }) async {
    if (kDebugMode) {
      debugPrint('❌ HouseholdService.rejectJoinRequest():');
      debugPrint('   Request: $requestId');
    }

    final requestDoc = await _firestore
        .collection(_requestsCollection)
        .doc(requestId)
        .get();

    if (!requestDoc.exists) {
      throw Exception('request_not_found');
    }

    final request = HouseholdJoinRequest.fromJson(requestDoc.data()!);

    if (!request.isPending) {
      throw Exception('request_already_processed');
    }

    await _firestore.collection(_requestsCollection).doc(requestId).update(
          request
              .reject(
                reviewerId: reviewerId,
                message: message,
              )
              .toJson(),
        );

    if (kDebugMode) {
      debugPrint('   ❌ Request rejected');
    }
  }

  // ============================================================
  // MEMBER MANAGEMENT
  // ============================================================

  /// 👨‍👩‍👧‍👦 קבלת חברי משפחה
  Future<List<HouseholdMember>> getHouseholdMembers(String householdId) async {
    final snapshot = await _firestore
        .collection(_membersCollection)
        .where('household_id', isEqualTo: householdId)
        .orderBy('joined_at')
        .get();

    return snapshot.docs
        .map((doc) => HouseholdMember.fromJson(doc.data()))
        .toList();
  }

  /// 🔔 Stream של חברי משפחה (real-time)
  Stream<List<HouseholdMember>> watchHouseholdMembers(String householdId) {
    return _firestore
        .collection(_membersCollection)
        .where('household_id', isEqualTo: householdId)
        .orderBy('joined_at')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HouseholdMember.fromJson(doc.data()))
            .toList());
  }

  /// ✏️ עדכון תפקיד חבר משפחה
  Future<void> updateMemberRole({
    required String householdId,
    required String memberId,
    required UserRole newRole,
  }) async {
    if (kDebugMode) {
      debugPrint('✏️ HouseholdService.updateMemberRole():');
      debugPrint('   Member: $memberId');
      debugPrint('   New role: ${newRole.name}');
    }

    // לא ניתן להפוך מישהו ל-owner
    if (newRole == UserRole.owner) {
      throw Exception('cannot_assign_owner_role');
    }

    await _firestore
        .collection(_membersCollection)
        .doc('${householdId}_$memberId')
        .update({'role': newRole.name});

    if (kDebugMode) {
      debugPrint('   ✅ Role updated');
    }
  }

  /// 🗑️ הסרת חבר מהמשפחה
  Future<void> removeMember({
    required String householdId,
    required String memberId,
    required String removerId,
  }) async {
    if (kDebugMode) {
      debugPrint('🗑️ HouseholdService.removeMember():');
      debugPrint('   Member: $memberId');
      debugPrint('   Removed by: $removerId');
    }

    // בדיקה שהמסיר הוא owner
    final removerDoc = await _firestore
        .collection(_membersCollection)
        .doc('${householdId}_$removerId')
        .get();

    if (!removerDoc.exists) {
      throw Exception('remover_not_found');
    }

    final remover = HouseholdMember.fromJson(removerDoc.data()!);
    if (!remover.isOwner) {
      throw Exception('only_owner_can_remove');
    }

    // בדיקה שלא מנסים להסיר את ה-owner
    final memberDoc = await _firestore
        .collection(_membersCollection)
        .doc('${householdId}_$memberId')
        .get();

    if (!memberDoc.exists) {
      throw Exception('member_not_found');
    }

    final member = HouseholdMember.fromJson(memberDoc.data()!);
    if (member.isOwner) {
      throw Exception('cannot_remove_owner');
    }

    // הסרת החבר
    await _firestore
        .collection(_membersCollection)
        .doc('${householdId}_$memberId')
        .delete();

    // עדכון ה-householdId של המשתמש ל-household חדש משלו
    await _firestore.collection(_usersCollection).doc(memberId).update({
      'household_id': 'house_$memberId',
      'is_admin': true, // עכשיו הוא admin של עצמו
    });

    if (kDebugMode) {
      debugPrint('   ✅ Member removed');
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// ביטול קודים קודמים
  Future<void> _deactivateExistingInvites(String householdId) async {
    final snapshot = await _firestore
        .collection(_invitesCollection)
        .where('household_id', isEqualTo: householdId)
        .where('status', isEqualTo: InviteStatus.active.name)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'status': InviteStatus.cancelled.name});
    }
    await batch.commit();
  }

  /// בדיקה אם יש בקשה קיימת
  Future<HouseholdJoinRequest?> _getExistingRequest({
    required String householdId,
    required String requesterId,
  }) async {
    final snapshot = await _firestore
        .collection(_requestsCollection)
        .where('household_id', isEqualTo: householdId)
        .where('requester_id', isEqualTo: requesterId)
        .where('status', isEqualTo: JoinRequestStatus.pending.name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return HouseholdJoinRequest.fromJson(snapshot.docs.first.data());
  }

  /// בדיקה אם משתמש כבר חבר
  Future<bool> _isUserMemberOfHousehold({
    required String householdId,
    required String userId,
  }) async {
    final doc = await _firestore
        .collection(_membersCollection)
        .doc('${householdId}_$userId')
        .get();

    return doc.exists;
  }

  /// ניקוי קודים פגי תוקף
  Future<int> cleanupExpiredInvites() async {
    final now = DateTime.now();

    final snapshot = await _firestore
        .collection(_invitesCollection)
        .where('status', isEqualTo: InviteStatus.active.name)
        .where('expires_at', isLessThan: Timestamp.fromDate(now))
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'status': InviteStatus.expired.name});
    }
    await batch.commit();

    if (kDebugMode && snapshot.docs.isNotEmpty) {
      debugPrint('🧹 Cleaned up ${snapshot.docs.length} expired invites');
    }

    return snapshot.docs.length;
  }
}
