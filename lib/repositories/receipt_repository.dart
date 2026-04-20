// lib/repositories/receipt_repository.dart — Receipt repository interface — abstract CRUD + stream for shopping receipts

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
