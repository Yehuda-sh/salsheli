// 📄 File: test/widgets/smart_suggestions_card_test.dart
// 🎯 Purpose: Widget tests for SmartSuggestionsCard
//
// ✅ Tests covered:
// 1. Loading State - מציג skeleton screen
// 2. Error State - מציג error + refresh button
// 3. Empty State - מציג empty message + CTA
// 4. Content State - מציג רשימת המלצות
// 5. Add to list - קורא לprovider כשלוחצים הוסף
// 6. Dismiss suggestion - קורא לprovider כשלוחצים דחה
// 7. More suggestions chip - מציג chip אם יש יותר מ-3

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:memozap/models/enums/suggestion_status.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/smart_suggestion.dart';
import 'package:memozap/providers/suggestions_provider.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/widgets/home/smart_suggestions_card.dart';

@GenerateMocks([SuggestionsProvider, ShoppingListsProvider])
import 'smart_suggestions_card_test.mocks.dart';

void main() {
  late MockSuggestionsProvider mockSuggestionsProvider;
  late MockShoppingListsProvider mockShoppingListsProvider;

  setUp(() {
    mockSuggestionsProvider = MockSuggestionsProvider();
    mockShoppingListsProvider = MockShoppingListsProvider();
  });

  /// Helper: יוצר widget עם providers מזויפים
  Widget createTestWidget({
    ShoppingList? list,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SuggestionsProvider>.value(
          value: mockSuggestionsProvider,
        ),
        ChangeNotifierProvider<ShoppingListsProvider>.value(
          value: mockShoppingListsProvider,
        ),
      ],
      child: MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SmartSuggestionsCard(mostRecentList: list),
          ),
        ),
      ),
    );
  }

  /// Helper: יוצר SmartSuggestion לבדיקות
  SmartSuggestion createMockSuggestion({
    required String id,
    required String name,
    int currentStock = 2,
    int threshold = 5,
    int quantityNeeded = 3,
    String unit = 'יח\'',
  }) {
    return SmartSuggestion(
      id: id,
      productId: 'product_$id',
      productName: name,
      category: 'כללי',
      currentStock: currentStock,
      threshold: threshold,
      quantityNeeded: quantityNeeded,
      unit: unit,
      status: SuggestionStatus.pending,
      suggestedAt: DateTime.now(),
    );
  }

  group('SmartSuggestionsCard - Loading State', () {
    testWidgets('מציג skeleton screen כשisLoading=true', (tester) async {
      // Arrange
      when(mockSuggestionsProvider.isLoading).thenReturn(true);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(Card), findsOneWidget);
      // Skeleton מורכב מ-_SkeletonBox widgets עם AnimatedBuilder
      expect(find.byType(AnimatedBuilder), findsWidgets); // skeleton animations
    });
  });

  group('SmartSuggestionsCard - Error State', () {
    testWidgets('מציג error message כשerror != null', (tester) async {
      // Arrange
      const errorMsg = 'שגיאה בטעינה';
      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(errorMsg);
      when(mockSuggestionsProvider.suggestions).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('שגיאה בטעינת ההמלצות'), findsOneWidget);
      expect(find.text(errorMsg), findsOneWidget);
      expect(find.text('נסה שוב'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });

    testWidgets('כפתור refresh קורא לprovider.refreshSuggestions()', (tester) async {
      // Arrange
      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn('שגיאה');
      when(mockSuggestionsProvider.suggestions).thenReturn([]);
      when(mockSuggestionsProvider.refreshSuggestions()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // לחץ על כפתור "נסה שוב"
      await tester.tap(find.text('נסה שוב'));
      await tester.pump();

      // Assert
      verify(mockSuggestionsProvider.refreshSuggestions()).called(1);
    });
  });

  group('SmartSuggestionsCard - Empty State', () {
    testWidgets('מציג empty state כשאין המלצות', (tester) async {
      // Arrange
      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('אין המלצות'), findsOneWidget);
      expect(find.text('עדכן מלאי במזווה\nכדי לקבל המלצות מותאמות אישית'), findsOneWidget);
      expect(find.text('עדכן מזווה'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('כפתור CTA קיים', (tester) async {
      // Arrange
      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - מחפשים רק את הטקסט, לא את הwidget המדויק
      expect(find.text('עדכן מזווה'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });
  });

  group('SmartSuggestionsCard - Content State', () {
    testWidgets('מציג 3 המלצות עליונות', (tester) async {
      // Arrange
      final suggestions = [
        createMockSuggestion(id: '1', name: 'חלב'),
        createMockSuggestion(id: '2', name: 'לחם'),
        createMockSuggestion(id: '3', name: 'ביצים'),
        createMockSuggestion(id: '4', name: 'גבינה'),
        createMockSuggestion(id: '5', name: 'חמאה'),
      ];

      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn(suggestions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle(); // חכה לאנימציות

      // Assert
      expect(find.text('חלב'), findsOneWidget);
      expect(find.text('לחם'), findsOneWidget);
      expect(find.text('ביצים'), findsOneWidget);
      // ה-4 וה-5 לא צריכים להופיע
      expect(find.text('גבינה'), findsNothing);
      expect(find.text('חמאה'), findsNothing);
    });

    testWidgets('מציג chip +X נוספות אם יש יותר מ-3', (tester) async {
      // Arrange
      final suggestions = List.generate(
        5,
        (i) => createMockSuggestion(id: '$i', name: 'מוצר $i'),
      );

      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn(suggestions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('+2 נוספות'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('כל המלצה יש 2 כפתורים - הוסף ודחה', (tester) async {
      // Arrange
      final suggestions = [
        createMockSuggestion(id: '1', name: 'חלב'),
      ];

      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn(suggestions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget); // כפתור דחייה
      expect(find.byType(IconButton), findsNWidgets(2));
    });

    testWidgets('לא מציג chip +X אם יש בדיוק 3 המלצות', (tester) async {
      // Arrange
      final suggestions = List.generate(
        3,
        (i) => createMockSuggestion(id: '$i', name: 'מוצר $i'),
      );

      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn(suggestions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('מציג stockDescription לכל המלצה', (tester) async {
      // Arrange
      final suggestions = [
        createMockSuggestion(
          id: '1',
          name: 'חלב',
          currentStock: 2,
          threshold: 5,
        ),
      ];

      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn(suggestions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      // stockDescription = "נשארו רק 2 יח'"
      expect(find.textContaining('נשארו רק'), findsOneWidget);
    });
  });

  group('SmartSuggestionsCard - Actions', () {
    testWidgets('כפתור הוסף קורא לaddItemToList', (tester) async {
      // Arrange
      final list = ShoppingList.newList(
        id: 'list1',
        name: 'רשימה בדיקה',
        createdBy: 'user1',
        items: [],
      );

      final suggestions = [
        createMockSuggestion(
          id: '1',
          name: 'חלב',
          quantityNeeded: 3,
        ),
      ];

      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn(suggestions);
      
      // Mock addItemToList
      when(mockShoppingListsProvider.addItemToList(
        any,
        any,
        any,
        any,
      )).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget(list: list));
      await tester.pump();
      await tester.pumpAndSettle();

      // לחץ על כפתור הוסף
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();

      // Assert
      verify(mockShoppingListsProvider.addItemToList(
        'list1',
        'חלב',
        3, // quantityNeeded
        any,
      )).called(1);
    });

    testWidgets('כפתור דחה קורא לdismissCurrentSuggestion', (tester) async {
      // Arrange
      final suggestions = [
        createMockSuggestion(id: '1', name: 'חלב'),
      ];

      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn(suggestions);
      when(mockSuggestionsProvider.dismissCurrentSuggestion()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();

      // לחץ על כפתור דחה (schedule icon)
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pump();

      // Assert
      verify(mockSuggestionsProvider.dismissCurrentSuggestion()).called(1);
    });

    testWidgets('מציג SnackBar אם אין רשימה פעילה', (tester) async {
      // Arrange
      final suggestions = [
        createMockSuggestion(id: '1', name: 'חלב'),
      ];

      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn(suggestions);

      // Act
      await tester.pumpWidget(createTestWidget(list: null)); // אין רשימה!
      await tester.pump();
      await tester.pumpAndSettle();

      // לחץ על כפתור הוסף
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('אין רשימה פעילה להוסיף אליה'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('SmartSuggestionsCard - UI Details', () {
    testWidgets('כותרת תמיד מוצגת בcontent state', (tester) async {
      // Arrange
      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn([
        createMockSuggestion(id: '1', name: 'חלב'),
      ]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('המלצות חכמות'), findsOneWidget);
    });

    testWidgets('אייקונים נכונים בכל state', (tester) async {
      // Error - cloud_off_outlined
      when(mockSuggestionsProvider.isLoading).thenReturn(false);
      when(mockSuggestionsProvider.error).thenReturn('שגיאה');
      when(mockSuggestionsProvider.suggestions).thenReturn([]);
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

      // Empty - lightbulb_outline
      when(mockSuggestionsProvider.error).thenReturn(null);
      when(mockSuggestionsProvider.suggestions).thenReturn([]);
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);

      // Content - auto_awesome
      when(mockSuggestionsProvider.suggestions).thenReturn([
        createMockSuggestion(id: '1', name: 'חלב'),
      ]);
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}
