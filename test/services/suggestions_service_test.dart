// 📄 File: test/services/suggestions_service_test.dart
//
// 🧪 בדיקות ל-SuggestionsService:
//     - יצירת המלצות ממלאי נמוך
//     - סינון המלצות פעילות
//     - דחייה זמנית
//     - מחיקה (זמנית/קבועה)
//     - סימון כנוסף
//     - סטטיסטיקות

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/smart_suggestion.dart';
import 'package:memozap/models/enums/suggestion_status.dart';
import 'package:memozap/services/suggestions_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('SuggestionsService', () {
    const uuid = Uuid();

    // Helper: יצירת פריט מלאי
    InventoryItem createInventoryItem({
      required String name,
      required int quantity,
      String category = 'כללי',
      String unit = 'יח\'',
    }) {
      return InventoryItem(
        id: uuid.v4(),
        productName: name,
        category: category,
        location: 'מזווה',
        quantity: quantity,
        unit: unit,
      );
    }

    group('generateSuggestions', () {
      test('יוצר המלצות למוצרים שמתחת לסף', () {
        // Arrange
        final inventory = [
          createInventoryItem(name: 'חלב', quantity: 2), // < 5 ✅
          createInventoryItem(name: 'לחם', quantity: 8), // >= 5 ❌
          createInventoryItem(name: 'ביצים', quantity: 0), // < 5 ✅
          createInventoryItem(name: 'גבינה', quantity: 3), // < 5 ✅
        ];

        // Act
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventory,
        );

        // Assert
        expect(suggestions.length, 3); // חלב, ביצים, גבינה
        expect(suggestions.any((s) => s.productName == 'חלב'), true);
        expect(suggestions.any((s) => s.productName == 'ביצים'), true);
        expect(suggestions.any((s) => s.productName == 'גבינה'), true);
        expect(suggestions.any((s) => s.productName == 'לחם'), false);
      });

      test('ממיין לפי דחיפות: critical → high → medium → low', () {
        // Arrange
        final inventory = [
          createInventoryItem(name: 'לחם', quantity: 3), // medium (60%)
          createInventoryItem(name: 'חלב', quantity: 0), // critical (0%)
          createInventoryItem(name: 'ביצים', quantity: 1), // high (20%)
          createInventoryItem(name: 'גבינה', quantity: 4), // low (80%)
        ];

        // Act
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventory,
        );

        // Assert
        expect(suggestions[0].productName, 'חלב'); // critical
        expect(suggestions[1].productName, 'ביצים'); // high
        expect(suggestions[2].productName, 'לחם'); // medium
        expect(suggestions[3].productName, 'גבינה'); // low

        expect(suggestions[0].urgency, 'critical');
        expect(suggestions[1].urgency, 'high');
        expect(suggestions[2].urgency, 'medium');
        expect(suggestions[3].urgency, 'low');
      });

      test('תומך בספים מותאמים אישית', () {
        // Arrange
        final inventory = [
          createInventoryItem(name: 'חלב', quantity: 8), // < 10 ✅
          createInventoryItem(name: 'לחם', quantity: 3), // < 5 ✅
        ];

        final customThresholds = {
          'חלב': 10, // סף גבוה יותר לחלב
        };

        // Act
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventory,
          customThresholds: customThresholds,
        );

        // Assert
        expect(suggestions.length, 2);
        final milkSuggestion = suggestions.firstWhere((s) => s.productName == 'חלב');
        expect(milkSuggestion.threshold, 10);
        expect(milkSuggestion.currentStock, 8);
      });

      test('מתעלם ממוצרים שנמחקו לצמיתות', () {
        // Arrange
        final inventory = [
          createInventoryItem(name: 'חלב', quantity: 2),
          createInventoryItem(name: 'לחם', quantity: 1),
          createInventoryItem(name: 'ביצים', quantity: 0),
        ];

        final excludedProducts = {'לחם', 'ביצים'};

        // Act
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventory,
          excludedProducts: excludedProducts,
        );

        // Assert
        expect(suggestions.length, 1);
        expect(suggestions[0].productName, 'חלב');
      });

      test('מחזיר רשימה ריקה אם אין מוצרים שמתחת לסף', () {
        // Arrange
        final inventory = [
          createInventoryItem(name: 'חלב', quantity: 10),
          createInventoryItem(name: 'לחם', quantity: 8),
        ];

        // Act
        final suggestions = SuggestionsService.generateSuggestions(
          inventoryItems: inventory,
        );

        // Assert
        expect(suggestions.isEmpty, true);
      });
    });

    group('getActiveSuggestions', () {
      test('מחזיר רק המלצות pending שלא נדחו', () {
        // Arrange
        final now = DateTime.now();
        final suggestions = [
          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 2,
            threshold: 5,
            unit: 'יח\'',
          ), // pending, לא נדחה ✅

          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '2',
            productName: 'לחם',
            category: 'מאפים',
            currentStock: 1,
            threshold: 5,
            unit: 'יח\'',
          ).copyWith(
            status: SuggestionStatus.added,
          ), // added ❌

          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '3',
            productName: 'ביצים',
            category: 'מוצרי חלב',
            currentStock: 0,
            threshold: 5,
            unit: 'יח\'',
          ).copyWith(
            dismissedUntil: now.add(const Duration(days: 7)),
          ), // dismissed, עדיין לא עבר ❌

          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '4',
            productName: 'גבינה',
            category: 'מוצרי חלב',
            currentStock: 1,
            threshold: 5,
            unit: 'יח\'',
          ).copyWith(
            dismissedUntil: now.subtract(const Duration(days: 1)),
          ), // dismissed, אבל עבר ✅
        ];

        // Act
        final active = SuggestionsService.getActiveSuggestions(suggestions);

        // Assert
        expect(active.length, 2);
        expect(active.any((s) => s.productName == 'חלב'), true);
        expect(active.any((s) => s.productName == 'גבינה'), true);
      });
    });

    group('getNextSuggestion', () {
      test('מחזיר את ההמלצה הדחופה ביותר', () {
        // Arrange
        final suggestions = [
          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '1',
            productName: 'לחם',
            category: 'מאפים',
            currentStock: 3,
            threshold: 5,
            unit: 'יח\'',
          ), // medium

          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '2',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 0,
            threshold: 5,
            unit: 'יח\'',
          ), // critical ← הכי דחוף

          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '3',
            productName: 'ביצים',
            category: 'מוצרי חלב',
            currentStock: 1,
            threshold: 5,
            unit: 'יח\'',
          ), // high
        ];

        // יש למיין אותם קודם
        final sorted = List<SmartSuggestion>.from(suggestions);
        sorted.sort((a, b) {
          const urgencyOrder = {
            'critical': 0,
            'high': 1,
            'medium': 2,
            'low': 3,
          };
          final urgencyA = urgencyOrder[a.urgency] ?? 999;
          final urgencyB = urgencyOrder[b.urgency] ?? 999;
          return urgencyA.compareTo(urgencyB);
        });

        // Act
        final next = SuggestionsService.getNextSuggestion(sorted);

        // Assert
        expect(next, isNotNull);
        expect(next!.productName, 'חלב');
        expect(next.urgency, 'critical');
      });

      test('מחזיר null אם אין המלצות פעילות', () {
        // Arrange
        final suggestions = [
          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 2,
            threshold: 5,
            unit: 'יח\'',
          ).copyWith(
            status: SuggestionStatus.added,
          ),
        ];

        // Act
        final next = SuggestionsService.getNextSuggestion(suggestions);

        // Assert
        expect(next, isNull);
      });
    });

    group('dismissSuggestion', () {
      test('מגדיר dismissed_until לעתיד', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: '1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        final before = DateTime.now();

        // Act
        final dismissed = SuggestionsService.dismissSuggestion(
          suggestion,
          duration: const Duration(days: 7),
        );

        final after = DateTime.now();

        // Assert
        expect(dismissed.status, SuggestionStatus.dismissed);
        expect(dismissed.dismissedUntil, isNotNull);
        expect(
          dismissed.dismissedUntil!.isAfter(before.add(const Duration(days: 6))),
          true,
        );
        expect(
          dismissed.dismissedUntil!.isBefore(after.add(const Duration(days: 8))),
          true,
        );
      });
    });

    group('deleteSuggestion', () {
      test('מחיקה קבועה (duration: null)', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: '1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        // Act
        final deleted = SuggestionsService.deleteSuggestion(
          suggestion,
          duration: null, // לצמיתות
        );

        // Assert
        expect(deleted.status, SuggestionStatus.deleted);
        expect(deleted.dismissedUntil, isNull);
      });

      test('מחיקה זמנית (duration: Duration)', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: '1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        // Act
        final deleted = SuggestionsService.deleteSuggestion(
          suggestion,
          duration: const Duration(days: 30),
        );

        // Assert
        expect(deleted.status, SuggestionStatus.dismissed);
        expect(deleted.dismissedUntil, isNotNull);
      });
    });

    group('markAsAdded', () {
      test('משנה סטטוס ל-added ושומר list_id', () {
        // Arrange
        final suggestion = SmartSuggestion.fromInventory(
          id: uuid.v4(),
          productId: '1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          unit: 'יח\'',
        );

        const listId = 'list-123';

        // Act
        final added = SuggestionsService.markAsAdded(
          suggestion,
          listId: listId,
        );

        // Assert
        expect(added.status, SuggestionStatus.added);
        expect(added.addedToListId, listId);
        expect(added.addedAt, isNotNull);
      });
    });

    group('getDurationFromChoice', () {
      test('מחזיר Duration נכון לפי בחירה', () {
        expect(
          SuggestionsService.getDurationFromChoice('day'),
          const Duration(days: 1),
        );
        expect(
          SuggestionsService.getDurationFromChoice('week'),
          const Duration(days: 7),
        );
        expect(
          SuggestionsService.getDurationFromChoice('month'),
          const Duration(days: 30),
        );
        expect(
          SuggestionsService.getDurationFromChoice('forever'),
          null,
        );
      });
    });

    group('getSuggestionsStats', () {
      test('מחזיר סטטיסטיקה נכונה', () {
        // Arrange
        final suggestions = [
          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 0,
            threshold: 5,
            unit: 'יח\'',
          ), // pending, critical

          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '2',
            productName: 'ביצים',
            category: 'מוצרי חלב',
            currentStock: 1,
            threshold: 5,
            unit: 'יח\'',
          ), // pending, high

          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '3',
            productName: 'לחם',
            category: 'מאפים',
            currentStock: 2,
            threshold: 5,
            unit: 'יח\'',
          ).copyWith(
            status: SuggestionStatus.added,
          ), // added

          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '4',
            productName: 'גבינה',
            category: 'מוצרי חלב',
            currentStock: 3,
            threshold: 5,
            unit: 'יח\'',
          ).copyWith(
            status: SuggestionStatus.dismissed,
          ), // dismissed
        ];

        // Act
        final stats = SuggestionsService.getSuggestionsStats(suggestions);

        // Assert
        expect(stats['total'], 4);
        expect(stats['active'], 2); // חלב, ביצים
        expect(stats['critical'], 1); // חלב
        expect(stats['high'], 1); // ביצים
        expect(stats['added'], 1); // לחם
        expect(stats['dismissed'], 1); // גבינה
      });
    });

    group('hasUrgentSuggestions', () {
      test('מחזיר true אם יש המלצות critical או high', () {
        // Arrange
        final suggestions = [
          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '1',
            productName: 'חלב',
            category: 'מוצרי חלב',
            currentStock: 0,
            threshold: 5,
            unit: 'יח\'',
          ), // critical ✅
        ];

        // Act & Assert
        expect(SuggestionsService.hasUrgentSuggestions(suggestions), true);
      });

      test('מחזיר false אם אין המלצות דחופות', () {
        // Arrange
        final suggestions = [
          SmartSuggestion.fromInventory(
            id: uuid.v4(),
            productId: '1',
            productName: 'גבינה',
            category: 'מוצרי חלב',
            currentStock: 4,
            threshold: 5,
            unit: 'יח\'',
          ), // low
        ];

        // Act & Assert
        expect(SuggestionsService.hasUrgentSuggestions(suggestions), false);
      });
    });
  });
}
