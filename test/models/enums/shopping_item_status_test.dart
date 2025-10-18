import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:salsheli/models/enums/shopping_item_status.dart';

void main() {
  group('ShoppingItemStatus', () {
    group('label property', () {
      test('returns correct Hebrew labels', () {
        // The actual labels come from AppStrings, but we'll test the mapping works
        expect(ShoppingItemStatus.pending.label, isNotEmpty);
        expect(ShoppingItemStatus.purchased.label, isNotEmpty);
        expect(ShoppingItemStatus.outOfStock.label, isNotEmpty);
        expect(ShoppingItemStatus.deferred.label, isNotEmpty);
        expect(ShoppingItemStatus.notNeeded.label, isNotEmpty);
      });

      test('each status has unique label', () {
        final labels = ShoppingItemStatus.values.map((s) => s.label).toSet();
        expect(labels.length, ShoppingItemStatus.values.length);
      });
    });

    group('icon property', () {
      test('returns correct icons for each status', () {
        expect(ShoppingItemStatus.pending.icon, Icons.radio_button_unchecked);
        expect(ShoppingItemStatus.purchased.icon, Icons.check_circle);
        expect(ShoppingItemStatus.outOfStock.icon, Icons.remove_shopping_cart);
        expect(ShoppingItemStatus.deferred.icon, Icons.schedule);
        expect(ShoppingItemStatus.notNeeded.icon, Icons.block);
      });

      test('each status has unique icon', () {
        final icons = ShoppingItemStatus.values.map((s) => s.icon).toSet();
        expect(icons.length, ShoppingItemStatus.values.length);
      });
    });

    group('color property', () {
      test('returns correct colors for each status', () {
        // We can't test exact color values without importing StatusColors,
        // but we can verify each status returns a color
        expect(ShoppingItemStatus.pending.color, isA<Color>());
        expect(ShoppingItemStatus.purchased.color, isA<Color>());
        expect(ShoppingItemStatus.outOfStock.color, isA<Color>());
        expect(ShoppingItemStatus.deferred.color, isA<Color>());
        expect(ShoppingItemStatus.notNeeded.color, isA<Color>());
      });

      test('each status has unique color', () {
        final colors = ShoppingItemStatus.values.map((s) => s.color).toSet();
        expect(colors.length, ShoppingItemStatus.values.length);
      });
    });

    group('isCompleted property', () {
      test('pending is not completed', () {
        expect(ShoppingItemStatus.pending.isCompleted, false);
      });

      test('purchased is completed', () {
        expect(ShoppingItemStatus.purchased.isCompleted, true);
      });

      test('outOfStock is completed', () {
        expect(ShoppingItemStatus.outOfStock.isCompleted, true);
      });

      test('deferred is completed', () {
        expect(ShoppingItemStatus.deferred.isCompleted, true);
      });

      test('notNeeded is completed', () {
        expect(ShoppingItemStatus.notNeeded.isCompleted, true);
      });

      test('only pending is not completed', () {
        final incompleteStatuses = ShoppingItemStatus.values
            .where((s) => !s.isCompleted)
            .toList();
        
        expect(incompleteStatuses.length, 1);
        expect(incompleteStatuses.first, ShoppingItemStatus.pending);
      });
    });

    group('enum values', () {
      test('has exactly 5 values', () {
        expect(ShoppingItemStatus.values.length, 5);
      });

      test('contains all expected values', () {
        expect(ShoppingItemStatus.values, contains(ShoppingItemStatus.pending));
        expect(ShoppingItemStatus.values, contains(ShoppingItemStatus.purchased));
        expect(ShoppingItemStatus.values, contains(ShoppingItemStatus.outOfStock));
        expect(ShoppingItemStatus.values, contains(ShoppingItemStatus.deferred));
        expect(ShoppingItemStatus.values, contains(ShoppingItemStatus.notNeeded));
      });

      test('values have correct order', () {
        expect(ShoppingItemStatus.values[0], ShoppingItemStatus.pending);
        expect(ShoppingItemStatus.values[1], ShoppingItemStatus.purchased);
        expect(ShoppingItemStatus.values[2], ShoppingItemStatus.outOfStock);
        expect(ShoppingItemStatus.values[3], ShoppingItemStatus.deferred);
        expect(ShoppingItemStatus.values[4], ShoppingItemStatus.notNeeded);
      });
    });

    group('Use cases', () {
      test('can filter completed items', () {
        final allStatuses = ShoppingItemStatus.values;
        final completedStatuses = allStatuses.where((s) => s.isCompleted).toList();
        
        expect(completedStatuses.length, 4);
        expect(completedStatuses, isNot(contains(ShoppingItemStatus.pending)));
      });

      test('can filter pending items', () {
        final allStatuses = ShoppingItemStatus.values;
        final pendingStatuses = allStatuses.where((s) => !s.isCompleted).toList();
        
        expect(pendingStatuses.length, 1);
        expect(pendingStatuses.first, ShoppingItemStatus.pending);
      });

      test('can create status map for counting', () {
        final statusCounts = <ShoppingItemStatus, int>{};
        
        for (final status in ShoppingItemStatus.values) {
          statusCounts[status] = 0;
        }
        
        expect(statusCounts.length, 5);
        expect(statusCounts.containsKey(ShoppingItemStatus.pending), true);
        expect(statusCounts.containsKey(ShoppingItemStatus.purchased), true);
        expect(statusCounts.containsKey(ShoppingItemStatus.outOfStock), true);
        expect(statusCounts.containsKey(ShoppingItemStatus.deferred), true);
        expect(statusCounts.containsKey(ShoppingItemStatus.notNeeded), true);
      });

      test('can be used in switch statement', () {
        String getStatusDescription(ShoppingItemStatus status) {
          switch (status) {
            case ShoppingItemStatus.pending:
              return 'מחכה לקנייה';
            case ShoppingItemStatus.purchased:
              return 'נקנה בהצלחה';
            case ShoppingItemStatus.outOfStock:
              return 'לא היה במלאי';
            case ShoppingItemStatus.deferred:
              return 'נדחה לפעם הבאה';
            case ShoppingItemStatus.notNeeded:
              return 'לא נחוץ';
          }
        }

        expect(getStatusDescription(ShoppingItemStatus.pending), 'מחכה לקנייה');
        expect(getStatusDescription(ShoppingItemStatus.purchased), 'נקנה בהצלחה');
        expect(getStatusDescription(ShoppingItemStatus.outOfStock), 'לא היה במלאי');
        expect(getStatusDescription(ShoppingItemStatus.deferred), 'נדחה לפעם הבאה');
        expect(getStatusDescription(ShoppingItemStatus.notNeeded), 'לא נחוץ');
      });

      test('can calculate shopping progress', () {
        // Simulate a shopping list with different statuses
        final items = [
          ShoppingItemStatus.purchased,
          ShoppingItemStatus.purchased,
          ShoppingItemStatus.outOfStock,
          ShoppingItemStatus.pending,
          ShoppingItemStatus.pending,
          ShoppingItemStatus.deferred,
        ];
        
        final completedCount = items.where((s) => s.isCompleted).length;
        final totalCount = items.length;
        final progressPercentage = (completedCount / totalCount * 100).round();
        
        expect(completedCount, 4);
        expect(totalCount, 6);
        expect(progressPercentage, 67);
      });

      test('can determine if shopping is finished', () {
        // All completed
        final finishedShopping = [
          ShoppingItemStatus.purchased,
          ShoppingItemStatus.purchased,
          ShoppingItemStatus.outOfStock,
          ShoppingItemStatus.deferred,
        ];
        
        final isFinished = finishedShopping.every((s) => s.isCompleted);
        expect(isFinished, true);
        
        // Some pending
        final inProgressShopping = [
          ShoppingItemStatus.purchased,
          ShoppingItemStatus.pending,
          ShoppingItemStatus.outOfStock,
        ];
        
        final isInProgress = inProgressShopping.every((s) => s.isCompleted);
        expect(isInProgress, false);
      });

      test('can group items by status', () {
        final items = [
          ('חלב', ShoppingItemStatus.purchased),
          ('לחם', ShoppingItemStatus.purchased),
          ('ביצים', ShoppingItemStatus.outOfStock),
          ('גבינה', ShoppingItemStatus.pending),
          ('עגבניות', ShoppingItemStatus.pending),
          ('מלפפון', ShoppingItemStatus.deferred),
        ];
        
        final grouped = <ShoppingItemStatus, List<String>>{};
        
        for (final (name, status) in items) {
          grouped.putIfAbsent(status, () => []).add(name);
        }
        
        expect(grouped[ShoppingItemStatus.purchased]?.length, 2);
        expect(grouped[ShoppingItemStatus.pending]?.length, 2);
        expect(grouped[ShoppingItemStatus.outOfStock]?.length, 1);
        expect(grouped[ShoppingItemStatus.deferred]?.length, 1);
        expect(grouped[ShoppingItemStatus.notNeeded], isNull);
      });
    });

    group('Visual representation', () {
      test('each status has complete visual identity', () {
        for (final status in ShoppingItemStatus.values) {
          // Each status should have all visual properties defined
          expect(status.label, isNotEmpty, reason: 'Status $status should have a label');
          expect(status.icon, isNotNull, reason: 'Status $status should have an icon');
          expect(status.color, isNotNull, reason: 'Status $status should have a color');
        }
      });

      test('pending status uses unchecked icon', () {
        // Pending should look "empty" or "unchecked"
        expect(ShoppingItemStatus.pending.icon, Icons.radio_button_unchecked);
      });

      test('purchased status uses check icon', () {
        // Purchased should have a checkmark
        expect(ShoppingItemStatus.purchased.icon, Icons.check_circle);
      });

      test('outOfStock status uses cart removal icon', () {
        // Out of stock should indicate unavailability
        expect(ShoppingItemStatus.outOfStock.icon, Icons.remove_shopping_cart);
      });

      test('deferred status uses schedule icon', () {
        // Deferred should indicate time/scheduling
        expect(ShoppingItemStatus.deferred.icon, Icons.schedule);
      });

      test('notNeeded status uses block icon', () {
        // Not needed should indicate cancellation/blocking
        expect(ShoppingItemStatus.notNeeded.icon, Icons.block);
      });
    });
  });
}
