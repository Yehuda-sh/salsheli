// 📄 File: lib/providers/shopping_lists_provider.dart
//
// 🎯 Purpose: Provider לניהול רשימות קניות - ניהול state מרכזי של כל הרשימות
//
// 📦 Dependencies:
// - ShoppingListsRepository: ממשק לטעינת/שמירת רשימות
// - UserContext: household_id + auth state
// - FirebaseShoppingListsRepository: מימוש Firebase של Repository
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
// Version: 2.1 (FirebaseShoppingListsRepository - naming consistency)
// Last Updated: 09/10/2025
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
  String? _currentHouseholdId; // 🆕 מעקב אחרי household_id נוכחי

  ShoppingListsProvider({
    required ShoppingListsRepository repository,
  }) : _repository = repository;

  // === Getters ===
  List<ShoppingList> get lists => List.unmodifiable(_lists);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isEmpty => _lists.isEmpty;

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
    final newHouseholdId = _userContext?.user?.householdId;
    
    // 🔍 בדוק אם המשתמש השתנה
    if (newHouseholdId != _currentHouseholdId) {
      debugPrint('🔄 _onUserChanged: household_id השתנה');
      debugPrint('   ישן: $_currentHouseholdId');
      debugPrint('   חדש: $newHouseholdId');
      
      // נקה רשימות ישנות
      _lists = [];
      _errorMessage = null;
      _currentHouseholdId = newHouseholdId;
    }
    
    // טען רשימות רק אם יש משתמש מחובר
    if (_userContext?.isLoggedIn == true && newHouseholdId != null) {
      loadLists();
    }
  }

  void _initialize() {
    final householdId = _userContext?.user?.householdId;
    
    if (_userContext?.isLoggedIn == true && householdId != null) {
      _currentHouseholdId = householdId;
      loadLists();
    } else {
      _lists = [];
      _currentHouseholdId = null;
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
    
    // 🛡️ Guard: אל תטען אם אין משתמש או אין household_id
    if (householdId == null || _userContext?.user == null) {
      debugPrint('⚠️ loadLists: householdId או user לא זמינים');
      return;
    }
    
    // 🛡️ Guard: אל תטען אם זה לא ה-household הנוכחי
    if (_currentHouseholdId != null && householdId != _currentHouseholdId) {
      debugPrint('⚠️ loadLists: household_id לא תואם (נוכחי: $_currentHouseholdId, מבוקש: $householdId)');
      return;
    }

    debugPrint('📥 loadLists: מתחיל טעינה (householdId: $householdId)');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lists = await _repository.fetchLists(householdId);
      _lastUpdated = DateTime.now();
      debugPrint('✅ loadLists: נטענו ${_lists.length} רשימות');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ loadLists: שגיאה - $e');
      notifyListeners(); // ← עדכון UI מיידי על שגיאה
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ניסיון חוזר אחרי שגיאה
  /// 
  /// Example:
  /// ```dart
  /// if (provider.hasError) {
  ///   await provider.retry();
  /// }
  /// ```
  Future<void> retry() async {
    debugPrint('🔄 retry: מנסה שוב לטעון רשימות');
    _errorMessage = null;
    await loadLists();
  }

  /// מנקה את כל ה-state (שימושי ב-logout)
  /// 
  /// Example:
  /// ```dart
  /// await provider.clearAll();
  /// ```
  void clearAll() {
    debugPrint('🧹 clearAll: מנקה state');
    _lists = [];
    _errorMessage = null;
    _isLoading = false;
    _lastUpdated = null;
    _currentHouseholdId = null; // 🆕 נקה גם household_id
    notifyListeners();
  }

  /// יוצר רשימת קניות חדשה
  /// 
  /// Example:
  /// ```dart
  /// final list = await provider.createList(
  ///   name: 'קניות שבועיות',
  ///   type: ShoppingList.typeSuper,
  ///   budget: 500.0,
  ///   eventDate: DateTime(2025, 10, 15), // אירוע ב-15/10
  ///   items: [...], // 🆕 פריטים מתבנית
  /// );
  /// ```
  Future<ShoppingList> createList({
    required String name,
    String type = ShoppingList.typeSuper,
    double? budget,
    DateTime? eventDate,
    bool isShared = false,
    List<ReceiptItem>? items, // 🆕 פריטים אופציונליים
    String? templateId, // 🆕 מזהה תבנית
  }) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;
    
    if (userId == null || householdId == null) {
      debugPrint('❌ createList: משתמש לא מחובר');
      throw Exception('❌ משתמש לא מחובר');
    }

    debugPrint('➕ createList: "$name" (סוג: $type, תקציב: $budget, תאריך: $eventDate)');
    debugPrint('   🆕 פריטים: ${items?.length ?? 0}, תבנית: ${templateId ?? "ללא"}');
    _errorMessage = null;

    try {
      // 🆕 אם יש תבנית, השתמש ב-factory המיוחד
      final newList = templateId != null
          ? ShoppingList.fromTemplate(
              id: _uuid.v4(),
              templateId: templateId,
              name: name,
              createdBy: userId,
              type: type,
              format: 'shared',
              items: items ?? [],
              budget: budget,
              eventDate: eventDate,
              isShared: isShared,
            )
          : ShoppingList.newList(
              id: _uuid.v4(),
              name: name,
              createdBy: userId,
              type: type,
              budget: budget,
              eventDate: eventDate,
              isShared: isShared,
              items: items ?? [], // 🆕 העברת פריטים
              createdFromTemplate: items != null && items.isNotEmpty,
            );

      await _repository.saveList(newList, householdId);
      await loadLists();
      debugPrint('✅ createList: רשימה "$name" נוצרה בהצלחה!');
      return newList;
    } catch (e) {
      debugPrint('❌ createList: שגיאה - $e');
      _errorMessage = 'שגיאה ביצירת רשימה "$name": ${e.toString()}';
      notifyListeners();
      rethrow;
    }
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
      debugPrint('❌ deleteList: householdId לא נמצא');
      throw Exception('❌ householdId לא נמצא');
    }

    debugPrint('🗑️ deleteList: מוחק רשימה $id');
    _errorMessage = null;

    try {
      await _repository.deleteList(id, householdId);
      await loadLists();
      debugPrint('✅ deleteList: רשימה $id נמחקה בהצלחה');
    } catch (e) {
      debugPrint('❌ deleteList: שגיאה - $e');
      _errorMessage = 'שגיאה במחיקת רשימה $id: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
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
      debugPrint('❌ restoreList: householdId לא נמצא');
      throw Exception('❌ householdId לא נמצא');
    }

    debugPrint('↩️ restoreList: משחזר רשימה ${list.id}');
    await _repository.saveList(list, householdId);
    await loadLists();
    debugPrint('✅ restoreList: רשימה ${list.id} שוחזרה');
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
      debugPrint('❌ updateList: householdId לא נמצא');
      throw Exception('❌ householdId לא נמצא');
    }

    debugPrint('📝 updateList: מעדכן רשימה ${updated.id}');
    _errorMessage = null;

    try {
      await _repository.saveList(updated, householdId);
      await loadLists();
      debugPrint('✅ updateList: רשימה ${updated.id} עודכנה בהצלחה');
    } catch (e) {
      debugPrint('❌ updateList: שגיאה - $e');
      _errorMessage = 'שגיאה בעדכון רשימה ${updated.id}: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
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
    debugPrint('➕ addItemToList: מוסיף פריט "${item.name}" לרשימה $listId');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ addItemToList: רשימה $listId לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    final updatedList = list.withItemAdded(item);
    await updateList(updatedList);
    debugPrint('✅ addItemToList: פריט "${item.name}" נוסף');
  }

  // === Remove Item From List ===
  Future<void> removeItemFromList(String listId, int index) async {
    debugPrint('🗑️ removeItemFromList: מוחק פריט #$index מרשימה $listId');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ removeItemFromList: רשימה $listId לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    final updatedList = list.withItemRemoved(index);
    await updateList(updatedList);
    debugPrint('✅ removeItemFromList: פריט #$index הוסר');
  }

  // === Update Item At Index ===
  Future<void> updateItemAt(
    String listId,
    int index,
    ReceiptItem Function(ReceiptItem) updateFn,
  ) async {
    debugPrint('📝 updateItemAt: מעדכן פריט #$index ברשימה $listId');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ updateItemAt: רשימה $listId לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    if (index < 0 || index >= list.items.length) {
      debugPrint('❌ updateItemAt: אינדקס לא חוקי $index');
      throw Exception('אינדקס לא חוקי: $index');
    }

    final updatedItem = updateFn(list.items[index]);
    final newItems = List<ReceiptItem>.from(list.items);
    newItems[index] = updatedItem;

    final updatedList = list.copyWith(items: newItems);
    await updateList(updatedList);
    debugPrint('✅ updateItemAt: פריט #$index עודכן');
  }

  // === Toggle All Items Checked ===
  Future<void> toggleAllItemsChecked(String listId, bool isChecked) async {
    debugPrint('✔️ toggleAllItemsChecked: מסמן הכל = $isChecked ברשימה $listId');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ toggleAllItemsChecked: רשימה $listId לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    final newItems = list.items.map((item) {
      return item.copyWith(isChecked: isChecked);
    }).toList();

    final updatedList = list.copyWith(items: newItems);
    await updateList(updatedList);
    debugPrint('✅ toggleAllItemsChecked: ${newItems.length} פריטים עודכנו');
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
    debugPrint('🔄 updateListStatus: משנה סטטוס ל-$newStatus (רשימה $listId)');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ updateListStatus: רשימה $listId לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    final updatedList = list.copyWith(status: newStatus);
    await updateList(updatedList);
    debugPrint('✅ updateListStatus: סטטוס עודכן ל-$newStatus');
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
    debugPrint('🗑️ ShoppingListsProvider.dispose()');
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }
    super.dispose();
  }
}
