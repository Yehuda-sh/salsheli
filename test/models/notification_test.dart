// 📄 test/models/notification_test.dart
// Tests for AppNotification model: fromJson/toJson, enums, defaults.

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/core/status_colors.dart';
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

    test('enum has 11 values', () {
      expect(NotificationType.values.length, 11);
    });
  });

  // ===== isUnread =====
  group('AppNotification - isUnread', () {
    test('isUnread true when not read', () {
      final n = AppNotification(
        id: 'n1', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.isUnread, true);
    });

    test('isUnread false when read', () {
      final n = AppNotification(
        id: 'n2', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {}, isRead: true, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.isUnread, false);
    });
  });

  // ===== actionData Getters =====
  group('AppNotification - actionData getters', () {
    test('listId from camelCase', () {
      final n = AppNotification(
        id: 'ad-1', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {'listId': 'list-123'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.listId, 'list-123');
    });

    test('listId from snake_case', () {
      final n = AppNotification(
        id: 'ad-2', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {'list_id': 'list-456'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.listId, 'list-456');
    });

    test('requestId getter', () {
      final n = AppNotification(
        id: 'ad-3', userId: 'u1', householdId: 'h1',
        type: NotificationType.requestApproved, title: 't', message: 'm',
        actionData: const {'request_id': 'req-1'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.requestId, 'req-1');
    });

    test('listName getter', () {
      final n = AppNotification(
        id: 'ad-4', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {'list_name': 'קניות שבועיות'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.listName, 'קניות שבועיות');
    });

    test('productId and productName getters', () {
      final n = AppNotification(
        id: 'ad-5', userId: 'u1', householdId: 'h1',
        type: NotificationType.lowStock, title: 't', message: 'm',
        actionData: const {'product_id': 'prod-1', 'product_name': 'חלב'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.productId, 'prod-1');
      expect(n.productName, 'חלב');
    });

    test('volunteerName getter', () {
      final n = AppNotification(
        id: 'ad-6', userId: 'u1', householdId: 'h1',
        type: NotificationType.whoBringsVolunteer, title: 't', message: 'm',
        actionData: const {'volunteer_name': 'אבי'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.volunteerName, 'אבי');
    });

    test('reason getter', () {
      final n = AppNotification(
        id: 'ad-7', userId: 'u1', householdId: 'h1',
        type: NotificationType.userRemoved, title: 't', message: 'm',
        actionData: const {'reason': 'הוסר על ידי אדמין'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.reason, 'הוסר על ידי אדמין');
    });

    test('getters return null when data missing', () {
      final n = AppNotification(
        id: 'ad-8', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.listId, isNull);
      expect(n.requestId, isNull);
      expect(n.productId, isNull);
      expect(n.volunteerName, isNull);
    });
  });

  // ===== canNavigate =====
  group('AppNotification - canNavigate', () {
    test('invite with listId can navigate', () {
      final n = AppNotification(
        id: 'nav-1', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {'listId': 'list-1'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.canNavigate, true);
    });

    test('invite without listId cannot navigate', () {
      final n = AppNotification(
        id: 'nav-2', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.canNavigate, false);
    });

    test('lowStock with productId can navigate', () {
      final n = AppNotification(
        id: 'nav-3', userId: 'u1', householdId: 'h1',
        type: NotificationType.lowStock, title: 't', message: 'm',
        actionData: const {'product_id': 'prod-1'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.canNavigate, true);
    });

    test('userRemoved cannot navigate', () {
      final n = AppNotification(
        id: 'nav-4', userId: 'u1', householdId: 'h1',
        type: NotificationType.userRemoved, title: 't', message: 'm',
        actionData: const {'listId': 'list-1'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.canNavigate, false);
    });

    test('unknown cannot navigate', () {
      final n = AppNotification(
        id: 'nav-5', userId: 'u1', householdId: 'h1',
        type: NotificationType.unknown, title: 't', message: 'm',
        actionData: const {'listId': 'list-1'},
        createdAt: DateTime(2026, 3, 15),
      );
      expect(n.canNavigate, false);
    });
  });

  // ===== Priority =====
  group('AppNotification - priority', () {
    test('userRemoved is urgent', () {
      final n = AppNotification(
        id: 'p-1', userId: 'u1', householdId: 'h1',
        type: NotificationType.userRemoved, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.priority, NotificationPriority.urgent);
      expect(n.priority.isUrgent, true);
      expect(n.priority.isImportant, true);
    });

    test('invite is high', () {
      final n = AppNotification(
        id: 'p-2', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.priority, NotificationPriority.high);
      expect(n.priority.isUrgent, false);
      expect(n.priority.isImportant, true);
    });

    test('requestApproved is normal', () {
      final n = AppNotification(
        id: 'p-3', userId: 'u1', householdId: 'h1',
        type: NotificationType.requestApproved, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.priority, NotificationPriority.normal);
      expect(n.priority.isImportant, false);
    });

    test('memberLeft is low', () {
      final n = AppNotification(
        id: 'p-4', userId: 'u1', householdId: 'h1',
        type: NotificationType.memberLeft, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.priority, NotificationPriority.low);
    });
  });

  // ===== Haptic =====
  group('AppNotification - recommendedHaptic', () {
    test('urgent → heavy', () {
      final n = AppNotification(
        id: 'h-1', userId: 'u1', householdId: 'h1',
        type: NotificationType.userRemoved, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.recommendedHaptic, 'heavy');
    });

    test('high → medium', () {
      final n = AppNotification(
        id: 'h-2', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.recommendedHaptic, 'medium');
    });

    test('normal → light', () {
      final n = AppNotification(
        id: 'h-3', userId: 'u1', householdId: 'h1',
        type: NotificationType.newVote, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.recommendedHaptic, 'light');
    });

    test('low → selection', () {
      final n = AppNotification(
        id: 'h-4', userId: 'u1', householdId: 'h1',
        type: NotificationType.memberLeft, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.recommendedHaptic, 'selection');
    });
  });

  // ===== StatusType =====
  group('AppNotification - statusType', () {
    test('userRemoved → error', () {
      final n = AppNotification(
        id: 'st-1', userId: 'u1', householdId: 'h1',
        type: NotificationType.userRemoved, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.statusType, StatusType.error);
    });

    test('lowStock → warning', () {
      final n = AppNotification(
        id: 'st-2', userId: 'u1', householdId: 'h1',
        type: NotificationType.lowStock, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.statusType, StatusType.warning);
    });

    test('requestApproved → success', () {
      final n = AppNotification(
        id: 'st-3', userId: 'u1', householdId: 'h1',
        type: NotificationType.requestApproved, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.statusType, StatusType.success);
    });

    test('invite → info', () {
      final n = AppNotification(
        id: 'st-4', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
      );
      expect(n.statusType, StatusType.info);
    });
  });

  // ===== NotificationTypeExtension =====
  group('NotificationTypeExtension', () {
    test('every type has emoji', () {
      for (final type in NotificationType.values) {
        expect(type.emoji, isNotEmpty);
      }
    });

    test('every type has hebrewName', () {
      for (final type in NotificationType.values) {
        expect(type.hebrewName, isNotEmpty);
      }
    });

    test('isKnown true for invite', () {
      expect(NotificationType.invite.isKnown, true);
    });

    test('isKnown false for unknown', () {
      expect(NotificationType.unknown.isKnown, false);
    });

    test('statusType mapping covers all types', () {
      for (final type in NotificationType.values) {
        expect(type.statusType, isNotNull);
      }
    });
  });

  // ===== copyWith sentinel pattern =====
  group('AppNotification - copyWith sentinel', () {
    test('can clear readAt to null', () {
      final n = AppNotification(
        id: 'cw-1', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
        readAt: DateTime(2026, 3, 16),
      );
      final cleared = n.copyWith(readAt: null);
      expect(cleared.readAt, isNull);
    });

    test('can clear senderId to null', () {
      final n = AppNotification(
        id: 'cw-2', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
        senderId: 'sender-1',
      );
      final cleared = n.copyWith(senderId: null);
      expect(cleared.senderId, isNull);
    });

    test('preserves readAt when not passed', () {
      final readAt = DateTime(2026, 3, 16);
      final n = AppNotification(
        id: 'cw-3', userId: 'u1', householdId: 'h1',
        type: NotificationType.invite, title: 't', message: 'm',
        actionData: const {}, createdAt: DateTime(2026, 3, 15),
        readAt: readAt,
      );
      final copy = n.copyWith(title: 'updated');
      expect(copy.readAt, readAt);
    });
  });
}
