// 📄 lib/services/analytics_service.dart
//
// שירות Analytics - מעקב אחר 3 אירועים מרכזיים בלבד:
// 1. create_list - יצירת רשימה חדשה
// 2. add_item - הוספת מוצר לרשימה
// 3. mark_purchased - סימון מוצר כנקנה
//
// 🔗 Related: FirebaseAnalytics, AppConfig

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:memozap/config/app_config.dart';

/// 📊 שירות Analytics - מעקב אחר אירועים מרכזיים
///
/// משתמש ב-Singleton pattern - גישה דרך [AnalyticsService.instance]
class AnalyticsService {
  // Singleton instance
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;

  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// 📋 אירוע: יצירת רשימה חדשה
  ///
  /// [listType] - סוג הרשימה (supermarket, pharmacy, etc.)
  /// [isShared] - האם הרשימה משותפת
  Future<void> logCreateList({
    required String listType,
    required bool isShared,
  }) async {
    if (!AppConfig.isProduction) return;

    await _analytics.logEvent(
      name: 'create_list',
      parameters: {
        'list_type': listType,
        'is_shared': isShared,
      },
    );
  }

  /// 🛒 אירוע: הוספת מוצר לרשימה
  ///
  /// [category] - קטגוריית המוצר
  /// [isFromCatalog] - האם המוצר נבחר מהקטלוג או נכתב ידנית
  Future<void> logAddItem({
    required String category,
    required bool isFromCatalog,
  }) async {
    if (!AppConfig.isProduction) return;

    await _analytics.logEvent(
      name: 'add_item',
      parameters: {
        'category': category,
        'is_from_catalog': isFromCatalog,
      },
    );
  }

  /// ✅ אירוע: סימון מוצר כנקנה
  ///
  /// [isCollaborative] - האם הקנייה בוצעה במצב שיתופי
  Future<void> logMarkPurchased({
    required bool isCollaborative,
  }) async {
    if (!AppConfig.isProduction) return;

    await _analytics.logEvent(
      name: 'mark_purchased',
      parameters: {
        'is_collaborative': isCollaborative,
      },
    );
  }
}
