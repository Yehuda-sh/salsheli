// 📄 File: lib/services/recurring_product_service.dart
// 🎯 Purpose: שירות לזיהוי מוצרים קבועים (recurring products)
//
// 📋 Features:
// - זיהוי מוצרים שנקנו 4+ פעמים
// - הצעה אוטומטית להפיכת מוצר לקבוע
// - שמירת העדפות "אל תשאל שוב"
// - סטטיסטיקות קניות
//
// 🔗 Related:
// - inventory_item.dart - מודל פריט מזווה
// - inventory_provider.dart - ניהול מזווה
//
// Version: 1.0
// Created: 16/12/2025

import 'package:shared_preferences/shared_preferences.dart';

import '../models/inventory_item.dart';

/// סף לזיהוי מוצר כפופולרי/קבוע
const int kRecurringThreshold = 4;

/// מפתח שמירה למוצרים שלא לשאול עליהם
const String _kDismissedProductsKey = 'recurring_dismissed_products';

/// שירות לזיהוי וניהול מוצרים קבועים
class RecurringProductService {
  /// מוצאת מוצרים פופולריים שעדיין לא מסומנים כקבועים
  ///
  /// מחזיר רשימת מוצרים שעומדים בקריטריונים:
  /// 1. נקנו לפחות [threshold] פעמים
  /// 2. לא מסומנים כ-isRecurring
  /// 3. לא נדחו על ידי המשתמש
  static Future<List<InventoryItem>> findPotentialRecurringProducts(
    List<InventoryItem> items, {
    int threshold = kRecurringThreshold,
  }) async {
    // סינון לפי purchaseCount ו-isRecurring
    final candidates = items.where((item) {
      return item.purchaseCount >= threshold && !item.isRecurring;
    }).toList();

    if (candidates.isEmpty) return [];

    // קבל את רשימת המוצרים שנדחו
    final dismissedIds = await _getDismissedProductIds();

    // סנן מוצרים שנדחו
    return candidates.where((item) => !dismissedIds.contains(item.id)).toList();
  }

  /// בודק אם יש מוצרים פופולריים חדשים להציע
  static Future<bool> hasNewRecurringCandidates(
    List<InventoryItem> items,
  ) async {
    final candidates = await findPotentialRecurringProducts(items);
    return candidates.isNotEmpty;
  }

  /// מחזיר את המוצר הפופולרי ביותר שלא מסומן כקבוע
  ///
  /// שימושי להצגת הצעה אחת בכל פעם
  static Future<InventoryItem?> getTopRecurringCandidate(
    List<InventoryItem> items,
  ) async {
    final candidates = await findPotentialRecurringProducts(items);
    if (candidates.isEmpty) return null;

    // מיון לפי purchaseCount (יורד)
    candidates.sort((a, b) => b.purchaseCount.compareTo(a.purchaseCount));
    return candidates.first;
  }

  /// מסמן מוצר כ"אל תשאל שוב"
  static Future<void> dismissProduct(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getStringList(_kDismissedProductsKey) ?? [];

      if (!dismissed.contains(productId)) {
        dismissed.add(productId);
        await prefs.setStringList(_kDismissedProductsKey, dismissed);
      }
    } catch (e) {
      // ignore
    }
  }

  /// מבטל סימון "אל תשאל שוב" למוצר
  static Future<void> undismissProduct(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getStringList(_kDismissedProductsKey) ?? [];

      if (dismissed.contains(productId)) {
        dismissed.remove(productId);
        await prefs.setStringList(_kDismissedProductsKey, dismissed);
      }
    } catch (e) {
      // ignore
    }
  }

  /// מנקה את כל המוצרים שנדחו
  static Future<void> clearDismissedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kDismissedProductsKey);
    } catch (e) {
      // ignore
    }
  }

  /// מחזיר סטטיסטיקות על מוצרים קבועים
  static RecurringProductStats getStats(List<InventoryItem> items) {
    final recurring = items.where((i) => i.isRecurring).toList();
    final popular = items.where((i) => i.isPopular).toList();
    final candidates =
        items.where((i) => i.purchaseCount >= kRecurringThreshold && !i.isRecurring).toList();

    return RecurringProductStats(
      totalRecurring: recurring.length,
      totalPopular: popular.length,
      potentialCandidates: candidates.length,
      topPurchaseCount: items.isNotEmpty
          ? items.map((i) => i.purchaseCount).reduce((a, b) => a > b ? a : b)
          : 0,
    );
  }

  /// מחזיר רשימת מזהי מוצרים שנדחו
  static Future<Set<String>> _getDismissedProductIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getStringList(_kDismissedProductsKey) ?? [];
      return dismissed.toSet();
    } catch (e) {
      return {};
    }
  }
}

/// סטטיסטיקות מוצרים קבועים
class RecurringProductStats {
  /// כמות מוצרים מסומנים כקבועים
  final int totalRecurring;

  /// כמות מוצרים פופולריים (4+ קניות)
  final int totalPopular;

  /// כמות מועמדים להפיכה לקבועים
  final int potentialCandidates;

  /// מספר הקניות הגבוה ביותר
  final int topPurchaseCount;

  const RecurringProductStats({
    required this.totalRecurring,
    required this.totalPopular,
    required this.potentialCandidates,
    required this.topPurchaseCount,
  });

  @override
  String toString() =>
      'RecurringProductStats(recurring: $totalRecurring, popular: $totalPopular, candidates: $potentialCandidates, topCount: $topPurchaseCount)';
}
