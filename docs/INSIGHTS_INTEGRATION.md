# 🔌 מדריך אינטגרציה: Insights Screen

מדריך מפורט להוספת נתונים אמיתיים למסך התובנות (InsightsScreen).

---

## 📋 סקירה כללית

כרגע מסך התובנות משתמש בנתונים דמה (mock data) לשני רכיבים:
1. **גרף עוגה** - התפלגות הוצאות לפי קטגוריות
2. **הוצאות עיקריות** - רשימת המוצרים עם ההוצאה הגבוהה ביותר

מדריך זה מסביר איך להוסיף את הנתונים האמיתיים.

---

## 🎯 שלב 1: הוספת שדות ל-HomeStats

### קובץ: `lib/services/home_stats_service.dart`

#### 1.1 הוסף שדות חדשים למחלקה:

```dart
class HomeStats {
  // ... שדות קיימים ...
  
  /// התפלגות הוצאות לפי קטגוריות (לגרף העוגה)
  final List<Map<String, dynamic>>? categoryBreakdown;
  
  /// המוצרים עם ההוצאה הגבוהה ביותר (לרשימת הוצאות עיקריות)
  final List<Map<String, dynamic>>? topProducts;
  
  HomeStats({
    // ... פרמטרים קיימים ...
    this.categoryBreakdown,
    this.topProducts,
  });
}
```

#### 1.2 עדכן את ה-Constructor:

```dart
HomeStats({
  required this.monthlySpent,
  required this.potentialSavings,
  required this.listAccuracy,
  required this.lowInventoryCount,
  required this.expenseTrend,
  this.categoryBreakdown,  // 🆕
  this.topProducts,        // 🆕
});
```

---

## 🧮 שלב 2: חישוב הנתונים

### 2.1 עדכן את calculateStats():

```dart
static Future<HomeStats> calculateStats({
  required List<Receipt> receipts,
  required List<ShoppingList> shoppingLists,
  required List<InventoryItem> inventory,
  int monthsBack = 1,
}) async {
  // ... חישובים קיימים ...
  
  // 🆕 חישוב התפלגות קטגוריות
  final categoryBreakdown = _calculateCategoryBreakdown(
    receipts,
    monthsBack: monthsBack,
  );
  
  // 🆕 חישוב מוצרים עיקריים
  final topProducts = _calculateTopProducts(
    receipts,
    monthsBack: monthsBack,
  );
  
  return HomeStats(
    monthlySpent: monthlySpent,
    potentialSavings: potentialSavings,
    listAccuracy: accuracy,
    lowInventoryCount: lowInventoryItems.length,
    expenseTrend: expenseTrend,
    categoryBreakdown: categoryBreakdown,  // 🆕
    topProducts: topProducts,              // 🆕
  );
}
```

---

## 📊 שלב 3: פונקציות חישוב

### 3.1 חישוב התפלגות קטגוריות:

```dart
/// מחשב התפלגות הוצאות לפי קטגוריות
/// מחזיר: List<Map<String, dynamic>> עם category, amount, color
static List<Map<String, dynamic>> _calculateCategoryBreakdown(
  List<Receipt> receipts, {
  int monthsBack = 1,
}) {
  // מיפוי קטגוריות לצבעים (תואם ל-InsightsScreen)
  const categoryColors = {
    'מזון': Colors.blue,
    'ניקיון': Colors.green,
    'טיפוח': Colors.purple,
    'משקאות': Colors.orange,
    'אחר': Colors.grey,
  };
  
  // סינון קבלות לפי תקופה
  final now = DateTime.now();
  final cutoffDate = monthsBack > 0
      ? DateTime(now.year, now.month - monthsBack, now.day)
      : DateTime(2000); // כל ההיסטוריה
  
  final relevantReceipts = receipts.where((r) =>
    r.purchaseDate.isAfter(cutoffDate)
  ).toList();
  
  // חישוב סכום לכל קטגוריה
  final categoryTotals = <String, double>{};
  
  for (final receipt in relevantReceipts) {
    for (final item in receipt.items) {
      final category = item.category ?? 'אחר';
      categoryTotals[category] = 
        (categoryTotals[category] ?? 0.0) + item.totalPrice;
    }
  }
  
  // המרה לפורמט הנדרש ומיון לפי סכום (גבוה לנמוך)
  final result = categoryTotals.entries
      .map((e) => {
            'category': e.key,
            'amount': e.value,
            'color': categoryColors[e.key] ?? Colors.grey,
          })
      .toList()
    ..sort((a, b) => 
      (b['amount'] as double).compareTo(a['amount'] as double));
  
  return result;
}
```

### 3.2 חישוב מוצרים עיקריים:

```dart
/// מחשב את המוצרים עם ההוצאה הגבוהה ביותר
/// מחזיר: List<Map<String, dynamic>> עם name, amount, category
static List<Map<String, dynamic>> _calculateTopProducts(
  List<Receipt> receipts, {
  int monthsBack = 1,
}) {
  // סינון קבלות לפי תקופה
  final now = DateTime.now();
  final cutoffDate = monthsBack > 0
      ? DateTime(now.year, now.month - monthsBack, now.day)
      : DateTime(2000); // כל ההיסטוריה
  
  final relevantReceipts = receipts.where((r) =>
    r.purchaseDate.isAfter(cutoffDate)
  ).toList();
  
  // חישוב סכום לכל מוצר (לפי שם)
  final productTotals = <String, Map<String, dynamic>>{};
  
  for (final receipt in relevantReceipts) {
    for (final item in receipt.items) {
      final key = item.name;
      
      if (productTotals.containsKey(key)) {
        // מוצר קיים - הוסף לסכום
        productTotals[key]!['amount'] = 
          (productTotals[key]!['amount'] as double) + item.totalPrice;
      } else {
        // מוצר חדש
        productTotals[key] = {
          'name': item.name,
          'amount': item.totalPrice,
          'category': item.category ?? 'אחר',
        };
      }
    }
  }
  
  // מיון לפי סכום (גבוה לנמוך)
  final sorted = productTotals.values.toList()
    ..sort((a, b) => 
      (b['amount'] as double).compareTo(a['amount'] as double));
  
  return sorted;
}
```

---

## 🔄 שלב 4: עדכון InsightsScreen

### קובץ: `lib/screens/insights/insights_screen.dart`

אחרי שתוסיף את השדות ל-HomeStats, פשוט עדכן את הפונקציות:

#### 4.1 עדכן _getCategoryData():

```dart
List<Map<String, dynamic>> _getCategoryData(HomeStats stats) {
  // 🔄 החלף את השורה הזו:
  return _getMockCategoryDataWithColors();
  
  // 🔄 בשורה הזו:
  return stats.categoryBreakdown ?? _getMockCategoryDataWithColors();
}
```

#### 4.2 עדכן _getTopExpenses():

```dart
List<Map<String, dynamic>> _getTopExpenses(HomeStats stats) {
  // 🔄 החלף את השורה הזו:
  return _mockTopExpenses;
  
  // 🔄 בשורה הזו:
  return stats.topProducts?.take(5).toList() ?? _mockTopExpenses;
}
```

---

## ✅ בדיקה

### לפני האינטגרציה:
```dart
// InsightsScreen משתמש בנתונים דמה
_mockCategoryData = [
  {'category': 'מזון', 'amount': 800.0},
  ...
]
```

### אחרי האינטגרציה:
```dart
// InsightsScreen משתמש בנתונים אמיתיים מ-receipts
stats.categoryBreakdown = [
  {'category': 'מזון', 'amount': 1243.50, 'color': Colors.blue},
  ...
]
```

### בדיקות מומלצות:

1. **בדוק עם 0 קבלות:**
   - האפליקציה לא קורסת?
   - מוצג מסך ריק עם הודעה מתאימה?

2. **בדוק עם קבלה אחת:**
   - הגרף מציג נתונים נכונים?
   - המוצרים מוצגים נכון?

3. **בדוק עם תקופות שונות:**
   - שבוע/חודש/3 חודשים/שנה
   - הנתונים משתנים בהתאם?

4. **בדוק עם קטגוריות חדשות:**
   - קטגוריות שלא במיפוי מקבלות צבע 'אחר'?

---

## 🐛 טיפול בבעיות נפוצות

### בעיה 1: גרף העוגה ריק

**סיבה אפשרית:** `categoryBreakdown` מחזיר רשימה ריקה

**פתרון:**
```dart
// ב-_getCategoryData(), וודא שיש fallback:
return stats.categoryBreakdown ?? _getMockCategoryDataWithColors();
```

### בעיה 2: צבעים לא נכונים

**סיבה אפשרית:** קטגוריה לא במיפוי `_categoryColors`

**פתרון:** הוסף את הקטגוריה למיפוי או השתמש ב-fallback:
```dart
'color': categoryColors[category] ?? Colors.grey
```

### בעיה 3: ביצועים איטיים

**סיבה אפשרית:** יותר מדי קבלות לחישוב

**פתרון:** הגבל את מספר הקבלות או שמור בקאש:
```dart
// שמור את התוצאה ב-HomeStatsService
await _saveToCache(stats);
```

---

## 📝 רשימת משימות (Checklist)

- [ ] הוסף שדה `categoryBreakdown` ל-HomeStats
- [ ] הוסף שדה `topProducts` ל-HomeStats
- [ ] הוסף פונקציה `_calculateCategoryBreakdown()`
- [ ] הוסף פונקציה `_calculateTopProducts()`
- [ ] קרא לפונקציות החדשות ב-`calculateStats()`
- [ ] עדכן `_getCategoryData()` ב-InsightsScreen
- [ ] עדכן `_getTopExpenses()` ב-InsightsScreen
- [ ] בדוק עם 0 קבלות
- [ ] בדוק עם קבלה אחת
- [ ] בדוק עם מספר תקופות
- [ ] מחק/סמן את הנתונים הדמה (אופציונלי)

---

## 🎯 סיכום

אחרי ביצוע כל השלבים:
1. ✅ InsightsScreen יציג נתונים אמיתיים מהקבלות
2. ✅ הגרף יעדכן לפי תקופה שנבחרה
3. ✅ הוצאות עיקריות יראו את המוצרים האמיתיים
4. ✅ יש fallback לנתונים דמה במקרה של שגיאה

---

**📅 עדכון אחרון:** נוצר במקביל לשיפור התיעוד של InsightsScreen  
**👤 יוצר:** AI Assistant  
**🔗 קבצים קשורים:**
- `lib/screens/insights/insights_screen.dart`
- `lib/services/home_stats_service.dart`
