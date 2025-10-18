import 'package:flutter_test/flutter_test.dart';
import 'package:salsheli/models/suggestion.dart';

void main() {
  group('Suggestion', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
    });

    test('creates with all required fields', () {
      final suggestion = Suggestion(
        id: 'sug-123',
        productName: 'חלב 3%',
        reason: 'running_low',
        category: 'מוצרי חלב',
        suggestedQuantity: 2,
        unit: 'ליטר',
        priority: 'high',
        source: 'inventory',
        createdAt: testDate,
      );

      expect(suggestion.id, 'sug-123');
      expect(suggestion.productName, 'חלב 3%');
      expect(suggestion.reason, 'running_low');
      expect(suggestion.category, 'מוצרי חלב');
      expect(suggestion.suggestedQuantity, 2);
      expect(suggestion.unit, 'ליטר');
      expect(suggestion.priority, 'high');
      expect(suggestion.source, 'inventory');
      expect(suggestion.createdAt, testDate);
    });

    group('copyWith', () {
      test('updates only specified fields', () {
        final original = Suggestion(
          id: 'sug-123',
          productName: 'חלב',
          reason: 'running_low',
          category: 'מוצרי חלב',
          suggestedQuantity: 2,
          unit: 'ליטר',
          priority: 'medium',
          source: 'inventory',
          createdAt: testDate,
        );

        final updated = original.copyWith(
          priority: 'high',
          suggestedQuantity: 3,
          reason: 'both',
        );

        expect(updated.priority, 'high');
        expect(updated.suggestedQuantity, 3);
        expect(updated.reason, 'both');
        
        // Unchanged fields
        expect(updated.id, original.id);
        expect(updated.productName, original.productName);
        expect(updated.category, original.category);
        expect(updated.unit, original.unit);
        expect(updated.source, original.source);
        expect(updated.createdAt, original.createdAt);
      });
    });

    group('Computed Properties', () {
      test('reasonText returns correct Hebrew text', () {
        final runningLow = Suggestion(
          id: 'sug-1',
          productName: 'מוצר',
          reason: 'running_low',
          category: 'כללי',
          suggestedQuantity: 1,
          unit: 'יח\'',
          priority: 'medium',
          source: 'inventory',
          createdAt: testDate,
        );

        final frequentlyBought = runningLow.copyWith(
          reason: 'frequently_bought',
        );

        final both = runningLow.copyWith(
          reason: 'both',
        );

        final unknown = runningLow.copyWith(
          reason: 'unknown_reason',
        );

        expect(runningLow.reasonText, 'נגמר במזווה');
        expect(frequentlyBought.reasonText, 'נקנה לעיתים קרובות');
        expect(both.reasonText, 'נגמר במזווה ונקנה לעיתים קרובות');
        expect(unknown.reasonText, 'מומלץ');
      });

      test('priorityColor returns correct color codes', () {
        final highPriority = Suggestion(
          id: 'sug-1',
          productName: 'מוצר',
          reason: 'running_low',
          category: 'כללי',
          suggestedQuantity: 1,
          unit: 'יח\'',
          priority: 'high',
          source: 'inventory',
          createdAt: testDate,
        );

        final mediumPriority = highPriority.copyWith(priority: 'medium');
        final lowPriority = highPriority.copyWith(priority: 'low');
        final unknownPriority = highPriority.copyWith(priority: 'unknown');

        expect(highPriority.priorityColor, 0xFFEF5350);  // Red
        expect(mediumPriority.priorityColor, 0xFFFF9800);  // Orange
        expect(lowPriority.priorityColor, 0xFF66BB6A);  // Green
        expect(unknownPriority.priorityColor, 0xFF9E9E9E);  // Gray
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly', () {
        final original = Suggestion(
          id: 'sug-456',
          productName: 'לחם אחיד',
          reason: 'frequently_bought',
          category: 'מאפים',
          suggestedQuantity: 1,
          unit: 'יחידות',
          priority: 'medium',
          source: 'history',
          createdAt: testDate,
        );

        final json = original.toJson();
        final restored = Suggestion.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.productName, original.productName);
        expect(restored.reason, original.reason);
        expect(restored.category, original.category);
        expect(restored.suggestedQuantity, original.suggestedQuantity);
        expect(restored.unit, original.unit);
        expect(restored.priority, original.priority);
        expect(restored.source, original.source);
        expect(restored.createdAt, original.createdAt);
      });

      test('handles default values in JSON', () {
        final json = {
          'id': 'sug-minimal',
          'product_name': 'מוצר',
          'created_at': testDate.toIso8601String(),
          // All other fields missing - should use defaults
        };

        final suggestion = Suggestion.fromJson(json);

        expect(suggestion.id, 'sug-minimal');
        expect(suggestion.productName, 'מוצר');
        expect(suggestion.reason, 'frequently_bought');
        expect(suggestion.category, 'כללי');
        expect(suggestion.suggestedQuantity, 1);
        expect(suggestion.unit, 'יחידות');
        expect(suggestion.priority, 'medium');
        expect(suggestion.source, 'inventory');
      });

      test('JSON structure uses snake_case', () {
        final suggestion = Suggestion(
          id: 'sug-789',
          productName: 'מוצר בדיקה',
          reason: 'running_low',
          category: 'קטגוריה',
          suggestedQuantity: 5,
          unit: 'ק"ג',
          priority: 'high',
          source: 'both',
          createdAt: testDate,
        );

        final json = suggestion.toJson();

        expect(json.containsKey('product_name'), true);
        expect(json.containsKey('suggested_quantity'), true);
        expect(json.containsKey('created_at'), true);
        expect(json['product_name'], 'מוצר בדיקה');
        expect(json['suggested_quantity'], 5);
      });
    });

    group('Equality and HashCode', () {
      test('equality is based on id only', () {
        final suggestion1 = Suggestion(
          id: 'same-id',
          productName: 'מוצר 1',
          reason: 'running_low',
          category: 'כללי',
          suggestedQuantity: 1,
          unit: 'יח\'',
          priority: 'high',
          source: 'inventory',
          createdAt: testDate,
        );

        final suggestion2 = Suggestion(
          id: 'same-id',
          productName: 'מוצר 2',
          reason: 'frequently_bought',
          category: 'אחר',
          suggestedQuantity: 5,
          unit: 'ק"ג',
          priority: 'low',
          source: 'history',
          createdAt: DateTime.now(),
        );

        final suggestion3 = Suggestion(
          id: 'different-id',
          productName: 'מוצר 1',
          reason: 'running_low',
          category: 'כללי',
          suggestedQuantity: 1,
          unit: 'יח\'',
          priority: 'high',
          source: 'inventory',
          createdAt: testDate,
        );

        expect(suggestion1 == suggestion2, true);
        expect(suggestion1 == suggestion3, false);
        expect(suggestion1.hashCode, suggestion2.hashCode);
        expect(suggestion1.hashCode, isNot(suggestion3.hashCode));
      });

      test('identical instances are equal', () {
        final suggestion = Suggestion(
          id: 'test',
          productName: 'בדיקה',
          reason: 'running_low',
          category: 'כללי',
          suggestedQuantity: 1,
          unit: 'יח\'',
          priority: 'medium',
          source: 'inventory',
          createdAt: testDate,
        );

        expect(suggestion == suggestion, true);
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        final suggestion = Suggestion(
          id: 'sug-123',
          productName: 'חלב תנובה',
          reason: 'running_low',
          category: 'מוצרי חלב',
          suggestedQuantity: 2,
          unit: 'ליטר',
          priority: 'high',
          source: 'inventory',
          createdAt: testDate,
        );

        final str = suggestion.toString();

        expect(str, contains('sug-123'));
        expect(str, contains('חלב תנובה'));
        expect(str, contains('running_low'));
        expect(str, contains('high'));
      });
    });

    group('Common use cases', () {
      test('creates inventory-based suggestion', () {
        final suggestion = Suggestion(
          id: 'sug-inv-1',
          productName: 'אורז',
          reason: 'running_low',
          category: 'יבשים',
          suggestedQuantity: 1,
          unit: 'ק"ג',
          priority: 'high',
          source: 'inventory',
          createdAt: testDate,
        );

        expect(suggestion.source, 'inventory');
        expect(suggestion.reason, 'running_low');
        expect(suggestion.reasonText, 'נגמר במזווה');
      });

      test('creates history-based suggestion', () {
        final suggestion = Suggestion(
          id: 'sug-hist-1',
          productName: 'חלב',
          reason: 'frequently_bought',
          category: 'מוצרי חלב',
          suggestedQuantity: 2,
          unit: 'ליטר',
          priority: 'medium',
          source: 'history',
          createdAt: testDate,
        );

        expect(suggestion.source, 'history');
        expect(suggestion.reason, 'frequently_bought');
        expect(suggestion.reasonText, 'נקנה לעיתים קרובות');
      });

      test('creates combined suggestion', () {
        final suggestion = Suggestion(
          id: 'sug-both-1',
          productName: 'ביצים',
          reason: 'both',
          category: 'חלבון',
          suggestedQuantity: 12,
          unit: 'יחידות',
          priority: 'high',
          source: 'both',
          createdAt: testDate,
        );

        expect(suggestion.source, 'both');
        expect(suggestion.reason, 'both');
        expect(suggestion.reasonText, 'נגמר במזווה ונקנה לעיתים קרובות');
      });
    });
  });
}
