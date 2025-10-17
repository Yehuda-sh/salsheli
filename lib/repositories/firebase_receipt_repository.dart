// 📄 File: lib/repositories/firebase_receipt_repository.dart
//
// 🇮🇱 Repository לקבלות עם Firestore:
//     - שמירת קבלות ב-Firestore
//     - טעינת קבלות לפי householdId
//     - עדכון קבלות
//     - מחיקת קבלות
//     - Real-time updates
//
// 🇬🇧 Receipt repository with Firestore:
//     - Save receipts to Firestore
//     - Load receipts by householdId
//     - Update receipts
//     - Delete receipts
//     - Real-time updates
//
// Version: 2.0 - Helper method + Constants
// Last Updated: 09/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/receipt.dart';
import 'receipt_repository.dart';
import 'utils/firestore_utils.dart';
import 'constants/repository_constants.dart';

class FirebaseReceiptRepository implements ReceiptRepository {
  final FirebaseFirestore _firestore;

  FirebaseReceiptRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;



  // === Fetch Receipts ===

  @override
  Future<List<Receipt>> fetchReceipts(String householdId) async {
    try {
      debugPrint('📥 FirebaseReceiptRepository.fetchReceipts: טוען קבלות ל-$householdId');

      final snapshot = await _firestore
          .collection(FirestoreCollections.receipts)
          .where('household_id', isEqualTo: householdId)
          .orderBy('date', descending: true)
          .get();

      final receipts = snapshot.docs.map((doc) {
        final data = FirestoreUtils.convertTimestamps(
          Map<String, dynamic>.from(doc.data()),
        );
        return Receipt.fromJson(data);
      }).toList();

      debugPrint('✅ FirebaseReceiptRepository.fetchReceipts: נטענו ${receipts.length} קבלות');
      return receipts;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseReceiptRepository.fetchReceipts: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to fetch receipts for $householdId', e);
    }
  }

  // === Save Receipt ===

  @override
  Future<Receipt> saveReceipt(Receipt receipt, String householdId) async {
    try {
      debugPrint('💾 FirebaseReceiptRepository.saveReceipt: שומר קבלה ${receipt.id}');

      // הוספת household_id לנתונים
      final data = receipt.toJson();
      data['household_id'] = householdId;

      await _firestore
          .collection(FirestoreCollections.receipts)
          .doc(receipt.id)
          .set(data, SetOptions(merge: true));

      debugPrint('✅ FirebaseReceiptRepository.saveReceipt: קבלה נשמרה');
      return receipt;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseReceiptRepository.saveReceipt: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to save receipt ${receipt.id}', e);
    }
  }

  // === Delete Receipt ===

  @override
  Future<void> deleteReceipt(String id, String householdId) async {
    try {
      debugPrint('🗑️ FirebaseReceiptRepository.deleteReceipt: מוחק קבלה $id');

      // וידוא שהקבלה שייכת ל-household
      final doc = await _firestore
          .collection(FirestoreCollections.receipts)
          .doc(id)
          .get();
      
      if (!doc.exists) {
        debugPrint('⚠️ קבלה לא קיימת');
        return;
      }

      final data = doc.data();
      if (data?['household_id'] != householdId) {
        debugPrint('⚠️ קבלה לא שייכת ל-household זה');
        throw ReceiptRepositoryException('Receipt does not belong to household', null);
      }

      await _firestore
          .collection(FirestoreCollections.receipts)
          .doc(id)
          .delete();

      debugPrint('✅ FirebaseReceiptRepository.deleteReceipt: קבלה נמחקה');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseReceiptRepository.deleteReceipt: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to delete receipt $id', e);
    }
  }

  // === 🆕 פונקציות נוספות ===

  /// מחזיר stream של קבלות (real-time updates)
  /// 
  /// Example:
  /// ```dart
  /// repository.watchReceipts('house_demo').listen((receipts) {
  ///   print('Receipts updated: ${receipts.length}');
  /// });
  /// ```
  Stream<List<Receipt>> watchReceipts(String householdId) {
    return _firestore
        .collection(FirestoreCollections.receipts)
        .where('household_id', isEqualTo: householdId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = FirestoreUtils.convertTimestamps(
          Map<String, dynamic>.from(doc.data()),
        );
        return Receipt.fromJson(data);
      }).toList();
    });
  }

  /// מחזיר קבלה לפי ID
  /// 
  /// Example:
  /// ```dart
  /// final receipt = await repository.getReceiptById('receipt_123', 'house_demo');
  /// ```
  Future<Receipt?> getReceiptById(String receiptId, String householdId) async {
    try {
      debugPrint('🔍 FirebaseReceiptRepository.getReceiptById: מחפש קבלה $receiptId');

      final doc = await _firestore
          .collection(FirestoreCollections.receipts)
          .doc(receiptId)
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ קבלה לא נמצאה');
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data()!);
      
      // בדיקה שהקבלה שייכת ל-household
      if (data['household_id'] != householdId) {
        debugPrint('⚠️ קבלה לא שייכת ל-household זה');
        return null;
      }

      final convertedData = FirestoreUtils.convertTimestamps(data);
      final receipt = Receipt.fromJson(convertedData);
      debugPrint('✅ קבלה נמצאה');
      
      return receipt;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseReceiptRepository.getReceiptById: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to get receipt by id', e);
    }
  }

  /// מחזיר קבלות לפי חנות
  /// 
  /// Example:
  /// ```dart
  /// final receipts = await repository.getReceiptsByStore('שופרסל', 'house_demo');
  /// ```
  Future<List<Receipt>> getReceiptsByStore(String storeName, String householdId) async {
    try {
      debugPrint('🏪 FirebaseReceiptRepository.getReceiptsByStore: מחפש קבלות מ-$storeName');

      final snapshot = await _firestore
          .collection(FirestoreCollections.receipts)
          .where('household_id', isEqualTo: householdId)
          .where(FirestoreFields.storeName, isEqualTo: storeName)
          .orderBy('date', descending: true)
          .get();

      final receipts = snapshot.docs.map((doc) {
        final data = FirestoreUtils.convertTimestamps(
          Map<String, dynamic>.from(doc.data()),
        );
        return Receipt.fromJson(data);
      }).toList();

      debugPrint('✅ נמצאו ${receipts.length} קבלות');
      return receipts;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseReceiptRepository.getReceiptsByStore: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to get receipts by store', e);
    }
  }

  /// מחזיר קבלות בטווח תאריכים
  /// 
  /// Example:
  /// ```dart
  /// final receipts = await repository.getReceiptsByDateRange(
  ///   startDate: DateTime(2025, 1, 1),
  ///   endDate: DateTime(2025, 1, 31),
  ///   householdId: 'house_demo',
  /// );
  /// ```
  Future<List<Receipt>> getReceiptsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String householdId,
  }) async {
    try {
      debugPrint('📅 FirebaseReceiptRepository.getReceiptsByDateRange: מחפש קבלות');

      final snapshot = await _firestore
          .collection(FirestoreCollections.receipts)
          .where('household_id', isEqualTo: householdId)
          .where(FirestoreFields.date, isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where(FirestoreFields.date, isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      final receipts = snapshot.docs.map((doc) {
        final data = FirestoreUtils.convertTimestamps(
          Map<String, dynamic>.from(doc.data()),
        );
        return Receipt.fromJson(data);
      }).toList();

      debugPrint('✅ נמצאו ${receipts.length} קבלות');
      return receipts;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseReceiptRepository.getReceiptsByDateRange: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to get receipts by date range', e);
    }
  }
}

/// Exception class for receipt repository errors
class ReceiptRepositoryException implements Exception {
  final String message;
  final Object? cause;

  ReceiptRepositoryException(this.message, this.cause);

  @override
  String toString() => 'ReceiptRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
