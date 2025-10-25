// 🧪 Test: test/widgets/active_lists_section_test.dart
// 🎯 Purpose: Widget tests for ActiveListsSection
// 
// ✅ Tests Coverage:
// 1. Empty State - הצגת הודעה כשאין רשימות
// 2. Lists Display - הצגת רשימות נכונה
// 3. List Tile Content - תוכן נכון בכל פריט
// 4. Navigation - פעולת לחיצה על רשימה
// 5. Items Count - ספירת פריטים נכונה
// 6. Multiple Lists - טיפול במספר רשימות
// 7. Sticky Note Design - עיצוב נכון

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/unified_list_item.dart';
import 'package:memozap/models/enums/item_type.dart';
import 'package:memozap/widgets/common/sticky_note.dart';
import 'package:memozap/widgets/home/active_lists_section.dart';

// Helper function to create test ShoppingList
ShoppingList _createTestList({
  required String id,
  required String name,
  String type = 'super',
  List<UnifiedListItem> items = const [],
}) {
  return ShoppingList(
    id: id,
    name: name,
    type: type,
    status: 'active',
    format: 'shared',
    createdBy: 'user1',
    isShared: false,
    sharedWith: const [],
    createdFromTemplate: false,
    createdDate: DateTime.now(),
    updatedDate: DateTime.now(),
    items: items,
  );
}

void main() {
  group('ActiveListsSection Widget Tests', () {
    // ========================================
    // Test 1: Empty State
    // ========================================
    testWidgets('displays empty state message when lists is empty',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveListsSection(
              lists: const [],
              onTapList: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(AppStrings.home.noOtherActiveLists), findsOneWidget);
      expect(find.byType(StickyNote), findsOneWidget);
      
      // צבע פתק צריך להיות ירוק
      final stickyNote = tester.widget<StickyNote>(find.byType(StickyNote));
      expect(stickyNote.color, equals(kStickyGreen));
    });

    // ========================================
    // Test 2: Lists Display
    // ========================================
    testWidgets('displays lists when provided', (tester) async {
      // Arrange
      final lists = [
        _createTestList(
          id: '1',
          name: 'רשימת סופר',
          type: 'super',
          items: [
            UnifiedListItem.product(
              name: 'חלב',
              quantity: 2,
            ),
          ],
        ),
        _createTestList(
          id: '2',
          name: 'רשימת פארם',
          type: 'pharm',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveListsSection(
              lists: lists,
              onTapList: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('רשימת סופר'), findsOneWidget);
      expect(find.text('רשימת פארם'), findsOneWidget);
      expect(find.text(AppStrings.home.noOtherActiveLists), findsNothing);
    });

    // ========================================
    // Test 3: List Tile Content
    // ========================================
    testWidgets('displays correct content for each list tile', (tester) async {
      // Arrange
      final list = _createTestList(
        id: '1',
        name: 'רשימת קניות',
        items: [
          UnifiedListItem.product(name: 'חלב', quantity: 2),
          UnifiedListItem.product(name: 'לחם', quantity: 1),
          UnifiedListItem.product(name: 'ביצים', quantity: 1),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveListsSection(
              lists: [list],
              onTapList: () {},
            ),
          ),
        ),
      );

      // Assert - שם רשימה
      expect(find.text('רשימת קניות'), findsOneWidget);
      
      // Assert - ספירת פריטים
      expect(find.text(AppStrings.home.itemsCount(3)), findsOneWidget);
      
      // Assert - אייקון תיק קניות
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      
      // Assert - חץ ניווט
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    // ========================================
    // Test 4: Navigation Callback
    // ========================================
    testWidgets('calls onTapList when list tile is tapped', (tester) async {
      // Arrange
      bool wasCallbackCalled = false;
      final list = _createTestList(
        id: '1',
        name: 'רשימת סופר',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveListsSection(
              lists: [list],
              onTapList: () {
                wasCallbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('רשימת סופר'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasCallbackCalled, isTrue);
    });

    // ========================================
    // Test 5: Items Count Display
    // ========================================
    testWidgets('displays correct items count for lists', (tester) async {
      // Arrange
      final lists = [
        _createTestList(
          id: '1',
          name: 'רשימה עם 5 פריטים',
          items: List.generate(
            5,
            (i) => UnifiedListItem.product(name: 'מוצר $i', quantity: 1),
          ),
        ),
        _createTestList(
          id: '2',
          name: 'רשימה ריקה',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveListsSection(
              lists: lists,
              onTapList: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(AppStrings.home.itemsCount(5)), findsOneWidget);
      // רשימה ריקה לא תציג ספירה
      expect(find.text(AppStrings.home.itemsCount(0)), findsNothing);
    });

    // ========================================
    // Test 6: Multiple Lists Display
    // ========================================
    testWidgets('displays multiple lists correctly', (tester) async {
      // Arrange
      final lists = List.generate(
        4,
        (i) => _createTestList(
          id: '$i',
          name: 'רשימה ${i + 1}',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveListsSection(
              lists: lists,
              onTapList: () {},
            ),
          ),
        ),
      );

      // Assert - כל הרשימות מוצגות
      for (int i = 0; i < 4; i++) {
        expect(find.text('רשימה ${i + 1}'), findsOneWidget);
      }
      
      // Assert - ספירת רשימות בכותרת
      expect(find.text('4'), findsOneWidget);
    });

    // ========================================
    // Test 7: Sticky Note Design
    // ========================================
    testWidgets('uses correct Sticky Note design', (tester) async {
      // Arrange
      final list = _createTestList(
        id: '1',
        name: 'רשימה',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveListsSection(
              lists: [list],
              onTapList: () {},
            ),
          ),
        ),
      );

      // Assert - StickyNote עם צבע ירוק
      final stickyNote = tester.widget<StickyNote>(find.byType(StickyNote));
      expect(stickyNote.color, equals(kStickyGreen));
      
      // Assert - סיבוב קיים
      expect(stickyNote.rotation, isNotNull);
      expect(stickyNote.rotation.abs(), lessThanOrEqualTo(0.03));
    });

    // ========================================
    // Test 8: Header Display
    // ========================================
    testWidgets('displays section header with title and icon',
        (tester) async {
      // Arrange
      final list = _createTestList(
        id: '1',
        name: 'רשימה',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveListsSection(
              lists: [list],
              onTapList: () {},
            ),
          ),
        ),
      );

      // Assert - כותרת
      expect(find.text(AppStrings.home.otherActiveLists), findsOneWidget);
      
      // Assert - אייקון כותרת
      expect(find.byIcon(Icons.list_alt), findsOneWidget);
      
      // Assert - Divider
      expect(find.byType(Divider), findsOneWidget);
    });

    // ========================================
    // Test 9: InkWell Ripple Effect
    // ========================================
    testWidgets('list tiles have InkWell for ripple effect', (tester) async {
      // Arrange
      final list = _createTestList(
        id: '1',
        name: 'רשימה',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveListsSection(
              lists: [list],
              onTapList: () {},
            ),
          ),
        ),
      );

      // Assert - InkWell קיים
      expect(find.byType(InkWell), findsOneWidget);
    });

    // ========================================
    // Test 10: List Name Ellipsis
    // ========================================
    testWidgets('truncates long list names with ellipsis', (tester) async {
      // Arrange
      final list = _createTestList(
        id: '1',
        name: 'רשימה עם שם ארוך מאוד מאוד מאוד שצריך להיחתך',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // רוחב מוגבל
              child: ActiveListsSection(
                lists: [list],
                onTapList: () {},
              ),
            ),
          ),
        ),
      );

      // Assert - טקסט עם ellipsis
      final textWidget = tester.widget<Text>(
        find.text('רשימה עם שם ארוך מאוד מאוד מאוד שצריך להיחתך'),
      );
      expect(textWidget.maxLines, equals(1));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });
  });
}
