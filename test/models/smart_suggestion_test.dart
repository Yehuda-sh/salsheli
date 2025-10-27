// 📄 File: test/models/smart_suggestion_test.dart
//
// 🧪 בדיקות ל-SmartSuggestion Model:
//     - יצירה מ-inventory
//     - computed properties (isActive, urgency, stockPercentage)
//     - JSON serialization
//     - copyWith

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/smart_suggestion.dart';
import 'package:memozap/models/enums/suggestion_status.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('SmartSuggestion', () {
    const uuid = Uuid();

    group('fromInventory factory', () {
      test('יוצר המלצה חדשה בסטטוס pending', () {
        // Act
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.status, SuggestionStatus.pending);
        expect(suggestion.productName, 'חלב');
        expect(suggestion.currentStock, 2);
        expect(suggestion.threshold, 5);
        expect(suggestion.dismissedUntil, isNull);
        expect(suggestion.addedAt, isNull);
      });

      test('מחשב quantityNeeded נכון', () {
        // Act
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 8,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.quantityNeeded, 6); // 8 - 2 = 6
      });

      test('מגביל quantityNeeded למינימום 1', () {
        // Act
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 10, // יותר מהסף!
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.quantityNeeded, 1); // מינימום 1
      });
    });

    group('isActive', () {
      test('true אם pending ולא נדחה', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.isActive, true);
      });

      test('false אם נדחה וזמן הדחייה לא עבר', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        ).copyWith(
          dismissedUntil: DateTime.now().add(const Duration(days: 7)),
        );

        // Assert
        expect(suggestion.isActive, false);
      });

      test('true אם נדחה אבל זמן הדחייה עבר', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        ).copyWith(
          dismissedUntil: DateTime.now().subtract(const Duration(days: 1)),
        );

        // Assert
        expect(suggestion.isActive, true);
      });

      test('false אם הסטטוס לא pending', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        ).copyWith(
          status: SuggestionStatus.added,
        );

        // Assert
        expect(suggestion.isActive, false);
      });
    });

    group('urgency levels', () {
      test('critical אם המלאי אזל (0)', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 0,
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.urgency, 'critical');
        expect(suggestion.isOutOfStock, true);
        expect(suggestion.isCriticallyLow, true);  // ✅ 0 = out of stock AND critically low
        expect(suggestion.isLow, true);  // ✅ כל critically low הוא גם low
      });

      test('high אם < 20% מהסף', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 1, // 1/5 = 20% (גבול, אבל מעל)
          threshold: 10,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.urgency, 'high');
        expect(suggestion.isOutOfStock, false);
        expect(suggestion.isCriticallyLow, true);
        expect(suggestion.isLow, true);
      });

      test('medium אם < 50% מהסף', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2, // 2/5 = 40%
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.urgency, 'medium');
        expect(suggestion.isOutOfStock, false);
        expect(suggestion.isCriticallyLow, false);
        expect(suggestion.isLow, true);
      });

      test('low אם >= 50% מהסף', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 4, // 4/5 = 80%
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.urgency, 'low');
        expect(suggestion.isOutOfStock, false);
        expect(suggestion.isCriticallyLow, false);
        expect(suggestion.isLow, false);
      });
    });

    group('stockPercentage', () {
      test('מחזיר אחוז נכון', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.stockPercentage, 40); // 2/5 * 100 = 40
      });

      test('מוגבל ל-100 אם יותר מהסף', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 10,
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.stockPercentage, 100); // מוגבל ל-100
      });

      test('מחזיר 100 אם סף = 0', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 5,
          threshold: 0,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.stockPercentage, 100);
      });
    });

    group('stockDescription', () {
      test('מחזיר "נגמר!" אם 0', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 0,
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.stockDescription, 'נגמר! צריך לקנות');
      });

      test('מחזיר "נשאר 1 X בלבד" אם 1', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 1,
          threshold: 5,
          unit: 'בקבוקים',
        );

        // Assert
        expect(suggestion.stockDescription, 'נשאר 1 בקבוקים בלבד');
      });

      test('מחזיר "נשארו רק X" אם יותר מ-1', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 3,
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(suggestion.stockDescription, 'נשארו רק 3 יח\'');
      });
    });

    group('copyWith', () {
      test('יוצר עותק עם שינויים', () {
        // Arrange
        final original = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        // Act
        final updated = original.copyWith(
          status: SuggestionStatus.added,
          addedToListId: 'list-123',
          currentStock: 10,
        );

        // Assert
        expect(updated.status, SuggestionStatus.added);
        expect(updated.addedToListId, 'list-123');
        expect(updated.currentStock, 10);
        expect(updated.productName, 'חלב'); // לא השתנה
        expect(updated.id, original.id); // לא השתנה
      });
    });

    group('JSON serialization', () {
      test('toJson ו-fromJson עובדים נכון', () {
        // Arrange
        final original = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        // Act
        final json = original.toJson();
        final restored = SmartSuggestion.fromJson(json);

        // Assert
        expect(restored.id, original.id);
        expect(restored.productName, original.productName);
        expect(restored.currentStock, original.currentStock);
        expect(restored.threshold, original.threshold);
        expect(restored.status, original.status);
      });
    });

    group('equality', () {
      test('שווים אם ID זהה', () {
        // Arrange
        const id = 'test-id-123';
        final s1 = SmartSuggestion.fromInventory(
          id: id,
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        final s2 = SmartSuggestion.fromInventory(
          id: id,
          productId: 'prod-2',
          productName: 'לחם',
          category: 'מאפים',
          currentStock: 1,
          threshold: 3,
          unit: 'יח\'',
        );

        // Assert
        expect(s1, s2); // שווים כי ID זהה
        expect(s1.hashCode, s2.hashCode);
      });

      test('לא שווים אם ID שונה', () {
        // Arrange
        final s1 = SmartSuggestion.fromInventory(
          id: 'id-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        final s2 = SmartSuggestion.fromInventory(
          id: 'id-2',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        // Assert
        expect(s1, isNot(s2)); // לא שווים כי ID שונה
      });
    });
  });
}
