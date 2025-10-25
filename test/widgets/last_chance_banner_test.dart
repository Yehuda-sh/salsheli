// 📄 File: test/widgets/last_chance_banner_test.dart
// 🎯 Purpose: Widget tests for LastChanceBanner
//
// ✅ Tests covered:
// 1. Visibility - נראות הבאנר
// 2. Content Display - תצוגת תוכן
// 3. Action Buttons - כפתורי פעולה
// 4. SnackBars - הודעות
// 5. Error Handling - טיפול בשגיאות
// 6. Animations - אנימציות

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'package:memozap/models/smart_suggestion.dart';
import 'package:memozap/models/enums/suggestion_status.dart';
import 'package:memozap/providers/suggestions_provider.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/widgets/shopping/last_chance_banner.dart';

@GenerateMocks([SuggestionsProvider, ShoppingListsProvider])
import 'last_chance_banner_test.mocks.dart';

void main() {
  late MockSuggestionsProvider mockSuggestionsProvider;
  late MockShoppingListsProvider mockShoppingListsProvider;

  setUp(() {
    mockSuggestionsProvider = MockSuggestionsProvider();
    mockShoppingListsProvider = MockShoppingListsProvider();
    
    // Default stubs for all tests
    when(mockShoppingListsProvider.addUnifiedItem(any, any))
        .thenAnswer((_) async {});
  });

  Widget createTestWidget({String? listId}) {
    return MaterialApp(
      home: Scaffold(
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<SuggestionsProvider>.value(
              value: mockSuggestionsProvider,
            ),
            ChangeNotifierProvider<ShoppingListsProvider>.value(
              value: mockShoppingListsProvider,
            ),
          ],
          child: LastChanceBanner(listId: listId ?? 'test-list-id'),
        ),
      ),
    );
  }

  group('LastChanceBanner Widget Tests', () {
    group('Visibility Tests', () {
      testWidgets('should not show banner when no suggestions', (tester) async {
        // Arrange
        when(mockSuggestionsProvider.currentSuggestion).thenReturn(null);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(LastChanceBanner), findsOneWidget);
        expect(find.text('עוד לא הוספת:'), findsNothing);
      });

      testWidgets('should show banner when suggestion exists', (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.pendingSuggestionsCount).thenReturn(2);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('עוד לא הוספת:'), findsOneWidget);
        expect(find.text('חלב'), findsOneWidget);
        expect(find.text('נשארו 2 יחידות'), findsOneWidget);
      });

      testWidgets('should not show banner when loading', (tester) async {
        // Arrange
        when(mockSuggestionsProvider.currentSuggestion).thenReturn(null);
        when(mockSuggestionsProvider.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('עוד לא הוספת:'), findsNothing);
      });
    });

    group('Content Display Tests', () {
      testWidgets('should display product name and stock info', (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'ביצים',
          category: 'מוצרי חלב',
          currentStock: 1,
          threshold: 10,
          quantityNeeded: 9,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.pendingSuggestionsCount).thenReturn(0);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('ביצים'), findsOneWidget);
        expect(find.text('נשארו 1 יחידות'), findsOneWidget);
      });

      testWidgets('should display correct stock message for zero stock',
          (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'לחם',
          category: 'מאפים',
          currentStock: 0,
          threshold: 5,
          quantityNeeded: 5,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.pendingSuggestionsCount).thenReturn(0);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('לחם'), findsOneWidget);
        expect(find.text('נשארו 0 יחידות'), findsOneWidget);
      });

      testWidgets('should display pending count badge', (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.pendingSuggestionsCount).thenReturn(7);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('+7'), findsOneWidget);
      });

      testWidgets('should not display badge when count is zero', (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.pendingSuggestionsCount).thenReturn(0);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('+0'), findsNothing);
      });
    });

    group('Action Buttons Tests', () {
      testWidgets('should show Add and Skip buttons', (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('הוסף לרשימה'), findsOneWidget);
        expect(find.text('הבא'), findsOneWidget);
      });

      testWidgets('should call addCurrentSuggestion when Add button is tapped',
          (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.addCurrentSuggestion(any))
            .thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(createTestWidget(listId: 'test-list-123'));
        await tester.tap(find.text('הוסף לרשימה'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockSuggestionsProvider.addCurrentSuggestion('test-list-123'))
            .called(1);
      });

      testWidgets('should call dismissSuggestion when Skip button is tapped',
          (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.dismissCurrentSuggestion())
            .thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('הבא'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockSuggestionsProvider.dismissCurrentSuggestion()).called(1);
      });
    });

    group('SnackBar Tests', () {
      testWidgets('should show success SnackBar after adding item',
          (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.addCurrentSuggestion(any))
            .thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('הוסף לרשימה'));
        await tester.pump(); // Start the SnackBar animation
        await tester.pump(const Duration(milliseconds: 100)); // Let it appear

        // Assert
        expect(find.textContaining('הוספתי חלב לרשימה'), findsOneWidget);
      });

      testWidgets('should show success SnackBar after skipping',
          (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.dismissCurrentSuggestion())
            .thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle(); // Wait for animations to complete
        
        // וודא שהכפתור קיים
        expect(find.text('הבא'), findsOneWidget);
        
        await tester.tap(find.text('הבא'));
        await tester.pump(); // Start the SnackBar animation
        await tester.pump(const Duration(milliseconds: 100)); // Let it appear

        // Assert
        expect(find.text('הדחיתי את ההמלצה'), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should show error SnackBar when add fails', (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.pendingSuggestionsCount).thenReturn(0);
        when(mockShoppingListsProvider.addUnifiedItem(any, any))
            .thenThrow(Exception('Failed to add'));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('הוסף לרשימה'));
        await tester.pump(); // Start the SnackBar animation
        await tester.pump(const Duration(milliseconds: 100)); // Let it appear

        // Assert
        expect(find.textContaining('שגיאה'), findsOneWidget);
      });

      testWidgets('should show error SnackBar when skip fails', (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.pendingSuggestionsCount).thenReturn(0);
        
        // dismissCurrentSuggestion זורק exception
        when(mockSuggestionsProvider.dismissCurrentSuggestion())
            .thenThrow(Exception('Failed to dismiss'));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle(); // Wait for animations
        
        // וודא שהכפתור קיים
        expect(find.text('הבא'), findsOneWidget);
        
        // Tap על הכפתור - זה יזרוק exception
        await tester.tap(find.text('הבא'));
        await tester.pump(); // Process the exception
        await tester.pump(const Duration(milliseconds: 100)); // Let SnackBar appear

        // Assert - הודעת שגיאה צריכה להופיע
        expect(find.textContaining('שגיאה'), findsOneWidget);
      });
    });

    group('Animation Tests', () {
      testWidgets('should have animation when banner appears', (tester) async {
        // Arrange
        final suggestion = SmartSuggestion(
          id: 'sugg-1',
          productId: 'prod-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          currentStock: 2,
          threshold: 5,
          quantityNeeded: 3,
          unit: 'יח\'',
          suggestedAt: DateTime.now(),
          status: SuggestionStatus.pending,
        );

        when(mockSuggestionsProvider.currentSuggestion).thenReturn(suggestion);
        when(mockSuggestionsProvider.isLoading).thenReturn(false);
        when(mockSuggestionsProvider.pendingSuggestionsCount).thenReturn(0);

        // Act
        await tester.pumpWidget(createTestWidget());
        
        // The widget should exist immediately
        expect(find.text('חלב'), findsOneWidget);
        
        // Pump animations
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('חלב'), findsOneWidget);
        
        // Complete all animations
        await tester.pumpAndSettle();
        
        // Assert - banner fully visible after animation
        expect(find.text('חלב'), findsOneWidget);
        expect(find.text('עוד לא הוספת:'), findsOneWidget);
      });
    });
  });
}
