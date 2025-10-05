// 📄 File: lib/data/rich_demo_data.dart - VERSION 3.0
//
// ✅ שדרוגים:
// 1. טעינת מוצרים אמיתיים מ-assets/data/products.json
// 2. 7 רשימות קניות עם מוצרים אמיתיים
// 3. 3 קבלות עם מוצרים אמיתיים
// 4. מלאי מגוון עם מוצרים אמיתיים
// 5. סונכרן עם demo_shopping_lists.dart
//
// תיאור: נתוני דמו עשירים למשתמש דמו - רשימות, קבלות, מלאי, היסטוריה

import 'dart:math';
import '../models/shopping_list.dart';
import '../models/receipt.dart';
import '../models/inventory_item.dart';
import '../core/constants.dart';
import '../helpers/product_loader.dart';

// ✅ משתמש ב-product_loader.dart (cache משותף)

/// בחירת מוצרים אקראיים לפי קטגוריה
Future<List<ReceiptItem>> _getRandomReceiptItems({
  required int count,
  List<String>? categories,
  bool allChecked = false,
}) async {
  final products = await loadProductsAsList();
  if (products.isEmpty) {
    print('⚠️ Rich Demo: אין מוצרים זמינים, משתמש בפריטים ברירת מחדל');
    return _getFallbackItems(count);
  }

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

  // המרה ל-ReceiptItem
  return selected.asMap().entries.map((entry) {
    final index = entry.key;
    final p = entry.value;
    
    return ReceiptItem(
      id: 'item_${p['barcode'] ?? index}',
      name: p['name'] ?? 'מוצר',
      quantity: Random().nextInt(3) + 1, // 1-3
      unitPrice: (p['price'] as num?)?.toDouble() ?? 0.0,
      isChecked: allChecked || (index % 3 == 0), // אם allChecked או כל שלישי
      barcode: p['barcode'],
    );
  }).toList();
}

/// פריטים ברירת מחדל במקרה שהטעינה נכשלת
List<ReceiptItem> _getFallbackItems(int count) {
  final fallbackProducts = [
    {'name': 'חלב 3%', 'price': 6.90, 'barcode': '7290000000001'},
    {'name': 'לחם פרוס', 'price': 5.50, 'barcode': null},
    {'name': 'ביצים', 'price': 12.90, 'barcode': '7290000000002'},
    {'name': 'גבינה צהובה', 'price': 24.90, 'barcode': null},
    {'name': 'עגבניות', 'price': 8.90, 'barcode': null},
  ];

  return List.generate(
    min(count, fallbackProducts.length),
    (i) => ReceiptItem(
      id: 'fallback_$i',
      name: fallbackProducts[i]['name'] as String,
      quantity: 1,
      unitPrice: fallbackProducts[i]['price'] as double,
      barcode: fallbackProducts[i]['barcode'] as String?,
    ),
  );
}

/// === רשימות קניות דמו ===
/// ✅ 7 רשימות עם מוצרים אמיתיים מ-JSON
Future<List<ShoppingList>> getRichDemoShoppingLists(String userId) async {
  final now = DateTime.now();

  // טעינת פריטים לכל רשימה
  final superItems = await _getRandomReceiptItems(
    count: 5,
    categories: ['מוצרי חלב', 'מאפים', 'ירקות'],
  );
  
  final pharmacyItems = await _getRandomReceiptItems(
    count: 3,
    categories: ['היגיינה אישית', 'מוצרי ניקיון'],
  );
  
  final partyItems = await _getRandomReceiptItems(
    count: 4,
    categories: ['ממתקים וחטיפים', 'משקאות'],
  );
  
  final cleaningItems = await _getRandomReceiptItems(
    count: 3,
    categories: ['מוצרי ניקיון'],
    allChecked: true,
  );
  
  final pantryItems = await _getRandomReceiptItems(
    count: 3,
    categories: ['אורז ופסטה', 'תבלינים ואפייה', 'שמנים ורטבים'],
  );
  
  final holidayItems = await _getRandomReceiptItems(
    count: 2,
    categories: ['בשר ודגים', 'משקאות'],
    allChecked: true,
  );

  return [
    // 1️⃣ רשימה פעילה - סופר שבועי
    ShoppingList(
      id: 'demo_list_1',
      name: 'סופר שבועי',
      updatedDate: now.subtract(const Duration(hours: 2)),
      status: ShoppingList.statusActive,
      type: ShoppingList.typeSuper,
      budget: 450.0,
      isShared: true,
      createdBy: userId,
      sharedWith: ['dana_456'],
      items: superItems,
    ),

    // 2️⃣ רשימת בית מרקחת - פעילה
    ShoppingList(
      id: 'demo_list_2',
      name: 'בית מרקחת חודשי',
      updatedDate: now.subtract(const Duration(days: 1)),
      status: ShoppingList.statusActive,
      type: ShoppingList.typePharmacy,
      budget: 180.0,
      isShared: false,
      createdBy: userId,
      sharedWith: [],
      items: pharmacyItems,
    ),

    // 3️⃣ מסיבה - מתוכננת
    ShoppingList(
      id: 'demo_list_3',
      name: 'מסיבת יום הולדת',
      updatedDate: now.subtract(const Duration(days: 2)),
      status: ShoppingList.statusActive,
      type: ShoppingList.typeOther,
      budget: 350.0,
      isShared: true,
      createdBy: 'dana_456',
      sharedWith: [userId],
      items: partyItems,
    ),

    // 4️⃣ רשימה שהושלמה - מוצרי ניקיון
    ShoppingList(
      id: 'demo_list_4',
      name: 'מוצרי ניקיון',
      updatedDate: now.subtract(const Duration(days: 3)),
      status: ShoppingList.statusCompleted,
      type: ShoppingList.typeSuper,
      budget: 120.0,
      isShared: true,
      createdBy: userId,
      sharedWith: ['dana_456'],
      items: cleaningItems,
    ),

    // 5️⃣ חידוש מזווה - פעילה
    ShoppingList(
      id: 'demo_list_5',
      name: 'חידוש מזווה',
      updatedDate: now.subtract(const Duration(days: 5)),
      status: ShoppingList.statusActive,
      type: ShoppingList.typeSuper,
      budget: 200.0,
      isShared: false,
      createdBy: userId,
      sharedWith: [],
      items: pantryItems,
    ),

    // 6️⃣ רשימה מאורכבת - ישנה
    ShoppingList(
      id: 'demo_list_6',
      name: 'קניות חג האביב',
      updatedDate: now.subtract(const Duration(days: 30)),
      status: ShoppingList.statusArchived,
      type: ShoppingList.typeSuper,
      budget: 800.0,
      isShared: true,
      createdBy: userId,
      sharedWith: ['dana_456'],
      items: holidayItems,
    ),

    // 7️⃣ רשימה ריקה - חדשה
    ShoppingList(
      id: 'demo_list_7',
      name: 'רשימה חדשה',
      updatedDate: now,
      status: ShoppingList.statusActive,
      type: ShoppingList.typeOther,
      budget: null,
      isShared: false,
      createdBy: userId,
      sharedWith: [],
      items: [],
    ),
  ];
}

/// === קבלות דמו ===
/// ✅ 3 קבלות עם מוצרים אמיתיים מ-JSON
Future<List<Receipt>> getRichDemoReceipts() async {
  final now = DateTime.now();

  // קבלה 1 - מוצרי מזון מגוונים
  final receipt1Items = await _getRandomReceiptItems(
    count: 10,
    categories: ['מוצרי חלב', 'מאפים', 'ירקות', 'פירות', 'בשר ודגים'],
  );

  // קבלה 2 - מוצרי מזווה
  final receipt2Items = await _getRandomReceiptItems(
    count: 7,
    categories: ['אורז ופסטה', 'שמנים ורטבים', 'קפה ותה'],
  );

  // קבלה 3 - מוצרי ניקיון
  final receipt3Items = await _getRandomReceiptItems(
    count: 5,
    categories: ['מוצרי ניקיון', 'היגיינה אישית'],
  );

  return [
    // קבלה 1 - לפני שבוע
    Receipt(
      id: 'receipt_1',
      storeName: 'שופרסל',
      date: now.subtract(const Duration(days: 7)),
      createdDate: now.subtract(const Duration(days: 7)),
      totalAmount: receipt1Items.fold<double>(
        0,
        (sum, item) => sum + (item.quantity * item.unitPrice),
      ),
      items: receipt1Items,
    ),

    // קבלה 2 - לפני שבועיים
    Receipt(
      id: 'receipt_2',
      storeName: 'רמי לוי',
      date: now.subtract(const Duration(days: 14)),
      createdDate: now.subtract(const Duration(days: 14)),
      totalAmount: receipt2Items.fold<double>(
        0,
        (sum, item) => sum + (item.quantity * item.unitPrice),
      ),
      items: receipt2Items,
    ),

    // קבלה 3 - לפני 3 שבועות
    Receipt(
      id: 'receipt_3',
      storeName: 'יוחננוף',
      date: now.subtract(const Duration(days: 21)),
      createdDate: now.subtract(const Duration(days: 21)),
      totalAmount: receipt3Items.fold<double>(
        0,
        (sum, item) => sum + (item.quantity * item.unitPrice),
      ),
      items: receipt3Items,
    ),
  ];
}

/// === מלאי דמו ===
/// ✅ מלאי מגוון עם מוצרים אמיתיים מ-JSON
Future<List<InventoryItem>> getRichDemoInventory() async {
  final products = await loadProductsAsList();
  
  // אם אין מוצרים, החזר מלאי ברירת מחדל
  if (products.isEmpty) {
    return _getFallbackInventory();
  }

  // מקבל את שמות המיקומים מ-constants
  final mainPantry = kStorageLocations['main_pantry']!['name']!;
  final refrigerator = kStorageLocations['refrigerator']!['name']!;
  final freezer = kStorageLocations['freezer']!['name']!;
  final bathroom = kStorageLocations['bathroom']!['name']!;

  final inventory = <InventoryItem>[];

  // פונקציה עזר להוספת מוצר למלאי
  void addInventoryItem(String category, String location, int maxItems) {
    final categoryProducts = products
        .where((p) => (p['category'] as String?)?.contains(category) ?? false)
        .toList();
    
    if (categoryProducts.isEmpty) return;
    
    categoryProducts.shuffle();
    final selected = categoryProducts.take(min(maxItems, categoryProducts.length));
    
    for (final p in selected) {
      inventory.add(InventoryItem(
        id: 'inv_${p['barcode'] ?? inventory.length}',
        productName: p['name'] ?? 'מוצר',
        category: category,
        location: location,
        quantity: Random().nextInt(5) + 1, // 1-5
        unit: _guessUnit(p['unit'] as String?),
      ));
    }
  }

  // מזווה ראשי - מוצרי מזווה
  addInventoryItem('אורז ופסטה', mainPantry, 3);
  addInventoryItem('שמנים ורטבים', mainPantry, 2);

  // מקרר - מוצרי חלב
  addInventoryItem('מוצרי חלב', refrigerator, 4);

  // מקפיא - בשר
  addInventoryItem('בשר ודגים', freezer, 2);

  // אמבטיה - היגיינה
  addInventoryItem('היגיינה אישית', bathroom, 2);

  print('✅ Rich Demo: נוצרו ${inventory.length} פריטי מלאי');
  return inventory;
}

/// ניחוש יחידה לפי יחידת המדידה במוצר
String _guessUnit(String? unit) {
  if (unit == null) return 'יחידות';
  
  if (unit.contains('ק"ג') || unit.contains('קילו')) return 'קילוגרם';
  if (unit.contains('ליטר') || unit.contains('ל')) return 'ליטר';
  if (unit.contains('גרם') || unit.contains('ג')) return 'גרם';
  if (unit.contains('מ"ל')) return 'מיליליטר';
  
  return 'יחידות';
}

/// מלאי ברירת מחדל אם הטעינה נכשלת
List<InventoryItem> _getFallbackInventory() {
  final mainPantry = kStorageLocations['main_pantry']!['name']!;
  final refrigerator = kStorageLocations['refrigerator']!['name']!;
  
  return [
    InventoryItem(
      id: 'inv_1',
      productName: 'אורז בסמטי',
      category: 'יבשים',
      location: mainPantry,
      quantity: 2,
      unit: 'קילוגרם',
    ),
    InventoryItem(
      id: 'inv_2',
      productName: 'חלב 3%',
      category: 'חלב ומוצריו',
      location: refrigerator,
      quantity: 2,
      unit: 'ליטר',
    ),
  ];
}

/// === פונקציה מרכזית לטעינת כל הנתונים ===
/// ✅ מחזירה Map עם כל סוגי הנתונים + מטא-דאטה
Future<Map<String, dynamic>> loadRichDemoData(
  String userId,
  String householdId,
) async {
  print('🚀 Rich Demo: מתחיל טעינת נתונים עבור משתמש $userId');
  
  final lists = await getRichDemoShoppingLists(userId);
  final receipts = await getRichDemoReceipts();
  final inventory = await getRichDemoInventory();

  final result = {
    'shoppingLists': lists,
    'receipts': receipts,
    'inventory': inventory,
    'metadata': {
      'userId': userId,
      'householdId': householdId,
      'loadedAt': DateTime.now().toIso8601String(),
      'totalLists': lists.length,
      'totalReceipts': receipts.length,
      'totalInventoryItems': inventory.length,
      'listsByStatus': {
        'active': lists
            .where((l) => l.status == ShoppingList.statusActive)
            .length,
        'completed': lists
            .where((l) => l.status == ShoppingList.statusCompleted)
            .length,
        'archived': lists
            .where((l) => l.status == ShoppingList.statusArchived)
            .length,
      },
      'listsByType': {
        'super': lists.where((l) => l.type == ShoppingList.typeSuper).length,
        'pharmacy': lists
            .where((l) => l.type == ShoppingList.typePharmacy)
            .length,
        'other': lists.where((l) => l.type == ShoppingList.typeOther).length,
      },
      'totalBudget': lists
          .where((l) => l.budget != null)
          .fold<double>(0, (sum, l) => sum + l.budget!),
      'totalSpent': receipts.fold<double>(0, (sum, r) => sum + r.totalAmount),
    },
  };

  print('✅ Rich Demo: טעינה הושלמה בהצלחה');
  return result;
}
