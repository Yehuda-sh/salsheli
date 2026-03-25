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
// ✅ תיקונים:
//    - InviteResult typed result במקום throw Exception
//    - try-catch בכל מתודה
//    - Email validation ב-createInvite
//
// 🔗 Related:
// - share_list_service.dart - שירות שיתוף
// - notifications_service.dart - התראות
// - pending_request.dart - מודל בקשה ממתינה
//
// 📝 Version: 1.2 — Security comment on email auth source
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

// ========================================
// 🆕 Typed Result for Invites
// ========================================

/// סוגי תוצאות מפעולות הזמנה
///
/// מאפשר ל-UI להבחין בין מצבים שונים:
/// ```dart
/// final result = await invitesService.createInviteResult(...);
/// switch (result.type) {
///   case InviteResultType.success:
///     // הצג הודעת הצלחה
///     break;
///   case InviteResultType.inviteAlreadyPending:
///     // הצג שכבר יש הזמנה ממתינה
///     break;
///   case InviteResultType.invalidEmail:
///     // הצג שגיאת אימייל
///     break;
/// }
/// ```
enum InviteResultType {
  /// הצלחה
  success,

  /// כבר יש הזמנה ממתינה לאותו משתמש ורשימה
  inviteAlreadyPending,

  /// ההזמנה לא נמצאה
  inviteNotFound,

  /// ההזמנה כבר טופלה (אושרה/נדחתה)
  inviteAlreadyProcessed,

  /// המשתמש לא מורשה לבצע את הפעולה
  notAuthorized,

  /// הרשימה לא נמצאה
  listNotFound,

  /// המשתמש כבר שותף ברשימה
  userAlreadyShared,

  /// שגיאת Firestore
  firestoreError,

  /// שגיאת וולידציה (אימייל לא תקין וכו')
  validationError,
}

/// תוצאת פעולת הזמנה - Type-Safe!
///
/// כוללת:
/// - [type] - סוג התוצאה (enum)
/// - [invite] - ההזמנה שנוצרה (אם יש)
/// - [sharedUser] - המשתמש שנוסף (לאחר אישור)
/// - [invites] - רשימת הזמנות (לשאילתות)
/// - [count] - מספר הזמנות (לספירה)
/// - [errorMessage] - הודעת שגיאה (לדיבוג)
class InviteResult {
  final InviteResultType type;
  final PendingRequest? invite;
  final SharedUser? sharedUser;
  final List<PendingRequest>? invites;
  final String? errorMessage;

  const InviteResult._({
    required this.type,
    this.invite,
    this.sharedUser,
    this.invites,
    this.errorMessage,
  });

  /// הצלחה עם הזמנה
  factory InviteResult.success({PendingRequest? invite}) {
    return InviteResult._(
      type: InviteResultType.success,
      invite: invite,
    );
  }

  /// הצלחה עם SharedUser (לאחר אישור)
  factory InviteResult.successWithUser(SharedUser sharedUser) {
    return InviteResult._(
      type: InviteResultType.success,
      sharedUser: sharedUser,
    );
  }

  /// הצלחה עם רשימת הזמנות
  factory InviteResult.successWithInvites(List<PendingRequest> invites) {
    return InviteResult._(
      type: InviteResultType.success,
      invites: invites,
    );
  }

  /// כבר יש הזמנה ממתינה
  factory InviteResult.inviteAlreadyPending() {
    return const InviteResult._(
      type: InviteResultType.inviteAlreadyPending,
      errorMessage: 'Invite already pending for this user and list',
    );
  }

  /// ההזמנה לא נמצאה
  factory InviteResult.inviteNotFound() {
    return const InviteResult._(
      type: InviteResultType.inviteNotFound,
      errorMessage: 'Invite not found',
    );
  }

  /// ההזמנה כבר טופלה
  factory InviteResult.inviteAlreadyProcessed() {
    return const InviteResult._(
      type: InviteResultType.inviteAlreadyProcessed,
      errorMessage: 'Invite already processed',
    );
  }

  /// לא מורשה
  factory InviteResult.notAuthorized() {
    return const InviteResult._(
      type: InviteResultType.notAuthorized,
      errorMessage: 'Not authorized to perform this action',
    );
  }

  /// רשימה לא נמצאה
  factory InviteResult.listNotFound() {
    return const InviteResult._(
      type: InviteResultType.listNotFound,
      errorMessage: 'Shopping list not found',
    );
  }

  /// משתמש כבר שותף
  factory InviteResult.userAlreadyShared() {
    return const InviteResult._(
      type: InviteResultType.userAlreadyShared,
      errorMessage: 'User is already shared on this list',
    );
  }

  /// שגיאת Firestore
  factory InviteResult.firestoreError(String message) {
    return InviteResult._(
      type: InviteResultType.firestoreError,
      errorMessage: message,
    );
  }

  /// שגיאת וולידציה
  factory InviteResult.validationError(String message) {
    return InviteResult._(
      type: InviteResultType.validationError,
      errorMessage: message,
    );
  }

  /// האם הצליח
  bool get isSuccess => type == InviteResultType.success;

  /// האם יש משתמש (לאחר אישור הזמנה)
  bool get hasUser => sharedUser != null;
}

// ========================================
// 🔧 Email Validation Helper
// ========================================

/// בדיקת תקינות אימייל בסיסית
bool _isValidEmail(String email) {
  if (email.isEmpty) return false;
  // Regex בסיסי לאימייל
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

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
  // 🆕 Typed Result API (Recommended)
  // ============================================================

  /// יצירת הזמנה ממתינה חדשה
  ///
  /// ✅ מחזיר [InviteResult] עם סוג תוצאה ברור
  ///
  /// נקראת כאשר בעלים מזמין משתמש לרשימה.
  /// ההזמנה נשמרת וממתינה לאישור מצד המוזמן.
  ///
  /// Example:
  /// ```dart
  /// final result = await invitesService.createInviteResult(...);
  /// if (result.isSuccess) {
  ///   // הצג הודעת הצלחה
  /// } else if (result.type == InviteResultType.inviteAlreadyPending) {
  ///   // הצג שכבר יש הזמנה ממתינה
  /// }
  /// ```
  Future<InviteResult> createInviteResult({
    required String listId,
    required String listName,
    required String inviterId,
    required String inviterName,
    required String invitedUserId,
    required String invitedUserEmail,
    String? invitedUserName,
    required UserRole role,
    required String householdId,
    String? householdName,
  }) async {

    try {
      // ✅ Email validation
      if (!_isValidEmail(invitedUserEmail)) {
        return InviteResult.validationError('Invalid email format: $invitedUserEmail');
      }

      // בדיקה אם כבר יש הזמנה ממתינה לאותו משתמש ורשימה
      final existingInvite = await _getExistingInvite(
        listId: listId,
        invitedUserId: invitedUserId,
      );

      if (existingInvite != null) {
        return InviteResult.inviteAlreadyPending();
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
          'invited_user_email': invitedUserEmail.toLowerCase(),
          'invited_user_name': invitedUserName,
          'list_name': listName,
          'role': role.name,
          'household_id': householdId,
          'household_name': householdName,
        },
      );

      await _invitesRef.doc(invite.id).set(invite.toJson());


      return InviteResult.success(invite: invite);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      return InviteResult.firestoreError(e.toString());
    }
  }

  // ============================================================
  // 🏠 CREATE HOUSEHOLD INVITE
  // ============================================================

  /// יצירת הזמנה לבית (household)
  ///
  /// בשונה מ-createInviteResult שמזמינה לרשימה ספציפית,
  /// זו מזמינה להצטרף לבית כולו.
  Future<InviteResult> createHouseholdInvite({
    required String inviterId,
    required String inviterName,
    required String invitedUserEmail,
    String? invitedUserId,
    String? invitedUserName,
    required String householdId,
    required String householdName,
  }) async {
    try {
      if (!_isValidEmail(invitedUserEmail)) {
        return InviteResult.validationError('Invalid email format');
      }

      // בדיקה אם כבר יש הזמנה ממתינה לאותו בית
      final existing = await _invitesRef
          .where('request_data.invited_user_email',
              isEqualTo: invitedUserEmail.toLowerCase())
          .where('request_data.household_id', isEqualTo: householdId)
          .where('status', isEqualTo: RequestStatus.pending.name)
          .where('type', isEqualTo: RequestType.inviteToHousehold.value)
          .get();

      if (existing.docs.isNotEmpty) {
        return InviteResult.inviteAlreadyPending();
      }

      // בדיקה אם המוזמן כבר חבר בבית
      if (invitedUserId != null) {
        final memberDoc = await _firestore
            .collection('households')
            .doc(householdId)
            .collection('members')
            .doc(invitedUserId)
            .get();
        if (memberDoc.exists) {
          return InviteResult.validationError('המשתמש כבר חבר בבית');
        }
      }

      final invite = PendingRequest(
        id: _uuid.v4(),
        listId: householdId, // reuse listId field for householdId
        requesterId: inviterId,
        type: RequestType.inviteToHousehold,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
        requesterName: inviterName,
        requestData: {
          'invited_user_id': invitedUserId ?? invitedUserEmail.toLowerCase(),
          'invited_user_email': invitedUserEmail.toLowerCase(),
          'invited_user_name': invitedUserName,
          'household_id': householdId,
          'household_name': householdName,
          'role': UserRole.editor.name,
        },
      );

      await _invitesRef.doc(invite.id).set(invite.toJson());

      return InviteResult.success(invite: invite);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      return InviteResult.firestoreError(e.toString());
    }
  }

  // ============================================================
  // GET INVITES
  // ============================================================

  /// שליפת הזמנות ממתינות למשתמש (הזמנות שהוא קיבל)
  ///
  /// ✅ מחזיר [InviteResult] עם סוג תוצאה ברור
  ///
  /// מחפש לפי UID ראשית, ואז גם לפי אימייל (למקרה שההזמנה נשלחה
  /// לפני שהמשתמש נרשם לאפליקציה).
  Future<InviteResult> getPendingInvitesForUserResult(
    String userId, {
    String? userEmail,
  }) async {

    try {
      // 🔍 חיפוש לפי UID
      final uidSnapshot = await _invitesRef
          .where('request_data.invited_user_id', isEqualTo: userId)
          .where('status', isEqualTo: RequestStatus.pending.name)
          .orderBy('created_at', descending: true)
          .get();

      final invites = uidSnapshot.docs
          .map((doc) => PendingRequest.fromJson(doc.data()))
          .toList();

      // 🔍 חיפוש גם לפי אימייל (למקרה שהוזמן לפני שנרשם)
      if (userEmail != null && userEmail.isNotEmpty) {
        final emailSnapshot = await _invitesRef
            .where('request_data.invited_user_id', isEqualTo: userEmail.toLowerCase())
            .where('status', isEqualTo: RequestStatus.pending.name)
            .orderBy('created_at', descending: true)
            .get();

        // הוספת הזמנות שנמצאו לפי אימייל (ללא כפילויות)
        for (final doc in emailSnapshot.docs) {
          final invite = PendingRequest.fromJson(doc.data());
          if (!invites.any((i) => i.id == invite.id)) {
            invites.add(invite);
          }
        }
      }


      return InviteResult.successWithInvites(invites);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      return InviteResult.firestoreError(e.toString());
    }
  }

  /// Stream של הזמנות ממתינות (real-time)
  ///
  /// 💡 הערה: Stream לא תומך בחיפוש לפי אימייל בנפרד.
  /// למימוש מלא עם אימייל, השתמש ב-getPendingInvitesForUserResult עם Timer.
  ///
  /// Note: Streams לא מחזירים typed result - שגיאות מועברות דרך onError
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

  // ============================================================
  // ACCEPT / DECLINE
  // ============================================================

  /// אישור הזמנה - המוזמן מאשר להצטרף
  ///
  /// ✅ מחזיר [InviteResult] עם סוג תוצאה ברור
  ///
  /// Example:
  /// ```dart
  /// final result = await invitesService.acceptInviteResult(...);
  /// if (result.isSuccess && result.hasUser) {
  ///   // הצג הודעת הצלחה
  /// } else if (result.type == InviteResultType.notAuthorized) {
  ///   // הצג שגיאת הרשאה
  /// }
  /// ```
  Future<InviteResult> acceptInviteResult({
    required String inviteId,
    required String acceptingUserId,
    String? acceptingUserName,
    String? acceptingUserAvatar,
    String? acceptingUserEmail,
  }) async {

    try {
      // קבלת ההזמנה
      final inviteDoc = await _invitesRef.doc(inviteId).get();
      if (!inviteDoc.exists) {
        return InviteResult.inviteNotFound();
      }

      final invite = PendingRequest.fromJson(inviteDoc.data()!);

      // בדיקות
      if (invite.status != RequestStatus.pending) {
        return InviteResult.inviteAlreadyProcessed();
      }

      // ✅ Auth check: invited_user_id may be UID or email (for email-based invites)
      // SECURITY: acceptingUserEmail comes from UserContext.userEmail which is sourced
      // from Firebase Auth (verified email), NOT from user input. This is safe.
      final invitedUserId = invite.requestData['invited_user_id'] as String;
      final isAuthorized = invitedUserId == acceptingUserId ||
          (acceptingUserEmail != null &&
              invitedUserId.toLowerCase() == acceptingUserEmail.toLowerCase());
      if (!isAuthorized) {
        return InviteResult.notAuthorized();
      }

      // עדכון ההזמנה לאושרה
      await _invitesRef.doc(inviteId).update({
        'status': RequestStatus.approved.name,
        'reviewer_id': acceptingUserId,
        'reviewer_name': acceptingUserName,
        'reviewed_at': FieldValue.serverTimestamp(),
      });

      // 🏠 הזמנה לבית — הצטרפות ל-household
      if (invite.type == RequestType.inviteToHousehold) {
        final householdId = invite.requestData['household_id'] as String;
        final result = await _addUserToHousehold(
          householdId: householdId,
          userId: acceptingUserId,
          userName: acceptingUserName,
          userEmail: invite.requestData['invited_user_email'] as String?,
        );
        return result;
      }

      // 📋 הזמנה לרשימה (legacy) — הוספה לרשימה ספציפית
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

      final addResult = await _addUserToListResult(
        listId: invite.listId,
        sharedUser: sharedUser,
      );

      if (!addResult.isSuccess) {
        return addResult;
      }

      return InviteResult.successWithUser(sharedUser);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      return InviteResult.firestoreError(e.toString());
    }
  }

  /// דחיית הזמנה
  ///
  /// ✅ מחזיר [InviteResult] עם סוג תוצאה ברור
  Future<InviteResult> declineInviteResult({
    required String inviteId,
    required String decliningUserId,
    String? decliningUserName,
    String? reason,
  }) async {

    try {
      // קבלת ההזמנה
      final inviteDoc = await _invitesRef.doc(inviteId).get();
      if (!inviteDoc.exists) {
        return InviteResult.inviteNotFound();
      }

      final invite = PendingRequest.fromJson(inviteDoc.data()!);

      // בדיקות
      if (invite.status != RequestStatus.pending) {
        return InviteResult.inviteAlreadyProcessed();
      }

      final invitedUserId = invite.requestData['invited_user_id'] as String;
      if (invitedUserId != decliningUserId) {
        return InviteResult.notAuthorized();
      }

      // עדכון ההזמנה לנדחתה
      await _invitesRef.doc(inviteId).update({
        'status': RequestStatus.rejected.name,
        'reviewer_id': decliningUserId,
        'reviewer_name': decliningUserName,
        'reviewed_at': FieldValue.serverTimestamp(),
        if (reason != null) 'rejection_reason': reason,
      });


      return InviteResult.success();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      return InviteResult.firestoreError(e.toString());
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

  /// 🏠 הוספת משתמש לבית (household) לאחר אישור הזמנה
  ///
  /// 1. מוסיף ל-households/{id}/members
  /// 2. מעדכן users/{uid}/household_id
  /// 3. מוחק בית ישן אם ריק
  Future<InviteResult> _addUserToHousehold({
    required String householdId,
    required String userId,
    String? userName,
    String? userEmail,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. הוספה ל-members של הבית החדש
      final memberRef = _firestore
          .collection('households')
          .doc(householdId)
          .collection('members')
          .doc(userId);

      batch.set(memberRef, {
        'user_id': userId,
        'role': UserRole.editor.name,
        'joined_at': FieldValue.serverTimestamp(),
        'display_name': userName,
        'email': userEmail,
      });

      // 2. קריאת הבית הנוכחי של המשתמש (לפני עדכון)
      final userDoc =
          await _firestore.collection('users').doc(userId).get();
      final oldHouseholdId = userDoc.data()?['household_id'] as String?;

      // 3. עדכון household_id של המשתמש
      batch.update(
        _firestore.collection('users').doc(userId),
        {'household_id': householdId},
      );

      // 4. הסרה מהבית הישן (אם שונה)
      if (oldHouseholdId != null && oldHouseholdId != householdId) {
        batch.delete(
          _firestore
              .collection('households')
              .doc(oldHouseholdId)
              .collection('members')
              .doc(userId),
        );
      }

      await batch.commit();

      // 5. בדיקה אם הבית הישן ריק → מחיקה
      if (oldHouseholdId != null && oldHouseholdId != householdId) {
        final oldMembers = await _firestore
            .collection('households')
            .doc(oldHouseholdId)
            .collection('members')
            .limit(1)
            .get();
        if (oldMembers.docs.isEmpty) {
          await _firestore
              .collection('households')
              .doc(oldHouseholdId)
              .delete();
        }
      }

      return InviteResult.success();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      return InviteResult.firestoreError(e.toString());
    }
  }

  /// הוספת משתמש לרשימה לאחר אישור ההזמנה
  ///
  /// ✅ מחזיר [InviteResult] עם סוג תוצאה ברור
  Future<InviteResult> _addUserToListResult({
    required String listId,
    required SharedUser sharedUser,
  }) async {
    try {
      final listRef = _firestore.collection('shopping_lists').doc(listId);

      await _firestore.runTransaction((transaction) async {
        final listDoc = await transaction.get(listRef);
        if (!listDoc.exists) {
          throw Exception('list_not_found');
        }

        final listData = listDoc.data()!;
        final list = ShoppingList.fromJson({...listData, 'id': listId});

        // בדיקה שהמשתמש לא כבר שותף
        if (list.sharedUsers.containsKey(sharedUser.userId)) {
          throw Exception('user_already_shared');
        }

        // הוספת המשתמש - Map format
        final updatedSharedUsers = {
          ...list.sharedUsers,
          sharedUser.userId: sharedUser,
        };

        transaction.update(listRef, {
          'shared_users': updatedSharedUsers.map((key, value) => MapEntry(key, value.toJson())),
          'is_shared': true,
          'updated_date': FieldValue.serverTimestamp(),
        });
      });

      return InviteResult.success();
    } catch (e) {
      if (e.toString().contains('list_not_found')) {
        return InviteResult.listNotFound();
      }
      if (e.toString().contains('user_already_shared')) {
        return InviteResult.userAlreadyShared();
      }
      return InviteResult.firestoreError(e.toString());
    }
  }

}
