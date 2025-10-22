// test/providers/shopping_lists_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/repositories/shopping_lists_repository.dart';
import 'package:memozap/repositories/receipt_repository.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/unified_list_item.dart';
import 'package:memozap/models/enums/item_type.dart';
import 'package:memozap/models/user_entity.dart';
import 'package:memozap/models/active_shopper.dart';

import 'shopping_lists_provider_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  ShoppingListsRepository,
  ReceiptRepository,
  UserContext,
])
void main() {
  late ShoppingListsProvider provider;
  late MockShoppingListsRepository mockRepository;
  late MockReceiptRepository mockReceiptRepository;
  late MockUserContext mockUserContext;
  
  const testUserId = 'test-user-id';
  const testHouseholdId = 'test-household-id';
  const testListId = 'test-list-id';
  
  final uuid = const Uuid();
  
  setUp(() {
    mockRepository = MockShoppingListsRepository();
    mockReceiptRepository = MockReceiptRepository();
    mockUserContext = MockUserContext();
    
    // Setup UserContext mocks
    final testUser = UserEntity(
      id: testUserId,
      name: 'Test User',
      email: 'test@example.com',
      householdId: testHouseholdId,
      joinedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferredStores: const [],
      favoriteProducts: const [],
      weeklyBudget: 0.0,
      isAdmin: true,
    );
    
    when(mockUserContext.user).thenReturn(testUser);
    when(mockUserContext.isLoggedIn).thenReturn(true);
    
    provider = ShoppingListsProvider(
      repository: mockRepository,
      receiptRepository: mockReceiptRepository,
    );
    provider.updateUserContext(mockUserContext);
  });
  
  group('addUnifiedItem', () {
    late ShoppingList testList;
    
    setUp(() {
      testList = ShoppingList.newList(
        id: testListId,
        name: 'רשימת קניות',
        createdBy: testUserId,
        type: ShoppingList.typeSuper,
        items: [],
      );
      
      // Setup initial fetch
      when(mockRepository.fetchLists(testHouseholdId))
          .thenAnswer((_) async => [testList]);
    });
    
    group('Success Cases', () {
      test('adds product item successfully', () async {
        // Arrange
        await provider.loadLists();
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
          category: 'חלב וביצים',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async => testList);
        
        // Act
        await provider.addUnifiedItem(testListId, product);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.length, 1);
        expect(list.items.first.name, 'חלב');
        expect(list.items.first.type, ItemType.product);
        expect(list.items.first.quantity, 2);
        expect(list.items.first.unitPrice, 6.90);
        
        verify(mockRepository.saveList(any, testHouseholdId)).called(1);
      });
      
      test('adds task item successfully', () async {
        // Arrange
        await provider.loadLists();
        
        final dueDate = DateTime.now().add(Duration(days: 3));
        final task = UnifiedListItem.task(
          id: uuid.v4(),
          name: 'להזמין עוגה',
          dueDate: dueDate,
          priority: 'high',
          assignedTo: testUserId,
          category: 'הכנות',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, task);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.length, 1);
        expect(list.items.first.name, 'להזמין עוגה');
        expect(list.items.first.type, ItemType.task);
        expect(list.items.first.priority, 'high');
        expect(list.items.first.dueDate, dueDate);
        
        verify(mockRepository.saveList(any, testHouseholdId)).called(1);
      });
      
      test('adds multiple items to same list', () async {
        // Arrange
        await provider.loadLists();
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        final task = UnifiedListItem.task(
          id: uuid.v4(),
          name: 'להזמין עוגה',
          dueDate: DateTime.now().add(Duration(days: 3)),
          priority: 'high',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, product);
        await provider.addUnifiedItem(testListId, task);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.length, 2);
        expect(list.items[0].type, ItemType.product);
        expect(list.items[1].type, ItemType.task);
        
        verify(mockRepository.saveList(any, testHouseholdId)).called(2);
      });
      
      test('notifies listeners after adding item', () async {
        // Arrange
        await provider.loadLists();
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        var notificationCount = 0;
        provider.addListener(() {
          notificationCount++;
        });
        
        // Act
        await provider.addUnifiedItem(testListId, product);
        
        // Assert
        expect(notificationCount, greaterThan(0));
      });
    });
    
    group('Error Cases', () {
      test('throws exception when list not found', () async {
        // Arrange
        await provider.loadLists();
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        // Act & Assert
        expect(
          () => provider.addUnifiedItem('non-existent-id', product),
          throwsException,
        );
        
        verifyNever(mockRepository.saveList(any, testHouseholdId));
      });
      
      test('handles repository save error gracefully', () async {
        // Arrange
        await provider.loadLists();
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenThrow(Exception('Network error'));
        
        // Act & Assert
        expect(
          () => provider.addUnifiedItem(testListId, product),
          throwsException,
        );
        
        // Verify state wasn't corrupted
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.length, 0); // Item wasn't added due to error
      });
      
      test('handles empty item name', () async {
        // Arrange
        await provider.loadLists();
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: '', // Empty name!
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, product);
        
        // Assert - should still work, but list might validate later
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.length, 1);
        expect(list.items.first.name, '');
      });
    });
    
    group('Data Integrity', () {
      test('preserves other items when adding new item', () async {
        // Arrange
        final existingItem = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'לחם',
          quantity: 1,
          unitPrice: 5.50,
          unit: 'יח\'',
        );
        
        testList = testList.copyWith(items: [existingItem]);
        
        when(mockRepository.fetchLists(testHouseholdId))
            .thenAnswer((_) async => [testList]);
        
        await provider.loadLists();
        
        final newItem = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, newItem);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.length, 2);
        expect(list.items[0].name, 'לחם');
        expect(list.items[1].name, 'חלב');
      });
      
      test('updates list updatedDate when adding item', () async {
        // Arrange
        await provider.loadLists();
        
        final originalDate = testList.updatedDate;
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Wait a tiny bit to ensure timestamp changes
        await Future.delayed(Duration(milliseconds: 10));
        
        // Act
        await provider.addUnifiedItem(testListId, product);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(
          list!.updatedDate.isAfter(originalDate),
          isTrue,
          reason: 'updatedDate should be refreshed',
        );
      });
      
      test('calculates totalAmount correctly after adding product', () async {
        // Arrange
        await provider.loadLists();
        
        final product1 = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        final product2 = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'לחם',
          quantity: 1,
          unitPrice: 5.50,
          unit: 'יח\'',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, product1);
        await provider.addUnifiedItem(testListId, product2);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        
        // 2 * 6.90 + 1 * 5.50 = 13.80 + 5.50 = 19.30
        final expectedTotal = (2 * 6.90) + (1 * 5.50);
        expect(list!.totalAmount, closeTo(expectedTotal, 0.01));
      });
      
      test('task items do not affect totalAmount', () async {
        // Arrange
        await provider.loadLists();
        
        final task = UnifiedListItem.task(
          id: uuid.v4(),
          name: 'להזמין עוגה',
          dueDate: DateTime.now().add(Duration(days: 3)),
          priority: 'high',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, task);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.totalAmount, 0); // Tasks don't affect total
      });
    });
    
    group('Edge Cases', () {
      test('handles product with zero quantity', () async {
        // Arrange
        await provider.loadLists();
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 0, // Zero!
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, product);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.first.quantity, 0);
        expect(list.items.first.totalPrice, 0);
      });
      
      test('handles product with zero price', () async {
        // Arrange
        await provider.loadLists();
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'מדגם חינם',
          quantity: 1,
          unitPrice: 0, // Free!
          unit: 'יח\'',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, product);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.first.unitPrice, 0);
        expect(list.items.first.totalPrice, 0);
      });
      
      test('handles task with past dueDate', () async {
        // Arrange
        await provider.loadLists();
        
        final pastDate = DateTime.now().subtract(Duration(days: 5));
        final task = UnifiedListItem.task(
          id: uuid.v4(),
          name: 'משימה ישנה',
          dueDate: pastDate,
          priority: 'high',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, task);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.first.dueDate, pastDate);
        expect(list.items.first.dueDate!.isBefore(DateTime.now()), isTrue);
      });
      
      test('handles task with no dueDate', () async {
        // Arrange
        await provider.loadLists();
        
        final task = UnifiedListItem.task(
          id: uuid.v4(),
          name: 'משימה ללא תאריך',
          dueDate: null, // No due date
          priority: 'low',
        );
        
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        // Act
        await provider.addUnifiedItem(testListId, task);
        
        // Assert
        final list = provider.getById(testListId);
        expect(list, isNotNull);
        expect(list!.items.first.dueDate, isNull);
      });
    });
    
    group('Integration with Other Methods', () {
      test('addUnifiedItem works after updateList', () async {
        // Arrange
        when(mockRepository.fetchLists(testHouseholdId))
            .thenAnswer((_) async => [testList]);
        
        await provider.loadLists();
        
        // First update the list name
        final updatedList = testList.copyWith(name: 'רשימה מעודכנת');
        when(mockRepository.saveList(any, testHouseholdId))
            .thenAnswer((_) async {});
        
        when(mockRepository.fetchLists(testHouseholdId))
            .thenAnswer((_) async => [updatedList]);
        
        await provider.updateList(updatedList);
        
        // Then add an item
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        // Act
        await provider.addUnifiedItem(testListId, product);
        
        // Assert
        verify(mockRepository.saveList(any, testHouseholdId))
            .called(2); // once for update, once for add
      });
      
      test('addUnifiedItem after deleteList throws error', () async {
        // Arrange
        when(mockRepository.fetchLists(testHouseholdId))
            .thenAnswer((_) async => [testList]);
        
        await provider.loadLists();
        
        // Delete the list
        when(mockRepository.deleteList(testListId, testHouseholdId))
            .thenAnswer((_) async {});
        
        when(mockRepository.fetchLists(testHouseholdId))
            .thenAnswer((_) async => []); // List is gone
        
        await provider.deleteList(testListId);
        
        final product = UnifiedListItem.product(
          id: uuid.v4(),
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          unit: 'יח\'',
        );
        
        // Act & Assert
        expect(
          () => provider.addUnifiedItem(testListId, product),
          throwsException,
        );
      });
    });
  });
}
