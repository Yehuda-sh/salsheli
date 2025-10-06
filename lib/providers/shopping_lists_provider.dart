// 📄 File: lib/providers/shopping_lists_provider.dart
//
// 🎯 Purpose: Provider לניהול רשימות קניות - ניהול state מרכזי של כל הרשימות
//
// 📦 Dependencies:
// - ShoppingListsRepository: ממשק לטעינת/שמירת רשימות
// - UserContext: household_id + auth state
//
// ✨ Features:
// - 📥 טעינה אוטומטית: מאזין ל-UserContext ומריענן כשמשתמש משתנה
// - ✏️ CRUD מלא: יצירה, עדכון, מחיקה, שחזור (Undo)
// - 📊 State management: isLoading, errorMessage, lastUpdated
// - 🔄 Auto-sync: רענון אוטומטי כשמשתמש מתחבר/מתנתק
// - 🎯 פעולות על פריטים: הוספה, עדכון, מחיקה, סימון כולם
// - 📋 סטטיסטיקות: ספירת פריטים מסומנים/לא מסומנים
// - 🐛 Logging מפורט: כל פעולה עם debugPrint
//
// 📝 Usage:
// ```dart
// // בקריאת נתונים:
// final provider = context.watch<ShoppingListsProvider>();
// final lists = provider.lists;
//
// // ביצירת רשימה:
// final list = await provider.createList(
//   name: 'קניות שבועיות',
//   type: ShoppingList.typeSuper,
//   budget: 500.0,
// );
//
// // בעדכון:
// await provider.updateList(updatedList);
//
// // במחיקה:
// await provider.deleteList(listId);
//
// // בשחזור (Undo):
// await provider.restoreList(deletedList);
// ```
//
// 🔄 State Flow:
// 1. Constructor → מחכה ל-UserContext
// 2. updateUserContext() → _onUserChanged() → loadLists()
// 3. CRUD operations → Repository → loadLists() → notifyListeners()
//
// Version: 2.0 (עם UserContext סטנדרטי + logging מלא)
// Last Updated: 06/10/2025
//

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/receipt.dart';
import '../models/shopping_list.dart';
import '../repositories/shopping_lists_repository.dart';
import 'user_context.dart';

class ShoppingListsProvider with ChangeNotifier {
  final ShoppingListsRepository _repository;
  final _uuid = const Uuid();

  // State
  List<ShoppingList> _lists = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // UserContext
  UserContext? _userContext;
  bool _listening = false;

  ShoppingListsProvider({
    required ShoppingListsRepository repository,
  }) : _repository = repository;

  // === Getters ===
  List<ShoppingList> get lists => List.unmodifiable(_lists);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  // === חיבור UserContext ===
  
  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
  void updateUserContext(UserContext newContext) {
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;
    _initialize();
  }

  void _onUserChanged() {
    loadLists();
  }

  void _initialize() {
    if (_userContext?.isLoggedIn == true) {
      loadLists();
    } else {
      _lists = [];
      notifyListeners();
    }
  }

  /// טוען את כל הרשימות מחדש מה-Repository
  /// 
  /// Example:
  /// ```dart
  /// await shoppingListsProvider.loadLists();
  /// ```
  Future<void> loadLists() async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lists = await _repository.fetchLists(householdId);
      _lastUpdated = DateTime.now();
      debugPrint('✅ נטענו ${_lists.length} רשימות');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ שגיאה בטעינת רשימות: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// יוצר רשימת קניות חדשה
  /// 
  /// Example:
  /// ```dart
  /// final list = await provider.createList(
  ///   name: 'קניות שבועיות',
  ///   type: ShoppingList.typeSuper,
  ///   budget: 500.0,
  /// );
  /// ```
  Future<ShoppingList> createList({
    required String name,
    String type = ShoppingList.typeSuper,
    double? budget,
    bool isShared = false,
  }) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;
    
    if (userId == null || householdId == null) {
      throw Exception('❌ משתמש לא מחובר');
    }

    final newList = ShoppingList.newList(
      id: _uuid.v4(),
      name: name,
      createdBy: userId,
      type: type,
      budget: budget,
      isShared: isShared,
    );

    await _repository.saveList(newList, householdId);
    await loadLists();
    return newList;
  }

  /// מחיק רשימה
  /// 
  /// Example:
  /// ```dart
  /// await provider.deleteList(listId);
  /// ```
  Future<void> deleteList(String id) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      throw Exception('❌ householdId לא נמצא');
    }

    await _repository.deleteList(id, householdId);
    await loadLists();
  }

  /// משחזר רשימה שנמחקה (Undo)
  /// 
  /// Example:
  /// ```dart
  /// await provider.restoreList(deletedList);
  /// ```
  Future<void> restoreList(ShoppingList list) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      throw Exception('❌ householdId לא נמצא');
    }

    await _repository.saveList(list, householdId);
    await loadLists();
  }

  /// מעדכן רשימה קיימת
  /// 
  /// Example:
  /// ```dart
  /// await provider.updateList(updatedList);
  /// ```
  Future<void> updateList(ShoppingList updated) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      throw Exception('❌ householdId לא נמצא');
    }

    await _repository.saveList(updated, householdId);
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

  /// מחזיר סטטיסטיקות על רשימה
  /// 
  /// Returns: Map עם total, checked, unchecked
  /// 
  /// Example:
  /// ```dart
  /// final stats = provider.getListStats(listId);
  /// print('סומנו: ${stats['checked']}/${stats['total']}');
  /// ```
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

  /// מעדכן סטטוס רשימה
  /// 
  /// Example:
  /// ```dart
  /// await provider.updateListStatus(listId, ShoppingList.statusCompleted);
  /// ```
  Future<void> updateListStatus(String listId, String newStatus) async {
    final list = getById(listId);
    if (list == null) {
      throw Exception('רשימה $listId לא נמצאה');
    }

    final updatedList = list.copyWith(status: newStatus);
    await updateList(updatedList);
  }

  /// מארכבת רשימה
  Future<void> archiveList(String listId) async {
    await updateListStatus(listId, ShoppingList.statusArchived);
  }

  /// מסיימת רשימה כהושלמה
  Future<void> completeList(String listId) async {
    await updateListStatus(listId, ShoppingList.statusCompleted);
  }

  /// מפעילה רשימה
  Future<void> activateList(String listId) async {
    await updateListStatus(listId, ShoppingList.statusActive);
  }

  @override
  void dispose() {
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }
    super.dispose();
  }
}
