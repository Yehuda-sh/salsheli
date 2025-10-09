// 📄 File: lib/repositories/receipt_repository.dart
//
// 🇮🇱 Repository לניהול קבלות (Receipts).
//     - שכבת ביניים בין Providers ↔ מקור נתונים (API / Firebase / Mock).
//     - מאפשר שליפה, שמירה ומחיקה של קבלות.
//     - קל להחליף מימושים (Mock, API, Firebase) בלי לשנות את ה־UI.
//
// 🇬🇧 Repository for managing receipts.
//     - Bridge layer between Providers ↔ data source (API / Firebase / Mock).
//     - Supports fetching, saving, and deleting receipts.
//     - Easy to swap implementations (Mock, API, Firebase) without UI changes.
//
// Version: 2.0 - Added docstrings
// Last Updated: 09/10/2025

import '../models/receipt.dart';

/// === Contract ===
///
/// 🇮🇱 כל מקור נתונים (API, Firebase, Mock) יצטרך לממש את הממשק הזה.
/// 🇬🇧 Any data source (API, Firebase, Mock) must implement this interface.
abstract class ReceiptRepository {
  /// טוען את כל הקבלות של household
  /// 
  /// [householdId] - מזהה המשק בית
  /// 
  /// Returns: רשימת קבלות, ריקה אם אין
  /// 
  /// Throws: Exception במקרה של שגיאת רשת/DB
  /// 
  /// Example:
  /// ```dart
  /// final receipts = await repository.fetchReceipts('house_123');
  /// print('נטענו ${receipts.length} קבלות');
  /// ```
  Future<List<Receipt>> fetchReceipts(String householdId);

  /// שומר קבלה (יצירה או עדכון)
  /// 
  /// [receipt] - הקבלה לשמירה
  /// [householdId] - מזהה המשק בית
  /// 
  /// Returns: הקבלה ששמורה (עם שדות מעודכנים אם צריך)
  /// 
  /// Throws: Exception במקרה של שגיאת רשת/DB
  /// 
  /// Example:
  /// ```dart
  /// final newReceipt = Receipt.newReceipt(
  ///   storeName: 'שופרסל',
  ///   date: DateTime.now(),
  ///   items: [...],
  /// );
  /// final saved = await repository.saveReceipt(newReceipt, 'house_123');
  /// ```
  Future<Receipt> saveReceipt(Receipt receipt, String householdId);

  /// מחיק קבלה
  /// 
  /// [id] - מזהה הקבלה
  /// [householdId] - מזהה המשק בית (לאימות ownership)
  /// 
  /// Throws: Exception במקרה של שגיאת רשת/DB או אם הקבלה לא שייכת ל-household
  /// 
  /// Example:
  /// ```dart
  /// await repository.deleteReceipt('receipt_123', 'house_123');
  /// print('קבלה נמחקה בהצלחה');
  /// ```
  Future<void> deleteReceipt(String id, String householdId);
}
