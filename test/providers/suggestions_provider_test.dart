// 📄 File: test/providers/suggestions_provider_test.dart
//
// 🧪 בדיקות ל-SuggestionsProvider:
//     - רענון המלצות
//     - הוספת המלצה לרשימה
//     - דחיית המלצה
//     - מחיקת המלצה (זמנית/קבועה)
//     - טעינת המלצה הבאה
//     - האזנה לשינויים במלאי

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'package:memozap/providers/suggestions_provider.dart';
import 'package:memozap/providers/inventory_provider.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/smart_suggestion.dart';
import 'package:memozap/models/enums/suggestion_status.dart';

import 'suggestions_provider_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  InventoryProvider,
])
void main() {
  late SuggestionsProvider provider;
  late MockInventoryProvider mockInventoryProvider;

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

  setUp(() {
    mockInventoryProvider = MockInventoryProvider();

    // Mock ברירת מחדל: מלאי ריק
    when(mockInventoryProvider.items).thenReturn([]);

    provider = SuggestionsProvider(
      inventoryProvider: mockInventoryProvider,
    );
  });

  tearDown(() {
    provider.dispose();
  });

  group('Initialization', () {
    test('מתחיל עם רשימה ריקה', () {
      expect(provider.suggestions, isEmpty);
      expect(provider.currentSuggestion, isNull);
      expect(provider.hasCurrentSuggestion, false);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });
  });

  group('refreshSuggestions', () {
    test('יוצר המלצות ממלאי נמוך', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 2), // < 5 ✅
        createInventoryItem(name: 'לחם', quantity: 8), // >= 5 ❌
        createInventoryItem(name: 'ביצים', quantity: 0), // < 5 ✅
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);

      // Act
      await provider.refreshSuggestions();

      // Assert
      expect(provider.suggestions.length, 2); // חלב, ביצים
      expect(provider.suggestions.any((s) => s.productName == 'חלב'), true);
      expect(provider.suggestions.any((s) => s.productName == 'ביצים'), true);
      expect(provider.suggestions.any((s) => s.productName == 'לחם'), false);
    });

    test('טוען את ההמלצה הדחופה ביותר כ-current', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'לחם', quantity: 3), // medium
        createInventoryItem(name: 'חלב', quantity: 0), // critical ← הכי דחוף
        createInventoryItem(name: 'ביצים', quantity: 1), // high
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);

      // Act
      await provider.refreshSuggestions();

      // Assert
      expect(provider.currentSuggestion, isNotNull);
      expect(provider.currentSuggestion!.productName, 'חלב');
      expect(provider.currentSuggestion!.urgency, 'critical');
      expect(provider.hasCurrentSuggestion, true);
    });

    test('מחזיר רשימה ריקה אם אין מוצרים שמתחת לסף', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 10),
        createInventoryItem(name: 'לחם', quantity: 8),
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);

      // Act
      await provider.refreshSuggestions();

      // Assert
      expect(provider.suggestions, isEmpty);
      expect(provider.currentSuggestion, isNull);
      expect(provider.hasCurrentSuggestion, false);
    });
  });

  group('addCurrentSuggestion', () {
    test('מוסיף המלצה נוכחית לרשימה', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 2),
        createInventoryItem(name: 'ביצים', quantity: 1),
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      final beforeSuggestion = provider.currentSuggestion;
      expect(beforeSuggestion, isNotNull);

      const listId = 'test-list-123';

      // Act
      await provider.addCurrentSuggestion(listId);

      // Assert
      // המלצה הקודמת סומנה כ-added
      final addedSuggestion = provider.suggestions.firstWhere(
        (s) => s.id == beforeSuggestion!.id,
      );
      expect(addedSuggestion.status, SuggestionStatus.added);
      expect(addedSuggestion.addedToListId, listId);
      expect(addedSuggestion.addedAt, isNotNull);

      // נטענה המלצה חדשה
      expect(provider.currentSuggestion, isNotNull);
      expect(provider.currentSuggestion!.id, isNot(beforeSuggestion?.id));
    });

    test('לא עושה כלום אם אין המלצה נוכחית', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 10), // מעל הסף
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      expect(provider.currentSuggestion, isNull);

      // Act
      await provider.addCurrentSuggestion('test-list-123');

      // Assert
      expect(provider.currentSuggestion, isNull);
      expect(provider.error, isNull);
    });

    test('טוען את ההמלצה הבאה בתור', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 0), // critical
        createInventoryItem(name: 'ביצים', quantity: 1), // high
        createInventoryItem(name: 'לחם', quantity: 3), // medium
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      expect(provider.currentSuggestion!.productName, 'חלב');

      // Act
      await provider.addCurrentSuggestion('list-123');

      // Assert
      expect(provider.currentSuggestion, isNotNull);
      expect(provider.currentSuggestion!.productName, 'ביצים'); // ההמלצה הבאה
    });
  });

  group('dismissCurrentSuggestion', () {
    test('דוחה המלצה נוכחית לשבוע', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 2),
        createInventoryItem(name: 'ביצים', quantity: 1),
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      final beforeSuggestion = provider.currentSuggestion;
      expect(beforeSuggestion, isNotNull);

      // Act
      await provider.dismissCurrentSuggestion();

      // Assert
      // המלצה הקודמת נדחתה
      final dismissedSuggestion = provider.suggestions.firstWhere(
        (s) => s.id == beforeSuggestion!.id,
      );
      expect(dismissedSuggestion.status, SuggestionStatus.dismissed);
      expect(dismissedSuggestion.dismissedUntil, isNotNull);

      // נטענה המלצה חדשה
      expect(provider.currentSuggestion, isNotNull);
      expect(provider.currentSuggestion!.id, isNot(beforeSuggestion?.id));
    });

    test('לא עושה כלום אם אין המלצה נוכחית', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 10), // מעל הסף
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      expect(provider.currentSuggestion, isNull);

      // Act
      await provider.dismissCurrentSuggestion();

      // Assert
      expect(provider.currentSuggestion, isNull);
      expect(provider.error, isNull);
    });
  });

  group('deleteCurrentSuggestion', () {
    test('מוחק המלצה לצמיתות', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 2),
        createInventoryItem(name: 'ביצים', quantity: 1),
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      final beforeSuggestion = provider.currentSuggestion;
      expect(beforeSuggestion, isNotNull);

      // Act
      await provider.deleteCurrentSuggestion(null);

      // Assert
      // המלצה הקודמת נמחקה
      final deletedSuggestion = provider.suggestions.firstWhere(
        (s) => s.id == beforeSuggestion!.id,
      );
      expect(deletedSuggestion.status, SuggestionStatus.deleted);

      // המוצר נוסף ל-excludedProducts
      // (לא נוכל לבדוק ישירות כי זה private, אבל נוכל לבדוק שהוא לא יופיע יותר)

      // נטענה המלצה חדשה
      expect(provider.currentSuggestion, isNotNull);
      expect(provider.currentSuggestion!.id, isNot(beforeSuggestion?.id));
    });

    test('מוחק המלצה זמנית', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 2),
        createInventoryItem(name: 'ביצים', quantity: 1),
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      final beforeSuggestion = provider.currentSuggestion;
      expect(beforeSuggestion, isNotNull);

      // Act
      await provider.deleteCurrentSuggestion(const Duration(days: 30));

      // Assert
      // המלצה הקודמת נדחתה (לא נמחקה לצמיתות)
      final dismissedSuggestion = provider.suggestions.firstWhere(
        (s) => s.id == beforeSuggestion!.id,
      );
      expect(dismissedSuggestion.status, SuggestionStatus.dismissed);
      expect(dismissedSuggestion.dismissedUntil, isNotNull);

      // נטענה המלצה חדשה
      expect(provider.currentSuggestion, isNotNull);
      expect(provider.currentSuggestion!.id, isNot(beforeSuggestion?.id));
    });

    test('לא עושה כלום אם אין המלצה נוכחית', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 10), // מעל הסף
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      expect(provider.currentSuggestion, isNull);

      // Act
      await provider.deleteCurrentSuggestion(null);

      // Assert
      expect(provider.currentSuggestion, isNull);
      expect(provider.error, isNull);
    });
  });

  group('pendingSuggestionsCount', () {
    test('מחזיר מספר נכון של המלצות פעילות', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 2), // active
        createInventoryItem(name: 'ביצים', quantity: 1), // active
        createInventoryItem(name: 'לחם', quantity: 3), // active
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      // Act & Assert
      expect(provider.pendingSuggestionsCount, 3);

      // הוסף אחת לרשימה
      await provider.addCurrentSuggestion('list-123');

      // עכשיו צריכות להיות 2 פעילות (אחת added)
      expect(provider.pendingSuggestionsCount, 2);
    });
  });

  group('Error Handling', () {
    test('תופס שגיאות ומעדכן error state', () async {
      // Arrange
      when(mockInventoryProvider.items).thenThrow(Exception('Test error'));

      // Act
      await provider.refreshSuggestions();

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Test error'));
      expect(provider.isLoading, false);
    });
  });

  group('ChangeNotifier', () {
    test('שולח notifyListeners אחרי refreshSuggestions', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 2),
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);

      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.refreshSuggestions();

      // Assert
      expect(notifyCount, greaterThan(0));
    });

    test('שולח notifyListeners אחרי addCurrentSuggestion', () async {
      // Arrange
      final inventory = [
        createInventoryItem(name: 'חלב', quantity: 2),
      ];

      when(mockInventoryProvider.items).thenReturn(inventory);
      await provider.refreshSuggestions();

      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.addCurrentSuggestion('list-123');

      // Assert
      expect(notifyCount, greaterThan(0));
    });
  });
}
