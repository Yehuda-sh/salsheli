// 📄 File: lib/repositories/firebase_shopping_lists_repository.dart
//
// 🎯 Purpose: Repository לרשימות קניות עם Firestore
//
// 📋 Features:
//     - תמיכה ב-2 קולקציות: private_lists + shared_lists
//     - טעינה ממוזגת של רשימות פרטיות ומשותפות
//     - שמירה לפי isPrivate (פרטי/משותף)
//     - העברת רשימה מפרטית למשותפת (atomic batch)
//     - Sharing & Permissions (roles, ownership transfer)
//     - Pending Requests (approve/reject with transactions)
//     - Real-time updates (merged streams via RxDart)
//     - שימוש ב-FirestoreUtils להמרה בטוחה ורקורסיבית
//     - ריכוז לוגיקת מיפוי (DRY) עם _mapSnapshotToShoppingLists
//     - שיפור בטיחות ב-Atomic Operations
//
// 🏗️ Database Structure:
//     - /users/{userId}/private_lists/{listId} - רשימות פרטיות
//     - /households/{householdId}/shared_lists/{listId} - רשימות משותפות
//
// 📦 Dependencies:
//     - cloud_firestore
//     - rxdart (for merged streams)
//     - ShoppingList model
//     - FirestoreUtils להמרת Timestamps רקורסיבית
//
// Version: 4.0
// Last Updated: 22/02/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/repositories/constants/repository_constants.dart';
import 'package:memozap/repositories/shopping_lists_repository.dart';
import 'package:memozap/repositories/utils/firestore_utils.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseShoppingListsRepository implements ShoppingListsRepository {
  final FirebaseFirestore _firestore;

  FirebaseShoppingListsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ========================================
  // Collection References
  // ========================================

  /// רשימות פרטיות: /users/{userId}/private_lists
  CollectionReference<Map<String, dynamic>> _privateListsCollection(String userId) =>
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.privateLists);

  /// רשימות משותפות: /households/{householdId}/shared_lists
  CollectionReference<Map<String, dynamic>> _sharedListsCollection(String householdId) =>
      _firestore
          .collection(FirestoreCollections.households)
          .doc(householdId)
          .collection(FirestoreCollections.sharedLists);

  // ========================================
  // Fetch Lists (Merged)
  // ========================================

  @override
  Future<List<ShoppingList>> fetchLists(String userId, String? householdId) async {
    try {
      debugPrint(
        '📥 FirebaseShoppingListsRepository.fetchLists: טוען רשימות (user: $userId, household: $householdId)',
      );

      // טען רשימות פרטיות + משותפות במקביל
      final privateFuture = _fetchPrivateLists(userId);
      final sharedFuture = householdId != null
          ? _fetchSharedLists(householdId)
          : Future.value(<ShoppingList>[]);

      final results = await Future.wait([privateFuture, sharedFuture]);
      final privateLists = results[0];
      final sharedLists = results[1];

      // מיזוג הרשימות
      final allLists = [...privateLists, ...sharedLists];

      // מיון לפי תאריך עדכון (חדש ביותר ראשון)
      allLists.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));

      debugPrint(
        '✅ FirebaseShoppingListsRepository.fetchLists: נטענו ${allLists.length} רשימות '
        '(${privateLists.length} פרטיות, ${sharedLists.length} משותפות)',
      );
      return allLists;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.fetchLists: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to fetch shopping lists',
        e,
      );
    }
  }

  /// טוען רשימות פרטיות בלבד
  Future<List<ShoppingList>> _fetchPrivateLists(String userId) async {
    final snapshot = await _privateListsCollection(userId)
        .orderBy(FirestoreFields.updatedDate, descending: true)
        .get();

    return _mapSnapshotToShoppingLists(snapshot, isPrivate: true);
  }

  /// טוען רשימות משותפות בלבד
  Future<List<ShoppingList>> _fetchSharedLists(String householdId) async {
    final snapshot = await _sharedListsCollection(householdId)
        .orderBy(FirestoreFields.updatedDate, descending: true)
        .get();

    return _mapSnapshotToShoppingLists(snapshot, isPrivate: false);
  }

  // ========================================
  // Save List (Route by isPrivate)
  // ========================================

  @override
  Future<ShoppingList> saveList(ShoppingList list, String userId, String? householdId) async {
    try {
      debugPrint(
        '💾 FirebaseShoppingListsRepository.saveList: שומר רשימה ${list.id} (${list.name}) '
        '[isPrivate: ${list.isPrivate}]',
      );

      final data = list.toJson();

      if (list.isPrivate) {
        // שמירה לרשימות פרטיות
        await _privateListsCollection(userId)
            .doc(list.id)
            .set(data, SetOptions(merge: true));
        debugPrint('✅ רשימה נשמרה ב-private_lists');
      } else {
        // שמירה לרשימות משותפות
        if (householdId == null) {
          throw ShoppingListRepositoryException(
            'Cannot save shared list without householdId',
            null,
          );
        }
        await _sharedListsCollection(householdId)
            .doc(list.id)
            .set(data, SetOptions(merge: true));
        debugPrint('✅ רשימה נשמרה ב-shared_lists');
      }

      return list;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.saveList: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to save shopping list ${list.id}',
        e,
      );
    }
  }

  // ========================================
  // Delete List
  // ========================================

  @override
  Future<void> deleteList(String id, String userId, String? householdId, bool isPrivate) async {
    try {
      debugPrint(
        '🗑️ FirebaseShoppingListsRepository.deleteList: מוחק רשימה $id [isPrivate: $isPrivate]',
      );

      if (isPrivate) {
        // מחיקה מרשימות פרטיות
        await _privateListsCollection(userId).doc(id).delete();
        debugPrint('✅ רשימה נמחקה מ-private_lists');
      } else {
        // מחיקה מרשימות משותפות
        if (householdId == null) {
          throw ShoppingListRepositoryException(
            'Cannot delete shared list without householdId',
            null,
          );
        }
        await _sharedListsCollection(householdId).doc(id).delete();
        debugPrint('✅ רשימה נמחקה מ-shared_lists');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.deleteList: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to delete shopping list $id',
        e,
      );
    }
  }

  // ========================================
  // Share List to Household
  // ========================================

  @override
  Future<ShoppingList> shareListToHousehold(
    String listId,
    String userId,
    String householdId,
  ) async {
    try {
      debugPrint(
        '🔄 FirebaseShoppingListsRepository.shareListToHousehold: '
        'מעביר רשימה $listId מפרטית למשותפת',
      );

      // 1. טען את הרשימה מ-private_lists
      final privateDoc = await _privateListsCollection(userId).doc(listId).get();

      if (!privateDoc.exists) {
        throw ShoppingListRepositoryException(
          'Private list $listId not found',
          null,
        );
      }

      final data = privateDoc.toDartMap()!;

      // 2. עדכן את הדגלים
      data[FirestoreFields.isPrivate] = false;
      // 🔧 שימוש ב-Timestamp לעקביות עם שאר המסמכים (לא String!)
      data[FirestoreFields.updatedDate] = Timestamp.now();

      // 3. 🔧 WriteBatch - אטומי! שתי הפעולות יצליחו או ייכשלו יחד
      final batch = _firestore.batch();

      // שמור ב-shared_lists
      batch.set(_sharedListsCollection(householdId).doc(listId), data);

      // מחק מ-private_lists
      batch.delete(_privateListsCollection(userId).doc(listId));

      // ביצוע אטומי
      await batch.commit();

      debugPrint('✅ רשימה הועברה בהצלחה מפרטית למשותפת (atomic batch)');

      // 🔧 קרא מחדש את המסמך כדי לקבל את הנתונים הסופיים
      final savedDoc = await _sharedListsCollection(householdId).doc(listId).get();
      if (!savedDoc.exists) {
        throw ShoppingListRepositoryException('List not found after transfer', null);
      }
      final savedData = savedDoc.toDartMap()!;
      savedData['id'] ??= savedDoc.id;
      savedData[FirestoreFields.isPrivate] = false;
      return ShoppingList.fromJson(savedData);
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.shareListToHousehold: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to share list $listId to household',
        e,
      );
    }
  }

  // ========================================
  // Sharing & Permissions Methods
  // (Only for shared lists)
  // ========================================

  @override
  Future<void> addSharedUser(
    String householdId,
    String listId,
    String userId,
    String role,
    String? userName,
    String? userEmail,
  ) async {
    try {
      debugPrint(
        '📝 FirebaseShoppingListsRepository.addSharedUser: '
        'מוסיף משתמש $userId לרשימה $listId כ-$role',
      );

      final docRef = _sharedListsCollection(householdId).doc(listId);

      final sharedUserData = {
        FirestoreFields.role: role,
        'shared_at': FieldValue.serverTimestamp(),
        if (userName != null) FirestoreFields.userName: userName,
        if (userEmail != null) FirestoreFields.email: userEmail,
      };

      await docRef.update({
        '${FirestoreFields.sharedUsers}.$userId': sharedUserData,
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ משתמש נוסף בהצלחה');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.addSharedUser: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to add shared user to list $listId',
        e,
      );
    }
  }

  /// הוספת משתמש משותף לרשימה פרטית (לא household)
  ///
  /// משמש כאשר משתף רשימה עם אנשים ספציפיים מחוץ למשפחה.
  /// הרשימה נשארת ב-private_lists אבל יש לה shared_users.
  Future<void> addSharedUserToPrivateList({
    required String ownerId,
    required String listId,
    required String sharedUserId,
    required String role,
    String? userName,
    String? userEmail,
  }) async {
    try {
      debugPrint(
        '📝 FirebaseShoppingListsRepository.addSharedUserToPrivateList: '
        'מוסיף משתמש $sharedUserId לרשימה פרטית $listId כ-$role',
      );

      final docRef = _privateListsCollection(ownerId).doc(listId);

      final sharedUserData = {
        FirestoreFields.role: role,
        'shared_at': FieldValue.serverTimestamp(),
        if (userName != null) FirestoreFields.userName: userName,
        if (userEmail != null) FirestoreFields.email: userEmail,
      };

      await docRef.update({
        '${FirestoreFields.sharedUsers}.$sharedUserId': sharedUserData,
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ משתמש נוסף לרשימה פרטית בהצלחה');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.addSharedUserToPrivateList: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to add shared user to private list $listId',
        e,
      );
    }
  }

  @override
  Future<void> removeSharedUser(String householdId, String listId, String userId) async {
    try {
      debugPrint(
        '🗑️ FirebaseShoppingListsRepository.removeSharedUser: '
        'מסיר משתמש $userId מרשימה $listId',
      );

      final docRef = _sharedListsCollection(householdId).doc(listId);

      await docRef.update({
        '${FirestoreFields.sharedUsers}.$userId': FieldValue.delete(),
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ משתמש הוסר בהצלחה');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.removeSharedUser: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to remove shared user from list $listId',
        e,
      );
    }
  }

  @override
  Future<void> updateUserRole(
    String householdId,
    String listId,
    String userId,
    String newRole,
  ) async {
    try {
      debugPrint(
        '🔄 FirebaseShoppingListsRepository.updateUserRole: '
        'משנה תפקיד $userId ברשימה $listId ל-$newRole',
      );

      final docRef = _sharedListsCollection(householdId).doc(listId);

      await docRef.update({
        '${FirestoreFields.sharedUsers}.$userId.${FirestoreFields.role}': newRole,
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ תפקיד עודכן בהצלחה');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.updateUserRole: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to update user role in list $listId',
        e,
      );
    }
  }

  @override
  Future<void> transferOwnership(
    String householdId,
    String listId,
    String currentOwnerId,
    String newOwnerId,
  ) async {
    try {
      debugPrint(
        '👑 FirebaseShoppingListsRepository.transferOwnership: '
        'מעביר בעלות מ-$currentOwnerId ל-$newOwnerId',
      );

      final docRef = _sharedListsCollection(householdId).doc(listId);

      // 🔧 Transaction - מבטיח עקביות ומונע race conditions
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw ShoppingListRepositoryException('List not found', null);
        }

        // 🔧 לוגיקה נכונה:
        // - הבעלים החדש הופך ל-owner (לא נמחק!)
        // - הבעלים הישן הופך ל-admin
        // - ownerId מתעדכן לבעלים החדש (שדה מפורש לבעלות)
        transaction.update(docRef, {
          // הבעלים החדש הופך ל-owner
          '${FirestoreFields.sharedUsers}.$newOwnerId': {
            FirestoreFields.role: 'owner',
            'shared_at': Timestamp.now(),
          },
          // הבעלים הישן הופך ל-admin (נשאר ברשימה)
          '${FirestoreFields.sharedUsers}.$currentOwnerId': {
            FirestoreFields.role: 'admin',
            'shared_at': Timestamp.now(),
          },
          // 🔧 שדה מפורש לבעלות - מקור אמת ברור
          FirestoreFields.ownerId: newOwnerId,
          // createdBy נשאר כמו שהיה (מי יצר את הרשימה במקור)
          FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
        });
      });

      debugPrint('✅ בעלות הועברה בהצלחה (transaction)');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.transferOwnership: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to transfer ownership of list $listId',
        e,
      );
    }
  }

  // ========================================
  // Pending Requests Methods
  // (Only for shared lists)
  // ========================================

  @override
  Future<String> createRequest(
    String householdId,
    String listId,
    String requesterId,
    String type,
    Map<String, dynamic> requestData,
    String? requesterName,
  ) async {
    try {
      debugPrint(
        '📝 FirebaseShoppingListsRepository.createRequest: '
        'יוצר בקשה מסוג $type לרשימה $listId',
      );

      final docRef = _sharedListsCollection(householdId).doc(listId);

      final requestId = '${DateTime.now().millisecondsSinceEpoch}_$requesterId';

      // 🔧 שימוש ב-Timestamp.now() במקום FieldValue.serverTimestamp() בתוך array
      // FieldValue לא תמיד עובד טוב בתוך מערכים/אובייקטים מקוננים
      final request = {
        'id': requestId,
        'requester_id': requesterId,
        FirestoreFields.type: type,
        FirestoreFields.status: 'pending',
        'created_at': Timestamp.now(),
        'request_data': requestData,
        if (requesterName != null) 'requester_name': requesterName,
      };

      await docRef.update({
        FirestoreFields.pendingRequests: FieldValue.arrayUnion([request]),
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ בקשה נוצרה: $requestId');
      return requestId;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.createRequest: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to create request for list $listId',
        e,
      );
    }
  }

  @override
  Future<void> approveRequest(
    String householdId,
    String listId,
    String requestId,
    String reviewerId,
    String? reviewerName,
  ) async {
    try {
      debugPrint(
        '✅ FirebaseShoppingListsRepository.approveRequest: מאשר בקשה $requestId',
      );

      final docRef = _sharedListsCollection(householdId).doc(listId);

      // 🔧 Transaction - מונע race conditions כששני אנשים מאשרים/דוחים במקביל
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw ShoppingListRepositoryException('List not found', null);
        }

        final data = doc.data()!;
        final pendingRequests = List<Map<String, dynamic>>.from(
          data[FirestoreFields.pendingRequests] ?? [],
        );

        final requestIndex = pendingRequests.indexWhere(
          (req) => req['id'] == requestId,
        );

        if (requestIndex == -1) {
          throw ShoppingListRepositoryException('Request not found', null);
        }

        // בדוק שהבקשה עדיין pending (לא טופלה כבר)
        if (pendingRequests[requestIndex][FirestoreFields.status] != 'pending') {
          throw ShoppingListRepositoryException('Request already processed', null);
        }

        // 🔧 שימוש ב-Timestamp.now() לעקביות עם created_at
        pendingRequests[requestIndex][FirestoreFields.status] = 'approved';
        pendingRequests[requestIndex]['reviewer_id'] = reviewerId;
        pendingRequests[requestIndex]['reviewed_at'] = Timestamp.now();
        if (reviewerName != null) {
          pendingRequests[requestIndex]['reviewer_name'] = reviewerName;
        }

        transaction.update(docRef, {
          FirestoreFields.pendingRequests: pendingRequests,
          FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
        });
      });

      debugPrint('✅ בקשה אושרה בהצלחה (transaction)');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.approveRequest: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to approve request $requestId',
        e,
      );
    }
  }

  @override
  Future<void> rejectRequest(
    String householdId,
    String listId,
    String requestId,
    String reviewerId,
    String reason,
    String? reviewerName,
  ) async {
    try {
      debugPrint(
        '❌ FirebaseShoppingListsRepository.rejectRequest: דוחה בקשה $requestId',
      );

      final docRef = _sharedListsCollection(householdId).doc(listId);

      // 🔧 Transaction - מונע race conditions כששני אנשים מאשרים/דוחים במקביל
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw ShoppingListRepositoryException('List not found', null);
        }

        final data = doc.data()!;
        final pendingRequests = List<Map<String, dynamic>>.from(
          data[FirestoreFields.pendingRequests] ?? [],
        );

        final requestIndex = pendingRequests.indexWhere(
          (req) => req['id'] == requestId,
        );

        if (requestIndex == -1) {
          throw ShoppingListRepositoryException('Request not found', null);
        }

        // בדוק שהבקשה עדיין pending (לא טופלה כבר)
        if (pendingRequests[requestIndex][FirestoreFields.status] != 'pending') {
          throw ShoppingListRepositoryException('Request already processed', null);
        }

        // 🔧 שימוש ב-Timestamp.now() לעקביות עם created_at
        pendingRequests[requestIndex][FirestoreFields.status] = 'rejected';
        pendingRequests[requestIndex]['reviewer_id'] = reviewerId;
        pendingRequests[requestIndex]['reviewed_at'] = Timestamp.now();
        pendingRequests[requestIndex]['rejection_reason'] = reason;
        if (reviewerName != null) {
          pendingRequests[requestIndex]['reviewer_name'] = reviewerName;
        }

        transaction.update(docRef, {
          FirestoreFields.pendingRequests: pendingRequests,
          FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
        });
      });

      debugPrint('✅ בקשה נדחתה בהצלחה (transaction)');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.rejectRequest: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to reject request $requestId',
        e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingRequests(
    String householdId,
    String listId,
  ) async {
    try {
      debugPrint(
        '📝 FirebaseShoppingListsRepository.getPendingRequests: מביא בקשות ממתינות',
      );

      final doc = await _sharedListsCollection(householdId).doc(listId).get();

      if (!doc.exists) {
        throw ShoppingListRepositoryException('List not found', null);
      }

      final data = doc.data()!;
      final allRequests = List<Map<String, dynamic>>.from(
        data[FirestoreFields.pendingRequests] ?? [],
      );

      final pendingRequests = allRequests
          .where((req) => req[FirestoreFields.status] == 'pending')
          .toList();

      debugPrint('✅ נמצאו ${pendingRequests.length} בקשות ממתינות');
      return pendingRequests;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.getPendingRequests: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to get pending requests for list $listId',
        e,
      );
    }
  }

  // ========================================
  // Additional Helper Methods
  // ========================================

  /// מחזיר stream של רשימות (real-time updates) - ממוזג
  @override
  Stream<List<ShoppingList>> watchLists(String userId, String? householdId) {
    debugPrint(
      '🔄 FirebaseShoppingListsRepository.watchLists: מאזין לרשימות (user: $userId, household: $householdId)',
    );

    // Stream של רשימות פרטיות
    final privateStream = _privateListsCollection(userId)
        .orderBy(FirestoreFields.updatedDate, descending: true)
        .snapshots()
        .map((snapshot) => _mapSnapshotToShoppingLists(snapshot, isPrivate: true));

    // אם אין household, מחזיר רק רשימות פרטיות
    if (householdId == null) {
      return privateStream;
    }

    // Stream של רשימות משותפות
    final sharedStream = _sharedListsCollection(householdId)
        .orderBy(FirestoreFields.updatedDate, descending: true)
        .snapshots()
        .map((snapshot) => _mapSnapshotToShoppingLists(snapshot, isPrivate: false));

    // מיזוג שני ה-streams - בכל פעם שאחד משתנה, ממזגים את שניהם
    return Rx.combineLatest2<List<ShoppingList>, List<ShoppingList>, List<ShoppingList>>(
      privateStream,
      sharedStream,
      (privateLists, sharedLists) {
        // מיזוג הרשימות
        final allLists = [...privateLists, ...sharedLists];

        // מיון לפי תאריך עדכון (חדש ביותר ראשון)
        allLists.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));

        debugPrint(
          '📥 FirebaseShoppingListsRepository.watchLists: ${allLists.length} רשימות '
          '(${privateLists.length} פרטיות, ${sharedLists.length} משותפות)',
        );

        return allLists;
      },
    );
  }

  /// מחזיר רשימה לפי ID (חיפוש בשתי הקולקציות)
  @override
  Future<ShoppingList?> getListById(
    String listId,
    String userId,
    String? householdId,
  ) async {
    try {
      debugPrint(
        '🔍 FirebaseShoppingListsRepository.getListById: מחפש רשימה $listId',
      );

      // חפש קודם ברשימות פרטיות
      final privateDoc = await _privateListsCollection(userId).doc(listId).get();
      if (privateDoc.exists) {
        final data = privateDoc.toDartMap()!;
        data['id'] ??= privateDoc.id;
        data[FirestoreFields.isPrivate] = true;
        debugPrint('✅ רשימה נמצאה ב-private_lists');
        return ShoppingList.fromJson(data);
      }

      // חפש ברשימות משותפות
      if (householdId != null) {
        final sharedDoc = await _sharedListsCollection(householdId).doc(listId).get();
        if (sharedDoc.exists) {
          final data = sharedDoc.toDartMap()!;
          data['id'] ??= sharedDoc.id;
          data[FirestoreFields.isPrivate] = false;
          debugPrint('✅ רשימה נמצאה ב-shared_lists');
          return ShoppingList.fromJson(data);
        }
      }

      debugPrint('⚠️ רשימה לא נמצאה');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.getListById: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to get shopping list by id',
        e,
      );
    }
  }

  // ========================================
  // Private Helpers
  // ========================================

  /// ממיר snapshot של Firestore לרשימת ShoppingList
  ///
  /// דולג על מסמכים פגומים (log + null filter) כדי לא לקרוס
  /// משתמש ב-toDartMap() להמרת Timestamps רקורסיבית
  /// מזריק id ו-isPrivate לכל מסמך
  List<ShoppingList> _mapSnapshotToShoppingLists(
    QuerySnapshot<Map<String, dynamic>> snapshot, {
    required bool isPrivate,
  }) {
    return snapshot.docs.map((doc) {
      try {
        final data = doc.toDartMap()!;
        data['id'] ??= doc.id;
        data[FirestoreFields.isPrivate] = isPrivate;
        return ShoppingList.fromJson(data);
      } catch (e) {
        debugPrint('⚠️ ShoppingListsRepository: דולג על רשימה פגומה ${doc.id} - $e');
        return null;
      }
    }).whereType<ShoppingList>().toList();
  }
}

/// Exception class for shopping list repository errors
class ShoppingListRepositoryException implements Exception {
  final String message;
  final Object? cause;

  ShoppingListRepositoryException(this.message, this.cause);

  @override
  String toString() =>
      'ShoppingListRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
