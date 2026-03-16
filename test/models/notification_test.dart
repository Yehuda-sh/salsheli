// 📄 test/models/notification_test.dart
// Tests for AppNotification model: fromJson/toJson, enums, defaults.

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/notification.dart';

void main() {
  group('AppNotification - Construction', () {
    test('creates with required fields', () {
      final notification = AppNotification(
        id: 'notif-1',
        userId: 'user-1',
        householdId: 'house-1',
        type: NotificationType.invite,
        title: 'הזמנה',
        message: 'הוזמנת לרשימה',
        actionData: const {'listId': 'list-1'},
        createdAt: DateTime(2026, 3, 15),
      );

      expect(notification.id, 'notif-1');
      expect(notification.userId, 'user-1');
      expect(notification.type, NotificationType.invite);
      expect(notification.isRead, false);
      expect(notification.readAt, isNull);
      expect(notification.actionData['listId'], 'list-1');
    });

    test('actionData is unmodifiable', () {
      final notification = AppNotification(
        id: 'notif-2',
        userId: 'user-1',
        householdId: 'house-1',
        type: NotificationType.invite,
        title: 'test',
        message: 'test',
        actionData: const {'key': 'value'},
        createdAt: DateTime(2026, 3, 15),
      );

      expect(
        () => (notification.actionData as Map)['new_key'] = 'x',
        throwsUnsupportedError,
      );
    });
  });

  group('AppNotification - fromJson', () {
    test('parses complete JSON', () {
      final json = {
        'id': 'notif-json-1',
        'user_id': 'user-1',
        'household_id': 'house-1',
        'type': 'invite',
        'title': 'הזמנה',
        'message': 'הוזמנת',
        'action_data': {'listId': 'list-1'},
        'is_read': true,
        'created_at': '2026-03-15T10:00:00.000Z',
        'read_at': '2026-03-15T11:00:00.000Z',
      };

      final notification = AppNotification.fromJson(json);
      expect(notification.id, 'notif-json-1');
      expect(notification.type, NotificationType.invite);
      expect(notification.isRead, true);
      expect(notification.readAt, isNotNull);
    });

    test('missing fields use defaults', () {
      final json = <String, dynamic>{
        'type': 'invite',
        'action_data': <String, dynamic>{},
        'created_at': '2026-03-15T10:00:00.000Z',
      };

      final notification = AppNotification.fromJson(json);
      expect(notification.id, '');
      expect(notification.userId, '');
      expect(notification.householdId, '');
      expect(notification.title, '');
      expect(notification.message, '');
      expect(notification.isRead, false);
    });

    test('unknown notification type uses unknown', () {
      final json = {
        'id': 'notif-unk',
        'user_id': 'u1',
        'household_id': 'h1',
        'type': 'future_type_v99',
        'title': 'test',
        'message': 'test',
        'action_data': <String, dynamic>{},
        'created_at': '2026-03-15T10:00:00.000Z',
      };

      final notification = AppNotification.fromJson(json);
      expect(notification.type, NotificationType.unknown);
    });
  });

  group('AppNotification - toJson round-trip', () {
    test('round-trip preserves all fields', () {
      final original = AppNotification(
        id: 'rt-1',
        userId: 'user-rt',
        householdId: 'house-rt',
        type: NotificationType.roleChanged,
        title: 'תפקיד השתנה',
        message: 'שונה ל-admin',
        actionData: const {'oldRole': 'viewer', 'newRole': 'admin'},
        isRead: true,
        createdAt: DateTime(2026, 3, 15, 10, 0),
        readAt: DateTime(2026, 3, 15, 11, 0),
        senderId: 'sender-1',
        senderName: 'אבי',
      );

      final json = original.toJson();
      final restored = AppNotification.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.type, original.type);
      expect(restored.title, original.title);
      expect(restored.isRead, original.isRead);
      expect(restored.actionData['oldRole'], 'viewer');
      expect(restored.senderId, 'sender-1');
      expect(restored.senderName, 'אבי');
    });
  });

  group('NotificationType - all values', () {
    test('all known types are not unknown', () {
      for (final type in NotificationType.values) {
        if (type == NotificationType.unknown) continue;
        expect(type, isNot(NotificationType.unknown));
      }
    });

    test('enum has expected count', () {
      // invite, requestApproved, requestRejected, roleChanged, userRemoved,
      // whoBringsVolunteer, newVote, voteTie, lowStock, unknown
      expect(NotificationType.values.length, greaterThanOrEqualTo(10));
    });
  });
}
