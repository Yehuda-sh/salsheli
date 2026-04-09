// 📄 lib/services/home_widget_service.dart
//
// שירות לעדכון Home Screen Widget עם נתוני מזווה.
// משתמש ב-home_widget package לתקשורת עם native widgets.
//
// 🔗 Related: InventoryProvider, InventoryItem

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/inventory_item.dart';

/// App group ID for iOS widget data sharing
const String _kAppGroupId = 'group.com.memozap.app';

/// Android widget class name
const String _kAndroidWidgetProvider = 'PantryWidgetProvider';

/// Keys for widget data
class _WidgetKeys {
  static const lowStockItems = 'low_stock_items';
  static const lowStockCount = 'low_stock_count';
  static const expiringItems = 'expiring_items';
  static const expiringCount = 'expiring_count';
  static const totalItems = 'total_items';
  static const pantryHealth = 'pantry_health';
  static const lastUpdated = 'last_updated';
}

/// שירות לעדכון Home Screen Widget
class HomeWidgetService {
  HomeWidgetService._();
  static final instance = HomeWidgetService._();

  bool _initialized = false;

  /// אתחול — קורא פעם אחת ב-startup
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await HomeWidget.setAppGroupId(_kAppGroupId);
    } catch (e) {
      debugPrint('HomeWidgetService: init failed: $e');
    }
  }

  /// עדכון נתוני Widget עם המצב הנוכחי של המזווה
  ///
  /// נקרא אחרי כל שינוי במזווה (CRUD, addStock, removeStock).
  Future<void> updateWidgetData({
    required List<InventoryItem> allItems,
  }) async {
    try {
      // מלאי נמוך
      final lowStock = allItems.where((i) => i.isLowStock && i.quantity > 0).toList()
        ..sort((a, b) => a.quantity.compareTo(b.quantity));
      final lowStockNames = lowStock.take(5).map((i) => i.productName).toList();

      // תפוגה קרובה (רק פריטים עם תאריך שהוזן)
      final expiring = allItems.where((i) => i.hasExpiryDate && (i.isExpired || i.isExpiringSoon)).toList()
        ..sort((a, b) => (a.expiryDate ?? DateTime(9999)).compareTo(b.expiryDate ?? DateTime(9999)));
      final expiringNames = expiring.take(5).map((i) => i.productName).toList();

      // בריאות מזווה
      final healthyCount = allItems.where((i) => !i.isLowStock && i.quantity > 0).length;
      final healthPercent = allItems.isEmpty ? 100 : ((healthyCount / allItems.length) * 100).round();

      // שמור נתונים
      await Future.wait([
        HomeWidget.saveWidgetData(_WidgetKeys.lowStockItems, jsonEncode(lowStockNames)),
        HomeWidget.saveWidgetData(_WidgetKeys.lowStockCount, lowStock.length),
        HomeWidget.saveWidgetData(_WidgetKeys.expiringItems, jsonEncode(expiringNames)),
        HomeWidget.saveWidgetData(_WidgetKeys.expiringCount, expiring.length),
        HomeWidget.saveWidgetData(_WidgetKeys.totalItems, allItems.length),
        HomeWidget.saveWidgetData(_WidgetKeys.pantryHealth, healthPercent),
        HomeWidget.saveWidgetData(_WidgetKeys.lastUpdated, DateTime.now().toIso8601String()),
      ]);

      // עדכן Widget
      await HomeWidget.updateWidget(
        androidName: _kAndroidWidgetProvider,
        iOSName: 'PantryWidget',
      );
    } catch (e) {
      debugPrint('HomeWidgetService: update failed: $e');
    }
  }
}
