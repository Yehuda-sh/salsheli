// 📄 File: lib/providers/shopping_lists_provider.dart - FIXED
//
// ✅ תיקונים:
// 1. הסרת תלות ב-UserContextProvider (לא קיים)
// 2. createList() תומך ב-type ו-budget
// 3. שמירה על תאימות למערכת הקיימת
//
// 🇮🇱 Provider לניהול רשימות קניות.
// 🇬🇧 Provider for managing shopping lists.

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/receipt.dart';
import '../models/shopping_list.dart';
import '../repositories/shopping_lists_repository.dart';

class ShoppingListsProvider with ChangeNotifier {
  final ShoppingListsRepository _repository;
  final _uuid = const Uuid();

  List<ShoppingList> _lists = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // ✅ במקום UserContext - פשוט נשמור את ה-householdId
  String? _householdId;
  String? _currentUserId;

  ShoppingListsProvider({required ShoppingListsRepository repository})
    : _repository = repository;

  List<ShoppingList> get lists => List.unmodifiable(_lists);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  // ✅ הגדרת המשתמש הנוכחי (קריאה מהמערכת הקיימת)
  void setCurrentUser({required String userId, required String householdId}) {
    debugPrint('\n👤 ShoppingListsProvider.setCurrentUser()');
    debugPrint('   userId: $userId');
    debugPrint('   householdId: $householdId');
    
    _currentUserId = userId;
    _householdId = householdId;
    
    debugPrint('   ➡️ קורא ל-loadLists()...');
    loadLists();
  }

  // === Load Lists ===
  Future<void> loadLists() async {
    if (_householdId == null) {
      debugPrint(
        '⚠️ ShoppingListsProvider.loadLists: לא ניתן לטעון רשימות - אין householdId',
      );
      return;
    }

    debugPrint('\n📜 ShoppingListsProvider.loadLists() - מתחיל...');
    debugPrint('   householdId: $_householdId');
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lists = await _repository.fetchLists(_householdId!);
      _lastUpdated = DateTime.now();
      debugPrint('✅ ShoppingListsProvider: נטענו ${_lists.length} רשימות');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ ShoppingListsProvider: שגיאה בטעינת רשימות - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Create List === ✅ עודכן - תומך ב-type ו-budget
  Future<ShoppingList> createList({
    required String name,
    String type = ShoppingList.typeSuper,
    double? budget,
    bool isShared = false,
  }) async {
    debugPrint('\n➕ ShoppingListsProvider.createList()');
    debugPrint('   name: $name');
    debugPrint('   type: $type');
    debugPrint('   budget: $budget');
    debugPrint('   isShared: $isShared');
    
    if (_currentUserId == null || _householdId == null) {
      debugPrint('❌ משתמש לא מחובר');
      throw Exception('❌ משתמש לא מחובר');
    }

    final newList = ShoppingList.newList(
      id: _uuid.v4(),
      name: name,
      createdBy: _currentUserId!,
      type: type,
      budget: budget,
      isShared: isShared,
    );

    debugPrint('✅ שומר רשימה חדשה: ${newList.id}');
    await _repository.saveList(newList, _householdId!);
    
    debugPrint('   ➡️ טוען מחדש את כל הרשימות...');
    await loadLists();
    return newList;
  }

  // === Delete List ===
  Future<void> deleteList(String id) async {
    if (_householdId == null) {
      throw Exception('❌ householdId לא נמצא');
    }

    await _repository.deleteList(id, _householdId!);
    await loadLists();
  }

  // === Update List ===
  Future<void> updateList(ShoppingList updated) async {
    if (_householdId == null) {
      throw Exception('❌ householdId לא נמצא');
    }

    await _repository.saveList(updated, _householdId!);
    await loadLists();
  }

  // === Get List By ID ===
  ShoppingList? getById(String id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (_) {
      return null;
    }
  }

  // === Add Item To List ===
  Future<void> addItemToList(String listId, ReceiptItem item) async {
    final list = getById(listId);
    if (list == null) {
      throw Exception('רשימה $listId לא נמצאה');
    }

    final updatedList = list.withItemAdded(item);
    await updateList(updatedList);
  }

  // === Remove Item From List ===
  Future<void> removeItemFromList(String listId, int index) async {
    final list = getById(listId);
    if (list == null) {
      throw Exception('רשימה $listId לא נמצאה');
    }

    final updatedList = list.withItemRemoved(index);
    await updateList(updatedList);
  }

  // === Update Item At Index ===
  Future<void> updateItemAt(
    String listId,
    int index,
    ReceiptItem Function(ReceiptItem) updateFn,
  ) async {
    final list = getById(listId);
    if (list == null) {
      throw Exception('רשימה $listId לא נמצאה');
    }

    if (index < 0 || index >= list.items.length) {
      throw Exception('אינדקס לא חוקי: $index');
    }

    final updatedItem = updateFn(list.items[index]);
    final newItems = List<ReceiptItem>.from(list.items);
    newItems[index] = updatedItem;

    final updatedList = list.copyWith(items: newItems);
    await updateList(updatedList);
  }

  // === Toggle All Items Checked ===
  Future<void> toggleAllItemsChecked(String listId, bool isChecked) async {
    final list = getById(listId);
    if (list == null) {
      throw Exception('רשימה $listId לא נמצאה');
    }

    final newItems = list.items.map((item) {
      return item.copyWith(isChecked: isChecked);
    }).toList();

    final updatedList = list.copyWith(items: newItems);
    await updateList(updatedList);
  }

  // === Get List Stats ===
  Map<String, int> getListStats(String listId) {
    final list = getById(listId);
    if (list == null) {
      return {'total': 0, 'checked': 0, 'unchecked': 0};
    }

    final total = list.items.length;
    final checked = list.items.where((item) => item.isChecked).length;
    final unchecked = total - checked;

    return {'total': total, 'checked': checked, 'unchecked': unchecked};
  }

  // === Update List Status ===
  Future<void> updateListStatus(String listId, String newStatus) async {
    final list = getById(listId);
    if (list == null) {
      throw Exception('רשימה $listId לא נמצאה');
    }

    final updatedList = list.copyWith(status: newStatus);
    await updateList(updatedList);
  }

  // === Archive List ===
  Future<void> archiveList(String listId) async {
    await updateListStatus(listId, ShoppingList.statusArchived);
  }

  // === Complete List ===
  Future<void> completeList(String listId) async {
    await updateListStatus(listId, ShoppingList.statusCompleted);
  }

  // === Activate List ===
  Future<void> activateList(String listId) async {
    await updateListStatus(listId, ShoppingList.statusActive);
  }
}
