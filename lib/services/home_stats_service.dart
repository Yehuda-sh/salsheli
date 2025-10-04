// 📄 File: lib/services/home_stats_service.dart
//
// 📌 מטרה: חישוב וטעינת סטטיסטיקות כלליות לדף הבית (הוצאות חודשיות, חיסכון פוטנציאלי, מגמות, דיוק רשימות וכו׳).
//     כולל שמירה מטמון מקומי (SharedPreferences) ותמיכה בטעינה מקוונת של נתונים אמתיים במקום דמו.
//
// 📌 Purpose: Service to compute and load aggregated home statistics
//     (monthly expenses, potential savings, trend charts, list accuracy, inventory status).
//     Includes caching via SharedPreferences, and flexible support to use real data sources.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/receipt.dart' as receipt_model;
import '../models/shopping_list.dart' as shopping_list_model;

/// מודל סטטיסטיקות לדף הבית
class HomeStats {
  final double monthlySpent;
  final double potentialSavings;
  final int lowInventoryCount;
  final int listAccuracy;
  final List<Map<String, dynamic>> expenseTrend;

  HomeStats({
    this.monthlySpent = 0,
    this.potentialSavings = 0,
    this.lowInventoryCount = 0,
    this.listAccuracy = 0,
    this.expenseTrend = const [],
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      monthlySpent: (json['monthlySpent'] as num?)?.toDouble() ?? 0,
      potentialSavings: (json['potentialSavings'] as num?)?.toDouble() ?? 0,
      lowInventoryCount: json['lowInventoryCount'] as int? ?? 0,
      listAccuracy: json['listAccuracy'] as int? ?? 0,
      expenseTrend:
          (json['expenseTrend'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'monthlySpent': monthlySpent,
    'potentialSavings': potentialSavings,
    'lowInventoryCount': lowInventoryCount,
    'listAccuracy': listAccuracy,
    'expenseTrend': expenseTrend,
  };
}

/// שירות לחישוב, טעינה ושמירה של סטטיסטיקות הבית
class HomeStatsService {
  static const _cacheKey = "home_stats_cache_v2";

  /// שמירה בטוחה למטמון
  static Future<void> saveToCache(HomeStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(stats.toJson()));
      await prefs.setInt(
        '$_cacheKey.savedAt',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // בולעים – לא קריטי אם המטמון נכשל
    }
  }

  /// טעינה פשוטה מהמטמון (ללא TTL)
  static Future<HomeStats?> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      return HomeStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// טעינה מהמטמון עם TTL (ברירת מחדל: 6 שעות)
  static Future<HomeStats?> loadFromCacheWithTTL({
    Duration ttl = const Duration(hours: 6),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAtMs = prefs.getInt('$_cacheKey.savedAt');
      if (savedAtMs == null) return null;
      final savedAt = DateTime.fromMillisecondsSinceEpoch(savedAtMs);
      if (DateTime.now().difference(savedAt) > ttl) return null;
      return loadFromCache();
    } catch (_) {
      return null;
    }
  }

  /// ניקוי המטמון
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove('$_cacheKey.savedAt');
  }

  /// חישוב סטטיסטיקות (נשמר למטמון בסיום)
  static Future<HomeStats> calculateStats({
    required List<receipt_model.Receipt> receipts,
    required List<shopping_list_model.ShoppingList> shoppingLists,
    int monthsBack = 4,
  }) async {
    // הגנות בסיס
    if (monthsBack <= 0) monthsBack = 1;

    final monthlySpent = _calculateMonthlySpent(receipts);
    final expenseTrend = _calculateExpenseTrends(
      receipts,
      monthsBack: monthsBack,
    );

    final lowInventoryCount = _calculateLowInventoryCount(shoppingLists);
    final listAccuracy = _calculateListAccuracy(shoppingLists, receipts);

    final stats = HomeStats(
      monthlySpent: monthlySpent,
      potentialSavings: monthlySpent * 0.15, // דוגמה בלבד
      lowInventoryCount: lowInventoryCount,
      listAccuracy: listAccuracy.clamp(0, 100),
      expenseTrend: expenseTrend,
    );

    await saveToCache(stats);
    return stats;
  }

  static double _calculateMonthlySpent(List<receipt_model.Receipt> receipts) {
    final now = DateTime.now();
    return receipts
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .fold<double>(0.0, (sum, r) => sum + (r.totalAmount));
  }

  static List<Map<String, dynamic>> _calculateExpenseTrends(
    List<receipt_model.Receipt> receipts, {
    int monthsBack = 4,
  }) {
    final now = DateTime.now();
    final trends = <Map<String, dynamic>>[];

    for (int i = monthsBack - 1; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthStart = DateTime(monthDate.year, monthDate.month, 1);
      final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 0);

      final monthlyAmount = receipts
          .where(
            (r) => !r.date.isBefore(monthStart) && !r.date.isAfter(monthEnd),
          )
          .fold<double>(0.0, (sum, r) => sum + r.totalAmount);

      trends.add({
        "month": DateFormat.MMM("he_IL").format(monthDate),
        "value": monthlyAmount.round(), // לייצוג גרפי נעים
      });
    }
    return trends;
  }

  /// חישוב דוגמה למספר מוצרים נמוכים במלאי – החלף בלוגיקה אמיתית מול inventory
  static int _calculateLowInventoryCount(
    List<shopping_list_model.ShoppingList> lists,
  ) {
    // TODO: לחבר למודל/Provider של Inventory (כשיהיה), למשל לפי תאריך תפוגה/כמות
    return 0;
  }

  /// חישוב דוגמה לדיוק הרשימות – החלף בלוגיקה אמיתית (השוואת פריטים מול קבלות)
  static int _calculateListAccuracy(
    List<shopping_list_model.ShoppingList> lists,
    List<receipt_model.Receipt> receipts,
  ) {
    // TODO: לדוגמה, שיעור פריטים שנכללו ברשימה וגם נקנו בפועל
    return 100;
  }
}
