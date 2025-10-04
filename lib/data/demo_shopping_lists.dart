// 📄 File: lib/data/demo_shopping_lists.dart - VERSION 3.0
//
// ✅ שדרוגים:
// 1. טעינת מוצרים אמיתיים מ-assets/data/products.json
// 2. 7 רשימות מגוונות עם מוצרים אמיתיים
// 3. כולל type (super/pharmacy/other) ו-budget
// 4. סטטוסים שונים (active/completed/archived)
// 5. רשימות משותפות וסולו
// 6. תאריכים ריאליסטיים
//
// 🇮🇱 נתוני דמו לרשימות קניות (לפיתוח/בדיקות בלבד!)
// 🇬🇧 Demo shopping lists (dev/testing only)

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../api/entities/shopping_list.dart' as api;
import '../models/shopping_list.dart' as domain;
import '../models/receipt.dart';

/// Cache למוצרים שנטענו מה-JSON
List<Map<String, dynamic>>? _productsCache;

/// טעינת מוצרים מקובץ JSON
Future<List<Map<String, dynamic>>> _loadProducts() async {
  if (_productsCache != null) return _productsCache!;

  try {
    final jsonString = await rootBundle.loadString('assets/data/products.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _productsCache = jsonList.cast<Map<String, dynamic>>();
    return _productsCache!;
  } catch (e) {
    print('❌ Error loading products.json: $e');
    return [];
  }
}

/// בחירת מוצרים אקראיים לפי קטגוריה
Future<List<api.ApiShoppingListItem>> _getRandomItems({
  required int count,
  List<String>? categories,
  bool includeChecked = true,
}) async {
  final products = await _loadProducts();
  if (products.isEmpty) return [];

  // סינון לפי קטגוריות (אם צוין)
  var filtered = products;
  if (categories != null && categories.isNotEmpty) {
    filtered = products.where((p) {
      final cat = p['category'] as String?;
      return categories.any((c) => cat?.contains(c) ?? false);
    }).toList();
  }

  if (filtered.isEmpty) filtered = products;

  // ערבוב ובחירה
  filtered.shuffle();
  final selected = filtered.take(count).toList();

  // המרה ל-ApiShoppingListItem
  return selected.asMap().entries.map((entry) {
    final index = entry.key;
    final p = entry.value;
    
    return api.ApiShoppingListItem(
      id: 'item_${p['barcode'] ?? index}',
      name: p['name'] ?? 'מוצר',
      quantity: Random().nextInt(3) + 1, // 1-3
      unitPrice: (p['price'] as num?)?.toDouble() ?? 0.0,
      isChecked: includeChecked ? (index % 3 == 0) : false, // כל שלישי מסומן
      barcode: p['barcode'],
      category: p['category'],
    );
  }).toList();
}

/// אתחול נתוני דמו עם מוצרים אמיתיים
Future<void> initializeDemoData() async {
  if (_storage.isNotEmpty) return; // כבר אותחל

  // 1️⃣ רשימה פעילה - סופר שבועי (משותפת)
  final superItems = await _getRandomItems(
    count: 8,
    categories: ['מוצרי חלב', 'מאפים', 'ירקות', 'פירות'],
  );

  _storage.add(api.ApiShoppingList(
    id: "list1",
    name: "סופר שבועי",
    householdId: "house1",
    updatedDate: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    status: "active",
    type: "super",
    budget: 450.0,
    isShared: true,
    createdBy: "yoni_123",
    sharedWith: ["dana_456"],
    items: superItems,
  ));

  // 2️⃣ רשימת בית מרקחת - פעילה
  final pharmacyItems = await _getRandomItems(
    count: 5,
    categories: ['היגיינה אישית', 'מוצרי ניקיון'],
  );

  _storage.add(api.ApiShoppingList(
    id: "list2",
    name: "בית מרקחת חודשי",
    householdId: "house1",
    updatedDate: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    status: "active",
    type: "pharmacy",
    budget: 180.0,
    isShared: false,
    createdBy: "yoni_123",
    sharedWith: [],
    items: pharmacyItems,
  ));

  // 3️⃣ מסיבה - מתוכננת
  final partyItems = await _getRandomItems(
    count: 6,
    categories: ['ממתקים וחטיפים', 'משקאות'],
  );

  _storage.add(api.ApiShoppingList(
    id: "list3",
    name: "מסיבת יום הולדת",
    householdId: "house1",
    updatedDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    status: "active",
    type: "other",
    budget: 350.0,
    isShared: true,
    createdBy: "dana_456",
    sharedWith: ["yoni_123"],
    items: partyItems,
  ));

  // 4️⃣ רשימה שהושלמה - מוצרי ניקיון
  final cleaningItems = await _getRandomItems(
    count: 4,
    categories: ['מוצרי ניקיון'],
    includeChecked: true, // הכל מסומן
  );

  _storage.add(api.ApiShoppingList(
    id: "list4",
    name: "מוצרי ניקיון",
    householdId: "house1",
    updatedDate: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    status: "completed",
    type: "super",
    budget: 120.0,
    isShared: true,
    createdBy: "yoni_123",
    sharedWith: ["dana_456"],
    items: cleaningItems.map((item) => item.copyWith(isChecked: true)).toList(),
  ));

  // 5️⃣ חידוש מזווה - פעילה
  final pantryItems = await _getRandomItems(
    count: 5,
    categories: ['אורז ופסטה', 'תבלינים ואפייה', 'שמנים ורטבים'],
  );

  _storage.add(api.ApiShoppingList(
    id: "list5",
    name: "חידוש מזווה",
    householdId: "house1",
    updatedDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    status: "active",
    type: "super",
    budget: 200.0,
    isShared: false,
    createdBy: "yoni_123",
    sharedWith: [],
    items: pantryItems,
  ));

  // 6️⃣ רשימה מאורכבת - ישנה
  final holidayItems = await _getRandomItems(
    count: 6,
    categories: ['בשר ודגים', 'משקאות'],
  );

  _storage.add(api.ApiShoppingList(
    id: "list6",
    name: "קניות חג האביב",
    householdId: "house1",
    updatedDate: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    status: "archived",
    type: "super",
    budget: 800.0,
    isShared: true,
    createdBy: "yoni_123",
    sharedWith: ["dana_456"],
    items: holidayItems.map((item) => item.copyWith(isChecked: true)).toList(),
  ));

  // 7️⃣ רשימה ריקה - חדשה
  _storage.add(api.ApiShoppingList(
    id: "list7",
    name: "רשימה חדשה",
    householdId: "house1",
    updatedDate: DateTime.now().toIso8601String(),
    status: "active",
    type: "other",
    budget: null,
    isShared: false,
    createdBy: "yoni_123",
    sharedWith: [],
    items: [],
  ));

  print('✅ Demo data initialized with ${_storage.length} lists');
}

/// in-memory "DB" - יאותחל עם מוצרים אמיתיים
final List<api.ApiShoppingList> _storage = [];

/// רשימות דמו (קריאה בלבד)
Future<List<api.ApiShoppingList>> get kDemoShoppingLists async {
  if (_storage.isEmpty) await initializeDemoData();
  return List.unmodifiable(_storage);
}

/// Mock: פילטור רשימות לפי householdId + מיון אופציונלי + עמודות
Future<List<api.ApiShoppingList>> demoFilter(
  Map<String, dynamic> query, {
  String? sort,
  int? limit,
  int? offset,
}) async {
  if (_storage.isEmpty) await initializeDemoData();
  
  await Future.delayed(const Duration(milliseconds: 250));
  final hid = query['household_id'] as String?;
  final status = query['status'] as String?;
  final type = query['type'] as String?;

  var lists = _storage.where((l) {
    if (hid != null && l.householdId != hid) return false;
    if (status != null && l.status != status) return false;
    if (type != null && l.type != type) return false;
    return true;
  }).toList();

  // מיון
  if (sort != null && sort.isNotEmpty) {
    final desc = sort.startsWith('-');
    final key = desc ? sort.substring(1) : sort;

    int cmp(api.ApiShoppingList a, api.ApiShoppingList b) {
      int byKey() {
        switch (key) {
          case 'updatedDate':
            final ad = DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(1970);
            final bd = DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(1970);
            return ad.compareTo(bd);
          case 'name':
            return (a.name).toLowerCase().compareTo((b.name).toLowerCase());
          case 'budget':
            final ab = a.budget ?? 0.0;
            final bb = b.budget ?? 0.0;
            return ab.compareTo(bb);
          default:
            return 0;
        }
      }

      final c = byKey();
      return desc ? -c : c;
    }

    lists.sort(cmp);
  }

  // עמודות
  final start = max(0, offset ?? 0);
  final end = (limit == null) ? lists.length : min(lists.length, start + limit);
  return lists.sublist(start, end);
}

/// יצירה (דמו)
Future<api.ApiShoppingList> demoCreate({
  required String name,
  required String householdId,
  String type = "super",
  double? budget,
  bool isShared = false,
  String? createdBy,
  List<String> sharedWith = const [],
}) async {
  if (_storage.isEmpty) await initializeDemoData();
  
  await Future.delayed(const Duration(milliseconds: 200));
  final id = 'list_${DateTime.now().millisecondsSinceEpoch}';
  final created = api.ApiShoppingList(
    id: id,
    name: name,
    householdId: householdId,
    updatedDate: DateTime.now().toIso8601String(),
    status: "active",
    type: type,
    budget: budget,
    isShared: isShared,
    createdBy: createdBy ?? "demo_user",
    sharedWith: sharedWith,
    items: [],
  );
  _storage.add(created);
  return created;
}

/// עדכון (דמו)
Future<api.ApiShoppingList?> demoUpdate({
  required String id,
  String? name,
  String? status,
  String? type,
  double? budget,
  List<api.ApiShoppingListItem>? items,
}) async {
  if (_storage.isEmpty) await initializeDemoData();
  
  await Future.delayed(const Duration(milliseconds: 200));
  final i = _storage.indexWhere((e) => e.id == id);
  if (i == -1) return null;

  final current = _storage[i];
  final updated = api.ApiShoppingList(
    id: current.id,
    name: name ?? current.name,
    householdId: current.householdId,
    updatedDate: DateTime.now().toIso8601String(),
    status: status ?? current.status,
    type: type ?? current.type,
    budget: budget ?? current.budget,
    isShared: current.isShared,
    createdBy: current.createdBy,
    sharedWith: current.sharedWith,
    items: items ?? current.items,
  );
  _storage[i] = updated;
  return updated;
}

/// מחיקה (דמו)
Future<bool> demoDelete(String id) async {
  if (_storage.isEmpty) await initializeDemoData();
  
  await Future.delayed(const Duration(milliseconds: 150));
  final before = _storage.length;
  _storage.removeWhere((e) => e.id == id);
  final after = _storage.length;
  return after < before;
}

/// ✅ מתאם נוח לדומיין: החזרת ShoppingList (לUI)
Future<List<domain.ShoppingList>> demoFilterAsDomain(
  Map<String, dynamic> query, {
  String? sort,
  int? limit,
  int? offset,
  required String createdByUserId,
}) async {
  final raw = await demoFilter(query, sort: sort, limit: limit, offset: offset);
  
  return raw.map((a) {
    // המרת items מ-API ל-domain
    final domainItems = (a.items ?? []).map((apiItem) {
      return ReceiptItem(
        id: apiItem.id,
        name: apiItem.name,
        quantity: apiItem.quantity,
        unitPrice: apiItem.unitPrice,
        isChecked: apiItem.isChecked ?? false,
        barcode: apiItem.barcode,
      );
    }).toList();

    return domain.ShoppingList(
      id: a.id,
      name: a.name,
      updatedDate: DateTime.tryParse(a.updatedDate ?? '') ?? DateTime.now(),
      status: a.status ?? domain.ShoppingList.statusActive,
      type: a.type ?? domain.ShoppingList.typeSuper,
      budget: a.budget,
      isShared: a.isShared ?? false,
      createdBy: a.createdBy ?? createdByUserId,
      sharedWith: a.sharedWith ?? [],
      items: domainItems,
    );
  }).toList();
}

/// ✅ חדש: קבלת רשימה בודדת לפי ID
Future<api.ApiShoppingList?> demoGetById(String id) async {
  if (_storage.isEmpty) await initializeDemoData();
  
  await Future.delayed(const Duration(milliseconds: 100));
  try {
    return _storage.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
}

/// ✅ חדש: סטטיסטיקות מהירות
Future<Map<String, int>> demoGetStats(String householdId) async {
  if (_storage.isEmpty) await initializeDemoData();
  
  final lists = _storage.where((l) => l.householdId == householdId).toList();
  
  return {
    'total': lists.length,
    'active': lists.where((l) => l.status == 'active').length,
    'completed': lists.where((l) => l.status == 'completed').length,
    'archived': lists.where((l) => l.status == 'archived').length,
    'super': lists.where((l) => l.type == 'super').length,
    'pharmacy': lists.where((l) => l.type == 'pharmacy').length,
    'other': lists.where((l) => l.type == 'other').length,
    'shared': lists.where((l) => l.isShared == true).length,
  };
}
