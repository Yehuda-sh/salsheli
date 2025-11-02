import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/active_shopper.dart';

void main() {
  group('ActiveShopper', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 11, 2, 14, 30);
    });

    group('Constructors', () {
      test('creates with all required fields', () {
        final shopper = ActiveShopper(
          userId: 'user-123',
          joinedAt: testDate,
          isStarter: true,
        );

        expect(shopper.userId, 'user-123');
        expect(shopper.joinedAt, testDate);
        expect(shopper.isStarter, true);
        expect(shopper.isActive, true); // default
      });

      test('creates with explicit isActive', () {
        final shopper = ActiveShopper(
          userId: 'user-456',
          joinedAt: testDate,
          isStarter: false,
          isActive: false,
        );

        expect(shopper.userId, 'user-456');
        expect(shopper.isActive, false);
      });

      test('starter factory creates starter shopper', () {
        final starter = ActiveShopper.starter(
          userId: 'starter-789',
          now: testDate,
        );

        expect(starter.userId, 'starter-789');
        expect(starter.joinedAt, testDate);
        expect(starter.isStarter, true);
        expect(starter.isActive, true);
      });

      test('starter factory uses current time when now not provided', () {
        final before = DateTime.now();
        final starter = ActiveShopper.starter(userId: 'starter-auto');
        final after = DateTime.now();

        expect(starter.userId, 'starter-auto');
        expect(starter.isStarter, true);
        expect(starter.isActive, true);
        expect(starter.joinedAt.isAfter(before.subtract(Duration(seconds: 1))), true);
        expect(starter.joinedAt.isBefore(after.add(Duration(seconds: 1))), true);
      });

      test('helper factory creates helper shopper', () {
        final helper = ActiveShopper.helper(
          userId: 'helper-012',
          now: testDate,
        );

        expect(helper.userId, 'helper-012');
        expect(helper.joinedAt, testDate);
        expect(helper.isStarter, false);
        expect(helper.isActive, true);
      });

      test('helper factory uses current time when now not provided', () {
        final before = DateTime.now();
        final helper = ActiveShopper.helper(userId: 'helper-auto');
        final after = DateTime.now();

        expect(helper.userId, 'helper-auto');
        expect(helper.isStarter, false);
        expect(helper.isActive, true);
        expect(helper.joinedAt.isAfter(before.subtract(Duration(seconds: 1))), true);
        expect(helper.joinedAt.isBefore(after.add(Duration(seconds: 1))), true);
      });
    });

    group('copyWith', () {
      test('updates only specified fields', () {
        final original = ActiveShopper(
          userId: 'user-original',
          joinedAt: testDate,
          isStarter: true,
          isActive: true,
        );

        final updated = original.copyWith(
          isActive: false,
        );

        expect(updated.isActive, false);
        // Unchanged fields
        expect(updated.userId, original.userId);
        expect(updated.joinedAt, original.joinedAt);
        expect(updated.isStarter, original.isStarter);
      });

      test('can update all fields', () {
        final newDate = testDate.add(Duration(hours: 2));
        final original = ActiveShopper(
          userId: 'user-all',
          joinedAt: testDate,
          isStarter: true,
          isActive: true,
        );

        final updated = original.copyWith(
          userId: 'user-new',
          joinedAt: newDate,
          isStarter: false,
          isActive: false,
        );

        expect(updated.userId, 'user-new');
        expect(updated.joinedAt, newDate);
        expect(updated.isStarter, false);
        expect(updated.isActive, false);
      });

      test('returns new instance with same values when no updates', () {
        final original = ActiveShopper(
          userId: 'user-same',
          joinedAt: testDate,
          isStarter: true,
        );

        final updated = original.copyWith();

        expect(updated.userId, original.userId);
        expect(updated.joinedAt, original.joinedAt);
        expect(updated.isStarter, original.isStarter);
        expect(updated.isActive, original.isActive);
        expect(identical(updated, original), false); // Different instance
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly', () {
        final original = ActiveShopper(
          userId: 'user-json-test',
          joinedAt: testDate,
          isStarter: true,
          isActive: false,
        );

        final json = original.toJson();
        final restored = ActiveShopper.fromJson(json);

        expect(restored.userId, original.userId);
        expect(restored.joinedAt, original.joinedAt);
        expect(restored.isStarter, original.isStarter);
        expect(restored.isActive, original.isActive);
      });

      test('JSON structure uses snake_case', () {
        final shopper = ActiveShopper(
          userId: 'user-case-test',
          joinedAt: testDate,
          isStarter: true,
          isActive: false,
        );

        final json = shopper.toJson();

        expect(json.containsKey('user_id'), true);
        expect(json.containsKey('joined_at'), true);
        expect(json.containsKey('is_starter'), true);
        expect(json.containsKey('is_active'), true);
      });

      test('fromJson handles default values', () {
        final json = {
          'user_id': 'user-defaults',
          'joined_at': testDate.toIso8601String(),
          // is_starter and is_active missing
        };

        final shopper = ActiveShopper.fromJson(json);

        expect(shopper.userId, 'user-defaults');
        expect(shopper.joinedAt, testDate);
        expect(shopper.isStarter, false); // default
        expect(shopper.isActive, true); // default
      });

      test('roundtrip serialization preserves data', () {
        final original = ActiveShopper.helper(
          userId: 'roundtrip-user',
          now: testDate,
        );

        final json = original.toJson();
        final restored = ActiveShopper.fromJson(json);
        final jsonAgain = restored.toJson();

        expect(jsonAgain, equals(json));
      });
    });

    group('Equality and hashCode', () {
      test('two shoppers with same values are equal', () {
        final shopper1 = ActiveShopper(
          userId: 'user-equal',
          joinedAt: testDate,
          isStarter: true,
          isActive: true,
        );

        final shopper2 = ActiveShopper(
          userId: 'user-equal',
          joinedAt: testDate,
          isStarter: true,
          isActive: true,
        );

        expect(shopper1, equals(shopper2));
        expect(shopper1.hashCode, equals(shopper2.hashCode));
      });

      test('shoppers with different userId are not equal', () {
        final shopper1 = ActiveShopper(
          userId: 'user-1',
          joinedAt: testDate,
          isStarter: true,
        );

        final shopper2 = ActiveShopper(
          userId: 'user-2',
          joinedAt: testDate,
          isStarter: true,
        );

        expect(shopper1, isNot(equals(shopper2)));
      });

      test('shoppers with different isStarter are not equal', () {
        final shopper1 = ActiveShopper(
          userId: 'user-same',
          joinedAt: testDate,
          isStarter: true,
        );

        final shopper2 = ActiveShopper(
          userId: 'user-same',
          joinedAt: testDate,
          isStarter: false,
        );

        expect(shopper1, isNot(equals(shopper2)));
      });

      test('shoppers with different isActive are not equal', () {
        final shopper1 = ActiveShopper(
          userId: 'user-same',
          joinedAt: testDate,
          isStarter: true,
          isActive: true,
        );

        final shopper2 = ActiveShopper(
          userId: 'user-same',
          joinedAt: testDate,
          isStarter: true,
          isActive: false,
        );

        expect(shopper1, isNot(equals(shopper2)));
      });

      test('identical shoppers return true', () {
        final shopper = ActiveShopper.starter(
          userId: 'user-identical',
          now: testDate,
        );

        expect(identical(shopper, shopper), true);
        expect(shopper == shopper, true);
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        final shopper = ActiveShopper(
          userId: 'user-toString',
          joinedAt: testDate,
          isStarter: true,
          isActive: false,
        );

        final str = shopper.toString();

        expect(str, contains('ActiveShopper'));
        expect(str, contains('user-toString'));
        expect(str, contains('true')); // isStarter
        expect(str, contains('false')); // isActive
      });

      test('different shoppers have different string representations', () {
        final starter = ActiveShopper.starter(userId: 'starter-str', now: testDate);
        final helper = ActiveShopper.helper(userId: 'helper-str', now: testDate);

        expect(starter.toString(), isNot(equals(helper.toString())));
      });
    });

    group('Use cases', () {
      test('starter begins shopping session', () {
        final starter = ActiveShopper.starter(
          userId: 'dad-123',
          now: testDate,
        );

        expect(starter.isStarter, true);
        expect(starter.isActive, true);
        expect(starter.joinedAt, testDate);
      });

      test('helper joins shopping session', () {
        final helper = ActiveShopper.helper(
          userId: 'mom-456',
          now: testDate.add(Duration(minutes: 5)),
        );

        expect(helper.isStarter, false);
        expect(helper.isActive, true);
        expect(helper.joinedAt, testDate.add(Duration(minutes: 5)));
      });

      test('shopper leaves session', () {
        final active = ActiveShopper.helper(
          userId: 'son-789',
          now: testDate,
        );

        final left = active.copyWith(isActive: false);

        expect(left.userId, active.userId);
        expect(left.isActive, false);
        expect(left.isStarter, active.isStarter);
      });

      test('shopping timeline tracking', () {
        final startTime = testDate;
        final joinTime = testDate.add(Duration(minutes: 10));
        final leaveTime = testDate.add(Duration(minutes: 25));

        final starter = ActiveShopper.starter(userId: 'user-1', now: startTime);
        final helper = ActiveShopper.helper(userId: 'user-2', now: joinTime);
        final helperLeft = helper.copyWith(isActive: false);

        // Calculate durations
        final starterDuration = leaveTime.difference(starter.joinedAt);
        final helperDuration = leaveTime.difference(helper.joinedAt);

        expect(starterDuration.inMinutes, 25);
        expect(helperDuration.inMinutes, 15);
        expect(helperLeft.isActive, false);
      });

      test('multiple helpers scenario', () {
        final shoppers = [
          ActiveShopper.starter(userId: 'dad', now: testDate),
          ActiveShopper.helper(userId: 'mom', now: testDate.add(Duration(minutes: 5))),
          ActiveShopper.helper(userId: 'son', now: testDate.add(Duration(minutes: 10))),
        ];

        expect(shoppers.where((s) => s.isStarter).length, 1);
        expect(shoppers.where((s) => !s.isStarter).length, 2);
        expect(shoppers.where((s) => s.isActive).length, 3);
      });

      test('power transfer when starter leaves', () {
        final starter = ActiveShopper.starter(userId: 'original-starter', now: testDate);
        final helper = ActiveShopper.helper(userId: 'new-starter', now: testDate);

        // Starter leaves
        final starterLeft = starter.copyWith(isActive: false);

        // Helper becomes starter
        final newStarter = helper.copyWith(isStarter: true);

        expect(starterLeft.isActive, false);
        expect(starterLeft.isStarter, true); // Still marked as original starter
        expect(newStarter.isStarter, true);
        expect(newStarter.isActive, true);
      });
    });
  });
}
