// 📄 test/providers/shopping_lists_provider_test.dart
// Tests for ShoppingListsProvider: CRUD, item management, collaborative shopping,
// limits, dispose safety.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/models/active_shopper.dart';
import 'package:memozap/models/activity_event.dart';
import 'package:memozap/models/enums/shopping_item_status.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/models/receipt.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/unified_list_item.dart';
import 'package:memozap/models/user_entity.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/repositories/receipt_repository.dart';
import 'package:memozap/repositories/shopping_lists_repository.dart';
import 'package:memozap/repositories/user_repository.dart';
import 'package:memozap/services/activity_log_service.dart';
import 'package:memozap/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// MOCK — ShoppingListsRepository
// =============================================================================

class MockShoppingListsRepository implements ShoppingListsRepository {
  List<ShoppingList> _lists = [];
  bool shouldThrow = false;
  int saveCallCount = 0;
  int deleteCallCount = 0;
  int shareCallCount = 0;

  final StreamController<List<ShoppingList>> _streamCtrl =
      StreamController<List<ShoppingList>>.broadcast();

  void setInitialLists(List<ShoppingList> lists) {
    _lists = List.from(lists);
  }

  // Push a snapshot to all active listeners (simulates Firestore update).
  void _pushToStream() {
    if (!_streamCtrl.isClosed) {
      _streamCtrl.add(List.from(_lists));
    }
  }

  void dispose() {
    _streamCtrl.close();
  }

  @override
  Stream<List<ShoppingList>> watchLists(String userId, String? householdId) {
    // Emit the current snapshot in the next microtask so the subscription
    // is established before data arrives (mirrors Firestore behaviour).
    Future.microtask(_pushToStream);
    return _streamCtrl.stream;
  }

  @override
  Future<List<ShoppingList>> fetchLists(String userId, String? householdId) async =>
      List.from(_lists);

  @override
  Future<ShoppingList?> getListById(
          String listId, String userId, String? householdId) async =>
      _lists.where((l) => l.id == listId).firstOrNull;

  @override
  Future<ShoppingList> saveList(
      ShoppingList list, String userId, String? householdId) async {
    saveCallCount++;
    if (shouldThrow) throw Exception('Mock save error');
    final idx = _lists.indexWhere((l) => l.id == list.id);
    if (idx >= 0) {
      _lists[idx] = list;
    } else {
      _lists.add(list);
    }
    _pushToStream(); // ← synchronous broadcast → provider sees update immediately
    return list;
  }

  @override
  Future<void> deleteList(
      String id, String userId, String? householdId, bool isPrivate) async {
    deleteCallCount++;
    if (shouldThrow) throw Exception('Mock delete error');
    _lists.removeWhere((l) => l.id == id);
    _pushToStream();
  }

  @override
  Future<ShoppingList> shareListToHousehold(
      String listId, String userId, String householdId) async {
    shareCallCount++;
    final list = _lists.firstWhere((l) => l.id == listId);
    final shared = list.copyWith(isPrivate: false);
    final idx = _lists.indexWhere((l) => l.id == listId);
    _lists[idx] = shared;
    _pushToStream();
    return shared;
  }

  // ── Sharing & Roles ──────────────────────────────────────────────────────
  @override
  Future<void> addSharedUser(String householdId, String listId, String userId,
      String role, String? userName, String? userEmail,
      {String? userAvatar}) async {}

  @override
  Future<void> addSharedUserToPrivateList({
    required String ownerId,
    required String listId,
    required String sharedUserId,
    required String role,
    String? userName,
    String? userEmail,
    String? userAvatar,
  }) async {}

  @override
  Future<void> removeSharedUser(
      String householdId, String listId, String userId) async {}

  @override
  Future<void> updateUserRole(
      String householdId, String listId, String userId, String newRole) async {}

  @override
  Future<void> transferOwnership(String householdId, String listId,
      String currentOwnerId, String newOwnerId) async {}

  // ── Pending Requests ─────────────────────────────────────────────────────
  @override
  Future<String> createRequest(String householdId, String listId,
          String requesterId, String type,
          Map<String, dynamic> requestData, String? requesterName) async =>
      'req-mock';

  @override
  Future<void> approveRequest(String householdId, String listId,
      String requestId, String reviewerId, String? reviewerName) async {}

  @override
  Future<void> rejectRequest(String householdId, String listId,
      String requestId, String reviewerId, String reason,
      String? reviewerName) async {}

  @override
  Future<List<Map<String, dynamic>>> getPendingRequests(
          String householdId, String listId) async =>
      [];
}

// =============================================================================
// MOCK — ReceiptRepository
// =============================================================================

class MockReceiptRepository implements ReceiptRepository {
  int saveCallCount = 0;
  Receipt? lastSaved;

  @override
  Future<Receipt> saveReceipt(
      {required Receipt receipt, required String householdId}) async {
    saveCallCount++;
    lastSaved = receipt;
    return receipt;
  }

  @override
  Future<List<Receipt>> fetchReceipts(String householdId) async => [];

  @override
  Future<Receipt?> getReceiptById(
          String receiptId, String householdId) async =>
      null;

  @override
  Stream<List<Receipt>> watchReceipts(String householdId) => const Stream.empty();

  @override
  Future<void> deleteReceipt(
      {required String id, required String householdId}) async {}
}

// =============================================================================
// STUB — ActivityLogService (no-op, avoids Firebase in tests)
// =============================================================================

class _StubActivityLog implements ActivityLogService {
  @override
  Future<void> log({
    required String householdId,
    required ActivityType type,
    required String actorId,
    required String actorName,
    Map<String, dynamic> data = const {},
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// =============================================================================
// MINIMAL MOCKS — UserContext dependencies
// =============================================================================

class _MockUserRepository implements UserRepository {
  UserEntity? mockUser;

  @override
  Future<UserEntity?> fetchUser(String userId) async => mockUser;

  @override
  Future<UserEntity> createUser({
    required String userId,
    required String email,
    required String name,
    String? phone,
    String? householdId,
    bool? seenOnboarding,
    String? profileImageUrl,
  }) async =>
      throw UnimplementedError();

  @override
  Future<UserEntity> saveUser(UserEntity user) async => user;

  @override
  Future<void> deleteUser(String userId) async {}

  @override
  Future<UserEntity?> findByPhone(String phone) async => null;

  @override
  Future<UserEntity> updateProfile(
          {required String userId, String? name, String? avatar}) async =>
      throw UnimplementedError();

  @override
  Future<void> clearAll({String? householdId}) async {}

  @override
  Future<bool> existsUser(String userId) async => false;

  @override
  Future<UserEntity?> findByEmail(String email,
          {String? householdId}) async =>
      null;

  @override
  Future<List<UserEntity>> getAllUsers({String? householdId}) async => [];

  @override
  Future<void> updateLastLogin(String userId) async {}

  @override
  Future<void> updateHouseholdName(
      String userId, String? householdName) async {}

  @override
  Stream<UserEntity?> watchUser(String userId) => Stream.value(null);
}

class _MockAuthService implements AuthService {
  final _authUserCtrl = StreamController<AuthUser?>.broadcast();
  final _rawCtrl = StreamController<firebase_auth.User?>.broadcast();

  bool _signedIn = false;
  String? _userId;
  String? _email;

  @override
  Stream<AuthUser?> get authUserChanges => _authUserCtrl.stream;

  @override
  Stream<firebase_auth.User?> get authStateChanges => _rawCtrl.stream;

  @override
  bool get isSignedIn => _signedIn;

  @override
  String? get currentUserId => _userId;

  @override
  String? get currentUserEmail => _email;

  @override
  String? get currentUserDisplayName => null;

  @override
  firebase_auth.User? get currentUser => null;

  @override
  AuthUser? get currentAuthUser => null;

  @override
  bool get isEmailVerified => false;

  @override
  Future<firebase_auth.UserCredential> signUp(
          {required String email,
          required String password,
          required String name}) async =>
      throw UnimplementedError();

  @override
  Future<firebase_auth.UserCredential> signIn(
          {required String email, required String password}) async =>
      throw UnimplementedError();

  @override
  Future<bool> signOut() async => true;

  @override
  Future<SocialLoginResult> signInWithGoogle() async =>
      throw UnimplementedError();

  @override
  Future<SocialLoginResult> signInWithApple() async =>
      throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> reauthenticate(
      {required String email, required String password}) async {}

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

  void simulateSignIn({
    String userId = 'u-test',
    String email = 'test@test.com',
  }) {
    _signedIn = true;
    _userId = userId;
    _email = email;
    _authUserCtrl.add(AuthUser(uid: userId, email: email));
  }

  void dispose() {
    _authUserCtrl.close();
    _rawCtrl.close();
  }
}

// =============================================================================
// HELPERS
// =============================================================================

/// Creates a [UserContext] that immediately reports as logged in.
Future<({UserContext ctx, _MockAuthService auth})> _makeLoggedIn({
  String userId = 'u-test',
  String householdId = 'h-test',
}) async {
  SharedPreferences.setMockInitialValues({});

  final repo = _MockUserRepository()
    ..mockUser = UserEntity(
      id: userId,
      name: 'Test',
      email: 'test@test.com',
      householdId: householdId,
      joinedAt: DateTime(2026, 1, 1),
      seenOnboarding: true,
    );
  final auth = _MockAuthService();
  auth._signedIn = true;
  auth._userId = userId;
  auth._email = 'test@test.com';

  final ctx = UserContext(repository: repo, authService: auth);

  auth._authUserCtrl.add(AuthUser(uid: userId, email: 'test@test.com'));
  await Future.delayed(const Duration(milliseconds: 150));

  return (ctx: ctx, auth: auth);
}

/// Builds a [ShoppingListsProvider] with all mocks injected.
///
/// If [mockRepo] already has lists set via [setInitialLists], they will be
/// visible in the provider after this call returns (stream fires on subscribe).
Future<ShoppingListsProvider> _buildProvider({
  required MockShoppingListsRepository mockRepo,
  required MockReceiptRepository mockReceipts,
  required UserContext userContext,
  // 🔄 פאזה 3: ברוב הבדיקות נכבה את היצירה האוטומטית כדי לשלוט במצב הרשימות.
  // הבדיקות הייעודיות ל"רשימה אחת קבועה" מדליקות אותה במפורש.
  bool autoEnsureDefaultList = false,
}) async {
  final provider = ShoppingListsProvider(
    repository: mockRepo,
    activityLog: _StubActivityLog(),
    autoEnsureDefaultList: autoEnsureDefaultList,
  );
  provider.updateUserContext(userContext);
  // Two rounds of microtasks:
  // 1. updateUserContext → Future.microtask(_onUserChanged)
  // 2. watchLists → Future.microtask(_pushToStream) → stream listener updates _lists
  await Future.delayed(const Duration(milliseconds: 50));
  return provider;
}

/// Convenience: a minimal active [ShoppingList] with no items.
ShoppingList _makeList({
  String id = 'list-1',
  String name = 'רשימה',
  String status = ShoppingList.statusActive,
  bool isPrivate = true,
  List<UnifiedListItem> items = const [],
  List<ActiveShopper> activeShoppers = const [],
  String createdBy = 'u-test',
}) {
  return ShoppingList.newList(
    id: id,
    name: name,
    createdBy: createdBy,
    isPrivate: isPrivate,
    items: items,
  ).copyWith(
    status: status,
    activeShoppers: activeShoppers,
  );
}

/// Convenience: an [InventoryItem] to feed `syncMissingFromPantry`
/// (the provider treats every item passed in as a "missing" item).
InventoryItem _pantryItem(String id, String name, {String category = 'כללי'}) =>
    InventoryItem(
      id: id,
      productName: name,
      category: category,
      location: 'מקרר',
      quantity: 0,
      unit: "יח'",
      // minQuantity ברירת המחדל = 1, אז quantity 0 הוא "חוסר"
    );

// =============================================================================
// TESTS
// =============================================================================

void main() {
  late MockShoppingListsRepository mockRepo;
  late MockReceiptRepository mockReceipts;
  late UserContext userCtx;
  late _MockAuthService mockAuth;

  setUp(() async {
    mockRepo = MockShoppingListsRepository();
    mockReceipts = MockReceiptRepository();
    final result = await _makeLoggedIn();
    userCtx = result.ctx;
    mockAuth = result.auth;
  });

  tearDown(() {
    userCtx.dispose();
    mockAuth.dispose();
    mockRepo.dispose();
  });

  // ===========================================================================
  // Initial State
  // ===========================================================================
  group('ShoppingListsProvider - Initial State', () {
    test('starts with empty list, no error, not loading', () async {
      final provider =
          await _buildProvider(mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      expect(provider.lists, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.hasError, false);
      expect(provider.isEmpty, true);

      provider.dispose();
    });

    test('loads initial lists pushed by stream', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1'), _makeList(id: 'l2')]);

      final provider =
          await _buildProvider(mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      expect(provider.lists.length, 2);
      provider.dispose();
    });
  });

  // ===========================================================================
  // getById
  // ===========================================================================
  group('ShoppingListsProvider - getById', () {
    test('returns list when found', () async {
      mockRepo.setInitialLists([_makeList(id: 'target')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      expect(provider.getById('target'), isNotNull);
      expect(provider.getById('target')!.id, 'target');
      provider.dispose();
    });

    test('returns null when not found', () async {
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      expect(provider.getById('ghost'), isNull);
      provider.dispose();
    });
  });

  // ===========================================================================
  // clearAll
  // ===========================================================================
  group('ShoppingListsProvider - clearAll', () {
    test('clears lists, error and loading', () async {
      mockRepo.setInitialLists([_makeList()]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      expect(provider.lists.length, 1);

      provider.clearAll();

      expect(provider.lists, isEmpty);
      expect(provider.hasError, false);
      expect(provider.isLoading, false);

      provider.dispose();
    });
  });

  // ===========================================================================
  // createList
  // ===========================================================================
  group('ShoppingListsProvider - createList', () {
    test('creates list and adds to provider', () async {
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.createList(name: 'קניות שבועיות');

      expect(provider.lists.length, 1);
      expect(provider.lists.first.name, 'קניות שבועיות');
      expect(provider.lists.first.createdBy, 'u-test');
      expect(mockRepo.saveCallCount, 1);

      provider.dispose();
    });

    test('createList respects kMaxActiveListsPerUser (30 lists → 31st throws)', () async {
      // Fill up to the limit
      final existing = List.generate(
        30,
        (i) => _makeList(id: 'l$i', status: ShoppingList.statusActive),
      );
      mockRepo.setInitialLists(existing);

      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      expect(provider.activeLists.length, 30);

      await expectLater(
        provider.createList(name: 'רשימה 31'),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });

    test('createList with template sets createdFromTemplate flag', () async {
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      final item = UnifiedListItem.product(
          id: 'i1', name: 'חלב', quantity: 1, unitPrice: 6.9);
      await provider.createList(
          name: 'מתבנית', templateId: 'tmpl-1', items: [item]);

      expect(provider.lists.first.createdFromTemplate, true);
      expect(provider.lists.first.items.length, 1);

      provider.dispose();
    });
  });

  // ===========================================================================
  // deleteList
  // ===========================================================================
  group('ShoppingListsProvider - deleteList', () {
    test('removes list from provider', () async {
      mockRepo.setInitialLists([_makeList(id: 'del-me')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      expect(provider.lists.length, 1);

      await provider.deleteList('del-me');

      expect(provider.lists, isEmpty);
      expect(mockRepo.deleteCallCount, 1);

      provider.dispose();
    });

    test('delete on shared list calls activity log path', () async {
      // Shared list: isPrivate = false
      mockRepo.setInitialLists([_makeList(id: 'shared-1', isPrivate: false)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      // Should complete without throwing
      await expectLater(provider.deleteList('shared-1'), completes);

      provider.dispose();
    });
  });

  // ===========================================================================
  // addItemToList
  // ===========================================================================
  group('ShoppingListsProvider - addItemToList', () {
    test('adds item to list', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.addItemToList('l1', 'חלב', 2, "יח'");

      expect(provider.getById('l1')!.items.length, 1);
      expect(provider.getById('l1')!.items.first.name, 'חלב');

      provider.dispose();
    });

    test('throws when list not found', () async {
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await expectLater(
        provider.addItemToList('ghost', 'פריט', 1, "יח'"),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });

    test('throws when kMaxItemsPerList (200) is reached', () async {
      final items = List.generate(
        200,
        (i) => UnifiedListItem.product(
            id: 'i$i', name: 'פריט $i', quantity: 1, unitPrice: 0.0),
      );
      mockRepo.setInitialLists([_makeList(id: 'full', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      expect(provider.getById('full')!.items.length, 200);

      await expectLater(
        provider.addItemToList('full', 'פריט 201', 1, "יח'"),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });
  });

  // ===========================================================================
  // autoEnsureDefaultList (פאזה 3 — רשימה אחת קבועה)
  // ===========================================================================
  group('ShoppingListsProvider - autoEnsureDefaultList', () {
    test('auto-creates the live list when no active list exists', () async {
      // אין רשימות התחלתיות + הדגל דלוק
      final provider = await _buildProvider(
        mockRepo: mockRepo,
        mockReceipts: mockReceipts,
        userContext: userCtx,
        autoEnsureDefaultList: true,
      );

      expect(provider.activeLists.length, 1);
      expect(provider.activeLists.first.name,
          AppStrings.shopping.defaultShoppingListName);

      provider.dispose();
    });

    test('does not create a second list when one already exists', () async {
      mockRepo.setInitialLists([_makeList(id: 'existing')]);
      final provider = await _buildProvider(
        mockRepo: mockRepo,
        mockReceipts: mockReceipts,
        userContext: userCtx,
        autoEnsureDefaultList: true,
      );

      expect(provider.activeLists.length, 1);
      expect(provider.activeLists.first.id, 'existing');

      provider.dispose();
    });

    test('does not create duplicates across repeated stream emissions', () async {
      final provider = await _buildProvider(
        mockRepo: mockRepo,
        mockReceipts: mockReceipts,
        userContext: userCtx,
        autoEnsureDefaultList: true,
      );

      // נותן זמן לכמה מחזורי stream (יצירה → re-emit → בדיקה חוזרת)
      await Future.delayed(const Duration(milliseconds: 80));

      expect(provider.activeLists.length, 1);
      provider.dispose();
    });
  });

  // ===========================================================================
  // finishShoppingKeepListActive (פאזה 6 — סיום קנייה, הרשימה נשארת)
  // ===========================================================================
  group('ShoppingListsProvider - finishShoppingKeepListActive', () {
    test('removes purchased items, keeps the rest, list stays active', () async {
      final items = [
        UnifiedListItem.product(id: 'i1', name: 'חלב', quantity: 1, unitPrice: 0.0),
        UnifiedListItem.product(id: 'i2', name: 'לחם', quantity: 1, unitPrice: 0.0),
        UnifiedListItem.product(id: 'i3', name: 'ביצים', quantity: 1, unitPrice: 0.0),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.finishShoppingKeepListActive('l1', purchasedItemIds: {'i1', 'i2'});

      final list = provider.getById('l1')!;
      expect(list.items.map((i) => i.id), ['i3']); // unbought stays
      expect(list.status, ShoppingList.statusActive); // not completed
      provider.dispose();
    });

    test('marks active shoppers inactive', () async {
      final items = [
        UnifiedListItem.product(id: 'i1', name: 'חלב', quantity: 1, unitPrice: 0.0),
      ];
      mockRepo.setInitialLists([
        _makeList(
          id: 'l1',
          items: items,
          activeShoppers: [ActiveShopper.starter(userId: 'u-test')],
        ),
      ]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.finishShoppingKeepListActive('l1', purchasedItemIds: {'i1'});

      final list = provider.getById('l1')!;
      expect(list.activeShoppers.every((s) => !s.isActive), isTrue);
      provider.dispose();
    });

    test('idempotent — nothing purchased and no active shopper → no write', () async {
      mockRepo.setInitialLists([
        _makeList(id: 'l1', items: [
          UnifiedListItem.product(id: 'i1', name: 'חלב', quantity: 1, unitPrice: 0.0),
        ]),
      ]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      final before = mockRepo.saveCallCount;
      await provider.finishShoppingKeepListActive('l1', purchasedItemIds: {});

      expect(mockRepo.saveCallCount, before);
      provider.dispose();
    });
  });

  // ===========================================================================
  // syncMissingFromPantry (פאזה 2 — המזווה כותב את הרשימה)
  // ===========================================================================
  group('ShoppingListsProvider - syncMissingFromPantry', () {
    test('adds missing pantry items to the active list as auto items', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.syncMissingFromPantry([
        _pantryItem('p1', 'חלב'),
        _pantryItem('p2', 'ביצים'),
      ]);

      final items = provider.getById('l1')!.items;
      expect(items.length, 2);
      expect(items.every((i) => i.isFromPantry), isTrue);
      expect(items.map((i) => i.pantryItemId).toSet(), {'p1', 'p2'});

      provider.dispose();
    });

    test('removes auto items whose pantry item is no longer missing', () async {
      final auto = UnifiedListItem.product(
          id: 'a1', name: 'חלב', quantity: 1, unitPrice: 0.0, pantryItemId: 'p1');
      mockRepo.setInitialLists([_makeList(id: 'l1', items: [auto])]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      // back in stock → nothing missing
      await provider.syncMissingFromPantry([]);

      expect(provider.getById('l1')!.items, isEmpty);
      provider.dispose();
    });

    test('never touches manual items', () async {
      // no pantryItemId → manual
      final manual = UnifiedListItem.product(
          id: 'm1', name: 'שוקולד', quantity: 1, unitPrice: 0.0);
      mockRepo.setInitialLists([_makeList(id: 'l1', items: [manual])]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.syncMissingFromPantry([]);

      final items = provider.getById('l1')!.items;
      expect(items.length, 1);
      expect(items.first.id, 'm1');
      expect(items.first.isFromPantry, isFalse);
      provider.dispose();
    });

    test('keeps an in-cart auto item that is still missing', () async {
      final checkedAuto = UnifiedListItem.product(
          id: 'a1',
          name: 'חלב',
          quantity: 1,
          unitPrice: 0.0,
          isChecked: true,
          pantryItemId: 'p1');
      mockRepo.setInitialLists([_makeList(id: 'l1', items: [checkedAuto])]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.syncMissingFromPantry([_pantryItem('p1', 'חלב')]);

      final items = provider.getById('l1')!.items;
      expect(items.length, 1);
      expect(items.first.isChecked, isTrue);
      provider.dispose();
    });

    test('is idempotent — no write when nothing changed', () async {
      final auto = UnifiedListItem.product(
          id: 'a1', name: 'חלב', quantity: 1, unitPrice: 0.0, pantryItemId: 'p1');
      mockRepo.setInitialLists([_makeList(id: 'l1', items: [auto])]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      final before = mockRepo.saveCallCount;
      await provider.syncMissingFromPantry([_pantryItem('p1', 'חלב')]);

      expect(mockRepo.saveCallCount, before);
      provider.dispose();
    });

    test('no active list → no-op (no throw, no write)', () async {
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      final before = mockRepo.saveCallCount;
      await provider.syncMissingFromPantry([_pantryItem('p1', 'חלב')]);

      expect(mockRepo.saveCallCount, before);
      provider.dispose();
    });
  });

  // ===========================================================================
  // addUnifiedItem
  // ===========================================================================
  group('ShoppingListsProvider - addUnifiedItem', () {
    test('adds product item to list', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      final item = UnifiedListItem.product(
          id: 'p1', name: 'גבינה', quantity: 1, unitPrice: 12.0);
      await provider.addUnifiedItem('l1', item);

      expect(provider.getById('l1')!.items.length, 1);
      expect(provider.getById('l1')!.items.first.name, 'גבינה');

      provider.dispose();
    });

    test('adds task item to list', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      final task = UnifiedListItem.task(id: 't1', name: 'לקנות כיכר לחם');
      await provider.addUnifiedItem('l1', task);

      expect(provider.getById('l1')!.items.length, 1);
      expect(provider.getById('l1')!.items.first.name, 'לקנות כיכר לחם');

      provider.dispose();
    });
  });

  // ===========================================================================
  // removeItemFromList
  // ===========================================================================
  group('ShoppingListsProvider - removeItemFromList', () {
    test('removes item at index', () async {
      final items = [
        UnifiedListItem.product(
            id: 'i0', name: 'חלב', quantity: 1, unitPrice: 0.0),
        UnifiedListItem.product(
            id: 'i1', name: 'לחם', quantity: 1, unitPrice: 0.0),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.removeItemFromList('l1', 0);

      expect(provider.getById('l1')!.items.length, 1);
      expect(provider.getById('l1')!.items.first.name, 'לחם');

      provider.dispose();
    });
  });

  // ===========================================================================
  // updateItemAt
  // ===========================================================================
  group('ShoppingListsProvider - updateItemAt', () {
    test('updates item at valid index', () async {
      final items = [
        UnifiedListItem.product(
            id: 'i0', name: 'חלב', quantity: 1, unitPrice: 0.0),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.updateItemAt('l1', 0, (item) => item.copyWith(name: 'חלב 3%'));

      expect(provider.getById('l1')!.items.first.name, 'חלב 3%');

      provider.dispose();
    });

    test('throws on out-of-bounds index', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await expectLater(
        provider.updateItemAt('l1', 5, (item) => item),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });
  });

  // ===========================================================================
  // updateItemById
  // ===========================================================================
  group('ShoppingListsProvider - updateItemById', () {
    test('updates item by ID', () async {
      final item = UnifiedListItem.product(
          id: 'unique-id', name: 'מלח', quantity: 1, unitPrice: 0.0);
      mockRepo.setInitialLists([_makeList(id: 'l1', items: [item])]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      final updated = item.copyWith(name: 'מלח גס');
      await provider.updateItemById('l1', updated);

      expect(provider.getById('l1')!.items.first.name, 'מלח גס');

      provider.dispose();
    });

    test('throws when item ID not in list', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      final ghost = UnifiedListItem.product(
          id: 'ghost', name: 'רוח', quantity: 1, unitPrice: 0.0);

      await expectLater(
        provider.updateItemById('l1', ghost),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });
  });

  // ===========================================================================
  // toggleAllItemsChecked
  // ===========================================================================
  group('ShoppingListsProvider - toggleAllItemsChecked', () {
    test('marks all items as checked', () async {
      final items = [
        UnifiedListItem.product(
            id: 'i0', name: 'חלב', quantity: 1, unitPrice: 0.0),
        UnifiedListItem.product(
            id: 'i1', name: 'לחם', quantity: 1, unitPrice: 0.0),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.toggleAllItemsChecked('l1', true);

      final updatedItems = provider.getById('l1')!.items;
      expect(updatedItems.every((i) => i.isChecked), true);

      provider.dispose();
    });

    test('marks all items as unchecked', () async {
      final items = [
        UnifiedListItem.product(
            id: 'i0', name: 'חלב', quantity: 1, unitPrice: 0.0, isChecked: true),
        UnifiedListItem.product(
            id: 'i1', name: 'לחם', quantity: 1, unitPrice: 0.0, isChecked: true),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.toggleAllItemsChecked('l1', false);

      final updatedItems = provider.getById('l1')!.items;
      expect(updatedItems.every((i) => !i.isChecked), true);

      provider.dispose();
    });
  });

  // ===========================================================================
  // updateListStatus
  // ===========================================================================
  group('ShoppingListsProvider - updateListStatus', () {
    test('completes list', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.updateListStatus('l1', ShoppingList.statusCompleted);

      expect(provider.getById('l1')!.status, ShoppingList.statusCompleted);

      provider.dispose();
    });

    test('reactivating list respects kMaxActiveListsPerUser limit', () async {
      // 30 active lists + 1 completed (the one we'll try to reactivate)
      final active =
          List.generate(30, (i) => _makeList(id: 'a$i'));
      final completed = _makeList(id: 'done', status: ShoppingList.statusCompleted);
      mockRepo.setInitialLists([...active, completed]);

      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      expect(provider.activeLists.length, 30);

      await expectLater(
        provider.updateListStatus('done', ShoppingList.statusActive),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });
  });

  // 🔄 פאזה 6: בדיקות addToNextList הוסרו — השיטה הוסרה (אין "רשימה הבאה").

  // ===========================================================================
  // Collaborative Shopping — start / join / leave
  // ===========================================================================
  group('ShoppingListsProvider - Collaborative Shopping', () {
    test('startCollaborativeShopping adds Starter shopper', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.startCollaborativeShopping('l1', 'u-test');

      final list = provider.getById('l1')!;
      expect(list.isBeingShopped, true);
      expect(list.activeShoppers.first.isStarter, true);

      provider.dispose();
    });

    test('startCollaborativeShopping throws when already shopping', () async {
      final shopper = ActiveShopper.starter(userId: 'u-test');
      mockRepo.setInitialLists([_makeList(id: 'l1', activeShoppers: [shopper])]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await expectLater(
        provider.startCollaborativeShopping('l1', 'u-other'),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });

    test('joinCollaborativeShopping adds Helper shopper', () async {
      final starter = ActiveShopper.starter(userId: 'u-starter');
      mockRepo.setInitialLists([_makeList(id: 'l1', activeShoppers: [starter])]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.joinCollaborativeShopping('l1', 'u-helper');

      final list = provider.getById('l1')!;
      expect(list.activeShoppers.length, 2);
      expect(list.activeShoppers.any((s) => s.userId == 'u-helper'), true);

      provider.dispose();
    });

    test('joinCollaborativeShopping throws when no active session', () async {
      mockRepo.setInitialLists([_makeList(id: 'l1')]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await expectLater(
        provider.joinCollaborativeShopping('l1', 'u-helper'),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });

    test('joinCollaborativeShopping throws when already in session', () async {
      final starter = ActiveShopper.starter(userId: 'u-starter');
      final helper = ActiveShopper.helper(userId: 'u-helper');
      mockRepo.setInitialLists([
        _makeList(id: 'l1', activeShoppers: [starter, helper])
      ]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await expectLater(
        provider.joinCollaborativeShopping('l1', 'u-helper'),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });

    test('leaveCollaborativeShopping marks shopper inactive', () async {
      final starter = ActiveShopper.starter(userId: 'u-test');
      mockRepo.setInitialLists([_makeList(id: 'l1', activeShoppers: [starter])]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.leaveCollaborativeShopping('l1', 'u-test');

      final list = provider.getById('l1')!;
      expect(list.activeShoppers.first.isActive, false);
      expect(list.isBeingShopped, false);

      provider.dispose();
    });
  });

  // ===========================================================================
  // markItemAsChecked
  // ===========================================================================
  group('ShoppingListsProvider - markItemAsChecked', () {
    test('marks item as checked with userId', () async {
      final starter = ActiveShopper.starter(userId: 'u-test');
      final items = [
        UnifiedListItem.product(
            id: 'i0', name: 'חלב', quantity: 1, unitPrice: 0.0),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items, activeShoppers: [starter])]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.markItemAsChecked('l1', 0, 'u-test');

      final item = provider.getById('l1')!.items.first;
      expect(item.isChecked, true);
      expect(item.checkedBy, 'u-test');

      provider.dispose();
    });

    test('throws when user is not an active shopper', () async {
      final items = [
        UnifiedListItem.product(
            id: 'i0', name: 'חלב', quantity: 1, unitPrice: 0.0),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await expectLater(
        provider.markItemAsChecked('l1', 0, 'u-not-shopping'),
        throwsA(isA<Exception>()),
      );

      provider.dispose();
    });
  });

  // ===========================================================================
  // updateItemStatus
  // ===========================================================================
  group('ShoppingListsProvider - updateItemStatus', () {
    test('purchased status sets isChecked = true', () async {
      final items = [
        UnifiedListItem.product(
            id: 'i0', name: 'חלב', quantity: 1, unitPrice: 0.0),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.updateItemStatus('l1', 'i0', ShoppingItemStatus.purchased);

      expect(provider.getById('l1')!.items.first.isChecked, true);

      provider.dispose();
    });

    test('pending status clears isChecked', () async {
      final items = [
        UnifiedListItem.product(
            id: 'i0', name: 'חלב', quantity: 1, unitPrice: 0.0, isChecked: true),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.updateItemStatus('l1', 'i0', ShoppingItemStatus.pending);

      expect(provider.getById('l1')!.items.first.isChecked, false);

      provider.dispose();
    });

    test('early return — no save when status unchanged (purchased → purchased)', () async {
      final items = [
        UnifiedListItem.product(
            id: 'i0', name: 'חלב', quantity: 1, unitPrice: 0.0, isChecked: true),
      ];
      mockRepo.setInitialLists([_makeList(id: 'l1', items: items)]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);
      final savesBefore = mockRepo.saveCallCount;

      await provider.updateItemStatus('l1', 'i0', ShoppingItemStatus.purchased);

      // No new write to the repository
      expect(mockRepo.saveCallCount, savesBefore);

      provider.dispose();
    });
  });

  // 🔄 פאזה 6: בדיקות finishCollaborativeShopping הוסרו — השיטה הוסרה.

  // ===========================================================================
  // cleanupAbandonedSessions
  // ===========================================================================
  group('ShoppingListsProvider - cleanupAbandonedSessions', () {
    test('no-op when no sessions are timed out', () async {
      // Active shopper who just joined (not timed out)
      final freshShopper = ActiveShopper.starter(userId: 'u-test');
      mockRepo.setInitialLists([
        _makeList(id: 'l1', activeShoppers: [freshShopper])
      ]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);
      final savesBefore = mockRepo.saveCallCount;

      await provider.cleanupAbandonedSessions();

      expect(mockRepo.saveCallCount, savesBefore);

      provider.dispose();
    });

    test('marks shoppers inactive on timed-out sessions (7h old)', () async {
      // Shopper who joined 7 hours ago — exceeds 6-hour timeout
      final staleShopper = ActiveShopper(
        userId: 'u-stale',
        joinedAt: DateTime.now().subtract(const Duration(hours: 7)),
        isStarter: true,
      );
      mockRepo.setInitialLists([
        _makeList(id: 'l1', activeShoppers: [staleShopper])
      ]);
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      await provider.cleanupAbandonedSessions();

      // After cleanup, all shoppers in that list should be inactive
      final list = provider.getById('l1')!;
      expect(list.activeShoppers.every((s) => !s.isActive), true);

      provider.dispose();
    });
  });

  // ===========================================================================
  // Dispose Safety
  // ===========================================================================
  group('ShoppingListsProvider - Dispose Safety', () {
    test('reading getters after dispose does not crash', () async {
      final provider = await _buildProvider(
          mockRepo: mockRepo, mockReceipts: mockReceipts, userContext: userCtx);

      provider.dispose();

      expect(() => provider.lists, returnsNormally);
      expect(() => provider.isLoading, returnsNormally);
      expect(() => provider.hasError, returnsNormally);
      expect(() => provider.isEmpty, returnsNormally);
    });
  });
}
