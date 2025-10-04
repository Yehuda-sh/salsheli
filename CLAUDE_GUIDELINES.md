# 🤖 כללי עבודה עם Claude בפרויקט salsheli

## 🚀 התחלת שיחה חדשה - קריטי!

**בכל תחילת שיחה על הפרויקט:**
1. **קרא מיד** את `WORK_LOG.md`
2. **הצג סיכום קצר** (2-3 שורות) של מה עשינו לאחרונה
3. **שאל** מה רוצים לעשות היום

**דוגמה לתחילת שיחה נכונה:**
```
[קורא WORK_LOG.md אוטומטית]

היי! ראיתי שבשיחה האחרונה שיפרנו את storage_location_manager 
ועברנו לארכיטקטורה עם Provider.

במה נעבוד היום?
```

**חריג יחיד:** אם המשתמש מתחיל עם שאלה כללית לא קשורה לפרויקט 
(כמו "מה זה Provider?") - אל תקרא את היומן.

---

## 📝 עדכון יומן אוטומטי - חדש! ⭐

**אחרי כל עבודה משמעותית - עדכן את WORK_LOG.md אוטומטית!**

### מתי לעדכן:
✅ **כן - תעדכן אוטומטית:**
- תיקון באג קריטי
- הוספת פיצ'ר חדש
- שדרוג/רפקטור משמעותי
- שינוי בארכיטקטורה
- תיקון מספר קבצים

❌ **לא - אל תעדכן:**
- שאלות הבהרה
- דיונים כלליים
- הסברים על קוד קיים
- שינויים קוסמטיים קטנים

### איך לעדכן:

1. **בסוף העבודה, שאל:**
   ```
   ✅ סיימתי! רוצה שאעדכן את היומן (WORK_LOG.md)?
   ```

2. **אם המשתמש אומר "כן":**
   - צור רשומה חדשה **בפורמט המדויק** של WORK_LOG.md
   - הוסף אותה **בראש הקובץ** (אחרי "## 🗓️ רשומות (מהחדש לישן)")
   - **כתוב ישירות לקובץ** עם `Filesystem:edit_file`

3. **פורמט הרשומה - חובה:**
   ```markdown
   ---
   
   ## 📅 [תאריך] - [כותרת תיאורית]
   
   ### 🎯 משימה
   [תיאור קצר של מה עשינו]
   
   ### ✅ מה הושלם
   [רשימה ממוספרת של שינויים]
   
   ### 📂 קבצים שהושפעו
   [רשימה של נתיבים מלאים]
   
   ### 💡 לקחים
   [תובנות חשובות]
   
   ### 🔄 מה נותר לעתיד
   [משימות פתוחות - אופציונלי]
   
   ---
   ```

4. **דוגמה לעדכון:**
   ```
   [קורא את WORK_LOG.md]
   [מוסיף רשומה חדשה בראש]
   [כותב חזרה לקובץ]
   
   ✅ היומן עודכן! הרשומה החדשה נוספה בראש WORK_LOG.md
   ```

### 💡 טיפים:
- **תאריך**: השתמש בפורמט DD/MM/YYYY (04/10/2025)
- **כותרת**: תיאורית וקצרה (לא יותר מ-60 תווים)
- **לקחים**: מה למדנו שיעזור בעתיד
- **נתיבים**: תמיד נתיבים מלאים מ-`lib/`

---

## 👤 פרטי מפתח

- **מפתח:** גבר
- **סביבת פיתוח:** Flutter (Dart)
- **מערכת הפעלה:** Windows
- **Shell:** PowerShell
- **העדפה:** כולל פקודות טרמינל בהסברים

---

## 📋 עקרונות עבודה בסיסיים

### 1. חיפוש עצמאי - תמיד
- **אסור** לבקש מהמשתמש לחפש קבצים או מידע בקוד
- **חובה** לחפש בעצמך עם `Filesystem:search_files` או `read_file`
- אם לא מוצא - חפש בניסוחים שונים לפני שאתה שואל
- רק במקרה נדיר שאחרי מספר חיפושים לא מצאת - אז תשאל

**דוגמה נכונה:**
```
אני צריך לבדוק איך PopulateListScreen מוגדר...
[search_files: "PopulateListScreen"]
מצאתי! הפרמטרים הם...
```

**דוגמה שגויה:**
```
❌ "תוכל לחפש בקוד ולהעביר לי את הפרמטרים של PopulateListScreen?"
```

---

### 2. תשובות תמציתיות - פחות פירוט

**אל תעשה:**
- ❌ תוכניות עבודה ארוכות עם הסברים מפורטים
- ❌ "שלב 1 (5 דקות): נעשה X כי Y וגם Z..."
- ❌ טקסט מרובה שמציף

**כן תעשה:**
- ✅ ישר לעניין: "אני עושה 3 דברים: X, Y, Z"
- ✅ אם צריך להסביר - תמציתי ובנקודות
- ✅ אם המשתמש רוצה פירוט - הוא ישאל

**דוגמה טובה:**
```
אני מתקן 3 דברים:
1. constants.dart - מוסיף מיקומים
2. LocationsProvider - Provider חדש
3. Widget - מחבר ל-Provider

מוכן להתחיל?
```

**דוגמה רעה:**
```
❌ בואי נתכנן את העבודה בשלבים...

שלב 1: הכנה (5 דקות)
נוסיף מיקומים ל-constants כי זה...
[עוד 3 פסקאות הסבר]

שלב 2: יצירת Provider (15 דקות)
ניצור Provider חדש שיעשה...
[עוד פסקת הסבר ארוכה]
```

---

### 3. פקודות PowerShell

כשאתה נותן פקודות טרמינל:
- **השתמש בתחביר PowerShell**, לא bash
- תן דוגמאות עם פקודות Windows-friendly
- אם יש הבדל בין PowerShell ל-CMD - ציין זאת

**דוגמאות נכונות:**
```powershell
# PowerShell - מחיקת תיקייה
Remove-Item -Recurse -Force lib/screens/profile/

# Flutter commands
flutter pub get
flutter run
flutter build apk --release

# בדיקת גרסה
flutter --version
dart --version
```

**דוגמה שגויה:**
```bash
❌ rm -rf lib/screens/profile/  # זה bash, לא PowerShell!
```

---

## 💡 לקחים מהפרויקט

### 🎯 Provider & State Management

#### 1. תלויות בין Providers
**בעיה:** כאשר Service/Provider אחד תלוי באחר, שינוי אחד יכול לשבור הכל.

**פתרון:**
```dart
// תמיד תעד תלויות בראש הקובץ:
// 📦 Dependencies:
// - ReceiptProvider: קבלות
// - ShoppingListsProvider: רשימות קניות
// - InventoryProvider: מלאי

// בדוק תלויות לאחר כל שינוי ב-Service:
Ctrl+Shift+F → "ServiceName" → בדוק כל תוצאה
```

**מתי להשתמש ב-ProxyProvider:**
- כאשר Provider אחד **תלוי** ב-Provider אחר
- כאשר צריך **לעדכן** Provider כשה-Provider התלוי משתנה
- דוגמאות: ShoppingListsProvider, InventoryProvider, ProductsProvider

**חשוב:**
```dart
ChangeNotifierProxyProvider<UserContext, ProductsProvider>(
  lazy: false, // ← קריטי! אחרת לא נוצר עד שמישהו צריך אותו
  create: ...,
  update: ...,
)
```

#### 2. notifyListeners מפעיל update()
כאשר `Provider.notifyListeners()` נקרא:
- **כל** ה-ProxyProviders **שתלויים בו** מקבלים `update()`
- זה קורה **כל פעם** ש-notifyListeners נקרא
- לכן חשוב לבדוק ב-update אם **באמת** צריך לעשות משהו

```dart
update: (context, userContext, previous) {
  // ⚠️ זה יקרה כל פעם ש-UserContext משתנה!
  if (userContext.isLoggedIn && !previous.hasInitialized) {
    previous.initializeAndLoad(); // רק פעם אחת!
  }
  return previous;
}
```

#### 3. skipInitialLoad Pattern
דפוס שימושי כאשר רוצים **לדחות** אתחול:

```dart
class MyProvider with ChangeNotifier {
  bool _hasInitialized = false;

  MyProvider({bool skipInitialLoad = false}) {
    if (!skipInitialLoad) {
      _initialize();
    }
  }

  bool get hasInitialized => _hasInitialized;

  Future<void> initializeAndLoad() async {
    if (_hasInitialized) return;
    await _initialize();
  }
}
```

#### 4. טעינה מאוחרת ב-StatefulWidget
שימוש ב-`initState()` מאפשר:
- טעינה **אחרי** שכל ה-Providers נבנו
- גישה ל-`context.read<>()`
- שליטה על **מתי** הטעינה קורית

```dart
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadSavedUser(); // אחרי build
  }
}
```

---

### 🔧 Code Quality & Debugging

#### 1. Null Safety הוא חובה
```dart
// ❌ רע - יקרוס
final sum = receipts.fold(...);

// ✅ טוב - בטוח
if (receipts == null || receipts.isEmpty) return 0.0;
final sum = receipts.fold(...);
```

**כלל:** כל פרמטר שיכול להיות null → בדוק אותו תחילה!

#### 2. Logging חוסך זמן
בלי לוגים: "למה הסטטיסטיקות לא נכונות?" 🤷

עם לוגים:
```dart
debugPrint('⚠️ מלאי נמוך: 5 פריטים');
debugPrint('   • חלב 3%: 1 ליטר');  // ← רואים בדיוק מה!
```

**טיפ:** הוסף לוגים בכל מקום שיש חישוב או החלטה.

**אסטרטגיית Logging טובה:**
- `🔔 notifyListeners()` - מתי Provider מעדכן
- `🔄 update()` - מתי ProxyProvider מתעדכן
- `👤 User: ${user?.email}` - מצב המשתמש
- `🚀 initializeAndLoad()` - מתי אתחול קורה

#### 3. TODO = חוב טכני
**לפני:**
```dart
// TODO: לחבר למודל/Provider של Inventory
return 0;
```

**אחרי:**
```dart
final lowItems = inventory.where((item) => item.quantity <= 2).toList();
return lowItems.length;
```

**לקח:** תמיד סמן TODO אבל חזור לתקן בהקדם!

#### 4. נתונים דמה צריכים סימון ברור
**רע:**
```dart
final data = [
  {'category': 'מזון', 'amount': 800.0},
];
```

**טוב:**
```dart
// TODO: חבר ל-stats.categoryBreakdown
// ⚠️ כרגע: נתונים דמה להדגמה
final data = [
  {'category': 'מזון', 'amount': 800.0},
];
```

זה עוזר למפתח הבא להבין מה צריך לתקן!

---

### 🗂️ Data & Storage

#### 1. תמיד בדוק את פורמט הקבצים
**לפני:**
```javascript
// הנחנו שה-JSON הוא Map
{
  "7290000000001": {"name": "חלב", ...}
}
```

**במציאות:**
```javascript
// ה-JSON הוא Array
[
  {"barcode": "7290000000001", "name": "חלב", ...}
]
```

**שיטה טובה:**
- פתח את הקובץ ובדוק ידנית
- הוסף לוגים שמדפיסים את ה-`runtimeType`
- בדוק את התו הראשון (`[` או `{`)

#### 2. Cache - חובה לקבצים גדולים
```dart
// Cache לתוצאות סינון
List<InventoryItem> _cachedFilteredItems = [];
String _lastCacheKey = "";

List<InventoryItem> get filteredInventory {
  final cacheKey = "$selectedLocation|$searchQuery|$sortBy";

  // החזר מהcache אם לא השתנה כלום
  if (cacheKey == _lastCacheKey && _cachedFilteredItems.isNotEmpty) {
    return _cachedFilteredItems;
  }

  // חשב מחדש רק אם צריך
  var items = _applyFilters();
  _cachedFilteredItems = items;
  _lastCacheKey = cacheKey;

  return items;
}
```

**מתי לנקות cache:**
```dart
void _updateFilter() {
  setState(() {
    searchQuery = newValue;
    _cacheKey = "";  // נקה cache!
  });
}
```

#### 3. Hive - אחסון מקומי מהיר
**למה Hive?**
- מהיר מאוד (NoSQL)
- קל לשימוש (type-safe)
- תמיכה ב-Flutter
- אין צורך ב-SQL queries

**איך להשתמש:**
```dart
// 1. הגדרת Model
@HiveType(typeId: 0)
class ProductEntity extends HiveObject {
  @HiveField(0)
  final String barcode;
}

// 2. אתחול
await Hive.initFlutter();
Hive.registerAdapter(ProductEntityAdapter());
final box = await Hive.openBox<ProductEntity>('products');

// 3. שימוש
await box.put(product.barcode, product);
final product = box.get(barcode);
```

#### 4. ארכיטקטורה היברידית
**יתרונות:**
- מהירות - טעינה מקומית
- נתונים עדכניים - מחירים מ-API
- Offline support - עובד בלי אינטרנט
- חסכון ב-bandwidth - רק מחירים, לא כל המוצרים

**מתי להשתמש:**
- אפליקציות עם catalog גדול
- נתונים שמשתנים בתדירויות שונות
- צורך ב-offline access

#### 5. Fallback Strategy חשוב!
תמיד צריך fallback למקרה שה-API נכשל:

```dart
try {
  final apiProducts = await _apiService.getProducts();
  if (apiProducts.isEmpty) {
    await _loadFallbackProducts(); // fallback
  }
} catch (e) {
  await _loadFallbackProducts(); // fallback
}
```

---

### 🎨 UI/UX Best Practices

#### 1. UX טוב = Undo
תמיד תן ביטול לפעולות הרסניות:

```dart
SnackBar(
  content: Text("נמחק"),
  action: SnackBarAction(
    label: "בטל",
    onPressed: () => undoAction(),
  ),
  duration: const Duration(seconds: 5),
)
```

**טיפ:** שמור את הנתונים הנדרשים לביטול _לפני_ המחיקה!

#### 2. טאבים = ארגון מושלם
**יתרונות:**
- מסך אחד במקום 2 נפרדים
- שומר על קונטקסט
- ניווט מהיר
- משתמש טבעי

**דוגמה:**
```dart
TabController _tabController;

Scaffold(
  appBar: AppBar(
    bottom: TabBar(
      controller: _tabController,
      tabs: [Tab(...), Tab(...)],
    ),
  ),
  body: TabBarView(
    controller: _tabController,
    children: [Widget1(), Widget2()],
  ),
)
```

#### 3. Flutter 3.27+ - withValues במקום withOpacity
**ישן:**
```dart
color.withOpacity(0.1)  // ❌ deprecated
```

**חדש:**
```dart
color.withValues(alpha: 0.1)  // ✅ Flutter 3.27+
```

---

### 🔑 Keys, Maps & i18n

#### 1. תמיד בדוק Keys במיפויים
כשיש מיפוי בין קבועים למשתנים:

```powershell
# חיפוש גלובלי
Ctrl+Shift+F → "fridge" → מצא בעיה!
```

**שיטה טובה:**
```dart
// במקום strings קשיחים:
const FRIDGE_KEY = "refrigerator";  // מוגדר במקום אחד
if (location == FRIDGE_KEY) { ... }  // שימוש בקבוע
```

#### 2. תמיכה רב-לשונית במיפויים
כשיש קטגוריות/נתונים בשפות שונות:

```dart
// ❌ לא טוב - רק אנגלית
final categoryEmojis = {"dairy": "🥛"};

// ✅ טוב - תמיכה דינמית
String getEmoji(String category) {
  // נסה עברית
  if (_hebrewEmojis.containsKey(category)) {
    return _hebrewEmojis[category]!;
  }
  // נסה אנגלית
  if (_englishEmojis.containsKey(category)) {
    return _englishEmojis[category]!;
  }
  // fallback
  return "📦";
}
```

---

### 🧰 Build & Dependencies

#### 1. Hive + build_runner
**פקודות:**
```powershell
# התקנת תלויות
flutter pub get

# יצירת *.g.dart
dart run build_runner build --delete-conflicting-outputs

# watch mode (יצירה אוטומטית)
dart run build_runner watch
```

#### 2. בעיות תאימות
**בעיה שנתקלנו:**
- `flutter_gen_runner` לא תואם ל-`dart_style` המעודכן
- גרם לשגיאת build

**פתרון:**
- הסרת `flutter_gen_runner` מ-pubspec.yaml
- השארת רק `hive_generator`

---

### 🧪 Testing & Validation

#### 1. חישובים צריכים להיות אמיתיים
**עיקרון:** אם יש נתונים אמיתיים זמינים - **השתמש בהם**!

```dart
// ❌ לא טוב - תמיד דמה
final previousSpent = totalSpent * 1.15;

// ✅ טוב - אמיתי עם fallback
if (stats.expenseTrend.length >= 2) {
  previousSpent = stats.expenseTrend[...]['value'];
} else {
  previousSpent = totalSpent * 1.15; // fallback בלבד
}
```

#### 2. חישוב דיוק רשימות - חכם
**אסטרטגיה:**
- רק רשימות מהחודש האחרון (relevance)
- חלון זמן: 7 ימים אחרי יצירת הרשימה
- `contains()` במקום `==` (גמישות)

**למה?**
- אנשים לא תמיד קונים בדיוק לפי הרשימה
- שמות מוצרים משתנים (חלב 3% vs חלב)
- קניות יכולות להיות מפוצלות

---

## 📌 סיכום - כללי זהב

1. **קרא WORK_LOG.md בתחילת כל שיחה** - כדי להבין את ההקשר
2. **עדכן WORK_LOG.md בסוף עבודה משמעותית** - שאל תחילה!
3. **חפש בעצמך** - אל תבקש מהמשתמש
4. **תמציתי ולעניין** - פחות הסברים, יותר עשייה
5. **תמיד בדוק dependencies** - לאחר כל שינוי ב-Service/Provider
6. **Logging מפורט** - חוסך שעות דיבאג
7. **Null Safety תמיד** - בדוק כל פרמטר nullable
8. **Cache חכם** - לנתונים שמחושבים הרבה
9. **UX טוב = Undo** - לפעולות הרסניות
10. **Fallback Strategy** - תמיד תכנן מה קורה אם משהו נכשל

---

**הערה:** כללים אלה משלימים את MOBILE_GUIDELINES.md ו-CODE_REVIEW_CHECKLIST.md, לא מחליפים אותם.

**גרסה:** 3.0 (עם לקחים מרוכזים מכל העבודות)  
**עדכון אחרון:** 05/10/2025
