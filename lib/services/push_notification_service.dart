// 📄 lib/services/push_notification_service.dart
//
// שירות Push Notifications — ניהול FCM token ואתחול Firebase Messaging.
// - שומר token ב-Firestore (users/{uid}/fcm_token)
// - מאזין לעדכוני token
// - מבקש הרשאות
//
// 🔗 Related: NotificationsService (in-app), Cloud Functions (trigger)

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// שירות Push Notifications
///
/// אתחול:
/// ```dart
/// await PushNotificationService.instance.initialize(userId);
/// ```
class PushNotificationService {
  static final PushNotificationService instance = PushNotificationService._();
  PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<String>? _tokenSub;
  String? _currentUserId;

  /// אתחול — מבקש הרשאות, שומר token, מאזין לרענונים
  Future<void> initialize(String userId) async {
    _currentUserId = userId;

    // בקשת הרשאות (iOS דורש, Android 13+ דורש)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) debugPrint('🔕 Push notifications denied by user');
      return;
    }

    // שמירת token ראשוני
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(userId, token);
    }

    // האזנה לרענוני token (Google עשוי לרענן token)
    _tokenSub?.cancel();
    _tokenSub = _messaging.onTokenRefresh.listen(
      (newToken) => unawaited(_saveToken(userId, newToken)),
      onError: (e) {
        if (kDebugMode) debugPrint('⚠️ FCM token refresh error: $e');
      },
    );

    if (kDebugMode) debugPrint('🔔 Push notifications initialized for $userId');
  }

  /// שמירת FCM token ב-Firestore
  Future<void> _saveToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcm_token': token,
        'fcm_token_updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to save FCM token: $e');
    }
  }

  /// ניקוי token בהתנתקות
  Future<void> clearToken() async {
    if (_currentUserId != null) {
      try {
        await _firestore.collection('users').doc(_currentUserId).update({
          'fcm_token': FieldValue.delete(),
        });
      } catch (_) {}
    }
    _tokenSub?.cancel();
    _tokenSub = null;
    _currentUserId = null;
  }

  /// ביטול האזנה
  void dispose() {
    _tokenSub?.cancel();
  }
}
