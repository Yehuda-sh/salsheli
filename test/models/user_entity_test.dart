import 'package:flutter_test/flutter_test.dart';
import 'package:salsheli/models/user_entity.dart';

void main() {
  group('UserEntity', () {
    late DateTime testDate;
    
    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
    });

    group('Constructors', () {
      test('creates with all required fields', () {
        final user = UserEntity(
          id: 'user-123',
          name: 'יוסי כהן',
          email: 'yossi@example.com',
          householdId: 'house-456',
          joinedAt: testDate,
        );

        expect(user.id, 'user-123');
        expect(user.name, 'יוסי כהן');
        expect(user.email, 'yossi@example.com');
        expect(user.householdId, 'house-456');
        expect(user.joinedAt, testDate);
        expect(user.lastLoginAt, isNull);
        expect(user.profileImageUrl, isNull);
        expect(user.preferredStores, isEmpty);
        expect(user.favoriteProducts, isEmpty);
        expect(user.weeklyBudget, 0.0);
        expect(user.isAdmin, false);
      });

      test('creates with all optional fields', () {
        final lastLogin = testDate.add(Duration(days: 1));
        final user = UserEntity(
          id: 'user-789',
          name: 'שרה לוי',
          email: 'sara@example.com',
          householdId: 'house-012',
          joinedAt: testDate,
          lastLoginAt: lastLogin,
          profileImageUrl: 'https://example.com/profile.jpg',
          preferredStores: const ['store-1', 'store-2'],
          favoriteProducts: const ['prod-1', 'prod-2', 'prod-3'],
          weeklyBudget: 1500.0,
          isAdmin: true,
        );

        expect(user.lastLoginAt, lastLogin);
        expect(user.profileImageUrl, 'https://example.com/profile.jpg');
        expect(user.preferredStores, ['store-1', 'store-2']);
        expect(user.favoriteProducts, ['prod-1', 'prod-2', 'prod-3']);
        expect(user.weeklyBudget, 1500.0);
        expect(user.isAdmin, true);
      });

      test('empty constructor creates default user', () {
        final emptyUser = UserEntity.empty();

        expect(emptyUser.id, '');
        expect(emptyUser.name, '');
        expect(emptyUser.email, '');
        expect(emptyUser.householdId, '');
        expect(emptyUser.joinedAt, DateTime(1970, 1, 1));
        expect(emptyUser.lastLoginAt, isNull);
        expect(emptyUser.profileImageUrl, isNull);
        expect(emptyUser.preferredStores, isEmpty);
        expect(emptyUser.favoriteProducts, isEmpty);
        expect(emptyUser.weeklyBudget, 0.0);
        expect(emptyUser.isAdmin, false);
      });

      test('demo constructor creates test user', () {
        final demoUser = UserEntity.demo(
          id: 'demo-123',
          name: 'דני הבודק',
        );

        expect(demoUser.id, 'demo-123');
        expect(demoUser.name, 'דני הבודק');
        expect(demoUser.email, 'demo-123@example.com');
        expect(demoUser.householdId, startsWith('house_'));
        expect(demoUser.joinedAt.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
        expect(demoUser.lastLoginAt, isNotNull);
        expect(demoUser.preferredStores, isEmpty);
        expect(demoUser.favoriteProducts, isEmpty);
        expect(demoUser.weeklyBudget, 0.0);
        expect(demoUser.isAdmin, false);
      });

      test('demo constructor with custom email and household', () {
        final demoUser = UserEntity.demo(
          id: 'demo-456',
          name: 'רונית הבודקת',
          email: 'ronit@test.com',
          householdId: 'test-house-789',
        );

        expect(demoUser.email, 'ronit@test.com');
        expect(demoUser.householdId, 'test-house-789');
      });

      test('newUser constructor creates admin user', () {
        final newUser = UserEntity.newUser(
          id: 'new-user-123',
          email: 'new@example.com',
          name: 'משתמש חדש',
        );

        expect(newUser.id, 'new-user-123');
        expect(newUser.email, 'new@example.com');
        expect(newUser.name, 'משתמש חדש');
        expect(newUser.householdId, 'house_new-user-123');
        expect(newUser.joinedAt.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
        expect(newUser.lastLoginAt, isNotNull);
        expect(newUser.isAdmin, true);  // New user is admin of their household
      });

      test('newUser with custom household', () {
        final newUser = UserEntity.newUser(
          id: 'new-user-456',
          email: 'another@example.com',
          name: 'משתמש אחר',
          householdId: 'custom-house-123',
        );

        expect(newUser.householdId, 'custom-house-123');
      });
    });

    group('copyWith', () {
      test('updates only specified fields', () {
        final original = UserEntity(
          id: 'user-original',
          name: 'שם מקורי',
          email: 'original@example.com',
          householdId: 'house-original',
          joinedAt: testDate,
          weeklyBudget: 1000.0,
          isAdmin: false,
        );

        final updated = original.copyWith(
          name: 'שם חדש',
          weeklyBudget: 1500.0,
          isAdmin: true,
        );

        expect(updated.name, 'שם חדש');
        expect(updated.weeklyBudget, 1500.0);
        expect(updated.isAdmin, true);
        
        // Unchanged fields
        expect(updated.id, original.id);
        expect(updated.email, original.email);
        expect(updated.householdId, original.householdId);
        expect(updated.joinedAt, original.joinedAt);
      });

      test('can update lists', () {
        final original = UserEntity(
          id: 'user-123',
          name: 'משתמש',
          email: 'user@example.com',
          householdId: 'house-123',
          joinedAt: testDate,
          preferredStores: const ['store-1'],
          favoriteProducts: const ['prod-1'],
        );

        final updated = original.copyWith(
          preferredStores: ['store-1', 'store-2', 'store-3'],
          favoriteProducts: ['prod-a', 'prod-b'],
        );

        expect(updated.preferredStores, ['store-1', 'store-2', 'store-3']);
        expect(updated.favoriteProducts, ['prod-a', 'prod-b']);
      });

      test('can set and clear nullable fields', () {
        final original = UserEntity(
          id: 'user-123',
          name: 'משתמש',
          email: 'user@example.com',
          householdId: 'house-123',
          joinedAt: testDate,
          lastLoginAt: testDate,
          profileImageUrl: 'https://example.com/pic.jpg',
        );

        // Clear fields using the clear flags
        final updated = original.copyWith(
          clearLastLoginAt: true,
          clearProfileImageUrl: true,
        );

        expect(updated.lastLoginAt, isNull);
        expect(updated.profileImageUrl, isNull);

        // Set new values for nullable fields
        final updated2 = updated.copyWith(
          lastLoginAt: testDate.add(Duration(days: 1)),
          profileImageUrl: 'https://example.com/new.jpg',
        );

        expect(updated2.lastLoginAt, testDate.add(Duration(days: 1)));
        expect(updated2.profileImageUrl, 'https://example.com/new.jpg');
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly', () {
        final original = UserEntity(
          id: 'user-json-test',
          name: 'בדיקת JSON',
          email: 'json@test.com',
          householdId: 'house-json',
          joinedAt: testDate,
          lastLoginAt: testDate.add(Duration(hours: 2)),
          profileImageUrl: 'https://example.com/avatar.png',
          preferredStores: const ['store-a', 'store-b'],
          favoriteProducts: const ['barcode-1', 'barcode-2'],
          weeklyBudget: 2000.0,
          isAdmin: true,
        );

        final json = original.toJson();
        final restored = UserEntity.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.email, original.email);
        expect(restored.householdId, original.householdId);
        expect(restored.joinedAt, original.joinedAt);
        expect(restored.lastLoginAt, original.lastLoginAt);
        expect(restored.profileImageUrl, original.profileImageUrl);
        expect(restored.preferredStores, original.preferredStores);
        expect(restored.favoriteProducts, original.favoriteProducts);
        expect(restored.weeklyBudget, original.weeklyBudget);
        expect(restored.isAdmin, original.isAdmin);
      });

      test('handles missing optional fields in JSON', () {
        final json = {
          'id': 'user-minimal',
          'name': 'משתמש מינימלי',
          'email': 'minimal@test.com',
          'household_id': 'house-minimal',
          'joined_at': testDate.toIso8601String(),
          // All optional fields missing
        };

        final user = UserEntity.fromJson(json);

        expect(user.id, 'user-minimal');
        expect(user.name, 'משתמש מינימלי');
        expect(user.email, 'minimal@test.com');
        expect(user.householdId, 'house-minimal');
        expect(user.lastLoginAt, isNull);
        expect(user.profileImageUrl, isNull);
        expect(user.preferredStores, isEmpty);
        expect(user.favoriteProducts, isEmpty);
        expect(user.weeklyBudget, 0.0);
        expect(user.isAdmin, false);
      });

      test('JSON structure uses snake_case', () {
        final user = UserEntity(
          id: 'user-case-test',
          name: 'בדיקת Case',
          email: 'case@test.com',
          householdId: 'house-case',
          joinedAt: testDate,
          lastLoginAt: testDate,
          profileImageUrl: 'https://example.com/pic.jpg',
        );

        final json = user.toJson();

        expect(json.containsKey('household_id'), true);
        expect(json.containsKey('joined_at'), true);
        expect(json.containsKey('last_login_at'), true);
        expect(json.containsKey('profile_image_url'), true);
        expect(json.containsKey('preferred_stores'), true);
        expect(json.containsKey('favorite_products'), true);
        expect(json.containsKey('weekly_budget'), true);
        expect(json.containsKey('is_admin'), true);
      });

      test('listFromJson handles various inputs', () {
        final users = [
          UserEntity.newUser(id: 'u1', name: 'משתמש 1', email: 'u1@test.com'),
          UserEntity.newUser(id: 'u2', name: 'משתמש 2', email: 'u2@test.com'),
        ];

        final jsonList = users.map((u) => u.toJson()).toList();
        final restoredList = UserEntity.listFromJson(jsonList);

        expect(restoredList.length, 2);
        expect(restoredList[0].id, 'u1');
        expect(restoredList[1].id, 'u2');

        // Test with null
        expect(UserEntity.listFromJson(null), isEmpty);

        // Test with empty list
        expect(UserEntity.listFromJson([]), isEmpty);

        // Test with invalid items
        final mixedList = [
          users[0].toJson(),
          'invalid',
          null,
          users[1].toJson(),
        ];
        final filteredList = UserEntity.listFromJson(mixedList);
        expect(filteredList.length, 2);
      });

      test('listToJson converts list correctly', () {
        final users = [
          UserEntity.newUser(id: 'u1', name: 'משתמש 1', email: 'u1@test.com'),
          UserEntity.newUser(id: 'u2', name: 'משתמש 2', email: 'u2@test.com'),
        ];

        final jsonList = UserEntity.listToJson(users);

        expect(jsonList.length, 2);
        expect(jsonList[0]['id'], 'u1');
        expect(jsonList[1]['id'], 'u2');
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        final user = UserEntity(
          id: 'user-123',
          name: 'יוסי כהן',
          email: 'yossi@example.com',
          householdId: 'house-456',
          joinedAt: testDate,
          weeklyBudget: 1500.0,
          isAdmin: true,
        );

        final str = user.toString();

        expect(str, contains('user-123'));
        expect(str, contains('יוסי כהן'));
        expect(str, contains('yossi@example.com'));
        expect(str, contains('house-456'));
        expect(str, contains('1500.0'));
        expect(str, contains('true'));
      });
    });

    group('Use cases', () {
      test('creates family admin user', () {
        final admin = UserEntity.newUser(
          id: 'admin-123',
          name: 'ראש המשפחה',
          email: 'admin@family.com',
        );

        expect(admin.isAdmin, true);
        expect(admin.householdId, startsWith('house_'));
        expect(admin.preferredStores, isEmpty);
        expect(admin.weeklyBudget, 0.0);
      });

      test('creates family member (non-admin)', () {
        final member = UserEntity(
          id: 'member-456',
          name: 'בן משפחה',
          email: 'member@family.com',
          householdId: 'house-shared',
          joinedAt: DateTime.now(),
          isAdmin: false,
        );

        expect(member.isAdmin, false);
        expect(member.householdId, 'house-shared');
      });

      test('user with shopping preferences', () {
        final shopper = UserEntity(
          id: 'shopper-789',
          name: 'קונה מנוסה',
          email: 'shopper@example.com',
          householdId: 'house-shopping',
          joinedAt: DateTime.now().subtract(Duration(days: 365)),
          lastLoginAt: DateTime.now(),
          preferredStores: const ['רמי לוי', 'שופרסל', 'מחסני השוק'],
          favoriteProducts: const ['7290000000123', '7290000000456', '7290000000789'],
          weeklyBudget: 2500.0,
          isAdmin: true,
        );

        expect(shopper.preferredStores.length, 3);
        expect(shopper.favoriteProducts.length, 3);
        expect(shopper.weeklyBudget, 2500.0);
      });

      test('user budget management', () {
        final budgetUser = UserEntity(
          id: 'budget-user',
          name: 'מנהל תקציב',
          email: 'budget@example.com',
          householdId: 'house-budget',
          joinedAt: DateTime.now(),
          weeklyBudget: 1800.0,
        );

        // Calculate monthly budget
        final monthlyBudget = budgetUser.weeklyBudget * 4.33;
        expect(monthlyBudget, closeTo(7794.0, 1.0));

        // Check if user has budget set
        expect(budgetUser.weeklyBudget > 0, true);
      });

      test('user activity tracking', () {
        final now = DateTime.now();
        final activeUser = UserEntity(
          id: 'active-user',
          name: 'משתמש פעיל',
          email: 'active@example.com',
          householdId: 'house-active',
          joinedAt: now.subtract(Duration(days: 30)),
          lastLoginAt: now.subtract(Duration(hours: 2)),
        );

        // Check if user is recently active (within 24 hours)
        final isRecentlyActive = activeUser.lastLoginAt != null &&
            now.difference(activeUser.lastLoginAt!).inHours < 24;
        expect(isRecentlyActive, true);

        // Calculate days since joined
        final daysSinceJoined = now.difference(activeUser.joinedAt).inDays;
        expect(daysSinceJoined, 30);
      });
    });
  });
}
