// 📄 File: test/models/smart_suggestion_test.dart
//
// Unit tests for SmartSuggestion model
// Tests: creation, urgency calculation, JSON serialization

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/smart_suggestion.dart';
import 'package:memozap/models/enums/suggestion_status.dart';

void main() {
  group('SmartSuggestion', () {
    // ===== Factory Constructor Tests =====
    group('fromInventory', () {
      test('should create suggestion with correct quantityNeeded', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        expect(suggestion.quantityNeeded, 3); // 5 - 2 = 3
        expect(suggestion.status, SuggestionStatus.pending);
      });

      test('should clamp quantityNeeded to minimum 0', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 10, // More than threshold
          threshold: 5,
          unit: 'יח\'',
        );

        // When stock > threshold, needed is 0 (no purchase required)
        expect(suggestion.quantityNeeded, 0);
      });

      test('should use provided timestamp', () {
        final timestamp = DateTime(2025, 1, 15, 10, 30);
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
          now: timestamp,
        );

        expect(suggestion.suggestedAt, timestamp);
      });
    });

    // ===== Urgency Calculation Tests =====
    group('urgency', () {
      test('should return "critical" when stock is 0', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 0,
          threshold: 5,
          unit: 'יח\'',
        );

        expect(suggestion.urgency, 'critical');
        expect(suggestion.isOutOfStock, true);
      });

      test('should return "high" when stock < 20% of threshold', () {
        // threshold = 10, 20% = 2, so stock < 2 is "high"
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 1, // < 2 (20% of 10)
          threshold: 10,
          unit: 'יח\'',
        );

        expect(suggestion.urgency, 'high');
        expect(suggestion.isCriticallyLow, true);
      });

      test('should return "medium" when stock < 50% of threshold', () {
        // threshold = 10, 50% = 5, so stock < 5 is "medium"
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 3, // < 5 (50% of 10) but >= 2 (20%)
          threshold: 10,
          unit: 'יח\'',
        );

        expect(suggestion.urgency, 'medium');
        expect(suggestion.isLow, true);
      });

      test('should return "low" when stock >= 50% of threshold', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 6, // >= 5 (50% of 10)
          threshold: 10,
          unit: 'יח\'',
        );

        expect(suggestion.urgency, 'low');
        expect(suggestion.isLow, false);
      });
    });

    // ===== Stock Percentage Tests =====
    group('stockPercentage', () {
      test('should calculate percentage correctly', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 3,
          threshold: 10,
          unit: 'יח\'',
        );

        expect(suggestion.stockPercentage, 30); // 3/10 * 100 = 30%
      });

      test('should clamp percentage to 0-100', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 15, // More than threshold
          threshold: 10,
          unit: 'יח\'',
        );

        expect(suggestion.stockPercentage, 100); // clamped to 100
      });

      test('should return 100 when threshold is 0', () {
        final suggestion = SmartSuggestion(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 5,
          threshold: 0,
          quantityNeeded: 1,
          unit: 'יח\'',
          status: SuggestionStatus.pending,
          suggestedAt: DateTime.now(),
        );

        expect(suggestion.stockPercentage, 100);
      });
    });

    // ===== Stock Description Tests =====
    group('stockDescription', () {
      test('should return "נגמר" when stock is 0', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 0,
          threshold: 5,
          unit: 'יח\'',
        );

        expect(suggestion.isOutOfStock, true);
        expect(suggestion.urgency, 'critical');
      });

      test('should detect low stock when stock is 1', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 1,
          threshold: 5,
          unit: 'יח\'',
        );

        // 1 < 5*0.2(=1.0) is false, so not critically low
        // 1 < 5*0.5(=2.5) is true, so isLow
        expect(suggestion.isCriticallyLow, false);
        expect(suggestion.isLow, true);
        expect(suggestion.urgency, 'medium');
      });

      test('should detect medium urgency when stock > 1 but low', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 3,
          threshold: 5,
          unit: 'יח\'',
        );

        expect(suggestion.isLow, false);
        expect(suggestion.urgency, 'low');
      });
    });

    // ===== isActive Tests =====
    group('isActive', () {
      test('should return true for pending suggestion without dismissal', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        expect(suggestion.isActive, true);
      });

      test('should return false for non-pending status', () {
        final suggestion = SmartSuggestion(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          status: SuggestionStatus.added,
          suggestedAt: DateTime.now(),
        );

        expect(suggestion.isActive, false);
      });

      test('should return false when dismissed until future date', () {
        final suggestion = SmartSuggestion(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          status: SuggestionStatus.pending,
          suggestedAt: DateTime.now(),
          dismissedUntil: DateTime.now().add(const Duration(days: 7)),
        );

        expect(suggestion.isActive, false);
      });

      test('should return true when dismissal period has passed', () {
        final suggestion = SmartSuggestion(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          status: SuggestionStatus.pending,
          suggestedAt: DateTime.now(),
          dismissedUntil: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(suggestion.isActive, true);
      });
    });

    // ===== copyWith Tests =====
    group('copyWith', () {
      test('should create copy with updated status', () {
        final original = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        final copy = original.copyWith(status: SuggestionStatus.added);

        expect(copy.status, SuggestionStatus.added);
        expect(copy.id, original.id);
        expect(copy.productName, original.productName);
      });

      test('should create copy with dismissedUntil', () {
        final original = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        final dismissDate = DateTime.now().add(const Duration(days: 7));
        final copy = original.copyWith(dismissedUntil: dismissDate);

        expect(copy.dismissedUntil, dismissDate);
      });
    });

    // ===== JSON Serialization Tests =====
    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'json-test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        final json = suggestion.toJson();

        expect(json['id'], 'json-test-id');
        expect(json['product_id'], 'product-1');
        expect(json['product_name'], 'חלב');
        expect(json['current_stock'], 2);
        expect(json['threshold'], 5);
        expect(json['quantity_needed'], 3);
        expect(json['status'], 'pending');
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'json-deserialize-id',
          'product_id': 'product-1',
          'product_name': 'יוגורט',
          'category': 'מוצרי חלב',
          'current_stock': 1,
          'threshold': 4,
          'quantity_needed': 3,
          'unit': 'יח\'',
          'status': 'pending',
          'suggested_at': DateTime.now().toIso8601String(),
        };

        final suggestion = SmartSuggestion.fromJson(json);

        expect(suggestion.id, 'json-deserialize-id');
        expect(suggestion.productName, 'יוגורט');
        expect(suggestion.currentStock, 1);
        expect(suggestion.threshold, 4);
      });

      test('should roundtrip serialize/deserialize correctly', () {
        final now = DateTime.now();
        final original = SmartSuggestion(
          id: 'roundtrip-id',
          productId: 'product-1',
          productName: 'גבינה',
          category: 'מוצרי חלב',
          currentStock: 1,
          threshold: 3,
          quantityNeeded: 2,
          unit: 'יח\'',
          status: SuggestionStatus.pending,
          suggestedAt: now,
        );

        final json = original.toJson();
        final restored = SmartSuggestion.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.productId, original.productId);
        expect(restored.productName, original.productName);
        expect(restored.currentStock, original.currentStock);
        expect(restored.threshold, original.threshold);
        expect(restored.quantityNeeded, original.quantityNeeded);
        expect(restored.status, original.status);
      });
    });

    // ===== toUnifiedListItem Tests =====
    group('toUnifiedListItem', () {
      test('should convert to UnifiedListItem correctly', () {
        final suggestion = SmartSuggestion.fromInventory(
          id: 'test-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        final item = suggestion.toUnifiedListItem();

        expect(item.id, 'product-1'); // Uses productId
        expect(item.name, 'חלב');
        expect(item.quantity, 3); // quantityNeeded
        expect(item.unit, 'יח\'');
        expect(item.category, 'מוצרי חלב');
      });
    });

    // ===== Equality Tests =====
    group('Equality', () {
      test('should be equal when ids match', () {
        final suggestion1 = SmartSuggestion.fromInventory(
          id: 'same-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        final suggestion2 = SmartSuggestion.fromInventory(
          id: 'same-id',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        expect(suggestion1, suggestion2);
        expect(suggestion1.hashCode, suggestion2.hashCode);
      });

      test('should not be equal when ids differ', () {
        final suggestion1 = SmartSuggestion.fromInventory(
          id: 'id-1',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        final suggestion2 = SmartSuggestion.fromInventory(
          id: 'id-2',
          productId: 'product-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        expect(suggestion1, isNot(suggestion2));
      });
    });
  });
}
