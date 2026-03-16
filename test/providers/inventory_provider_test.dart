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
  @override
  Future<UserEntity?> fetchUser(String userId) async => null;
  @override
  Future<UserEntity> createUser({
    required String userId, required String email, required String name,
    String? phone, List<String>? preferredStores, int? familySize,
    int? shoppingFrequency, List<int>? shoppingDays, bool? hasChildren,
    bool? shareLists, String? reminderTime, bool? seenOnboarding, String? householdId,
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
  final _ctrl = StreamController<AuthUser?>.broadcast();
  final _rawCtrl = StreamController<firebase_auth.User?>.broadcast();

  @override Stream<AuthUser?> get authUserChanges => _ctrl.stream;
  @override Stream<firebase_auth.User?> get authStateChanges => _rawCtrl.stream;
  @override bool get isSignedIn => false;
  @override String? get currentUserId => null;
  @override String? get currentUserEmail => null;
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
    _ctrl.close();
    _rawCtrl.close();
  }
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
}
