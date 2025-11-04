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
import '../models/unified_list_item.dart';
import '../models/enums/item_type.dart';
import '../models/active_shopper.dart';
import '../repositories/shopping_lists_repository.dart';
import '../repositories/receipt_repository.dart';
import 'user_context.dart';

class ShoppingListsProvider with ChangeNotifier {
  final ShoppingListsRepository _repository;
  final ReceiptRepository _receiptRepository;
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
    required ReceiptRepository receiptRepository,
  })  : _repository = repository,
        _receiptRepository = receiptRepository;

  // === Getters ===
  List<ShoppingList> get lists => List.unmodifiable(_lists);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isEmpty => _lists.isEmpty;
  
  /// Repository access for services
  ShoppingListsRepository get repository => _repository;

  /// רשימות פעילות בלבד (לא הושלמו)
  List<ShoppingList> get activeLists => _lists
      .where((list) => list.status == ShoppingList.statusActive)
      .toList();

  /// רשימות שהושלמו (היסטוריה)
  List<ShoppingList> get completedLists => _lists
      .where((list) => list.status == ShoppingList.statusCompleted)
      .toList();

  /// רשימות מ-N ימים אחרונים
  List<ShoppingList> getRecentLists(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _lists
        .where((list) => list.updatedDate.isAfter(cutoff))
        .toList();
  }

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
    
    // 🔄 קריאה ידנית לטעינה ראשונית (listener לא מופעל אוטומטית בפעם הראשונה)
    _onUserChanged();
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
      
      // ✅ טען רשימות רק אם יש household_id חדש
      if (_userContext?.isLoggedIn == true && newHouseholdId != null) {
        loadLists();
      }
    } else {
      debugPrint('⏭️ _onUserChanged: אותו household_id, מדלג');
    }
  }

  void _initialize() {
    final householdId = _userContext?.user?.householdId;
    
    if (_userContext?.isLoggedIn == true && householdId != null) {
      // ⏭️ אל תגדיר _currentHouseholdId כאן! _onUserChanged() יטפל בזה
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
    List<UnifiedListItem>? items, // 🆕 פריטים אופציונליים (UnifiedListItem)
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
  Future<void> addItemToList(String listId, String name, int quantity, String unit) async {
    debugPrint('➕ addItemToList: מוסיף פריט "$name" לרשימה $listId');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ addItemToList: רשימה $listId לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    // יצירת UnifiedListItem חדש (מוצר)
    final item = UnifiedListItem.product(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: 0.0,
      isChecked: false,
    );
    
    final updatedList = list.withItemAdded(item);
    await updateList(updatedList);
    debugPrint('✅ addItemToList: פריט "$name" נוסף');
  }

  // === 🆕 Add UnifiedListItem (Product or Task) ===
  /// הוספת UnifiedListItem כללי (מוצר או משימה)
  /// 
  /// Example:
  /// ```dart
  /// // הוספת מוצר
  /// final product = UnifiedListItem.product(
  ///   id: uuid.v4(),
  ///   name: 'חלב',
  ///   quantity: 2,
  ///   unitPrice: 6.90,
  ///   unit: 'יח\',
  /// );
  /// await provider.addUnifiedItem(listId, product);
  /// 
  /// // הוספת משימה
  /// final task = UnifiedListItem.task(
  ///   id: uuid.v4(),
  ///   name: 'להזמין עוגה',
  ///   dueDate: DateTime(2025, 11, 15),
  ///   priority: 'high',
  /// );
  /// await provider.addUnifiedItem(listId, task);
  /// ```
  Future<void> addUnifiedItem(String listId, UnifiedListItem item) async {
    debugPrint('➕ addUnifiedItem: מוסיף ${item.type == ItemType.product ? "מוצר" : "משימה"} "${item.name}" לרשימה $listId');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ addUnifiedItem: רשימה $listId לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    final updatedList = list.withItemAdded(item);
    await updateList(updatedList);
    debugPrint('✅ addUnifiedItem: ${item.type == ItemType.product ? "מוצר" : "משימה"} "${item.name}" נוסף');
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
    UnifiedListItem Function(UnifiedListItem) updateFn,
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
    final newItems = List<UnifiedListItem>.from(list.items);
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

  /// מחזיר פריטים שלא נקנו מרשימה
  /// 
  /// Example:
  /// ```dart
  /// final unpurchased = provider.getUnpurchasedItems(listId);
  /// ```
  List<UnifiedListItem> getUnpurchasedItems(String listId) {
    final list = getById(listId);
    if (list == null) {
      debugPrint('⚠️ getUnpurchasedItems: רשימה $listId לא נמצאה');
      return [];
    }

    return list.items.where((item) => !item.isChecked).toList();
  }

  /// מסיימת רשימה כהושלמה
  Future<void> completeList(String listId) async {
    await updateListStatus(listId, ShoppingList.statusCompleted);
  }

  /// מפעילה רשימה
  Future<void> activateList(String listId) async {
    await updateListStatus(listId, ShoppingList.statusActive);
  }

  /// מוסיף פריטים לרשימה הבאה (אוטומטי)
  /// 
  /// Example:
  /// ```dart
  /// final unpurchased = provider.getUnpurchasedItems(listId);
  /// await provider.addToNextList(unpurchased);
  /// ```
  Future<void> addToNextList(List<UnifiedListItem> items) async {
    debugPrint('🔄 addToNextList: מעביר ${items.length} פריטים לרשימה הבאה');
    
    if (items.isEmpty) {
      debugPrint('   ⏭️ אין פריטים להעביר');
      return;
    }

    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;
    
    if (userId == null || householdId == null) {
      debugPrint('❌ addToNextList: משתמש לא מחובר');
      throw Exception('❌ משתמש לא מחובר');
    }

    _errorMessage = null;

    try {
      // מצא רשימה פעילה קיימת (לא "קניות כלליות")
      final existingList = activeLists.firstWhere(
        (list) => list.name != 'קניות כלליות',
        orElse: () {
          // אין רשימה פעילה → צור חדשה
          return ShoppingList.newList(
            id: '',
            name: '',
            createdBy: userId,
          );
        },
      );

      if (existingList.id.isEmpty) {
        // צור רשימה חדשה "קניות כלליות"
        debugPrint('   ➕ יוצר רשימה חדשה "קניות כלליות"');
        await createList(
          name: 'קניות כלליות',
          type: ShoppingList.typeSuper,
          items: items,
        );
        debugPrint('✅ addToNextList: רשימה חדשה נוצרה עם ${items.length} פריטים');
      } else {
        // הוסף לרשימה קיימת
        debugPrint('   📝 מוסיף ל"${existingList.name}"');
        final updatedItems = [...existingList.items, ...items];
        final updatedList = existingList.copyWith(items: updatedItems);
        await updateList(updatedList);
        debugPrint('✅ addToNextList: ${items.length} פריטים הוספו ל"${existingList.name}"');
      }
    } catch (e) {
      debugPrint('❌ addToNextList: שגיאה - $e');
      _errorMessage = 'שגיאה בהוספת פריטים לרשימה הבאה: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // ==========================================
  // 🆕 Collaborative Shopping Methods
  // ==========================================

  /// מתחיל קנייה משותפת - רק מי שמתחיל הופך ל-Starter
  /// 
  /// Example:
  /// ```dart
  /// await provider.startCollaborativeShopping(listId, userId);
  /// ```
  Future<void> startCollaborativeShopping(String listId, String userId) async {
    debugPrint('🛒 startCollaborativeShopping: מתחיל קנייה (list: $listId, user: $userId)');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ startCollaborativeShopping: רשימה לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    // בדוק שאין כבר קנייה פעילה
    if (list.isBeingShopped) {
      debugPrint('⚠️ startCollaborativeShopping: יש כבר קנייה פעילה');
      throw Exception('יש כבר קנייה פעילה ברשימה הזו');
    }

    _errorMessage = null;

    try {
      // צור Starter
      final starter = ActiveShopper.starter(userId: userId);
      
      // עדכן רשימה
      final updatedList = list.copyWith(
        activeShoppers: [starter],
        updatedDate: DateTime.now(),
      );

      await updateList(updatedList);
      debugPrint('✅ startCollaborativeShopping: קנייה התחילה!');
    } catch (e) {
      debugPrint('❌ startCollaborativeShopping: שגיאה - $e');
      _errorMessage = 'שגיאה בהתחלת קנייה: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// מצטרף לקנייה משותפת קיימת - הופך ל-Helper
  /// 
  /// Example:
  /// ```dart
  /// await provider.joinCollaborativeShopping(listId, userId);
  /// ```
  Future<void> joinCollaborativeShopping(String listId, String userId) async {
    debugPrint('🤝 joinCollaborativeShopping: מצטרף לקנייה (list: $listId, user: $userId)');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ joinCollaborativeShopping: רשימה לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    // בדוק שיש קנייה פעילה
    if (!list.isBeingShopped) {
      debugPrint('⚠️ joinCollaborativeShopping: אין קנייה פעילה');
      throw Exception('אין קנייה פעילה ברשימה הזו');
    }

    // בדוק שהמשתמש לא כבר קונה
    if (list.isUserShopping(userId)) {
      debugPrint('⚠️ joinCollaborativeShopping: המשתמש כבר קונה');
      throw Exception('אתה כבר קונה ברשימה הזו');
    }

    _errorMessage = null;

    try {
      // צור Helper
      final helper = ActiveShopper.helper(userId: userId);
      
      // הוסף לרשימת קונים
      final updatedList = list.copyWith(
        activeShoppers: [...list.activeShoppers, helper],
        updatedDate: DateTime.now(),
      );

      await updateList(updatedList);
      debugPrint('✅ joinCollaborativeShopping: הצטרף בהצלחה!');
    } catch (e) {
      debugPrint('❌ joinCollaborativeShopping: שגיאה - $e');
      _errorMessage = 'שגיאה בהצטרפות לקנייה: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// עוזב קנייה משותפת - מסמן את עצמו כלא פעיל
  /// 
  /// Example:
  /// ```dart
  /// await provider.leaveCollaborativeShopping(listId, userId);
  /// ```
  Future<void> leaveCollaborativeShopping(String listId, String userId) async {
    debugPrint('👋 leaveCollaborativeShopping: עוזב קנייה (list: $listId, user: $userId)');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ leaveCollaborativeShopping: רשימה לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    _errorMessage = null;

    try {
      // מצא את הקונה ושנה isActive ל-false
      final updatedShoppers = list.activeShoppers.map((shopper) {
        if (shopper.userId == userId) {
          return shopper.copyWith(isActive: false);
        }
        return shopper;
      }).toList();

      final updatedList = list.copyWith(
        activeShoppers: updatedShoppers,
        updatedDate: DateTime.now(),
      );

      await updateList(updatedList);
      debugPrint('✅ leaveCollaborativeShopping: עזב בהצלחה!');
    } catch (e) {
      debugPrint('❌ leaveCollaborativeShopping: שגיאה - $e');
      _errorMessage = 'שגיאה ביציאה מקנייה: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// מסמן פריט כנרכש + רושם מי סימן ומתי
  /// 
  /// Example:
  /// ```dart
  /// await provider.markItemAsChecked(listId, 0, userId);
  /// ```
  Future<void> markItemAsChecked(
    String listId,
    int itemIndex,
    String userId,
  ) async {
    debugPrint('✓ markItemAsChecked: מסמן פריט #$itemIndex (list: $listId, user: $userId)');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ markItemAsChecked: רשימה לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    // בדוק שהמשתמש קונה
    if (!list.isUserShopping(userId)) {
      debugPrint('⚠️ markItemAsChecked: המשתמש לא קונה');
      throw Exception('אתה לא קונה ברשימה הזו');
    }

    _errorMessage = null;

    try {
      // עדכן את הפריט
      await updateItemAt(listId, itemIndex, (item) {
        return item.copyWith(
          isChecked: true,
          // TODO: checkedBy + checkedAt יתווספו ב-UnifiedListItem
        );
      });

      debugPrint('✅ markItemAsChecked: פריט #$itemIndex סומן!');
    } catch (e) {
      debugPrint('❌ markItemAsChecked: שגיאה - $e');
      _errorMessage = 'שגיאה בסימון פריט: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// מעדכן סטטוס פריט (לשימוש ב-ActiveShoppingScreen)
  /// מקבל ShoppingItemStatus ומתרגם ל-isChecked
  /// 
  /// Example:
  /// ```dart
  /// await provider.updateItemStatus(listId, itemId, ShoppingItemStatus.purchased);
  /// ```
  Future<void> updateItemStatus(
    String listId,
    String itemId,
    dynamic status, // ShoppingItemStatus or any status object
  ) async {
    debugPrint('📝 updateItemStatus: מעדכן פריט $itemId (list: $listId, status: $status)');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ updateItemStatus: רשימה לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    // מצא את האינדקס של הפריט
    final itemIndex = list.items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      debugPrint('❌ updateItemStatus: פריט לא נמצא');
      throw Exception('פריט $itemId לא נמצא');
    }

    _errorMessage = null;

    try {
      // תרגם status ל-isChecked
      // אם הסטטוס הוא purchased → סמן כנבחר
      // במקרים אחרים, השאר את isChecked כמו שהוא (הסטטוס נשמר במקומי בלבד)
      final statusString = status.toString();
      final isChecked = statusString.contains('purchased');

      await updateItemAt(listId, itemIndex, (item) {
        return item.copyWith(isChecked: isChecked);
      });

      debugPrint('✅ updateItemStatus: פריט $itemId עודכן (isChecked: $isChecked)');
    } catch (e) {
      debugPrint('❌ updateItemStatus: שגיאה - $e');
      _errorMessage = 'שגיאה בעדכון סטטוס פריט: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// מסיים קנייה משותפת - רק ה-Starter יכול!
  /// יוצר קבלה וירטואלית מכל הפריטים המסומנים
  /// 
  /// Example:
  /// ```dart
  /// await provider.finishCollaborativeShopping(listId, userId);
  /// ```
  Future<void> finishCollaborativeShopping(String listId, String userId) async {
    debugPrint('🏁 finishCollaborativeShopping: מסיים קנייה (list: $listId, user: $userId)');
    final list = getById(listId);
    if (list == null) {
      debugPrint('❌ finishCollaborativeShopping: רשימה לא נמצאה');
      throw Exception('רשימה $listId לא נמצאה');
    }

    // בדוק שהמשתמש יכול לסיים (רק Starter)
    if (!list.canUserFinish(userId)) {
      debugPrint('⚠️ finishCollaborativeShopping: רק מי שהתחיל יכול לסיים');
      throw Exception('רק מי שהתחיל את הקנייה יכול לסיים');
    }

    _errorMessage = null;

    try {
      // 1. סמן את כל הקונים כלא פעילים
      final inactiveShoppers = list.activeShoppers.map((shopper) {
        return shopper.copyWith(isActive: false);
      }).toList();

      // 2. מצא פריטים מסומנים (רק Products)
      final checkedItems = list.items
          .where((item) => item.isChecked && item.type == ItemType.product)
          .map((item) => ReceiptItem(
                id: item.id,
                name: item.name,
                quantity: item.quantity ?? 0,
                unitPrice: item.unitPrice ?? 0.0,
                unit: item.unit,
                barcode: item.barcode,
                isChecked: item.isChecked,
                checkedBy: null, // UnifiedListItem לא מחזיק checkedBy
                checkedAt: null,
              ))
          .toList();
      debugPrint('   📦 נמצאו ${checkedItems.length} פריטים מסומנים (מוצרים)');

      // 3. צור קבלה וירטואלית
      if (checkedItems.isNotEmpty) {
        final householdId = _userContext?.user?.householdId;
        if (householdId == null) {
          throw Exception('household_id לא נמצא');
        }

        final receipt = Receipt.virtual(
          linkedShoppingListId: listId,
          createdBy: userId,
          householdId: householdId,
          storeName: list.name,
          items: checkedItems,
          date: DateTime.now(),
        );

        // שמור קבלה ב-ReceiptRepository
        await _receiptRepository.saveReceipt(receipt: receipt, householdId: householdId);
        debugPrint('   📄 קבלה וירטואלית נוצרה ונשמרה: ${receipt.id}');
      }

      // 4. עדכן רשימה: סטטוס + inactiveShoppers
      final updatedList = list.copyWith(
        status: ShoppingList.statusCompleted,
        activeShoppers: inactiveShoppers,
        updatedDate: DateTime.now(),
      );

      await updateList(updatedList);
      debugPrint('✅ finishCollaborativeShopping: קנייה הסתיימה!');
    } catch (e) {
      debugPrint('❌ finishCollaborativeShopping: שגיאה - $e');
      _errorMessage = 'שגיאה בסיום קנייה: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// מנקה sessions נטושים (6+ שעות)
  /// 
  /// Example:
  /// ```dart
  /// await provider.cleanupAbandonedSessions();
  /// ```
  Future<void> cleanupAbandonedSessions() async {
    debugPrint('🧹 cleanupAbandonedSessions: בודק sessions נטושים');
    
    final timedOutLists = _lists.where((list) => list.isShoppingTimedOut).toList();
    
    if (timedOutLists.isEmpty) {
      debugPrint('   ✓ אין sessions נטושים');
      return;
    }

    debugPrint('   ⚠️ נמצאו ${timedOutLists.length} sessions נטושים');
    _errorMessage = null;

    try {
      for (final list in timedOutLists) {
        debugPrint('   🧹 מנקה session של רשימה ${list.id}');
        
        // סמן את כל הקונים כלא פעילים
        final inactiveShoppers = list.activeShoppers.map((shopper) {
          return shopper.copyWith(isActive: false);
        }).toList();

        final updatedList = list.copyWith(
          activeShoppers: inactiveShoppers,
          updatedDate: DateTime.now(),
        );

        await updateList(updatedList);
      }

      debugPrint('✅ cleanupAbandonedSessions: ${timedOutLists.length} sessions נוקו!');
    } catch (e) {
      debugPrint('❌ cleanupAbandonedSessions: שגיאה - $e');
      _errorMessage = 'שגיאה בניקוי sessions: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
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
