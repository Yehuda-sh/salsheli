// 📄 test/models/unified_list_item_test.dart
// Edge cases for UnifiedListItem: special chars, massive quantities, unknown types, round-trip.

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/unified_list_item.dart';
import 'package:memozap/models/enums/item_type.dart';

void main() {
  group('UnifiedListItem - Construction', () {
    test('basic product creation', () {
      const item = UnifiedListItem(
        id: 'test-1',
        name: 'חלב 3%',
        type: ItemType.product,
      );
      expect(item.id, 'test-1');
      expect(item.name, 'חלב 3%');
      expect(item.type, ItemType.product);
      expect(item.isChecked, false);
      expect(item.category, isNull);
    });

    test('task creation', () {
      const item = UnifiedListItem(
        id: 'task-1',
        name: 'להזמין פיצה',
        type: ItemType.task,
        taskData: {'priority': 'high'},
      );
      expect(item.type, ItemType.task);
      expect(item.taskData?['priority'], 'high');
    });
  });

  group('UnifiedListItem - Special Characters', () {
    test('emoji in name', () {
      const item = UnifiedListItem(
        id: 'emoji-1',
        name: '🥛 חלב טרי 🐄',
        type: ItemType.product,
      );
      expect(item.name, contains('🥛'));
      expect(item.name, contains('🐄'));
    });

    test('Hebrew with nikud', () {
      const item = UnifiedListItem(
        id: 'nikud-1',
        name: 'חָלָב',
        type: ItemType.product,
      );
      expect(item.name, 'חָלָב');
    });

    test('very long name (500 chars)', () {
      final longName = 'א' * 500;
      final item = UnifiedListItem(
        id: 'long-1',
        name: longName,
        type: ItemType.product,
      );
      expect(item.name.length, 500);
    });

    test('special characters and punctuation', () {
      const item = UnifiedListItem(
        id: 'special-1',
        name: 'חלב 3% (תנובה) - 1 ליטר [גדול]',
        type: ItemType.product,
      );
      expect(item.name, contains('3%'));
      expect(item.name, contains('[גדול]'));
    });
  });

  group('UnifiedListItem - productData edge cases', () {
    test('massive quantity', () {
      const item = UnifiedListItem(
        id: 'mass-1',
        name: 'בקבוקי מים',
        type: ItemType.product,
        productData: {'quantity': 999999},
      );
      expect(item.quantity, 999999);
    });

    test('zero quantity', () {
      const item = UnifiedListItem(
        id: 'zero-1',
        name: 'חלב',
        type: ItemType.product,
        productData: {'quantity': 0},
      );
      expect(item.quantity, 0);
    });

    test('null productData returns default quantity', () {
      const item = UnifiedListItem(
        id: 'null-pd-1',
        name: 'חלב',
        type: ItemType.product,
      );
      expect(item.quantity, isNull); // no productData → null
    });

    test('price calculation', () {
      const item = UnifiedListItem(
        id: 'price-1',
        name: 'חלב',
        type: ItemType.product,
        productData: {'quantity': 3, 'unit_price': 7.5},
      );
      expect(item.totalPrice, 22.5);
    });
  });

  group('UnifiedListItem - fromJson', () {
    test('basic JSON parsing', () {
      final json = {
        'id': 'json-1',
        'name': 'חלב',
        'type': 'product',
        'is_checked': false,
      };
      final item = UnifiedListItem.fromJson(json);
      expect(item.id, 'json-1');
      expect(item.name, 'חלב');
      expect(item.type, ItemType.product);
    });

    test('missing optional fields still parse', () {
      final json = <String, dynamic>{
        'id': 'min-1',
        'name': 'פריט',
        'type': 'product',
      };
      final item = UnifiedListItem.fromJson(json);
      expect(item.id, 'min-1');
      expect(item.name, 'פריט');
      expect(item.isChecked, false);
      expect(item.category, isNull);
      expect(item.notes, isNull);
    });

    test('unknown type string', () {
      final json = {
        'id': 'unknown-1',
        'name': 'שירות מיוחד',
        'type': 'service',
      };
      // json_serializable with unknownEnumValue handles this
      final item = UnifiedListItem.fromJson(json);
      expect(item.type, ItemType.unknown);
    });
  });

  group('UnifiedListItem - Round-trip (toJson → fromJson)', () {
    test('product round-trip preserves all fields', () {
      const original = UnifiedListItem(
        id: 'rt-1',
        name: 'שוקולד 🍫',
        type: ItemType.product,
        isChecked: true,
        category: 'ממתקים',
        notes: 'של Elite',
        productData: {'quantity': 5, 'unit_price': 8.9, 'unit': "יח'"},
        checkedBy: 'user-123',
        checkedAt: '2026-03-15T10:00:00Z',
      );

      final json = original.toJson();
      final restored = UnifiedListItem.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.type, original.type);
      expect(restored.isChecked, original.isChecked);
      expect(restored.category, original.category);
      expect(restored.notes, original.notes);
      expect(restored.checkedBy, original.checkedBy);
      expect(restored.quantity, original.quantity);
    });

    test('unknown type in round-trip', () {
      final json = {
        'id': 'rt-unknown',
        'name': 'שירות',
        'type': 'service',
      };
      final item = UnifiedListItem.fromJson(json);
      expect(item.type, ItemType.unknown);

      final reJson = item.toJson();
      // After round-trip, type becomes the string representation of ItemType.unknown
      expect(reJson['type'], isNotNull);
    });

    test('task round-trip', () {
      const original = UnifiedListItem(
        id: 'rt-task-1',
        name: 'להזמין DJ',
        type: ItemType.task,
        taskData: {'priority': 'high', 'assigned_to': 'user-456'},
      );

      final json = original.toJson();
      final restored = UnifiedListItem.fromJson(json);

      expect(restored.type, ItemType.task);
      expect(restored.taskData?['priority'], 'high');
    });
  });

  group('UnifiedListItem - copyWith', () {
    test('change isChecked', () {
      const original = UnifiedListItem(
        id: 'cw-1',
        name: 'חלב',
        type: ItemType.product,
        isChecked: false,
      );
      final checked = original.copyWith(isChecked: true);
      expect(checked.isChecked, true);
      expect(checked.id, original.id);
      expect(checked.name, original.name);
    });

    test('change name preserves other fields', () {
      const original = UnifiedListItem(
        id: 'cw-2',
        name: 'חלב',
        type: ItemType.product,
        category: 'חלב',
        notes: 'של תנובה',
      );
      final renamed = original.copyWith(name: 'חלב טרי');
      expect(renamed.name, 'חלב טרי');
      expect(renamed.category, 'חלב');
      expect(renamed.notes, 'של תנובה');
    });
  });
}
