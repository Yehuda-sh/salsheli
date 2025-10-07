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

import '../models/receipt.dart';

/// === Contract ===
///
/// 🇮🇱 כל מקור נתונים (API, Firebase, Mock) יצטרך לממש את הממשק הזה.
/// 🇬🇧 Any data source (API, Firebase, Mock) must implement this interface.
abstract class ReceiptRepository {
  Future<List<Receipt>> fetchReceipts(String householdId);
  Future<Receipt> saveReceipt(Receipt receipt, String householdId);
  Future<void> deleteReceipt(String id, String householdId);
}


