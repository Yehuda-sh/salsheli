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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../l10n/app_strings.dart';
import '../services/analytics_service.dart';
import '../models/active_shopper.dart';
import '../models/enums/item_type.dart';
import '../models/enums/shopping_item_status.dart';
import '../models/enums/user_role.dart';
import '../models/receipt.dart';
import '../models/selected_contact.dart';
import '../models/shopping_list.dart';
import '../models/unified_list_item.dart';
import '../repositories/firebase_shopping_lists_repository.dart';
import '../repositories/receipt_repository.dart';
import '../repositories/shopping_lists_repository.dart';
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
  String? _currentHouseholdId; // מעקב אחרי household_id נוכחי
  String? _currentUserId; // 🆕 מעקב אחרי user_id נוכחי (לזיהוי login/logout)

  // 🔄 Real-time updates
  StreamSubscription<List<ShoppingList>>? _listsSubscription;
  String? _watchedUserId; // מניעת restart מיותר של ה-Stream
  bool _useRealTimeUpdates = true; // ניתן לכבות אם יש בעיות

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

  // === חישוב הרשאות משתמש ===

  /// מעשיר רשימות עם currentUserRole לפי המשתמש הנוכחי
  List<ShoppingList> _enrichListsWithUserRole(List<ShoppingList> lists) {
    final currentUserId = _userContext?.user?.id;
    if (currentUserId == null) return lists;

    return lists.map((list) {
      final role = _calculateUserRole(list, currentUserId);
      return list.copyWith(currentUserRole: role);
    }).toList();
  }

  /// מחשב את ה-role של משתמש ברשימה מסוימת
  UserRole _calculateUserRole(ShoppingList list, String userId) {
    // 🆕 Use ShoppingList's built-in method (O(1) Map lookup)
    final role = list.getUserRole(userId);

    // ברירת מחדל - Viewer (אם נמצא ברשימה אבל לא ב-sharedUsers)
    return role ?? UserRole.viewer;
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
    // ⚠️ חייב להיות ב-microtask כי updateUserContext נקרא מ-ProxyProvider במהלך build
    Future.microtask(_onUserChanged);
  }

  void _onUserChanged() {
    final newHouseholdId = _userContext?.user?.householdId;
    final newUserId = _userContext?.user?.id;

    // 🔍 בדוק אם המשתמש או משק הבית השתנו
    // ✅ חשוב לבדוק גם userId כי משתמש יכול להתחלף באותו household
    final userChanged = newUserId != _currentUserId;
    final householdChanged = newHouseholdId != _currentHouseholdId;

    if (userChanged || householdChanged) {
      if (kDebugMode && (userChanged || householdChanged)) {
        debugPrint('🔄 _onUserChanged: user=$userChanged, household=$householdChanged');
      }

      // נקה רשימות ישנות
      _lists = [];
      _errorMessage = null;
      _currentHouseholdId = newHouseholdId;
      _currentUserId = newUserId;

      // 🛑 עצור האזנה קודמת אם משתמש השתנה
      if (userChanged) {
        _stopWatchingLists();
      }

      // ✅ טען רשימות רק אם יש household_id חדש
      if (_userContext?.isLoggedIn == true && newHouseholdId != null && newUserId != null) {
        if (_useRealTimeUpdates) {
          _startWatchingLists(newUserId, newHouseholdId);
        } else {
          loadLists();
        }
      }
    }
  }

  /// 🔄 התחלת האזנה לשינויים בזמן אמת
  void _startWatchingLists(String userId, String householdId) {
    // אל תתחיל מחדש אם כבר מאזינים לאותו משתמש
    if (_watchedUserId == userId && _listsSubscription != null) {
      return;
    }

    if (kDebugMode) {
      debugPrint('🔄 _startWatchingLists: מתחיל להאזין לרשימות של $userId');
    }

    // ביטול subscription קודם
    _listsSubscription?.cancel();
    _watchedUserId = userId;
    _isLoading = true;
    notifyListeners();

    // התחלת האזנה
    _listsSubscription = _repository.watchLists(userId, householdId).listen(
      (fetchedLists) {
        // 🔑 חישוב currentUserRole לכל רשימה
        _lists = _enrichListsWithUserRole(fetchedLists);
        _lastUpdated = DateTime.now();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();

        if (kDebugMode) {
          debugPrint('📥 ShoppingListsProvider: קיבלנו ${_lists.length} רשימות בזמן אמת');
        }
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('❌ _startWatchingLists: שגיאה - $error');
        }
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// 🛑 עצירת האזנה לשינויים
  void _stopWatchingLists() {
    _listsSubscription?.cancel();
    _listsSubscription = null;
    _watchedUserId = null;
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
      return;
    }

    // 🛡️ Guard: אל תטען אם זה לא ה-household הנוכחי
    if (_currentHouseholdId != null && householdId != _currentHouseholdId) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _userContext?.user?.id;
      if (userId == null) return;

      final fetchedLists = await _repository.fetchLists(userId, householdId);
      // 🔑 חישוב currentUserRole לכל רשימה
      _lists = _enrichListsWithUserRole(fetchedLists);
      _lastUpdated = DateTime.now();
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('❌ loadLists: שגיאה - $e');
      }
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
    if (kDebugMode) {
      debugPrint('🔄 retry: מנסה שוב לטעון רשימות');
    }
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
    if (kDebugMode) {
      debugPrint('🧹 clearAll: מנקה state');
    }
    _stopWatchingLists();
    _lists = [];
    _errorMessage = null;
    _isLoading = false;
    _lastUpdated = null;
    _currentHouseholdId = null;
    _currentUserId = null; // 🆕 נקה גם user_id
    notifyListeners();
  }

  /// יוצר רשימת קניות חדשה
  ///
  /// Example:
  /// ```dart
  /// final list = await provider.createList(
  ///   name: 'קניות שבועיות',
  ///   type: ShoppingList.typeSupermarket,
  ///   budget: 500.0,
  ///   eventDate: DateTime(2025, 10, 15), // אירוע ב-15/10
  ///   items: [...], // 🆕 פריטים מתבנית
  ///   sharedContacts: [...], // 🆕 אנשי קשר לשיתוף ספציפי
  /// );
  /// ```
  Future<ShoppingList> createList({
    required String name,
    String type = ShoppingList.typeSupermarket,
    double? budget,
    DateTime? eventDate,
    bool isShared = false,
    bool isPrivate = true, // 🆕 ברירת מחדל: רשימה אישית
    List<UnifiedListItem>? items, // 🆕 פריטים אופציונליים (UnifiedListItem)
    String? templateId, // 🆕 מזהה תבנית
    List<SelectedContact>? sharedContacts, // 🆕 אנשי קשר לשיתוף ספציפי
    String? eventMode, // 🆕 מצב אירוע (who_brings/shopping/tasks)
  }) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;

    if (userId == null || householdId == null) {
      if (kDebugMode) {
        debugPrint('❌ createList: משתמש לא מחובר');
      }
      throw Exception('❌ משתמש לא מחובר');
    }

    // 🛡️ בדיקת מגבלת רשימות פעילות
    if (activeLists.length >= kMaxActiveListsPerUser) {
      if (kDebugMode) {
        debugPrint('❌ createList: הגעת למקסימום $kMaxActiveListsPerUser רשימות פעילות');
      }
      throw Exception(AppStrings.shopping.maxListsReached(kMaxActiveListsPerUser));
    }

    if (kDebugMode) {
      debugPrint('➕ createList: "$name" (סוג: $type, תקציב: $budget, תאריך: $eventDate)');
      debugPrint('   🆕 פריטים: ${items?.length ?? 0}, תבנית: ${templateId ?? "ללא"}');
      if (sharedContacts != null && sharedContacts.isNotEmpty) {
        debugPrint('   👥 שיתוף עם: ${sharedContacts.length} אנשי קשר');
      }
    }
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
              isPrivate: isPrivate,
              eventMode: eventMode, // 🆕 מצב אירוע
            )
          : ShoppingList.newList(
              id: _uuid.v4(),
              name: name,
              createdBy: userId,
              type: type,
              budget: budget,
              eventDate: eventDate,
              isShared: isShared,
              isPrivate: isPrivate,
              items: items ?? [], // 🆕 העברת פריטים
              createdFromTemplate: items != null && items.isNotEmpty,
              eventMode: eventMode, // 🆕 מצב אירוע
            );

      await _repository.saveList(newList, userId, householdId);

      // 🆕 הוספת משתמשים משותפים (רק רשומים - pending מטופל ב-UI)
      if (sharedContacts != null && sharedContacts.isNotEmpty && isPrivate) {
        final firebaseRepo = _repository as FirebaseShoppingListsRepository;

        for (final contact in sharedContacts) {
          if (!contact.isPending && contact.userId != null) {
            // משתמש רשום → הוסף ישירות
            await firebaseRepo.addSharedUserToPrivateList(
              ownerId: userId,
              listId: newList.id,
              sharedUserId: contact.userId!,
              role: contact.role.name,
              userName: contact.name,
              userEmail: contact.email,
            );
            if (kDebugMode) {
              debugPrint('   ✅ נוסף משתמש: ${contact.displayName} (${contact.role.hebrewName})');
            }
          }
        }
      }

      await loadLists();
      if (kDebugMode) {
        debugPrint('✅ createList: רשימה "$name" נוצרה בהצלחה!');
      }

      // 📊 Analytics: track list creation (fire and forget)
      unawaited(AnalyticsService.instance.logCreateList(
        listType: type,
        isShared: isShared || !isPrivate,
      ));

      return newList;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ createList: שגיאה - $e');
      }
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
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint('❌ deleteList: userId לא נמצא');
      }
      throw Exception('❌ userId לא נמצא');
    }

    // מצא את הרשימה כדי לדעת אם היא פרטית או משותפת
    final list = getById(id);
    final isPrivate = list?.isPrivate ?? true;

    if (kDebugMode) {
      debugPrint('🗑️ deleteList: מוחק רשימה $id [isPrivate: $isPrivate]');
    }
    _errorMessage = null;

    try {
      await _repository.deleteList(id, userId, householdId, isPrivate);
      await loadLists();
      if (kDebugMode) {
        debugPrint('✅ deleteList: רשימה $id נמחקה בהצלחה');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ deleteList: שגיאה - $e');
      }
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
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint('❌ restoreList: userId לא נמצא');
      }
      throw Exception('❌ userId לא נמצא');
    }

    if (kDebugMode) {
      debugPrint('↩️ restoreList: משחזר רשימה ${list.id}');
    }
    await _repository.saveList(list, userId, householdId);
    await loadLists();
    if (kDebugMode) {
      debugPrint('✅ restoreList: רשימה ${list.id} שוחזרה');
    }
  }

  /// מעדכן רשימה קיימת
  ///
  /// Example:
  /// ```dart
  /// await provider.updateList(updatedList);
  /// ```
  Future<void> updateList(ShoppingList updated) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint('❌ updateList: userId לא נמצא');
      }
      throw Exception('❌ userId לא נמצא');
    }

    if (kDebugMode) {
      debugPrint('📝 updateList: מעדכן רשימה ${updated.id}');
    }
    _errorMessage = null;

    try {
      await _repository.saveList(updated, userId, householdId);
      await loadLists();
      if (kDebugMode) {
        debugPrint('✅ updateList: רשימה ${updated.id} עודכנה בהצלחה');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ updateList: שגיאה - $e');
      }
      _errorMessage = 'שגיאה בעדכון רשימה ${updated.id}: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// משתף רשימה פרטית למשק הבית
  ///
  /// מעביר רשימה מ-private_lists ל-shared_lists
  ///
  /// Example:
  /// ```dart
  /// await provider.shareListToHousehold(listId);
  /// ```
  Future<void> shareListToHousehold(String listId) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;

    if (userId == null) {
      if (kDebugMode) {
        debugPrint('❌ shareListToHousehold: userId לא נמצא');
      }
      throw Exception('❌ userId לא נמצא');
    }
    if (householdId == null) {
      if (kDebugMode) {
        debugPrint('❌ shareListToHousehold: householdId לא נמצא - משתמש לא במשפחה');
      }
      throw Exception('❌ לא ניתן לשתף רשימה ללא משק בית');
    }

    if (kDebugMode) {
      debugPrint('🔄 shareListToHousehold: משתף רשימה $listId למשק בית $householdId');
    }
    _errorMessage = null;

    try {
      await _repository.shareListToHousehold(listId, userId, householdId);
      await loadLists();
      if (kDebugMode) {
        debugPrint('✅ shareListToHousehold: רשימה $listId שותפה בהצלחה');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ shareListToHousehold: שגיאה - $e');
      }
      _errorMessage = 'שגיאה בשיתוף רשימה $listId: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // === Get List By ID ===
  ShoppingList? getById(String id) {
    return _lists.where((list) => list.id == id).firstOrNull;
  }

  // === Add Item To List ===
  Future<void> addItemToList(String listId, String name, int quantity, String unit, {String? category}) async {
    if (kDebugMode) {
      debugPrint('➕ addItemToList: מוסיף פריט "$name" לרשימה $listId (קטגוריה: $category)');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ addItemToList: רשימה $listId לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    // 🚫 בדיקת הגבלת פריטים
    if (list.items.length >= kMaxItemsPerList) {
      if (kDebugMode) {
        debugPrint('❌ addItemToList: הגעת למקסימום $kMaxItemsPerList פריטים');
      }
      throw Exception(AppStrings.shopping.maxItemsReached(kMaxItemsPerList));
    }

    // יצירת UnifiedListItem חדש (מוצר)
    final item = UnifiedListItem.product(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: 0.0,
      category: category,
    );

    final updatedList = list.withItemAdded(item);
    await updateList(updatedList);
    if (kDebugMode) {
      debugPrint('✅ addItemToList: פריט "$name" נוסף עם קטגוריה "$category"');
    }

    // 📊 Analytics: track item addition
    unawaited(AnalyticsService.instance.logAddItem(
      category: category ?? 'unknown',
      isFromCatalog: false, // addItemToList is manual entry
    ));
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
    if (kDebugMode) {
      debugPrint('➕ addUnifiedItem: מוסיף ${item.type == ItemType.product ? "מוצר" : "משימה"} "${item.name}" לרשימה $listId');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ addUnifiedItem: רשימה $listId לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    // 🚫 בדיקת הגבלת פריטים
    if (list.items.length >= kMaxItemsPerList) {
      if (kDebugMode) {
        debugPrint('❌ addUnifiedItem: הגעת למקסימום $kMaxItemsPerList פריטים');
      }
      throw Exception(AppStrings.shopping.maxItemsReached(kMaxItemsPerList));
    }

    final updatedList = list.withItemAdded(item);
    await updateList(updatedList);
    if (kDebugMode) {
      debugPrint('✅ addUnifiedItem: ${item.type == ItemType.product ? "מוצר" : "משימה"} "${item.name}" נוסף');
    }

    // 📊 Analytics: track item addition (only for products)
    if (item.type == ItemType.product) {
      unawaited(AnalyticsService.instance.logAddItem(
        category: item.category ?? 'unknown',
        isFromCatalog: true, // addUnifiedItem typically comes from catalog
      ));
    }
  }

  // === Remove Item From List ===
  Future<void> removeItemFromList(String listId, int index) async {
    if (kDebugMode) {
      debugPrint('🗑️ removeItemFromList: מוחק פריט #$index מרשימה $listId');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ removeItemFromList: רשימה $listId לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    final updatedList = list.withItemRemoved(index);
    await updateList(updatedList);
    if (kDebugMode) {
      debugPrint('✅ removeItemFromList: פריט #$index הוסר');
    }
  }

  // === Update Item At Index ===
  Future<void> updateItemAt(
    String listId,
    int index,
    UnifiedListItem Function(UnifiedListItem) updateFn,
  ) async {
    if (kDebugMode) {
      debugPrint('📝 updateItemAt: מעדכן פריט #$index ברשימה $listId');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ updateItemAt: רשימה $listId לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    if (index < 0 || index >= list.items.length) {
      if (kDebugMode) {
        debugPrint('❌ updateItemAt: אינדקס לא חוקי $index');
      }
      throw Exception('אינדקס לא חוקי: $index');
    }

    final updatedItem = updateFn(list.items[index]);
    final newItems = List<UnifiedListItem>.from(list.items);
    newItems[index] = updatedItem;

    final updatedList = list.copyWith(items: newItems);
    await updateList(updatedList);
    if (kDebugMode) {
      debugPrint('✅ updateItemAt: פריט #$index עודכן');
    }
  }

  // === Update Item By ID ===
  /// עדכון פריט לפי ID (שימושי לרשימות "מי מביא")
  Future<void> updateItemById(String listId, UnifiedListItem updatedItem) async {
    if (kDebugMode) {
      debugPrint('📝 updateItemById: מעדכן פריט ${updatedItem.id} ברשימה $listId');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ updateItemById: רשימה $listId לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    final index = list.items.indexWhere((item) => item.id == updatedItem.id);
    if (index == -1) {
      if (kDebugMode) {
        debugPrint('❌ updateItemById: פריט ${updatedItem.id} לא נמצא');
      }
      throw Exception('פריט ${updatedItem.id} לא נמצא');
    }

    final newItems = List<UnifiedListItem>.from(list.items);
    newItems[index] = updatedItem;

    final updatedList = list.copyWith(items: newItems);
    await updateList(updatedList);
    if (kDebugMode) {
      debugPrint('✅ updateItemById: פריט ${updatedItem.id} עודכן');
    }
  }

  // === Toggle All Items Checked ===
  Future<void> toggleAllItemsChecked(String listId, bool isChecked) async {
    if (kDebugMode) {
      debugPrint('✔️ toggleAllItemsChecked: מסמן הכל = $isChecked ברשימה $listId');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ toggleAllItemsChecked: רשימה $listId לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    final newItems = list.items.map((item) {
      return item.copyWith(isChecked: isChecked);
    }).toList();

    final updatedList = list.copyWith(items: newItems);
    await updateList(updatedList);
    if (kDebugMode) {
      debugPrint('✅ toggleAllItemsChecked: ${newItems.length} פריטים עודכנו');
    }
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
    if (kDebugMode) {
      debugPrint('🔄 updateListStatus: משנה סטטוס ל-$newStatus (רשימה $listId)');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ updateListStatus: רשימה $listId לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    // 🛡️ בדיקת מגבלה כשמפעילים רשימה (מ-completed/archived ל-active)
    if (newStatus == ShoppingList.statusActive &&
        list.status != ShoppingList.statusActive &&
        activeLists.length >= kMaxActiveListsPerUser) {
      if (kDebugMode) {
        debugPrint('❌ updateListStatus: הגעת למקסימום $kMaxActiveListsPerUser רשימות פעילות');
      }
      throw Exception(AppStrings.shopping.maxListsReached(kMaxActiveListsPerUser));
    }

    final updatedList = list.copyWith(status: newStatus);
    await updateList(updatedList);
    if (kDebugMode) {
      debugPrint('✅ updateListStatus: סטטוס עודכן ל-$newStatus');
    }
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
      if (kDebugMode) {
        debugPrint('⚠️ getUnpurchasedItems: רשימה $listId לא נמצאה');
      }
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
  /// ✅ לוגיקה משופרת:
  /// 1. מחפש רשימה פעילה קיימת (כולל רשימת ברירת מחדל!)
  /// 2. אם אין → יוצר רשימה חדשה עם שם ברירת מחדל
  /// 3. מוסיף פריטים עם מניעת כפילויות
  ///
  /// Example:
  /// ```dart
  /// final unpurchased = provider.getUnpurchasedItems(listId);
  /// await provider.addToNextList(unpurchased);
  /// ```
  Future<void> addToNextList(List<UnifiedListItem> items) async {
    if (kDebugMode) {
      debugPrint('🔄 addToNextList: מעביר ${items.length} פריטים לרשימה הבאה');
    }

    if (items.isEmpty) {
      if (kDebugMode) {
        debugPrint('   ⏭️ אין פריטים להעביר');
      }
      return;
    }

    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;

    if (userId == null || householdId == null) {
      if (kDebugMode) {
        debugPrint('❌ addToNextList: משתמש לא מחובר');
      }
      throw Exception('❌ משתמש לא מחובר');
    }

    _errorMessage = null;

    try {
      final defaultListName = AppStrings.shopping.defaultShoppingListName;

      // ✅ לוגיקה משופרת: מחפש רשימה פעילה קיימת (כולל ברירת מחדל!)
      // עדיפות: 1) רשימת ברירת מחדל פעילה 2) רשימה אחרת פעילה 3) יצירה חדשה
      ShoppingList? targetList;

      // 1. חפש רשימת ברירת מחדל פעילה
      targetList = activeLists.where((list) => list.name == defaultListName).firstOrNull;

      // 2. אם אין, חפש רשימה אחרת פעילה
      targetList ??= activeLists.firstOrNull;

      if (targetList == null) {
        // 3. אין רשימות פעילות → צור רשימה חדשה
        if (kDebugMode) {
          debugPrint('   ➕ יוצר רשימה חדשה "$defaultListName"');
        }
        await createList(
          name: defaultListName,
          items: items,
        );
        if (kDebugMode) {
          debugPrint('✅ addToNextList: רשימה חדשה נוצרה עם ${items.length} פריטים');
        }
      } else {
        // הוסף לרשימה קיימת - עם בדיקת כפילויות
        if (kDebugMode) {
          debugPrint('   📝 מוסיף ל"${targetList.name}"');
        }

        // 🔧 מניעת כפילויות - בודק לפי id ושם
        final existingIds = targetList.items.map((i) => i.id).toSet();
        final existingNames = targetList.items
            .map((i) => i.name.toLowerCase())
            .toSet();

        final newItems = items.where((item) {
          // בדוק גם לפי id וגם לפי שם
          return !existingIds.contains(item.id) &&
                 !existingNames.contains(item.name.toLowerCase());
        }).toList();

        if (newItems.isEmpty) {
          if (kDebugMode) {
            debugPrint('   ⏭️ כל הפריטים כבר קיימים ברשימה');
          }
          return;
        }

        final updatedItems = [...targetList.items, ...newItems];
        final updatedList = targetList.copyWith(items: updatedItems);
        await updateList(updatedList);
        if (kDebugMode) {
          debugPrint('✅ addToNextList: ${newItems.length} פריטים הוספו ל"${targetList.name}" (${items.length - newItems.length} כפילויות סוננו)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ addToNextList: שגיאה - $e');
      }
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
    if (kDebugMode) {
      debugPrint('🛒 startCollaborativeShopping: מתחיל קנייה (list: $listId, user: $userId)');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ startCollaborativeShopping: רשימה לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    // בדוק שאין כבר קנייה פעילה
    if (list.isBeingShopped) {
      if (kDebugMode) {
        debugPrint('⚠️ startCollaborativeShopping: יש כבר קנייה פעילה');
      }
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
      if (kDebugMode) {
        debugPrint('✅ startCollaborativeShopping: קנייה התחילה!');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ startCollaborativeShopping: שגיאה - $e');
      }
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
    if (kDebugMode) {
      debugPrint('🤝 joinCollaborativeShopping: מצטרף לקנייה (list: $listId, user: $userId)');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ joinCollaborativeShopping: רשימה לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    // בדוק שיש קנייה פעילה
    if (!list.isBeingShopped) {
      if (kDebugMode) {
        debugPrint('⚠️ joinCollaborativeShopping: אין קנייה פעילה');
      }
      throw Exception('אין קנייה פעילה ברשימה הזו');
    }

    // בדוק שהמשתמש לא כבר קונה
    if (list.isUserShopping(userId)) {
      if (kDebugMode) {
        debugPrint('⚠️ joinCollaborativeShopping: המשתמש כבר קונה');
      }
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
      if (kDebugMode) {
        debugPrint('✅ joinCollaborativeShopping: הצטרף בהצלחה!');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ joinCollaborativeShopping: שגיאה - $e');
      }
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
    if (kDebugMode) {
      debugPrint('👋 leaveCollaborativeShopping: עוזב קנייה (list: $listId, user: $userId)');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ leaveCollaborativeShopping: רשימה לא נמצאה');
      }
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
      if (kDebugMode) {
        debugPrint('✅ leaveCollaborativeShopping: עזב בהצלחה!');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ leaveCollaborativeShopping: שגיאה - $e');
      }
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
    if (kDebugMode) {
      debugPrint('✓ markItemAsChecked: מסמן פריט #$itemIndex (list: $listId, user: $userId)');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ markItemAsChecked: רשימה לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    // בדוק שהמשתמש קונה
    if (!list.isUserShopping(userId)) {
      if (kDebugMode) {
        debugPrint('⚠️ markItemAsChecked: המשתמש לא קונה');
      }
      throw Exception('אתה לא קונה ברשימה הזו');
    }

    _errorMessage = null;

    try {
      // עדכן את הפריט
      await updateItemAt(listId, itemIndex, (item) {
        return item.copyWith(
          isChecked: true,
          checkedBy: userId,
          checkedAt: DateTime.now().toIso8601String(),
        );
      });

      if (kDebugMode) {
        debugPrint('✅ markItemAsChecked: פריט #$itemIndex סומן!');
      }

      // 📊 Analytics: track item purchased
      final isCollaborative = list.activeShoppers.where((s) => s.isActive).length > 1;
      unawaited(AnalyticsService.instance.logMarkPurchased(
        isCollaborative: isCollaborative,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ markItemAsChecked: שגיאה - $e');
      }
      _errorMessage = 'שגיאה בסימון פריט: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// מעדכן סטטוס פריט (לשימוש ב-ActiveShoppingScreen)
  /// מקבל ShoppingItemStatus ומתרגם ל-isChecked
  ///
  /// ✅ כולל early return אם אין שינוי אמיתי (חוסך writes ל-Firebase)
  ///
  /// Example:
  /// ```dart
  /// await provider.updateItemStatus(listId, itemId, ShoppingItemStatus.purchased);
  /// ```
  Future<void> updateItemStatus(
    String listId,
    String itemId,
    ShoppingItemStatus status,
  ) async {
    if (kDebugMode) {
      debugPrint('📝 updateItemStatus: מעדכן פריט $itemId (list: $listId, status: ${status.name})');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ updateItemStatus: רשימה לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    // מצא את האינדקס של הפריט
    final itemIndex = list.items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      if (kDebugMode) {
        debugPrint('❌ updateItemStatus: פריט לא נמצא');
      }
      throw Exception('פריט $itemId לא נמצא');
    }

    // ✅ תרגם status ל-isChecked (רק purchased = true)
    final shouldBeChecked = status == ShoppingItemStatus.purchased;
    final currentItem = list.items[itemIndex];

    // ✅ Early return: אם אין שינוי אמיתי, אל תכתוב לשרת
    if (currentItem.isChecked == shouldBeChecked) {
      if (kDebugMode) {
        debugPrint('⏭️ updateItemStatus: אין שינוי (isChecked כבר $shouldBeChecked)');
      }
      return;
    }

    _errorMessage = null;

    try {
      final userId = _userContext?.user?.id;

      await updateItemAt(listId, itemIndex, (item) {
        if (shouldBeChecked && userId != null) {
          // purchased → סמן כנבחר עם מי/מתי
          return item.copyWith(
            isChecked: true,
            checkedBy: userId,
            checkedAt: DateTime.now().toIso8601String(),
          );
        }
        // לא purchased → נקה את הסימון
        return item.copyWith(
          isChecked: false,
          checkedBy: null,
          checkedAt: null,
        );
      });

      if (kDebugMode) {
        debugPrint('✅ updateItemStatus: פריט $itemId עודכן (isChecked: $shouldBeChecked)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ updateItemStatus: שגיאה - $e');
      }
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
    if (kDebugMode) {
      debugPrint('🏁 finishCollaborativeShopping: מסיים קנייה (list: $listId, user: $userId)');
    }
    final list = getById(listId);
    if (list == null) {
      if (kDebugMode) {
        debugPrint('❌ finishCollaborativeShopping: רשימה לא נמצאה');
      }
      throw Exception('רשימה $listId לא נמצאה');
    }

    // בדוק שהמשתמש יכול לסיים (רק Starter)
    if (!list.canUserFinish(userId)) {
      if (kDebugMode) {
        debugPrint('⚠️ finishCollaborativeShopping: רק מי שהתחיל יכול לסיים');
      }
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
              ))
          .toList();
      if (kDebugMode) {
        debugPrint('   📦 נמצאו ${checkedItems.length} פריטים מסומנים (מוצרים)');
      }

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
        if (kDebugMode) {
          debugPrint('   📄 קבלה וירטואלית נוצרה ונשמרה: ${receipt.id}');
        }
      }

      // 4. עדכן רשימה: סטטוס + inactiveShoppers
      final updatedList = list.copyWith(
        status: ShoppingList.statusCompleted,
        activeShoppers: inactiveShoppers,
        updatedDate: DateTime.now(),
      );

      await updateList(updatedList);
      if (kDebugMode) {
        debugPrint('✅ finishCollaborativeShopping: קנייה הסתיימה!');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ finishCollaborativeShopping: שגיאה - $e');
      }
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
    if (kDebugMode) {
      debugPrint('🧹 cleanupAbandonedSessions: בודק sessions נטושים');
    }

    final timedOutLists = _lists.where((list) => list.isShoppingTimedOut).toList();

    if (timedOutLists.isEmpty) {
      if (kDebugMode) {
        debugPrint('   ✓ אין sessions נטושים');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('   ⚠️ נמצאו ${timedOutLists.length} sessions נטושים');
    }
    _errorMessage = null;

    try {
      for (final list in timedOutLists) {
        if (kDebugMode) {
          debugPrint('   🧹 מנקה session של רשימה ${list.id}');
        }

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

      if (kDebugMode) {
        debugPrint('✅ cleanupAbandonedSessions: ${timedOutLists.length} sessions נוקו!');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ cleanupAbandonedSessions: שגיאה - $e');
      }
      _errorMessage = 'שגיאה בניקוי sessions: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('🗑️ ShoppingListsProvider.dispose()');
    }
    _stopWatchingLists(); // 🔄 ביטול subscription לרשימות
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }
    super.dispose();
  }
}
