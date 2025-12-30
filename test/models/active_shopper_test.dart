// 📄 File: test/models/active_shopper_test.dart
//
// 🧪 טסטים יחידתיים למודל ActiveShopper
// 🇬🇧 Unit tests for ActiveShopper model

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/active_shopper.dart';

void main() {
  group('ActiveShopper', () {
    // ===== Factory: starter =====
    group('starter factory', () {
      test('should create shopper with isStarter = true', () {
        final shopper = ActiveShopper.starter(userId: 'user-123');

        expect(shopper.userId, 'user-123');
        expect(shopper.isStarter, true);
        expect(shopper.isActive, true);
        expect(shopper.hasLeft, false);
      });

      test('should use provided DateTime when specified', () {
        final fixedTime = DateTime(2024, 1, 15, 10, 30);
        final shopper = ActiveShopper.starter(
          userId: 'user-123',
          now: fixedTime,
        );

        expect(shopper.joinedAt, fixedTime);
      });

      test('should use DateTime.now when not specified', () {
        final before = DateTime.now();
        final shopper = ActiveShopper.starter(userId: 'user-123');
        final after = DateTime.now();

        expect(shopper.joinedAt.isAfter(before.subtract(Duration(seconds: 1))), true);
        expect(shopper.joinedAt.isBefore(after.add(Duration(seconds: 1))), true);
      });
    });

    // ===== Factory: helper =====
    group('helper factory', () {
      test('should create shopper with isStarter = false', () {
        final shopper = ActiveShopper.helper(userId: 'user-456');

        expect(shopper.userId, 'user-456');
        expect(shopper.isStarter, false);
        expect(shopper.isActive, true);
        expect(shopper.hasLeft, false);
      });

      test('should use provided DateTime when specified', () {
        final fixedTime = DateTime(2024, 1, 15, 11, 45);
        final shopper = ActiveShopper.helper(
          userId: 'user-456',
          now: fixedTime,
        );

        expect(shopper.joinedAt, fixedTime);
      });
    });

    // ===== Helper Getter: hasLeft =====
    group('hasLeft getter', () {
      test('should return false when isActive is true', () {
        final shopper = ActiveShopper.starter(userId: 'user-123');

        expect(shopper.isActive, true);
        expect(shopper.hasLeft, false);
      });

      test('should return true when isActive is false', () {
        final shopper = ActiveShopper.starter(userId: 'user-123')
            .copyWith(isActive: false);

        expect(shopper.isActive, false);
        expect(shopper.hasLeft, true);
      });
    });

    // ===== copyWith =====
    group('copyWith', () {
      test('should create copy with updated userId', () {
        final original = ActiveShopper.starter(userId: 'user-123');
        final copy = original.copyWith(userId: 'user-999');

        expect(copy.userId, 'user-999');
        expect(copy.isStarter, original.isStarter);
        expect(copy.isActive, original.isActive);
      });

      test('should create copy with updated isActive', () {
        final original = ActiveShopper.starter(userId: 'user-123');
        final copy = original.copyWith(isActive: false);

        expect(copy.isActive, false);
        expect(copy.hasLeft, true);
        expect(copy.userId, original.userId);
      });

      test('should create copy with updated isStarter', () {
        final original = ActiveShopper.helper(userId: 'user-456');
        final copy = original.copyWith(isStarter: true);

        expect(copy.isStarter, true);
      });

      test('should create copy with updated joinedAt', () {
        final original = ActiveShopper.starter(userId: 'user-123');
        final newTime = DateTime(2025, 6, 1);
        final copy = original.copyWith(joinedAt: newTime);

        expect(copy.joinedAt, newTime);
      });

      test('should preserve all fields when no parameters given', () {
        final fixedTime = DateTime(2024, 5, 20, 14, 0);
        final original = ActiveShopper(
          userId: 'user-123',
          joinedAt: fixedTime,
          isStarter: true,
          isActive: true,
        );
        final copy = original.copyWith();

        expect(copy.userId, original.userId);
        expect(copy.joinedAt, original.joinedAt);
        expect(copy.isStarter, original.isStarter);
        expect(copy.isActive, original.isActive);
      });
    });

    // ===== JSON Serialization =====
    group('JSON serialization', () {
      test('toJson should serialize all fields correctly', () {
        final fixedTime = DateTime(2024, 3, 15, 9, 0, 0);
        final shopper = ActiveShopper(
          userId: 'user-123',
          joinedAt: fixedTime,
          isStarter: true,
          isActive: true,
        );

        final json = shopper.toJson();

        expect(json['user_id'], 'user-123');
        expect(json['is_starter'], true);
        expect(json['is_active'], true);
        // joined_at is converted to Timestamp by TimestampConverter
        expect(json['joined_at'], isA<Timestamp>());
      });

      test('fromJson should deserialize from Timestamp', () {
        final timestamp = Timestamp.fromDate(DateTime(2024, 3, 15, 9, 0, 0));
        final json = {
          'user_id': 'user-456',
          'joined_at': timestamp,
          'is_starter': false,
          'is_active': true,
        };

        final shopper = ActiveShopper.fromJson(json);

        expect(shopper.userId, 'user-456');
        expect(shopper.joinedAt, timestamp.toDate());
        expect(shopper.isStarter, false);
        expect(shopper.isActive, true);
      });

      test('fromJson should use default values when fields missing', () {
        final timestamp = Timestamp.fromDate(DateTime(2024, 3, 15, 9, 0, 0));
        final json = {
          'user_id': 'user-789',
          'joined_at': timestamp,
          // is_starter and is_active missing - should use defaults
        };

        final shopper = ActiveShopper.fromJson(json);

        expect(shopper.isStarter, false); // defaultValue: false
        expect(shopper.isActive, true); // defaultValue: true
      });

      test('round-trip serialization should preserve data', () {
        final original = ActiveShopper.starter(
          userId: 'user-123',
          now: DateTime(2024, 7, 4, 12, 0, 0),
        );

        final json = original.toJson();
        final restored = ActiveShopper.fromJson(json);

        expect(restored.userId, original.userId);
        expect(restored.joinedAt, original.joinedAt);
        expect(restored.isStarter, original.isStarter);
        expect(restored.isActive, original.isActive);
      });
    });

    // ===== Equality & HashCode =====
    group('equality and hashCode', () {
      test('identical shoppers should be equal', () {
        final fixedTime = DateTime(2024, 1, 1, 12, 0);
        final shopper1 = ActiveShopper(
          userId: 'user-123',
          joinedAt: fixedTime,
          isStarter: true,
          isActive: true,
        );
        final shopper2 = ActiveShopper(
          userId: 'user-123',
          joinedAt: fixedTime,
          isStarter: true,
          isActive: true,
        );

        expect(shopper1 == shopper2, true);
        expect(shopper1.hashCode, shopper2.hashCode);
      });

      test('shoppers with different userId should not be equal', () {
        final fixedTime = DateTime(2024, 1, 1, 12, 0);
        final shopper1 = ActiveShopper(
          userId: 'user-123',
          joinedAt: fixedTime,
          isStarter: true,
          isActive: true,
        );
        final shopper2 = ActiveShopper(
          userId: 'user-456',
          joinedAt: fixedTime,
          isStarter: true,
          isActive: true,
        );

        expect(shopper1 == shopper2, false);
      });

      test('shoppers with different isActive should not be equal', () {
        final fixedTime = DateTime(2024, 1, 1, 12, 0);
        final shopper1 = ActiveShopper(
          userId: 'user-123',
          joinedAt: fixedTime,
          isStarter: true,
          isActive: true,
        );
        final shopper2 = ActiveShopper(
          userId: 'user-123',
          joinedAt: fixedTime,
          isStarter: true,
          isActive: false,
        );

        expect(shopper1 == shopper2, false);
      });

      test('identical check should return true for same instance', () {
        final shopper = ActiveShopper.starter(userId: 'user-123');

        expect(shopper == shopper, true);
      });
    });

    // ===== toString =====
    group('toString', () {
      test('should include userId, isStarter, and isActive', () {
        final shopper = ActiveShopper.starter(userId: 'user-123');

        final str = shopper.toString();

        expect(str.contains('user-123'), true);
        expect(str.contains('isStarter: true'), true);
        expect(str.contains('isActive: true'), true);
      });
    });
  });
}
