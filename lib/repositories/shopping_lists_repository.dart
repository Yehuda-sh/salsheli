// 📄 File: lib/repositories/shopping_lists_repository.dart
//
// 🇮🇱 Repository לניהול רשימות קניות.
//     - משמש כשכבת ביניים בין Providers ↔ מקור הנתונים (API / Firebase / Mock).
//     - מאפשר להחליף בקלות מקור נתונים ע"י מימוש שונה.
//     - עוזר לשמור את ShoppingListsProvider נקי מהלוגיקה של אחסון/טעינה.
//
// 🇬🇧 Repository for managing shopping lists.
//     - Acts as a bridge between Providers ↔ data source (API / Firebase / Mock).
//     - Makes it easy to swap data source by changing the implementation.
//     - Keeps ShoppingListsProvider clean from storage/fetching logic.
//

import '../models/shopping_list.dart';

/// === Contract ===
///
/// 🇮🇱 כל מקור נתונים (API, Firebase, Mock) יצטרך לממש את הממשק הזה.
/// 🇬🇧 Any data source (API, Firebase, Mock) must implement this interface.
abstract class ShoppingListsRepository {
  Future<List<ShoppingList>> fetchLists(String householdId);
  Future<ShoppingList> saveList(ShoppingList list, String householdId);
  Future<void> deleteList(String id, String householdId);
}

/// === Mock Implementation ===
///
/// 🇮🇱 מימוש ראשוני: שומר את הרשימות בזיכרון בלבד (Map לפי householdId).
/// 🇬🇧 Initial implementation: stores lists only in memory (Map by householdId).
class MockShoppingListsRepository implements ShoppingListsRepository {
  final Map<String, List<ShoppingList>> _storage = {};

  @override
  Future<List<ShoppingList>> fetchLists(String householdId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulate latency
    return List.unmodifiable(_storage[householdId] ?? []);
  }

  @override
  Future<ShoppingList> saveList(ShoppingList list, String householdId) async {
    final lists = _storage.putIfAbsent(householdId, () => []);
    final index = lists.indexWhere((l) => l.id == list.id);
    final newList = list.copyWith(updatedDate: DateTime.now());

    if (index == -1) {
      lists.add(newList);
    } else {
      lists[index] = newList;
    }

    return newList;
  }

  @override
  Future<void> deleteList(String id, String householdId) async {
    _storage[householdId]?.removeWhere((l) => l.id == id);
  }
}
