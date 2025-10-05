# 📋 CODE_REVIEW_CHECKLIST

> בדיקה מהירה לפני עבודה על קבצים בפרויקט. קרא עם MOBILE_GUIDELINES.md

---

## ✅ כל קובץ חייב

- [ ] תיעוד בראש: `// 📄 File: path/to/file.dart`
- [ ] אין `dart:html`, `localStorage`, `sessionStorage`
- [ ] אין `Platform.isWindows/isMacOS`

---

## 🗂️ לפי סוג קובץ

### Providers

- [ ] `ChangeNotifier` + `dispose()`
- [ ] מחובר ל-Repository (לא פעולות ישירות)
- [ ] Getters: `unmodifiable` או `immutable`
- [ ] async עם `try/catch`
- [ ] **ProxyProvider:** `lazy: false` אם צריך אתחול מיידי
- [ ] **ProxyProvider:** בדיקה ב-`update()` למנוע כפילויות

```dart
// ✅ טוב
class MyProvider with ChangeNotifier {
  final MyRepository _repo;
  List<Item> _items = [];
  
  List<Item> get items => List.unmodifiable(_items);
  
  Future<void> load() async {
    try {
      _items = await _repo.fetch();
      notifyListeners();
    } catch (e) { }
  }
}

// ❌ רע
class BadProvider with ChangeNotifier {
  List<Item> items = []; // ניתן לשינוי
  Future<void> load() async {
    items = await http.get(...); // ישיר בלי Repository
  }
}
```

---

### Screens

- [ ] `SafeArea`
- [ ] תוכן scrollable אם ארוך
- [ ] `Consumer`/`context.watch` לקריאת state
- [ ] `context.read` לפעולות בלבד
- [ ] כפתורים 48x48 מינימום
- [ ] padding symmetric (RTL)
- [ ] **dispose חכם:** שמור provider ב-initState אם צריך ב-dispose

```dart
// ✅ טוב - dispose בטוח
class MyScreenState extends State<MyScreen> {
  MyProvider? _myProvider;
  
  @override
  void initState() {
    super.initState();
    _myProvider = context.read<MyProvider>();
  }
  
  @override
  void dispose() {
    _myProvider?.cleanup(); // בטוח!
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<MyProvider>(
          builder: (context, provider, _) => ListView(...),
        ),
      ),
    );
  }
}

// ❌ רע
Container(
  width: 1920, // גודל קבוע
  padding: EdgeInsets.only(left: 16), // לא RTL
);
```

---

### Models

- [ ] `@JsonSerializable()` (אם JSON)
- [ ] שדות `final`
- [ ] `copyWith()` method
- [ ] `*.g.dart` קיים
- [ ] **Hive:** `@HiveType` + `@HiveField` על כל שדה

```dart
@JsonSerializable()
class MyModel {
  final String id;
  final String name;
  
  const MyModel({required this.id, required this.name});
  
  MyModel copyWith({String? name}) => 
    MyModel(id: id, name: name ?? this.name);
  
  factory MyModel.fromJson(Map<String, dynamic> json) => 
    _$MyModelFromJson(json);
}
```

---

### Widgets

- [ ] תיעוד מפורט בראש (Purpose, Usage, Examples)
- [ ] `const` constructors כשאפשר
- [ ] Parameters עם `required` כשחובה
- [ ] `@override` על build
- [ ] גדלים responsive (לא קבועים)
- [ ] RTL support (symmetric padding)
- [ ] Accessibility (semantics, touch targets 48x48)

```dart
// ✅ טוב
/// Custom button widget for authentication flows
/// 
/// Usage:
/// ```dart
/// AuthButton(
///   label: 'התחבר',
///   onPressed: () => login(),
/// )
/// ```
class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  
  const AuthButton({
    super.key,
    required this.label,
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // responsive
      height: 48, // touch target
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

// ❌ רע
class BadButton extends StatelessWidget {
  String label; // לא final
  
  BadButton({this.label = ''}); // לא const, לא required
  
  Widget build(context) { // חסר @override
    return Container(
      width: 300, // קבוע
      padding: EdgeInsets.only(left: 16), // לא RTL
    );
  }
}
```

---

### Helpers/Utils

- [ ] פונקציות `static`
- [ ] תיעוד מפורט (Purpose, Parameters, Returns, Example)
- [ ] Cache אם קורא קבצים
- [ ] Logging מפורט
- [ ] Error handling עם fallback
- [ ] `const` לקבועים

```dart
// ✅ טוב
/// Helper for loading products from JSON
/// 
/// Returns: List of products or empty list on error
/// 
/// Example:
/// ```dart
/// final products = await ProductLoader.load();
/// ```
class ProductLoader {
  static List<Product>? _cache;
  
  static Future<List<Product>> load() async {
    debugPrint('📦 ProductLoader.load()');
    
    // בדוק cache
    if (_cache != null) {
      debugPrint('   ✅ מcache: ${_cache!.length}');
      return _cache!;
    }
    
    try {
      final data = await rootBundle.loadString('assets/products.json');
      final products = (jsonDecode(data) as List)
          .map((e) => Product.fromJson(e))
          .toList();
      
      _cache = products;
      debugPrint('   ✅ נטען: ${products.length}');
      return products;
    } catch (e) {
      debugPrint('   ❌ שגיאה: $e');
      return []; // fallback
    }
  }
}

// ❌ רע
class BadLoader {
  List<Product> products = []; // state
  
  Future<void> load() async { // לא static
    products = jsonDecode(...); // בלי error handling
  }
}
```

---

### Empty States Pattern

- [ ] **3 מצבים:** Loading, Error, Empty
- [ ] **Loading:** CircularProgressIndicator + הודעה
- [ ] **Error:** אייקון + הודעה + כפתור "נסה שוב"
- [ ] **Empty:** אייקון + הודעה + הדרכה/CTA
- [ ] הודעות עם context (למשל: "לא נמצאו X" ולא רק "ריק")

```dart
// ✅ טוב - 3 מצבים ברורים
Widget build(BuildContext context) {
  final provider = context.watch<MyProvider>();
  
  // 1️⃣ Loading
  if (provider.isLoading) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('טוען נתונים...'),
        ],
      ),
    );
  }
  
  // 2️⃣ Error
  if (provider.hasError) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64),
          SizedBox(height: 16),
          Text(provider.errorMessage ?? 'שגיאה'),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.retry(),
            child: Text('נסה שוב'),
          ),
        ],
      ),
    );
  }
  
  // 3️⃣ Empty
  if (provider.items.isEmpty) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.inbox, size: 80),
          SizedBox(height: 16),
          Text(
            provider.searchQuery.isNotEmpty
                ? 'לא נמצאו תוצאות ל"${provider.searchQuery}"'
                : 'אין פריטים עדיין',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text('התחל להוסיף פריטים'),
        ],
      ),
    );
  }
  
  // Content
  return ListView.builder(...);
}

// ❌ רע - מצב אחד בלבד
if (items.isEmpty) return Text('ריק'); // לא ברור למה
```

---

### Repositories

- [ ] יש ממשק (`abstract class`)
- [ ] async עם `Future`
- [ ] מחזיר מודלים, לא JSON
- [ ] **Hybrid:** Fallback אם API נכשל
- [ ] **Hive:** TypeAdapter רשום

```dart
abstract class MyRepository {
  Future<List<Item>> fetch();
}

class LocalRepo implements MyRepository {
  @override
  Future<List<Item>> fetch() async {
    // SharedPreferences / Hive
  }
}
```

---

### Services

- [ ] שיטות `static`
- [ ] פרמטרים nullable עם בדיקות
- [ ] Logging מפורט (`debugPrint`)
- [ ] **חישובים אמיתיים אם יש נתונים** - לא תמיד Mock!
- [ ] Fallback רק אם אין נתונים
- [ ] תיעוד TODO למה שחסר

```dart
class MyService {
  static Future<Stats> calculate({
    required List<Item> items,
  }) async {
    debugPrint('📊 מחשב...');
    
    // ✅ חישוב אמיתי
    if (items.isNotEmpty) {
      final result = items.fold(0, (sum, i) => sum + i.value);
      debugPrint('   ✅ תוצאה: $result');
      return Stats(result);
    }
    
    // Fallback רק אם אין נתונים
    debugPrint('   ⚠️ אין נתונים - fallback');
    return Stats(0);
  }
}

// ❌ רע
class BadService {
  List<Item> items = []; // יש state
  
  double calculate() { // לא static, לא async
    return items.length * 1.5; // תמיד Mock!
  }
}
```

---

### Caching

- [ ] Cache key מכל המשתנים
- [ ] ניקוי כשמשתנים משתנים
- [ ] Getter בודק cache לפני חישוב

```dart
List<Item> _cached = [];
String _cacheKey = "";

List<Item> get items {
  final key = "$location|$search";
  if (key == _cacheKey) return _cached;
  
  _cached = _filter();
  _cacheKey = key;
  return _cached;
}

void updateFilter() {
  _cacheKey = ""; // נקה
  setState(() {});
}
```

---

### JSON Handling

- [ ] בדיקת סוג (`is List` / `is Map`)
- [ ] Logging של רכיב ראשון
- [ ] `whereType<T>()` validation
- [ ] Error handling

```dart
final data = json.decode(content);
debugPrint('סוג: ${data.runtimeType}');

if (data is List) {
  return data
    .whereType<Map<String, dynamic>>()
    .map((i) => Item.fromJson(i))
    .toList();
}
return [];
```

---

### Undo Pattern

- [ ] שמירת **כל** הנתונים לפני מחיקה
- [ ] `SnackBarAction` לביטול
- [ ] duration: 5+ שניות
- [ ] שחזור מדויק

```dart
void _delete(String key, String name, String emoji) {
  // שמור לפני!
  final saved = (key: key, name: name, emoji: emoji);
  
  provider.delete(key);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('נמחק "$name"'),
      action: SnackBarAction(
        label: 'בטל',
        onPressed: () => provider.add(saved.name, emoji: saved.emoji),
      ),
      duration: Duration(seconds: 5),
    ),
  );
}
```

---

### i18n Mappings

- [ ] תמיכה בעברית **וגם** אנגלית
- [ ] Fallback אם Key לא נמצא
- [ ] לוגיקה: עברית → אנגלית → fallback

```dart
class Mapper {
  static const _he = {'חלבי': '🥛', 'ירקות': '🥬'};
  static const _en = {'dairy': '🥛', 'vegetables': '🥬'};
  
  static String get(String key) {
    return _he[key] ?? _en[key] ?? '📦';
  }
}
```

---

### Splash/Index Screens

- [ ] סדר בדיקות נכון: `userId` → `seenOnboarding` → `login`
- [ ] `mounted` checks לפני כל `Navigator`
- [ ] `try/catch` עם fallback ל-WelcomeScreen
- [ ] Loading indicator בזמן בדיקה

```dart
// ✅ טוב - סדר נכון
Future<void> _checkAndNavigate() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // 1️⃣ קודם: יש משתמש?
    final userId = prefs.getString('userId');
    if (userId != null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
      return;
    }
    
    // 2️⃣ שנית: ראה onboarding?
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    if (!seenOnboarding) {
      if (mounted) Navigator.pushReplacement(/* WelcomeScreen */);
      return;
    }
    
    // 3️⃣ ברירת מחדל
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    debugPrint('❌ Error in splash: $e');
    if (mounted) Navigator.pushReplacement(/* WelcomeScreen - fallback */);
  }
}

// ❌ רע - סדר הפוך
if (seenOnboarding) { ... }  // בדק לפני userId!
if (userId != null) { ... }  // מאוחר מדי
```

---

### Logging מפורט

- [ ] **Models:** `fromJson`/`toJson` - log מה נטען/נשמר
- [ ] **Providers:** `notifyListeners()` - log מתי ולמה
- [ ] **ProxyProvider:** `update()` - log שינויים
- [ ] **Services:** תוצאות חישובים וfallbacks
- [ ] **User state:** login/logout/changes

```dart
// ✅ Models - logging בserialization
factory User.fromJson(Map<String, dynamic> json) {
  debugPrint('📥 User.fromJson: ${json["email"]}');
  return _$UserFromJson(json);
}

Map<String, dynamic> toJson() {
  debugPrint('📤 User.toJson: $email');
  return _$UserToJson(this);
}

// ✅ Providers - logging בעדכונים
void updateItems(List<Item> items) {
  _items = items;
  debugPrint('🔔 ItemsProvider.notifyListeners: ${items.length} items');
  notifyListeners();
}

// ✅ ProxyProvider - logging בupdate
update: (context, userContext, previous) {
  debugPrint('🔄 ProductsProvider.update()');
  debugPrint('   👤 User: ${userContext.user?.email ?? "guest"}');
  debugPrint('   🔐 isLoggedIn: ${userContext.isLoggedIn}');
  
  if (userContext.isLoggedIn && !previous.hasInitialized) {
    debugPrint('   ✅ Calling initializeAndLoad()');
    previous.initializeAndLoad();
  }
  return previous;
}

// ✅ Services - logging תוצאות
static Stats calculate(List<Item> items) {
  debugPrint('📊 StatsService.calculate()');
  if (items.isEmpty) {
    debugPrint('   ⚠️ אין נתונים - fallback');
    return Stats.empty();
  }
  final result = /* חישוב */;
  debugPrint('   ✅ תוצאה: $result');
  return result;
}
```

---

### Navigation & Async

- [ ] `push` - מוסיף לstack (חזרה אפשרית)
- [ ] `pushReplacement` - מחליף (אין חזרה)
- [ ] `pushAndRemoveUntil` - מנקה stack מלא
- [ ] **Context בDialogs:** שמור `dialogContext` נפרד
- [ ] סגור dialogs **לפני** async operations
- [ ] `mounted` check אחרי async

```dart
// ✅ טוב - Context נכון בDialog
showDialog(
  context: context,
  builder: (dialogContext) => AlertDialog(  // ← dialogContext!
    actions: [
      ElevatedButton(
        onPressed: () async {
          Navigator.pop(dialogContext);  // סגור קודם!
          
          await _performOperation();  // async
          
          if (!context.mounted) return;  // בדוק mounted
          ScaffoldMessenger.of(context).showSnackBar(/* ... */);
        },
      ),
    ],
  ),
);

// ❌ רע - context אחרי async
showDialog(
  builder: (context) => AlertDialog(
    actions: [
      ElevatedButton(
        onPressed: () async {
          await _operation();
          Navigator.pop(context);  // ❌ context עלול להיות invalid!
        },
      ),
    ],
  ),
);

// ✅ Back button - double press לצאת
DateTime? _lastBackPress;

Future<bool> _onWillPop() async {
  final now = DateTime.now();
  if (_lastBackPress == null || 
      now.difference(_lastBackPress!) > Duration(seconds: 2)) {
    _lastBackPress = now;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('לחץ שוב לצאת')),
    );
    return false;
  }
  return true;
}
```

---

## 🎨 UI Specifics

**Touch Targets:** 48x48 מינימום  
**Font Sizes:** 14-24px  
**Spacing:** כפולות של 8 (8, 16, 24)  
**Colors (Flutter 3.27+):** `withValues(alpha: 0.5)` לא `withOpacity`  
**Animations:** AnimatedContainer/AnimatedOpacity (200ms) לUI משופר

---

## 🔍 בדיקה מהירה

**Ctrl+F חפש:**
- `dart:html` → ❌
- `localStorage` → ❌
- `Platform.is` → ❌ (Windows/macOS/Linux)
- `debugPrint` → אם אין = ⚠️ חסר logging
- `TODO` → סמן לעתיד
- `.withOpacity` → ⚠️ השתמש ב`.withValues` במקום
- `dispose()` → יש? בדוק שמשחרר משאבים
- `mounted` → יש לפני async navigation?
- `const` → השתמש כשאפשר (widgets, constructors)

**שורה ראשונה:** יש `// 📄 File:` ? אם לא = ❌

**Providers:** יש `_repository`? אם אין = ⚠️ בעיה

**Services:** כל מתודה `static`? אם לא = ❌

**Splash/Index:** סדר `userId` → `seenOnboarding` → `login`? אם לא = ❌

**Dialogs:** יש `dialogContext` נפרד? `Navigator.pop` לפני async? אם לא = ❌

**Empty States:** 3 מצבים (loading/error/empty)? אם לא = ⚠️

**Widgets:** יש תיעוד + const? אם לא = ⚠️

---

## 📊 זמני בדיקה

| סוג                  | זמן      |
| -------------------- | -------- |
| Provider             | 2-3 דק'  |
| Screen               | 3-4 דק'  |
| Splash/Index Screen  | 2-3 דק'  |
| Model                | 1-2 דק'  |
| Hive Model           | 2-3 דק'  |
| Repository           | 2 דק'    |
| Service              | 3 דק'    |
| Cache/JSON/Undo      | 1-2 דק'  |
| Navigation & Dialogs | 1-2 דק'  |
| Widget               | 1-2 דק'  |
| Helper/Utils         | 2 דק'    |
| Empty States         | 1 דק'    |

---

**גרסה:** 3.2 (Widgets, Helpers, Empty States)  
**תאימות:** Flutter 3.27+, Mobile Only  
**עדכון אחרון:** 05/10/2025
