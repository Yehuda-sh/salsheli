// 📄 File: test/helpers/mock_data.dart
// 🎯 Purpose: נתונים מדומים לבדיקות
//
// 📋 Features:
// - ✅ משתמשים מדומים
// - ✅ רשימות קניות מדומות
// - ✅ פריטים מדומים
// - ✅ מוצרים מדומים
//
// 📝 Version: 1.0
// 📅 Created: 18/10/2025

import 'package:memozap/models/user_entity.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/unified_list_item.dart';

/// משתמש דמו מלא
UserEntity createMockUser({
  String? id,
  String? email,
  String? name,
  String? householdId,
}) {
  return UserEntity.newUser(
    id: id ?? 'user-123',
    email: email ?? 'test@test.com',
    name: name ?? 'משתמש בדיקה',
    householdId: householdId ?? 'household-123',
  );
}

/// רשימת קניות דמו
ShoppingList createMockShoppingList({
  String? id,
  String? name,
  String? createdBy,
  List<UnifiedListItem>? items,
  String type = ShoppingList.typeSupermarket,
}) {
  return ShoppingList.newList(
    id: id ?? 'list-123',
    name: name ?? 'רשימת קניות',
    createdBy: createdBy ?? 'user-123',
    items: items ?? [],
    type: type,
  );
}

/// פריט קנייה דמו
UnifiedListItem createMockShoppingItem({
  String? id,
  String? name,
  int quantity = 1,
  bool isBought = false,
}) {
  return UnifiedListItem.product(
    id: id ?? 'item-123',
    name: name ?? 'חלב',
    quantity: quantity,
    unitPrice: 0.0,
    isChecked: isBought,
  );
}

/// מוצר דמו
UnifiedListItem createMockProduct({
  String? id,
  String? name,
  double? price,
  String? barcode,
}) {
  return UnifiedListItem.product(
    id: id ?? 'product-123',
    name: name ?? 'חלב 3%',
    quantity: 1,
    unitPrice: price ?? 5.90,
    barcode: barcode,
  );
}

/// רשימת משתמשים דמו למבחני multi-user
List<UserEntity> createMockUsers(int count) {
  return List.generate(count, (i) {
    return createMockUser(
      id: 'user-$i',
      email: 'user$i@test.com',
      name: 'משתמש $i',
      householdId: 'household-123', // כולם באותו household
    );
  });
}

/// רשימת פריטים דמו
List<UnifiedListItem> createMockShoppingItems(int count) {
  final items = [
    'חלב',
    'לחם',
    'ביצים',
    'גבינה',
    'חמאה',
    'יוגורט',
    'עגבניות',
    'מלפפונים',
    'בננות',
    'תפוחים',
  ];
  
  return List.generate(count, (i) {
    return createMockShoppingItem(
      id: 'item-$i',
      name: items[i % items.length],
      quantity: (i % 5) + 1,
      isBought: i % 3 == 0,
    );
  });
}

/// רשימת מוצרים דמו
List<UnifiedListItem> createMockProducts(int count) {
  final products = [
    {'name': 'חלב 3%', 'price': 5.90},
    {'name': 'לחם פרוס', 'price': 6.50},
    {'name': 'ביצים גודל L', 'price': 12.90},
    {'name': 'גבינה צהובה', 'price': 25.90},
    {'name': 'חמאה', 'price': 8.90},
    {'name': 'יוגורט טבעי', 'price': 4.50},
    {'name': 'עגבניות', 'price': 7.90},
    {'name': 'מלפפונים', 'price': 5.90},
    {'name': 'בננות', 'price': 6.90},
    {'name': 'תפוחים', 'price': 8.90},
  ];
  
  return List.generate(count, (i) {
    final product = products[i % products.length];
    return createMockProduct(
      id: 'product-$i',
      name: product['name'] as String,
      price: product['price'] as double?,  // unitPrice
      barcode: '${7290000000000 + i}',
    );
  });
}

/// רשימת רשימות קניות דמו
List<ShoppingList> createMockShoppingLists(int count) {
  return List.generate(count, (i) {
    // Note: status is always 'active' when using newList factory.
    // To create archived lists, use copyWith(status: ShoppingList.statusArchived)
    return createMockShoppingList(
      id: 'list-$i',
      name: 'רשימה $i',
      createdBy: 'user-123',
      items: createMockShoppingItems(5),
    );
  });
}
