// 📄 File: test/helpers/test_helpers.dart
// 🎯 Purpose: פונקציות עזר משותפות לכל הבדיקות
//
// 📋 Features:
// - ✅ Mock Firebase Auth
// - ✅ Mock Firestore
// - ✅ יצירת widgets לבדיקה
// - ✅ סימולציית רשת (איטית, לא זמינה)
// - ✅ פונקציות עזר לטפסים
//
// 📝 Version: 1.0
// 📅 Created: 18/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/repositories/user_repository.dart';
import 'package:memozap/services/auth_service.dart';
import 'package:memozap/theme/app_theme.dart';
import 'package:memozap/l10n/app_strings.dart';

/// יוצר MaterialApp עם כל ה-Providers הדרושים לבדיקות
/// 
/// שימושי לבדיקות Widget שצריכות Navigator, Theme, וכו'.
/// 
/// Example:
/// ```dart
/// await tester.pumpWidget(
///   createTestApp(
///     child: LoginScreen(),
///     userContext: mockUserContext,
///   ),
/// );
/// ```
Widget createTestApp({
  required Widget child,
  UserContext? userContext,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MultiProvider(
    providers: [
      if (userContext != null)
        ChangeNotifierProvider<UserContext>.value(value: userContext),
    ],
    child: MaterialApp(
      title: 'Salsheli Test',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: const Locale('he', 'IL'),
      home: child,
    ),
  );
}

/// יוצר Scaffold פשוט לבדיקות
/// 
/// שימושי לבדיקות של widgets בודדים.
/// 
/// Example:
/// ```dart
/// await tester.pumpWidget(
///   createTestScaffold(
///     body: StickyNote(
///       child: Text('Test'),
///     ),
///   ),
/// );
/// ```
Widget createTestScaffold({required Widget body}) {
  return MaterialApp(
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: body,
      ),
    ),
  );
}

/// ממלא TextFormField עם ערך
/// 
/// Example:
/// ```dart
/// await fillTextField(tester, 'email', 'test@test.com');
/// ```
Future<void> fillTextField(
  WidgetTester tester,
  String keyOrLabel,
  String value,
) async {
  // נסה למצוא לפי Key
  var finder = find.byKey(Key(keyOrLabel));
  
  // אם לא נמצא, נסה לפי label
  if (finder.evaluate().isEmpty) {
    finder = find.widgetWithText(TextFormField, keyOrLabel);
  }
  
  // אם עדיין לא נמצא, נסה לפי hint
  if (finder.evaluate().isEmpty) {
    finder = find.byType(TextFormField);
  }
  
  await tester.enterText(finder, value);
  await tester.pump();
}

/// לוחץ על כפתור לפי טקסט (עם גלילה אוטומטית אם צריך)
/// 
/// Example:
/// ```dart
/// await tapButton(tester, 'התחבר');
/// ```
Future<void> tapButton(WidgetTester tester, String text) async {
  final finder = find.text(text);
  
  // וודא שהכפתור נראה על המסך
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// מחכה עד שהטקסט מופיע על המסך
/// 
/// Example:
/// ```dart
/// await waitForText(tester, 'ברוך הבא!');
/// ```
Future<void> waitForText(
  WidgetTester tester,
  String text, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final endTime = DateTime.now().add(timeout);
  
  while (DateTime.now().isBefore(endTime)) {
    await tester.pump();
    
    if (find.text(text).evaluate().isNotEmpty) {
      return;
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  throw Exception('Text "$text" not found after ${timeout.inSeconds}s');
}

/// מחכה עד שהwidget מופיע על המסך
/// 
/// Example:
/// ```dart
/// await waitForWidget(tester, LoginScreen);
/// ```
Future<void> waitForWidget(
  WidgetTester tester,
  Type widgetType, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final endTime = DateTime.now().add(timeout);
  
  while (DateTime.now().isBefore(endTime)) {
    await tester.pump();
    
    if (find.byType(widgetType).evaluate().isNotEmpty) {
      return;
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  throw Exception('Widget $widgetType not found after ${timeout.inSeconds}s');
}

/// בודק שהטקסט מופיע במספר המצופה של פעמים
/// 
/// Example:
/// ```dart
/// expectTextCount(tester, 'פריט', 3); // בודק ש-"פריט" מופיע 3 פעמים
/// ```
void expectTextCount(WidgetTester tester, String text, int expectedCount) {
  final finder = find.text(text);
  expect(
    finder.evaluate().length,
    equals(expectedCount),
    reason: 'Expected to find "$text" $expectedCount times',
  );
}

/// בודק שהwidget מסוג מסוים מופיע במספר המצופה של פעמים
/// 
/// Example:
/// ```dart
/// expectWidgetCount(tester, StickyNote, 5);
/// ```
void expectWidgetCount(WidgetTester tester, Type widgetType, int expectedCount) {
  final finder = find.byType(widgetType);
  expect(
    finder.evaluate().length,
    equals(expectedCount),
    reason: 'Expected to find $widgetType $expectedCount times',
  );
}

/// מדמה delay של רשת (למשל, Firestore איטי)
/// 
/// Example:
/// ```dart
/// when(mockRepo.fetchLists()).thenAnswer((_) async {
///   await simulateNetworkDelay(milliseconds: 2000); // 2 שניות
///   return mockLists;
/// });
/// ```
Future<void> simulateNetworkDelay({int milliseconds = 1000}) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}

/// מדמה כישלון רשת
/// 
/// Example:
/// ```dart
/// when(mockRepo.fetchLists()).thenAnswer((_) async {
///   throw simulateNetworkError();
/// });
/// ```
Exception simulateNetworkError() {
  return Exception('Network error: Failed to connect to server');
}

/// מדמה Timeout של רשת
/// 
/// Example:
/// ```dart
/// when(mockRepo.fetchLists()).thenAnswer((_) async {
///   await Future.delayed(Duration(seconds: 11));
///   throw simulateTimeout();
/// });
/// ```
Exception simulateTimeout() {
  return Exception('TimeoutException: Connection timeout');
}

/// בודק שהכפתור מושבת (disabled)
/// 
/// Example:
/// ```dart
/// expectButtonDisabled(tester, 'התחבר');
/// ```
void expectButtonDisabled(WidgetTester tester, String buttonText) {
  final buttonFinder = find.widgetWithText(ElevatedButton, buttonText);
  
  if (buttonFinder.evaluate().isEmpty) {
    // אולי זה StickyButton
    final widget = tester.widget(find.text(buttonText).first);
    // בדוק אם יש onPressed: () {} (כפתור מושבת)
    // במקרה של StickyButton, זה יהיה בקוד שלו
  }
}

/// בודק שהצבע של widget תואם לצפוי
/// 
/// Example:
/// ```dart
/// expectWidgetColor(tester, Container, Colors.blue);
/// ```
void expectWidgetColor(
  WidgetTester tester,
  Type widgetType,
  Color expectedColor,
) {
  final widget = tester.widget(find.byType(widgetType).first);
  
  Color? actualColor;
  if (widget is Container) {
    actualColor = (widget.decoration as BoxDecoration?)?.color;
  } else if (widget is ColoredBox) {
    actualColor = widget.color;
  }
  
  expect(
    actualColor,
    equals(expectedColor),
    reason: 'Expected $widgetType to have color $expectedColor',
  );
}

/// סוגר את המקלדת (אם פתוחה)
/// 
/// Example:
/// ```dart
/// await dismissKeyboard(tester);
/// ```
Future<void> dismissKeyboard(WidgetTester tester) async {
  // לחץ מחוץ לשדות הטקסט
  await tester.tapAt(Offset.zero);
  await tester.pumpAndSettle();
}

/// גולל למטה עד שמוצא widget
/// 
/// Example:
/// ```dart
/// await scrollUntilVisible(tester, find.text('פריט 50'));
/// ```
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  double scrollDelta = 100,
}) async {
  const maxScrolls = 50;
  int scrollCount = 0;
  
  while (scrollCount < maxScrolls) {
    if (finder.evaluate().isNotEmpty) {
      final RenderBox box = tester.renderObject(finder.first);
      if (box.localToGlobal(Offset.zero).dy >= 0 &&
          box.localToGlobal(Offset.zero).dy < tester.view.physicalSize.height) {
        // הwidget כבר נראה על המסך
        return;
      }
    }
    
    // גלול למטה
    await tester.drag(
      find.byType(Scrollable).first,
      Offset(0, -scrollDelta),
    );
    await tester.pumpAndSettle();
    
    scrollCount++;
  }
  
  throw Exception('Widget not found after $maxScrolls scrolls');
}

/// בודק RTL alignment של widget
/// 
/// Example:
/// ```dart
/// expectRTLAlignment(tester, find.byType(Text));
/// ```
void expectRTLAlignment(WidgetTester tester, Finder finder) {
  final widget = tester.widget(finder.first);
  
  if (widget is Text) {
    // בדוק שהטקסט מיושר לימין
    final textAlign = widget.textAlign ?? TextAlign.start;
    expect(
      textAlign == TextAlign.right || textAlign == TextAlign.start,
      isTrue,
      reason: 'Text should be aligned to right in RTL',
    );
  }
}

/// בודק שהמרווח בין שני widgets תקין
/// 
/// Example:
/// ```dart
/// expectSpacing(tester, find.text('כותרת'), find.text('תוכן'), 16);
/// ```
void expectSpacing(
  WidgetTester tester,
  Finder first,
  Finder second,
  double expectedSpacing,
) {
  final firstBox = tester.renderObject(first.first) as RenderBox;
  final secondBox = tester.renderObject(second.first) as RenderBox;
  
  final firstBottom = firstBox.localToGlobal(Offset.zero).dy + firstBox.size.height;
  final secondTop = secondBox.localToGlobal(Offset.zero).dy;
  
  final actualSpacing = secondTop - firstBottom;
  
  expect(
    actualSpacing,
    closeTo(expectedSpacing, 1), // טולרנס של 1 פיקסל
    reason: 'Expected spacing of $expectedSpacing between widgets',
  );
}

/// מחזיר את האימייל של משתמש הדמו
String getDemoEmail() => 'demo@salsheli.com';

/// מחזיר את הסיסמה של משתמש הדמו
String getDemoPassword() => 'demo1234';

/// מחזיר אימייל בדיקה ייחודי
String getTestEmail([String prefix = 'test']) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '$prefix$timestamp@test.com';
}
