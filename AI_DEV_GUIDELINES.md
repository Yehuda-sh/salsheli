# 🤖 AI & Development Guidelines - salsheli Project

> **מטרה:** קובץ הנחיות מאוחד לסוכני AI ומפתחים אנושיים  
> **קוראים:** Claude, ChatGPT, מפתחים חדשים  
> **עדכון אחרון:** 07/10/2025  
> **גרסה:** 4.2 (Services vs API Clients vs Mock)

---

## 📖 Table of Contents

### 🤖 חלק A: הוראות למערכות AI

1. [התחלת שיחה חדשה](#1-התחלת-שיחה-חדשה)
2. [עדכון יומן אוטומטי](#2-עדכון-יומן-אוטומטי)
3. [עקרונות עבודה](#3-עקרונות-עבודה)
4. [פורמט תשובות](#4-פורמט-תשובות)

### 📱 חלק B: כללים טכניים - Mobile

5. [Mobile-First כללים](#5-mobile-first-כללים)
6. [אסור בהחלט](#6-אסור-בהחלט)
7. [ארכיטקטורה](#7-ארכיטקטורה)
8. [Navigation & Routing](#8-navigation--routing)
9. [State Management](#9-state-management)
10. [UI/UX Standards](#10-uiux-standards)

### ✅ חלק C: Code Review Checklist

11. [בדיקה מהירה](#11-בדיקה-מהירה)
12. [Checklist פר סוג קובץ](#12-checklist-פר-סוג-קובץ)
13. [דפוסים חובה](#13-דפוסים-חובה)
14. [Dead Code Detection](#14-dead-code-detection)

### 💡 חלק D: לקחים מהפרויקט

15. [Firebase Integration](#15-firebase-integration)
16. [Provider Patterns](#16-provider-patterns)
17. [Data & Storage](#17-data--storage)
18. [Services vs API Clients vs Mock](#18-services-vs-api-clients-vs-mock)
19. [UX Patterns](#19-ux-patterns)
20. [Build & Dependencies](#20-build--dependencies)

### 🎯 חלק E: כללי זהב

21. [16 כללי הזהב](#21-16-כללי-הזהב)
22. [Quick Reference](#22-quick-reference)

---

# 🤖 חלק A: הוראות למערכות AI

## 1. התחלת שיחה חדשה

### ✅ תהליך סטנדרטי:

**בכל תחילת שיחה על הפרויקט:**

1. ⬇️ **קרא מיד** את `WORK_LOG.md`
2. 📋 **הצג סיכום קצר** (2-3 שורות) של העבודה האחרונה
3. ❓ **שאל** מה רוצים לעשות היום

**דוגמה נכונה:**

```markdown
[קורא WORK_LOG.md אוטומטית]

היי! ראיתי שבשיחה האחרונה:

- העברנו Shopping Lists ל-Firestore
- הוספנו real-time sync
- תיקנו snake_case issues

במה נעבוד היום?
```

### ⚠️ חריג יחיד:

אם המשתמש מתחיל עם **שאלה כללית** לא קשורה לפרויקט (כמו "מה זה Provider?") - **אל תקרא** את היומן.

---

## 2. עדכון יומן אוטומטי

### 📝 מתי לעדכן אוטומטית:

✅ **כן - תעדכן:**

- תיקון באג קריטי
- הוספת פיצ'ר חדש
- שדרוג/רפקטור משמעותי
- שינוי ארכיטקטורה
- תיקון מספר קבצים

❌ **לא - אל תעדכן:**

- שאלות הבהרה
- דיונים כלליים
- הסברים על קוד קיים
- שינויים קוסמטיים קטנים

### 🔄 תהליך עדכון:

**בסוף העבודה:**

```
✅ סיימתי! רוצה שאעדכן את היומן (WORK_LOG.md)?
```

**אם "כן":**

1. צור רשומה בפורמט המדויק
2. הוסף **בראש** הקובץ (אחרי "## 🗓️ רשומות")
3. שמור עם `Filesystem:edit_file`

**פורמט חובה:**

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

- `נתיב מלא` - מה השתנה

### 💡 לקחים

- לקח 1
- לקח 2

### 📊 סיכום

זמן: X | קבצים: Y | שורות: Z | סטטוס: ✅
```

---

## 3. עקרונות עבודה

### 🔍 חיפוש עצמאי - תמיד

**כלל זהב:** אסור לבקש מהמשתמש לחפש קבצים!

✅ **נכון:**

```
אני צריך לבדוק את PopulateListScreen...
[search_files: "PopulateListScreen"]
מצאתי! הפרמטרים הם...
```

❌ **שגוי:**

```
תוכל לחפש בקוד ולהעביר לי את הפרמטרים של PopulateListScreen?
```

**אסטרטגיה:**

1. חפש בניסוח אחד
2. לא מצאת? נסה ניסוח אחר
3. גם לא? נסה חיפוש רחב יותר
4. רק אז שאל את המשתמש

---

## 4. פורמט תשובות

### 📏 תמציתיות - פחות פירוט

❌ **אל תעשה:**

```
בואי נתכנן את העבודה בשלבים...

שלב 1: הכנה (5 דקות)
נוסיף מיקומים ל-constants כי זה...
[עוד 3 פסקאות הסבר]

שלב 2: יצירת Provider (15 דקות)
ניצור Provider חדש שיעשה...
[עוד פסקת הסבר ארוכה]
```

✅ **כן תעשה:**

```
אני מתקן 3 דברים:
1. constants.dart - מוסיף מיקומים
2. LocationsProvider - Provider חדש
3. Widget - מחבר ל-Provider

מוכן להתחיל?
```

**עיקרון:** ישר לעניין, בלי תוכניות ארוכות.

### 💻 פקודות PowerShell

תמיד השתמש בתחביר PowerShell, לא bash:

✅ **נכון:**

```powershell
Remove-Item -Recurse -Force lib/screens/old/
flutter pub get
flutter run
```

❌ **שגוי:**

```bash
rm -rf lib/screens/old/  # זה bash!
```

---

# 📱 חלק B: כללים טכניים - Mobile

## 5. Mobile-First כללים

### ⚠️ קריטי: Mobile Only!

הפרויקט הוא **אפליקציית מובייל בלבד** (Android & iOS).  
אין תמיכה ב-Web/Desktop!

### 🌟 כללי זהב:

#### 1. SafeArea תמיד

```dart
// ✅ טוב
Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      child: Column(/* ... */),
    ),
  ),
);

// ❌ רע
Container(height: 900, child: Column(/* ... */));
```

#### 2. RTL Support

```dart
// ✅ טוב
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)

// ❌ רע
padding: EdgeInsets.only(left: 16, right: 8)
```

#### 3. Responsive

```dart
// ✅ טוב
final screenWidth = MediaQuery.of(context).size.width;
const minTouchTarget = 48.0;

// ❌ רע
const buttonWidth = 300.0;  // קבוע
```

---

## 6. אסור בהחלט

### 🚫 Browser/Web APIs

```dart
// ❌ אסור
import 'dart:html';
window.localStorage.setItem(/* ... */);

// ✅ מותר
import 'package:shared_preferences/shared_preferences.dart';
final prefs = await SharedPreferences.getInstance();
```

### 🚫 Desktop Checks

```dart
// ✅ מותר
if (Platform.isAndroid) { /* ... */ }
if (Platform.isIOS) { /* ... */ }

// ❌ אסור
if (Platform.isWindows) { /* ... */ }
```

### 🚫 Fixed Dimensions

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

## 7. ארכיטקטורה

### 📐 מבנה שכבות:

```
UI (Screens/Widgets)
    ↓
Providers (ChangeNotifier)
    ↓
Services (Business Logic)
    ↓
Repositories (Data Access)
    ↓
Data Sources (Local/Remote/Hybrid)
```

### 🎯 הפרדת אחריות:

✅ **טוב:**

```dart
class MyProvider extends ChangeNotifier {
  final MyRepository _repository;

  Future<void> loadData() async {
    final data = await _repository.fetch();
    notifyListeners();
  }
}
```

❌ **רע - לוגיקה ב-Widget:**

```dart
class MyWidget extends StatelessWidget {
  Widget build(context) {
    http.get('https://api.example.com/data');  // ❌
    return Container();
  }
}
```

---

## 8. Navigation & Routing

### 🧭 סוגי Navigation:

```dart
// push - מוסיף לstack (חזרה אפשרית)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => DetailsScreen()
));

// pushReplacement - מחליף (אין חזרה)
Navigator.pushReplacement(context, MaterialPageRoute(
  builder: (_) => HomeScreen()
));

// pushAndRemoveUntil - מנקה stack
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => WelcomeScreen()),
  (route) => false,  // מחק הכל
);
```

### 🚀 Splash Screen - סדר בדיקות נכון!

**כלל זהב:** בדוק `userId` לפני `seenOnboarding`!

✅ **נכון:**

```dart
Future<void> _checkAndNavigate() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // 1️⃣ קודם: האם מחובר?
    final userId = prefs.getString('userId');
    if (userId != null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // 2️⃣ שנית: האם ראה onboarding?
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    if (!seenOnboarding) {
      if (mounted) Navigator.pushReplacement(/* WelcomeScreen */);
      return;
    }

    // 3️⃣ ברירת מחדל
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    debugPrint('Error: $e');
    if (mounted) Navigator.pushReplacement(/* WelcomeScreen - fallback */);
  }
}
```

### 🗨️ Dialogs - Context נכון!

✅ **טוב - dialogContext נפרד:**

```dart
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
```

❌ **רע - context אחרי async:**

```dart
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
```

### 🔙 Back Button - double press:

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

## 9. State Management

### 🔄 Provider Pattern:

✅ **Consumer:**

```dart
Consumer<MyProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return CircularProgressIndicator();
    return ListView.builder(/* ... */);
  },
)
```

✅ **Immutable Models:**

```dart
class MyModel {
  final String id;
  const MyModel({required this.id});

  MyModel copyWith({String? id}) =>
    MyModel(id: id ?? this.id);
}
```

### 🎯 ProxyProvider Pattern:

**מתי להשתמש:**

- כש-Provider אחד **תלוי** ב-Provider אחר
- כשצריך **לעדכן** Provider כשה-Provider התלוי משתנה

**חשוב - lazy: false:**

```dart
ChangeNotifierProxyProvider<UserContext, ProductsProvider>(
  lazy: false,  // ← קריטי! אחרת לא נוצר עד שצריך
  create: (context) => ProductsProvider(
    skipInitialLoad: true,  // נאתחל ב-update
  ),
  update: (context, userContext, previous) {
    debugPrint('🔄 ProductsProvider.update()');
    debugPrint('   👤 User: ${userContext.user?.email}');
    debugPrint('   🔐 isLoggedIn: ${userContext.isLoggedIn}');

    // רק אם מחובר וטרם אותחל
    if (userContext.isLoggedIn && !previous.hasInitialized) {
      debugPrint('   ✅ Calling initializeAndLoad()');
      previous.initializeAndLoad();
    }

    return previous;
  },
)
```

---

## 10. UI/UX Standards

### 📏 Measurements:

```dart
// Touch Targets - מינימום 48x48
GestureDetector(
  child: Container(
    width: 48,
    height: 48,
    child: Icon(Icons.close)
  ),
)

// Font Sizes
fontSize: 14,  // Body
fontSize: 16,  // Body Large
fontSize: 20,  // Heading

// Spacing - כפולות של 8
padding: EdgeInsets.all(kSpacingSmall),   // 8
SizedBox(height: kSpacingMedium),         // 16
padding: EdgeInsets.all(kSpacingLarge),   // 24

// Safe Areas - תמיד!
Scaffold(
  body: SafeArea(
    child: YourContent(),
  ),
)
```

### 🎨 Modern APIs (Flutter 3.27+):

❌ **Deprecated:**

```dart
color.withOpacity(0.5)
color.value
color.alpha
```

✅ **Modern:**

```dart
color.withValues(alpha: 0.5)
color.toARGB32()
(color.a * 255.0).round() & 0xff
```

---

# ✅ חלק C: Code Review Checklist

## 11. בדיקה מהירה

### 🔍 Ctrl+F - חיפושים מהירים:

**בדוק אם יש:**

- ❌ `dart:html` → אסור!
- ❌ `localStorage` → אסור!
- ❌ `Platform.is` (Windows/macOS) → אסור!
- ⚠️ `TODO` → סמן לעתיד
- ⚠️ `.withOpacity` → deprecated, השתמש ב-`.withValues`
- ✅ `debugPrint` → טוב! יש logging
- ✅ `dispose()` → בדוק שמשחרר משאבים
- ✅ `mounted` → בדוק לפני async navigation
- ✅ `const` → השתמש כשאפשר

**בדיקות נוספות:**

- **שורה ראשונה:** יש `// 📄 File:`? אם לא = ❌
- **Providers:** יש `_repository`? אם אין = ⚠️
- **Services:** כל method `static`? אם לא = ❌
- **Splash/Index:** סדר נכון? `userId` → `seenOnboarding` → `login`
- **Dialogs:** `dialogContext` נפרד? `Navigator.pop` לפני async?

---

## 12. Checklist פר סוג קובץ

### 📦 Providers:

- [ ] `ChangeNotifier` + `dispose()`
- [ ] מחובר ל-Repository (לא ישיר)
- [ ] Getters: `unmodifiable` או `immutable`
- [ ] async עם `try/catch`
- [ ] **Error State:** `hasError`, `errorMessage` getters
- [ ] **Error Recovery:** `retry()` method - ניסיון חוזר אחרי שגיאה
- [ ] **State Cleanup:** `clearAll()` method - ניקוי מלא
- [ ] **Error Notification:** `notifyListeners()` בכל catch block (לא רק finally)
- [ ] **ProxyProvider:** `lazy: false` אם צריך אתחול מיידי
- [ ] **ProxyProvider:** בדיקה ב-`update()` למנוע כפילויות

✅ **טוב - Provider מושלם 100/100:**

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
    debugPrint('   🔔 notifyListeners() (isLoading=true)');

    try {
      _items = await _repo.fetch();
      _errorMessage = null; // נקה שגיאות קודמות
      debugPrint('✅ MyProvider.load: ${_items.length} items');
    } catch (e) {
      debugPrint('❌ MyProvider.load: שגיאה - $e');
      _errorMessage = 'שגיאה בטעינת נתונים';
      notifyListeners(); // עדכן UI מיד!
      debugPrint('   🔔 notifyListeners() (error occurred)');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('   🔔 notifyListeners() (isLoading=false)');
    }
  }

  /// ניסיון חוזר אחרי שגיאה
  Future<void> retry() async {
    debugPrint('🔄 MyProvider.retry()');
    _errorMessage = null;
    notifyListeners();
    await load();
  }

  /// ניקוי מלא של ה-state
  Future<void> clearAll() async {
    debugPrint('🗑️ MyProvider.clearAll()');
    _items = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
    debugPrint('   🔔 notifyListeners() (all cleared)');
  }

  @override
  void dispose() {
    debugPrint('🗑️ MyProvider.dispose()');
    super.dispose();
  }
}
```

---

### 📱 Screens:

- [ ] `SafeArea`
- [ ] תוכן scrollable אם ארוך
- [ ] `Consumer`/`context.watch` לקריאת state
- [ ] `context.read` לפעולות בלבד
- [ ] כפתורים 48x48 מינימום
- [ ] padding symmetric (RTL)
- [ ] **dispose חכם:** שמור provider ב-initState

✅ **טוב:**

```dart
class MyScreenState extends State<MyScreen> {
  MyProvider? _myProvider;

  @override
  void initState() {
    super.initState();
    _myProvider = context.read<MyProvider>();
  }

  @override
  void dispose() {
    _myProvider?.cleanup();
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
```

---

### 📋 Models:

- [ ] `@JsonSerializable()` (אם JSON)
- [ ] שדות `final`
- [ ] `copyWith()` method
- [ ] `*.g.dart` קיים
- [ ] **Hive:** `@HiveType` + `@HiveField` על כל שדה

✅ **טוב:**

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

### 🎨 Widgets:

- [ ] תיעוד מפורט (Purpose, Usage, Examples)
- [ ] `const` constructors כשאפשר
- [ ] Parameters עם `required` כשחובה
- [ ] `@override` על build
- [ ] גדלים responsive
- [ ] RTL support
- [ ] Accessibility (semantics, touch targets)

✅ **טוב:**

````dart
/// Custom button for auth flows
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
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
````

---

### 🛠️ Services:

**הבדל קריטי: Static Services vs Instance API Clients**

#### 🟢 Static Service (פונקציות עזר טהורות):

דוגמאות: `user_service.dart`, `shufersal_prices_service.dart`

- [ ] **כל** ה-methods הם `static`
- [ ] **אין** state (אין instance variables)
- [ ] **אין** `dispose()` method
- [ ] תיעוד מפורט (Purpose, Parameters, Returns, Example)
- [ ] Logging מפורט
- [ ] Error handling עם fallback
- [ ] **חישובים אמיתיים אם יש נתונים** - לא תמיד Mock!

✅ **טוב - Static Service:**

```dart
class UserService {
  static Future<UserEntity?> getUser() async {
    debugPrint('📥 UserService.getUser()');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // ... קוד טהור, ללא state
      debugPrint('✅ UserService.getUser: נמצא');
      return user;
    } catch (e) {
      debugPrint('❌ UserService.getUser: שגיאה - $e');
      return null;
    }
  }
  
  // אין dispose()!
}
```

#### 🔵 Instance API Client (שירות HTTP עם state):

דוגמה: `receipt_service.dart`

- [ ] **יש** state (http.Client, token, config)
- [ ] **יש** `dispose()` method
- [ ] **לא** static methods
- [ ] תיעוד מפורט + הערה שזה API Client
- [ ] Logging מפורט
- [ ] ניסיונות חוזרים (retry logic)
- [ ] Error handling עקבי

✅ **טוב - Instance API Client:**

```dart
class ReceiptService {
  final http.Client _client;  // ← State!
  String? _authToken;         // ← State!
  ReceiptServiceConfig _config; // ← State!

  ReceiptService({http.Client? client, ReceiptServiceConfig? config})
    : _client = client ?? http.Client(),
      _config = config ?? /* default */;

  Future<Receipt> uploadAndParseReceipt(String filePath) async {
    debugPrint('📤 ReceiptService.uploadAndParseReceipt()');
    // ... קוד שמשתמש ב-_client
  }

  void dispose() {
    debugPrint('🗑️ ReceiptService.dispose()');
    _client.close();  // ← שחרור משאבים!
  }
}
```

#### 🟡 Mock Service (סימולציה לפיתוח):

**⚠️ חשוב: הפרויקט עובד עם Firebase אמיתי!**

Mock Services הם **תמיד Static** (אין state אמיתי):

- [ ] **כל** ה-methods הם `static`
- [ ] **אין** state אמיתי (רק SharedPreferences wrapper)
- [ ] **אין** `dispose()` method
- [ ] מחזיר נתונים מזויפים/מקומיים
- [ ] Header עם הערה שזה Mock

⚠️ **בדוק לפני שמירה:**
- אם הפרויקט כבר עובד עם Firebase/Repository אמיתי
- Mock Service שלא בשימוש = **Dead Code**
- בדוק imports לפני מחיקה!

---

## 13. דפוסים חובה

### 🎯 Empty States (3 מצבים):

**חובה בכל מסך שטוען data!**

```dart
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
          Text('אין פריטים עדיין'),
          Text('התחל להוסיף...'),
        ],
      ),
    );
  }

  // 4️⃣ Content
  return ListView.builder(...);
}
```

---

### ↩️ Undo Pattern:

**חובה למחיקה!**

```dart
void _deleteItem(Item item) {
  // שמור לביטול
  final deletedItem = item;
  final deletedIndex = items.indexOf(item);

  // מחק
  items.remove(item);
  notifyListeners();

  // SnackBar עם Undo
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${item.name} נמחק'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'בטל',
        onPressed: () {
          items.insert(deletedIndex, deletedItem);
          notifyListeners();
        },
      ),
    ),
  );
}
```

---

### 🧹 Clear Button:

**בשדות טקסט ותאריכים:**

```dart
TextField(
  controller: _controller,
  decoration: InputDecoration(
    suffixIcon: _controller.text.isNotEmpty
      ? IconButton(
          icon: Icon(Icons.clear),
          tooltip: 'נקה',
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

### 🎨 Visual Feedback:

**צבעים לפי סטטוס:**

```dart
// הצלחה = ירוק
SnackBar(
  content: Text('נשמר!'),
  backgroundColor: Colors.green
);

// שגיאה = אדום
SnackBar(
  content: Text('שגיאה'),
  backgroundColor: Colors.red
);

// אזהרה = כתום
SnackBar(
  content: Text('שים לב'),
  backgroundColor: Colors.orange
);
```

---

## 14. Dead Code Detection

### 🔍 אסטרטגיה שיטתית:

**1. חיפוש Imports:**

```powershell
Ctrl+Shift+F → "demo_users.dart"
# אם 0 תוצאות → הקובץ לא בשימוש!
```

**2. בדיקת Providers ב-main.dart:**

```dart
MultiProvider(
  providers: [
    // אין NotificationsProvider? → מיותר!
  ],
)
```

**3. בדיקת Routes:**

```dart
final routes = {
  '/home': (context) => HomeScreen(),
  // אין '/suggestions'? → המסך מיותר!
};
```

**4. Deprecated APIs:**

```powershell
Ctrl+Shift+F → "withOpacity"    # ← deprecated
Ctrl+Shift+F → "WillPopScope"   # ← deprecated
Ctrl+Shift+F → "RawKeyboard"    # ← deprecated
```

**5. Imports מיותרים:**

```powershell
flutter analyze
# חפש בפלט: "Unused import"
```

**6. Naming ישן:**

- קבצים: `snake_case.dart` (לא `CamelCase.dart`)
- Classes: `PascalCase`
- Variables: `camelCase`

---

# 💡 חלק D: לקחים מהפרויקט

## 15. Firebase Integration

### 🔥 Authentication:

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

### 🗄️ Firestore CRUD:

```dart
class FirebaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
```

### 🛡️ Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /items/{itemId} {
      allow read, write: if request.auth != null &&
        resource.data.household_id == request.auth.uid;
    }
  }
}
```

### 💡 לקחים Firebase:

- **Timestamp Conversion חובה** - תמיד המר ל-ISO8601
- **household_id Pattern** - multi-tenancy + security
- **Indexes נדרשים** - queries מורכבים (where + orderBy)
- **Real-time Streams** - watchItems() בונוס ללא עלות

---

## 16. Provider Patterns

### 🎯 notifyListeners מפעיל update():

```dart
// UserContext.notifyListeners() →
// כל ProxyProvider שתלוי בו מקבל update()

update: (context, userContext, previous) {
  // ⚠️ זה יקרה כל פעם ש-UserContext משתנה!

  // בדוק אם באמת צריך לעשות משהו
  if (userContext.isLoggedIn && !previous.hasInitialized) {
    previous.initializeAndLoad(); // רק פעם אחת!
  }

  return previous;
}
```

### 🔴 Error Recovery Pattern:

**חובה בכל Provider!**

כל Provider צריך error state מלא כדי ל-UI להגיב לשגיאות:

```dart
class MyProvider with ChangeNotifier {
  String? _errorMessage;
  bool _isLoading = false;

  // === Getters ===
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // === Error Recovery ===
  
  /// ניסיון חוזר אחרי שגיאה
  /// 
  /// Example:
  /// ```dart
  /// if (provider.hasError) {
  ///   await provider.retry();
  /// }
  /// ```
  Future<void> retry() async {
    debugPrint('🔄 MyProvider.retry()');
    _errorMessage = null; // נקה שגיאה
    notifyListeners();
    await _loadData(); // נסה שוב
  }

  /// ניקוי מלא של כל ה-state
  /// 
  /// Example:
  /// ```dart
  /// await provider.clearAll();
  /// ```
  Future<void> clearAll() async {
    debugPrint('🗑️ MyProvider.clearAll()');
    _items = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // === בכל async method ===
  
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _repo.fetch();
      _errorMessage = null; // ✅ נקה אחרי הצלחה
      // ... process data
    } catch (e) {
      debugPrint('❌ Error: $e');
      _errorMessage = 'שגיאה בטעינה';
      notifyListeners(); // ✅ עדכן UI מיד!
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**למה חשוב:**
- ✅ UI יכול להציג הודעת שגיאה ברורה
- ✅ retry() מאפשר למשתמש לנסות שוב
- ✅ clearAll() מנקה state בlogout או reset
- ✅ notifyListeners() מיד בשגיאה = UX מהיר

---

### 🔄 skipInitialLoad Pattern:

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

### 📋 Logging בProviders:

**כלל זהב:** Logging בכל method + בכל notifyListeners()

```dart
// Models
factory User.fromJson(Map<String, dynamic> json) {
  debugPrint('📥 User.fromJson: ${json["email"]}');
  return _$UserFromJson(json);
}

// Providers - כל method
Future<void> loadItems() async {
  debugPrint('📥 ItemsProvider.loadItems()');
  
  try {
    _items = await _repo.fetch();
    debugPrint('✅ ItemsProvider: ${_items.length} items loaded');
  } catch (e) {
    debugPrint('❌ ItemsProvider.loadItems: שגיאה - $e');
    notifyListeners(); // ✅ logging + notify
    debugPrint('   🔔 notifyListeners() (error occurred)');
  } finally {
    notifyListeners();
    debugPrint('   🔔 notifyListeners() (finally)');
  }
}

// ProxyProvider
update: (context, userContext, previous) {
  debugPrint('🔄 ProductsProvider.update()');
  debugPrint('   👤 User: ${userContext.user?.email}');
  debugPrint('   🔐 isLoggedIn: ${userContext.isLoggedIn}');
  return previous;
}
```

**Emojis מומלצים:**
- 📥 טעינה (load, fetch)
- 💾 שמירה (save, update)
- 🗑️ מחיקה (delete, clear)
- ✅ הצלחה
- ❌ שגיאה
- 🔔 notifyListeners
- 🔄 retry/refresh
- ⚠️ אזהרה

---

## 17. Data & Storage

### 💾 Cache Pattern:

```dart
List<Item> _cached = [];
String _cacheKey = "";

List<Item> get items {
  final key = "$location|$search|$sort";

  // Cache hit
  if (key == _cacheKey && _cached.isNotEmpty) {
    return _cached;
  }

  // Cache miss - חשב מחדש
  _cached = _filter();
  _cacheKey = key;

  return _cached;
}

void updateFilter() {
  _cacheKey = "";  // נקה cache
  notifyListeners();
}
```

### 🗃️ Hive Storage:

```dart
// 1. Model
@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String barcode;

  @HiveField(1)
  final String name;
}

// 2. Setup
await Hive.initFlutter();
Hive.registerAdapter(ProductAdapter());
final box = await Hive.openBox<Product>('products');

// 3. CRUD
await box.put(product.barcode, product);
final product = box.get(barcode);
await box.delete(barcode);
```

### 🔀 Hybrid Strategy:

```dart
class HybridRepository {
  Future<List<Product>> load() async {
    try {
      // 1. טען מקומי (Hive)
      final local = await _loadLocal();

      // 2. עדכן מחירים (API)
      final updated = await _updatePrices(local);

      return updated;
    } catch (e) {
      // Fallback למקומי
      return await _loadLocal();
    }
  }
}
```

---

## 18. Services vs API Clients vs Mock

### 🔍 הבדל קריטי

**הפרויקט משתמש בשלושה סוגים שונים של "שירותים" - כל אחד עם מבנה ייעודי:**

---

### 🟢 Static Service (פונקציות עזר טהורות)

**מאפיינים:**
- **כל** המתודות `static`
- **אין** instance variables (state)
- **אין** constructor parameters
- **אין** `dispose()` method
- פונקציות טהורות שעוטפות APIs פשוטים

**דוגמאות בפרויקט:**
- `user_service.dart` - עוטף SharedPreferences
- `shufersal_prices_service.dart` - HTTP calls חד-פעמיים

✅ **טוב - Static Service:**

```dart
/// 📄 File: lib/services/user_service.dart
/// 
/// 📋 Description:
/// Static service for user data management using SharedPreferences.
/// Handles CRUD operations for user entity without maintaining state.
/// 
/// 🎯 Purpose:
/// - Provides stateless user data operations
/// - Wraps SharedPreferences for user entity
/// - No instance management needed
/// 
/// 📱 Mobile Only: Yes
class UserService {
  // No instance variables!
  
  static Future<UserEntity?> getUser() async {
    debugPrint('📥 UserService.getUser()');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        debugPrint('❌ UserService.getUser: לא נמצא userId');
        return null;
      }
      
      // ... build user from prefs
      debugPrint('✅ UserService.getUser: נמצא - ${user.email}');
      return user;
    } catch (e) {
      debugPrint('❌ UserService.getUser: שגיאה - $e');
      return null;
    }
  }
  
  static Future<bool> saveUser(UserEntity user) async {
    debugPrint('💾 UserService.saveUser: ${user.email}');
    // ... save to prefs
  }
  
  // No dispose() method!
}
```

**מתי להשתמש:**
- כשצריך רק פונקציות עזר (utilities)
- כשאין צורך ב-state management
- כשאין צורך ב-lifecycle management (dispose)
- עוטף APIs שאין להם state (SharedPreferences, HTTP חד-פעמי)

---

### 🔵 Instance API Client (שירות HTTP עם state)

**מאפיינים:**
- **יש** instance variables (state)
- **יש** `dispose()` method לשחרור משאבים
- **לא** static methods
- מנהל connection, authentication, configuration

**דוגמאות בפרויקט:**
- `receipt_service.dart` - API client עם http.Client + authToken

✅ **טוב - Instance API Client:**

```dart
/// 📄 File: lib/services/receipt_service.dart
/// 
/// 📋 Description:
/// Instance-based API client for receipt processing.
/// Manages HTTP client, authentication, and configuration state.
/// 
/// ⚠️ Note: This is an API Client (instance-based), not a pure Service.
/// 
/// 🎯 Purpose:
/// - Upload receipts to processing API
/// - Parse receipt data
/// - Manage API authentication
/// - Handle retry logic
/// 
/// Features:
/// - State management (client, token, config)
/// - Lifecycle management (dispose)
/// - Retry logic for failed requests
/// - Configurable timeouts
/// 
/// 📱 Mobile Only: Yes
class ReceiptService {
  // State!
  final http.Client _client;
  String? _authToken;
  ReceiptServiceConfig _config;

  ReceiptService({
    http.Client? client,
    ReceiptServiceConfig? config,
  })  : _client = client ?? http.Client(),
        _config = config ?? ReceiptServiceConfig.defaultConfig();

  Future<Receipt> uploadAndParseReceipt(String filePath) async {
    debugPrint('📤 ReceiptService.uploadAndParseReceipt()');
    debugPrint('   📁 File: $filePath');
    
    try {
      // Uses _client, _authToken, _config
      final response = await _client.post(
        Uri.parse(_config.apiUrl),
        headers: {'Authorization': 'Bearer $_authToken'},
        // ...
      );
      
      debugPrint('✅ ReceiptService: קבלה עובדה בהצלחה');
      return receipt;
    } catch (e) {
      debugPrint('❌ ReceiptService.uploadAndParseReceipt: שגיאה - $e');
      rethrow;
    }
  }

  void dispose() {
    debugPrint('🗑️ ReceiptService.dispose()');
    _client.close();  // ← Must release resources!
  }
}
```

**מתי להשתמש:**
- כשצריך לנהל HTTP client instance
- כשיש authentication state (tokens)
- כשיש configuration שמשתנה
- כשצריך dispose() לשחרור משאבים

---

### 🟡 Mock Service (סימולציה לפיתוח)

**מאפיינים:**
- **תמיד** Static (כמו Static Service)
- **אין** state אמיתי (רק SharedPreferences wrapper)
- **אין** `dispose()` method
- מחזיר נתונים מזויפים/מקומיים לפיתוח
- Header עם הערה ⚠️ שזה Mock

⚠️ **חשוב: הפרויקט כבר עובד עם Firebase אמיתי!**

Mock Services הם **Dead Code** אם הפרויקט כבר עובד עם Firebase/Repository אמיתי.

✅ **טוב - Mock Service (לפני מחיקה):**

```dart
/// 📄 File: lib/services/receipt_service_mock.dart
/// 
/// ⚠️ WARNING: This is a MOCK service for development only!
/// 
/// 📋 Description:
/// Mock implementation of receipt service using local storage.
/// 
/// 📱 Mobile Only: Yes
class ReceiptServiceMock {
  // No real state, only SharedPreferences wrapper

  static Future<Receipt> uploadAndParseReceipt(String filePath) async {
    debugPrint('📤 ReceiptServiceMock.uploadAndParseReceipt() [MOCK]');
    
    // Return fake data
    await Future.delayed(Duration(seconds: 1)); // Simulate network
    
    return Receipt(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      items: _generateMockItems(),
    );
  }
  
  // No dispose()!
}
```

**⚠️ בדיקה לפני שמירה:**
- האם הפרויקט כבר עובד עם Firebase/Repository אמיתי?
- Mock Service שלא בשימוש = **Dead Code**
- בדוק imports לפני מחיקה!

---

### 📋 Decision Tree

```
צריך state management?
├─ לא → Static Service
│   ├─ פונקציות עזר טהורות
│   ├─ עוטף APIs פשוטים (SharedPreferences)
│   └─ HTTP calls חד-פעמיים
│
└─ כן → Instance API Client
    ├─ HTTP client instance
    ├─ Authentication state
    ├─ Configuration
    └─ dispose() חובה!

לפיתוח בלבד?
└─ Mock Service (Static)
    ├─ נתונים מזויפים
    ├─ ⚠️ Header: "MOCK"
    └─ Dead Code כש-production מוכן!
```

---

### 💡 לקחים מהפרויקט

1. **Instance-based כשיש State:**
   - `http.Client` צריך `dispose()`
   - `authToken` משתנה
   - `config` ניתן לעדכון
   - Static לא מתאים!

2. **Static כשאין State:**
   - `user_service` = עוטף SharedPreferences (stateless)
   - `shufersal_prices_service` = HTTP calls חד-פעמיים (stateless)
   - אין צורך ב-instance!

3. **http.Client Management:**
   - אם צריך `dispose()` → Instance
   - אם לא צריך `dispose()` → Static + `http.get()` ישיר
   - `shufersal_prices_service` לא צריך client instance!

4. **Mock = Dead Code:**
   - `receipt_service_mock.dart` לא היה בשימוש בכלל
   - הפרויקט כבר עובד עם `FirebaseReceiptRepository`
   - תמיד לבדוק imports לפני מחיקה

5. **Header Comment עקביות:**
   - Static Service: "Static service for..."
   - Instance API Client: "Instance-based API client..." + ⚠️ Note
   - Mock Service: ⚠️ "WARNING: MOCK service..."

6. **Logging חוסך Debugging:**
   - Emojis לזיהוי מהיר בConsole
   - "מה" + "איפה" + "תוצאה" = context מלא
   - Retry logic עם logging = debugging קל

---

## 19. UX Patterns

כל הדוגמאות כבר הופיעו בחלק C (דפוסים חובה).

---

## 20. Build & Dependencies

### 🔨 Hive + build_runner:

```powershell
# התקנה
flutter pub get

# יצירת *.g.dart
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch
```

### ⚠️ תאימות:

בעיה: `flutter_gen_runner` לא תואם ל-`dart_style` המעודכן

פתרון: הסרה מ-pubspec.yaml, שימוש רק ב-`hive_generator`

---

# 🎯 חלק E: כללי זהב

## 21. 16 כללי הזהב

1. **קרא WORK_LOG.md בתחילת כל שיחה** - הקשר חשוב
2. **עדכן WORK_LOG.md בסוף** - שאל תחילה!
3. **חפש בעצמך** - אל תבקש מהמשתמש
4. **תמציתי ולעניין** - פחות הסברים, יותר עשייה
5. **בדוק dependencies** - אחרי כל שינוי
6. **Logging מפורט** - חוסך שעות דיבאג
7. **Null Safety תמיד** - בדוק כל nullable
8. **Cache חכם** - לחישובים כבדים
9. **UX טוב = Undo** - לפעולות הרסניות
10. **Fallback Strategy** - תכנן כשל
11. **Firebase Timestamp** - המר ל-ISO8601
12. **Dead Code = מחק** - בדוק imports → מחק
13. **3 Empty States** - Loading/Error/Empty
14. **Visual Feedback צבעוני** - ירוק/אדום/כתום
15. **Constants מרכזיים** - kSpacing, kColors, kEmojis
16. **Error Recovery חובה** - hasError + retry() + clearAll() בכל Provider

---

## 22. Quick Reference

### ✅ בדיקה ב-5 דקות:

```powershell
# 1. Deprecated APIs
Ctrl+Shift+F → "withOpacity"
Ctrl+Shift+F → "WillPopScope"

# 2. Imports מיותרים
flutter analyze

# 3. Dead Code
# בFile Explorer: חפש "old", "temp", "backup"

# 4. TODO ישנים
Ctrl+Shift+F → "TODO 2023"
Ctrl+Shift+F → "TODO 2022"

# 5. קבועים hardcoded
Ctrl+Shift+F → "height: 16" → החלף ב-kSpacingMedium
Ctrl+Shift+F → "padding: 8" → החלף ב-kSpacingSmall
```

### 📊 זמני בדיקה:

| סוג קובץ       | זמן ממוצע |
| -------------- | --------- |
| Provider       | 2-3 דק'   |
| Screen         | 3-4 דק'   |
| Model          | 1-2 דק'   |
| Widget         | 1-2 דק'   |
| Service        | 3 דק'     |
| Dead Code Scan | 5-10 דק'  |

---

## 📚 קבצים נוספים:

- **LESSONS_LEARNED.md** - לקחים מפורטים עם דוגמאות
- **WORK_LOG.md** - היסטוריה מלאה (קרא בתחילת שיחה!)
- **README.md** - overview הפרויקט

---

**גרסה:** 4.2 (Services vs API Clients vs Mock)  
**תאימות:** Flutter 3.27+, Mobile Only  
**עדכון אחרון:** 07/10/2025  
**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻
