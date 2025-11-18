# 🔄 מערכת סנכרון מחירים אוטומטי

מערכת זו מעדכנת מחירים ומוצרים ברקע בעת כניסת המשתמש לאפליקציה.

---

## 📋 רכיבי המערכת

### 1️⃣ **PriceSyncService** - שירות הסנכרון
📄 `lib/services/price_sync_service.dart`

**תפקיד:**
- מוריד עדכוני מחירים מ-Shufersal
- שומר את העדכונים ב-SharedPreferences
- מבצע סנכרון **פעם ב-24 שעות**
- רץ **ברקע** בלי לחסום את האפליקציה

**שימוש:**
```dart
final syncService = PriceSyncService();

// סנכרון אוטומטי (רק אם עבר יום)
await syncService.syncIfNeeded();

// סנכרון מאולץ (גם אם לא עבר יום)
await syncService.forceSync();

// קבל עדכונים שמורים
final updates = await syncService.getSyncedUpdates('bakery');
```

---

### 2️⃣ **AutoSyncInitializer** - אתחול אוטומטי
📄 `lib/services/auto_sync_initializer.dart`

**תפקיד:**
- מאתחל סנכרון אוטומטי בהפעלת האפליקציה
- קורא ל-`PriceSyncService.syncIfNeeded()` ברקע
- **לא חוסם** את הפעלת האפליקציה

**אתחול (ב-main.dart):**
```dart
void main() async {
  // ... Firebase, Hive, etc.

  // 🔄 Initialize Auto Price Sync
  AutoSyncInitializer.initialize();

  runApp(MyApp());
}
```

**שימוש ב-UI:**
```dart
// כפתור "רענן מחירים"
ElevatedButton(
  onPressed: () async {
    final success = await AutoSyncInitializer.forceSync();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('מחירים עודכנו!')),
      );
    }
  },
  child: Text('רענן מחירים'),
)
```

---

### 3️⃣ **ProductsMerger** - מיזוג נתונים
📄 `lib/services/products_merger.dart`

**תפקיד:**
- ממזג מוצרים מ-`assets/` (בסיס) עם עדכונים מ-SharedPreferences
- מעדכן מחירים למוצרים קיימים
- מוסיף מוצרים חדשים

**שימוש ב-ProductsProvider:**
```dart
// טען מוצרים מ-assets
final baseProducts = await loadFromAssets('bakery');

// מזג עם עדכונים
final merger = ProductsMerger();
final mergedProducts = await merger.mergeProducts(baseProducts, 'bakery');

// השתמש במוצרים הממוזגים
_products = mergedProducts;
```

---

## 🔄 זרימת הנתונים

```
1. האפליקציה מתחילה
   ↓
2. AutoSyncInitializer.initialize() נקרא
   ↓
3. PriceSyncService.syncIfNeeded() רץ ברקע
   ↓
4. בודק: האם עבר יום מהסנכרון האחרון?
   ├─ לא → מפסיק
   └─ כן → ממשיך ↓

5. מוריד עדכונים מ-Shufersal
   ↓
6. שומר ב-SharedPreferences לפי list_type:
   - sync_data_bakery
   - sync_data_butcher
   - sync_data_supermarket
   - וכו'...
   ↓
7. שומר תאריך סנכרון: last_price_sync
   ↓
8. גמר! ✅
```

---

## 📦 מבנה הנתונים

### **assets/** (קבצים סטטיים)
```
assets/data/list_types/
├── bakery.json       ← מוצרים בסיסיים (read-only)
├── butcher.json      ← מוצרים בסיסיים
└── supermarket.json  ← מוצרים בסיסיים
```

### **SharedPreferences** (עדכונים דינמיים)
```
Key: sync_data_bakery
Value: [
  {
    "barcode": "7290001234567",
    "name": "חלב 3%",
    "price": 5.9,  ← מחיר מעודכן!
    "category": "מוצרי חלב"
  },
  ...
]

Key: last_price_sync
Value: "2024-11-18T10:30:00.000"
```

### **מוצר ממוזג (ב-ProductsProvider)**
```dart
{
  "name": "לחם לבן",        // מ-assets
  "category": "מאפים",       // מ-assets
  "barcode": "1234567890",   // מ-assets
  "price": 10.5,             // ← מ-SharedPreferences (עודכן!)
  "icon": "🍞",              // מ-assets
  "unit": "יחידה"            // מ-assets
}
```

---

## 🛠️ התאמה אישית

### **שינוי מרווח הסנכרון**

ערוך את `PriceSyncService`:
```dart
// במקום 24 שעות:
static const Duration _syncInterval = Duration(hours: 24);

// שנה ל-12 שעות:
static const Duration _syncInterval = Duration(hours: 12);

// או פעם בשבוע:
static const Duration _syncInterval = Duration(days: 7);
```

---

### **הוספת מקור נתונים אחר**

ערוך את `_fetchPriceUpdates()` ב-`PriceSyncService`:

```dart
Future<List<Map<String, dynamic>>> _fetchPriceUpdates() async {
  // במקום Shufersal, השתמש ב-API אחר:

  final response = await http.get(
    Uri.parse('https://api.example.com/prices'),
  );

  final data = jsonDecode(response.body);

  return data.map((item) => {
    'barcode': item['barcode'],
    'price': item['price'],
    'name': item['name'],
    'list_type': _mapToListType(item['category']),
  }).toList();
}
```

---

## 🧪 בדיקה

### **בדיקה ידנית:**

```dart
// 1. אפס את הסנכרון
final syncService = PriceSyncService();
await syncService.clearSyncData();

// 2. כפה סנכרון
final success = await syncService.forceSync();
print('סנכרון הצליח: $success');

// 3. בדוק מתי היה הסנכרון האחרון
final lastSync = await syncService.getLastSyncTime();
print('סנכרון אחרון: $lastSync');

// 4. בדוק את העדכונים
final updates = await syncService.getSyncedUpdates('bakery');
print('${updates?.length ?? 0} עדכונים למאפייה');
```

---

## ⚠️ חשוב לדעת

### 1. **assets/ הם read-only**
לא ניתן לשנות קבצי assets מהאפליקציה!
לכן אנחנו שומרים עדכונים ב-SharedPreferences.

### 2. **המיזוג קורה ב-ProductsProvider**
כדי להשתמש במחירים המעודכנים, צריך:
```dart
// ב-ProductsProvider:
final baseProducts = await _repository.getProductsByListType(listType);
final merger = ProductsMerger();
final mergedProducts = await merger.mergeProducts(baseProducts, listType);
_products = mergedProducts; // ← השתמש במוצרים הממוזגים!
```

### 3. **הסנכרון רץ ברקע**
הסנכרון לא חוסם את האפליקציה:
- ✅ האפליקציה נפתחת מיד
- ✅ הסנכרון רץ בשקט ברקע
- ✅ המשתמש לא מרגיש שום דבר

### 4. **מה קורה אם הסנכרון נכשל?**
- ✅ האפליקציה ממשיכה לעבוד רגיל
- ✅ משתמשת במוצרים מ-assets (בסיס)
- ✅ ננסה שוב ב-24 השעות הבאות

---

## 🎯 TODO - מה צריך לממש

### ✅ מוכן:
- [x] PriceSyncService - מבנה בסיסי
- [x] AutoSyncInitializer - אתחול אוטומטי
- [x] ProductsMerger - מיזוג נתונים
- [x] אינטגרציה ב-main.dart

### ⏳ צריך להשלים:

1. **ממש את `_fetchPriceUpdates()`** ב-PriceSyncService
   - כרגע מחזיר רשימה ריקה
   - צריך להוסיף לוגיקה אמיתית להורדה מ-Shufersal

2. **שלב את ProductsMerger ב-ProductsProvider**
   - הוסף שורת קוד שמשתמשת ב-merger
   - ב-`loadProducts()` או `_loadProductsByTypeOrAll()`

3. **בדיקות**
   - תבדוק שהסנכרון עובד
   - תבדוק שהמחירים מתעדכנים

---

## 🚀 התקנה

### תלויות נדרשות:

```yaml
# pubspec.yaml
dependencies:
  shared_preferences: ^2.2.2
  http: ^1.1.0
```

התקן:
```bash
flutter pub get
```

---

**תאריך יצירה:** 18.11.2024
**גרסה:** 1.0
**סטטוס:** ⏳ דורש השלמת `_fetchPriceUpdates()`
