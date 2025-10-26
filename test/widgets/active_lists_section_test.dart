// 🧪 Test File: test/widgets/active_lists_section_test.dart
// Description: Tests for ActiveListsSection widget
//
// Test Coverage:
// ✅ Empty state (no lists)
// ✅ Single list display
// ✅ Multiple lists display
// ✅ List tile content (name, count, icons)
// ✅ Tap handling
// ✅ Header count badge

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/unified_list_item.dart';
import 'package:memozap/widgets/home/active_lists_section.dart';

void main() {
  group('ActiveListsSection Widget Tests', () {
    // Test data
    late ShoppingList list1;
    late ShoppingList list2;
    late ShoppingList list3;
    bool onTapListCalled = false;

    setUp(() {
      onTapListCalled = false;

      // List with 3 items
      list1 = ShoppingList(
        id: 'list1',
        name: 'רשימת סופר',
        householdId: 'household1',
        createdBy: 'user1',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        items: [
          UnifiedListItem.product(
            id: 'item1',
            name: 'חלב',
            quantity: 2,
            category: 'חלב וביצים',
          ),
          UnifiedListItem.product(
            id: 'item2',
            name: 'לחם',
            quantity: 1,
            category: 'לחם ומאפים',
          ),
          UnifiedListItem.product(
            id: 'item3',
            name: 'ביצים',
            quantity: 1,
            category: 'חלב וביצים',
          ),
        ],
      );

      // List with 1 item
      list2 = ShoppingList(
        id: 'list2',
        name: 'רשימת פארם',
        householdId: 'household1',
        createdBy: 'user1',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        items: [
          UnifiedListItem.product(
            id: 'item4',
            name: 'שמפו',
            quantity: 1,
            category: 'טיפוח',
          ),
        ],
      );

      // Empty list
      list3 = ShoppingList(
        id: 'list3',
        name: 'רשימה ריקה',
        householdId: 'household1',
        createdBy: 'user1',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        items: [],
      );
    });

    Widget buildWidget({required List<ShoppingList> lists}) {
      return MaterialApp(
        home: Scaffold(
          body: ActiveListsSection(
            lists: lists,
            onTapList: () => onTapListCalled = true,
          ),
        ),
      );
    }

    group('Empty State Tests', () {
      testWidgets('shows nothing when lists are empty', (tester) async {
        await tester.pumpWidget(buildWidget(lists: []));

        // Should show SizedBox.shrink() - nothing visible
        expect(find.text('רשימות נוספות'), findsNothing);
        expect(find.byType(StickyNote), findsNothing);
      });
    });

    group('Single List Tests', () {
      testWidgets('shows section with 1 list', (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list1]));

        // Header should show
        expect(find.text('רשימות נוספות'), findsOneWidget);
        expect(find.text('1'), findsOneWidget); // Count badge

        // List content should show
        expect(find.text('רשימת סופר'), findsOneWidget);
        expect(find.text('3 פריטים'), findsOneWidget);
      });

      testWidgets('shows correct item count for single list', (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list2]));

        expect(find.text('רשימת פארם'), findsOneWidget);
        expect(find.text('1 פריטים'), findsOneWidget);
      });

      testWidgets('handles empty list without crashing', (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list3]));

        expect(find.text('רשימה ריקה'), findsOneWidget);
        expect(find.text('0 פריטים'), findsNothing); // Empty list shows no count
      });
    });

    group('Multiple Lists Tests', () {
      testWidgets('shows all lists when multiple provided', (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list1, list2, list3]));

        // Header count should be 3
        expect(find.text('3'), findsOneWidget);

        // All list names should appear
        expect(find.text('רשימת סופר'), findsOneWidget);
        expect(find.text('רשימת פארם'), findsOneWidget);
        expect(find.text('רשימה ריקה'), findsOneWidget);
      });

      testWidgets('shows correct item counts for all lists', (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list1, list2]));

        expect(find.text('3 פריטים'), findsOneWidget);
        expect(find.text('1 פריטים'), findsOneWidget);
      });
    });

    group('UI Elements Tests', () {
      testWidgets('shows all required icons', (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list1]));

        // Header icon
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Icon && widget.icon == Icons.format_list_bulleted,
          ),
          findsOneWidget,
        );

        // List icon
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.shopping_basket,
          ),
          findsOneWidget,
        );

        // Arrow icon
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.chevron_right,
          ),
          findsOneWidget,
        );
      });

      testWidgets('header shows count badge with correct styling',
          (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list1, list2]));

        // Find the count badge container
        final badgeText = find.text('2');
        expect(badgeText, findsOneWidget);

        // Badge should be in a Container with background
        final containerFinder = find.ancestor(
          of: badgeText,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsAtLeastNWidgets(1));
      });
    });

    group('Interaction Tests', () {
      testWidgets('tapping list tile calls onTapList callback',
          (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list1]));

        expect(onTapListCalled, false);

        // Tap on the list tile
        await tester.tap(find.text('רשימת סופר'));
        await tester.pump();

        expect(onTapListCalled, true);
      });

      testWidgets('tapping anywhere in list tile triggers callback',
          (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list1]));

        expect(onTapListCalled, false);

        // Tap on item count text
        await tester.tap(find.text('3 פריטים'));
        await tester.pump();

        expect(onTapListCalled, true);
      });

      testWidgets('InkWell shows ripple effect on tap', (tester) async {
        await tester.pumpWidget(buildWidget(lists: [list1]));

        // Find InkWell
        final inkWellFinder = find.byType(InkWell);
        expect(inkWellFinder, findsOneWidget);

        // Tap should work
        await tester.tap(inkWellFinder);
        await tester.pump();

        expect(onTapListCalled, true);
      });
    });

    group('Text Overflow Tests', () {
      testWidgets('long list name truncates with ellipsis', (tester) async {
        final longNameList = ShoppingList(
          id: 'list_long',
          name: 'רשימה עם שם ארוך מאוד מאוד מאוד שצריך להיחתך',
          householdId: 'household1',
          createdBy: 'user1',
          createdDate: DateTime.now(),
          updatedDate: DateTime.now(),
          items: [
            UnifiedListItem.product(
              id: 'item1',
              name: 'מוצר',
              quantity: 1,
              category: 'אחר',
            ),
          ],
        );

        await tester.pumpWidget(buildWidget(lists: [longNameList]));

        // Text should exist
        final textFinder = find.text(longNameList.name);
        expect(textFinder, findsOneWidget);

        // Get the Text widget
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.maxLines, 1);
        expect(textWidget.overflow, TextOverflow.ellipsis);
      });
    });
  });
}
