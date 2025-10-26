// 🧪 Test File: test/services/suggestions_service_test.dart
// Description: Unit tests for SuggestionsService
//
// Test Coverage:
// ✅ generateSuggestions() - Creating suggestions from inventory
// ✅ getActiveSuggestions() - Filtering active suggestions
// ✅ getNextSuggestion() - Getting next from queue
// ✅ dismissSuggestion() - Temporary dismissal
// ✅ deleteSuggestion() - Temporary/permanent deletion
// ✅ markAsAdded() - Marking as added to list
// ✅ getDurationFromChoice() - Duration parsing
// ✅ getDurationText() - Duration description
// ✅ getSuggestionsStats() - Statistics calculation
// ✅ hasUrgentSuggestions() - Urgency checking
// ✅ getActiveSuggestionsCount() - Active count

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/smart_suggestion.dart';
import 'package:memozap/models/enums/suggestion_status.dart';
import 'package:memozap/services/suggestions_service.dart';

void main() {
  group('SuggestionsService Tests', () {
    // Test data
    late InventoryItem lowStockItem1;
    late InventoryItem lowStockItem2;
    late InventoryItem normalStockItem;
    late InventoryItem outOfStockItem;

    setUp(() {
      // נוצר לפני כל טסט
      lowStockItem1 = InventoryItem(
        id: 'item1',
        productName: 'חלב',
        category: 'חלב וביצים',
        quantity: 2, // נמוך מ-5 (threshold)
        unit: 'יחידות',
        householdId: 'household1',
        addedBy: 'user1',
        addedDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      lowStockItem2 = InventoryItem(
        id: 'item2',
        productName: 'לחם',
        category: 'לחם ומאפים',
        quantity: 3, // נמוך מ-5
        unit: 'יחידות',
        householdId: 'household1',
        addedBy: 'user1',
        addedDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      normalStockItem = InventoryItem(
        id: 'item3',
        productName: 'שמן',
        category: 'שמנים',
        quantity: 10, // מלאי תקין
        unit: 'יחידות',
        householdId: 'household1',
        addedBy: 'user1',
        addedDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      outOfStockItem = InventoryItem(
        id: 'item4',
        productName: 'סוכר',
        category: 'אפייה',
        quantity: 0, // אזל!
        unit: 'יחידות',
        householdId: 'household1',
        addedBy: 'user1',
        addedDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );
    });

    group('generateSuggestions() Tests', () {
      test('generates suggestions for low stock items', () {
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [lowStockItem1, lowStockItem2, normalStockItem],
        );

        // צריך ליצור 2 המלצות (חלב + לחם, לא שמן)
        expect(suggestions.length, 2);
        expect(
          suggestions.any((s) => s.productName == 'חלב'),
          true,
        );
        expect(
          suggestions.any((s) => s.productName == 'לחם'),
          true,
        );
        expect(
          suggestions.any((s) => s.productName == 'שמן'),
          false,
        );
      });

      test('sorts suggestions by urgency (critical first)', () {
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [outOfStockItem, lowStockItem1, lowStockItem2],
        );

        // אזל צריך להיות ראשון (critical)
        expect(suggestions.first.productName, 'סוכר');
        expect(suggestions.first.urgency, 'critical');
        expect(suggestions.first.currentStock, 0);
      });

      test('respects custom thresholds', () {
        // סף מותאם: חלב צריך 10 (לא 5)
        final customThresholds = {'חלב': 10};

        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [lowStockItem1, normalStockItem],
          customThresholds: customThresholds,
        );

        // חלב צריך להיות במלצות (2 < 10)
        expect(suggestions.length, 1);
        expect(suggestions.first.productName, 'חלב');
        expect(suggestions.first.threshold, 10);
      });

      test('excludes deleted products', () {
        final excludedProducts = {'חלב'};

        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [lowStockItem1, lowStockItem2],
          excludedProducts: excludedProducts,
        );

        // חלב לא צריך להיות בהמלצות
        expect(suggestions.length, 1);
        expect(suggestions.first.productName, 'לחם');
        expect(
          suggestions.any((s) => s.productName == 'חלב'),
          false,
        );
      });

      test('returns empty list when all items have sufficient stock', () {
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [normalStockItem],
        );

        expect(suggestions.isEmpty, true);
      });

      test('handles empty inventory list', () {
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [],
        );

        expect(suggestions.isEmpty, true);
      });
    });

    group('getActiveSuggestions() Tests', () {
      test('returns only pending suggestions', () {
        final suggestions = [
          SmartSuggestion.fromInventory(
            id: 's1',
            productId: 'p1',
            productName: 'חלב',
            category: 'חלב',
            currentStock: 2,
            threshold: 5,
            unit: 'יחידות',
            now: DateTime.now(),
          ),
          SmartSuggestion.fromInventory(
            id: 's2',
            productId: 'p2',
            productName: 'לחם',
            category: 'לחם',
            currentStock: 1,
            threshold: 5,
            unit: 'יחידות',
            now: DateTime.now(),
          ).copyWith(status: SuggestionStatus.added), // נוסף
        ];

        final active = SuggestionsService.getActiveSuggestions(suggestions);

        expect(active.length, 1);
        expect(active.first.productName, 'חלב');
      });

      test('filters out dismissed suggestions that havent expired', () {
        final now = DateTime.now();
        final dismissedUntil = now.add(const Duration(days: 1));

        final suggestions = [
          SmartSuggestion.fromInventory(
            id: 's1',
            productId: 'p1',
            productName: 'חלב',
            category: 'חלב',
            currentStock: 2,
            threshold: 5,
            unit: 'יחידות',
            now: now,
          ).copyWith(
            status: SuggestionStatus.dismissed,
            dismissedUntil: dismissedUntil,
          ),
        ];

        final active = SuggestionsService.getActiveSuggestions(suggestions);

        // לא צריך להיות פעיל (נדחה עד מחר)
        expect(active.isEmpty, true);
      });

      test('includes expired dismissed suggestions', () {
        final now = DateTime.now();
        final dismissedUntil = now.subtract(const Duration(days: 1));

        final suggestions = [
          SmartSuggestion.fromInventory(
            id: 's1',
            productId: 'p1',
            productName: 'חלב',
            category: 'חלב',
            currentStock: 2,
            threshold: 5,
            unit: 'יחידות',
            now: now,
          ).copyWith(
            status: SuggestionStatus.pending,
            dismissedUntil: dismissedUntil, // פג תוקף
          ),
        ];

        final active = SuggestionsService.getActiveSuggestions(suggestions);

        // צריך להיות פעיל (הדחייה פגה)
        expect(active.length, 1);
        expect(active.first.productName, 'חלב');
      });
    });

    group('getNextSuggestion() Tests', () {
      test('returns most urgent active suggestion', () {
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [
            outOfStockItem, // critical
            lowStockItem1, // high
            lowStockItem2, // high
          ],
        );

        final next = SuggestionsService.getNextSuggestion(suggestions);

        expect(next, isNotNull);
        expect(next!.productName, 'סוכר'); // אזל = critical
        expect(next.urgency, 'critical');
      });

      test('returns null when no active suggestions', () {
        final suggestions = [
          SmartSuggestion.fromInventory(
            id: 's1',
            productId: 'p1',
            productName: 'חלב',
            category: 'חלב',
            currentStock: 2,
            threshold: 5,
            unit: 'יחידות',
            now: DateTime.now(),
          ).copyWith(status: SuggestionStatus.added),
        ];

        final next = SuggestionsService.getNextSuggestion(suggestions);

        expect(next, isNull);
      });

      test('returns null when suggestions list is empty', () {
        final next = SuggestionsService.getNextSuggestion([]);

        expect(next, isNull);
      });
    });

    group('dismissSuggestion() Tests', () {
      test('sets status to dismissed with future date', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 's1',
          productId: 'p1',
          productName: 'חלב',
          category: 'חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          now: DateTime.now(),
        );

        final dismissed = SuggestionsService.dismissSuggestion(suggestion);

        expect(dismissed.status, SuggestionStatus.dismissed);
        expect(dismissed.dismissedUntil, isNotNull);
        expect(
          dismissed.dismissedUntil!.isAfter(DateTime.now()),
          true,
        );
      });

      test('uses custom duration when provided', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 's1',
          productId: 'p1',
          productName: 'חלב',
          category: 'חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          now: DateTime.now(),
        );

        final dismissed = SuggestionsService.dismissSuggestion(
          suggestion,
          duration: const Duration(days: 30),
        );

        final expectedDate = DateTime.now().add(const Duration(days: 30));
        final actualDate = dismissed.dismissedUntil!;

        // בדיקה שההפרש קטן מדקה (כדי להתמודד עם זמן ריצה)
        expect(
          actualDate.difference(expectedDate).inMinutes.abs(),
          lessThan(1),
        );
      });

      test('uses default 7 days when no duration provided', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 's1',
          productId: 'p1',
          productName: 'חלב',
          category: 'חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          now: DateTime.now(),
        );

        final dismissed = SuggestionsService.dismissSuggestion(suggestion);

        final expectedDate = DateTime.now().add(const Duration(days: 7));
        final actualDate = dismissed.dismissedUntil!;

        expect(
          actualDate.difference(expectedDate).inMinutes.abs(),
          lessThan(1),
        );
      });
    });

    group('deleteSuggestion() Tests', () {
      test('sets status to deleted when duration is null (permanent)', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 's1',
          productId: 'p1',
          productName: 'חלב',
          category: 'חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          now: DateTime.now(),
        );

        final deleted = SuggestionsService.deleteSuggestion(
          suggestion,
          duration: null,
        );

        expect(deleted.status, SuggestionStatus.deleted);
        expect(deleted.dismissedUntil, isNull);
      });

      test('dismisses temporarily when duration provided', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 's1',
          productId: 'p1',
          productName: 'חלב',
          category: 'חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          now: DateTime.now(),
        );

        final deleted = SuggestionsService.deleteSuggestion(
          suggestion,
          duration: const Duration(days: 1),
        );

        expect(deleted.status, SuggestionStatus.dismissed);
        expect(deleted.dismissedUntil, isNotNull);
      });
    });

    group('markAsAdded() Tests', () {
      test('sets status to added and stores list ID', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 's1',
          productId: 'p1',
          productName: 'חלב',
          category: 'חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          now: DateTime.now(),
        );

        final added = SuggestionsService.markAsAdded(
          suggestion,
          listId: 'list123',
        );

        expect(added.status, SuggestionStatus.added);
        expect(added.addedToListId, 'list123');
        expect(added.addedAt, isNotNull);
      });

      test('sets addedAt to current time', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 's1',
          productId: 'p1',
          productName: 'חלב',
          category: 'חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          now: DateTime.now(),
        );

        final before = DateTime.now();
        final added = SuggestionsService.markAsAdded(
          suggestion,
          listId: 'list123',
        );
        final after = DateTime.now();

        expect(added.addedAt, isNotNull);
        expect(
          added.addedAt!.isAfter(before.subtract(const Duration(seconds: 1))),
          true,
        );
        expect(
          added.addedAt!.isBefore(after.add(const Duration(seconds: 1))),
          true,
        );
      });
    });

    group('getDurationFromChoice() Tests', () {
      test('returns 1 day for "day"', () {
        final duration = SuggestionsService.getDurationFromChoice('day');
        expect(duration, const Duration(days: 1));
      });

      test('returns 7 days for "week"', () {
        final duration = SuggestionsService.getDurationFromChoice('week');
        expect(duration, const Duration(days: 7));
      });

      test('returns 30 days for "month"', () {
        final duration = SuggestionsService.getDurationFromChoice('month');
        expect(duration, const Duration(days: 30));
      });

      test('returns null for "forever"', () {
        final duration = SuggestionsService.getDurationFromChoice('forever');
        expect(duration, isNull);
      });

      test('returns default (7 days) for unknown choice', () {
        final duration = SuggestionsService.getDurationFromChoice('unknown');
        expect(duration, const Duration(days: 7));
      });
    });

    group('getDurationText() Tests', () {
      test('returns "לעולם לא" for null', () {
        final text = SuggestionsService.getDurationText(null);
        expect(text, 'לעולם לא');
      });

      test('returns "יום אחד" for 1 day', () {
        final text =
            SuggestionsService.getDurationText(const Duration(days: 1));
        expect(text, 'יום אחד');
      });

      test('returns "שבוע" for 7 days', () {
        final text =
            SuggestionsService.getDurationText(const Duration(days: 7));
        expect(text, 'שבוע');
      });

      test('returns "חודש" for 30 days', () {
        final text =
            SuggestionsService.getDurationText(const Duration(days: 30));
        expect(text, 'חודש');
      });

      test('returns days count for other durations', () {
        final text =
            SuggestionsService.getDurationText(const Duration(days: 14));
        expect(text, '14 ימים');
      });
    });

    group('getSuggestionsStats() Tests', () {
      test('calculates correct statistics', () {
        final now = DateTime.now();
        final suggestions = [
          // Active critical
          SmartSuggestion.fromInventory(
            id: 's1',
            productId: 'p1',
            productName: 'סוכר',
            category: 'אפייה',
            currentStock: 0,
            threshold: 5,
            unit: 'יחידות',
            now: now,
          ),
          // Active high
          SmartSuggestion.fromInventory(
            id: 's2',
            productId: 'p2',
            productName: 'חלב',
            category: 'חלב',
            currentStock: 2,
            threshold: 5,
            unit: 'יחידות',
            now: now,
          ),
          // Added
          SmartSuggestion.fromInventory(
            id: 's3',
            productId: 'p3',
            productName: 'לחם',
            category: 'לחם',
            currentStock: 1,
            threshold: 5,
            unit: 'יחידות',
            now: now,
          ).copyWith(status: SuggestionStatus.added),
          // Dismissed
          SmartSuggestion.fromInventory(
            id: 's4',
            productId: 'p4',
            productName: 'ביצים',
            category: 'חלב',
            currentStock: 3,
            threshold: 5,
            unit: 'יחידות',
            now: now,
          ).copyWith(status: SuggestionStatus.dismissed),
        ];

        final stats = SuggestionsService.getSuggestionsStats(suggestions);

        expect(stats['total'], 4);
        expect(stats['active'], 2);
        expect(stats['critical'], 1);
        expect(stats['high'], 1);
        expect(stats['added'], 1);
        expect(stats['dismissed'], 1);
      });

      test('handles empty suggestions list', () {
        final stats = SuggestionsService.getSuggestionsStats([]);

        expect(stats['total'], 0);
        expect(stats['active'], 0);
      });
    });

    group('hasUrgentSuggestions() Tests', () {
      test('returns true when critical suggestions exist', () {
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [outOfStockItem],
        );

        final hasUrgent =
            SuggestionsService.hasUrgentSuggestions(suggestions);

        expect(hasUrgent, true);
      });

      test('returns true when high urgency suggestions exist', () {
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [lowStockItem1],
        );

        final hasUrgent =
            SuggestionsService.hasUrgentSuggestions(suggestions);

        expect(hasUrgent, true);
      });

      test('returns false when only low/medium urgency', () {
        final mediumStockItem = InventoryItem(
          id: 'item5',
          productName: 'קמח',
          category: 'אפייה',
          quantity: 3,
          unit: 'יחידות',
          householdId: 'household1',
          addedBy: 'user1',
          addedDate: DateTime.now(),
          updatedDate: DateTime.now(),
        );

        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [mediumStockItem],
        );

        final hasUrgent =
            SuggestionsService.hasUrgentSuggestions(suggestions);

        expect(hasUrgent, false);
      });

      test('returns false when no active suggestions', () {
        final hasUrgent = SuggestionsService.hasUrgentSuggestions([]);
        expect(hasUrgent, false);
      });
    });

    group('getActiveSuggestionsCount() Tests', () {
      test('returns correct count of active suggestions', () {
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion.fromInventory(
            id: 's1',
            productId: 'p1',
            productName: 'חלב',
            category: 'חלב',
            currentStock: 2,
            threshold: 5,
            unit: 'יחידות',
            now: now,
          ),
          SmartSuggestion.fromInventory(
            id: 's2',
            productId: 'p2',
            productName: 'לחם',
            category: 'לחם',
            currentStock: 1,
            threshold: 5,
            unit: 'יחידות',
            now: now,
          ),
          SmartSuggestion.fromInventory(
            id: 's3',
            productId: 'p3',
            productName: 'ביצים',
            category: 'חלב',
            currentStock: 0,
            threshold: 5,
            unit: 'יחידות',
            now: now,
          ).copyWith(status: SuggestionStatus.added), // לא פעיל
        ];

        final count =
            SuggestionsService.getActiveSuggestionsCount(suggestions);

        expect(count, 2);
      });

      test('returns 0 for empty list', () {
        final count = SuggestionsService.getActiveSuggestionsCount([]);
        expect(count, 0);
      });
    });
  });
}
