// 📄 File: lib/providers/notifications_provider.dart
//
// 🇮🇱 קובץ זה מנהל את מצב ההתראות באפליקציה:
//     - מספר תובנות שלא נקראו (unread insights).
//     - סימון תובנות כנקראו.
//     - התראות נוספות יוכלו להתווסף כאן בעתיד.
//
// 🇬🇧 This file manages notification state in the app:
//     - Tracks the number of unread insights.
//     - Provides methods to mark insights as read.
//     - Can be extended for additional notification types.
//

import 'package:flutter/foundation.dart';

/// Provider לניהול מצב התראות באפליקציה.
/// Handles unread insights count and notification state.
class NotificationsProvider extends ChangeNotifier {
  int _unreadInsightsCount = 0;

  /// מספר התובנות שלא נקראו
  int get unreadInsightsCount => _unreadInsightsCount;

  /// קובע את מספר התובנות שלא נקראו
  void setUnreadInsights(int count) {
    _unreadInsightsCount = count;
    notifyListeners();
  }

  /// מסמן את כל התובנות כנקראו
  void markInsightsAsRead() {
    _unreadInsightsCount = 0;
    notifyListeners();
  }
}
