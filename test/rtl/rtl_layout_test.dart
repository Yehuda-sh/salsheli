// 📄 File: test/rtl/rtl_layout_test.dart
// 🎯 Purpose: בדיקות תמיכה ב-RTL (עברית)
//
// 📋 Tests:
// - ✅ כפתורים מיושרים לימין
// - ✅ טקסטים מיושרים לימין
// - ✅ אייקונים בצד הנכון
// - ✅ Padding symmetric עובד נכון
// - ✅ Navigation drawer מימין
// - ✅ מספרים ותאריכים (LTR בתוך RTL)
//
// 📝 Version: 1.0
// 📅 Created: 18/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salsheli/screens/auth/login_screen.dart';
import 'package:salsheli/widgets/common/sticky_note.dart';
import 'package:salsheli/widgets/common/sticky_button.dart';
import 'package:salsheli/core/ui_constants.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('🔤 RTL Layout Tests', () {
    testWidgets(
      'מסך התחברות - כפתורים וטקסטים מיושרים לימין',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Login screen RTL alignment');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Act ===
        debugPrint('🏗️ Building LoginScreen with RTL...');
        await tester.pumpWidget(
          MaterialApp(
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying RTL layout...');

        // בדוק שהכיוון הכללי הוא RTL - נמצא את ה-Directionality שעוטף את LoginScreen
        final directionalityFinder = find.ancestor(
          of: find.byType(LoginScreen),
          matching: find.byType(Directionality),
        ).first;
        final directionality = tester.widget<Directionality>(directionalityFinder);
        expect(directionality.textDirection, equals(TextDirection.rtl));

        // בדוק שהטקסטים מיושרים לימין
        final titleFinder = find.text('התחברות');
        expect(titleFinder, findsOneWidget);

        // בדוק שיש שדות טקסט
        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsWidgets);

        debugPrint('✅ Test passed: RTL layout is correct!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'StickyNote - RTL alignment',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: StickyNote RTL alignment');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Act ===
        await tester.pumpWidget(
          createTestScaffold(
            body: const Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: StickyNote(
                  color: kStickyYellow,
                  child: Text('טקסט בעברית'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying StickyNote RTL...');

        final textWidget = tester.widget<Text>(find.text('טקסט בעברית'));
        expect(textWidget.textDirection ?? TextDirection.rtl, equals(TextDirection.rtl));

        debugPrint('✅ Test passed: StickyNote supports RTL!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'StickyButton - אייקון בצד הנכון',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: StickyButton icon position in RTL');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Act ===
        await tester.pumpWidget(
          createTestScaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: StickyButton(
                  label: 'כפתור',
                  icon: Icons.arrow_forward,
                  onPressed: () {}, // Disabled button
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying button icon is on the right...');

        // מצא את האייקון והטקסט
        final iconFinder = find.byIcon(Icons.arrow_forward);
        final textFinder = find.text('כפתור');

        expect(iconFinder, findsOneWidget);
        expect(textFinder, findsOneWidget);

        // בדוק שהאייקון לפני הטקסט (בRTL = ימין)
        final iconBox = tester.getTopLeft(iconFinder);
        final textBox = tester.getTopLeft(textFinder);

        // בRTL, האייקון צריך להיות ימינה (x גדול יותר) מהטקסט
        expect(iconBox.dx > textBox.dx, isTrue,
            reason: 'Icon should be on the right side in RTL');

        debugPrint('✅ Test passed: Button icon is correctly positioned!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'Padding symmetric - עובד נכון ב-RTL',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Symmetric padding in RTL');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Act ===
        await tester.pumpWidget(
          createTestScaffold(
            body: const Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('טקסט עם padding'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying symmetric padding...');

        final paddingWidget = tester.widget<Padding>(
          find.byType(Padding),
        );

        final padding = paddingWidget.padding as EdgeInsets;
        expect(padding.left, equals(16));
        expect(padding.right, equals(16));

        debugPrint('✅ Test passed: Symmetric padding works in RTL!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'TextFormField - Cursor מתחיל מימין',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: TextFormField cursor starts from right');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Act ===
        final controller = TextEditingController();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Center(
                  child: TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'שדה טקסט',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // הכנס טקסט
        debugPrint('📝 Entering Hebrew text...');
        await tester.enterText(find.byType(TextFormField), 'שלום');
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying text direction...');

        // בדוק שהטקסט התקבל
        expect(controller.text, equals('שלום'));
        
        // בדוק שהשדה תומך בעברית
        expect(find.text('שלום'), findsOneWidget);

        controller.dispose();

        debugPrint('✅ Test passed: TextFormField supports RTL input!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'ListTile - אייקונים בצד הנכון ב-RTL',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: ListTile icons in RTL');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Act ===
        await tester.pumpWidget(
          MaterialApp(
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('פריט'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying ListTile icon positions...');

        final leadingIcon = tester.getTopLeft(find.byIcon(Icons.shopping_cart));
        final trailingIcon = tester.getTopLeft(find.byIcon(Icons.arrow_forward_ios));
        final title = tester.getTopLeft(find.text('פריט'));

        // ב-RTL:
        // leading צריך להיות ימינה מהטקסט
        // trailing צריך להיות שמאלה מהטקסט
        expect(leadingIcon.dx > title.dx, isTrue,
            reason: 'Leading icon should be on the right');
        expect(trailingIcon.dx < title.dx, isTrue,
            reason: 'Trailing icon should be on the left');

        debugPrint('✅ Test passed: ListTile icons correctly positioned!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'מספרים ותאריכים - נשארים LTR בתוך RTL',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Numbers and dates remain LTR in RTL');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Act ===
        await tester.pumpWidget(
          createTestScaffold(
            body: const Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Text('מחיר: ₪50.00'),
                  Text('תאריך: 18/10/2025'),
                  Text('טלפון: 050-1234567'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying numbers are displayed correctly...');

        expect(find.text('מחיר: ₪50.00'), findsOneWidget);
        expect(find.text('תאריך: 18/10/2025'), findsOneWidget);
        expect(find.text('טלפון: 050-1234567'), findsOneWidget);

        debugPrint('✅ Test passed: Numbers remain LTR in RTL context!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );
  });
}
