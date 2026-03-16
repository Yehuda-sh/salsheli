// 📄 test/performance/large_list_test.dart
// Performance tests: serialization, filtering, sorting on large datasets.

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/unified_list_item.dart';
import 'package:memozap/models/enums/item_type.dart';

void main() {
  group('Performance - ShoppingList with 1000+ items', () {
    late ShoppingList largeList;

    setUp(() {
      final items = List.generate(
        1000,
        (i) => UnifiedListItem(
          id: 'perf-item-$i',
          name: 'מוצר מספר $i עם שם ארוך',
          type: i % 5 == 0 ? ItemType.task : ItemType.product,
          isChecked: i % 3 == 0,
          category: ['מוצרי חלב', 'לחם', 'ירקות', 'בשר', 'ניקיון'][i % 5],
          notes: i % 4 == 0 ? 'הערה למוצר $i' : null,
          productData: i % 5 != 0
              ? {'quantity': i % 10 + 1, 'unit_price': (i % 50) * 1.5}
              : null,
        ),
      );

      largeList = ShoppingList(
        id: 'perf-list-1',
        name: 'רשימה ענקית',
        status: 'active',
        type: 'supermarket',
        createdBy: 'perf-user',
        isShared: false,
        format: 'shared',
        createdFromTemplate: false,
        sharedWith: const [],
        items: items,
        createdDate: DateTime(2026, 3, 15),
        updatedDate: DateTime(2026, 3, 15),
      );
    });

    test('toJson serialization < 500ms', () {
      final sw = Stopwatch()..start();
      final json = largeList.toJson();
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(500),
          reason: 'toJson took ${sw.elapsedMilliseconds}ms');
      expect(json['items'], isA<List>());
      expect((json['items'] as List).length, 1000);
    });

    test('fromJson deserialization < 500ms', () {
      final json = largeList.toJson();

      final sw = Stopwatch()..start();
      final restored = ShoppingList.fromJson(json);
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(500),
          reason: 'fromJson took ${sw.elapsedMilliseconds}ms');
      expect(restored.items.length, 1000);
    });

    test('filter checked items on 1000-item list', () {
      final sw = Stopwatch()..start();
      final checked = largeList.items.where((i) => i.isChecked).toList();
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(50));
      expect(checked.length, greaterThan(0));
      // Every 3rd item is checked (indices 0,3,6...) = 334 items
      expect(checked.length, 334);
    });

    test('search by name substring', () {
      final sw = Stopwatch()..start();
      final results = largeList.items
          .where((i) => i.name.contains('500'))
          .toList();
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(50));
      expect(results, isNotEmpty);
    });

    test('group by category', () {
      final sw = Stopwatch()..start();
      final grouped = <String, List<UnifiedListItem>>{};
      for (final item in largeList.items) {
        final cat = item.category ?? 'אחר';
        grouped.putIfAbsent(cat, () => []).add(item);
      }
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(50));
      expect(grouped.keys.length, 5);
      // 1000 items / 5 categories = 200 each
      expect(grouped['מוצרי חלב']!.length, 200);
    });
  });

  group('Performance - InventoryItem large list', () {
    late List<InventoryItem> largeInventory;

    setUp(() {
      largeInventory = List.generate(
        500,
        (i) => InventoryItem(
          id: 'inv-perf-$i',
          productName: 'מוצר מלאי $i',
          category: ['מקרר', 'מקפיא', 'ארון', 'מזווה', 'חדר'][i % 5],
          location: ['מדף עליון', 'מדף תחתון', 'מגירה'][i % 3],
          quantity: i % 8,
          unit: "יח'",
          minQuantity: 3,
          isRecurring: i % 4 == 0,
        ),
      );
    });

    test('sort by category < 50ms', () {
      final sw = Stopwatch()..start();
      final sorted = List<InventoryItem>.from(largeInventory)
        ..sort((a, b) => a.category.compareTo(b.category));
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(50));
      expect(sorted.first.category, 'ארון');
    });

    test('filter low stock items', () {
      final sw = Stopwatch()..start();
      final lowStock = largeInventory
          .where((i) => i.quantity < i.minQuantity)
          .toList();
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(50));
      // items with quantity 0,1,2 (< minQuantity 3) = indices where i%8 is 0,1,2
      expect(lowStock.length, greaterThan(100));
    });

    test('toJson/fromJson round-trip for 500 items', () {
      final sw = Stopwatch()..start();
      for (final item in largeInventory) {
        final json = item.toJson();
        InventoryItem.fromJson(json);
      }
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(1000),
          reason: '500 round-trips took ${sw.elapsedMilliseconds}ms');
    });
  });
}
