// 📄 lib/services/analytics_service.dart
//
// שירות Analytics - מעקב אחר 3 אירועים מרכזיים בלבד:
// 1. create_list - יצירת רשימה חדשה
// 2. add_item - הוספת מוצר לרשימה
// 3. mark_purchased - סימון מוצר כנקנה
//
// 🔗 Related: FirebaseAnalytics, AppConfig

import 'package:firebase_analytics/firebase_analytics.dart';

import '../config/app_config.dart';

/// 📊 שירות Analytics - מעקב אחר אירועים מרכזיים
///
/// משתמש ב-Singleton pattern - גישה דרך [AnalyticsService.instance]
/// כל הקריאות הן fire-and-forget — שגיאות נבלעות בשקט
/// כי analytics לעולם לא צריך לקרוס את האפליקציה.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;

  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// 📋 אירוע: יצירת רשימה חדשה
  Future<void> logCreateList({
    required String listType,
    required bool isShared,
  }) => _log('create_list', {'list_type': listType, 'is_shared': isShared});

  /// 🛒 אירוע: הוספת מוצר לרשימה
  Future<void> logAddItem({
    required String category,
    required bool isFromCatalog,
  }) => _log('add_item', {'category': category, 'is_from_catalog': isFromCatalog});

  /// ✅ אירוע: סימון מוצר כנקנה
  Future<void> logMarkPurchased({
    required bool isCollaborative,
  }) => _log('mark_purchased', {'is_collaborative': isCollaborative});

  /// שולח אירוע ל-Firebase Analytics.
  /// שגיאות נבלעות בשקט — analytics הוא non-critical.
  Future<void> _log(String name, Map<String, Object> parameters) async {
    if (!AppConfig.isProduction) return;
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Analytics should never crash the app
    }
  }
}
