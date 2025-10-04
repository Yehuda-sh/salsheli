# 📋 CODE_REVIEW_CHECKLIST.md

> **תיעוד:** מדריך בדיקת קבצים לפרויקט "סל שלי" (Mobile-Only Flutter App)  
> **שימוש:** קרא קובץ זה ביחד עם MOBILE_GUIDELINES.md לפני בדיקת קוד

**לקריאה:** Claude Code - קרא קובץ זה לפני כל עבודה על הפרויקט!

---

## 🎯 מטרת הקובץ

קובץ זה עוזר לבדוק קבצים בפרויקט בצורה מהירה ושיטתית. הוא **משלים** את MOBILE_GUIDELINES.md ולא מחליף אותו.

---

## 📚 כללי זהב - תמיד בדוק!

### ✅ כל קובץ חייב

- [ ] **תיעוד בראש הקובץ** - נתיב + תיאור קצר

  ```dart
  // 📄 File: lib/providers/shopping_lists_provider.dart
  // תיאור: Provider לניהול רשימות קניות
  ```

- [ ] **אין Web imports**

  ```dart
  // ❌ אסור
  import 'dart:html';

  // ✅ מותר
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  ```

- [ ] **אין שימוש ב-localStorage/sessionStorage**

  ```dart
  // ❌ אסור
  localStorage.setItem('key', 'value');

  // ✅ מותר
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('key', 'value');
  ```

---

## 🗂️ בדיקה לפי סוג קובץ

### 1️⃣ Providers (State Management)

#### ✅ Checklist מהיר

- [ ] משתמש ב-`ChangeNotifier`
- [ ] מחובר ל-Repository (לא עושה פעולות ישירות)
- [ ] יש `dispose()` אם צריך
- [ ] Getters מחזירים `unmodifiable` או `immutable`
- [ ] כל פעולה async עם try/catch
- [ ] **ProxyProvider:** יש `lazy: false` אם צריך אתחול מיידי
- [ ] **ProxyProvider:** בדיקה ב-`update()` אם באמת צריך לעדכן (לא לעשות פעולות כפולות)
- [ ] **skipInitialLoad Pattern:** אם תלוי ב-Provider אחר, דחה אתחול עד שהתלות מוכנה

#### 📝 דוגמה

```dart
// ✅ טוב - Provider נכון
class ShoppingListsProvider with ChangeNotifier {
  final ShoppingListsRepository _repository;
  List<ShoppingList> _lists = [];

  ShoppingListsProvider({required ShoppingListsRepository repository})
      : _repository = repository;

  // ✅ Getter מוגן
  List<ShoppingList> get lists => List.unmodifiable(_lists);

  // ✅ פעולה דרך Repository
  Future<void> loadLists() async {
    try {
      _lists = await _repository.fetchLists(householdId);
      notifyListeners();
    } catch (e) {
      // טיפול בשגיאה
    }
  }

  @override
  void dispose() {
    // ניקוי
    super.dispose();
  }
}

// ❌ רע - Provider לא נכון
class BadProvider with ChangeNotifier {
  List<ShoppingList> lists = []; // ❌ ניתן לשינוי מבחוץ

  // ❌ קריאה ישירה ל-API בלי Repository
  Future<void> loadLists() async {
    final response = await http.get('https://api.com/lists');
    lists = jsonDecode(response.body);
    notifyListeners();
  }
}
```

---

### 2️⃣ Screens (UI)

#### ✅ Checklist מהיר

- [ ] עוטף ב-`SafeArea`
- [ ] כל תוכן scrollable (אם ארוך)
- [ ] משתמש ב-`Consumer` או `context.watch` לקריאת state
- [ ] משתמש ב-`context.read` לפעולות בלבד
- [ ] כפתורים בגודל מינימלי 48x48
- [ ] אין גדלים קבועים (hard-coded)
- [ ] padding symmetric (לא only - בגלל RTL)

#### 📝 דוגמה

```dart
// ✅ טוב - Screen נכון
class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // ✅ SafeArea
        child: Consumer<ShoppingListsProvider>( // ✅ Consumer
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder( // ✅ scrollable
              padding: EdgeInsets.symmetric(horizontal: 16), // ✅ symmetric
              itemCount: provider.lists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  minVerticalPadding: 24, // ✅ גודל מגע מספיק
                  title: Text(provider.lists[index].name),
                  onTap: () {
                    // ✅ פעולה עם context.read
                    context.read<ShoppingListsProvider>().openList(index);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ❌ רע - Screen לא נכון
class BadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ אין SafeArea
    // ❌ קריאת Provider בלי Consumer
    final provider = context.read<ShoppingListsProvider>();

    return Container(
      width: 1920, // ❌ גודל קבוע
      height: 1080, // ❌ גודל קבוע
      padding: EdgeInsets.only(left: 16), // ❌ לא תומך RTL
      child: Column( // ❌ לא scrollable
        children: provider.lists.map((list) =>
          GestureDetector(
            child: Container(
              width: 30, // ❌ גודל מגע קטן מדי
              height: 30,
              child: Text(list.name),
            ),
          )
        ).toList(),
      ),
    );
  }
}
```

---

### 3️⃣ Models (Data Classes)

#### ✅ Checklist מהיר

- [ ] יש `@JsonSerializable()` (אם JSON)
- [ ] שדות `final` (immutable)
- [ ] יש `copyWith()` method
- [ ] יש `*.g.dart` file (אם JSON או Hive)
- [ ] constructor נכון עם `required`/optional
- [ ] **Hive Models:** יש `@HiveType` ו-`@HiveField` על כל שדה
- [ ] **Hive Models:** TypeAdapter נוצר עם `build_runner`

#### 📝 דוגמה

```dart
// ✅ טוב - Model נכון
@JsonSerializable(explicitToJson: true)
class ShoppingList {
  final String id;
  final String name;
  final List<ReceiptItem> items;

  const ShoppingList({
    required this.id,
    required this.name,
    this.items = const [],
  });

  ShoppingList copyWith({
    String? name,
    List<ReceiptItem>? items,
  }) {
    return ShoppingList(
      id: id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListFromJson(json);

  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);
}

// ❌ רע - Model לא נכון
class BadModel {
  String id; // ❌ לא final
  String name; // ❌ לא final
  List<ReceiptItem> items; // ❌ ניתן לשינוי

  BadModel(this.id, this.name, this.items);

  // ❌ אין copyWith
  // ❌ אין JSON serialization
}
```

---

### 4️⃣ Repositories (Data Layer)

#### ✅ Checklist מהיר

- [ ] יש ממשק (abstract class)
- [ ] פעולות async עם Future
- [ ] שמות פעולות ברורים (fetch, save, delete)
- [ ] לא עושה notifyListeners (זה תפקיד Provider!)
- [ ] מחזיר מודלים, לא JSON
- [ ] **Hybrid Repository:** יש Fallback Strategy אם API נכשל
- [ ] **Local Repository (Hive):** TypeAdapter רשום וקיים *.g.dart

#### 📝 דוגמה

```dart
// ✅ טוב - Repository נכון

// ממשק
abstract class ShoppingListsRepository {
  Future<List<ShoppingList>> fetchLists(String householdId);
  Future<ShoppingList> saveList(ShoppingList list, String householdId);
  Future<void> deleteList(String id, String householdId);
}

// מימוש מקומי
class LocalShoppingListsRepository implements ShoppingListsRepository {
  final SharedPreferences _prefs;

  @override
  Future<List<ShoppingList>> fetchLists(String householdId) async {
    final json = _prefs.getString('lists_$householdId');
    if (json == null) return [];

    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((item) => ShoppingList.fromJson(item)).toList();
  }

  @override
  Future<ShoppingList> saveList(ShoppingList list, String householdId) async {
    // שמירה...
    return list;
  }
}

// ❌ רע - Repository לא נכון
class BadRepository {
  // ❌ לא async
  List<ShoppingList> getLists() {
    return [];
  }

  // ❌ מחזיר JSON במקום מודל
  Map<String, dynamic> getList(String id) {
    return {};
  }
}
```

---

### 5️⃣ Services (Business Logic)

#### ✅ Checklist מהיר

- [ ] שיטות static (אין state פנימי)
- [ ] פרמטרים nullable עם בדיקות null
- [ ] Logging מפורט בכל שלב (debugPrint)
- [ ] Error handling עם try/catch
- [ ] חישובים אמיתיים (לא Mock) אם יש נתונים זמינים
- [ ] Fallback values אם אין נתונים
- [ ] תיעוד TODO ברור למה שחסר

#### 📝 דוגמה

```dart
// ✅ טוב - Service נכון
class HomeStatsService {
  // ✅ Static method
  static Future<HomeStats> calculateStats({
    required List<Receipt> receipts,
    required List<ShoppingList> shoppingLists,
    required List<InventoryItem> inventory, // ✅ כל התלויות
    int monthsBack = 4,
  }) async {
    debugPrint('📊 מתחיל חישוב סטטיסטיקות...');
    debugPrint('   📄 קבלות: ${receipts.length}');
    debugPrint('   📋 רשימות: ${shoppingLists.length}');
    debugPrint('   📦 מלאי: ${inventory.length}');

    // ✅ חישוב עם בדיקת null
    final monthlySpent = _calculateMonthlySpent(receipts);
    final lowInventory = _calculateLowInventoryCount(inventory);
    
    debugPrint('   💰 הוצאה חודשית: ₪${monthlySpent.toStringAsFixed(2)}');
    debugPrint('   ⚠️ מלאי נמוך: $lowInventory פריטים');
    
    return HomeStats(...);
  }

  // ✅ בדיקת null תחילה
  static double _calculateMonthlySpent(List<Receipt>? receipts) {
    if (receipts == null || receipts.isEmpty) {
      debugPrint('   ℹ️ אין קבלות');
      return 0.0;
    }
    // חישוב...
  }
}

// ❌ רע - Service לא נכון
class BadService {
  List<Receipt> receipts = []; // ❌ יש state

  // ❌ לא static, לא async, אין logging
  double calculateSpent() {
    return receipts.fold(0, (sum, r) => sum + r.total);
  }
}
```

---

### 6️⃣ Caching Patterns

#### ✅ Checklist מהיר

- [ ] Cache key מורכב מכל המשתנים שמשפיעים על התוצאה
- [ ] Cache מנוקה כשהמשתנים משתנים
- [ ] יש getter שבודק cache לפני חישוב
- [ ] Cache לא מתבצע על נתונים שמשתנים בתדירות גבוהה

#### 📝 דוגמה

```dart
// ✅ טוב - Caching נכון
class MyWidget extends StatefulWidget {
  List<Item> _cachedItems = [];
  String _cacheKey = "";

  List<Item> get filteredItems {
    // ✅ Cache key מכל המשתנים
    final key = "$location|$search|$sortBy";

    // ✅ בדיקת cache
    if (key == _cacheKey && _cachedItems.isNotEmpty) {
      return _cachedItems;
    }

    // חישוב מחדש
    _cachedItems = _applyFilters();
    _cacheKey = key;
    return _cachedItems;
  }

  void _updateFilter(String newSearch) {
    setState(() {
      search = newSearch;
      _cacheKey = ""; // ✅ ניקוי cache
    });
  }
}

// ❌ רע - Caching לא נכון
class BadWidget extends StatefulWidget {
  List<Item> _cached = [];

  List<Item> get items {
    // ❌ אין cache key - לא יודע מתי לנקות
    if (_cached.isNotEmpty) return _cached;
    _cached = _applyFilters();
    return _cached;
  }

  void _updateFilter() {
    // ❌ לא מנקה cache!
    setState(() => search = newValue);
  }
}
```

---

### 7️⃣ JSON File Handling

#### ✅ Checklist מהיר

- [ ] בדיקת סוג JSON (`is List` או `is Map<String, dynamic>`)
- [ ] Logging של רכיב ראשון לדיבאג
- [ ] Type validation עם `whereType<T>()`
- [ ] Error handling אם הפורמט לא צפוי

#### 📝 דוגמה

```dart
// ✅ טוב - JSON Handling נכון
Future<List<Product>> loadProducts() async {
  final content = await rootBundle.loadString('assets/products.json');
  final data = json.decode(content);

  debugPrint('📂 קורא JSON...');
  debugPrint('   סוג: ${data.runtimeType}');

  // ✅ בדיקת סוג
  if (data is List) {
    debugPrint('   ✅ Array עם ${data.length} פריטים');
    
    // ✅ Type validation
    final products = data
        .whereType<Map<String, dynamic>>()
        .map((item) => Product.fromJson(item))
        .toList();
    
    debugPrint('   ✅ נטענו ${products.length} מוצרים');
    return products;
  }

  // ✅ Fallback
  debugPrint('   ⚠️ פורמט לא צפוי');
  return [];
}

// ❌ רע - JSON Handling לא נכון
Future<List<Product>> badLoad() async {
  final content = await rootBundle.loadString('assets/products.json');
  final data = json.decode(content);

  // ❌ הנחה שזה Map בלי בדיקה
  final products = (data as Map<String, dynamic>).values
      .map((item) => Product.fromJson(item))
      .toList();

  return products; // יקרוס אם data הוא Array!
}
```

---

## 🎨 בדיקות UI ספציפיות

### Touch Targets (גודל מינימלי)

```dart
// ✅ טוב
GestureDetector(
  onTap: () {},
  child: Container(
    width: 48,
    height: 48,
    child: Icon(Icons.close),
  ),
)

// ❌ רע
IconButton(
  iconSize: 16, // ❌ קטן מדי
  onPressed: () {},
  icon: Icon(Icons.close),
)
```

### Font Sizes

```dart
// ✅ טוב
TextStyle(
  fontSize: 14, // Body
  fontSize: 16, // Body Large
  fontSize: 20, // Heading
  fontSize: 24, // Title
)

// ❌ רע
TextStyle(
  fontSize: 10, // ❌ קטן מדי
  fontSize: 32, // ❌ גדול מדי לכותרת מובייל
)
```

### Spacing (ריווחים)

```dart
// ✅ טוב - כפולות של 8
padding: EdgeInsets.all(8)
padding: EdgeInsets.all(16)
padding: EdgeInsets.all(24)
SizedBox(height: 8)

// ❌ רע - לא עקבי
padding: EdgeInsets.all(13)
SizedBox(height: 7)
```

---

---

## 🔍 בדיקות Logging

### Logging Best Practices

```dart
// ✅ טוב - Logging מפורט
class MyProvider with ChangeNotifier {
  Future<void> loadData() async {
    debugPrint('🚀 MyProvider: מתחיל טעינה...');
    
    try {
      final data = await _repository.fetch();
      debugPrint('   ✅ נטענו ${data.length} פריטים');
      
      _items = data;
      notifyListeners();
      debugPrint('   🔔 notifyListeners() - עדכון UI');
      
    } catch (e) {
      debugPrint('   ❌ שגיאה: $e');
      rethrow;
    }
  }
}

// ❌ רע - בלי Logging
class BadProvider with ChangeNotifier {
  Future<void> loadData() async {
    _items = await _repository.fetch();
    notifyListeners();
  }
}
```

**אמוג'י מומלצים:**
- 🚀 התחלת פעולה
- ✅ הצלחה
- ❌ שגיאה
- ⚠️ אזהרה
- 🔔 notifyListeners
- 🔄 עדכון/רענון
- 📊 סטטיסטיקות
- 💾 שמירה
- 📂 קריאת קובץ

---

## 🚀 הנחיות ל-Claude Code

כשאתה (Claude Code) עובד על פרויקט זה:

### 1. לפני כל עבודה

- [ ] קרא את `MOBILE_GUIDELINES.md`
- [ ] קרא את `CODE_REVIEW_CHECKLIST.md` (הקובץ הזה)
- [ ] בדוק איזה סוג קובץ אתה הולך לעבוד עליו

### 2. בזמן עבודה

- [ ] השתמש ב-checklist המתאים מלמעלה
- [ ] בדוק כל נקודה לפני שממשיך
- [ ] אם לא בטוח - **שאל** את המשתמש!

### 3. לפני שליחת הקובץ

- [ ] עבור על הchecklist שוב
- [ ] ודא שיש תיעוד בראש הקובץ
- [ ] הרץ `flutter analyze` מנטלית

### 4. דוגמה לתגובה טובה

```
✅ בדקתי את הקובץ לפי CODE_REVIEW_CHECKLIST.md:

Provider:
✅ מחובר ל-Repository
✅ יש dispose()
✅ Getters מוגנים
✅ Error handling
✅ Logging מפורט

UI:
✅ SafeArea
✅ Consumer לstate
✅ גדלי מגע 48x48+

Service (אם רלוונטי):
✅ שיטות static
✅ Null safety
✅ Fallback values
✅ Logging עם אמוג'י

הקובץ תקין ומוכן לשימוש!
```

---

## 🔍 טיפים לבדיקה מהירה

### איך למצוא בעיות מהר?

1. **חפש בקובץ:**

   - `Ctrl+F` → `dart:html` → אם מצאת = ❌ בעיה
   - `Ctrl+F` → `localStorage` → אם מצאת = ❌ בעיה
   - `Ctrl+F` → `Platform.isWindows` → אם מצאת = ❌ בעיה
   - `Ctrl+F` → `TODO` → סמן לתיקון עתידי
   - `Ctrl+F` → `debugPrint` → אם אין בכלל = ⚠️ חסר logging

2. **בדוק את השורה הראשונה:**

   - יש `// 📄 File:` = ✅ טוב
   - אין = ❌ הוסף תיעוד

3. **בדוק imports:**

   - רק `package:flutter` ו-`package:` אחרים = ✅ טוב
   - יש `dart:html` = ❌ בעיה

4. **אם זה Screen:**

   - חפש `SafeArea` = אם אין = ⚠️ אולי בעיה
   - חפש `Consumer` או `context.watch` = צריך להיות

5. **אם זה Provider:**
   - חפש `_repository` = צריך להיות
   - חפש `http.get` או `http.post` ישירות = ❌ בעיה (צריך דרך Repository)
   - חפש `ProxyProvider` ב-main.dart = בדוק `lazy: false` אם צריך
   - חפש `debugPrint` = צריך להיות לפחות 2-3

6. **אם זה Service:**
   - חפש `static` = כל המתודות צריכות להיות
   - חפש `debugPrint` = צריך בכל שלב חשוב
   - חפש `if (param == null` = Null safety
   - חפש `TODO` = סמן מה חסר

7. **אם זה JSON loading:**
   - חפש `is List` או `is Map` = צריך בדיקת סוג
   - חפש `whereType` = Type validation
   - חפש `debugPrint.*runtimeType` = Logging של הסוג

---

## 📊 סיכום מהיר

| סוג קובץ        | בדיקה ראשית                                        | זמן משוער |
| --------------- | -------------------------------------------------- | --------- |
| Provider        | Repository + ChangeNotifier + dispose + Logging    | 2-3 דקות  |
| ProxyProvider   | lazy: false + update logic + dependencies          | 3-4 דקות  |
| Screen          | SafeArea + Consumer + Touch Targets                | 3-4 דקות  |
| Model           | @JsonSerializable + copyWith + final               | 1-2 דקות  |
| Hive Model      | @HiveType + @HiveField + *.g.dart                  | 2 דקות    |
| Repository      | Abstract + async + מחזיר מודלים                    | 2 דקות    |
| Hybrid Repo     | Fallback + Local + API strategy                    | 3-4 דקות  |
| Service         | Static + Null Safety + Logging + Fallback          | 3 דקות    |
| JSON Handler    | Type check (List/Map) + Logging + Error handling   | 2 דקות    |
| Cache Pattern   | Cache key + Clear logic + Getter                   | 2 דקות    |

---

## ✨ הערה אחרונה

קובץ זה **לא מחליף** את MOBILE_GUIDELINES.md - הוא **משלים** אותו.

- **MOBILE_GUIDELINES.md** = הנחיות כלליות מפורטות
- **CODE_REVIEW_CHECKLIST.md** (הקובץ הזה) = בדיקה מהירה לקובץ ספציפי

**השתמש בשניהם יחד!**

---

**עדכון אחרון:** ספטמבר 2025  
**גרסה:** 1.0.0  
**תאימות:** Flutter 3.x, Dart 3.x, Mobile Only (Android & iOS)
