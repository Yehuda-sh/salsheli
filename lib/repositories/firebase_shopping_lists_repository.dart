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
import '../models/shopping_list.dart';
import 'shopping_lists_repository.dart';

class FirebaseShoppingListsRepository implements ShoppingListsRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'shopping_lists';

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
          .collection(_collectionName)
          .where('household_id', isEqualTo: householdId)
          .orderBy('updated_date', descending: true)
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
      data['household_id'] = householdId;

      await _firestore
          .collection(_collectionName)
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
      final doc = await _firestore.collection(_collectionName).doc(id).get();

      if (!doc.exists) {
        debugPrint('⚠️ רשימה לא קיימת');
        return;
      }

      final data = doc.data();
      if (data?['household_id'] != householdId) {
        debugPrint('⚠️ רשימה לא שייכת ל-household זה');
        throw ShoppingListRepositoryException(
          'Shopping list does not belong to household',
          null,
        );
      }

      await _firestore.collection(_collectionName).doc(id).delete();

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
        .collection(_collectionName)
        .where('household_id', isEqualTo: householdId)
        .orderBy('updated_date', descending: true)
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
          .collection(_collectionName)
          .doc(listId)
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ רשימה לא נמצאה');
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data()!);

      // בדיקה שהרשימה שייכת ל-household
      if (data['household_id'] != householdId) {
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
          .collection(_collectionName)
          .where('household_id', isEqualTo: householdId)
          .where('status', isEqualTo: status)
          .orderBy('updated_date', descending: true)
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
          .collection(_collectionName)
          .where('household_id', isEqualTo: householdId)
          .where('type', isEqualTo: type)
          .orderBy('updated_date', descending: true)
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
