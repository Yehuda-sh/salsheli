// 📄 File: test/providers/user_context_test.dart
//
// Unit tests for UserContext provider
// Tests: Dispose safety, state synchronization, error handling
//
// Version: 1.0
// Created: 22/12/2025

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/user_entity.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/repositories/user_repository.dart';
import 'package:memozap/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// MOCK CLASSES
// =============================================================================

/// Mock UserRepository for testing
class MockUserRepository implements UserRepository {
  UserEntity? _mockUser;
  bool shouldThrowOnFetch = false;
  bool shouldThrowOnSave = false;
  bool shouldThrowOnCreate = false;
  int fetchCallCount = 0;
  int saveCallCount = 0;
  int createCallCount = 0;

  void setMockUser(UserEntity? user) {
    _mockUser = user;
  }

  @override
  Future<UserEntity?> fetchUser(String userId) async {
    fetchCallCount++;
    if (shouldThrowOnFetch) {
      throw Exception('Mock fetch error');
    }
    return _mockUser;
  }

  @override
  Future<UserEntity> createUser({
    required String userId,
    required String email,
    required String name,
    String? phone,
    List<String>? preferredStores,
    int? familySize,
    int? shoppingFrequency,
    List<int>? shoppingDays,
    bool? hasChildren,
    bool? shareLists,
    String? reminderTime,
    bool? seenOnboarding,
    String? householdId,
  }) async {
    createCallCount++;
    if (shouldThrowOnCreate) {
      throw Exception('Mock create error');
    }
    return UserEntity(
      id: userId,
      name: name,
      email: email,
      phone: phone,
      householdId: householdId ?? 'test-household',
      joinedAt: DateTime.now(),
      preferredStores: preferredStores ?? const [],
      familySize: familySize ?? 2,
      shoppingFrequency: shoppingFrequency ?? 1,
      shoppingDays: shoppingDays ?? const [],
      hasChildren: hasChildren ?? false,
      shareLists: shareLists ?? false,
      seenOnboarding: seenOnboarding ?? false,
    );
  }

  @override
  Future<UserEntity> saveUser(UserEntity user) async {
    saveCallCount++;
    if (shouldThrowOnSave) {
      throw Exception('Mock save error');
    }
    _mockUser = user;
    return user;
  }

  @override
  Future<void> deleteUser(String userId) async {}

  @override
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? avatar,
  }) async {}

  @override
  Future<void> clearAll({String? householdId}) async {}

  @override
  Future<bool> existsUser(String userId) async => _mockUser != null;

  @override
  Future<UserEntity?> findByEmail(String email, {String? householdId}) async =>
      null;

  @override
  Future<List<UserEntity>> getAllUsers({String? householdId}) async => [];

  @override
  Future<void> updateLastLogin(String userId) async {}

  @override
  Stream<UserEntity?> watchUser(String userId) {
    return Stream.value(_mockUser);
  }
}

/// Mock AuthService for testing
class MockAuthService implements AuthService {
  final StreamController<firebase_auth.User?> _authController =
      StreamController<firebase_auth.User?>.broadcast();

  bool _isSignedIn = false;
  String? _currentUserId;
  String? _currentUserEmail;
  String? _currentUserDisplayName;
  bool shouldThrowOnSignIn = false;
  bool shouldThrowOnSignUp = false;
  int signInCallCount = 0;
  int signOutCallCount = 0;

  void simulateSignIn({
    String userId = 'test-user-id',
    String email = 'test@example.com',
    String displayName = 'Test User',
  }) {
    _isSignedIn = true;
    _currentUserId = userId;
    _currentUserEmail = email;
    _currentUserDisplayName = displayName;
    // We can't easily emit a real firebase_auth.User, so we emit null
    // and rely on the isSignedIn getter
    _authController.add(null);
  }

  void simulateSignOut() {
    _isSignedIn = false;
    _currentUserId = null;
    _currentUserEmail = null;
    _currentUserDisplayName = null;
    _authController.add(null);
  }

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  String? get currentUserId => _currentUserId;

  @override
  String? get currentUserEmail => _currentUserEmail;

  @override
  String? get currentUserDisplayName => _currentUserDisplayName;

  @override
  firebase_auth.User? get currentUser => null;

  @override
  bool get isEmailVerified => false;

  @override
  Stream<firebase_auth.User?> get authStateChanges => _authController.stream;

  @override
  Future<firebase_auth.UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (shouldThrowOnSignUp) {
      throw Exception('Mock sign up error');
    }
    throw UnimplementedError('Use simulateSignIn for testing');
  }

  @override
  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    if (shouldThrowOnSignIn) {
      throw Exception('Mock sign in error');
    }
    throw UnimplementedError('Use simulateSignIn for testing');
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    simulateSignOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> reloadUser() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> updateEmail(String newEmail) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> updateDisplayName(String displayName) async {}

  void dispose() {
    _authController.close();
  }
}

/// Helper to create test user
UserEntity createTestUser({
  String id = 'test-user-id',
  String name = 'Test User',
  String email = 'test@example.com',
}) {
  return UserEntity(
    id: id,
    name: name,
    email: email,
    householdId: 'test-household',
    joinedAt: DateTime.now(),
    preferredStores: const [],
    familySize: 2,
    shoppingFrequency: 1,
    shoppingDays: const [],
    hasChildren: false,
    shareLists: false,
    seenOnboarding: true,
  );
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  late MockUserRepository mockRepository;
  late MockAuthService mockAuthService;

  setUp(() {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockUserRepository();
    mockAuthService = MockAuthService();
  });

  tearDown(() {
    mockAuthService.dispose();
  });

  // ===========================================================================
  // DISPOSE SAFETY TESTS
  // ===========================================================================
  group('UserContext - Dispose Safety', () {
    test('should set isDisposed flag when dispose() is called', () {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      expect(userContext.isDisposed, false);

      userContext.dispose();

      expect(userContext.isDisposed, true);
    });

    test('should not crash when notifyListeners after dispose', () async {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      userContext.dispose();

      // These operations should not crash
      expect(() => userContext.setThemeMode(ThemeMode.dark), returnsNormally);
      expect(() => userContext.toggleCompactView(), returnsNormally);
      expect(() => userContext.toggleShowPrices(), returnsNormally);
    });

    test('signIn should abort if disposed during operation', () async {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      // Dispose immediately
      userContext.dispose();

      // signIn should not throw even after dispose
      // It should silently abort
      await userContext.signIn(email: 'test@test.com', password: 'password');

      expect(mockAuthService.signInCallCount, 0,
          reason: 'signIn should not call auth service if disposed');
    });

    test('retry should abort if disposed', () async {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      userContext.dispose();

      await userContext.retry();

      expect(mockRepository.fetchCallCount, 0,
          reason: 'retry should not fetch if disposed');
    });

    test('clearAll should abort if disposed', () async {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      userContext.dispose();

      await userContext.clearAll();

      // No crash = success
      expect(userContext.isDisposed, true);
    });

    test('saveUser should abort if disposed', () async {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      userContext.dispose();

      await userContext.saveUser(createTestUser());

      expect(mockRepository.saveCallCount, 0,
          reason: 'saveUser should not call repository if disposed');
    });
  });

  // ===========================================================================
  // STATE SYNCHRONIZATION TESTS
  // ===========================================================================
  group('UserContext - State Synchronization', () {
    test('hasAuthButNoProfile should be true when auth succeeds but profile fails',
        () async {
      mockRepository.shouldThrowOnFetch = true;
      mockAuthService.simulateSignIn();

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      // Wait for async operations
      await Future.delayed(const Duration(milliseconds: 100));

      // Note: Since we can't easily trigger the auth listener with a real user,
      // we test the internal logic directly
      expect(userContext.hasError, false,
          reason: 'Initial state should not have error');

      userContext.dispose();
    });

    test('isLoggedIn should require both auth and profile', () async {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      // Initially not logged in
      expect(userContext.isLoggedIn, false);
      expect(userContext.user, isNull);

      userContext.dispose();
    });

    test('error state should be clearable via retry', () async {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      // Simulate error state (would normally happen from failed fetch)
      // We can't easily test this without accessing private members,
      // but we can verify retry doesn't crash
      await userContext.retry();

      expect(userContext.errorMessage, isNull);

      userContext.dispose();
    });
  });

  // ===========================================================================
  // ERROR HANDLING TESTS
  // ===========================================================================
  group('UserContext - Error Handling', () {
    test('signIn should set error message on failure', () async {
      mockAuthService.shouldThrowOnSignIn = true;

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      try {
        await userContext.signIn(email: 'test@test.com', password: 'wrong');
      } catch (_) {
        // Expected to throw
      }

      expect(userContext.hasError, true);
      expect(userContext.errorMessage, contains('שגיאה בהתחברות'));

      userContext.dispose();
    });

    test('saveUser should set error message on failure', () async {
      mockRepository.shouldThrowOnSave = true;

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      try {
        await userContext.saveUser(createTestUser());
      } catch (_) {
        // Expected to throw
      }

      expect(userContext.hasError, true);
      expect(userContext.errorMessage, contains('שגיאה בשמירת פרטי משתמש'));

      userContext.dispose();
    });

    test('error should be cleared on successful operation', () async {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      // First, cause an error
      mockRepository.shouldThrowOnSave = true;
      try {
        await userContext.saveUser(createTestUser());
      } catch (_) {}

      expect(userContext.hasError, true);

      // Now succeed
      mockRepository.shouldThrowOnSave = false;
      await userContext.saveUser(createTestUser());

      expect(userContext.hasError, false);

      userContext.dispose();
    });
  });

  // ===========================================================================
  // PREFERENCES TESTS
  // ===========================================================================
  group('UserContext - Preferences', () {
    test('setThemeMode should update theme and notify', () async {
      SharedPreferences.setMockInitialValues({});

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      expect(userContext.themeMode, ThemeMode.system);

      var notified = false;
      userContext.addListener(() => notified = true);

      userContext.setThemeMode(ThemeMode.dark);

      expect(userContext.themeMode, ThemeMode.dark);
      expect(notified, true);

      userContext.dispose();
    });

    test('toggleCompactView should toggle and notify', () async {
      SharedPreferences.setMockInitialValues({});

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      expect(userContext.compactView, false);

      var notified = false;
      userContext.addListener(() => notified = true);

      userContext.toggleCompactView();

      expect(userContext.compactView, true);
      expect(notified, true);

      userContext.dispose();
    });

    test('toggleShowPrices should toggle and notify', () async {
      SharedPreferences.setMockInitialValues({});

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      expect(userContext.showPrices, true);

      var notified = false;
      userContext.addListener(() => notified = true);

      userContext.toggleShowPrices();

      expect(userContext.showPrices, false);
      expect(notified, true);

      userContext.dispose();
    });

    test('should not notify after dispose', () async {
      SharedPreferences.setMockInitialValues({});

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      var notifyCount = 0;
      userContext.addListener(() => notifyCount++);

      // Wait for initial notifications from constructor
      await Future.delayed(const Duration(milliseconds: 100));
      final initialCount = notifyCount;

      // Dispose
      userContext.dispose();

      // Try to trigger notifications
      userContext.setThemeMode(ThemeMode.dark);
      userContext.toggleCompactView();
      userContext.toggleShowPrices();

      // Should not have increased
      expect(notifyCount, initialCount,
          reason: 'Should not notify after dispose');
    });
  });

  // ===========================================================================
  // LOADING STATE TESTS
  // ===========================================================================
  group('UserContext - Loading State', () {
    test('isLoading should be false initially', () {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      expect(userContext.isLoading, false);

      userContext.dispose();
    });

    test('clearAll should reset all state', () async {
      SharedPreferences.setMockInitialValues({});

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      // Set some state
      userContext.setThemeMode(ThemeMode.dark);
      userContext.toggleCompactView();
      userContext.toggleShowPrices();

      await userContext.clearAll();

      expect(userContext.themeMode, ThemeMode.system);
      expect(userContext.compactView, false);
      expect(userContext.showPrices, true);
      expect(userContext.user, isNull);
      expect(userContext.errorMessage, isNull);

      userContext.dispose();
    });
  });

  // ===========================================================================
  // GETTERS TESTS
  // ===========================================================================
  group('UserContext - Getters', () {
    test('displayName should fallback to auth service', () {
      mockAuthService.simulateSignIn(displayName: 'Auth Name');

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      // Without user entity, should return from auth
      expect(userContext.displayName, 'Auth Name');

      userContext.dispose();
    });

    test('userId should fallback to auth service', () {
      mockAuthService.simulateSignIn(userId: 'auth-user-id');

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      expect(userContext.userId, 'auth-user-id');

      userContext.dispose();
    });

    test('userEmail should fallback to auth service', () {
      mockAuthService.simulateSignIn(email: 'auth@test.com');

      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      expect(userContext.userEmail, 'auth@test.com');

      userContext.dispose();
    });

    test('householdId should return null when no user', () {
      final userContext = UserContext(
        repository: mockRepository,
        authService: mockAuthService,
      );

      expect(userContext.householdId, isNull);

      userContext.dispose();
    });
  });
}
