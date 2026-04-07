// 📄 lib/services/household_service.dart
//
// 🏠 שירות ניהול משק בית — עוטף את כל הגישות הישירות ל-Firestore
// שמשמשות את household_members_screen ו-household_activity_feed.
//
// ✅ מרכז את לוגיקת ה-membership במקום אחד
// ✅ משתמש ב-FirestoreCollections constants
//
// 🔗 Related: household_members_screen.dart, household_activity_feed.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../l10n/app_strings.dart';
import '../models/activity_event.dart';
import '../repositories/constants/repository_constants.dart';
import 'activity_log_service.dart';

/// מידע על חבר בית
class HouseholdMember {
  final String userId;
  final String name;
  final String role;
  final DateTime? joinedAt;
  final String? email;

  const HouseholdMember({
    required this.userId,
    required this.name,
    required this.role,
    this.joinedAt,
    this.email,
  });
}

/// 🏠 שירות ניהול משק בית
class HouseholdService {
  final FirebaseFirestore _firestore;

  HouseholdService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// קריאת חברי הבית כולל זיהוי בעלים
  Future<List<HouseholdMember>> getMembers(String householdId) async {
    // קרא מסמך הבית לזיהוי הבעלים
    final householdDoc = await _firestore
        .collection(FirestoreCollections.households)
        .doc(householdId)
        .get();
    final createdBy = householdDoc.data()?[FirestoreFields.createdBy] as String?;

    // קרא חברים
    final snap = await _firestore
        .collection(FirestoreCollections.households)
        .doc(householdId)
        .collection(FirestoreCollections.members)
        .get();

    final members = snap.docs.map((doc) {
      final data = doc.data();
      final memberId = doc.id;
      final isCreator = memberId == createdBy;
      final rawRole = data[FirestoreFields.role] as String? ?? 'member';

      return HouseholdMember(
        userId: memberId,
        name: data[FirestoreFields.name] as String? ?? AppStrings.household.userFallback,
        role: isCreator ? 'owner' : rawRole,
        joinedAt: (data['joined_at'] as Timestamp?)?.toDate(),
        email: data[FirestoreFields.email] as String?,
      );
    }).toList();

    // מיון: owner → admin → member
    members.sort((a, b) {
      const order = {'owner': 0, 'admin': 1, 'member': 2};
      final cmp = (order[a.role] ?? 3).compareTo(order[b.role] ?? 3);
      if (cmp != 0) return cmp;
      return a.name.compareTo(b.name);
    });

    return members;
  }

  /// מפת שמות חברי הבית (userId → name)
  Future<Map<String, String>> getMemberNames(String householdId) async {
    final snap = await _firestore
        .collection(FirestoreCollections.households)
        .doc(householdId)
        .collection(FirestoreCollections.members)
        .get();

    return {
      for (final doc in snap.docs)
        doc.id: (doc.data()[FirestoreFields.name] as String?) ?? '',
    };
  }

  /// הסרת חבר + יצירת בית אישי חדש עבורו
  Future<void> removeMember({
    required String householdId,
    required String memberId,
    required String memberName,
  }) async {
    // מחק מהבית הנוכחי
    await _firestore
        .collection(FirestoreCollections.households)
        .doc(householdId)
        .collection(FirestoreCollections.members)
        .doc(memberId)
        .delete();

    // צור בית אישי חדש
    final personalId = 'house_$memberId';
    final batch = _firestore.batch();

    batch.set(
      _firestore.collection(FirestoreCollections.households).doc(personalId),
      {
        FirestoreFields.name: AppStrings.household.myHome,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
        FirestoreFields.createdBy: memberId,
      },
    );

    batch.set(
      _firestore
          .collection(FirestoreCollections.households)
          .doc(personalId)
          .collection(FirestoreCollections.members)
          .doc(memberId),
      {
        FirestoreFields.userId: memberId,
        FirestoreFields.name: memberName,
        FirestoreFields.role: 'admin',
        'joined_at': FieldValue.serverTimestamp(),
      },
    );

    batch.update(
      _firestore.collection(FirestoreCollections.users).doc(memberId),
      {FirestoreFields.householdId: personalId},
    );

    await batch.commit();
  }

  /// שינוי תפקיד חבר (admin ↔ member)
  Future<void> toggleRole({
    required String householdId,
    required String memberId,
    required String currentRole,
    String actorId = '',
    String actorName = '',
    String targetName = '',
  }) async {
    final newRole = currentRole == 'admin' ? 'member' : 'admin';
    await _firestore
        .collection(FirestoreCollections.households)
        .doc(householdId)
        .collection(FirestoreCollections.members)
        .doc(memberId)
        .update({FirestoreFields.role: newRole});

    // 📝 Activity log
    if (actorId.isNotEmpty) {
      unawaited(ActivityLogService().log(
        householdId: householdId,
        type: ActivityType.roleChanged,
        actorId: actorId,
        actorName: actorName,
        data: {
          'target_name': targetName,
          'new_role': newRole,
        },
      ));
    }
  }

  /// עזיבת בית — עובר לבית אישי
  Future<void> leaveHousehold({
    required String householdId,
    required String userId,
    required String userName,
  }) async {
    await removeMember(
      householdId: householdId,
      memberId: userId,
      memberName: userName,
    );

    // 📝 Activity log
    unawaited(ActivityLogService().log(
      householdId: householdId,
      type: ActivityType.memberLeft,
      actorId: userId,
      actorName: userName,
    ));
  }
}
