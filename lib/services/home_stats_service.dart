// 📄 File: lib/services/home_stats_service.dart
//
// 📋 Description:
// Static service for calculating home statistics and insights.
// Uses data from ReceiptProvider, ShoppingListsProvider, and InventoryProvider.
//
// 🎯 Purpose:
// - Calculate monthly spending
// - Track expense trends
// - Analyze shopping list accuracy
// - Identify low inventory items
// - Generate smart recommendations
//
// 📱 Mobile Only: Yes
//
// 🆕 Created: 07/10/2025 - Minimal implementation to fix insights_screen.dart

import 'package:flutter/foundation.dart';
import '../models/receipt.dart';
import '../models/shopping_list.dart';
import '../models/inventory_item.dart';

/// מחלקת נתונים סטטיסטיים
class HomeStats {
  /// סכום הוצאות חודשי
  final double monthlySpent;

  /// מגמת הוצאות לפי חודשים
  /// Format: [{'month': 'ינואר', 'value': 1200.0}, ...]
  final List<Map<String, dynamic>> expenseTrend;

  /// אחוז דיוק רשימות קניות (0-100)
  /// כמה פריטים שתכננו באמת נקנו
  final double listAccuracy;

  /// חיסכון פוטנציאלי (ש"ח)
  final double potentialSavings;

  /// מספר פריטים במלאי שנגמרים
  final int lowInventoryCount;

  const HomeStats({
    required this.monthlySpent,
    required this.expenseTrend,
    required this.listAccuracy,
    required this.potentialSavings,
    required this.lowInventoryCount,
  });

  /// יצירת HomeStats ריק (ברירת מחדל)
  factory HomeStats.empty() {
    return const HomeStats(
      monthlySpent: 0.0,
      expenseTrend: [],
      listAccuracy: 0.0,
      potentialSavings: 0.0,
      lowInventoryCount: 0,
    );
  }
}

/// שירות חישוב סטטיסטיקות
class HomeStatsService {
  /// חישוב סטטיסטיקות מנתונים
  ///
  /// [receipts] - רשימת קבלות
  /// [shoppingLists] - רשימות קניות
  /// [inventory] - מלאי
  /// [monthsBack] - כמה חודשים אחורה לנתח (0=שבוע, 1=חודש, 3=רבעון, 12=שנה)
  static Future<HomeStats> calculateStats({
    required List<Receipt> receipts,
    required List<ShoppingList> shoppingLists,
    required List<InventoryItem> inventory,
    int monthsBack = 1,
  }) async {
    debugPrint('📊 HomeStatsService.calculateStats()');
    debugPrint('   📄 ${receipts.length} קבלות');
    debugPrint('   📋 ${shoppingLists.length} רשימות');
    debugPrint('   📦 ${inventory.length} פריטים במלאי');
    debugPrint('   📅 מנתח $monthsBack חודשים אחורה');

    try {
      // 1. חישוב תקופת זמן
      final now = DateTime.now();
      final startDate = monthsBack == 0
          ? now.subtract(const Duration(days: 7)) // שבוע
          : DateTime(now.year, now.month - monthsBack, now.day);

      debugPrint('   📅 מתאריך: ${startDate.toString().split(' ')[0]}');

      // 2. סינון קבלות לפי תקופה
      final relevantReceipts = receipts.where((r) {
        return r.date.isAfter(startDate);
      }).toList();

      debugPrint('   ✅ ${relevantReceipts.length} קבלות רלוונטיות');

      // 3. חישוב הוצאה חודשית
      final monthlySpent = _calculateMonthlySpent(relevantReceipts);
      debugPrint('   💰 הוצאה חודשית: ₪${monthlySpent.toStringAsFixed(2)}');

      // 4. חישוב מגמת הוצאות
      final expenseTrend = _calculateExpenseTrend(receipts, monthsBack);
      debugPrint('   📈 מגמה: ${expenseTrend.length} נקודות');

      // 5. חישוב דיוק רשימות
      final listAccuracy = _calculateListAccuracy(shoppingLists, receipts);
      debugPrint('   🎯 דיוק רשימות: ${listAccuracy.toStringAsFixed(1)}%');

      // 6. חישוב חיסכון פוטנציאלי (בסיסי)
      final potentialSavings = _calculatePotentialSavings(relevantReceipts);
      debugPrint('   💡 חיסכון פוטנציאלי: ₪${potentialSavings.toStringAsFixed(2)}');

      // 7. ספירת מלאי נמוך
      final lowInventoryCount = _countLowInventory(inventory);
      debugPrint('   ⚠️ מלאי נמוך: $lowInventoryCount פריטים');

      final stats = HomeStats(
        monthlySpent: monthlySpent,
        expenseTrend: expenseTrend,
        listAccuracy: listAccuracy,
        potentialSavings: potentialSavings,
        lowInventoryCount: lowInventoryCount,
      );

      debugPrint('✅ HomeStatsService.calculateStats: הצליח');
      return stats;
    } catch (e, stackTrace) {
      debugPrint('❌ HomeStatsService.calculateStats: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      return HomeStats.empty();
    }
  }

  /// חישוב הוצאה חודשית ממוצעת
  static double _calculateMonthlySpent(List<Receipt> receipts) {
    if (receipts.isEmpty) return 0.0;

    final total = receipts.fold(0.0, (sum, r) => sum + r.totalAmount);
    
    // חישוב כמה חודשים בפועל (לפחות 1)
    final oldestDate = receipts.map((r) => r.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final newestDate = receipts.map((r) => r.date).reduce((a, b) => a.isAfter(b) ? a : b);
    final daysDiff = newestDate.difference(oldestDate).inDays;
    final monthsDiff = (daysDiff / 30).ceil().clamp(1, 100);

    return total / monthsDiff;
  }

  /// חישוב מגמת הוצאות לפי חודשים
  static List<Map<String, dynamic>> _calculateExpenseTrend(
    List<Receipt> receipts,
    int monthsBack,
  ) {
    if (receipts.isEmpty) return [];

    final now = DateTime.now();
    final trend = <Map<String, dynamic>>[];

    // חישוב לפי חודש
    for (var i = monthsBack; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthStart = DateTime(monthDate.year, monthDate.month, 1);
      final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 0);

      final monthReceipts = receipts.where((r) {
        return r.date.isAfter(monthStart) && r.date.isBefore(monthEnd);
      }).toList();

      final monthTotal = monthReceipts.fold(0.0, (sum, r) => sum + r.totalAmount);

      trend.add({
        'month': _getMonthName(monthDate.month),
        'value': monthTotal,
      });
    }

    return trend;
  }

  /// המרת מספר חודש לשם
  static String _getMonthName(int month) {
    const names = [
      'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
      'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'
    ];
    return names[month - 1];
  }

  /// חישוב דיוק רשימות קניות
  /// כמה פריטים שתכננו באמת נקנו
  static double _calculateListAccuracy(
    List<ShoppingList> lists,
    List<Receipt> receipts,
  ) {
    if (lists.isEmpty || receipts.isEmpty) return 0.0;

    // רשימות שהושלמו
    final completedLists = lists.where((l) => l.status == ShoppingList.statusCompleted).toList();
    if (completedLists.isEmpty) return 0.0;

    int totalPlanned = 0;
    int totalPurchased = 0;

    for (var list in completedLists) {
      // ספור פריטים מתוכננים
      final planned = list.items.length;
      totalPlanned += planned;

      // ספור פריטים שנקנו (עם כמות > 0 או isChecked = true)
      final purchased = list.items.where((item) {
        return item.quantity > 0 || item.isChecked;
      }).length;
      totalPurchased += purchased;
    }

    if (totalPlanned == 0) return 0.0;

    final accuracy = (totalPurchased / totalPlanned) * 100;
    return accuracy.clamp(0.0, 100.0);
  }

  /// חישוב חיסכון פוטנציאלי
  /// זוהי הערכה פשוטה - 5-10% מהסכום החודשי
  static double _calculatePotentialSavings(List<Receipt> receipts) {
    if (receipts.isEmpty) return 0.0;

    final total = receipts.fold(0.0, (sum, r) => sum + r.totalAmount);
    
    // הערכה: אפשר לחסוך בין 5% ל-10% עם השוואת מחירים
    final savingsPercent = 0.075; // 7.5% ממוצע
    return total * savingsPercent;
  }

  /// ספירת פריטים במלאי שנגמרים
  static int _countLowInventory(List<InventoryItem> inventory) {
    if (inventory.isEmpty) return 0;

    return inventory.where((item) {
      // פריט נחשב "נמוך" אם:
      // כמות < 2 (נגמר או עומד להיגמר)
      return item.quantity < 2;
    }).length;
  }

  /// טעינה מקאש (לא ממומש - מחזיר null)
  /// 
  /// TODO: אפשר להוסיף שמירה ל-SharedPreferences או Hive
  /// כדי למנוע חישובים מיותרים
  static Future<HomeStats?> loadFromCache() async {
    debugPrint('💾 HomeStatsService.loadFromCache()');
    debugPrint('   ⚠️ Cache לא ממומש - מחזיר null');
    return null;
  }

  /// שמירה לקאש (לא ממומש)
  /// 
  /// TODO: שמירת HomeStats ל-SharedPreferences/Hive
  static Future<void> saveToCache(HomeStats stats) async {
    debugPrint('💾 HomeStatsService.saveToCache()');
    debugPrint('   ⚠️ Cache לא ממומש - לא עושה כלום');
  }
}
