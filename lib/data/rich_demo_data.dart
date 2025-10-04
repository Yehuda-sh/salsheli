// 📄 File: lib/data/rich_demo_data.dart - VERSION 2.0
//
// ✅ שודרג:
// 1. סונכרן עם demo_shopping_lists.dart החדש (7 רשימות)
// 2. הוספת type + budget לכל רשימה
// 3. שימוש ב-constants.dart (kStorageLocations, kCategories)
// 4. קבלות מלאות יותר
// 5. מלאי מגוון יותר (12 פריטים)
//
// תיאור: נתוני דמו עשירים למשתמש דמו - רשימות, קבלות, מלאי, היסטוריה

import '../models/shopping_list.dart';
import '../models/receipt.dart';
import '../models/inventory_item.dart';
import '../core/constants.dart';

/// === רשימות קניות דמו ===
/// ✅ 7 רשימות מסונכרנות עם demo_shopping_lists.dart
List<ShoppingList> getRichDemoShoppingLists(String userId) {
  final now = DateTime.now();

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
      items: [
        ReceiptItem(
          id: 'item_1_1',
          name: 'חלב 3%',
          quantity: 2,
          unitPrice: 6.90,
          isChecked: false,
          barcode: '7290000000001',
        ),
        ReceiptItem(
          id: 'item_1_2',
          name: 'לחם פרוס',
          quantity: 1,
          unitPrice: 5.50,
          isChecked: true,
        ),
        ReceiptItem(
          id: 'item_1_3',
          name: 'ביצים',
          quantity: 1,
          unitPrice: 12.90,
          isChecked: false,
          barcode: '7290000000002',
        ),
        ReceiptItem(
          id: 'item_1_4',
          name: 'גבינה צהובה',
          quantity: 1,
          unitPrice: 24.90,
          isChecked: true,
        ),
        ReceiptItem(
          id: 'item_1_5',
          name: 'עגבניות',
          quantity: 1,
          unitPrice: 8.90,
          isChecked: false,
        ),
      ],
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
      items: [
        ReceiptItem(
          id: 'item_2_1',
          name: 'ויטמין D',
          quantity: 1,
          unitPrice: 42.90,
          isChecked: false,
        ),
        ReceiptItem(
          id: 'item_2_2',
          name: 'משחת שיניים',
          quantity: 2,
          unitPrice: 18.90,
          isChecked: false,
        ),
        ReceiptItem(
          id: 'item_2_3',
          name: 'סבון נוזלי',
          quantity: 1,
          unitPrice: 12.90,
          isChecked: true,
        ),
      ],
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
      items: [
        ReceiptItem(
          id: 'item_3_1',
          name: 'עוגה',
          quantity: 1,
          unitPrice: 89.00,
          isChecked: false,
        ),
        ReceiptItem(
          id: 'item_3_2',
          name: 'משקאות קלים',
          quantity: 6,
          unitPrice: 5.90,
          isChecked: false,
        ),
        ReceiptItem(
          id: 'item_3_3',
          name: 'צ\'יפס',
          quantity: 3,
          unitPrice: 8.90,
          isChecked: false,
        ),
        ReceiptItem(
          id: 'item_3_4',
          name: 'חטיפים',
          quantity: 5,
          unitPrice: 4.50,
          isChecked: false,
        ),
      ],
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
      items: [
        ReceiptItem(
          id: 'item_4_1',
          name: 'אקונומיקה',
          quantity: 1,
          unitPrice: 12.90,
          isChecked: true,
        ),
        ReceiptItem(
          id: 'item_4_2',
          name: 'נוזל רצפה',
          quantity: 1,
          unitPrice: 15.90,
          isChecked: true,
        ),
        ReceiptItem(
          id: 'item_4_3',
          name: 'ספוג כלים',
          quantity: 3,
          unitPrice: 2.90,
          isChecked: true,
        ),
      ],
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
      items: [
        ReceiptItem(
          id: 'item_5_1',
          name: 'אורז',
          quantity: 2,
          unitPrice: 18.90,
          isChecked: false,
        ),
        ReceiptItem(
          id: 'item_5_2',
          name: 'פסטה',
          quantity: 3,
          unitPrice: 7.90,
          isChecked: false,
        ),
        ReceiptItem(
          id: 'item_5_3',
          name: 'קטשופ',
          quantity: 1,
          unitPrice: 12.90,
          isChecked: true,
        ),
      ],
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
      items: [
        ReceiptItem(
          id: 'item_6_1',
          name: 'בשר טחון',
          quantity: 2,
          unitPrice: 45.00,
          isChecked: true,
        ),
        ReceiptItem(
          id: 'item_6_2',
          name: 'יין אדום',
          quantity: 2,
          unitPrice: 35.00,
          isChecked: true,
        ),
      ],
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
/// ✅ 3 קבלות מלאות עם כל השדות
List<Receipt> getRichDemoReceipts() {
  final now = DateTime.now();

  return [
    // קבלה 1 - לפני שבוע
    Receipt(
      id: 'receipt_1',
      storeName: 'שופרסל',
      date: now.subtract(const Duration(days: 7)),
      createdDate: now.subtract(const Duration(days: 7)),
      totalAmount: 287.50,
      items: [
        ReceiptItem(
          id: 'r1_item_1',
          name: 'חלב 3%',
          quantity: 4,
          unitPrice: 6.90,
          barcode: '7290000000001',
        ),
        ReceiptItem(
          id: 'r1_item_2',
          name: 'לחם פרוס',
          quantity: 2,
          unitPrice: 5.50,
        ),
        ReceiptItem(
          id: 'r1_item_3',
          name: 'גבינה לבנה 5%',
          quantity: 2,
          unitPrice: 7.90,
        ),
        ReceiptItem(
          id: 'r1_item_4',
          name: 'בשר טחון',
          quantity: 1,
          unitPrice: 45.00,
        ),
        ReceiptItem(
          id: 'r1_item_5',
          name: 'עגבניות',
          quantity: 1,
          unitPrice: 8.90,
        ),
        ReceiptItem(
          id: 'r1_item_6',
          name: 'מלפפונים',
          quantity: 1,
          unitPrice: 6.90,
        ),
        ReceiptItem(
          id: 'r1_item_7',
          name: 'תפוחי אדמה',
          quantity: 1,
          unitPrice: 12.50,
        ),
        ReceiptItem(id: 'r1_item_8', name: 'בצל', quantity: 1, unitPrice: 5.90),
        ReceiptItem(id: 'r1_item_9', name: 'שום', quantity: 1, unitPrice: 4.50),
        ReceiptItem(
          id: 'r1_item_10',
          name: 'ביצים',
          quantity: 2,
          unitPrice: 12.90,
        ),
      ],
    ),

    // קבלה 2 - לפני שבועיים
    Receipt(
      id: 'receipt_2',
      storeName: 'רמי לוי',
      date: now.subtract(const Duration(days: 14)),
      createdDate: now.subtract(const Duration(days: 14)),
      totalAmount: 456.80,
      items: [
        ReceiptItem(
          id: 'r2_item_1',
          name: 'אורז בסמטי',
          quantity: 3,
          unitPrice: 18.90,
        ),
        ReceiptItem(
          id: 'r2_item_2',
          name: 'פסטה',
          quantity: 5,
          unitPrice: 7.90,
        ),
        ReceiptItem(
          id: 'r2_item_3',
          name: 'שמן זית',
          quantity: 2,
          unitPrice: 32.90,
        ),
        ReceiptItem(
          id: 'r2_item_4',
          name: 'טונה',
          quantity: 8,
          unitPrice: 6.50,
        ),
        ReceiptItem(
          id: 'r2_item_5',
          name: 'קטשופ',
          quantity: 2,
          unitPrice: 12.90,
        ),
        ReceiptItem(
          id: 'r2_item_6',
          name: 'מיונז',
          quantity: 1,
          unitPrice: 9.90,
        ),
        ReceiptItem(
          id: 'r2_item_7',
          name: 'חומוס',
          quantity: 3,
          unitPrice: 7.50,
        ),
      ],
    ),

    // קבלה 3 - לפני 3 שבועות
    Receipt(
      id: 'receipt_3',
      storeName: 'יוחננוף',
      date: now.subtract(const Duration(days: 21)),
      createdDate: now.subtract(const Duration(days: 21)),
      totalAmount: 198.70,
      items: [
        ReceiptItem(
          id: 'r3_item_1',
          name: 'אקונומיקה',
          quantity: 2,
          unitPrice: 12.90,
        ),
        ReceiptItem(
          id: 'r3_item_2',
          name: 'נוזל רצפה',
          quantity: 1,
          unitPrice: 15.90,
        ),
        ReceiptItem(
          id: 'r3_item_3',
          name: 'ספוג כלים',
          quantity: 5,
          unitPrice: 2.90,
        ),
        ReceiptItem(
          id: 'r3_item_4',
          name: 'נייר טואלט',
          quantity: 2,
          unitPrice: 24.90,
        ),
        ReceiptItem(
          id: 'r3_item_5',
          name: 'סבון כלים',
          quantity: 1,
          unitPrice: 8.90,
        ),
      ],
    ),
  ];
}

/// === מלאי דמו ===
/// ✅ 12 פריטים מגוונים עם שימוש ב-constants
List<InventoryItem> getRichDemoInventory() {
  // מקבל את שמות המיקומים מ-constants
  final mainPantry = kStorageLocations['main_pantry']!['name']!;
  final refrigerator = kStorageLocations['refrigerator']!['name']!;
  final freezer = kStorageLocations['freezer']!['name']!;
  final bathroom = kStorageLocations['bathroom']!['name']!;

  return [
    // מזווה ראשי
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
      productName: 'פסטה',
      category: 'יבשים',
      location: mainPantry,
      quantity: 5,
      unit: 'אריזות',
    ),
    InventoryItem(
      id: 'inv_3',
      productName: 'שמן זית כתית',
      category: 'שמנים',
      location: mainPantry,
      quantity: 1,
      unit: 'בקבוק',
    ),
    InventoryItem(
      id: 'inv_4',
      productName: 'טונה',
      category: 'שימורים',
      location: mainPantry,
      quantity: 6,
      unit: 'קופסאות',
    ),
    InventoryItem(
      id: 'inv_5',
      productName: 'קטשופ',
      category: 'רטבים',
      location: mainPantry,
      quantity: 1,
      unit: 'בקבוק',
    ),

    // מקרר
    InventoryItem(
      id: 'inv_6',
      productName: 'חלב 3%',
      category: 'חלב ומוצריו',
      location: refrigerator,
      quantity: 2,
      unit: 'ליטר',
    ),
    InventoryItem(
      id: 'inv_7',
      productName: 'גבינה צהובה',
      category: 'חלב ומוצריו',
      location: refrigerator,
      quantity: 1,
      unit: 'אריזה',
    ),
    InventoryItem(
      id: 'inv_8',
      productName: 'ביצים',
      category: 'חלב ומוצריו',
      location: refrigerator,
      quantity: 12,
      unit: 'יחידות',
    ),
    InventoryItem(
      id: 'inv_9',
      productName: 'יוגורט',
      category: 'חלב ומוצריו',
      location: refrigerator,
      quantity: 4,
      unit: 'יחידות',
    ),

    // מקפיא
    InventoryItem(
      id: 'inv_10',
      productName: 'בשר טחון',
      category: 'בשר',
      location: freezer,
      quantity: 1,
      unit: 'קילוגרם',
    ),

    // אמבטיה
    InventoryItem(
      id: 'inv_11',
      productName: 'משחת שיניים',
      category: 'טיפוח',
      location: bathroom,
      quantity: 2,
      unit: 'יחידות',
    ),
    InventoryItem(
      id: 'inv_12',
      productName: 'סבון נוזלי',
      category: 'טיפוח',
      location: bathroom,
      quantity: 1,
      unit: 'בקבוק',
    ),
  ];
}

/// === פונקציה מרכזית לטעינת כל הנתונים ===
/// ✅ מחזירה Map עם כל סוגי הנתונים + מטא-דאטה
Map<String, dynamic> loadRichDemoData(String userId, String householdId) {
  final lists = getRichDemoShoppingLists(userId);
  final receipts = getRichDemoReceipts();
  final inventory = getRichDemoInventory();

  return {
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
}
