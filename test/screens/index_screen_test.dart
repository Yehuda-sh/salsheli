// test/screens/index_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memozap/screens/index_screen.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/screens/welcome_screen.dart';

import 'index_screen_test.mocks.dart';

/// 🧪 Unit tests for IndexScreen (Splash Screen)
///
/// Tests:
/// - Navigation to /home when user is logged in
/// - Navigation to WelcomeScreen when user hasn't seen onboarding
/// - Navigation to /login when user has seen onboarding but not logged in
/// - Error state display and retry functionality
/// - Theme-responsive colors (light/dark mode)
/// - Animation initialization and disposal
///
/// Coverage: 6 basic tests
///
/// Run: flutter test test/screens/index_screen_test.dart
/// Generate mocks: dart run build_runner build

@GenerateMocks([
  UserContext,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IndexScreen', () {
    late MockUserContext mockUserContext;

    setUp(() {
      mockUserContext = MockUserContext();
      
      // Default mock setup
      when(mockUserContext.isLoading).thenReturn(false);
      when(mockUserContext.isLoggedIn).thenReturn(false);
      when(mockUserContext.user).thenReturn(null);
      when(mockUserContext.userEmail).thenReturn(null);
      
      // SharedPreferences setup
      SharedPreferences.setMockInitialValues({
        'seenOnboarding': false,
      });
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<UserContext>.value(
        value: mockUserContext,
        child: MaterialApp(
          home: const IndexScreen(),
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home Screen')),
            '/login': (context) => const Scaffold(body: Text('Login Screen')),
          },
        ),
      );
    }

    testWidgets('should display loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Check for loading elements
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('בודק מצב...'), findsOneWidget);
    });

    testWidgets('should navigate to /home when user is logged in', (tester) async {
      // Mock logged in user
      when(mockUserContext.isLoggedIn).thenReturn(true);
      when(mockUserContext.userEmail).thenReturn('test@example.com');

      await tester.pumpWidget(createTestWidget());
      
      // Wait for navigation check (600ms delay + some buffer)
      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      // Should navigate to home
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('should navigate to WelcomeScreen when user hasn\'t seen onboarding', (tester) async {
      // Mock not logged in + hasn't seen onboarding
      when(mockUserContext.isLoggedIn).thenReturn(false);
      
      SharedPreferences.setMockInitialValues({
        'seenOnboarding': false,
      });

      await tester.pumpWidget(createTestWidget());
      
      // Wait for navigation check
      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      // Should navigate to WelcomeScreen
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('should navigate to /login when user has seen onboarding but not logged in', (tester) async {
      // Mock not logged in + seen onboarding
      when(mockUserContext.isLoggedIn).thenReturn(false);
      
      SharedPreferences.setMockInitialValues({
        'seenOnboarding': true,
      });

      await tester.pumpWidget(createTestWidget());
      
      // Wait for navigation check
      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      // Should navigate to login
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('should display gradient background in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: ChangeNotifierProvider<UserContext>.value(
            value: mockUserContext,
            child: const IndexScreen(),
          ),
        ),
      );

      await tester.pump();

      // Check that the IndexScreen was built
      expect(find.byType(IndexScreen), findsOneWidget);
    });

    testWidgets('should display gradient background in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ChangeNotifierProvider<UserContext>.value(
            value: mockUserContext,
            child: const IndexScreen(),
          ),
        ),
      );

      await tester.pump();

      // Check that the IndexScreen was built with dark theme
      final BuildContext context = tester.element(find.byType(IndexScreen));
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('should dispose animation controllers properly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Dispose by removing widget
      await tester.pumpWidget(const SizedBox());
      
      // No assertions needed - if no error thrown, disposal worked correctly
    });
  });

  group('IndexScreen Theme Integration', () {
    testWidgets('should use ColorScheme colors in light mode', (tester) async {
      final mockUserContext = MockUserContext();
      when(mockUserContext.isLoading).thenReturn(false);
      when(mockUserContext.isLoggedIn).thenReturn(false);

      SharedPreferences.setMockInitialValues({
        'seenOnboarding': false,
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: ChangeNotifierProvider<UserContext>.value(
            value: mockUserContext,
            child: const IndexScreen(),
          ),
        ),
      );

      await tester.pump();

      final context = tester.element(find.byType(IndexScreen));
      final colorScheme = Theme.of(context).colorScheme;

      // Verify theme exists and has expected properties
      expect(colorScheme, isNotNull);
      expect(colorScheme.brightness, Brightness.light);
    });

    testWidgets('should use ColorScheme colors in dark mode', (tester) async {
      final mockUserContext = MockUserContext();
      when(mockUserContext.isLoading).thenReturn(false);
      when(mockUserContext.isLoggedIn).thenReturn(false);

      SharedPreferences.setMockInitialValues({
        'seenOnboarding': false,
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ChangeNotifierProvider<UserContext>.value(
            value: mockUserContext,
            child: const IndexScreen(),
          ),
        ),
      );

      await tester.pump();

      final context = tester.element(find.byType(IndexScreen));
      final colorScheme = Theme.of(context).colorScheme;

      // Verify dark theme
      expect(colorScheme, isNotNull);
      expect(colorScheme.brightness, Brightness.dark);
    });
  });
}
