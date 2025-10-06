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

/// === Mock Implementation ===
///
/// 🇮🇱 מימוש ראשוני: שומר קבלות בזיכרון בלבד (Map לפי householdId).
/// 🇬🇧 Initial implementation: stores receipts in memory only (Map by householdId).
class MockReceiptRepository implements ReceiptRepository {
  final Map<String, List<Receipt>> _storage = {};

  @override
  Future<List<Receipt>> fetchReceipts(String householdId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulate latency
    return List.unmodifiable(_storage[householdId] ?? []);
  }

  @override
  Future<Receipt> saveReceipt(Receipt receipt, String householdId) async {
    final receipts = _storage.putIfAbsent(householdId, () => []);
    final index = receipts.indexWhere((r) => r.id == receipt.id);

    if (index == -1) {
      receipts.add(receipt);
    } else {
      receipts[index] = receipt;
    }

    return receipt;
  }

  @override
  Future<void> deleteReceipt(String id, String householdId) async {
    _storage[householdId]?.removeWhere((r) => r.id == id);
  }
}
