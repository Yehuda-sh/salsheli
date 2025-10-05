// 📄 File: lib/repositories/local_shopping_lists_repository.dart
//
// 🇮🇱 Repository מקומי לרשימות קניות ע"י LocalStorageService (SharedPreferences/File).
//      - Cache בזיכרון לכל householdId למניעת IO מיותר.
//      - טעינה עמידה לנתונים מושחתים (fallback לריק).
//      - עדכון updatedDate אוטומטי.
//      - נקודת הרחבה ל-export/import/clear.
// 🇬🇧 Local Shopping Lists repository backed by LocalStorageService.
//      - In-memory cache per householdId.
//      - Corruption-safe loading (fallback to empty).
//      - Auto-updates updatedDate on save.
//      - Hooks for export/import/clear.

import '../models/shopping_list.dart';
import '../services/local_storage_service.dart';
import 'shopping_lists_repository.dart';

class LocalShoppingListsRepository implements ShoppingListsRepository {
  LocalShoppingListsRepository({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  /// In-memory cache: householdId -> lists
  final Map<String, List<ShoppingList>> _cache = {};

  String _key(String householdId) => 'shopping_lists.$householdId';

  @override
  Future<List<ShoppingList>> fetchLists(String householdId) async {
    // serve from cache if available
    final cached = _cache[householdId];
    if (cached != null) return List<ShoppingList>.from(cached);

    // load from storage
    try {
      final data = await _storage.loadJson(_key(householdId));
      if (data == null) {
        _cache[householdId] = <ShoppingList>[];
        return const [];
      }

      if (data is List) {
        final lists =
            data
                .whereType<Map<String, dynamic>>() // ignore bad entries
                .map(ShoppingList.fromJson)
                .toList()
              ..sort(
                (a, b) =>
                    b.updatedDate.compareTo(a.updatedDate),
              );

        _cache[householdId] = lists;
        return List<ShoppingList>.from(lists);
      }
    } catch (_) {
      // corruption or unexpected shape -> fallback to empty
    }

    _cache[householdId] = <ShoppingList>[];
    return const [];
  }

  @override
  Future<ShoppingList> saveList(ShoppingList list, String householdId) async {
    // ensure up-to-date snapshot
    final lists = List<ShoppingList>.from(await fetchLists(householdId));

    final idx = lists.indexWhere((l) => l.id == list.id);
    final updated = list.copyWith(updatedDate: DateTime.now());

    if (idx == -1) {
      lists.add(updated);
    } else {
      lists[idx] = updated;
    }

    // deterministic order (newest first)
    lists.sort(
      (a, b) => b.updatedDate.compareTo(a.updatedDate),
    );

    // write-through cache
    _cache[householdId] = lists;

    // atomic-ish write (service should overwrite the key in one go)
    final encoded = lists.map((l) => l.toJson()).toList();
    await _storage.saveJson(_key(householdId), encoded);

    return updated;
  }

  @override
  Future<void> deleteList(String id, String householdId) async {
    final lists = List<ShoppingList>.from(await fetchLists(householdId))
      ..removeWhere((l) => l.id == id);

    _cache[householdId] = lists;

    final encoded = lists.map((l) => l.toJson()).toList();
    await _storage.saveJson(_key(householdId), encoded);
  }

  // -------- Optional utilities (לא חלק מה־interface) --------

  /// מוחק את כל הרשימות של householdId (לא חובה להשתמש).
  Future<void> clearAll(String householdId) async {
    _cache.remove(householdId);
    await _storage.remove(_key(householdId));
  }

  /// ייצוא לכלי גיבוי/שיתוף.
  Future<List<Map<String, dynamic>>> exportAll(String householdId) async {
    final lists = await fetchLists(householdId);
    return lists.map((l) => l.toJson()).toList();
  }

  /// יבוא מהרשימה הנתונה (מחליף לגמרי).
  Future<void> importAll(
    String householdId,
    List<Map<String, dynamic>> payload,
  ) async {
    final lists = payload.map(ShoppingList.fromJson).toList();
    _cache[householdId] = lists;
    await _storage.saveJson(_key(householdId), payload);
  }
}
