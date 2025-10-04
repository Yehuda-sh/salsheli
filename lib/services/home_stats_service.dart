// 📄 File: lib/services/home_stats_service.dart
//
// 📌 מטרה: חישוב וטעינת סטטיסטיקות כלליות לדף הבית (הוצאות חודשיות, חיסכון פוטנציאלי, מגמות, דיוק רשימות וכו׳).
//     כולל שמירה מטמון מקומי (SharedPreferences) ותמיכה בטעינה מקוונת של נתונים אמתיים במקום דמו.
//
// 📌 Purpose: Service to compute and load aggregated home statistics
//     (monthly expenses, potential savings, trend charts, list accuracy, inventory status).
//     Includes caching via SharedPreferences, and flexible support to use real data sources.
//
// ✅ עדכון 04/10/2025: חיבור ל-InventoryProvider, logging, List Accuracy אמיתי

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/receipt.dart' as receipt_model;
import '../models/shopping_list.dart' as shopping_list_model;
import '../models/inventory_item.dart';

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
      debugPrint('✅ HomeStatsService: שמור ל-cache בהצלחה');
    } catch (e) {
      debugPrint('❌ HomeStatsService: שגיאה בשמירה ל-cache: $e');
      // בולעים – לא קריטי אם המטמון נכשל
    }
  }

  /// טעינה פשוטה מהמטמון (ללא TTL)
  static Future<HomeStats?> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) {
        debugPrint('ℹ️ HomeStatsService: אין cache');
        return null;
      }
      debugPrint('✅ HomeStatsService: נטען מ-cache');
      return HomeStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ HomeStatsService: שגיאה בטעינה מ-cache: $e');
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
      if (savedAtMs == null) {
        debugPrint('ℹ️ HomeStatsService: אין timestamp ב-cache');
        return null;
      }
      final savedAt = DateTime.fromMillisecondsSinceEpoch(savedAtMs);
      final age = DateTime.now().difference(savedAt);
      
      if (age > ttl) {
        debugPrint('⏰ HomeStatsService: cache ישן (${age.inMinutes} דקות), TTL: ${ttl.inMinutes} דקות');
        return null;
      }
      
      debugPrint('✅ HomeStatsService: cache תקף (${age.inMinutes} דקות)');
      return loadFromCache();
    } catch (e) {
      debugPrint('❌ HomeStatsService: שגיאה בבדיקת TTL: $e');
      return null;
    }
  }

  /// ניקוי המטמון
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove('$_cacheKey.savedAt');
      debugPrint('✅ HomeStatsService: cache נמחק');
    } catch (e) {
      debugPrint('❌ HomeStatsService: שגיאה במחיקת cache: $e');
    }
  }

  /// חישוב סטטיסטיקות (נשמר למטמון בסיום)
  static Future<HomeStats> calculateStats({
    required List<receipt_model.Receipt> receipts,
    required List<shopping_list_model.ShoppingList> shoppingLists,
    required List<InventoryItem> inventory, // 🆕 חובה!
    int monthsBack = 4,
  }) async {
    debugPrint('\n📊 HomeStatsService: מתחיל חישוב סטטיסטיקות...');
    debugPrint('   📄 קבלות: ${receipts.length}');
    debugPrint('   📋 רשימות: ${shoppingLists.length}');
    debugPrint('   📦 מלאי: ${inventory.length}');
    
    // הגנות בסיס
    if (monthsBack <= 0) monthsBack = 1;

    final monthlySpent = _calculateMonthlySpent(receipts);
    debugPrint('   💰 הוצאה חודשית: ₪${monthlySpent.toStringAsFixed(2)}');
    
    final expenseTrend = _calculateExpenseTrends(
      receipts,
      monthsBack: monthsBack,
    );
    debugPrint('   📈 מגמות: ${expenseTrend.length} חודשים');

    final lowInventoryCount = _calculateLowInventoryCount(inventory);
    debugPrint('   ⚠️ מלאי נמוך: $lowInventoryCount פריטים');
    
    final listAccuracy = _calculateListAccuracy(shoppingLists, receipts);
    debugPrint('   🎯 דיוק רשימות: $listAccuracy%');

    final stats = HomeStats(
      monthlySpent: monthlySpent,
      potentialSavings: monthlySpent * 0.15, // דוגמה בלבד
      lowInventoryCount: lowInventoryCount,
      listAccuracy: listAccuracy.clamp(0, 100),
      expenseTrend: expenseTrend,
    );

    await saveToCache(stats);
    debugPrint('✅ HomeStatsService: חישוב הושלם\n');
    return stats;
  }

  /// חישוב הוצאה חודשית
  static double _calculateMonthlySpent(List<receipt_model.Receipt>? receipts) {
    if (receipts == null || receipts.isEmpty) {
      debugPrint('   ℹ️ _calculateMonthlySpent: אין קבלות');
      return 0.0;
    }
    
    final now = DateTime.now();
    final monthlyReceipts = receipts
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .toList();
    
    if (monthlyReceipts.isEmpty) {
      debugPrint('   ℹ️ _calculateMonthlySpent: אין קבלות מהחודש הנוכחי');
      return 0.0;
    }
    
    return monthlyReceipts.fold<double>(0.0, (sum, r) => sum + r.totalAmount);
  }

  /// חישוב מגמות הוצאות
  static List<Map<String, dynamic>> _calculateExpenseTrends(
    List<receipt_model.Receipt>? receipts, {
    int monthsBack = 4,
  }) {
    if (receipts == null || receipts.isEmpty) {
      debugPrint('   ℹ️ _calculateExpenseTrends: אין קבלות');
      return [];
    }
    
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

  /// חישוב מספר פריטים נמוכים במלאי (כמות ≤ 2)
  /// 🆕 עובד עם InventoryProvider אמיתי!
  static int _calculateLowInventoryCount(List<InventoryItem>? inventory) {
    if (inventory == null || inventory.isEmpty) {
      debugPrint('   ℹ️ _calculateLowInventoryCount: אין מלאי');
      return 0;
    }
    
    final lowItems = inventory.where((item) => item.quantity <= 2).toList();
    
    if (lowItems.isNotEmpty) {
      debugPrint('   ⚠️ פריטים נמוכים:');
      for (final item in lowItems.take(5)) { // הצג רק 5 ראשונים
        debugPrint('      • ${item.productName}: ${item.quantity} ${item.unit}');
      }
      if (lowItems.length > 5) {
        debugPrint('      ... ועוד ${lowItems.length - 5}');
      }
    }
    
    return lowItems.length;
  }

  /// חישוב דיוק רשימות - השוואה בין רשימות לקבלות
  /// 🆕 השוואה אמיתית לפי תאריכים!
  static int _calculateListAccuracy(
    List<shopping_list_model.ShoppingList>? lists,
    List<receipt_model.Receipt>? receipts,
  ) {
    if (lists == null || lists.isEmpty || receipts == null || receipts.isEmpty) {
      debugPrint('   ℹ️ _calculateListAccuracy: אין רשימות או קבלות');
      return 0;
    }
    
    // קח רק רשימות מהחודש האחרון
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentLists = lists.where((l) => 
      l.updatedDate.isAfter(thirtyDaysAgo)
    ).toList();
    
    if (recentLists.isEmpty) {
      debugPrint('   ℹ️ _calculateListAccuracy: אין רשימות מהחודש האחרון');
      return 0;
    }
    
    int totalItems = 0;
    int matchedItems = 0;
    
    for (final list in recentLists) {
      totalItems += list.items.length;
      
      for (final item in list.items) {
        // בדוק אם הפריט נקנה בקבלה (תוך 7 ימים מיצירת הרשימה)
        final listDate = list.updatedDate;
        final weekAfterList = listDate.add(const Duration(days: 7));
        
        final purchased = receipts.any((r) => 
          r.date.isAfter(listDate) && 
          r.date.isBefore(weekAfterList) &&
          r.items.any((rItem) => rItem.name.contains(item.name))
        );
        
        if (purchased) matchedItems++;
      }
    }
    
    final accuracy = totalItems > 0 ? ((matchedItems / totalItems) * 100).round() : 0;
    
    debugPrint('   🎯 דיוק: $matchedItems/$totalItems פריטים נקנו = $accuracy%');
    
    return accuracy;
  }
}
