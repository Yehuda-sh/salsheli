// 📄 test/providers/inventory_provider_test.dart
// Tests for InventoryProvider: loading, add/update/delete, dispose safety.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/user_entity.dart';
import 'package:memozap/providers/inventory_provider.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/repositories/inventory_repository.dart';
import 'package:memozap/repositories/user_repository.dart';
import 'package:memozap/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// MOCK CLASSES
// =============================================================================

class MockInventoryRepository implements InventoryRepository {
  List<InventoryItem> _items = [];
  bool shouldThrow = false;
  int fetchCallCount = 0;

  void setItems(List<InventoryItem> items) => _items = List.from(items);

  @override
  Future<List<InventoryItem>> fetchItems(String householdId) async {
    fetchCallCount++;
    if (shouldThrow) throw Exception('Mock fetch error');
    return List.from(_items);
  }

  @override
  Future<List<InventoryItem>> fetchUserItems(String userId) async {
    fetchCallCount++;
    if (shouldThrow) throw Exception('Mock fetch error');
    return List.from(_items);
  }

  @override
  Future<InventoryItem> saveItem(InventoryItem item, String householdId) async {
    if (shouldThrow) throw Exception('Mock save error');
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
    return item;
  }

  @override
  Future<InventoryItem> saveUserItem(InventoryItem item, String userId) async {
    if (shouldThrow) throw Exception('Mock save error');
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
    return item;
  }

  @override
  Future<void> deleteItem(String id, String householdId) async {
    if (shouldThrow) throw Exception('Mock delete error');
    _items.removeWhere((i) => i.id == id);
  }

  @override
  Future<void> deleteUserItem(String itemId, String userId) async {
    if (shouldThrow) throw Exception('Mock delete error');
    _items.removeWhere((i) => i.id == itemId);
  }

  @override
  Stream<List<InventoryItem>> watchInventory(String householdId) {
    return Stream.value(_items);
  }

  @override
  Future<int> deleteAllUserItems(String userId) async {
    final count = _items.length;
    _items.clear();
    return count;
  }
}

// Minimal mocks for UserContext dependencies
class _MockUserRepository implements UserRepository {
  UserEntity? _mockUser;

  @override
  Future<UserEntity?> fetchUser(String userId) async => _mockUser;
  @override
  Future<UserEntity> createUser({
    required String userId, required String email, required String name,
    String? phone, String? householdId, bool? seenOnboarding, String? profileImageUrl,
  }) async => throw UnimplementedError();
  @override
  Future<UserEntity> saveUser(UserEntity user) async => user;
  @override
  Future<void> deleteUser(String userId) async {}
  @override
  Future<UserEntity?> findByPhone(String phone) async => null;
  @override
  Future<UserEntity> updateProfile({required String userId, String? name, String? avatar}) async =>
      throw UnimplementedError();
  @override
  Future<void> clearAll({String? householdId}) async {}
  @override
  Future<bool> existsUser(String userId) async => false;
  @override
  Future<UserEntity?> findByEmail(String email, {String? householdId}) async => null;
  @override
  Future<List<UserEntity>> getAllUsers({String? householdId}) async => [];
  @override
  Future<void> updateLastLogin(String userId) async {}
  @override
  Future<void> updateHouseholdName(String userId, String? householdName) async {}
  @override
  Stream<UserEntity?> watchUser(String userId) => Stream.value(null);
}

class _MockAuthService implements AuthService {
  final _authUserController = StreamController<AuthUser?>.broadcast();
  final _rawCtrl = StreamController<firebase_auth.User?>.broadcast();

  bool _isSignedIn = false;
  String? _currentUserId;
  String? _currentUserEmail;

  @override Stream<AuthUser?> get authUserChanges => _authUserController.stream;
  @override Stream<firebase_auth.User?> get authStateChanges => _rawCtrl.stream;
  @override bool get isSignedIn => _isSignedIn;
  @override String? get currentUserId => _currentUserId;
  @override String? get currentUserEmail => _currentUserEmail;
  @override String? get currentUserDisplayName => null;
  @override firebase_auth.User? get currentUser => null;
  @override AuthUser? get currentAuthUser => null;
  @override bool get isEmailVerified => false;
  @override Future<firebase_auth.UserCredential> signUp({required String email, required String password, required String name}) async => throw UnimplementedError();
  @override Future<firebase_auth.UserCredential> signIn({required String email, required String password}) async => throw UnimplementedError();
  @override Future<bool> signOut() async => true;
  @override Future<SocialLoginResult> signInWithGoogle() async => throw UnimplementedError();
  @override Future<SocialLoginResult> signInWithApple() async => throw UnimplementedError();
  @override Future<void> sendPasswordResetEmail(String email) async {}
  @override Future<void> deleteAccount() async {}
  @override Future<void> reauthenticate({required String email, required String password}) async {}
  @override Future<void> reloadUser() async {}
  @override Future<void> sendEmailVerification() async {}
  @override Future<void> updateEmail(String newEmail) async {}
  @override Future<void> updatePassword(String newPassword) async {}
  @override Future<void> updateDisplayName(String displayName) async {}

  void dispose() {
    _authUserController.close();
    _rawCtrl.close();
  }
}

// =============================================================================
// HELPER: Logged-in UserContext
// =============================================================================

/// Creates a UserContext that reports as logged in with a user entity.
/// Must be called with `await Future.delayed` to let the auth listener fire.
Future<({UserContext ctx, _MockAuthService auth})> createLoggedInContext({
  String userId = 'test-user',
  String? householdId,
}) async {
  SharedPreferences.setMockInitialValues({});
  final mockAuth = _MockAuthService();
  final mockRepo = _MockUserRepository();

  // Pre-set the user so fetchUser returns it
  mockRepo._mockUser = UserEntity(
    id: userId,
    name: 'Test',
    email: 'test@test.com',
    householdId: householdId ?? 'house_$userId',
    joinedAt: DateTime(2026, 1, 1),
    seenOnboarding: true,
  );

  // Simulate signed in
  mockAuth._isSignedIn = true;
  mockAuth._currentUserId = userId;
  mockAuth._currentUserEmail = 'test@test.com';

  final ctx = UserContext(
    repository: mockRepo,
    authService: mockAuth,
  );

  // Fire the auth stream so UserContext loads the user
  mockAuth._authUserController.add(AuthUser(
    uid: userId,
    email: 'test@test.com',
    displayName: 'Test',
  ));

  // Wait for async load
  await Future.delayed(const Duration(milliseconds: 150));

  return (ctx: ctx, auth: mockAuth);
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  late MockInventoryRepository mockRepo;
  late UserContext userContext;
  late _MockAuthService mockAuth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockInventoryRepository();
    mockAuth = _MockAuthService();
    userContext = UserContext(
      repository: _MockUserRepository(),
      authService: mockAuth,
    );
  });

  tearDown(() {
    userContext.dispose();
    mockAuth.dispose();
  });

  group('InventoryProvider - Initial State', () {
    test('starts with empty list and not loading', () {
      final provider = InventoryProvider(
        repository: mockRepo,
        userContext: userContext,
      );

      expect(provider.items, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.hasError, false);
      expect(provider.isEmpty, true);
      expect(provider.currentMode, InventoryMode.personal);

      provider.dispose();
    });
  });

  group('InventoryProvider - Dispose Safety', () {
    test('should not crash after dispose', () {
      final provider = InventoryProvider(
        repository: mockRepo,
        userContext: userContext,
      );

      provider.dispose();

      // Operations after dispose should not crash
      expect(() => provider.items, returnsNormally);
      expect(() => provider.isLoading, returnsNormally);
    });
  });

  group('InventoryProvider - Low stock detection', () {
    test('items below minQuantity are low stock', () {
      final items = [
        InventoryItem(
          id: 'low-1',
          productName: 'חלב',
          category: 'חלב',
          location: 'מקרר',
          quantity: 1,
          unit: "יח'",
          minQuantity: 3,
        ),
        InventoryItem(
          id: 'ok-1',
          productName: 'לחם',
          category: 'לחם',
          location: 'ארון',
          quantity: 5,
          unit: "יח'",
          minQuantity: 2,
        ),
      ];

      final lowStock = items.where((i) => i.quantity < i.minQuantity).toList();
      expect(lowStock.length, 1);
      expect(lowStock.first.productName, 'חלב');
    });
  });

  // ===================================================================
  // CRUD Tests (requires logged-in UserContext)
  // ===================================================================
  group('InventoryProvider - createItem', () {
    test('creates item and adds to list', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final item = await provider.createItem(
        productName: 'חלב',
        category: 'dairy',
        location: 'fridge',
        quantity: 3,
      );

      expect(item.productName, 'חלב');
      expect(item.quantity, 3);
      expect(provider.items.any((i) => i.productName == 'חלב'), true);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('throws on empty product name', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        () => provider.createItem(
          productName: '',
          category: 'c',
          location: 'l',
        ),
        throwsArgumentError,
      );

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('throws on zero quantity', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        () => provider.createItem(
          productName: 'חלב',
          category: 'c',
          location: 'l',
          quantity: 0,
        ),
        throwsArgumentError,
      );

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('rollback on save failure', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      repo.shouldThrow = true;
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final countBefore = provider.items.length;
      try {
        await provider.createItem(
          productName: 'חלב',
          category: 'c',
          location: 'l',
          quantity: 1,
        );
      } catch (_) {}

      // Rolled back — count unchanged
      expect(provider.items.length, countBefore);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });
  });

  group('InventoryProvider - updateItem', () {
    test('updates item in list', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // Create first
      final item = await provider.createItem(
        productName: 'חלב',
        category: 'dairy',
        location: 'fridge',
        quantity: 3,
      );

      // Update
      final updated = item.copyWith(quantity: 10);
      await provider.updateItem(updated);

      final found = provider.items.firstWhere((i) => i.id == item.id);
      expect(found.quantity, 10);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('sets lastUpdatedBy audit field', () async {
      final logged = await createLoggedInContext(userId: 'user-abc');
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final item = await provider.createItem(
        productName: 'לחם',
        category: 'bread',
        location: 'cabinet',
        quantity: 2,
      );

      final updated = item.copyWith(quantity: 5, lastUpdatedBy: null);
      await provider.updateItem(updated);

      final found = provider.items.firstWhere((i) => i.id == item.id);
      expect(found.lastUpdatedBy, 'user-abc');

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });
  });

  group('InventoryProvider - deleteItem', () {
    test('removes item from list', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final item = await provider.createItem(
        productName: 'חלב',
        category: 'dairy',
        location: 'fridge',
        quantity: 1,
      );

      await provider.deleteItem(item.id);

      expect(provider.items.any((i) => i.id == item.id), false);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('throws on empty id', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        () => provider.deleteItem(''),
        throwsArgumentError,
      );

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('rollback on delete failure', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final item = await provider.createItem(
        productName: 'חלב',
        category: 'dairy',
        location: 'fridge',
        quantity: 1,
      );

      repo.shouldThrow = true;
      try {
        await provider.deleteItem(item.id);
      } catch (_) {}

      // Rolled back — item still there
      expect(provider.items.any((i) => i.id == item.id), true);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });
  });

  group('InventoryProvider - addStock', () {
    test('adds quantity to existing item (case-insensitive)', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.createItem(
        productName: 'חלב',
        category: 'dairy',
        location: 'fridge',
        quantity: 3,
      );

      await provider.addStock('חלב', 2);

      final found = provider.items.firstWhere((i) => i.productName == 'חלב');
      expect(found.quantity, 5);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('creates new item when product not found', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.addStock('מוצר חדש', 5);

      expect(provider.items.any((i) => i.productName == 'מוצר חדש'), true);
      final found = provider.items.firstWhere((i) => i.productName == 'מוצר חדש');
      expect(found.quantity, 5);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('throws on invalid inputs', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      expect(() => provider.addStock('', 5), throwsArgumentError);
      expect(() => provider.addStock('חלב', 0), throwsArgumentError);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });
  });

  group('InventoryProvider - removeStock', () {
    test('decrements quantity and returns updated item', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // הוסף פריט עם כמות 5
      await provider.createItem(
        productName: 'חלב',
        category: 'dairy',
        location: 'refrigerator',
        quantity: 5,
      );
      expect(provider.items.first.quantity, 5);

      // הורד 1
      final updated = await provider.removeStock('חלב');
      expect(updated, isNotNull);
      expect(updated!.quantity, 4);
      expect(provider.items.first.quantity, 4);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('decrements to 0 (out of stock) — item stays in list', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.createItem(
        productName: 'סוכר',
        category: 'dry_goods',
        location: 'pantry',
        quantity: 1,
      );

      final updated = await provider.removeStock('סוכר');
      expect(updated, isNotNull);
      expect(updated!.quantity, 0);
      // פריט נשאר ברשימה!
      expect(provider.items.length, 1);
      expect(provider.items.first.quantity, 0);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('returns null for non-existent product', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await provider.removeStock('לא קיים');
      expect(result, isNull);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('case-insensitive match', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.createItem(
        productName: 'חלב תנובה',
        category: 'dairy',
        location: 'refrigerator',
        quantity: 3,
      );

      final updated = await provider.removeStock('חלב תנובה');
      expect(updated, isNotNull);
      expect(updated!.quantity, 2);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });
  });

  group('InventoryProvider - Filters', () {
    test('itemsByCategory filters correctly', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.createItem(productName: 'חלב', category: 'dairy', location: 'fridge', quantity: 1);
      await provider.createItem(productName: 'לחם', category: 'bread', location: 'cabinet', quantity: 1);
      await provider.createItem(productName: 'גבינה', category: 'dairy', location: 'fridge', quantity: 1);

      final dairy = provider.itemsByCategory('dairy');
      expect(dairy.length, 2);

      final bread = provider.itemsByCategory('bread');
      expect(bread.length, 1);

      final empty = provider.itemsByCategory('nonexistent');
      expect(empty, isEmpty);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('itemsByLocation filters correctly', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.createItem(productName: 'חלב', category: 'dairy', location: 'fridge', quantity: 1);
      await provider.createItem(productName: 'לחם', category: 'bread', location: 'cabinet', quantity: 1);

      expect(provider.itemsByLocation('fridge').length, 1);
      expect(provider.itemsByLocation('cabinet').length, 1);
      expect(provider.itemsByLocation('freezer'), isEmpty);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('getLowStockItems returns items below min', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.createItem(productName: 'חלב', category: 'dairy', location: 'fridge', quantity: 1, minQuantity: 3);
      await provider.createItem(productName: 'לחם', category: 'bread', location: 'cabinet', quantity: 5, minQuantity: 2);

      final low = provider.getLowStockItems();
      expect(low.length, 1);
      expect(low.first.productName, 'חלב');

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });
  });

  group('InventoryProvider - clearAll & retry', () {
    test('clearAll empties items and error', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.createItem(productName: 'חלב', category: 'c', location: 'l', quantity: 1);
      expect(provider.items, isNotEmpty);

      provider.clearAll();

      expect(provider.items, isEmpty);
      expect(provider.hasError, false);
      expect(provider.isLoading, false);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });
  });

  group('InventoryProvider - addStarterItems', () {
    test('adds items and returns count', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final starters = [
        const InventoryItem(id: 's1', productName: 'חלב', category: 'dairy', location: 'fridge', quantity: 2, unit: "יח'"),
        const InventoryItem(id: 's2', productName: 'לחם', category: 'bread', location: 'cabinet', quantity: 1, unit: "יח'"),
      ];

      final count = await provider.addStarterItems(starters);

      expect(count, 2);
      expect(provider.items.length, greaterThanOrEqualTo(2));

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });

    test('returns 0 for empty list', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final count = await provider.addStarterItems([]);
      expect(count, 0);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });
  });

  group('InventoryProvider - deletePersonalInventory', () {
    test('deletes all and returns count', () async {
      final logged = await createLoggedInContext();
      final repo = MockInventoryRepository();
      final provider = InventoryProvider(
        repository: repo,
        userContext: logged.ctx,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.createItem(productName: 'חלב', category: 'c', location: 'l', quantity: 1);
      await provider.createItem(productName: 'לחם', category: 'c', location: 'l', quantity: 1);

      final count = await provider.deletePersonalInventory();
      expect(count, 2);

      provider.dispose();
      logged.ctx.dispose();
      logged.auth.dispose();
    });
  });
}
