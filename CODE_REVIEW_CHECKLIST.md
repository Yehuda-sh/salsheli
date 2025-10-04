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
- [ ] **חישובים אמיתיים (לא Mock) אם יש נתונים זמינים** - חשוב!
- [ ] Fallback values **רק** אם אין נתונים
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
  
  // ✅ חישוב אמיתי עם Fallback
  static double _calculatePreviousSpent(
    double currentSpent,
    List<Map<String, dynamic>>? expenseTrend,
  ) {
    // אם יש נתונים אמיתיים - השתמש בהם!
    if (expenseTrend != null && expenseTrend.length >= 2) {
      final previousMonth = expenseTrend[expenseTrend.length - 2];
      final value = (previousMonth['value'] as num?)?.toDouble() ?? 0.0;
      debugPrint('   📊 חישוב אמיתי: הוצאה קודמת = ₪$value');
      return value;
    }
    
    // Fallback רק אם אין נתונים
    debugPrint('   ⚠️ אין מגמות - משתמש ב-Fallback (x1.15)');
    return currentSpent * 1.15;
  }
}

// ❌ רע - Service לא נכון
class BadService {
  List<Receipt> receipts = []; // ❌ יש state

  // ❌ לא static, לא async, אין logging
  double calculateSpent() {
    return receipts.fold(0, (sum, r) => sum + r.total);
  }
  
  // ❌ תמיד Mock - אף פעם לא משתמש בנתונים אמיתיים!
  double calculatePreviousSpent(double current) {
    return current * 1.15; // ❌ תמיד דמה
  }
}
```

#### 💡 כלל זהב: חישובים אמיתיים

**עיקרון:** אם יש נתונים אמיתיים זמינים - **השתמש בהם**!

```dart
// ❌ לא טוב - תמיד דמה
final previousSpent = totalSpent * 1.15; // תמיד דמה!

// ✅ טוב - אמיתי עם fallback
if (stats.expenseTrend.length >= 2) {
  // חישוב מנתונים אמיתיים
  previousSpent = stats.expenseTrend[...]['value'];
} else {
  // fallback רק אם אין נתונים
  previousSpent = totalSpent * 1.15;
}
```

**למה זה חשוב:**
- משתמשים מצפים לנתונים אמיתיים
- Mock/Fallback צריך להיות **זמני** בלבד
- תמיד תעד ב-TODO מה חסר

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

### 8️⃣ Hybrid Repositories (Local + API)

#### ✅ Checklist מהיר

- [ ] יש Repository מקומי (Hive/SharedPreferences)
- [ ] יש API Repository או Service
- [ ] יש Fallback Strategy - אם API נכשל → Local או Mock
- [ ] `initialize()` טוען מקומי תחילה, אח"כ API
- [ ] עדכונים חלקיים (לא טעינה מחדש של הכל)
- [ ] Logging מפורט לכל שלב (local/API/fallback)
- [ ] שמירה אוטומטית למקומי אחרי API

#### 📝 דוגמה

```dart
// ✅ טוב - Hybrid Repository
class HybridProductsRepository implements ProductsRepository {
  final LocalProductsRepository _localRepo;
  final ProductsApiService _apiService;

  // אתחול: Local תחילה, אח"כ API
  Future<void> initialize() async {
    debugPrint('🚀 HybridProductsRepository: מאתחל...');
    
    // בדוק אם יש נתונים מקומיים
    final localProducts = await _localRepo.getAllProducts();
    
    if (localProducts.isEmpty) {
      debugPrint('   📂 DB ריק - טוען מ-API...');
      try {
        final apiProducts = await _apiService.getProducts();
        if (apiProducts.isNotEmpty) {
          await _localRepo.saveProducts(apiProducts);
          debugPrint('   ✅ נשמרו ${apiProducts.length} מוצרים מ-API');
        } else {
          // Fallback למוצרים דמה
          await _loadFallbackProducts();
        }
      } catch (e) {
        debugPrint('   ❌ API נכשל: $e');
        await _loadFallbackProducts();
      }
    } else {
      debugPrint('   ✅ נטענו ${localProducts.length} מוצרים מקומיים');
    }
  }

  // עדכון חלקי - רק מחירים
  Future<void> refreshPrices() async {
    debugPrint('🔄 מרענן מחירים מ-API...');
    try {
      final apiProducts = await _apiService.getProducts();
      
      for (final apiProduct in apiProducts) {
        // עדכן רק מחיר, לא כל המוצר
        await _localRepo.updatePrice(
          apiProduct.barcode,
          apiProduct.price,
        );
      }
      debugPrint('   ✅ ${apiProducts.length} מחירים עודכנו');
    } catch (e) {
      debugPrint('   ❌ רענון נכשל: $e');
    }
  }

  // Fallback למוצרים דמה
  Future<void> _loadFallbackProducts() async {
    debugPrint('   ⚠️ טוען 8 מוצרים דמה (fallback)...');
    final fallback = [
      Product(barcode: '001', name: 'חלב 3%', icon: '🥛'),
      // ... עוד 7 מוצרים
    ];
    await _localRepo.saveProducts(fallback);
    debugPrint('   ✅ נשמרו ${fallback.length} מוצרים דמה');
  }
}

// ❌ רע - Hybrid לא נכון
class BadHybridRepo {
  // ❌ תמיד API, אין fallback
  Future<List<Product>> getProducts() async {
    return await _apiService.getProducts(); // יקרוס אם אין אינטרנט!
  }
}
```

---

### 9️⃣ Hive Models & Local Storage

#### ✅ Checklist מהיר

- [ ] יש `@HiveType(typeId: X)` - typeId ייחודי
- [ ] כל שדה עם `@HiveField(index)` - index רציף (0,1,2...)
- [ ] יש `*.g.dart` נוצר עם `build_runner`
- [ ] TypeAdapter רשום ב-`Hive.registerAdapter()`
- [ ] Box נפתח לפני שימוש: `Hive.openBox<T>()`
- [ ] שדות nullable מסומנים נכון
- [ ] יש `save()` method אם מרחיב HiveObject

#### 📝 דוגמה

```dart
// ✅ טוב - Hive Model
import 'package:hive/hive.dart';

part 'product_entity.g.dart';

@HiveType(typeId: 0) // ✅ typeId ייחודי
class ProductEntity extends HiveObject {
  @HiveField(0)
  final String barcode;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? category; // ✅ nullable
  
  @HiveField(3)
  final double? currentPrice; // ✅ נתון דינמי
  
  @HiveField(4)
  final DateTime? lastPriceUpdate;

  ProductEntity({
    required this.barcode,
    required this.name,
    this.category,
    this.currentPrice,
    this.lastPriceUpdate,
  });
}

// ✅ אתחול נכון
void main() async {
  await Hive.initFlutter();
  
  // רישום Adapter
  Hive.registerAdapter(ProductEntityAdapter());
  
  // פתיחת Box
  final box = await Hive.openBox<ProductEntity>('products');
  
  runApp(MyApp());
}

// ❌ רע - Hive לא נכון
class BadModel {
  // ❌ חסר @HiveType
  // ❌ חסר @HiveField
  final String name;
  
  BadModel(this.name);
}
```

#### 💡 פקודות Hive חשובות

```powershell
# יצירת *.g.dart
dart run build_runner build --delete-conflicting-outputs

# watch mode (אוטומטי)
dart run build_runner watch

# ניקוי קבצים ישנים
dart run build_runner clean
```

---

### 🔟 Undo Pattern with Data Preservation

#### ✅ Checklist מהיר

- [ ] שמירת **כל** הנתונים הנדרשים לביטול **לפני** המחיקה/שינוי
- [ ] SnackBar עם `SnackBarAction` לביטול
- [ ] duration של 5+ שניות (זמן לביטול)
- [ ] פעולת Undo משחזרת את המצב המדויק
- [ ] Logging של פעולת Undo

#### 📝 דוגמה

```dart
// ✅ טוב - Undo נכון
void _deleteCustomLocation(String key, String name, String emoji) {
  // ⚠️ חשוב! שמור את כל הנתונים לפני מחיקה
  final savedKey = key;
  final savedName = name;
  final savedEmoji = emoji;
  
  // מחיקה
  await provider.deleteLocation(key);
  debugPrint('🗑️ מחק מיקום: $name');
  
  // Snackbar עם Undo
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('המיקום "$name" נמחק'),
      action: SnackBarAction(
        label: 'בטל',
        onPressed: () async {
          debugPrint('↩️ Undo: משחזר מיקום $savedName');
          // שחזור עם הנתונים השמורים
          await provider.addLocation(
            savedName,
            emoji: savedEmoji,
          );
        },
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

// ❌ רע - Undo לא נכון
void _badDelete(String key) {
  await provider.deleteLocation(key);
  
  // ❌ לא שמר name ו-emoji!
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      action: SnackBarAction(
        label: 'בטל',
        onPressed: () {
          // ❌ אין לנו את הנתונים לשחזר!
          await provider.addLocation('???'); // מה השם? מה האמוג'י?
        },
      ),
    ),
  );
}
```

#### 💡 טיפ חשוב

**שמור תמיד:**
- ID/Key
- שם
- כל שדה מותאם (אייקון, צבע, וכו')
- אפילו שדות אופציונליים!

---

### 1️⃣1️⃣ Flutter Version-Specific Features

#### ✅ Checklist מהיר

- [ ] **Flutter 3.27+:** השתמש ב-`withValues()` במקום `withOpacity()`
- [ ] בדוק deprecated APIs בקוד ישן
- [ ] עדכן syntax לגרסה הנוכחית

#### 📝 דוגמה

```dart
// ✅ טוב - Flutter 3.27+
final backgroundColor = Colors.indigo.withValues(alpha: 0.1);
final textColor = Colors.red.withValues(alpha: 0.5);

// ❌ רע - deprecated
final backgroundColor = Colors.indigo.withOpacity(0.1); // ⚠️ deprecated
```

#### 💡 בדיקת גרסה

```powershell
flutter --version
# אם < 3.27 → עדכן או השתמש ב-withOpacity
# אם >= 3.27 → השתמש ב-withValues
```

---

### 1️⃣2️⃣ i18n & Multi-Language Mappings

#### ✅ Checklist מהיר

- [ ] מיפויים (כמו אמוג'י) תומכים בעברית **וגם** אנגלית
- [ ] יש Fallback אם Key לא נמצא
- [ ] לוגיקה דינמית: נסה עברית → נסה אנגלית → fallback
- [ ] Constants בעברית ובאנגלית מוגדרים בנפרד

#### 📝 דוגמה

```dart
// ✅ טוב - תמיכה רב-לשונית
class CategoryEmojiMapper {
  // מיפוי עברית
  static const Map<String, String> _hebrew = {
    'חלבי': '🥛',
    'ירקות': '🥬',
    'פירות': '🍎',
    // ...
  };
  
  // מיפוי אנגלית
  static const Map<String, String> _english = {
    'dairy': '🥛',
    'vegetables': '🥬',
    'fruits': '🍎',
    // ...
  };
  
  // לוגיקה דינמית
  static String getEmoji(String category) {
    // נסה עברית
    if (_hebrew.containsKey(category)) {
      return _hebrew[category]!;
    }
    // נסה אנגלית
    if (_english.containsKey(category)) {
      return _english[category]!;
    }
    // fallback
    return '📦';
  }
}

// שימוש:
final emoji = CategoryEmojiMapper.getEmoji('חלבי'); // 🥛
final emoji2 = CategoryEmojiMapper.getEmoji('dairy'); // 🥛
final emoji3 = CategoryEmojiMapper.getEmoji('unknown'); // 📦

// ❌ רע - רק אנגלית
static const categoryEmojis = {
  'dairy': '🥛', // ❌ לא יעבוד עם 'חלבי'
};

final emoji = categoryEmojis['חלבי'] ?? '📦'; // תמיד fallback!
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
   - חפש חישובים אמיתיים (לא תמיד Mock) = אם יש נתונים, השתמש בהם!

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
| Hive Model      | @HiveType + @HiveField + Adapter + *.g.dart        | 2-3 דקות  |
| Repository      | Abstract + async + מחזיר מודלים                    | 2 דקות    |
| Hybrid Repo     | Fallback + Local + API strategy                    | 3-4 דקות  |
| Service         | Static + Null Safety + Logging + Real Data         | 3 דקות    |
| JSON Handler    | Type check (List/Map) + Logging + Error handling   | 2 דקות    |
| Cache Pattern   | Cache key + Clear logic + Getter                   | 2 דקות    |
| Undo Pattern    | Data preservation + SnackBar + Duration            | 1-2 דקות  |
| i18n Mapping    | Hebrew + English + Fallback                        | 1-2 דקות  |

---

## ✨ הערה אחרונה

קובץ זה **לא מחליף** את MOBILE_GUIDELINES.md - הוא **משלים** אותו.

- **MOBILE_GUIDELINES.md** = הנחיות כלליות מפורטות
- **CODE_REVIEW_CHECKLIST.md** (הקובץ הזה) = בדיקה מהירה לקובץ ספציפי

**השתמש בשניהם יחד!**

---

**עדכון אחרון:** אוקטובר 2025  
**גרסה:** 2.0.0 (כולל Hybrid Repos, Hive, Undo Pattern, i18n)  
**תאימות:** Flutter 3.27+, Dart 3.x, Mobile Only (Android & iOS)
