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


