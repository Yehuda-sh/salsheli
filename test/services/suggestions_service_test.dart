// 📄 File: test/services/suggestions_service_test.dart
//
// Unit tests for SuggestionsService
// Tests: generateSuggestions, filtering, dismissal, statistics

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/enums/suggestion_status.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/smart_suggestion.dart';
import 'package:memozap/services/suggestions_service.dart';

void main() {
  group('SuggestionsService', () {
    // ===== generateSuggestions Tests =====
    group('generateSuggestions', () {
      test('should generate suggestions for items below threshold', () {
        final inventoryItems = [
          const InventoryItem(
            id: 'item-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            location: 'מקרר',
            quantity: 2, // Below default threshold (5)
            unit: 'יח\'',
          ),
          const InventoryItem(
            id: 'item-2',
            productName: 'לחם',
            category: 'מאפים',
            location: 'ארון',
            quantity: 10, // Above default threshold (5)
            unit: 'יח\'',
          ),
        ];

        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventoryItems,
        );

        expect(suggestions.length, 1);
        expect(suggestions.first.productName, 'חלב');
      });

      test('should use custom thresholds when provided', () {
        final inventoryItems = [
          const InventoryItem(
            id: 'item-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            location: 'מקרר',
            quantity: 8, // Below custom threshold (10)
            unit: 'יח\'',
          ),
        ];

        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventoryItems,
          customThresholds: {'חלב': 10},
        );

        expect(suggestions.length, 1);
        expect(suggestions.first.threshold, 10);
      });

      test('should exclude products in excludedProducts set', () {
        final inventoryItems = [
          const InventoryItem(
            id: 'item-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            location: 'מקרר',
            quantity: 2,
            unit: 'יח\'',
          ),
          const InventoryItem(
            id: 'item-2',
            productName: 'לחם',
            category: 'מאפים',
            location: 'ארון',
            quantity: 1,
            unit: 'יח\'',
          ),
        ];

        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventoryItems,
          excludedProducts: {'חלב'},
        );

        expect(suggestions.length, 1);
        expect(suggestions.first.productName, 'לחם');
      });

      test('should sort suggestions by urgency (critical first)', () {
        final inventoryItems = [
          const InventoryItem(
            id: 'item-1',
            productName: 'לחם',
            category: 'מאפים',
            location: 'ארון',
            quantity: 4, // low urgency (close to threshold 5)
            unit: 'יח\'',
          ),
          const InventoryItem(
            id: 'item-2',
            productName: 'חלב',
            category: 'מוצרי חלב',
            location: 'מקרר',
            quantity: 0, // critical urgency
            unit: 'יח\'',
          ),
          const InventoryItem(
            id: 'item-3',
            productName: 'גבינה',
            category: 'מוצרי חלב',
            location: 'מקרר',
            quantity: 2, // medium urgency
            unit: 'יח\'',
          ),
        ];

        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventoryItems,
        );

        expect(suggestions.length, 3);
        expect(suggestions[0].productName, 'חלב'); // critical
        expect(suggestions[0].urgency, 'critical');
      });

      test('should return empty list when no items are below threshold', () {
        final inventoryItems = [
          const InventoryItem(
            id: 'item-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            location: 'מקרר',
            quantity: 10, // Above threshold
            unit: 'יח\'',
          ),
        ];

        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventoryItems,
        );

        expect(suggestions.isEmpty, true);
      });

      test('should return empty list when inventory is empty', () {
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: [],
        );

        expect(suggestions.isEmpty, true);
      });
    });

    // ===== getActiveSuggestions Tests =====
    group('getActiveSuggestions', () {
      test('should return only pending suggestions', () {
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion(
            id: 'sug-1',
            productId: 'prod-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 2,
            threshold: 5,
            quantityNeeded: 3,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
          ),
          SmartSuggestion(
            id: 'sug-2',
            productId: 'prod-2',
            productName: 'לחם',
            category: 'מאפים',
            currentStock: 1,
            threshold: 5,
            quantityNeeded: 4,
            unit: 'יח\'',
            status: SuggestionStatus.added, // Not pending
            suggestedAt: now,
          ),
        ];

        final active = SuggestionsService.getActiveSuggestions(suggestions);

        expect(active.length, 1);
        expect(active.first.productName, 'חלב');
      });

      test('should exclude dismissed suggestions until date passes', () {
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion(
            id: 'sug-1',
            productId: 'prod-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 2,
            threshold: 5,
            quantityNeeded: 3,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
            dismissedUntil: now.add(const Duration(days: 7)), // Still dismissed
          ),
        ];

        final active = SuggestionsService.getActiveSuggestions(suggestions);

        expect(active.isEmpty, true);
      });

      test('should include suggestions where dismissal has passed', () {
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion(
            id: 'sug-1',
            productId: 'prod-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 2,
            threshold: 5,
            quantityNeeded: 3,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
            dismissedUntil: now.subtract(const Duration(days: 1)), // Passed
          ),
        ];

        final active = SuggestionsService.getActiveSuggestions(suggestions);

        expect(active.length, 1);
      });
    });

    // ===== getNextSuggestion Tests =====
    group('getNextSuggestion', () {
      test('should return first active suggestion', () {
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion(
            id: 'sug-1',
            productId: 'prod-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 0, // critical
            threshold: 5,
            quantityNeeded: 5,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
          ),
          SmartSuggestion(
            id: 'sug-2',
            productId: 'prod-2',
            productName: 'לחם',
            category: 'מאפים',
            currentStock: 4, // low
            threshold: 5,
            quantityNeeded: 1,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
          ),
        ];

        final next = SuggestionsService.getNextSuggestion(suggestions);

        expect(next, isNotNull);
        expect(next!.productName, 'חלב');
      });

      test('should return null when no active suggestions', () {
        final suggestions = <SmartSuggestion>[];

        final next = SuggestionsService.getNextSuggestion(suggestions);

        expect(next, isNull);
      });
    });

    // ===== dismissSuggestion Tests =====
    group('dismissSuggestion', () {
      test('should set status to dismissed with default duration', () {
        final now = DateTime.now();
        final suggestion = SmartSuggestion(
          id: 'sug-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          status: SuggestionStatus.pending,
          suggestedAt: now,
        );

        final dismissed = SuggestionsService.dismissSuggestion(suggestion);

        expect(dismissed.status, SuggestionStatus.dismissed);
        expect(dismissed.dismissedUntil, isNotNull);
        // Should be approximately 7 days from now
        expect(
          dismissed.dismissedUntil!.difference(DateTime.now()).inDays,
          greaterThanOrEqualTo(6),
        );
      });

      test('should set custom dismissal duration', () {
        final now = DateTime.now();
        final suggestion = SmartSuggestion(
          id: 'sug-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          status: SuggestionStatus.pending,
          suggestedAt: now,
        );

        final dismissed = SuggestionsService.dismissSuggestion(
          suggestion,
          duration: const Duration(days: 30),
        );

        expect(
          dismissed.dismissedUntil!.difference(DateTime.now()).inDays,
          greaterThanOrEqualTo(29),
        );
      });
    });

    // ===== deleteSuggestion Tests =====
    group('deleteSuggestion', () {
      test('should set status to deleted when duration is null (permanent)', () {
        final now = DateTime.now();
        final suggestion = SmartSuggestion(
          id: 'sug-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          status: SuggestionStatus.pending,
          suggestedAt: now,
        );

        final deleted = SuggestionsService.deleteSuggestion(
          suggestion,
          duration: null,
        );

        expect(deleted.status, SuggestionStatus.deleted);
        expect(deleted.dismissedUntil, isNull);
      });

      test('should set status to dismissed when duration is provided (temporary)', () {
        final now = DateTime.now();
        final suggestion = SmartSuggestion(
          id: 'sug-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          status: SuggestionStatus.pending,
          suggestedAt: now,
        );

        final deleted = SuggestionsService.deleteSuggestion(
          suggestion,
          duration: const Duration(days: 7),
        );

        expect(deleted.status, SuggestionStatus.dismissed);
        expect(deleted.dismissedUntil, isNotNull);
      });
    });

    // ===== markAsAdded Tests =====
    group('markAsAdded', () {
      test('should set status to added with listId', () {
        final now = DateTime.now();
        final suggestion = SmartSuggestion(
          id: 'sug-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          status: SuggestionStatus.pending,
          suggestedAt: now,
        );

        final added = SuggestionsService.markAsAdded(
          suggestion,
          listId: 'list-123',
        );

        expect(added.status, SuggestionStatus.added);
        expect(added.addedToListId, 'list-123');
        expect(added.addedAt, isNotNull);
      });
    });

    // ===== getDurationFromChoice Tests =====
    group('getDurationFromChoice', () {
      test('should return 1 day for "day"', () {
        final duration = SuggestionsService.getDurationFromChoice('day');
        expect(duration, const Duration(days: 1));
      });

      test('should return 7 days for "week"', () {
        final duration = SuggestionsService.getDurationFromChoice('week');
        expect(duration, const Duration(days: 7));
      });

      test('should return 30 days for "month"', () {
        final duration = SuggestionsService.getDurationFromChoice('month');
        expect(duration, const Duration(days: 30));
      });

      test('should return null for "forever"', () {
        final duration = SuggestionsService.getDurationFromChoice('forever');
        expect(duration, isNull);
      });

      test('should return default 7 days for unknown choice', () {
        final duration = SuggestionsService.getDurationFromChoice('unknown');
        expect(duration, const Duration(days: 7));
      });
    });

    // ===== getDurationText Tests =====
    group('getDurationText', () {
      test('should return "לעולם לא" for null duration', () {
        expect(SuggestionsService.getDurationText(null), 'לעולם לא');
      });

      test('should return "יום אחד" for 1 day', () {
        expect(
          SuggestionsService.getDurationText(const Duration(days: 1)),
          'יום אחד',
        );
      });

      test('should return "שבוע" for 7 days', () {
        expect(
          SuggestionsService.getDurationText(const Duration(days: 7)),
          'שבוע',
        );
      });

      test('should return "חודש" for 30 days', () {
        expect(
          SuggestionsService.getDurationText(const Duration(days: 30)),
          'חודש',
        );
      });

      test('should return "X ימים" for other durations', () {
        expect(
          SuggestionsService.getDurationText(const Duration(days: 14)),
          '14 ימים',
        );
      });
    });

    // ===== getSuggestionsStats Tests =====
    group('getSuggestionsStats', () {
      test('should calculate statistics correctly', () {
        final now = DateTime.now();
        final suggestions = [
          // Active, critical
          SmartSuggestion(
            id: 'sug-1',
            productId: 'prod-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 0,
            threshold: 5,
            quantityNeeded: 5,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
          ),
          // Active, medium
          SmartSuggestion(
            id: 'sug-2',
            productId: 'prod-2',
            productName: 'לחם',
            category: 'מאפים',
            currentStock: 2,
            threshold: 5,
            quantityNeeded: 3,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
          ),
          // Added
          SmartSuggestion(
            id: 'sug-3',
            productId: 'prod-3',
            productName: 'גבינה',
            category: 'מוצרי חלב',
            currentStock: 1,
            threshold: 5,
            quantityNeeded: 4,
            unit: 'יח\'',
            status: SuggestionStatus.added,
            suggestedAt: now,
          ),
        ];

        final stats = SuggestionsService.getSuggestionsStats(suggestions);

        expect(stats['total'], 3);
        expect(stats['active'], 2);
        expect(stats['critical'], 1);
        expect(stats['added'], 1);
      });

      test('should return zeros for empty list', () {
        final stats = SuggestionsService.getSuggestionsStats([]);

        expect(stats['total'], 0);
        expect(stats['active'], 0);
      });
    });

    // ===== hasUrgentSuggestions Tests =====
    group('hasUrgentSuggestions', () {
      test('should return true when there are critical suggestions', () {
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion(
            id: 'sug-1',
            productId: 'prod-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 0, // critical
            threshold: 5,
            quantityNeeded: 5,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
          ),
        ];

        expect(SuggestionsService.hasUrgentSuggestions(suggestions), true);
      });

      test('should return true when there are high urgency suggestions', () {
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion(
            id: 'sug-1',
            productId: 'prod-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 1, // high (< 20% of 10)
            threshold: 10,
            quantityNeeded: 9,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
          ),
        ];

        expect(SuggestionsService.hasUrgentSuggestions(suggestions), true);
      });

      test('should return false when only medium/low suggestions', () {
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion(
            id: 'sug-1',
            productId: 'prod-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 4, // low
            threshold: 5,
            quantityNeeded: 1,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
          ),
        ];

        expect(SuggestionsService.hasUrgentSuggestions(suggestions), false);
      });
    });

    // ===== getActiveSuggestionsCount Tests =====
    group('getActiveSuggestionsCount', () {
      test('should return count of active suggestions', () {
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion(
            id: 'sug-1',
            productId: 'prod-1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 2,
            threshold: 5,
            quantityNeeded: 3,
            unit: 'יח\'',
            status: SuggestionStatus.pending,
            suggestedAt: now,
          ),
          SmartSuggestion(
            id: 'sug-2',
            productId: 'prod-2',
            productName: 'לחם',
            category: 'מאפים',
            currentStock: 1,
            threshold: 5,
            quantityNeeded: 4,
            unit: 'יח\'',
            status: SuggestionStatus.added, // Not active
            suggestedAt: now,
          ),
        ];

        expect(SuggestionsService.getActiveSuggestionsCount(suggestions), 1);
      });
    });
  });
}
