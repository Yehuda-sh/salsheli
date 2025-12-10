// 📄 File: lib/repositories/firebase_shopping_lists_repository.dart
//
// 🇮🇱 Repository לרשימות קניות עם Firestore:
//     - שמירת רשימות ב-Firestore
//     - טעינת רשימות לפי householdId
//     - עדכון רשימות
//     - מחיקת רשימות
//     - Real-time updates
//
// 🇬🇧 Shopping Lists repository with Firestore:
//     - Save shopping lists to Firestore
//     - Load shopping lists by householdId
//     - Update shopping lists
//     - Delete shopping lists
//     - Real-time updates
//
// 📝 Version: 2.0 - Naming consistency (FirebaseShoppingListsRepository)
// 📅 Last Updated: 09/10/2025
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/repositories/constants/repository_constants.dart';
import 'package:memozap/repositories/shopping_lists_repository.dart';

class FirebaseShoppingListsRepository implements ShoppingListsRepository {
  final FirebaseFirestore _firestore;

  FirebaseShoppingListsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // === Fetch Shopping Lists ===

  @override
  Future<List<ShoppingList>> fetchLists(String householdId) async {
    try {
      debugPrint(
        '📥 FirebaseShoppingListsRepository.fetchLists: טוען רשימות ל-$householdId',
      );

      final snapshot = await _firestore
          .collection(FirestoreCollections.shoppingLists)
          .where(FirestoreFields.householdId, isEqualTo: householdId)
          .orderBy(FirestoreFields.updatedDate, descending: true)
          .get();

      final lists = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return ShoppingList.fromJson(data);
      }).toList();

      debugPrint(
        '✅ FirebaseShoppingListsRepository.fetchLists: נטענו ${lists.length} רשימות',
      );
      return lists;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.fetchLists: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to fetch shopping lists for $householdId',
        e,
      );
    }
  }

  // === Save Shopping List ===

  @override
  Future<ShoppingList> saveList(ShoppingList list, String householdId) async {
    try {
      debugPrint(
        '💾 FirebaseShoppingListsRepository.saveList: שומר רשימה ${list.id} (${list.name})',
      );

      // המרת המודל ל-JSON
      final data = list.toJson();

      // הוספת household_id
      data[FirestoreFields.householdId] = householdId;

      await _firestore
          .collection(FirestoreCollections.shoppingLists)
          .doc(list.id)
          .set(data, SetOptions(merge: true));

      debugPrint('✅ FirebaseShoppingListsRepository.saveList: רשימה נשמרה');
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

  // === Delete Shopping List ===

  @override
  Future<void> deleteList(String id, String householdId) async {
    try {
      debugPrint(
        '🗑️ FirebaseShoppingListsRepository.deleteList: מוחק רשימה $id',
      );

      // וידוא שהרשימה שייכת ל-household
      final doc = await _firestore.collection(FirestoreCollections.shoppingLists).doc(id).get();

      if (!doc.exists) {
        debugPrint('⚠️ רשימה לא קיימת');
        return;
      }

      final data = doc.data();
      if (data?[FirestoreFields.householdId] != householdId) {
        debugPrint('⚠️ רשימה לא שייכת ל-household זה');
        throw ShoppingListRepositoryException(
          'Shopping list does not belong to household',
          null,
        );
      }

      await _firestore.collection(FirestoreCollections.shoppingLists).doc(id).delete();

      debugPrint('✅ FirebaseShoppingListsRepository.deleteList: רשימה נמחקה');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.deleteList: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to delete shopping list $id',
        e,
      );
    }
  }

  // ===== 🆕 Sharing & Permissions Methods (Map Structure) =====
  //
  // שינוי מבנה: מ-Array ל-Map לשיפור Scalability
  // מבנה חדש:
  // "shared_users": {
  //   "user123": { "role": "admin", "shared_at": ..., "user_name": ... },
  //   "user456": { "role": "viewer", "shared_at": ..., "user_name": ... }
  // }
  //
  // יתרונות:
  // - O(1) lookup by userId
  // - No limit on number of users
  // - Simple Security Rules (uid in sharedUsers)

  @override
  Future<void> addSharedUser(
    String listId,
    String userId,
    String role,
    String? userName,
    String? userEmail,
  ) async {
    try {
      debugPrint(
        '📝 FirebaseShoppingListsRepository.addSharedUser: מוסיף משתמש $userId לרשימה $listId כ-$role',
      );

      final docRef = _firestore.collection(FirestoreCollections.shoppingLists).doc(listId);

      // 🆕 Map structure: userId is the key
      // SharedUser data (without userId - it's the key)
      final sharedUserData = {
        FirestoreFields.role: role,
        'shared_at': FieldValue.serverTimestamp(),
        if (userName != null) FirestoreFields.userName: userName,
        if (userEmail != null) FirestoreFields.email: userEmail,
      };

      // 🆕 Update using dot notation: shared_users.{userId} = data
      await docRef.update({
        '${FirestoreFields.sharedUsers}.$userId': sharedUserData,
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ משתמש נוסף בהצלחה (Map structure)');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.addSharedUser: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to add shared user to list $listId',
        e,
      );
    }
  }

  @override
  Future<void> removeSharedUser(String listId, String userId) async {
    try {
      debugPrint(
        '🗑️ FirebaseShoppingListsRepository.removeSharedUser: מסיר משתמש $userId מרשימה $listId',
      );

      final docRef = _firestore.collection(FirestoreCollections.shoppingLists).doc(listId);

      // 🆕 Delete key from Map using FieldValue.delete()
      await docRef.update({
        '${FirestoreFields.sharedUsers}.$userId': FieldValue.delete(),
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ משתמש הוסר בהצלחה (Map structure)');
    } catch (e, stackTrace) {
      debugPrint(
        '❌ FirebaseShoppingListsRepository.removeSharedUser: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to remove shared user from list $listId',
        e,
      );
    }
  }

  @override
  Future<void> updateUserRole(
    String listId,
    String userId,
    String newRole,
  ) async {
    try {
      debugPrint(
        '🔄 FirebaseShoppingListsRepository.updateUserRole: משנה תפקיד $userId ברשימה $listId ל-$newRole',
      );

      final docRef = _firestore.collection(FirestoreCollections.shoppingLists).doc(listId);

      // 🆕 Direct update using dot notation: shared_users.{userId}.role = newRole
      await docRef.update({
        '${FirestoreFields.sharedUsers}.$userId.${FirestoreFields.role}': newRole,
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ תפקיד עודכן בהצלחה (Map structure)');
    } catch (e, stackTrace) {
      debugPrint(
        '❌ FirebaseShoppingListsRepository.updateUserRole: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to update user role in list $listId',
        e,
      );
    }
  }

  @override
  Future<void> transferOwnership(
    String listId,
    String currentOwnerId,
    String newOwnerId,
  ) async {
    try {
      debugPrint(
        '👑 FirebaseShoppingListsRepository.transferOwnership: מעביר בעלות מ-$currentOwnerId ל-$newOwnerId',
      );

      final docRef = _firestore.collection(FirestoreCollections.shoppingLists).doc(listId);

      // 🆕 Map structure:
      // 1. Remove new owner from shared_users (will become created_by)
      // 2. Add current owner as admin in shared_users
      // 3. Update created_by to new owner
      await docRef.update({
        // Remove new owner from shared_users
        '${FirestoreFields.sharedUsers}.$newOwnerId': FieldValue.delete(),
        // Add current owner as admin
        '${FirestoreFields.sharedUsers}.$currentOwnerId': {
          FirestoreFields.role: 'admin',
          'shared_at': FieldValue.serverTimestamp(),
        },
        // Change ownership
        FirestoreFields.createdBy: newOwnerId,
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ בעלות הועברה בהצלחה (Map structure)');
    } catch (e, stackTrace) {
      debugPrint(
        '❌ FirebaseShoppingListsRepository.transferOwnership: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to transfer ownership of list $listId',
        e,
      );
    }
  }

  // ===== 🆕 Pending Requests Methods =====

  @override
  Future<String> createRequest(
    String listId,
    String requesterId,
    String type,
    Map<String, dynamic> requestData,
    String? requesterName,
  ) async {
    try {
      debugPrint(
        '📝 FirebaseShoppingListsRepository.createRequest: יוצר בקשה מסוג $type לרשימה $listId',
      );

      final docRef = _firestore.collection(FirestoreCollections.shoppingLists).doc(listId);

      // יצירת request ID
      final requestId = '${DateTime.now().millisecondsSinceEpoch}_$requesterId';

      final request = {
        'id': requestId,
        'requester_id': requesterId,
        FirestoreFields.type: type,
        FirestoreFields.status: 'pending',
        'created_at': FieldValue.serverTimestamp(),
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
      debugPrint(
        '❌ FirebaseShoppingListsRepository.createRequest: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to create request for list $listId',
        e,
      );
    }
  }

  @override
  Future<void> approveRequest(
    String listId,
    String requestId,
    String reviewerId,
    String? reviewerName,
  ) async {
    try {
      debugPrint(
        '✅ FirebaseShoppingListsRepository.approveRequest: מאשר בקשה $requestId',
      );

      final docRef = _firestore.collection(FirestoreCollections.shoppingLists).doc(listId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw ShoppingListRepositoryException('List not found', null);
      }

      final data = doc.data()!;
      final pendingRequests = List<Map<String, dynamic>>.from(
        data[FirestoreFields.pendingRequests] ?? [],
      );

      // מציאת הבקשה
      final requestIndex = pendingRequests.indexWhere(
        (req) => req['id'] == requestId,
      );

      if (requestIndex == -1) {
        throw ShoppingListRepositoryException('Request not found', null);
      }

      // עדכון סטטוס הבקשה
      pendingRequests[requestIndex][FirestoreFields.status] = 'approved';
      pendingRequests[requestIndex]['reviewer_id'] = reviewerId;
      pendingRequests[requestIndex]['reviewed_at'] = FieldValue.serverTimestamp();
      if (reviewerName != null) {
        pendingRequests[requestIndex]['reviewer_name'] = reviewerName;
      }

      // TODO: כאן צריך לבצע את הפעולה עצמה (הוספה/עריכה/מחיקה)
      // זה יועבר ל-Provider לטיפול

      await docRef.update({
        FirestoreFields.pendingRequests: pendingRequests,
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ בקשה אושרה בהצלחה');
    } catch (e, stackTrace) {
      debugPrint(
        '❌ FirebaseShoppingListsRepository.approveRequest: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to approve request $requestId',
        e,
      );
    }
  }

  @override
  Future<void> rejectRequest(
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

      final docRef = _firestore.collection(FirestoreCollections.shoppingLists).doc(listId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw ShoppingListRepositoryException('List not found', null);
      }

      final data = doc.data()!;
      final pendingRequests = List<Map<String, dynamic>>.from(
        data[FirestoreFields.pendingRequests] ?? [],
      );

      // מציאת הבקשה
      final requestIndex = pendingRequests.indexWhere(
        (req) => req['id'] == requestId,
      );

      if (requestIndex == -1) {
        throw ShoppingListRepositoryException('Request not found', null);
      }

      // עדכון סטטוס הבקשה
      pendingRequests[requestIndex][FirestoreFields.status] = 'rejected';
      pendingRequests[requestIndex]['reviewer_id'] = reviewerId;
      pendingRequests[requestIndex]['reviewed_at'] = FieldValue.serverTimestamp();
      pendingRequests[requestIndex]['rejection_reason'] = reason;
      if (reviewerName != null) {
        pendingRequests[requestIndex]['reviewer_name'] = reviewerName;
      }

      await docRef.update({
        FirestoreFields.pendingRequests: pendingRequests,
        FirestoreFields.updatedDate: FieldValue.serverTimestamp(),
      });

      debugPrint('✅ בקשה נדחתה בהצלחה');
    } catch (e, stackTrace) {
      debugPrint(
        '❌ FirebaseShoppingListsRepository.rejectRequest: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to reject request $requestId',
        e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingRequests(String listId) async {
    try {
      debugPrint(
        '📝 FirebaseShoppingListsRepository.getPendingRequests: מביא בקשות ממתינות',
      );

      final doc = await _firestore.collection(FirestoreCollections.shoppingLists).doc(listId).get();

      if (!doc.exists) {
        throw ShoppingListRepositoryException('List not found', null);
      }

      final data = doc.data()!;
      final allRequests = List<Map<String, dynamic>>.from(
        data[FirestoreFields.pendingRequests] ?? [],
      );

      // סינון רק בקשות pending
      final pendingRequests = allRequests
          .where((req) => req[FirestoreFields.status] == 'pending')
          .toList();

      debugPrint('✅ נמצאו ${pendingRequests.length} בקשות ממתינות');
      return pendingRequests;
    } catch (e, stackTrace) {
      debugPrint(
        '❌ FirebaseShoppingListsRepository.getPendingRequests: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to get pending requests for list $listId',
        e,
      );
    }
  }

  // === 🆕 פונקציות נוספות ===

  /// מחזיר stream של רשימות (real-time updates)
  ///
  /// Example:
  /// ```dart
  /// repository.watchLists('house_demo').listen((lists) {
  ///   print('Lists updated: ${lists.length}');
  /// });
  /// ```
  Stream<List<ShoppingList>> watchLists(String householdId) {
    return _firestore
        .collection(FirestoreCollections.shoppingLists)
        .where(FirestoreFields.householdId, isEqualTo: householdId)
        .orderBy(FirestoreFields.updatedDate, descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            return ShoppingList.fromJson(data);
          }).toList();
        });
  }

  /// מחזיר רשימה לפי ID
  ///
  /// Example:
  /// ```dart
  /// final list = await repository.getListById('list_123', 'house_demo');
  /// ```
  Future<ShoppingList?> getListById(String listId, String householdId) async {
    try {
      debugPrint(
        '🔍 FirebaseShoppingListsRepository.getListById: מחפש רשימה $listId',
      );

      final doc = await _firestore
          .collection(FirestoreCollections.shoppingLists)
          .doc(listId)
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ רשימה לא נמצאה');
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data()!);

      // בדיקה שהרשימה שייכת ל-household
      if (data[FirestoreFields.householdId] != householdId) {
        debugPrint('⚠️ רשימה לא שייכת ל-household זה');
        return null;
      }

      final list = ShoppingList.fromJson(data);
      debugPrint('✅ רשימה נמצאה');

      return list;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.getListById: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to get shopping list by id',
        e,
      );
    }
  }

  /// מחזיר רשימות לפי סטטוס
  ///
  /// Example:
  /// ```dart
  /// final activeLists = await repository.getListsByStatus('active', 'house_demo');
  /// ```
  Future<List<ShoppingList>> getListsByStatus(
    String status,
    String householdId,
  ) async {
    try {
      debugPrint(
        '📋 FirebaseShoppingListsRepository.getListsByStatus: מחפש רשימות עם סטטוס $status',
      );

      final snapshot = await _firestore
          .collection(FirestoreCollections.shoppingLists)
          .where(FirestoreFields.householdId, isEqualTo: householdId)
          .where(FirestoreFields.status, isEqualTo: status)
          .orderBy(FirestoreFields.updatedDate, descending: true)
          .get();

      final lists = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return ShoppingList.fromJson(data);
      }).toList();

      debugPrint('✅ נמצאו ${lists.length} רשימות');
      return lists;
    } catch (e, stackTrace) {
      debugPrint(
        '❌ FirebaseShoppingListsRepository.getListsByStatus: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to get shopping lists by status',
        e,
      );
    }
  }

  /// מחזיר רשימות לפי סוג
  ///
  /// Example:
  /// ```dart
  /// final superLists = await repository.getListsByType('super', 'house_demo');
  /// ```
  Future<List<ShoppingList>> getListsByType(
    String type,
    String householdId,
  ) async {
    try {
      debugPrint(
        '🛒 FirebaseShoppingListsRepository.getListsByType: מחפש רשימות מסוג $type',
      );

      final snapshot = await _firestore
          .collection(FirestoreCollections.shoppingLists)
          .where(FirestoreFields.householdId, isEqualTo: householdId)
          .where(FirestoreFields.type, isEqualTo: type)
          .orderBy(FirestoreFields.updatedDate, descending: true)
          .get();

      final lists = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return ShoppingList.fromJson(data);
      }).toList();

      debugPrint('✅ נמצאו ${lists.length} רשימות');
      return lists;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseShoppingListsRepository.getListsByType: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ShoppingListRepositoryException(
        'Failed to get shopping lists by type',
        e,
      );
    }
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
