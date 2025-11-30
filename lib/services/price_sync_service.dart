// 📄 File: lib/services/price_sync_service.dart
//
// 🔄 שירות סנכרון מחירים אוטומטי ברקע
//
// 🎯 תפקיד:
// - מעדכן מחירים מ-Shufersal ברקע
// - מוסיף מוצרים חדשים
// - שומר ב-SharedPreferences (cache מקומי)
// - רץ פעם ביום (לא בכל כניסה)
//
// 🚀 שימוש:
// ```dart
// final syncService = PriceSyncService();
// await syncService.syncIfNeeded(); // רק אם עבר יום
// ```
//
// 📦 מבנה נתונים:
// - assets/data/list_types/*.json - מוצרים בסיסיים (read-only)
// - SharedPreferences - מחירים מעודכנים + מוצרים חדשים
// - ProductsProvider - ממזג את שני המקורות

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PriceSyncService {
  static const String _lastSyncKey = 'last_price_sync';
  static const String _syncDataPrefix = 'sync_data_';
  static const String _shufersalApiUrl = 'https://api.shufersal.co.il/prices'; // דוגמה

  // מרווח זמן בין סנכרונים (24 שעות)
  static const Duration _syncInterval = Duration(hours: 24);

  /// 🔄 מבצע סנכרון אם צריך (עבר יום מהסנכרון האחרון)
  Future<bool> syncIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_lastSyncKey);

      if (lastSyncStr != null) {
        final lastSync = DateTime.parse(lastSyncStr);
        final now = DateTime.now();

        if (now.difference(lastSync) < _syncInterval) {
          debugPrint('⏭️  PriceSyncService: סנכרון לא נדרש (עבר ${now.difference(lastSync).inHours} שעות)');
          return false;
        }
      }

      debugPrint('🔄 PriceSyncService: מתחיל סנכרון...');
      return await _performSync(prefs);
    } catch (e) {
      debugPrint('❌ PriceSyncService: שגיאה בבדיקת סנכרון: $e');
      return false;
    }
  }

  /// 🔄 מבצע סנכרון בפועל
  Future<bool> _performSync(SharedPreferences prefs) async {
    try {
      // 1. הורד עדכוני מחירים מ-Shufersal
      final updates = await _fetchPriceUpdates();

      if (updates.isEmpty) {
        debugPrint('   ⚠️  לא נמצאו עדכונים');
        return false;
      }

      debugPrint('   ✅ נמצאו ${updates.length} עדכוני מחירים');

      // 2. שמור ב-SharedPreferences לפי list_type
      final updatesByType = _groupByListType(updates);

      for (final entry in updatesByType.entries) {
        final listType = entry.key;
        final data = entry.value;

        await prefs.setString(
          '$_syncDataPrefix$listType',
          jsonEncode(data),
        );

        debugPrint('   💾 נשמר: $listType (${data.length} מוצרים)');
      }

      // 3. עדכן תאריך סנכרון אחרון
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      debugPrint('✅ PriceSyncService: סנכרון הושלם בהצלחה!');
      return true;
    } catch (e) {
      debugPrint('❌ PriceSyncService: שגיאה בסנכרון: $e');
      return false;
    }
  }

  /// 📥 מוריד עדכוני מחירים מ-Shufersal
  ///
  /// 🔮 פיתוח עתידי:
  /// - לחבר ל-ShufersalPricesService.getProducts()
  /// - להשוות barcodes מול ה-JSONים הקיימים
  /// - לעדכן רק מחירים (לא להוסיף מוצרים חדשים)
  /// - לשמור ב-SharedPreferences כ-cache
  ///
  /// ⚠️ דרישות לפני הפעלה:
  /// - לבדוק שה-API של שופרסל עדיין עובד
  /// - להתמודד עם timeout (הורדה יכולה לקחת דקות)
  /// - לבדוק על מכשיר אמיתי (לא אמולטור)
  Future<List<Map<String, dynamic>>> _fetchPriceUpdates() async {
    // TODO: פיתוח עתידי - חיבור ל-ShufersalPricesService
    //
    // הקוד צריך להיות:
    // 1. final shufersalProducts = await ShufersalPricesService.getProducts();
    // 2. להשוות barcodes מול המוצרים הקיימים
    // 3. להחזיר רק מוצרים שיש להם barcode תואם + מחיר שונה
    //
    // מבנה התוצאה:
    // return [
    //   {
    //     'barcode': '7290001234567',
    //     'price': 5.9,
    //     'list_type': 'supermarket',
    //   },
    // ];

    debugPrint('   ⏸️ סנכרון מחירים - פיתוח עתידי');
    return [];
  }

  /// 🏷️ מקבץ מוצרים לפי list_type
  Map<String, List<Map<String, dynamic>>> _groupByListType(
    List<Map<String, dynamic>> products,
  ) {
    final result = <String, List<Map<String, dynamic>>>{};

    for (final product in products) {
      final listType = product['list_type'] as String? ?? 'supermarket';

      if (!result.containsKey(listType)) {
        result[listType] = [];
      }

      result[listType]!.add(product);
    }

    return result;
  }

  /// 📥 מביא עדכונים שמורים עבור list_type מסוים
  ///
  /// מחזיר null אם אין עדכונים שמורים
  Future<List<Map<String, dynamic>>?> getSyncedUpdates(String listType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('$_syncDataPrefix$listType');

      if (dataStr == null) return null;

      final List<dynamic> data = jsonDecode(dataStr);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ PriceSyncService: שגיאה בקריאת עדכונים: $e');
      return null;
    }
  }

  /// 🧹 מנקה את כל הנתונים השמורים
  Future<void> clearSyncData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_syncDataPrefix) || key == _lastSyncKey) {
        await prefs.remove(key);
      }
    }

    debugPrint('🧹 PriceSyncService: נתוני סנכרון נמחקו');
  }

  /// 📅 מחזיר את תאריך הסנכרון האחרון
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_lastSyncKey);

      if (lastSyncStr == null) return null;

      return DateTime.parse(lastSyncStr);
    } catch (e) {
      return null;
    }
  }

  /// 🔄 כפה סנכרון (גם אם עבר פחות מיום)
  Future<bool> forceSync() async {
    debugPrint('🔄 PriceSyncService: סנכרון מאולץ...');
    final prefs = await SharedPreferences.getInstance();
    return await _performSync(prefs);
  }
}
