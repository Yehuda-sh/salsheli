# 🔗 דוגמת שילוב ProductsMerger ב-ProductsProvider

דוגמה מלאה איך לשלב את מערכת הסנכרון ב-ProductsProvider.

---

## 📝 שינויים נדרשים

### 1️⃣ הוסף import

```dart
// בתחילת הקובץ lib/providers/products_provider.dart

import '../services/products_merger.dart';
```

---

### 2️⃣ הוסף instance של ProductsMerger

```dart
class ProductsProvider with ChangeNotifier {
  final ProductsRepository _repository;
  final ProductsMerger _merger = ProductsMerger(); // ← הוסף זאת!

  // ... שאר הקוד
}
```

---

### 3️⃣ עדכן את `_loadProductsByTypeOrAll()`

**לפני:**
```dart
Future<List<Map<String, dynamic>>> _loadProductsByTypeOrAll({
  int? limit,
  int? offset,
}) async {
  if (_selectedListType != null && _repository is LocalProductsRepository) {
    final localRepo = _repository as LocalProductsRepository;
    debugPrint('   🎯 טוען מוצרים לפי list_type: $_selectedListType');
    return await localRepo.getProductsByListType(
      _selectedListType!,
      limit: limit,
      offset: offset,
    );
  }

  debugPrint('   📦 טוען כל המוצרים (supermarket)');
  return await _repository.getAllProducts(
    limit: limit,
    offset: offset,
  );
}
```

**אחרי:**
```dart
Future<List<Map<String, dynamic>>> _loadProductsByTypeOrAll({
  int? limit,
  int? offset,
}) async {
  // 1. טען מוצרים בסיסיים מ-assets
  List<Map<String, dynamic>> baseProducts;

  if (_selectedListType != null && _repository is LocalProductsRepository) {
    final localRepo = _repository as LocalProductsRepository;
    debugPrint('   🎯 טוען מוצרים לפי list_type: $_selectedListType');
    baseProducts = await localRepo.getProductsByListType(
      _selectedListType!,
      limit: limit,
      offset: offset,
    );
  } else {
    debugPrint('   📦 טוען כל המוצרים (supermarket)');
    baseProducts = await _repository.getAllProducts(
      limit: limit,
      offset: offset,
    );
  }

  // 2. מזג עם עדכונים מסונכרנים (אם יש)
  if (_selectedListType != null) {
    debugPrint('   🔀 ממזג עם עדכונים מסונכרנים...');
    final mergedProducts = await _merger.mergeProducts(
      baseProducts,
      _selectedListType!,
    );
    return mergedProducts;
  }

  return baseProducts;
}
```

---

## 🎯 זהו!

עכשיו הקוד:
1. ✅ טוען מוצרים מ-assets (כמו קודם)
2. ✅ ממזג עם עדכונים מ-SharedPreferences
3. ✅ מעדכן מחירים אוטומטית
4. ✅ מוסיף מוצרים חדשים

---

## 🧪 בדיקה

### בדיקה 1: בדוק שהמיזוג קורה

```dart
// הוסף debug print ב-ProductsProvider:
debugPrint('📊 לפני מיזוג: ${baseProducts.length} מוצרים');
final mergedProducts = await _merger.mergeProducts(
  baseProducts,
  _selectedListType!,
);
debugPrint('📊 אחרי מיזוג: ${mergedProducts.length} מוצרים');
```

**צפוי לראות בקונסול:**
```
📊 לפני מיזוג: 41 מוצרים
🔀 ProductsMerger: ממזג 41 מוצרים בסיס + 5 עדכונים
   ✅ 3 מחירים עודכנו, 2 מוצרים נוספו
📊 אחרי מיזוג: 43 מוצרים
```

---

### בדיקה 2: וודא שהמחירים השתנו

```dart
// לפני המיזוג:
print('מחיר לחם לבן: ${baseProducts[0]['price']}'); // 10.0

// אחרי המיזוג:
print('מחיר לחם לבן: ${mergedProducts[0]['price']}'); // 10.5 (עודכן!)
```

---

### בדיקה 3: בדוק עם UI

1. פתח את האפליקציה
2. לך לרשימת קניות → הוסף מוצר
3. חפש מוצר שהמחיר שלו עודכן
4. ודא שהמחיר החדש מוצג

---

## ⚙️ אופציונלי: כפתור "רענן מחירים"

אם תרצה להוסיף כפתור ידני לרענון:

```dart
// ב-ProductsProvider:
Future<void> refreshPrices() async {
  debugPrint('🔄 ProductsProvider: מרענן מחירים...');

  // כפה סנכרון
  final success = await AutoSyncInitializer.forceSync();

  if (success) {
    // טען מחדש את המוצרים (יכלול את העדכונים החדשים)
    await loadProducts();
    debugPrint('✅ ProductsProvider: מחירים רוענו!');
  } else {
    debugPrint('❌ ProductsProvider: רענון נכשל');
  }
}
```

**שימוש ב-UI:**
```dart
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: () async {
    final provider = context.read<ProductsProvider>();
    await provider.refreshPrices();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('מחירים עודכנו!')),
    );
  },
)
```

---

## 📊 סטטיסטיקות (אופציונלי)

הצג למשתמש מתי היה עדכון אחרון:

```dart
// ב-UI:
FutureBuilder<DateTime?>(
  future: AutoSyncInitializer.getLastSyncTime(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return Text('עדכון אחרון: לא ידוע');
    }

    final lastSync = snapshot.data!;
    final ago = DateTime.now().difference(lastSync);

    return Text('עדכון אחרון: לפני ${ago.inHours} שעות');
  },
)
```

---

**זהו! המערכת מוכנה לשימוש** 🚀
