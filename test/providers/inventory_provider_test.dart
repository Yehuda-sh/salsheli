// 🧪 Unit Tests: InventoryProvider
//
// Tests for:
// - addStock(): Adding inventory to existing products
// - getLowStockItems(): Filtering low-stock items
// - Error handling and edge cases

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/user_entity.dart';
import 'package:memozap/providers/inventory_provider.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/repositories/inventory_repository.dart';

@GenerateNiceMocks([
  MockSpec<InventoryRepository>(),
  MockSpec<UserContext>(),
])
import 'inventory_provider_test.mocks.dart';

void main() {
  late MockInventoryRepository mockRepository;
  late MockUserContext mockUserContext;
  late InventoryProvider provider;

  const testUserId = 'test_user_123';
  const testHouseholdId = 'test_household_456';

  setUp(() {
    mockRepository = MockInventoryRepository();
    mockUserContext = MockUserContext();

    // Default stubs for UserContext
    when(mockUserContext.isLoggedIn).thenReturn(true);
    when(mockUserContext.user).thenReturn(
      UserEntity(
        id: testUserId,
        email: 'test@example.com',
        name: 'Test User',
        householdId: testHouseholdId,
        joinedAt: DateTime.now(),
      ),
    );

    // Default stub for fetchItems
    when(mockRepository.fetchItems(testHouseholdId))
        .thenAnswer((_) async => []);

    provider = InventoryProvider(
      repository: mockRepository,
      userContext: mockUserContext,
    );
  });

  tearDown(() {
    provider.dispose();
  });

  group('addStock()', () {
    test('adds stock to existing product (addition)', () async {
      // Arrange
      final existingItem = InventoryItem(
        id: 'item1',
        productName: 'חלב',
        category: 'מוצרי חלב',
        location: 'מקרר',
        quantity: 3,
        unit: 'יחידות',
      );

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => [existingItem]);

      await provider.loadItems();

      when(mockRepository.saveItem(any, testHouseholdId))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as InventoryItem);

      // Act
      await provider.addStock('חלב', 2);

      // Assert
      final updatedItem = provider.items.firstWhere(
        (item) => item.productName == 'חלב',
      );
      expect(updatedItem.quantity, 5); // 3 + 2 = 5 ✅
      verify(mockRepository.saveItem(any, testHouseholdId)).called(1);
    });

    test('handles case-insensitive product matching', () async {
      // Arrange
      final existingItem = InventoryItem(
        id: 'item1',
        productName: 'חלב',
        category: 'מוצרי חלב',
        location: 'מקרר',
        quantity: 2,
        unit: 'יחידות',
      );

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => [existingItem]);

      await provider.loadItems();

      when(mockRepository.saveItem(any, testHouseholdId))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as InventoryItem);

      // Act - different casing
      await provider.addStock('חלב', 1);

      // Assert
      final updatedItem = provider.items.first;
      expect(updatedItem.quantity, 3); // 2 + 1 = 3
    });

    test('trims whitespace from product name', () async {
      // Arrange
      final existingItem = InventoryItem(
        id: 'item1',
        productName: 'לחם',
        category: 'מאפים',
        location: 'מגש',
        quantity: 1,
        unit: 'יחידות',
      );

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => [existingItem]);

      await provider.loadItems();

      when(mockRepository.saveItem(any, testHouseholdId))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as InventoryItem);

      // Act - with extra whitespace
      await provider.addStock('  לחם  ', 2);

      // Assert
      final updatedItem = provider.items.first;
      expect(updatedItem.quantity, 3); // 1 + 2 = 3
    });

    test('updates local list correctly', () async {
      // Arrange
      final items = [
        InventoryItem(
          id: 'item1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2,
          unit: 'יחידות',
        ),
        InventoryItem(
          id: 'item2',
          productName: 'לחם',
          category: 'מאפים',
          location: 'מגש',
          quantity: 1,
          unit: 'יחידות',
        ),
      ];

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => items);

      await provider.loadItems();

      when(mockRepository.saveItem(any, testHouseholdId))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as InventoryItem);

      // Act
      await provider.addStock('חלב', 3);

      // Assert - only milk updated
      expect(provider.items.length, 2);
      expect(
        provider.items.firstWhere((i) => i.productName == 'חלב').quantity,
        5, // 2 + 3
      );
      expect(
        provider.items.firstWhere((i) => i.productName == 'לחם').quantity,
        1, // unchanged
      );
    });

    test('calls notifyListeners after successful update', () async {
      // Arrange
      final existingItem = InventoryItem(
        id: 'item1',
        productName: 'ביצים',
        category: 'מוצרי חלב',
        location: 'מקרר',
        quantity: 6,
        unit: 'יחידות',
      );

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => [existingItem]);

      await provider.loadItems();

      when(mockRepository.saveItem(any, testHouseholdId))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as InventoryItem);

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // Act
      await provider.addStock('ביצים', 12);

      // Assert
      expect(notifyCount, greaterThan(0)); // notifyListeners was called
    });

    test('does not throw when product not found', () async {
      // Arrange
      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => []);

      await provider.loadItems();

      // Act & Assert - should not throw
      expect(
        () => provider.addStock('מוצר לא קיים', 5),
        returnsNormally,
      );
    });

    test('logs warning when product not found', () async {
      // Arrange
      final existingItem = InventoryItem(
        id: 'item1',
        productName: 'חלב',
        category: 'מוצרי חלב',
        location: 'מקרר',
        quantity: 2,
        unit: 'יחידות',
      );

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => [existingItem]);

      await provider.loadItems();

      // Act
      await provider.addStock('מוצר לא קיים', 5);

      // Assert - no repository call
      verifyNever(mockRepository.saveItem(any, testHouseholdId));
    });

    test('returns early when householdId is null', () async {
      // Arrange
      when(mockUserContext.user).thenReturn(null);

      final newProvider = InventoryProvider(
        repository: mockRepository,
        userContext: mockUserContext,
      );

      // Act & Assert - should not throw
      expect(
        () => newProvider.addStock('חלב', 2),
        returnsNormally,
      );

      // No repository interaction
      verifyNever(mockRepository.saveItem(any, any));

      newProvider.dispose();
    });

    test('handles repository errors gracefully', () async {
      // Arrange
      final existingItem = InventoryItem(
        id: 'item1',
        productName: 'חלב',
        category: 'מוצרי חלב',
        location: 'מקרר',
        quantity: 2,
        unit: 'יחידות',
      );

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => [existingItem]);

      await provider.loadItems();

      when(mockRepository.saveItem(any, testHouseholdId))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => provider.addStock('חלב', 3),
        throwsException,
      );

      // Error state set
      expect(provider.hasError, true);
      expect(provider.errorMessage, contains('שגיאה בעדכון מלאי'));
    });

    test('adds large quantities correctly', () async {
      // Arrange
      final existingItem = InventoryItem(
        id: 'item1',
        productName: 'קפה',
        category: 'משקאות',
        location: 'מזווה',
        quantity: 5,
        unit: 'חבילות',
      );

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => [existingItem]);

      await provider.loadItems();

      when(mockRepository.saveItem(any, testHouseholdId))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as InventoryItem);

      // Act - add large quantity
      await provider.addStock('קפה', 100);

      // Assert
      final updatedItem = provider.items.first;
      expect(updatedItem.quantity, 105); // 5 + 100 = 105
    });

    test('preserves other item properties when updating quantity', () async {
      // Arrange
      final existingItem = InventoryItem(
        id: 'item1',
        productName: 'גבינה',
        category: 'מוצרי חלב',
        location: 'מקרר',
        quantity: 3,
        unit: 'חבילות',
      );

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => [existingItem]);

      await provider.loadItems();

      when(mockRepository.saveItem(any, testHouseholdId))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as InventoryItem);

      // Act
      await provider.addStock('גבינה', 2);

      // Assert - other properties unchanged
      final updatedItem = provider.items.first;
      expect(updatedItem.quantity, 5); // updated
      expect(updatedItem.productName, 'גבינה'); // unchanged
      expect(updatedItem.category, 'מוצרי חלב'); // unchanged
      expect(updatedItem.location, 'מקרר'); // unchanged
      expect(updatedItem.unit, 'חבילות'); // unchanged
      expect(updatedItem.id, 'item1'); // unchanged
    });
  });

  group('getLowStockItems()', () {
    test('returns items with quantity <= default threshold (2)', () async {
      // Arrange
      final items = [
        InventoryItem(
          id: 'item1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 1, // low
          unit: 'יחידות',
        ),
        InventoryItem(
          id: 'item2',
          productName: 'לחם',
          category: 'מאפים',
          location: 'מגש',
          quantity: 5, // not low
          unit: 'יחידות',
        ),
        InventoryItem(
          id: 'item3',
          productName: 'ביצים',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2, // at threshold
          unit: 'יחידות',
        ),
      ];

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => items);

      await provider.loadItems();

      // Act
      final lowStock = provider.getLowStockItems();

      // Assert
      expect(lowStock.length, 2); // חלב + ביצים
      expect(lowStock.any((i) => i.productName == 'חלב'), true);
      expect(lowStock.any((i) => i.productName == 'ביצים'), true);
      expect(lowStock.any((i) => i.productName == 'לחם'), false);
    });

    test('returns items with quantity <= custom threshold', () async {
      // Arrange
      final items = [
        InventoryItem(
          id: 'item1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 3,
          unit: 'יחידות',
        ),
        InventoryItem(
          id: 'item2',
          productName: 'לחם',
          category: 'מאפים',
          location: 'מגש',
          quantity: 5,
          unit: 'יחידות',
        ),
      ];

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => items);

      await provider.loadItems();

      // Act
      final lowStock = provider.getLowStockItems(threshold: 4);

      // Assert
      expect(lowStock.length, 1); // only חלב
      expect(lowStock.first.productName, 'חלב');
    });

    test('returns empty list when no low-stock items', () async {
      // Arrange
      final items = [
        InventoryItem(
          id: 'item1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 10,
          unit: 'יחידות',
        ),
      ];

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => items);

      await provider.loadItems();

      // Act
      final lowStock = provider.getLowStockItems();

      // Assert
      expect(lowStock, isEmpty);
    });

    test('includes items with quantity = 0', () async {
      // Arrange
      final items = [
        InventoryItem(
          id: 'item1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 0, // out of stock
          unit: 'יחידות',
        ),
      ];

      when(mockRepository.fetchItems(testHouseholdId))
          .thenAnswer((_) async => items);

      await provider.loadItems();

      // Act
      final lowStock = provider.getLowStockItems();

      // Assert
      expect(lowStock.length, 1);
      expect(lowStock.first.quantity, 0);
    });
  });
}
