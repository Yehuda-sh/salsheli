// 📄 File: lib/repositories/firebase_receipt_repository.dart
//
// 🎯 Purpose: Repository לקבלות עם Firestore
//
// 📋 Features:
//     - CRUD operations לקבלות (שמירה, טעינה, עדכון, מחיקה)
//     - Real-time updates (watchReceipts)
//     - Queries מתקדמים (לפי חנות, טווח תאריכים)
//     - שימוש ב-FirestoreUtils להמרה בטוחה ורקורסיבית
//     - ריכוז לוגיקת מיפוי (DRY) ב-_mapSnapshotToReceipts
//
// 🏗️ Database Structure:
//     - /households/{householdId}/receipts/{receiptId}
//
// 📦 Dependencies:
//     - cloud_firestore
//     - Receipt model
//     - FirestoreUtils להמרת Timestamps רקורסיבית
//
// Version: 4.0
// Last Updated: 22/02/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/receipt.dart';
import 'constants/repository_constants.dart';
import 'receipt_repository.dart';
import 'utils/firestore_utils.dart';

class FirebaseReceiptRepository implements ReceiptRepository {
  final FirebaseFirestore _firestore;

  FirebaseReceiptRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ========================================
  // Collection Reference
  // ========================================

  /// מחזיר reference לקולקציית הקבלות של משק בית
  /// Path: /households/{householdId}/receipts
  CollectionReference<Map<String, dynamic>> _receiptsCollection(String householdId) =>
      _firestore
          .collection(FirestoreCollections.households)
          .doc(householdId)
          .collection(FirestoreCollections.householdReceipts);

  // === Fetch Receipts ===

  @override
  Future<List<Receipt>> fetchReceipts(String householdId) async {
    try {

      // 🆕 שימוש ב-subcollection - לא צריך where על household_id
      final snapshot = await _receiptsCollection(householdId)
          .orderBy(FirestoreFields.date, descending: true)
          .get();

      final receipts = _mapSnapshotToReceipts(snapshot);

      return receipts;
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to fetch receipts for $householdId', e);
    }
  }

  // === Save Receipt ===

  @override
  Future<Receipt> saveReceipt({required Receipt receipt, required String householdId}) async {
    try {
      // 🔧 אם אין id - יוצר חדש
      final receiptId = (receipt.id.isEmpty)
          ? _receiptsCollection(householdId).doc().id
          : receipt.id;

      final isNew = receipt.id.isEmpty;

      // 🆕 לא צריך להוסיף household_id - הוא בנתיב
      final data = receipt.toJson();

      // 🔧 הזרקת id לנתונים
      data['id'] = receiptId;

      // 🔧 timestamps עקביים
      final now = FieldValue.serverTimestamp();
      if (isNew) {
        data[FirestoreFields.createdDate] = now;
      }
      data[FirestoreFields.updatedDate] = now;

      // 🆕 שימוש ב-subcollection
      await _receiptsCollection(householdId)
          .doc(receiptId)
          .set(data, SetOptions(merge: true));

      // 🔧 קורא בחזרה כדי לקבל timestamps אמיתיים
      final savedDoc = await _receiptsCollection(householdId).doc(receiptId).get();
      final savedData = savedDoc.toDartMap()!;
      savedData['id'] = receiptId;

      return Receipt.fromJson(savedData);
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to save receipt ${receipt.id}', e);
    }
  }

  // === Delete Receipt ===

  @override
  Future<void> deleteReceipt({required String id, required String householdId}) async {
    try {

      // 🆕 מחיקה ישירה - הבעלות מאומתת דרך ה-subcollection path
      await _receiptsCollection(householdId).doc(id).delete();

    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to delete receipt $id', e);
    }
  }

  // === Real-time & Queries ===

  /// מחזיר stream של קבלות (real-time updates)
  ///
  /// Example:
  /// ```dart
  /// repository.watchReceipts('house_demo').listen((receipts) {
  ///   print('Receipts updated: ${receipts.length}');
  /// });
  /// ```
  @override
  Stream<List<Receipt>> watchReceipts(String householdId) {
    return _receiptsCollection(householdId)
        .orderBy(FirestoreFields.date, descending: true)
        .snapshots()
        .map(_mapSnapshotToReceipts);
  }

  /// מחזיר קבלה לפי ID
  ///
  /// Example:
  /// ```dart
  /// final receipt = await repository.getReceiptById('receipt_123', 'house_demo');
  /// ```
  @override
  Future<Receipt?> getReceiptById(String receiptId, String householdId) async {
    try {

      // 🆕 שימוש ב-subcollection - הבעלות מאומתת דרך הנתיב
      final doc = await _receiptsCollection(householdId).doc(receiptId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.toDartMap()!;
      data['id'] ??= doc.id;
      final receipt = Receipt.fromJson(data);

      return receipt;
    } catch (e, stackTrace) {
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
  @override
  Future<List<Receipt>> getReceiptsByStore(String storeName, String householdId) async {
    try {

      // 🆕 שימוש ב-subcollection - לא צריך where על household_id
      final snapshot = await _receiptsCollection(householdId)
          .where(FirestoreFields.storeName, isEqualTo: storeName)
          .orderBy(FirestoreFields.date, descending: true)
          .get();

      final receipts = _mapSnapshotToReceipts(snapshot);

      return receipts;
    } catch (e, stackTrace) {
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
  @override
  Future<List<Receipt>> getReceiptsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String householdId,
  }) async {
    try {

      // 🔧 מתחיל מתחילת startDate ומסיים בסוף endDate
      final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

      // 🆕 שימוש ב-subcollection - לא צריך where על household_id
      final snapshot = await _receiptsCollection(householdId)
          .where(FirestoreFields.date, isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStart))
          .where(FirestoreFields.date, isLessThanOrEqualTo: Timestamp.fromDate(normalizedEnd))
          .orderBy(FirestoreFields.date, descending: true)
          .get();

      final receipts = _mapSnapshotToReceipts(snapshot);

      return receipts;
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      throw ReceiptRepositoryException('Failed to get receipts by date range', e);
    }
  }

  // ========================================
  // Private Helpers
  // ========================================

  /// ממיר snapshot של Firestore לרשימת Receipt
  ///
  /// דולג על מסמכים פגומים (log + null filter) כדי לא לקרוס
  /// משתמש ב-toDartMap() להמרת Timestamps רקורסיבית
  /// מזריק id מהמסמך אם לא קיים בנתונים
  List<Receipt> _mapSnapshotToReceipts(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) {
      try {
        final data = doc.toDartMap()!;
        data['id'] ??= doc.id;
        return Receipt.fromJson(data);
      } catch (e) {
        debugPrint('⚠️ Failed to parse document ${doc.id}: $e');
        return null;
      }
    }).whereType<Receipt>().toList();
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
