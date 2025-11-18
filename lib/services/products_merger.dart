// 📄 File: lib/services/products_merger.dart
//
// 🔀 שירות למיזוג מוצרים מ-assets עם עדכונים מסונכרנים
//
// 🎯 תפקיד:
// - ממזג מוצרים בסיסיים (מ-assets) עם עדכונים (מ-SharedPreferences)
// - מעדכן מחירים למוצרים קיימים
// - מוסיף מוצרים חדשים
//
// 📦 שימוש:
// ```dart
// final merger = ProductsMerger();
// final merged = await merger.mergeProducts(baseProducts, 'bakery');
// ```

import 'package:flutter/foundation.dart';
import 'price_sync_service.dart';

class ProductsMerger {
  final PriceSyncService _syncService = PriceSyncService();

  /// 🔀 ממזג מוצרים בסיסיים עם עדכונים מסונכרנים
  ///
  /// [baseProducts] - מוצרים מ-assets (בסיס)
  /// [listType] - סוג רשימה (bakery, butcher, וכו')
  ///
  /// Returns: מוצרים ממוזגים (בסיס + עדכונים)
  Future<List<Map<String, dynamic>>> mergeProducts(
    List<Map<String, dynamic>> baseProducts,
    String listType,
  ) async {
    try {
      // 1. קבל עדכונים מסונכרנים
      final syncedUpdates = await _syncService.getSyncedUpdates(listType);

      if (syncedUpdates == null || syncedUpdates.isEmpty) {
        debugPrint('ℹ️  ProductsMerger: אין עדכונים עבור $listType');
        return baseProducts;
      }

      debugPrint('🔀 ProductsMerger: ממזג ${baseProducts.length} מוצרים בסיס + ${syncedUpdates.length} עדכונים');

      // 2. צור מפה של מוצרים לפי barcode
      final baseByBarcode = <String, Map<String, dynamic>>{};
      for (final product in baseProducts) {
        final barcode = product['barcode'] as String?;
        if (barcode != null && barcode.isNotEmpty) {
          baseByBarcode[barcode] = Map<String, dynamic>.from(product);
        }
      }

      // 3. עדכן מחירים והוסף מוצרים חדשים
      int updatedCount = 0;
      int addedCount = 0;

      for (final update in syncedUpdates) {
        final barcode = update['barcode'] as String?;
        if (barcode == null || barcode.isEmpty) continue;

        if (baseByBarcode.containsKey(barcode)) {
          // עדכן מוצר קיים
          final existing = baseByBarcode[barcode]!;
          final oldPrice = existing['price'];
          final newPrice = update['price'];

          if (oldPrice != newPrice) {
            existing['price'] = newPrice;
            updatedCount++;
          }

          // עדכן שדות נוספים אם יש
          if (update['name'] != null) existing['name'] = update['name'];
          if (update['category'] != null) existing['category'] = update['category'];
          if (update['brand'] != null) existing['brand'] = update['brand'];
        } else {
          // הוסף מוצר חדש
          baseByBarcode[barcode] = Map<String, dynamic>.from(update);
          addedCount++;
        }
      }

      debugPrint('   ✅ $updatedCount מחירים עודכנו, $addedCount מוצרים נוספו');

      // 4. החזר רשימה ממוזגת
      return baseByBarcode.values.toList();
    } catch (e) {
      debugPrint('❌ ProductsMerger: שגיאה במיזוג: $e');
      // במקרה של שגיאה - החזר את המוצרים הבסיסיים
      return baseProducts;
    }
  }

  /// 🔍 בודק אם יש עדכונים זמינים עבור list_type
  Future<bool> hasUpdatesFor(String listType) async {
    final updates = await _syncService.getSyncedUpdates(listType);
    return updates != null && updates.isNotEmpty;
  }

  /// 📊 מחזיר סטטיסטיקה על העדכונים
  Future<Map<String, int>> getUpdateStats(String listType) async {
    final updates = await _syncService.getSyncedUpdates(listType);

    return {
      'total_updates': updates?.length ?? 0,
      'price_updates': updates?.where((u) => u['price'] != null).length ?? 0,
      'new_products': updates?.length ?? 0,
    };
  }
}
