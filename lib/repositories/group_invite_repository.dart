// File: lib/repositories/group_invite_repository.dart
// Purpose: Repository לניהול הזמנות לקבוצות
//
// Database Structure:
// /group_invites/{inviteId}
//
// Version: 1.0
// Created: 16/12/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/group.dart';
import '../models/group_invite.dart';

/// Exception להזמנות
class GroupInviteException implements Exception {
  final String message;
  final dynamic originalError;

  GroupInviteException(this.message, [this.originalError]);

  @override
  String toString() => 'GroupInviteException: $message';
}

/// Repository להזמנות קבוצה
class GroupInviteRepository {
  final FirebaseFirestore _firestore;

  static const String _collectionName = 'group_invites';

  GroupInviteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  // ============================================================
  // CREATE
  // ============================================================

  /// יצירת הזמנה חדשה
  Future<GroupInvite> createInvite(GroupInvite invite) async {
    try {
      if (kDebugMode) {
        debugPrint('📨 GroupInviteRepository.createInvite:');
        debugPrint('   Group: ${invite.groupName}');
        debugPrint('   Phone: ${invite.invitedPhone}');
        debugPrint('   Email: ${invite.invitedEmail}');
      }

      // בדיקה שאין כבר הזמנה פעילה לאותו איש קשר באותה קבוצה
      final existing = await _findExistingInvite(
        groupId: invite.groupId,
        phone: invite.invitedPhone,
        email: invite.invitedEmail,
      );

      if (existing != null && existing.isPending) {
        if (kDebugMode) {
          debugPrint('   ⚠️ Invite already exists, returning existing');
        }
        return existing;
      }

      // שמירה ל-Firestore
      await _collection.doc(invite.id).set(invite.toJson());

      if (kDebugMode) {
        debugPrint('✅ Invite created: ${invite.id}');
      }

      return invite;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ GroupInviteRepository.createInvite failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupInviteException('Failed to create invite', e);
    }
  }

  /// חיפוש הזמנה קיימת
  Future<GroupInvite?> _findExistingInvite({
    required String groupId,
    String? phone,
    String? email,
  }) async {
    // נורמליזציה של הטלפון
    final normalizedPhone = phone?.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    final Query<Map<String, dynamic>> query =
        _collection.where('group_id', isEqualTo: groupId);

    if (normalizedPhone != null) {
      // חיפוש לפי טלפון
      final phoneQuery = await query
          .where('invited_phone', isEqualTo: phone)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        return GroupInvite.fromFirestore(phoneQuery.docs.first);
      }
    }

    if (email != null) {
      // חיפוש לפי אימייל
      final emailQuery = await query
          .where('invited_email', isEqualTo: email.toLowerCase())
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        return GroupInvite.fromFirestore(emailQuery.docs.first);
      }
    }

    return null;
  }

  // ============================================================
  // READ
  // ============================================================

  /// קבלת הזמנה לפי ID
  Future<GroupInvite?> getInvite(String inviteId) async {
    try {
      final doc = await _collection.doc(inviteId).get();
      if (!doc.exists) return null;
      return GroupInvite.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ GroupInviteRepository.getInvite failed: $e');
      }
      throw GroupInviteException('Failed to get invite', e);
    }
  }

  /// חיפוש הזמנות ממתינות לפי טלפון או אימייל
  /// זה מה שנקרא כשמשתמש נרשם/מתחבר
  Future<List<GroupInvite>> findPendingInvites({
    String? phone,
    String? email,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 GroupInviteRepository.findPendingInvites:');
        debugPrint('   Phone: $phone');
        debugPrint('   Email: $email');
      }

      final List<GroupInvite> invites = [];

      // חיפוש לפי טלפון
      if (phone != null && phone.isNotEmpty) {
        final normalizedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

        // ננסה כמה וריאציות של הטלפון
        final phoneVariations = _getPhoneVariations(normalizedPhone);

        for (final phoneVariant in phoneVariations) {
          final phoneQuery = await _collection
              .where('invited_phone', isEqualTo: phoneVariant)
              .where('status', isEqualTo: 'pending')
              .get();

          for (final doc in phoneQuery.docs) {
            final invite = GroupInvite.fromFirestore(doc);
            if (!invites.any((i) => i.id == invite.id)) {
              invites.add(invite);
            }
          }
        }
      }

      // חיפוש לפי אימייל
      if (email != null && email.isNotEmpty) {
        final emailQuery = await _collection
            .where('invited_email', isEqualTo: email.toLowerCase())
            .where('status', isEqualTo: 'pending')
            .get();

        for (final doc in emailQuery.docs) {
          final invite = GroupInvite.fromFirestore(doc);
          if (!invites.any((i) => i.id == invite.id)) {
            invites.add(invite);
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Found ${invites.length} pending invites');
      }

      return invites;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ GroupInviteRepository.findPendingInvites failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupInviteException('Failed to find pending invites', e);
    }
  }

  /// וריאציות של מספר טלפון (עם/בלי קידומת מדינה)
  List<String> _getPhoneVariations(String phone) {
    final variations = <String>[phone];

    // אם מתחיל ב-+972, הוסף גם 0
    if (phone.startsWith('+972')) {
      variations.add('0${phone.substring(4)}');
    }
    // אם מתחיל ב-972, הוסף גם 0 ו-+972
    else if (phone.startsWith('972')) {
      variations.add('0${phone.substring(3)}');
      variations.add('+$phone');
    }
    // אם מתחיל ב-0, הוסף גם +972
    else if (phone.startsWith('0')) {
      variations.add('+972${phone.substring(1)}');
      variations.add('972${phone.substring(1)}');
    }

    return variations;
  }

  /// קבלת כל ההזמנות שנשלחו לקבוצה
  Future<List<GroupInvite>> getGroupInvites(String groupId) async {
    try {
      final query = await _collection
          .where('group_id', isEqualTo: groupId)
          .orderBy('created_at', descending: true)
          .get();

      return query.docs.map(GroupInvite.fromFirestore).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ GroupInviteRepository.getGroupInvites failed: $e');
      }
      throw GroupInviteException('Failed to get group invites', e);
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// אישור הזמנה
  Future<void> acceptInvite(String inviteId, String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('✅ GroupInviteRepository.acceptInvite: $inviteId');
      }

      await _collection.doc(inviteId).update({
        'status': 'accepted',
        'responded_at': FieldValue.serverTimestamp(),
        'accepted_by_user_id': userId,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ GroupInviteRepository.acceptInvite failed: $e');
      }
      throw GroupInviteException('Failed to accept invite', e);
    }
  }

  /// דחיית הזמנה
  Future<void> rejectInvite(String inviteId) async {
    try {
      if (kDebugMode) {
        debugPrint('👎 GroupInviteRepository.rejectInvite: $inviteId');
      }

      await _collection.doc(inviteId).update({
        'status': 'rejected',
        'responded_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ GroupInviteRepository.rejectInvite failed: $e');
      }
      throw GroupInviteException('Failed to reject invite', e);
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// מחיקת הזמנה (ביטול)
  Future<void> deleteInvite(String inviteId) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ GroupInviteRepository.deleteInvite: $inviteId');
      }

      await _collection.doc(inviteId).delete();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ GroupInviteRepository.deleteInvite failed: $e');
      }
      throw GroupInviteException('Failed to delete invite', e);
    }
  }

  /// מחיקת הזמנות ממתינות לאיש קשר בקבוצה
  /// (למשל כשמסירים חבר מוזמן מהקבוצה)
  Future<void> deleteInvitesForContact({
    required String groupId,
    String? phone,
    String? email,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ GroupInviteRepository.deleteInvitesForContact:');
        debugPrint('   Group: $groupId');
        debugPrint('   Phone: $phone, Email: $email');
      }

      final batch = _firestore.batch();
      var count = 0;

      if (phone != null) {
        final phoneQuery = await _collection
            .where('group_id', isEqualTo: groupId)
            .where('invited_phone', isEqualTo: phone)
            .where('status', isEqualTo: 'pending')
            .get();

        for (final doc in phoneQuery.docs) {
          batch.delete(doc.reference);
          count++;
        }
      }

      if (email != null) {
        final emailQuery = await _collection
            .where('group_id', isEqualTo: groupId)
            .where('invited_email', isEqualTo: email.toLowerCase())
            .where('status', isEqualTo: 'pending')
            .get();

        for (final doc in emailQuery.docs) {
          batch.delete(doc.reference);
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        if (kDebugMode) {
          debugPrint('✅ Deleted $count invites');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ GroupInviteRepository.deleteInvitesForContact failed: $e');
      }
      throw GroupInviteException('Failed to delete invites for contact', e);
    }
  }

  // ============================================================
  // HELPER: Full accept flow
  // ============================================================

  /// אישור הזמנה + הוספה לקבוצה (flow מלא)
  /// מחזיר את הקבוצה המעודכנת
  Future<Group?> acceptInviteAndJoinGroup({
    required GroupInvite invite,
    required String userId,
    required String userName,
    required String userEmail,
    String? userAvatar,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🎉 GroupInviteRepository.acceptInviteAndJoinGroup:');
        debugPrint('   Invite: ${invite.id}');
        debugPrint('   User: $userName ($userId)');
        debugPrint('   Group: ${invite.groupName}');
      }

      final groupRef = _firestore.collection('groups').doc(invite.groupId);
      final userRef = _firestore.collection('users').doc(userId);
      final inviteRef = _collection.doc(invite.id);

      // יצירת חבר חדש
      final member = GroupMember.invited(
        userId: userId,
        name: userName,
        email: userEmail,
        avatarUrl: userAvatar,
        role: invite.role,
        invitedBy: invite.invitedBy,
      );

      // מזהה החבר המוזמן הישן (לפני שהצטרף)
      final invitedUserId =
          'invited_${invite.invitedEmail ?? invite.invitedPhone ?? invite.id}';

      // Step 1: עדכון ההזמנה ל-accepted (יש הרשאה לזה)
      await inviteRef.update({
        'status': 'accepted',
        'responded_at': FieldValue.serverTimestamp(),
        'accepted_by_user_id': userId,
      });

      if (kDebugMode) {
        debugPrint('   ✅ Invite marked as accepted');
      }

      // Step 2: עדכון ה-user להוסיף את הקבוצה (יש הרשאה לזה)
      await userRef.update({
        'group_ids': FieldValue.arrayUnion([invite.groupId]),
      });

      if (kDebugMode) {
        debugPrint('   ✅ User group_ids updated');
      }

      // Step 3: עדכון הקבוצה - הוספת החבר החדש והסרת המוזמן הישן
      // עכשיו יש למשתמש הרשאה כי הוא כבר ב-group_ids
      await groupRef.update({
        'members.$userId': member.toJson(),
        'members.$invitedUserId': FieldValue.delete(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('   ✅ Group members updated');
        debugPrint('✅ User joined group successfully');
      }

      // החזרת הקבוצה המעודכנת
      final updatedGroupDoc = await groupRef.get();
      if (!updatedGroupDoc.exists) {
        return null;
      }
      final data = updatedGroupDoc.data()!;
      return Group.fromJson({...data, 'id': updatedGroupDoc.id});
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            '❌ GroupInviteRepository.acceptInviteAndJoinGroup failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupInviteException('Failed to accept invite and join group', e);
    }
  }
}
