import 'package:flutter_test/flutter_test.dart';
import 'package:salsheli/models/custom_location.dart';

void main() {
  group('CustomLocation', () {
    test('creates with required fields and default emoji', () {
      const location = CustomLocation(
        key: 'pantry_top_shelf',
        name: 'מדף עליון במזווה',
      );

      expect(location.key, 'pantry_top_shelf');
      expect(location.name, 'מדף עליון במזווה');
      expect(location.emoji, '📍');  // Default emoji
    });

    test('creates with custom emoji', () {
      const location = CustomLocation(
        key: 'freezer_drawer_1',
        name: 'מגירה 1 במקפיא',
        emoji: '🧊',
      );

      expect(location.key, 'freezer_drawer_1');
      expect(location.name, 'מגירה 1 במקפיא');
      expect(location.emoji, '🧊');
    });

    group('copyWith', () {
      test('updates only specified fields', () {
        const original = CustomLocation(
          key: 'original_key',
          name: 'שם מקורי',
          emoji: '📦',
        );

        final updated = original.copyWith(
          name: 'שם חדש',
          emoji: '📍',
        );

        expect(updated.name, 'שם חדש');
        expect(updated.emoji, '📍');
        expect(updated.key, original.key);
      });

      test('can update key', () {
        const original = CustomLocation(
          key: 'old_key',
          name: 'מיקום',
          emoji: '📦',
        );

        final updated = original.copyWith(
          key: 'new_key',
        );

        expect(updated.key, 'new_key');
        expect(updated.name, original.name);
        expect(updated.emoji, original.emoji);
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly', () {
        const original = CustomLocation(
          key: 'test_location',
          name: 'מיקום בדיקה',
          emoji: '🎯',
        );

        final json = original.toJson();
        final restored = CustomLocation.fromJson(json);

        expect(restored.key, original.key);
        expect(restored.name, original.name);
        expect(restored.emoji, original.emoji);
      });

      test('JSON structure is correct', () {
        const location = CustomLocation(
          key: 'cabinet_3',
          name: 'ארון 3',
          emoji: '🚪',
        );

        final json = location.toJson();

        expect(json['key'], 'cabinet_3');
        expect(json['name'], 'ארון 3');
        expect(json['emoji'], '🚪');
        expect(json.keys.length, 3);
      });

      test('handles missing emoji in JSON', () {
        final json = {
          'key': 'no_emoji_location',
          'name': 'מיקום ללא אמוג\'י',
          // emoji field missing
        };

        final location = CustomLocation.fromJson(json);

        expect(location.key, 'no_emoji_location');
        expect(location.name, 'מיקום ללא אמוג\'י');
        expect(location.emoji, '📍');  // Should use default
      });
    });

    group('Equality and HashCode', () {
      test('equality is based on key only', () {
        const location1 = CustomLocation(
          key: 'same_key',
          name: 'שם 1',
          emoji: '📦',
        );

        const location2 = CustomLocation(
          key: 'same_key',
          name: 'שם 2',
          emoji: '📍',
        );

        const location3 = CustomLocation(
          key: 'different_key',
          name: 'שם 1',
          emoji: '📦',
        );

        expect(location1 == location2, true);
        expect(location1 == location3, false);
        expect(location1.hashCode, location2.hashCode);
        expect(location1.hashCode, isNot(location3.hashCode));
      });

      test('identical instances are equal', () {
        const location = CustomLocation(
          key: 'test',
          name: 'בדיקה',
        );

        expect(location == location, true);
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        const location = CustomLocation(
          key: 'kitchen_drawer_2',
          name: 'מגירה 2 במטבח',
          emoji: '🍴',
        );

        final str = location.toString();

        expect(str, contains('kitchen_drawer_2'));
        expect(str, contains('מגירה 2 במטבח'));
        expect(str, contains('🍴'));
      });
    });

    group('Common use cases', () {
      test('creates typical kitchen location', () {
        const kitchen = CustomLocation(
          key: 'kitchen_top_cabinet',
          name: 'ארון עליון במטבח',
          emoji: '🍳',
        );

        expect(kitchen.key, contains('kitchen'));
        expect(kitchen.name, contains('מטבח'));
        expect(kitchen.emoji, '🍳');
      });

      test('creates typical storage room location', () {
        const storage = CustomLocation(
          key: 'storage_room_shelf_3',
          name: 'מדף 3 במחסן',
          emoji: '📦',
        );

        expect(storage.key, contains('storage'));
        expect(storage.name, contains('מחסן'));
        expect(storage.emoji, '📦');
      });

      test('creates typical bathroom location', () {
        const bathroom = CustomLocation(
          key: 'bathroom_cabinet',
          name: 'ארונית באמבטיה',
          emoji: '🚿',
        );

        expect(bathroom.key, contains('bathroom'));
        expect(bathroom.name, contains('אמבטיה'));
        expect(bathroom.emoji, '🚿');
      });
    });
  });
}
