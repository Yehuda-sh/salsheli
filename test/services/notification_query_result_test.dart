// 📄 test/services/notification_query_result_test.dart
// Tests for NotificationQueryResult typed result.

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/notification.dart';
import 'package:memozap/services/notifications_service.dart';

void main() {
  AppNotification _makeNotification(String id) => AppNotification(
        id: id,
        userId: 'user-1',
        householdId: 'house-1',
        type: NotificationType.invite,
        title: 'Test',
        message: 'Test message',
        actionData: const {},
        createdAt: DateTime(2026, 3, 15),
      );

  group('NotificationQueryResult.success', () {
    test('with items → type is success', () {
      final result = NotificationQueryResult.success([
        _makeNotification('n1'),
        _makeNotification('n2'),
      ]);
      expect(result.type, NotificationQueryResultType.success);
      expect(result.isSuccess, true);
      expect(result.hasNotifications, true);
      expect(result.count, 2);
      expect(result.notifications!.length, 2);
      expect(result.errorMessage, isNull);
    });

    test('with empty list → type is empty', () {
      final result = NotificationQueryResult.success([]);
      expect(result.type, NotificationQueryResultType.empty);
      expect(result.isSuccess, true);
      expect(result.hasNotifications, false);
      expect(result.count, 0);
    });
  });


  group('NotificationQueryResult.error', () {
    test('has error message', () {
      final result = NotificationQueryResult.error('Firestore unavailable');
      expect(result.type, NotificationQueryResultType.error);
      expect(result.isSuccess, false);
      expect(result.hasNotifications, false);
      expect(result.errorMessage, 'Firestore unavailable');
      expect(result.notifications, isNull);
      expect(result.count, isNull);
    });
  });
}
