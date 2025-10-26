// 🧪 Unit Tests: SuggestionsService
//
// Tests for:
// - generateSuggestions(): Creating suggestions from low inventory
// - getActiveSuggestions(): Filtering active suggestions
// - getNextSuggestion(): Getting next suggestion from queue
// - dismissSuggestion(): Temporary dismissal
// - deleteSuggestion(): Temporary or permanent deletion
// - markAsAdded(): Marking as added to list
// - getDurationFromChoice(): Converting choice to Duration
// - getDurationText(): Duration description text
// - getSuggestionsStats(): Statistics calculation
// - hasUrgentSuggestions(): Checking for urgent suggestions
// - getActiveSuggestionsCount(): Counting active suggestions

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/smart_suggestion.dart';
import 'package:memozap/models/enums/suggestion_status.dart';
import 'package:memozap/services/suggestions_service.dart';

void main() {
  // Helper function to create test inventory items
  InventoryItem createInventoryItem({
    required String id,
    required String productName,
    required int quantity,
    String category = 'מוצרי מזון',
    String unit = 'יחידות',
  }) {
    return InventoryItem(
      id: id,
      productName: productName,
      category: category,
      location: 'מזווה',
      quantity: quantity,
      unit: unit,
    );
  }

  group('generateSuggestions()', () {
    test('generates suggestions for low stock items', () {
      // Arrange
      final items = [
        createInventoryItem(id: 'item1', productName: 'חלב', quantity: 2),
        createInventoryItem(id: 'item2', productName: 'לחם', quantity: 10),
        createInventoryItem(id: 'item3', productName: 'ביצים', quantity: 0),
      ];

      // Act
      final suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: items,
      );

      // Assert
      expect(suggestions.length, 2); // חלב + ביצים (below threshold 5)
      expect(suggestions.any((s) => s.productName == 'חלב'), true);
      expect(suggestions.any((s) => s.productName == 'ביצים'), true);
      expect(suggestions.any((s) => s.productName == 'לחם'), false);
    });

    test('uses custom thresholds when provided', () {
      // Arrange
      final items = [
        createInventoryItem(id: 'item1', productName: 'חלב', quantity: 8),
        createInventoryItem(id: 'item2', productName: 'לחם', quantity: 2),
      ];

      final customThresholds = {
        'חלב': 10, // חלב needs to be > 10
        'לחם': 3, // לחם needs to be > 3
      };

      // Act
      final suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: items,
        customThresholds: customThresholds,
      );

      // Assert
      expect(suggestions.length, 2); // both below their custom thresholds
      expect(suggestions.any((s) => s.productName == 'חלב'), true);
      expect(suggestions.any((s) => s.productName == 'לחם'), true);
    });

    test('excludes products from suggestions', () {
      // Arrange
      final items = [
        createInventoryItem(id: 'item1', productName: 'חלב', quantity: 2),
        createInventoryItem(id: 'item2', productName: 'לחם', quantity: 1),
        createInventoryItem(id: 'item3', productName: 'ביצים', quantity: 0),
      ];

      final excludedProducts = {'חלב', 'ביצים'};

      // Act
      final suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: items,
        excludedProducts: excludedProducts,
      );

      // Assert
      expect(suggestions.length, 1); // only לחם
      expect(suggestions.first.productName, 'לחם');
    });

    test('sorts by urgency: critical → high → medium → low', () {
      // Arrange
      final items = [
        createInventoryItem(id: 'item1', productName: 'A_Low', quantity: 4), // low (4/5)
        createInventoryItem(id: 'item2', productName: 'B_Critical', quantity: 0), // critical (0/5)
        createInventoryItem(id: 'item3', productName: 'C_Medium', quantity: 2), // medium (2/5)
        createInventoryItem(id: 'item4', productName: 'D_High', quantity: 1), // high (1/5)
      ];

      // Act
      final suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: items,
      );

      // Assert
      expect(suggestions.length, 4);
      expect(suggestions[0].urgency, 'critical'); // B_Critical
      expect(suggestions[1].urgency, 'high'); // D_High
      expect(suggestions[2].urgency, 'medium'); // C_Medium
      expect(suggestions[3].urgency, 'low'); // A_Low
    });

    test('sorts alphabetically within same urgency level', () {
      // Arrange
      final items = [
        createInventoryItem(id: 'item1', productName: 'זית', quantity: 0),
        createInventoryItem(id: 'item2', productName: 'אבוקדו', quantity: 0),
        createInventoryItem(id: 'item3', productName: 'גבינה', quantity: 0),
      ];

      // Act
      final suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: items,
      );

      // Assert
      expect(suggestions[0].productName, 'אבוקדו'); // alphabetically first
      expect(suggestions[1].productName, 'גבינה');
      expect(suggestions[2].productName, 'זית');
    });

    test('returns empty list when no low stock items', () {
      // Arrange
      final items = [
        createInventoryItem(id: 'item1', productName: 'חלב', quantity: 10),
        createInventoryItem(id: 'item2', productName: 'לחם', quantity: 20),
      ];

      // Act
      final suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: items,
      );

      // Assert
      expect(suggestions, isEmpty);
    });

    test('returns empty list when inventory is empty', () {
      // Act
      final suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: [],
      );

      // Assert
      expect(suggestions, isEmpty);
    });

    test('sets correct urgency levels', () {
      // Arrange
      final items = [
        createInventoryItem(id: 'item1', productName: 'Critical', quantity: 0), // 0/5 = 0%
        createInventoryItem(id: 'item2', productName: 'High', quantity: 1), // 1/5 = 20% (< 20% threshold)
        createInventoryItem(id: 'item3', productName: 'Medium', quantity: 2), // 2/5 = 40% (20-50%)
        createInventoryItem(id: 'item4', productName: 'Low', quantity: 4), // 4/5 = 80% (> 50%)
      ];

      // Act
      final suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: items,
      );

      // Assert
      expect(suggestions[0].urgency, 'critical');
      expect(suggestions[1].urgency, 'high');
      expect(suggestions[2].urgency, 'medium');
      expect(suggestions[3].urgency, 'low');
    });
  });

  group('getActiveSuggestions()', () {
    test('returns only pending suggestions', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = <SmartSuggestion>[
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יחידות',
          status: SuggestionStatus.pending,
          suggestedAt: now,
        ),
        SmartSuggestion(
          id: '2',
          productId: 'p2',
          productName: 'לחם',
          category: 'מאפים',
          currentStock: 1,
          threshold: 5,
          quantityNeeded: 4,
          unit: 'יחידות',
          status: SuggestionStatus.added,
          suggestedAt: now,
          addedAt: now,
        ),
        SmartSuggestion(
          id: '3',
          productId: 'p3',
          productName: 'ביצים',
          category: 'מוצרי חלב',
          currentStock: 0,
          threshold: 5,
          quantityNeeded: 5,
          unit: 'יחידות',
          status: SuggestionStatus.deleted,
          suggestedAt: now,
        ),
      ];

      // Act
      final active = SuggestionsService.getActiveSuggestions(suggestions);

      // Assert
      expect(active.length, 1); // only חלב (pending)
      expect(active.first.productName, 'חלב');
    });

    test('filters out dismissed suggestions with active dismissedUntil', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = [
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'medium',
          status: SuggestionStatus.pending,
          createdAt: now,
          dismissedUntil: now.add(const Duration(days: 7)), // future
        ),
        SmartSuggestion(
          id: '2',
          productId: 'p2',
          productName: 'לחם',
          category: 'מאפים',
          currentStock: 1,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'high',
          status: SuggestionStatus.pending,
          createdAt: now,
          dismissedUntil: now.subtract(const Duration(days: 1)), // past
        ),
      ];

      // Act
      final active = SuggestionsService.getActiveSuggestions(suggestions);

      // Assert
      expect(active.length, 1); // only לחם (dismissedUntil is past)
      expect(active.first.productName, 'לחם');
    });

    test('returns empty list when no active suggestions', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = [
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'medium',
          status: SuggestionStatus.added,
          createdAt: now,
        ),
      ];

      // Act
      final active = SuggestionsService.getActiveSuggestions(suggestions);

      // Assert
      expect(active, isEmpty);
    });
  });

  group('getNextSuggestion()', () {
    test('returns the most urgent active suggestion', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = [
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'Low',
          category: 'מוצרי מזון',
          currentStock: 4,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'low',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
        SmartSuggestion(
          id: '2',
          productId: 'p2',
          productName: 'Critical',
          category: 'מוצרי מזון',
          currentStock: 0,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'critical',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
        SmartSuggestion(
          id: '3',
          productId: 'p3',
          productName: 'Medium',
          category: 'מוצרי מזון',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'medium',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
      ];

      // Act
      final next = SuggestionsService.getNextSuggestion(suggestions);

      // Assert
      expect(next, isNotNull);
      expect(next!.productName, 'Critical');
      expect(next.urgency, 'critical');
    });

    test('returns null when no active suggestions', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = [
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'medium',
          status: SuggestionStatus.added,
          createdAt: now,
        ),
      ];

      // Act
      final next = SuggestionsService.getNextSuggestion(suggestions);

      // Assert
      expect(next, isNull);
    });

    test('returns null when list is empty', () {
      // Act
      final next = SuggestionsService.getNextSuggestion([]);

      // Assert
      expect(next, isNull);
    });
  });

  group('dismissSuggestion()', () {
    test('sets status to dismissed with default duration', () {
      // Arrange
      final now = DateTime.now();
      final suggestion = SmartSuggestion(
        id: '1',
        productId: 'p1',
        productName: 'חלב',
        category: 'מוצרי חלב',
        currentStock: 2,
        threshold: 5,
        unit: 'יחידות',
        urgency: 'medium',
        status: SuggestionStatus.pending,
        createdAt: now,
      );

      // Act
      final dismissed = SuggestionsService.dismissSuggestion(suggestion);

      // Assert
      expect(dismissed.status, SuggestionStatus.dismissed);
      expect(dismissed.dismissedUntil, isNotNull);
      expect(
        dismissed.dismissedUntil!.isAfter(now.add(const Duration(days: 6))),
        true,
      ); // ~7 days
    });

    test('uses custom duration when provided', () {
      // Arrange
      final now = DateTime.now();
      final suggestion = SmartSuggestion(
        id: '1',
        productId: 'p1',
        productName: 'חלב',
        category: 'מוצרי חלב',
        currentStock: 2,
        threshold: 5,
        unit: 'יחידות',
        urgency: 'medium',
        status: SuggestionStatus.pending,
        createdAt: now,
      );

      // Act
      final dismissed = SuggestionsService.dismissSuggestion(
        suggestion,
        duration: const Duration(days: 1),
      );

      // Assert
      expect(dismissed.dismissedUntil, isNotNull);
      expect(
        dismissed.dismissedUntil!.isBefore(now.add(const Duration(days: 2))),
        true,
      ); // ~1 day
    });
  });

  group('deleteSuggestion()', () {
    test('permanently deletes when duration is null', () {
      // Arrange
      final now = DateTime.now();
      final suggestion = SmartSuggestion(
        id: '1',
        productId: 'p1',
        productName: 'חלב',
        category: 'מוצרי חלב',
        currentStock: 2,
        threshold: 5,
        unit: 'יחידות',
        urgency: 'medium',
        status: SuggestionStatus.pending,
        createdAt: now,
      );

      // Act
      final deleted = SuggestionsService.deleteSuggestion(
        suggestion,
        duration: null,
      );

      // Assert
      expect(deleted.status, SuggestionStatus.deleted);
      expect(deleted.dismissedUntil, isNull);
    });

    test('temporarily deletes when duration is provided', () {
      // Arrange
      final now = DateTime.now();
      final suggestion = SmartSuggestion(
        id: '1',
        productId: 'p1',
        productName: 'חלב',
        category: 'מוצרי חלב',
        currentStock: 2,
        threshold: 5,
        unit: 'יחידות',
        urgency: 'medium',
        status: SuggestionStatus.pending,
        createdAt: now,
      );

      // Act
      final deleted = SuggestionsService.deleteSuggestion(
        suggestion,
        duration: const Duration(days: 30),
      );

      // Assert
      expect(deleted.status, SuggestionStatus.dismissed);
      expect(deleted.dismissedUntil, isNotNull);
      expect(
        deleted.dismissedUntil!.isAfter(now.add(const Duration(days: 29))),
        true,
      ); // ~30 days
    });
  });

  group('markAsAdded()', () {
    test('sets status to added with listId', () {
      // Arrange
      final now = DateTime.now();
      final suggestion = SmartSuggestion(
        id: '1',
        productId: 'p1',
        productName: 'חלב',
        category: 'מוצרי חלב',
        currentStock: 2,
        threshold: 5,
        unit: 'יחידות',
        urgency: 'medium',
        status: SuggestionStatus.pending,
        createdAt: now,
      );

      // Act
      final added = SuggestionsService.markAsAdded(
        suggestion,
        listId: 'list123',
      );

      // Assert
      expect(added.status, SuggestionStatus.added);
      expect(added.addedToListId, 'list123');
      expect(added.addedAt, isNotNull);
    });
  });

  group('getDurationFromChoice()', () {
    test('returns correct duration for day', () {
      final duration = SuggestionsService.getDurationFromChoice('day');
      expect(duration, const Duration(days: 1));
    });

    test('returns correct duration for week', () {
      final duration = SuggestionsService.getDurationFromChoice('week');
      expect(duration, const Duration(days: 7));
    });

    test('returns correct duration for month', () {
      final duration = SuggestionsService.getDurationFromChoice('month');
      expect(duration, const Duration(days: 30));
    });

    test('returns null for forever', () {
      final duration = SuggestionsService.getDurationFromChoice('forever');
      expect(duration, isNull);
    });

    test('returns default duration for unknown choice', () {
      final duration = SuggestionsService.getDurationFromChoice('unknown');
      expect(duration, const Duration(days: 7)); // default
    });
  });

  group('getDurationText()', () {
    test('returns correct text for null (forever)', () {
      final text = SuggestionsService.getDurationText(null);
      expect(text, 'לעולם לא');
    });

    test('returns correct text for 1 day', () {
      final text = SuggestionsService.getDurationText(const Duration(days: 1));
      expect(text, 'יום אחד');
    });

    test('returns correct text for 7 days', () {
      final text = SuggestionsService.getDurationText(const Duration(days: 7));
      expect(text, 'שבוע');
    });

    test('returns correct text for 30 days', () {
      final text = SuggestionsService.getDurationText(const Duration(days: 30));
      expect(text, 'חודש');
    });

    test('returns correct text for custom days', () {
      final text = SuggestionsService.getDurationText(const Duration(days: 15));
      expect(text, '15 ימים');
    });
  });

  group('getSuggestionsStats()', () {
    test('calculates stats correctly', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = [
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'Critical',
          category: 'מוצרי מזון',
          currentStock: 0,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'critical',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
        SmartSuggestion(
          id: '2',
          productId: 'p2',
          productName: 'High',
          category: 'מוצרי מזון',
          currentStock: 1,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'high',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
        SmartSuggestion(
          id: '3',
          productId: 'p3',
          productName: 'Added',
          category: 'מוצרי מזון',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'medium',
          status: SuggestionStatus.added,
          createdAt: now,
          addedAt: now,
        ),
        SmartSuggestion(
          id: '4',
          productId: 'p4',
          productName: 'Dismissed',
          category: 'מוצרי מזון',
          currentStock: 3,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'low',
          status: SuggestionStatus.dismissed,
          createdAt: now,
          dismissedUntil: now.add(const Duration(days: 7)),
        ),
      ];

      // Act
      final stats = SuggestionsService.getSuggestionsStats(suggestions);

      // Assert
      expect(stats['total'], 4);
      expect(stats['active'], 2); // critical + high
      expect(stats['critical'], 1);
      expect(stats['high'], 1);
      expect(stats['medium'], 0);
      expect(stats['low'], 0);
      expect(stats['added'], 1);
      expect(stats['dismissed'], 1);
    });

    test('returns zero stats for empty list', () {
      // Act
      final stats = SuggestionsService.getSuggestionsStats([]);

      // Assert
      expect(stats['total'], 0);
      expect(stats['active'], 0);
    });
  });

  group('hasUrgentSuggestions()', () {
    test('returns true when critical suggestions exist', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = [
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'Critical',
          category: 'מוצרי מזון',
          currentStock: 0,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'critical',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
      ];

      // Act
      final hasUrgent = SuggestionsService.hasUrgentSuggestions(suggestions);

      // Assert
      expect(hasUrgent, true);
    });

    test('returns true when high suggestions exist', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = [
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'High',
          category: 'מוצרי מזון',
          currentStock: 1,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'high',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
      ];

      // Act
      final hasUrgent = SuggestionsService.hasUrgentSuggestions(suggestions);

      // Assert
      expect(hasUrgent, true);
    });

    test('returns false when only medium/low suggestions exist', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = [
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'Medium',
          category: 'מוצרי מזון',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'medium',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
      ];

      // Act
      final hasUrgent = SuggestionsService.hasUrgentSuggestions(suggestions);

      // Assert
      expect(hasUrgent, false);
    });

    test('returns false for empty list', () {
      // Act
      final hasUrgent = SuggestionsService.hasUrgentSuggestions([]);

      // Assert
      expect(hasUrgent, false);
    });
  });

  group('getActiveSuggestionsCount()', () {
    test('counts only active suggestions', () {
      // Arrange
      final now = DateTime.now();
      final suggestions = [
        SmartSuggestion(
          id: '1',
          productId: 'p1',
          productName: 'Active1',
          category: 'מוצרי מזון',
          currentStock: 0,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'critical',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
        SmartSuggestion(
          id: '2',
          productId: 'p2',
          productName: 'Active2',
          category: 'מוצרי מזון',
          currentStock: 1,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'high',
          status: SuggestionStatus.pending,
          createdAt: now,
        ),
        SmartSuggestion(
          id: '3',
          productId: 'p3',
          productName: 'Added',
          category: 'מוצרי מזון',
          currentStock: 2,
          threshold: 5,
          unit: 'יחידות',
          urgency: 'medium',
          status: SuggestionStatus.added,
          createdAt: now,
        ),
      ];

      // Act
      final count = SuggestionsService.getActiveSuggestionsCount(suggestions);

      // Assert
      expect(count, 2); // Active1 + Active2
    });

    test('returns 0 for empty list', () {
      // Act
      final count = SuggestionsService.getActiveSuggestionsCount([]);

      // Assert
      expect(count, 0);
    });
  });
}
