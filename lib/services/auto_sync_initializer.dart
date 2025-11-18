// 📄 File: lib/services/auto_sync_initializer.dart
//
// 🚀 אתחול אוטומטי של סנכרון מחירים
//
// 🎯 תפקיד:
// - מאתחל סנכרון מחירים אוטומטי ברקע
// - נקרא פעם אחת ב-main.dart
// - רץ ברקע בלי לחסום את האפליקציה
//
// 📦 שימוש:
// ```dart
// // ב-main.dart:
// AutoSyncInitializer.initialize();
// ```

import 'package:flutter/foundation.dart';
import 'price_sync_service.dart';

class AutoSyncInitializer {
  static bool _initialized = false;

  /// 🚀 מאתחל סנכרון אוטומטי
  ///
  /// קורא ל-PriceSyncService.syncIfNeeded() ברקע
  /// לא חוסם את הפעלת האפליקציה
  static void initialize() {
    if (_initialized) {
      debugPrint('⚠️  AutoSyncInitializer: כבר אותחל');
      return;
    }

    _initialized = true;
    debugPrint('🚀 AutoSyncInitializer: מתחיל אתחול...');

    // רץ ברקע - לא חוסם את האפליקציה
    Future.microtask(() async {
      try {
        final syncService = PriceSyncService();
        final didSync = await syncService.syncIfNeeded();

        if (didSync) {
          debugPrint('✅ AutoSyncInitializer: סנכרון הושלם בהצלחה');
        } else {
          debugPrint('ℹ️  AutoSyncInitializer: אין צורך בסנכרון');
        }
      } catch (e) {
        debugPrint('❌ AutoSyncInitializer: שגיאה בסנכרון: $e');
        // לא עושים כלום - האפליקציה תמשיך לעבוד רגיל
      }
    });
  }

  /// 🔄 כפה סנכרון מיידי
  ///
  /// שימושי אם המשתמש לוחץ על כפתור "רענן"
  static Future<bool> forceSync() async {
    debugPrint('🔄 AutoSyncInitializer: סנכרון מאולץ...');

    try {
      final syncService = PriceSyncService();
      return await syncService.forceSync();
    } catch (e) {
      debugPrint('❌ AutoSyncInitializer: שגיאה בסנכרון מאולץ: $e');
      return false;
    }
  }

  /// 📅 מחזיר מתי היה הסנכרון האחרון
  static Future<DateTime?> getLastSyncTime() async {
    final syncService = PriceSyncService();
    return await syncService.getLastSyncTime();
  }
}
