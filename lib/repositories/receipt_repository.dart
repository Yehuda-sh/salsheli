// 📄 File: lib/repositories/receipt_repository.dart
//
// 🎯 Purpose: Interface לניהול קבלות (Receipts)
//
// 📋 Features:
//     - תמיכה ב-Real-time Updates (watchReceipts)
//     - חיפושים מתקדמים (חנות, טווח תאריכים)
//     - תיעוד מלא ל-Intellisense
//     - CRUD operations מלאות
//
// 🏗️ Architecture: Repository Pattern
//     - Interface מופשט - שכבת ביניים בין Provider ל-Data Source
//     - מאפשר החלפת מימוש (Firebase / Mock) ללא שינוי UI
//
// 📋 Implementations:
//     - FirebaseReceiptRepository - מימוש הייצור (Firestore)
//
// 🔗 Related:
//     - lib/repositories/firebase_receipt_repository.dart - המימוש
//     - lib/providers/receipt_provider.dart - Provider שמשתמש ב-repository
//     - lib/models/receipt.dart - מבנה הנתונים
//
// 📜 History:
//     - v1.0 (09/10/2025): Interface ראשוני - fetch, save, delete
//     - v2.0 (09/10/2025): הוספת docstrings
//     - v3.0 (22/02/2026): סנכרון מול Implementation - watch, queries, תיעוד מלא
//
// Version: 3.0
// Last Updated: 22/02/2026

import '../models/receipt.dart';

/// Interface לניהול קבלות
///
/// מגדיר חוזה לגישת נתונים לקבלות של משק בית.
/// כל מקור נתונים (Firebase, Mock) חייב לממש את הממשק הזה.
///
/// המתודות מחולקות לשלושה עולמות:
/// - **Fetch** - טעינה וחיפוש (one-shot)
/// - **Real-time** - האזנה לשינויים (Streams)
/// - **Persistence** - שמירה ומחיקה
abstract class ReceiptRepository {
  // ========================================
  // Fetch - טעינה וחיפוש
  // ========================================

  /// טוען את כל הקבלות של משק בית
  ///
  /// Path: `/households/{householdId}/receipts`
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: רשימת קבלות ממוינת לפי תאריך (חדש → ישן)
  ///
  /// Throws: Exception במקרה של שגיאת רשת/DB
  ///
  /// Example:
  /// ```dart
  /// final receipts = await repository.fetchReceipts('house_demo');
  /// print('נטענו ${receipts.length} קבלות');
  /// ```
  Future<List<Receipt>> fetchReceipts(String householdId);

  /// מחזיר קבלה בודדת לפי ID
  ///
  /// Path: `/households/{householdId}/receipts/{receiptId}`
  ///
  /// Parameters:
  ///   - [receiptId]: מזהה הקבלה
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: הקבלה או `null` אם לא נמצאה
  ///
  /// Example:
  /// ```dart
  /// final receipt = await repository.getReceiptById('receipt_123', 'house_demo');
  /// if (receipt != null) print('נמצאה: ${receipt.storeName}');
  /// ```
  Future<Receipt?> getReceiptById(String receiptId, String householdId);

  /// מחזיר קבלות לפי שם חנות
  ///
  /// Path: `/households/{householdId}/receipts` (filtered by store_name)
  ///
  /// Parameters:
  ///   - [storeName]: שם החנות (למשל: 'שופרסל')
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: רשימת קבלות מהחנות, ממוינת לפי תאריך (חדש → ישן)
  ///
  /// Example:
  /// ```dart
  /// final receipts = await repository.getReceiptsByStore('שופרסל', 'house_demo');
  /// print('${receipts.length} קבלות משופרסל');
  /// ```
  Future<List<Receipt>> getReceiptsByStore(String storeName, String householdId);

  /// מחזיר קבלות בטווח תאריכים
  ///
  /// Parameters:
  ///   - [startDate]: תחילת הטווח (כולל)
  ///   - [endDate]: סוף הטווח (כולל, עד 23:59:59)
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: רשימת קבלות בטווח, ממוינת לפי תאריך (חדש → ישן)
  ///
  /// Example:
  /// ```dart
  /// final receipts = await repository.getReceiptsByDateRange(
  ///   startDate: DateTime(2026, 1, 1),
  ///   endDate: DateTime(2026, 1, 31),
  ///   householdId: 'house_demo',
  /// );
  /// ```
  Future<List<Receipt>> getReceiptsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String householdId,
  });

  // ========================================
  // Real-time - האזנה לשינויים
  // ========================================

  /// מאזין לשינויים בקבלות בזמן אמת
  ///
  /// Path: `/households/{householdId}/receipts`
  ///
  /// Parameters:
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: Stream של רשימת קבלות - מתעדכן אוטומטית
  /// כאשר בן משפחה אחר מוסיף/מעדכן/מוחק קבלה
  ///
  /// Example:
  /// ```dart
  /// repository.watchReceipts('house_demo').listen((receipts) {
  ///   print('קבלות עודכנו: ${receipts.length}');
  /// });
  /// ```
  Stream<List<Receipt>> watchReceipts(String householdId);

  // ========================================
  // Persistence - שמירה ומחיקה
  // ========================================

  /// שומר קבלה (יצירה או עדכון)
  ///
  /// Path: `/households/{householdId}/receipts/{receipt.id}`
  ///
  /// Parameters:
  ///   - [receipt]: הקבלה לשמירה (חדשה או קיימת)
  ///   - [householdId]: מזהה משק הבית
  ///
  /// Returns: הקבלה השמורה (עם timestamps מעודכנים מהשרת)
  ///
  /// Throws: Exception במקרה של שגיאת רשת/DB
  ///
  /// Example:
  /// ```dart
  /// final saved = await repository.saveReceipt(
  ///   receipt: receipt,
  ///   householdId: 'house_demo',
  /// );
  /// ```
  Future<Receipt> saveReceipt({required Receipt receipt, required String householdId});

  /// מוחק קבלה
  ///
  /// Path: `/households/{householdId}/receipts/{id}`
  ///
  /// Parameters:
  ///   - [id]: מזהה הקבלה למחיקה
  ///   - [householdId]: מזהה משק הבית (הבעלות מאומתת דרך הנתיב)
  ///
  /// Throws: Exception במקרה של שגיאת רשת/DB
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteReceipt(id: 'receipt_123', householdId: 'house_demo');
  /// ```
  Future<void> deleteReceipt({required String id, required String householdId});
}
