// 📄 test/fixtures/demo_personas.dart
// Mock data for 3 test personas with realistic usage history.

import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/unified_list_item.dart';
import 'package:memozap/models/user_entity.dart';
import 'package:memozap/models/enums/item_type.dart';

// =============================================================================
// PERSONA 1: Family Shopper (Cohen Family)
// =============================================================================

class FamilyShopperPersona {
  static UserEntity get avi => UserEntity(
        id: 'avi-cohen-001',
        name: 'אבי כהן',
        email: 'avi.cohen@demo.com',
        phone: '0501234567',
        householdId: 'household_cohen',
        householdName: 'משפחת כהן',
        joinedAt: DateTime(2025, 1, 15),
        preferredStores: const ['שופרסל', 'רמי לוי'],
        familySize: 4,
        shoppingFrequency: 2,
        shoppingDays: const [4, 5],
        hasChildren: true,
        shareLists: true,
        seenOnboarding: true,
      );

  static UserEntity get ronit => UserEntity(
        id: 'ronit-cohen-002',
        name: 'רונית כהן',
        email: 'ronit.cohen@demo.com',
        householdId: 'household_cohen',
        householdName: 'משפחת כהן',
        joinedAt: DateTime(2025, 1, 16),
        preferredStores: const ['שופרסל', 'יוחננוף'],
        familySize: 4,
        shoppingFrequency: 3,
        shoppingDays: const [0, 3, 5],
        hasChildren: true,
        shareLists: true,
        seenOnboarding: true,
      );

  /// Recurring child items
  static List<UnifiedListItem> get childItems => [
        const UnifiedListItem(
          id: 'child-1',
          name: 'במבה',
          type: ItemType.product,
          category: 'ממתקים וחטיפים',
          productData: {'quantity': 3, 'unit': 'שקית'},
        ),
        const UnifiedListItem(
          id: 'child-2',
          name: 'מיץ תפוחים קטן',
          type: ItemType.product,
          category: 'משקאות',
          productData: {'quantity': 6, 'unit': "יח'"},
        ),
        const UnifiedListItem(
          id: 'child-3',
          name: 'יוגורט דניאלה',
          type: ItemType.product,
          category: 'מוצרי חלב',
          productData: {'quantity': 4, 'unit': "יח'"},
        ),
      ];

  static ShoppingList get weeklyList => ShoppingList(
        id: 'cohen-weekly-001',
        name: 'קניות שבועיות',
        status: 'active',
        type: 'supermarket',
        budget: 800,
        isShared: true,
        createdBy: 'avi-cohen-001',
        format: 'shared',
        createdFromTemplate: false,
        sharedWith: const ['ronit-cohen-002'],
        items: [
          ...childItems,
          const UnifiedListItem(
            id: 'weekly-1',
            name: 'חלב 3%',
            type: ItemType.product,
            category: 'מוצרי חלב',
            productData: {'quantity': 2, 'unit': 'ליטר'},
          ),
          const UnifiedListItem(
            id: 'weekly-2',
            name: 'לחם אחיד',
            type: ItemType.product,
            category: 'לחם ומאפים',
            isChecked: true,
            checkedBy: 'ronit-cohen-002',
          ),
        ],
        createdDate: DateTime(2026, 3, 10),
        updatedDate: DateTime(2026, 3, 14),
      );

  /// Generate N weeks of shopping history
  static List<ShoppingList> generateHistory(int weeks) {
    return List.generate(weeks, (i) {
      final date = DateTime(2026, 3, 15).subtract(Duration(days: i * 7));
      return ShoppingList(
        id: 'cohen-history-$i',
        name: 'קניות שבוע ${weeks - i}',
        status: 'completed',
        type: 'supermarket',
        budget: 700 + (i * 10.0),
        isShared: true,
        createdBy: i.isEven ? 'avi-cohen-001' : 'ronit-cohen-002',
        format: 'shared',
        createdFromTemplate: false,
        sharedWith: const ['avi-cohen-001', 'ronit-cohen-002'],
        items: childItems,
        createdDate: date,
        updatedDate: date.add(const Duration(days: 2)),
      );
    });
  }
}

// =============================================================================
// PERSONA 2: Heavy Organizer (Naama)
// =============================================================================

class HeavyOrganizerPersona {
  static UserEntity get naama => UserEntity(
        id: 'naama-001',
        name: 'נעמה שמעון',
        email: 'naama@demo.com',
        householdId: 'household_naama',
        householdName: 'הבית של נעמה',
        joinedAt: DateTime(2025, 2, 1),
        preferredStores: const ['שופרסל', 'רמי לוי', 'יוחננוף', 'מחסני השוק', 'ויקטורי'],
        familySize: 3,
        shoppingFrequency: 4,
        shoppingDays: const [0, 2, 4, 5],
        hasChildren: true,
        shareLists: false,
        seenOnboarding: true,
      );

  static const _categories = [
    'מוצרי חלב', 'לחם ומאפים', 'פירות וירקות', 'בשר ועוף',
    'דגים', 'שימורים', 'אורז ופסטה', 'תבלינים ואפייה',
    'משקאות', 'ממתקים וחטיפים', 'מוצרי ניקיון', 'היגיינה ויופי',
  ];

  /// Generate 200+ categorized inventory items
  static List<InventoryItem> generateInventory(int count) {
    return List.generate(count, (i) {
      final cat = _categories[i % _categories.length];
      return InventoryItem(
        id: 'inv-naama-$i',
        productName: 'מוצר $i ($cat)',
        category: cat,
        location: i % 3 == 0 ? 'מקרר' : (i % 3 == 1 ? 'מקפיא' : 'ארון'),
        quantity: (i % 10) + 1,
        unit: "יח'",
        minQuantity: 2,
        isRecurring: i % 4 == 0,
        notes: i % 5 == 0 ? 'הערה למוצר $i' : null,
      );
    });
  }

  /// Generate multiple custom lists
  static List<ShoppingList> generateLists(int count) {
    final types = ['supermarket', 'pharmacy', 'bakery', 'butcher', 'greengrocer'];
    return List.generate(count, (i) {
      return ShoppingList(
        id: 'naama-list-$i',
        name: 'רשימה ${i + 1}',
        status: i < count - 2 ? 'completed' : 'active',
        type: types[i % types.length],
        createdBy: 'naama-001',
        isShared: false,
        format: 'personal',
        createdFromTemplate: false,
        sharedWith: const [],
        items: List.generate(
          10 + (i * 3),
          (j) => UnifiedListItem(
            id: 'item-$i-$j',
            name: 'פריט $j ברשימה $i',
            type: ItemType.product,
            category: _categories[j % _categories.length],
            isChecked: j < 5,
            notes: j % 3 == 0 ? 'הערה מפורטת לפריט $j' : null,
          ),
        ),
        createdDate: DateTime(2026, 1, 1 + i),
        updatedDate: DateTime(2026, 1, 2 + i),
      );
    });
  }
}

// =============================================================================
// PERSONA 3: Unstable Connection User (Tomer)
// =============================================================================

class UnstableConnectionPersona {
  static UserEntity get tomer => UserEntity(
        id: 'tomer-001',
        name: 'תומר בר',
        email: 'tomer@demo.com',
        householdId: 'household_tomer',
        householdName: 'הבית של תומר',
        joinedAt: DateTime(2025, 6, 1),
        preferredStores: const ['AM:PM'],
        familySize: 1,
        shoppingFrequency: 1,
        shoppingDays: const [5],
        hasChildren: false,
        shareLists: false,
        seenOnboarding: true,
      );

  /// Simulates items created offline with pending sync
  static List<UnifiedListItem> get offlineCreatedItems => [
        const UnifiedListItem(
          id: 'offline-1',
          name: 'חלב',
          type: ItemType.product,
          productData: {'quantity': 1},
        ),
        const UnifiedListItem(
          id: 'offline-2',
          name: 'לחם',
          type: ItemType.product,
          productData: {'quantity': 2},
          isChecked: true,
        ),
        const UnifiedListItem(
          id: 'offline-3',
          name: 'ביצים',
          type: ItemType.product,
          productData: {'quantity': 1},
        ),
      ];

  /// Same items with quantity changes (simulating offline edits)
  static List<UnifiedListItem> get editedOfflineItems => [
        const UnifiedListItem(
          id: 'offline-1',
          name: 'חלב',
          type: ItemType.product,
          productData: {'quantity': 3}, // changed from 1 → 3
        ),
        const UnifiedListItem(
          id: 'offline-2',
          name: 'לחם',
          type: ItemType.product,
          productData: {'quantity': 2},
          isChecked: false, // unchecked offline
        ),
        const UnifiedListItem(
          id: 'offline-3',
          name: 'ביצים',
          type: ItemType.product,
          productData: {'quantity': 2}, // changed 1 → 2
          isChecked: true, // checked offline
        ),
      ];

  static ShoppingList get activeList => ShoppingList(
        id: 'tomer-active-001',
        name: 'סופר מהיר',
        status: 'active',
        type: 'supermarket',
        createdBy: 'tomer-001',
        isShared: false,
        format: 'personal',
        createdFromTemplate: false,
        sharedWith: const [],
        items: offlineCreatedItems,
        createdDate: DateTime(2026, 3, 15),
        updatedDate: DateTime(2026, 3, 15),
      );
}

void main() {
  // This is a helper file for test fixtures, not a test file itself.
}
