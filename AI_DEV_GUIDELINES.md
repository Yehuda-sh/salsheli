# 🤖 AI Development Guidelines - salsheli Project

> **מטרה:** קובץ הנחיות מאוחד לסוכני AI ומפתחים  
> **קוראים:** Claude, ChatGPT, מפתחים חדשים  
> **עדכון אחרון:** 07/10/2025  
> **גרסה:** 5.0 - ארגון מחדש + Quick Reference

---

## 📖 תוכן עניינים

### 🚀 [Quick Start](#-quick-start)
- [טבלת בעיות נפוצות](#-טבלת-בעיות-נפוצות)
- [16 כללי הזהב](#-16-כללי-הזהב)
- [בדיקה מהירה (5 דק')](#-בדיקה-מהירה-5-דק)

### 🤖 [חלק A: הוראות למערכות AI](#-חלק-a-הוראות-למערכות-ai)
1. [התחלת שיחה חדשה](#1-התחלת-שיחה-חדשה)
2. [עדכון יומן אוטומטי](#2-עדכון-יומן-אוטומטי)
3. [עקרונות עבודה](#3-עקרונות-עבודה)
4. [פורמט תשובות](#4-פורמט-תשובות)

### 📱 [חלק B: כללים טכניים](#-חלק-b-כללים-טכניים)
5. [Mobile-First](#5-mobile-first-כללים)
6. [אסור בהחלט](#6-אסור-בהחלט)
7. [ארכיטקטורה](#7-ארכיטקטורה)
8. [Navigation & Routing](#8-navigation--routing)
9. [State Management](#9-state-management)
10. [UI/UX Standards](#10-uiux-standards)

### ✅ [חלק C: Code Review](#-חלק-c-code-review)
11. [בדיקות אוטומטיות](#11-בדיקות-אוטומטיות)
12. [Checklist לפי סוג קובץ](#12-checklist-לפי-סוג-קובץ)
13. [דפוסים חובה](#13-דפוסים-חובה)
14. [Dead Code Detection](#14-dead-code-detection)

### 💡 [חלק D: לקחים מהפרויקט](#-חלק-d-לקחים-מהפרויקט)
15. [Firebase Integration](#15-firebase-integration)
16. [Provider Patterns](#16-provider-patterns)
17. [Data & Storage](#17-data--storage)
18. [Services Architecture](#18-services-architecture)

---

## 🚀 Quick Start

### 📋 טבלת בעיות נפוצות

| בעיה | פתרון מהיר | קישור |
|------|-----------|-------|
| 🔴 Provider לא מתעדכן | `addListener()` + `removeListener()` | [#9](#9-state-management) |
| 🔴 Timestamp שגיאות | `@TimestampConverter()` | [#15](#15-firebase-integration) |
| 🔴 Race condition ב-Auth | זרוק Exception בשגיאה | [#8](#8-navigation--routing) |
| 🔴 קובץ לא בשימוש | חפש imports → 0 = מחק | [#14](#14-dead-code-detection) |
| 🔴 Context אחרי async | שמור dialogContext נפרד | [#8](#8-navigation--routing) |
| 🔴 Color deprecated | `.withValues(alpha:)` | [#10](#10-uiux-standards) |
| 🔴 אפליקציה איטית | `.then()` לפעולות ברקע | [#17](#17-data--storage) |
| 🔴 Empty state חסר | 3 מצבים חובה | [#13](#13-דפוסים-חובה) |

### 🎯 16 כללי הזהב

1. **קרא WORK_LOG.md** - בתחילת כל שיחה
2. **עדכן WORK_LOG.md** - בסוף (שאל תחילה!)
3. **חפש בעצמך** - אל תבקש מהמשתמש
4. **תמציתי** - פחות הסברים, יותר עשייה
5. **Logging מפורט** - 🗑️ ✏️ ➕ 🔄 בכל method
6. **3 Empty States** - Loading/Error/Empty חובה
7. **Error Recovery** - hasError + retry() + clearAll()
8. **Undo למחיקה** - 5 שניות עם SnackBar
9. **Cache חכם** - O(1) במקום O(n)
10. **Firebase Timestamps** - `@TimestampConverter()`
11. **Dead Code = מחק** - 0 imports = מחיקה
12. **Visual Feedback** - צבעים לפי סטטוס
13. **Constants מרכזיים** - לא hardcoded
14. **Null Safety תמיד** - בדוק כל nullable
15. **Fallback Strategy** - תכנן כשל
16. **Dependencies בדיקה** - אחרי כל שינוי

### ⚡ בדיקה מהירה (5 דק')

```powershell
# 1. Deprecated APIs
Ctrl+Shift+F → ".withOpacity"
Ctrl+Shift+F → "WillPopScope"

# 2. Dead Code
Ctrl+Shift+F → "import.*my_file.dart"  # 0 תוצאות = מחק

# 3. Imports מיותרים
flutter analyze

# 4. Constants hardcoded
Ctrl+Shift+F → "height: 16"  # → kSpacingMedium
Ctrl+Shift+F → "padding: 8"  # → kSpacingSmall
```

---

## 🤖 חלק A: הוראות למערכות AI

### 1. התחלת שיחה חדשה

**בכל תחילת שיחה על הפרויקט:**

```
1️⃣ קרא מיד את WORK_LOG.md
2️⃣ הצג סיכום (2-3 שורות) של העבודה האחרונה
3️⃣ שאל מה רוצים לעשות היום
```

**דוגמה נכונה:**

```markdown
[קורא WORK_LOG.md אוטומטית]

היי! בשיחה האחרונה:
- OCR מקומי עם ML Kit
- Dead Code: 3,000+ שורות נמחקו
- Providers: עקביות מלאה

במה נעבוד היום?
```

**חריג:** שאלה כללית לא קשורה לפרויקט → אל תקרא יומן

---

### 2. עדכון יומן אוטומטי

**✅ כן - תעדכן:**
- תיקון באג קריטי
- הוספת פיצ'ר חדש
- שדרוג/רפקטור משמעותי
- שינוי ארכיטקטורה
- תיקון מספר קבצים

**❌ לא - אל תעדכן:**
- שאלות הבהרה
- דיונים כלליים
- הסברים על קוד קיים
- שינויים קוסמטיים

**תהליך:**

```
✅ סיימתי! רוצה שאעדכן את היומן (WORK_LOG.md)?
```

**אם "כן":**
1. צור רשומה בפורמט המדויק
2. הוסף **בראש** (אחרי "## 🗓️ רשומות")
3. שמור עם `Filesystem:edit_file`

**פורמט:**

```markdown
---

## 📅 DD/MM/YYYY - כותרת תיאורית

### 🎯 משימה
תיאור קצר

### ✅ מה הושלם
- פריט 1
- פריט 2

### 📂 קבצים שהושפעו
**נוצר/עודכן/נמחק (מספר):**
- `נתיב` - מה השתנה

### 💡 לקחים
- לקח 1

### 📊 סיכום
זמן: X | קבצים: Y | שורות: Z | סטטוס: ✅
```

---

### 3. עקרונות עבודה

**כלל זהב:** אסור לבקש מהמשתמש לחפש קבצים!

**✅ נכון:**
```
אני צריך לבדוק את PopulateListScreen...
[search_files: "PopulateListScreen"]
מצאתי! הפרמטרים הם...
```

**❌ שגוי:**
```
תוכל לחפש בקוד את הפרמטרים של PopulateListScreen?
```

**אסטרטגיה:**
1. חפש בניסוח אחד
2. לא מצאת? נסה ניסוח אחר
3. גם לא? חפש רחב יותר
4. רק אז שאל את המשתמש

---

### 4. פורמט תשובות

**❌ אל תעשה - תכנון ארוך:**
```
בואי נתכנן את העבודה בשלבים...

שלב 1: הכנה (5 דקות)
נוסיף מיקומים ל-constants כי...
[עוד 3 פסקאות הסבר]

שלב 2: יצירת Provider (15 דקות)
[עוד פסקת הסבר ארוכה]
```

**✅ כן תעשה - ישר לעניין:**
```
אני מתקן 3 דברים:
1. constants.dart - מוסיף מיקומים
2. LocationsProvider - Provider חדש
3. Widget - מחבר ל-Provider

מוכן להתחיל?
```

**PowerShell - תמיד:**
```powershell
# ✅ נכון
Remove-Item -Recurse -Force lib/old/
flutter pub get

# ❌ שגוי (bash)
rm -rf lib/old/
```

---

## 📱 חלק B: כללים טכניים

### 5. Mobile-First כללים

**⚠️ קריטי: Mobile Only!** (Android & iOS בלבד)

**1. SafeArea תמיד:**
```dart
Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(/* ... */),
  ),
)
```

**2. RTL Support:**
```dart
// ✅ טוב
padding: EdgeInsets.symmetric(horizontal: 16)

// ❌ רע
padding: EdgeInsets.only(left: 16, right: 8)
```

**3. Responsive:**
```dart
final width = MediaQuery.of(context).size.width;
const minTouchTarget = 48.0;
```

---

### 6. אסור בהחלט

**🚫 Browser/Web APIs:**
```dart
// ❌ אסור
import 'dart:html';
window.localStorage.setItem(/* ... */);

// ✅ מותר
import 'package:shared_preferences/shared_preferences.dart';
```

**🚫 Desktop Checks:**
```dart
// ✅ מותר
if (Platform.isAndroid) { }
if (Platform.isIOS) { }

// ❌ אסור
if (Platform.isWindows) { }
```

**🚫 Fixed Dimensions:**
```dart
// ❌ אסור
Container(width: 1920, height: 1080)

// ✅ מותר
Container(
  width: double.infinity,
  height: MediaQuery.of(context).size.height * 0.3,
)
```

---

### 7. ארכיטקטורה

**מבנה שכבות:**
```
UI (Screens/Widgets)
    ↓
Providers (ChangeNotifier)
    ↓
Services (Business Logic)
    ↓
Repositories (Data Access)
    ↓
Data Sources (Firebase/Hive/HTTP)
```

**הפרדת אחריות:**
```dart
// ✅ טוב
class MyProvider extends ChangeNotifier {
  final MyRepository _repository;
  Future<void> load() => _repository.fetch();
}

// ❌ רע - לוגיקה ב-Widget
class MyWidget extends StatelessWidget {
  Widget build(context) {
    http.get('https://api.example.com');  // ❌
  }
}
```

---

### 8. Navigation & Routing

**סוגי Navigation:**
```dart
// push - מוסיף לstack
Navigator.push(context, MaterialPageRoute(/* ... */));

// pushReplacement - מחליף
Navigator.pushReplacement(context, MaterialPageRoute(/* ... */));

// pushAndRemoveUntil - מנקה stack
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(/* ... */),
  (route) => false,  // מחק הכל
);
```

**Splash Screen - סדר בדיקות נכון:**

```dart
Future<void> _checkAndNavigate() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // 1️⃣ האם מחובר?
    final userId = prefs.getString('userId');
    if (userId != null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // 2️⃣ האם ראה onboarding?
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    if (!seenOnboarding) {
      if (mounted) Navigator.pushReplacement(/* WelcomeScreen */);
      return;
    }

    // 3️⃣ ברירת מחדל
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    if (mounted) Navigator.pushReplacement(/* WelcomeScreen */);
  }
}
```

**Dialogs - Context נכון:**

```dart
showDialog(
  context: context,
  builder: (dialogContext) => AlertDialog(  // ← dialogContext נפרד!
    actions: [
      ElevatedButton(
        onPressed: () async {
          Navigator.pop(dialogContext);  // סגור קודם

          await _performOperation();  // async

          if (!context.mounted) return;  // בדוק mounted
          ScaffoldMessenger.of(context).showSnackBar(/* ... */);
        },
      ),
    ],
  ),
);
```

**Back Button - double press:**

```dart
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

### 9. State Management

**Provider Pattern:**

```dart
// קריאה שמאזינה לשינויים
Consumer<MyProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return CircularProgressIndicator();
    return ListView.builder(/* ... */);
  },
)

// קריאה לפעולה בלבד
ElevatedButton(
  onPressed: () => context.read<MyProvider>().save(),
  child: Text('שמור'),
)
```

**ProxyProvider - חשוב:**

```dart
ChangeNotifierProxyProvider<UserContext, ProductsProvider>(
  lazy: false,  // ← קריטי! אחרת לא נוצר עד שצריך
  create: (_) => ProductsProvider(skipInitialLoad: true),
  update: (_, userContext, previous) {
    // רק אם מחובר וטרם אותחל
    if (userContext.isLoggedIn && !previous!.hasInitialized) {
      previous.initializeAndLoad();
    }
    return previous;
  },
)
```

**Immutable Models:**

```dart
class MyModel {
  final String id;
  const MyModel({required this.id});

  MyModel copyWith({String? id}) =>
    MyModel(id: id ?? this.id);
}
```

---

### 10. UI/UX Standards

**Measurements:**

```dart
// Touch Targets - מינימום 48x48
GestureDetector(
  child: Container(width: 48, height: 48, child: Icon(Icons.close)),
)

// Font Sizes
fontSize: 14,  // Body
fontSize: 16,  // Body Large
fontSize: 20,  // Heading

// Spacing - כפולות של 8
SizedBox(height: kSpacingSmall),   // 8
SizedBox(height: kSpacingMedium),  // 16
SizedBox(height: kSpacingLarge),   // 24
```

**Modern APIs (Flutter 3.27+):**

```dart
// ❌ Deprecated
color.withOpacity(0.5)
color.value
color.alpha

// ✅ Modern
color.withValues(alpha: 0.5)
color.toARGB32()
(color.a * 255.0).round() & 0xff
```

---

## ✅ חלק C: Code Review

### 11. בדיקות אוטומטיות

**Ctrl+F חיפושים:**

| חפש | בעיה | פתרון |
|-----|------|-------|
| `dart:html` | Browser API | אסור! |
| `localStorage` | Web storage | SharedPreferences |
| `Platform.isWindows` | Desktop check | אסור! |
| `.withOpacity` | Deprecated | `.withValues` |
| `WillPopScope` | Deprecated | PopScope |
| `TODO 2023` | TODO ישן | מחק/תקן |

**בדיקות נוספות:**
- **Header:** שורה ראשונה יש `// 📄 File:`?
- **Providers:** יש `_repository`?
- **Services:** כל method `static`?
- **Dialogs:** `dialogContext` נפרד?

---

### 12. Checklist לפי סוג קובץ

#### 📦 Providers

- [ ] `ChangeNotifier` + `dispose()`
- [ ] Repository (לא ישיר לAPI)
- [ ] Getters: `unmodifiable` / `immutable`
- [ ] async עם `try/catch`
- [ ] **Error State:** `hasError`, `errorMessage`
- [ ] **Error Recovery:** `retry()` method
- [ ] **State Cleanup:** `clearAll()` method
- [ ] **Error Notification:** `notifyListeners()` בכל catch
- [ ] **ProxyProvider:** `lazy: false` אם צריך

**דוגמה מושלמת:**

```dart
class MyProvider with ChangeNotifier {
  final MyRepository _repo;
  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Item> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;

  Future<void> load() async {
    debugPrint('📥 MyProvider.load()');
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _repo.fetch();
      _errorMessage = null;
      debugPrint('✅ Loaded ${_items.length}');
    } catch (e) {
      debugPrint('❌ Error: $e');
      _errorMessage = 'שגיאה בטעינה';
      notifyListeners(); // ← עדכן UI מיד!
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    _errorMessage = null;
    await load();
  }

  void clearAll() {
    _items = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('🗑️ MyProvider.dispose()');
    super.dispose();
  }
}
```

---

#### 📱 Screens

- [ ] `SafeArea`
- [ ] תוכן scrollable
- [ ] `Consumer` / `context.watch` לקריאה
- [ ] `context.read` לפעולות
- [ ] כפתורים 48x48 מינימום
- [ ] padding symmetric (RTL)
- [ ] **dispose חכם:** provider שמור ב-initState

```dart
class MyScreenState extends State<MyScreen> {
  MyProvider? _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<MyProvider>();
  }

  @override
  void dispose() {
    _provider?.cleanup();
    super.dispose();
  }
}
```

---

#### 📋 Models

- [ ] `@JsonSerializable()` אם JSON
- [ ] שדות `final`
- [ ] `copyWith()` method
- [ ] `*.g.dart` קיים
- [ ] **Hive:** `@HiveType` + `@HiveField`

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

  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}
```

---

#### 🎨 Widgets

- [ ] תיעוד מפורט
- [ ] `const` constructors
- [ ] `required` כשחובה
- [ ] `@override build`
- [ ] גדלים responsive
- [ ] RTL support

```dart
/// Custom auth button
///
/// Usage:
/// ```dart
/// AuthButton(label: 'התחבר', onPressed: login)
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
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
```

---

#### 🛠️ Services

**3 סוגים:**

**🟢 Static Service (עוטף APIs פשוטים):**
- [ ] **כל** ה-methods `static`
- [ ] **אין** instance variables
- [ ] **אין** `dispose()`
- [ ] תיעוד מפורט

```dart
/// Static service for user data via SharedPreferences
class UserService {
  static Future<UserEntity?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // ... קוד טהור
      return user;
    } catch (e) {
      return null;
    }
  }
}
```

**🔵 Instance API Client (HTTP עם state):**
- [ ] **יש** state (client, token)
- [ ] **יש** `dispose()`
- [ ] **לא** static methods
- [ ] Header: "Instance-based API client"

```dart
/// Instance-based API client for receipts
class ReceiptService {
  final http.Client _client;
  String? _authToken;

  ReceiptService({http.Client? client})
    : _client = client ?? http.Client();

  Future<Receipt> upload(String path) async {
    // ... uses _client, _authToken
  }

  void dispose() {
    _client.close();
  }
}
```

**🟡 Mock Service (לפיתוח):**
- [ ] תמיד Static
- [ ] Header: "⚠️ MOCK service"
- [ ] בדוק אם Dead Code!

---

### 13. דפוסים חובה

#### 🎭 3 Empty States

```dart
Widget build(BuildContext context) {
  final provider = context.watch<MyProvider>();

  // 1️⃣ Loading
  if (provider.isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  // 2️⃣ Error
  if (provider.hasError) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64),
          Text(provider.errorMessage ?? 'שגיאה'),
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
          Text('אין פריטים'),
        ],
      ),
    );
  }

  // 4️⃣ Content
  return ListView.builder(/* ... */);
}
```

---

#### ↩️ Undo Pattern

```dart
void _deleteItem(Item item) {
  final index = items.indexOf(item);
  items.remove(item);
  notifyListeners();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${item.name} נמחק'),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'ביטול',
        onPressed: () {
          items.insert(index, item);
          notifyListeners();
        },
      ),
    ),
  );
}
```

---

#### 🧹 Clear Button

```dart
TextField(
  controller: _controller,
  decoration: InputDecoration(
    suffixIcon: _controller.text.isNotEmpty
      ? IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
            setState(() {});
          },
        )
      : null,
  ),
)
```

---

#### 🎨 Visual Feedback

```dart
// הצלחה = ירוק
SnackBar(
  content: Text('נשמר!'),
  backgroundColor: Colors.green,
);

// שגיאה = אדום
SnackBar(
  content: Text('שגיאה'),
  backgroundColor: Colors.red,
);

// אזהרה = כתום
SnackBar(
  content: Text('שים לב'),
  backgroundColor: Colors.orange,
);
```

---

### 14. Dead Code Detection

**אסטרטגיה:**

```powershell
# 1. חיפוש Imports
Ctrl+Shift+F → "import.*demo_users.dart"
# 0 תוצאות = Dead Code!

# 2. בדיקת Providers ב-main.dart
# חפש אם Provider רשום

# 3. בדיקת Routes
# חפש ב-onGenerateRoute

# 4. Deprecated APIs
Ctrl+Shift+F → "withOpacity"
Ctrl+Shift+F → "WillPopScope"

# 5. Imports מיותרים
flutter analyze
```

**תוצאות 07/10/2025:**
- 🗑️ 3,000+ שורות Dead Code נמחקו
- 🗑️ 6 scripts ישנים
- 🗑️ 3 services לא בשימוש

---

## 💡 חלק D: לקחים מהפרויקט

### 15. Firebase Integration

**Authentication:**

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

**Firestore CRUD:**

```dart
Future<List<Item>> fetch(String householdId) async {
  final snapshot = await _firestore
    .collection('items')
    .where('household_id', isEqualTo: householdId)
    .orderBy('created_at', descending: true)
    .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();

    // ⚡ CRITICAL: Timestamp conversion!
    if (data['date'] is Timestamp) {
      data['date'] = (data['date'] as Timestamp)
        .toDate()
        .toIso8601String();
    }

    return Item.fromJson(data);
  }).toList();
}
```

**לקחים:**
- **Timestamp Conversion חובה** - תמיד המר ל-ISO8601
- **household_id Pattern** - multi-tenancy
- **Indexes נדרשים** - queries מורכבים
- **Real-time Streams** - watch() בונוס

---

### 16. Provider Patterns

#### 🔴 Error Recovery חובה

```dart
class MyProvider {
  String? _errorMessage;

  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  Future<void> retry() async {
    _errorMessage = null;
    await _loadData();
  }

  Future<void> clearAll() async {
    _items = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadData() async {
    try {
      // ...
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'שגיאה';
      notifyListeners(); // ← מיד!
    }
  }
}
```

**למה חשוב:**
- UI יכול להציג שגיאה
- retry() לנסות שוב
- clearAll() מנקה ב-logout

---

#### 🔄 ProxyProvider Pattern

```dart
update: (context, userContext, previous) {
  // ⚠️ זה יקרה כל פעם ש-UserContext משתנה

  // בדוק אם צריך
  if (userContext.isLoggedIn && !previous.hasInitialized) {
    previous.initializeAndLoad();
  }

  return previous;
}
```

---

#### 📋 Logging מפורט

```dart
Future<void> load() async {
  debugPrint('📥 Provider.load()');
  
  try {
    _items = await _repo.fetch();
    debugPrint('✅ ${_items.length} loaded');
  } catch (e) {
    debugPrint('❌ Error: $e');
    notifyListeners();
    debugPrint('   🔔 notifyListeners() (error)');
  } finally {
    notifyListeners();
    debugPrint('   🔔 notifyListeners() (finally)');
  }
}
```

**Emojis:**
- 📥 טעינה
- 💾 שמירה
- 🗑️ מחיקה
- ✅ הצלחה
- ❌ שגיאה
- 🔔 notify
- 🔄 retry

---

### 17. Data & Storage

#### 💾 Cache Pattern

```dart
List<Item> _cached = [];
String _cacheKey = "";

List<Item> get items {
  final key = "$location|$search";

  if (key == _cacheKey && _cached.isNotEmpty) {
    debugPrint('💨 Cache HIT');
    return _cached;
  }

  debugPrint('🔄 Cache MISS');
  _cached = _filter();
  _cacheKey = key;
  return _cached;
}
```

**תוצאות:**
- מהירות פי 10 (O(1) במקום O(n))

---

#### 🗃️ Hive Storage

```dart
// 1. Model
@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String barcode;
}

// 2. Setup
await Hive.initFlutter();
Hive.registerAdapter(ProductAdapter());
final box = await Hive.openBox<Product>('products');

// 3. CRUD
await box.put(product.barcode, product);
final product = box.get(barcode);
```

---

#### 🔀 Hybrid Strategy

```dart
Future<List<Product>> load() async {
  try {
    // 1. טען מקומי (Hive)
    final local = await _loadLocal();

    // 2. עדכן מחירים (API) - ברקע!
    _updatePrices(local).then((_) {
      debugPrint('✅ מחירים עודכנו');
    });

    return local;
  } catch (e) {
    return await _loadLocal();
  }
}
```

**לקחים:**
- `.then()` לפעולות ברקע
- לפני: 4 שניות → אחרי: 1 שניה = **פי 4**

---

### 18. Services Architecture

**3 סוגים:**

#### 🟢 Static Service

פונקציות עזר טהורות, ללא state

**דוגמאות:** `user_service.dart`, `ocr_service.dart`

```dart
class OcrService {
  static Future<String> extractText(String path) async {
    // ... קוד טהור
  }
}
```

**מתי:** עוטף APIs פשוטים (SharedPreferences, HTTP חד-פעמי)

---

#### 🔵 Instance API Client

שירות HTTP עם state

**דוגמה:** `auth_service.dart`

```dart
class AuthService {
  final FirebaseAuth _auth;  // ← State

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

**מתי:** HTTP client, authentication, configuration

---

#### 🟡 Mock Service

סימולציה לפיתוח

```dart
/// ⚠️ MOCK service for development
class MyServiceMock {
  static Future<Data> fetch() async {
    return Data.fake();
  }
}
```

**חשוב:** הפרויקט עובד עם Firebase אמיתי → Mock = Dead Code

---

## 📚 קבצים נוספים

- `LESSONS_LEARNED.md` - דפוסים מפורטים
- `WORK_LOG.md` - היסטוריה (קרא תחילה!)
- `README.md` - Overview

---

## 📊 זמני בדיקה

| סוג קובץ | זמן ממוצע |
|----------|-----------|
| Provider | 2-3 דק' |
| Screen | 3-4 דק' |
| Model | 1-2 דק' |
| Widget | 1-2 דק' |
| Service | 3 דק' |
| Dead Code | 5-10 דק' |

---

**גרסה:** 5.0 - Quick Reference + ארגון מחדש  
**תאימות:** Flutter 3.27+, Mobile Only  
**עדכון אחרון:** 07/10/2025  
**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻
