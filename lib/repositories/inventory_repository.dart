// 📄 File: lib/repositories/inventory_repository.dart
//
// 🇮🇱 Repository לניהול מלאי (Inventory).
//     - אחראי לטעינה, שמירה ומחיקה של פריטי Inventory.
//     - כרגע מימוש בזיכרון (Mock), בעתיד חיבור ל-Firebase/SQLite.
//     - מאפשר ל-Providers לעבוד בצורה אחידה מול כל מקור נתונים.
//
// 🇬🇧 Repository for managing inventory items.
//     - Responsible for loading, saving, and deleting inventory items.
//     - Currently in-memory Mock, future: Firebase/SQLite.
//     - Provides a clean interface for Providers.
//

import '../models/inventory_item.dart';

/// === Contract ===
///
/// 🇮🇱 כל מקור נתונים (API, Firebase, Mock) יצטרך לממש את הממשק הזה.
/// 🇬🇧 Any data source (API, Firebase, Mock) must implement this interface.
abstract class InventoryRepository {
  Future<List<InventoryItem>> fetchItems(String householdId);
  Future<InventoryItem> saveItem(InventoryItem item, String householdId);
  Future<void> deleteItem(String id, String householdId);
}

/// === Mock Implementation ===
///
/// 🇮🇱 מימוש ראשוני: שומר את הפריטים בזיכרון בלבד.
/// 🇬🇧 Initial implementation: stores inventory items only in memory.
class MockInventoryRepository implements InventoryRepository {
  final Map<String, List<InventoryItem>> _storage = {};

  @override
  Future<List<InventoryItem>> fetchItems(String householdId) async {
    await Future.delayed(const Duration(milliseconds: 200)); // simulate latency
    return List.unmodifiable(_storage[householdId] ?? []);
  }

  @override
  Future<InventoryItem> saveItem(InventoryItem item, String householdId) async {
    final items = _storage.putIfAbsent(householdId, () => []);
    final index = items.indexWhere((i) => i.id == item.id);

    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }

    return item;
  }

  @override
  Future<void> deleteItem(String id, String householdId) async {
    _storage[householdId]?.removeWhere((i) => i.id == id);
  }
}
