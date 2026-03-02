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
// 📝 Version: 1.1
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
  final int? count;
  final String? errorMessage;

  const InviteResult._({
    required this.type,
    this.invite,
    this.sharedUser,
    this.invites,
    this.count,
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

  /// הצלחה עם ספירה
  factory InviteResult.successWithCount(int count) {
    return InviteResult._(
      type: InviteResultType.success,
      count: count,
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

  /// האם יש הזמנה
  bool get hasInvite => invite != null;

  /// האם יש משתמש
  bool get hasUser => sharedUser != null;

  /// האם יש רשימת הזמנות
  bool get hasInvites => invites != null;

  /// האם יש שגיאה
  bool get isError => type != InviteResultType.success;
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
    if (kDebugMode) {
      debugPrint('📨 PendingInvitesService.createInviteResult():');
      debugPrint('   List: $listName ($listId)');
      debugPrint('   Inviter: $inviterName ($inviterId)');
      debugPrint('   Invited: $invitedUserEmail ($invitedUserId)');
      debugPrint('   Role: ${role.hebrewName}');
    }

    try {
      // ✅ Email validation
      if (!_isValidEmail(invitedUserEmail)) {
        if (kDebugMode) {
          debugPrint('   ❌ Invalid email format: $invitedUserEmail');
        }
        return InviteResult.validationError('Invalid email format: $invitedUserEmail');
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

      if (kDebugMode) {
        debugPrint('   ✅ Invite created: ${invite.id}');
      }

      return InviteResult.success(invite: invite);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('   ❌ Error creating invite: $e');
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
    if (kDebugMode) {
      debugPrint('📋 PendingInvitesService.getPendingInvitesForUserResult():');
      debugPrint('   User: $userId');
      debugPrint('   Email: $userEmail');
    }

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

      if (kDebugMode) {
        debugPrint('   ✅ Found ${invites.length} pending invites');
      }

      return InviteResult.successWithInvites(invites);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('   ❌ Error getting invites: $e');
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

  /// מספר הזמנות ממתינות (לbadge)
  ///
  /// ✅ מחזיר [InviteResult] עם סוג תוצאה ברור
  ///
  /// מחפש לפי UID ואימייל (למקרה שהוזמן לפני הרשמה).
  Future<InviteResult> getPendingInvitesCountResult(String userId, {String? userEmail}) async {
    if (kDebugMode) {
      debugPrint('🔢 PendingInvitesService.getPendingInvitesCountResult():');
      debugPrint('   User: $userId');
    }

    try {
      final uidSnapshot = await _invitesRef
          .where('request_data.invited_user_id', isEqualTo: userId)
          .where('status', isEqualTo: RequestStatus.pending.name)
          .get();

      int count = uidSnapshot.docs.length;

      // חיפוש גם לפי אימייל
      if (userEmail != null && userEmail.isNotEmpty) {
        final emailSnapshot = await _invitesRef
            .where('request_data.invited_user_id', isEqualTo: userEmail.toLowerCase())
            .where('status', isEqualTo: RequestStatus.pending.name)
            .get();

        // ספירת הזמנות ייחודיות (לא כפולות)
        final uidIds = uidSnapshot.docs.map((d) => d.id).toSet();
        for (final doc in emailSnapshot.docs) {
          if (!uidIds.contains(doc.id)) {
            count++;
          }
        }
      }

      if (kDebugMode) {
        debugPrint('   ✅ Count: $count');
      }

      return InviteResult.successWithCount(count);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('   ❌ Error getting count: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      return InviteResult.firestoreError(e.toString());
    }
  }

  /// Stream של מספר הזמנות ממתינות (real-time badge)
  ///
  /// 💡 הערה: Stream לא תומך בחיפוש לפי אימייל בנפרד.
  /// למימוש מלא עם אימייל, השתמש ב-getPendingInvitesCountResult עם Timer.
  ///
  /// Note: Streams לא מחזירים typed result - שגיאות מועברות דרך onError
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
  }) async {
    if (kDebugMode) {
      debugPrint('✅ PendingInvitesService.acceptInviteResult():');
      debugPrint('   Invite: $inviteId');
      debugPrint('   User: $acceptingUserId');
    }

    try {
      // קבלת ההזמנה
      final inviteDoc = await _invitesRef.doc(inviteId).get();
      if (!inviteDoc.exists) {
        if (kDebugMode) {
          debugPrint('   ❌ Invite not found');
        }
        return InviteResult.inviteNotFound();
      }

      final invite = PendingRequest.fromJson(inviteDoc.data()!);

      // בדיקות
      if (invite.status != RequestStatus.pending) {
        if (kDebugMode) {
          debugPrint('   ❌ Invite already processed');
        }
        return InviteResult.inviteAlreadyProcessed();
      }

      final invitedUserId = invite.requestData['invited_user_id'] as String;
      if (invitedUserId != acceptingUserId) {
        if (kDebugMode) {
          debugPrint('   ❌ Not authorized');
        }
        return InviteResult.notAuthorized();
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
      final addResult = await _addUserToListResult(
        listId: invite.listId,
        sharedUser: sharedUser,
      );

      if (!addResult.isSuccess) {
        return addResult;
      }

      if (kDebugMode) {
        debugPrint('   ✅ Invite accepted, user added to list');
      }

      return InviteResult.successWithUser(sharedUser);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('   ❌ Error accepting invite: $e');
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
    if (kDebugMode) {
      debugPrint('❌ PendingInvitesService.declineInviteResult():');
      debugPrint('   Invite: $inviteId');
      debugPrint('   User: $decliningUserId');
    }

    try {
      // קבלת ההזמנה
      final inviteDoc = await _invitesRef.doc(inviteId).get();
      if (!inviteDoc.exists) {
        if (kDebugMode) {
          debugPrint('   ❌ Invite not found');
        }
        return InviteResult.inviteNotFound();
      }

      final invite = PendingRequest.fromJson(inviteDoc.data()!);

      // בדיקות
      if (invite.status != RequestStatus.pending) {
        if (kDebugMode) {
          debugPrint('   ❌ Invite already processed');
        }
        return InviteResult.inviteAlreadyProcessed();
      }

      final invitedUserId = invite.requestData['invited_user_id'] as String;
      if (invitedUserId != decliningUserId) {
        if (kDebugMode) {
          debugPrint('   ❌ Not authorized');
        }
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

      if (kDebugMode) {
        debugPrint('   ✅ Invite declined');
      }

      return InviteResult.success();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('   ❌ Error declining invite: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      return InviteResult.firestoreError(e.toString());
    }
  }

  /// ביטול הזמנה (על ידי המזמין)
  ///
  /// ✅ מחזיר [InviteResult] עם סוג תוצאה ברור
  Future<InviteResult> cancelInviteResult({
    required String inviteId,
    required String cancellingUserId,
  }) async {
    if (kDebugMode) {
      debugPrint('🗑️ PendingInvitesService.cancelInviteResult():');
      debugPrint('   Invite: $inviteId');
    }

    try {
      final inviteDoc = await _invitesRef.doc(inviteId).get();
      if (!inviteDoc.exists) {
        if (kDebugMode) {
          debugPrint('   ❌ Invite not found');
        }
        return InviteResult.inviteNotFound();
      }

      final invite = PendingRequest.fromJson(inviteDoc.data()!);

      // רק המזמין יכול לבטל
      if (invite.requesterId != cancellingUserId) {
        if (kDebugMode) {
          debugPrint('   ❌ Not authorized');
        }
        return InviteResult.notAuthorized();
      }

      await _invitesRef.doc(inviteId).delete();

      if (kDebugMode) {
        debugPrint('   ✅ Invite cancelled');
      }

      return InviteResult.success();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('   ❌ Error cancelling invite: $e');
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

  /// ניקוי הזמנות ישנות (מעל 30 יום)
  ///
  /// ✅ מחזיר [InviteResult] עם סוג תוצאה ברור
  Future<InviteResult> cleanupOldInvitesResult({int daysOld = 30}) async {
    if (kDebugMode) {
      debugPrint('🧹 PendingInvitesService.cleanupOldInvitesResult():');
      debugPrint('   Days old: $daysOld');
    }

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      final snapshot = await _invitesRef
          .where('created_at', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        debugPrint('   ✅ Cleaned up ${snapshot.docs.length} old invites');
      }

      return InviteResult.successWithCount(snapshot.docs.length);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('   ❌ Error cleaning up: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      return InviteResult.firestoreError(e.toString());
    }
  }

  // ============================================================
  // 🔙 Legacy API (Deprecated)
  // ============================================================

  /// @deprecated השתמש ב-createInviteResult() במקום
  @Deprecated('Use createInviteResult() instead')
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
    String? householdName,
  }) async {
    final result = await createInviteResult(
      listId: listId,
      listName: listName,
      inviterId: inviterId,
      inviterName: inviterName,
      invitedUserId: invitedUserId,
      invitedUserEmail: invitedUserEmail,
      invitedUserName: invitedUserName,
      role: role,
      householdId: householdId,
      householdName: householdName,
    );
    if (!result.isSuccess) {
      throw Exception(result.type.name);
    }
    return result.invite!;
  }

  /// @deprecated השתמש ב-getPendingInvitesForUserResult() במקום
  @Deprecated('Use getPendingInvitesForUserResult() instead')
  Future<List<PendingRequest>> getPendingInvitesForUser(
    String userId, {
    String? userEmail,
  }) async {
    final result = await getPendingInvitesForUserResult(userId, userEmail: userEmail);
    return result.invites ?? [];
  }

  /// @deprecated השתמש ב-getPendingInvitesCountResult() במקום
  @Deprecated('Use getPendingInvitesCountResult() instead')
  Future<int> getPendingInvitesCount(String userId, {String? userEmail}) async {
    final result = await getPendingInvitesCountResult(userId, userEmail: userEmail);
    return result.count ?? 0;
  }

  /// @deprecated השתמש ב-acceptInviteResult() במקום
  @Deprecated('Use acceptInviteResult() instead')
  Future<SharedUser> acceptInvite({
    required String inviteId,
    required String acceptingUserId,
    String? acceptingUserName,
    String? acceptingUserAvatar,
  }) async {
    final result = await acceptInviteResult(
      inviteId: inviteId,
      acceptingUserId: acceptingUserId,
      acceptingUserName: acceptingUserName,
      acceptingUserAvatar: acceptingUserAvatar,
    );
    if (!result.isSuccess) {
      throw Exception(result.type.name);
    }
    return result.sharedUser!;
  }

  /// @deprecated השתמש ב-declineInviteResult() במקום
  @Deprecated('Use declineInviteResult() instead')
  Future<void> declineInvite({
    required String inviteId,
    required String decliningUserId,
    String? decliningUserName,
    String? reason,
  }) async {
    final result = await declineInviteResult(
      inviteId: inviteId,
      decliningUserId: decliningUserId,
      decliningUserName: decliningUserName,
      reason: reason,
    );
    if (!result.isSuccess) {
      throw Exception(result.type.name);
    }
  }

  /// @deprecated השתמש ב-cancelInviteResult() במקום
  @Deprecated('Use cancelInviteResult() instead')
  Future<void> cancelInvite({
    required String inviteId,
    required String cancellingUserId,
  }) async {
    final result = await cancelInviteResult(
      inviteId: inviteId,
      cancellingUserId: cancellingUserId,
    );
    if (!result.isSuccess) {
      throw Exception(result.type.name);
    }
  }

  /// @deprecated השתמש ב-cleanupOldInvitesResult() במקום
  @Deprecated('Use cleanupOldInvitesResult() instead')
  Future<int> cleanupOldInvites({int daysOld = 30}) async {
    final result = await cleanupOldInvitesResult(daysOld: daysOld);
    return result.count ?? 0;
  }
}
