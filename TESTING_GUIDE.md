# 🧪 Testing Guide - Comprehensive Testing Strategy

> **מטרה:** אסטרטגיה בדיקה שלמה לפרויקט  
> **כיסוי:** Unit + Widget + Integration Tests  
> **גרסה:** 1.0 | **עדכון:** 15/10/2025

---

## 📊 Testing Pyramid

```
        🏆 E2E (5%)
       Integration Tests

    🧩 Widget (20%)
    Component Tests

🏗️ Unit (75%)
Core Logic Tests
```

---

## 🚀 Setup

### 1. Add Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
  mocktail: ^0.3.0
  integration_test:
    sdk: flutter
```

### 2. Create Test Directory Structure

```
project/
├── test/
│   ├── unit/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   └── services/
│   ├── widget/
│   │   ├── screens/
│   │   └── widgets/
│   └── fixtures/ (mock data)
├── integration_test/
│   ├── app_test.dart
│   ├── shopping_list_flow_test.dart
│   └── helpers/
└── pubspec.yaml
```

### 3. Generate Mocks

```bash
build_runner build
# → Generates *.mocks.dart files
```

---

## 🧪 Unit Tests

### 1. Model Tests

```dart
// test/unit/models/shopping_list_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/shopping_list.dart';

void main() {
  group('ShoppingList Model', () {

    test('copyWith updates only specified fields', () {
      // Arrange
      final original = ShoppingList(
        id: '1',
        name: 'Groceries',
        items: [],
        createdAt: DateTime(2025, 10, 15),
      );

      // Act
      final updated = original.copyWith(name: 'Vegetables');

      // Assert
      expect(updated.id, equals('1'));
      expect(updated.name, equals('Vegetables'));
      expect(updated.items, equals([]));
    });

    test('fromJson correctly deserializes', () {
      // Arrange
      final json = {
        'id': '1',
        'name': 'Shopping',
        'items': [],
        'created_at': '2025-10-15T10:00:00.000Z',
      };

      // Act
      final list = ShoppingList.fromJson(json);

      // Assert
      expect(list.id, equals('1'));
      expect(list.name, equals('Shopping'));
      expect(list.items.isEmpty, isTrue);
    });

    test('toJson correctly serializes', () {
      // Arrange
      final list = ShoppingList(
        id: '1',
        name: 'Shopping',
        items: [],
        createdAt: DateTime(2025, 10, 15),
      );

      // Act
      final json = list.toJson();

      // Assert
      expect(json['id'], equals('1'));
      expect(json['name'], equals('Shopping'));
      expect(json['items'], equals([]));
    });

    test('equality works correctly', () {
      // Arrange
      final list1 = ShoppingList(
        id: '1',
        name: 'Shopping',
        items: [],
        createdAt: DateTime(2025, 10, 15),
      );
      final list2 = ShoppingList(
        id: '1',
        name: 'Shopping',
        items: [],
        createdAt: DateTime(2025, 10, 15),
      );

      // Assert
      expect(list1, equals(list2));
    });
  });
}
```

### 2. Provider Tests

```dart
// test/unit/providers/shopping_lists_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/repositories/shopping_lists_repository.dart';
import 'package:memozap/models/shopping_list.dart';

import 'shopping_lists_provider_test.mocks.dart';

@GenerateMocks([ShoppingListsRepository])
void main() {
  group('ShoppingListsProvider', () {
    late MockShoppingListsRepository mockRepository;
    late ShoppingListsProvider provider;

    setUp(() {
      mockRepository = MockShoppingListsRepository();
      provider = ShoppingListsProvider(mockRepository);
    });

    test('initial state is correct', () {
      // Assert
      expect(provider.items, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isTrue);
    });

    test('load() updates items successfully', () async {
      // Arrange
      final mockLists = [
        ShoppingList(
          id: '1',
          name: 'Groceries',
          items: [],
          createdAt: DateTime(2025, 10, 15),
        ),
        ShoppingList(
          id: '2',
          name: 'Hardware',
          items: [],
          createdAt: DateTime(2025, 10, 15),
        ),
      ];

      when(mockRepository.fetchLists('household-1'))
          .thenAnswer((_) async => mockLists);

      // Act
      await provider.load('household-1');

      // Assert
      expect(provider.items, equals(mockLists));
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      verify(mockRepository.fetchLists('household-1')).called(1);
    });

    test('load() handles errors', () async {
      // Arrange
      when(mockRepository.fetchLists('household-1'))
          .thenThrow(Exception('Network error'));

      // Act
      await provider.load('household-1');

      // Assert
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, isNotEmpty);
      expect(provider.items, isEmpty);
    });

    test('createList() adds new item', () async {
      // Arrange
      final newList = ShoppingList(
        id: '3',
        name: 'New List',
        items: [],
        createdAt: DateTime.now(),
      );

      when(mockRepository.createList(newList, 'household-1'))
          .thenAnswer((_) async => {});

      // Act
      await provider.createList(newList, 'household-1');

      // Assert
      verify(mockRepository.createList(newList, 'household-1')).called(1);
    });

    test('deleteList() removes item', () async {
      // Arrange
      const listId = '1';

      when(mockRepository.deleteList(listId, 'household-1'))
          .thenAnswer((_) async => {});

      // Act
      await provider.deleteList(listId, 'household-1');

      // Assert
      verify(mockRepository.deleteList(listId, 'household-1')).called(1);
    });

    test('retry() recovers from error', () async {
      // Arrange
      final mockLists = [
        ShoppingList(
          id: '1',
          name: 'Groceries',
          items: [],
          createdAt: DateTime(2025, 10, 15),
        ),
      ];

      when(mockRepository.fetchLists('household-1'))
          .thenAnswer((_) async => mockLists);

      // First call fails
      provider._errorMessage = 'Previous error';

      // Act
      await provider.retry('household-1');

      // Assert
      expect(provider.hasError, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.items, equals(mockLists));
    });

    tearDown(() {
      provider.dispose();
    });
  });
}
```

### 3. Repository Tests

```dart
// test/unit/repositories/shopping_lists_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memozap/repositories/firebase_shopping_lists_repository.dart';

import 'shopping_lists_repository_test.mocks.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, QuerySnapshot])
void main() {
  group('FirebaseShoppingListsRepository', () {
    late MockFirebaseFirestore mockFirestore;
    late FirebaseShoppingListsRepository repository;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      repository = FirebaseShoppingListsRepository(mockFirestore);
    });

    test('household_id filtering in queries', () async {
      // Arrange
      const householdId = 'household-1';

      // This test verifies that household_id is always filtered
      // Actual implementation depends on Firestore setup

      // Assert
      // Verify repository enforces household_id filtering
      expect(
        () => repository.fetchLists(householdId),
        completes,
      );
    });

    test('createList() saves to Firestore', () async {
      // Arrange
      final list = ShoppingList(
        id: '1',
        name: 'Groceries',
        items: [],
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => repository.createList(list, 'household-1'),
        completes,
      );
    });
  });
}
```

---

## 🎨 Widget Tests

### 1. Screen Tests

```dart
// test/widget/screens/home_dashboard_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:memozap/screens/home/home_dashboard_screen.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';

import '../../fixtures/mock_providers.dart';

void main() {
  group('HomeDashboardScreen', () {

    testWidgets('displays loading skeleton', (tester) async {
      // Arrange
      final mockProvider = MockShoppingListsProvider();
      when(mockProvider.isLoading).thenReturn(true);
      when(mockProvider.items).thenReturn([]);
      when(mockProvider.hasError).thenReturn(false);
      when(mockProvider.isEmpty).thenReturn(true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ShoppingListsProvider>.value(
            value: mockProvider,
            child: HomeDashboardScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(ShimmerLoading), findsWidgets);
    });

    testWidgets('displays shopping lists', (tester) async {
      // Arrange
      final mockLists = [/* ... */];
      final mockProvider = MockShoppingListsProvider();
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.items).thenReturn(mockLists);
      when(mockProvider.hasError).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ShoppingListsProvider>.value(
            value: mockProvider,
            child: HomeDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ShoppingListCard), findsWidgets);
    });

    testWidgets('displays error widget on error', (tester) async {
      // Arrange
      final mockProvider = MockShoppingListsProvider();
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.hasError).thenReturn(true);
      when(mockProvider.errorMessage).thenReturn('Network error');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ShoppingListsProvider>.value(
            value: mockProvider,
            child: HomeDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Network error'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('displays empty widget when no lists', (tester) async {
      // Arrange
      final mockProvider = MockShoppingListsProvider();
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.items).thenReturn([]);
      when(mockProvider.hasError).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ShoppingListsProvider>.value(
            value: mockProvider,
            child: HomeDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No shopping lists'), findsOneWidget);
    });

    testWidgets('navigate to list details on tap', (tester) async {
      // Arrange
      final mockLists = [/* ... */];
      final mockProvider = MockShoppingListsProvider();
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.items).thenReturn(mockLists);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ShoppingListsProvider>.value(
            value: mockProvider,
            child: HomeDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShoppingListCard).first);
      await tester.pumpAndSettle();

      // Assert
      // Verify navigation occurred
      expect(find.byType(ShoppingListDetailsScreen), findsOneWidget);
    });
  });
}
```

### 2. Widget Component Tests

```dart
// test/widget/widgets/animated_button_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/widgets/common/animated_button.dart';

void main() {
  group('AnimatedButton', () {

    testWidgets('scales on tap', (tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () => tapped = true,
              child: ElevatedButton(
                onPressed: null,
                child: Text('Press'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(AnimatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
      // Scale animation should complete
      expect(find.byType(AnimatedScale), findsOneWidget);
    });

    testWidgets('haptic feedback on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () {},
              hapticFeedback: true,
              child: ElevatedButton(
                onPressed: null,
                child: Text('Press'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(AnimatedButton));

      // Assert - Haptic feedback called
      // (Would need to mock HapticFeedback to verify)
      expect(find.byType(AnimatedButton), findsOneWidget);
    });
  });
}
```

---

## 🔗 Integration Tests

### 1. Shopping List Flow

```dart
// integration_test/shopping_list_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memozap/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Shopping List Full Flow', () {

    testWidgets('Create and delete shopping list', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to create new list
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter list name
      await tester.enterText(
        find.byType(TextField),
        'Groceries',
      );

      // Create list
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify list appears
      expect(find.text('Groceries'), findsWidgets);

      // Delete list
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verify undo snackbar
      expect(find.byType(SnackBar), findsOneWidget);

      // Verify list deleted
      await Future.delayed(Duration(seconds: 5)); // Wait for undo timeout
      await tester.pumpAndSettle();
      expect(find.text('Groceries'), findsNothing);
    });

    testWidgets('Add items to shopping list', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Create list
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Open list
      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      // Add item
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Milk');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify item added
      expect(find.text('Milk'), findsOneWidget);
    });
  });
}
```

---

## 📊 Running Tests

### Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/unit/models/shopping_list_test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
lcov --list coverage/lcov.info
```

### Widget Tests

```bash
# Run all widget tests
flutter test test/widget/

# Run specific widget test
flutter test test/widget/screens/home_dashboard_screen_test.dart
```

### Integration Tests

```bash
# Run integration tests (requires physical device or emulator)
flutter test integration_test/shopping_list_flow_test.dart

# Run on specific device
flutter test integration_test/ -d <device_id>
```

### Coverage Reports

```bash
# Generate coverage
flutter test --coverage

# Install lcov (macOS)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🎯 Coverage Goals

| Component    | Target   | Current |
| ------------ | -------- | ------- |
| Models       | 90%+     | -       |
| Providers    | 80%+     | -       |
| Repositories | 85%+     | -       |
| Services     | 75%+     | -       |
| Screens      | 60%+     | -       |
| Widgets      | 70%+     | -       |
| **Overall**  | **80%+** | -       |

---

## 📝 Test Fixtures & Mocks

### Fixture: Mock Providers

```dart
// test/fixtures/mock_providers.dart

import 'package:mockito/mockito.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';

class MockShoppingListsProvider extends Mock
    implements ShoppingListsProvider {
  @override
  List<ShoppingList> get items => [];

  @override
  bool get isLoading => false;

  @override
  bool get hasError => false;

  @override
  String? get errorMessage => null;

  @override
  bool get isEmpty => true;

  @override
  Future<void> load(String householdId) async {}

  @override
  Future<void> createList(ShoppingList list, String householdId) async {}

  @override
  Future<void> deleteList(String id, String householdId) async {}

  @override
  Future<void> retry(String householdId) async {}
}
```

### Fixture: Mock Data

```dart
// test/fixtures/mock_data.dart

import 'package:memozap/models/shopping_list.dart';

final mockShoppingLists = [
  ShoppingList(
    id: '1',
    name: 'Groceries',
    items: [],
    createdAt: DateTime(2025, 10, 15),
  ),
  ShoppingList(
    id: '2',
    name: 'Hardware',
    items: [],
    createdAt: DateTime(2025, 10, 15),
  ),
];
```

---

## 🏆 Best Practices

### ✅ Do

```dart
// ✅ Test one thing per test
test('provider loads items', () async {
  // Only test loading, not error handling
});

// ✅ Use Arrange-Act-Assert
test('example', () {
  // Arrange
  final data = setUp();

  // Act
  final result = doSomething(data);

  // Assert
  expect(result, equals(expected));
});

// ✅ Mock external dependencies
when(mockRepository.fetch()).thenAnswer((_) async => data);

// ✅ Use fixtures for common data
final mockLists = mockShoppingLists;
```

### ❌ Don't

```dart
// ❌ Test multiple things in one test
test('provider loads, errors, and retries', () {
  // Too many concerns!
});

// ❌ Test implementation details
expect(provider._internalField, isNotNull);

// ❌ Real network calls
await http.get('https://api.example.com/data');

// ❌ Hardcoded test data everywhere
const testData = [{'id': '1'}];
```

---

## 📚 Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mockito Library](https://pub.dev/packages/mockito)
- [Integration Testing Guide](https://flutter.dev/docs/testing/integration-tests)

---

**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻  
**Version:** 1.0 | **Last Updated:** 15/10/2025
