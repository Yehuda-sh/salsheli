// 📄 File: lib/data/demo_shopping_lists.dart - VERSION 2.0
//
// ✅ שדרוגים:
// 1. 7 רשימות מגוונות (לא 2!)
// 2. כולל type (super/pharmacy/other) ו-budget
// 3. כולל items מלאים לכל רשימה
// 4. סטטוסים שונים (active/completed/archived)
// 5. רשימות משותפות וסולו
// 6. תאריכים ריאליסטיים
// 7. סנכרון עם kListTypes מ-constants.dart
//
// 🇮🇱 נתוני דמו לרשימות קניות (לפיתוח/בדיקות בלבד!)
// 🇬🇧 Demo shopping lists (dev/testing only)

import 'dart:math';
import '../api/entities/shopping_list.dart' as api;
import '../models/shopping_list.dart' as domain;
import '../models/receipt.dart';

/// in-memory "DB" - ✅ משודרג עם 7 רשימות מגוונות
final List<api.ApiShoppingList> _storage = [
  // 1️⃣ רשימה פעילה - סופר שבועי (משותפת)
  api.ApiShoppingList(
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
    items: [
      api.ApiReceiptItem(
        id: "item_1_1",
        name: "חלב 3%",
        quantity: 2,
        unitPrice: 6.90,
        isChecked: false,
      ),
      api.ApiReceiptItem(
        id: "item_1_2",
        name: "לחם פרוס",
        quantity: 1,
        unitPrice: 5.50,
        isChecked: true,
      ),
      api.ApiReceiptItem(
        id: "item_1_3",
        name: "ביצים",
        quantity: 1,
        unitPrice: 12.90,
        isChecked: false,
      ),
      api.ApiReceiptItem(
        id: "item_1_4",
        name: "גבינה צהובה",
        quantity: 1,
        unitPrice: 24.90,
        isChecked: true,
      ),
      api.ApiReceiptItem(
        id: "item_1_5",
        name: "עגבניות",
        quantity: 1,
        unitPrice: 8.90,
        isChecked: false,
      ),
    ],
  ),

  // 2️⃣ רשימת בית מרקחת - פעילה
  api.ApiShoppingList(
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
    items: [
      api.ApiReceiptItem(
        id: "item_2_1",
        name: "ויטמין D",
        quantity: 1,
        unitPrice: 42.90,
        isChecked: false,
      ),
      api.ApiReceiptItem(
        id: "item_2_2",
        name: "משחת שיניים",
        quantity: 2,
        unitPrice: 18.90,
        isChecked: false,
      ),
      api.ApiReceiptItem(
        id: "item_2_3",
        name: "סבון נוזלי",
        quantity: 1,
        unitPrice: 12.90,
        isChecked: true,
      ),
    ],
  ),

  // 3️⃣ מסיבה - מתוכננת
  api.ApiShoppingList(
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
    items: [
      api.ApiReceiptItem(
        id: "item_3_1",
        name: "עוגה",
        quantity: 1,
        unitPrice: 89.00,
        isChecked: false,
      ),
      api.ApiReceiptItem(
        id: "item_3_2",
        name: "משקאות קלים",
        quantity: 6,
        unitPrice: 5.90,
        isChecked: false,
      ),
      api.ApiReceiptItem(
        id: "item_3_3",
        name: "צ'יפס",
        quantity: 3,
        unitPrice: 8.90,
        isChecked: false,
      ),
    ],
  ),

  // 4️⃣ רשימה שהושלמה - מוצרי ניקיון
  api.ApiShoppingList(
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
    items: [
      api.ApiReceiptItem(
        id: "item_4_1",
        name: "אקונומיקה",
        quantity: 1,
        unitPrice: 12.90,
        isChecked: true,
      ),
      api.ApiReceiptItem(
        id: "item_4_2",
        name: "נוזל רצפה",
        quantity: 1,
        unitPrice: 15.90,
        isChecked: true,
      ),
      api.ApiReceiptItem(
        id: "item_4_3",
        name: "ספוג כלים",
        quantity: 3,
        unitPrice: 2.90,
        isChecked: true,
      ),
    ],
  ),

  // 5️⃣ חידוש מזווה - פעילה
  api.ApiShoppingList(
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
    items: [
      api.ApiReceiptItem(
        id: "item_5_1",
        name: "אורז",
        quantity: 2,
        unitPrice: 18.90,
        isChecked: false,
      ),
      api.ApiReceiptItem(
        id: "item_5_2",
        name: "פסטה",
        quantity: 3,
        unitPrice: 7.90,
        isChecked: false,
      ),
      api.ApiReceiptItem(
        id: "item_5_3",
        name: "קטשופ",
        quantity: 1,
        unitPrice: 12.90,
        isChecked: true,
      ),
    ],
  ),

  // 6️⃣ רשימה מאורכבת - ישנה
  api.ApiShoppingList(
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
    items: [
      api.ApiReceiptItem(
        id: "item_6_1",
        name: "בשר טחון",
        quantity: 2,
        unitPrice: 45.00,
        isChecked: true,
      ),
      api.ApiReceiptItem(
        id: "item_6_2",
        name: "יין אדום",
        quantity: 2,
        unitPrice: 35.00,
        isChecked: true,
      ),
    ],
  ),

  // 7️⃣ רשימה ריקה - חדשה
  api.ApiShoppingList(
    id: "list7",
    name: "רשימה חדשה",
    householdId: "house1",
    updatedDate: DateTime.now().toIso8601String(),
    status: "active",
    type: "other",
    budget: null, // ללא תקציב
    isShared: false,
    createdBy: "yoni_123",
    sharedWith: [],
    items: [], // רשימה ריקה
  ),
];

/// רשימות דמו (קריאה בלבד)
List<api.ApiShoppingList> get kDemoShoppingLists => List.unmodifiable(_storage);

/// Mock: פילטור רשימות לפי householdId + מיון אופציונלי + עמודות
Future<List<api.ApiShoppingList>> demoFilter(
  Map<String, dynamic> query, {
  String? sort,
  int? limit,
  int? offset,
}) async {
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
  List<api.ApiReceiptItem>? items,
}) async {
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
  await Future.delayed(const Duration(milliseconds: 100));
  try {
    return _storage.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
}

/// ✅ חדש: סטטיסטיקות מהירות
Map<String, int> demoGetStats(String householdId) {
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