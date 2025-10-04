# 📱 Mobile Development Guidelines - סל שלי

> **⚠️ קריטי:** פרוייקט זה הוא **אפליקציית מובייל בלבד** (Android & iOS).  
> אין תמיכה ב-Web, Desktop, או פלטפורמות אחרות.

מסמך זה מכיל כללים והנחיות טכניות למפתחים ול-AI coding assistants (כמו Claude Code).

---

## 📋 תוכן עניינים

- [כללי זהב](#-כללי-זהב)
- [אסור בהחלט](#-אסור-בהחלט)
- [ארכיטקטורה ומבנה](#-ארכיטקטורה-ומבנה)
- [🚀 Splash & Initial Navigation](#-splash--initial-navigation)
- [UI/UX למובייל](#-uiux-למובייל)
- [State Management](#-state-management)
- [Navigation Patterns](#-navigation-patterns)
- [Error Handling](#-error-handling)
- [Performance](#-performance)
- [Storage & Persistence](#-storage--persistence)
- [Platform-Specific](#-platform-specific)
- [Testing](#-testing)
- [Code Review Checklist](#-code-review-checklist)

---

## 🌟 כללי זהב

### 1. Mobile-First Thinking

```dart
// ✅ טוב - חשיבה מובייל
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(  // תמיד להשתמש ב-SafeArea
      child: SingleChildScrollView(  // תמיד scrollable
        child: Column(/* ... */),
      ),
    ),
  );
}

// ❌ רע - לא מתחשב במובייל
Widget build(BuildContext context) {
  return Container(
    height: 900,  // גובה קבוע - לא יעבוד על כל המכשירים
    child: Column(/* ... */),
  );
}
```

### 2. RTL Support (Hebrew)

```dart
// ✅ טוב - תמיכה ב-RTL
return Directionality(
  textDirection: TextDirection.rtl,
  child: MaterialApp(/* ... */),
);

// ✅ טוב - Padding symmetric
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)

// ❌ רע - Padding specific (לא עובד ב-RTL)
padding: EdgeInsets.only(left: 16, right: 8)
```

### 3. Responsive Design

```dart
// ✅ טוב - גדלים יחסיים
final screenWidth = MediaQuery.of(context).size.width;
final buttonWidth = screenWidth * 0.9;

// ✅ טוב - גדלי מגע מינימליים
const minTouchTarget = 48.0;  // Material Design standard

// ❌ רע - גדלים קבועים
const buttonWidth = 300.0;  // לא יעבוד על מכשירים קטנים
```

---

## 🚫 אסור בהחלט

### 1. Browser/Web APIs

```dart
// ❌ אסור - Web APIs
import 'dart:html';  // ❌ לא עובד במובייל!
window.localStorage.setItem(/* ... */);  // ❌
document.getElementById(/* ... */);  // ❌

// ✅ מותר - Mobile Storage
import 'package:shared_preferences/shared_preferences.dart';
final prefs = await SharedPreferences.getInstance();
await prefs.setString('key', 'value');
```

### 2. Desktop/Web Packages

```yaml
# ❌ אסור בpubspec.yaml
dependencies:
  flutter_web: any  # ❌
  desktop_window: any  # ❌
  url_strategy: any  # ❌ Web-only

# ✅ מותר - Mobile packages
dependencies:
  camera: ^0.11.0  # ✅
  image_picker: ^1.1.0  # ✅
  mobile_scanner: ^3.5.0  # ✅
```

### 3. Platform Checks - רק Android & iOS

```dart
// ✅ טוב
import 'dart:io';

if (Platform.isAndroid) {
  // Android specific code
} else if (Platform.isIOS) {
  // iOS specific code
}

// ❌ רע - לא נתמך
if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
  // ❌ אין תמיכה בDesktop
}
```

### 4. Fixed Dimensions

```dart
// ❌ אסור - גדלים קבועים
Container(
  width: 1920,  // ❌ גודל דסקטופ
  height: 1080,
)

// ✅ מותר - גדלים דינמיים
Container(
  width: double.infinity,
  height: MediaQuery.of(context).size.height * 0.3,
)
```

---

## 🏗️ ארכיטקטורה ומבנה

### Layer Architecture

הפרוייקט בנוי בשכבות:

```
UI (Screens/Widgets)
    ↓
Providers (State Management)
    ↓
Services (Business Logic)
    ↓
Repositories (Data Access)
    ↓
Data Sources (Local/Remote)
```

### כללי מבנה

```dart
// ✅ טוב - הפרדת אחריות
class ShoppingListsProvider extends ChangeNotifier {
  final ShoppingListsRepository _repository;

  ShoppingListsProvider({required ShoppingListsRepository repository})
      : _repository = repository;

  Future<void> createList(ShoppingList list) async {
    await _repository.create(list);
    notifyListeners();
  }
}

// ❌ רע - לוגיקה ב-Widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ קריאות API ישירות מהwidget
    http.get('https://api.example.com/data');
    return Container();
  }
}
```

### File Organization

```
lib/
├── models/           # Data models + *.g.dart
├── repositories/     # Data access layer
├── providers/        # State management
├── services/         # Business logic
├── screens/          # UI screens
│   ├── auth/
│   ├── home/
│   ├── shopping/
│   └── ...
└── widgets/          # Reusable components
    ├── common/       # רכיבים כלליים
    ├── auth/         # רכיבי אימות
    ├── shopping/     # רכיבי קניות
    └── home/         # רכיבי דף הבית
```

---

## 🚀 Splash & Initial Navigation

### עקרונות מרכזיים למסכי אתחול

מסכי Index/Splash הם נקודת הכניסה לאפליקציה ודורשים טיפול מיוחד:

#### 1. סדר בדיקות נכון

**כלל זהב:** בדוק תמיד את מצב ההתחברות לפני כל בדיקה אחרת!

```dart
// ✅ טוב - סדר בדיקות נכון
Future<void> _checkAndNavigate() async {
  final prefs = await SharedPreferences.getInstance();

  // 1️⃣ קודם כל: האם המשתמש מחובר?
  final userId = prefs.getString('userId');
  if (userId != null) {
    // משתמש מחובר → ישר לדף הבית
    Navigator.pushReplacementNamed(context, '/home');
    return;
  }

  // 2️⃣ אם לא מחובר: האם ראה את ה-onboarding?
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  if (!seenOnboarding) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
    );
    return;
  }

  // 3️⃣ ראה onboarding אבל לא מחובר → login
  Navigator.pushReplacementNamed(context, '/login');
}

// ❌ רע - סדר לא נכון
Future<void> _checkAndNavigate() async {
  final prefs = await SharedPreferences.getInstance();

  // ❌ בודק onboarding לפני userId - משתמש מחובר יראה welcome!
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  if (!seenOnboarding) {
    Navigator.pushReplacement(/* ... */);
    return;
  }

  final userId = prefs.getString('userId');
  // ...
}
```

**למה זה חשוב?**

- משתמש מחובר צריך להגיע **ישר** לדף הבית
- אם נבדוק onboarding קודם, משתמש מחובר שמחק את ה-flag ייאלץ לעבור welcome שוב!

#### 2. אל תוסיף עיכובים מלאכותיים

```dart
// ❌ רע - עיכוב מיותר
Future<void> _checkAndNavigate() async {
  await Future.delayed(Duration(milliseconds: 800));  // ❌ למה?
  final prefs = await SharedPreferences.getInstance();
  // ...
}

// ✅ טוב - ניווט מיידי
Future<void> _checkAndNavigate() async {
  final prefs = await SharedPreferences.getInstance();
  // בדיקה וניווט ישירות - מהיר יותר!
}
```

**למה?**

- בדיקת SharedPreferences היא מהירה (כמה ms)
- אין סיבה להוסיף עיכוב מלאכותי
- משתמשים מעדיפים אפליקציה מהירה

**יוצא מן הכלל:** רק אם יש פעולה אמיתית (כמו קריאה לשרת) כדאי להציג splash.

#### 3. טיפול בשגיאות + Fallback Route

תמיד צריך fallback במקרה שמשהו משתבש:

```dart
// ✅ טוב - עם try-catch ו-fallback
Future<void> _checkAndNavigate() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // ... בדיקות ...
  } catch (e) {
    debugPrint('Error in IndexScreen: $e');

    // Fallback: שלח ל-welcome (הכי בטוח)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
    }
  }
}

// ❌ רע - אין טיפול בשגיאות
Future<void> _checkAndNavigate() async {
  final prefs = await SharedPreferences.getInstance();  // עלול לזרוק exception!
  // אם יש שגיאה - האפליקציה תקרוס
}
```

**איזה fallback לבחור?**

- `WelcomeScreen` - הכי בטוח, מתנהג כפעם ראשונה
- `LoginScreen` - אם אתה בטוח שהמשתמש כבר עבר onboarding
- בספק? תמיד `WelcomeScreen`.

#### 4. Mounted Checks לפני ניווט

חובה לבדוק `mounted` לפני ניווט async:

```dart
// ✅ טוב - בדיקת mounted
Future<void> _checkAndNavigate() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  if (userId != null) {
    if (mounted) {  // ✅ בודק שה-widget עדיין קיים
      Navigator.pushReplacementNamed(context, '/home');
    }
    return;
  }
  // ...
}

// ❌ רע - אין בדיקת mounted
Future<void> _checkAndNavigate() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  if (userId != null) {
    Navigator.pushReplacementNamed(context, '/home');  // ❌ עלול לקרוס!
    return;
  }
}
```

**למה?**

- בין הזמן שה-async מסתיים ל-ניווט, ה-widget יכול להיהרס
- בלי בדיקה → Exception: "setState called after dispose"

#### 5. StatefulWidget עם initState

מסכי Index צריכים להשתמש ב-StatefulWidget + initState:

```dart
// ✅ טוב - StatefulWidget עם initState
class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();  // ✅ קוראים לניווט מ-initState
  }

  Future<void> _checkAndNavigate() async {
    // ... לוגיקת ניווט ...
  }

  @override
  Widget build(BuildContext context) {
    // מציג splash בזמן טעינה
    return Scaffold(/* splash UI */);
  }
}

// ❌ רע - FutureBuilder מורכב
class IndexScreen extends StatelessWidget {
  Future<String> _determineRoute() async {
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _determineRoute(),
      builder: (context, snapshot) {
        // הרבה לוגיקה מורכבת עם addPostFrameCallback
        // קשה לקרוא ולתחזק
      },
    );
  }
}
```

**למה initState עדיף?**

- פשוט יותר לקרוא
- קל יותר לטיפול בשגיאות
- ברור מתי הלוגיקה רצה (פעם אחת בהתחלה)

### דוגמה מלאה: IndexScreen נכון

```dart
// 📄 File: lib/screens/index_screen.dart
// תיאור: מסך פתיחה ראשוני - בודק מצב משתמש ומנווט למסך המתאים

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1️⃣ בדיקה ראשונה: האם מחובר?
      final userId = prefs.getString('userId');
      if (userId != null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        return;
      }

      // 2️⃣ בדיקה שנייה: האם ראה onboarding?
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      if (!seenOnboarding) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        }
        return;
      }

      // 3️⃣ ברירת מחדל: ראה onboarding אבל לא מחובר
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('Error in IndexScreen: $e');
      // Fallback: שלח ל-welcome
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 36,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Salsheli',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              const CircularProgressIndicator(strokeWidth: 3),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Checklist למסכי Index/Splash

לפני commit, וודא:

- [ ] **סדר בדיקות נכון** - userId לפני seenOnboarding
- [ ] **אין עיכובים מלאכותיים** - רק אם באמת צריך
- [ ] **יש try-catch** - עם fallback ל-welcome/login
- [ ] **יש mounted checks** - לפני כל Navigator.push
- [ ] **StatefulWidget + initState** - לא FutureBuilder מורכב
- [ ] **יש תיעוד** - נתיב + תיאור בראש הקובץ

---

## 🎨 UI/UX למובייל

### Touch Targets

```dart
// ✅ טוב - גדלי מגע מינימליים (48dp)
GestureDetector(
  onTap: () {},
  child: Container(
    width: 48,
    height: 48,
    child: Icon(Icons.close),
  ),
)

// ❌ רע - גדלי מגע קטנים מדי
GestureDetector(
  onTap: () {},
  child: Container(
    width: 20,  // ❌ קטן מדי
    height: 20,
    child: Icon(Icons.close, size: 12),
  ),
)
```

### Font Sizes

```dart
// ✅ טוב - גדלי פונט מובייל
TextStyle(
  fontSize: 14,  // Body
  fontSize: 16,  // Body Large
  fontSize: 20,  // Heading
  fontSize: 24,  // Title
)

// ❌ רע - גדלי פונט דסקטופ
TextStyle(
  fontSize: 11,  // ❌ קטן מדי למובייל
  fontSize: 32,  // ❌ גדול מדי לכותרת
)
```

### Spacing

```dart
// ✅ טוב - ריווחים מובייל (8dp grid)
padding: EdgeInsets.all(16),
SizedBox(height: 8),
SizedBox(height: 16),
SizedBox(height: 24),

// ❌ רע - ריווחים לא עקביים
padding: EdgeInsets.all(13),
SizedBox(height: 7),
```

### Screen Orientation

```dart
// ✅ טוב - תמיכה ב-Portrait בלבד (אם רלוונטי)
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}
```

### Safe Areas

```dart
// ✅ טוב - תמיד להשתמש ב-SafeArea
Scaffold(
  body: SafeArea(
    child: YourContent(),
  ),
)

// ❌ רע - תוכן עלול להסתתר מתחת ל-notch/status bar
Scaffold(
  body: YourContent(),
)
```

---

## 🔄 State Management

### Provider Pattern

```dart
// ✅ טוב - שימוש נכון ב-Provider
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CircularProgressIndicator();
        }
        return ListView.builder(
          itemCount: provider.lists.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(provider.lists[index].name),
            );
          },
        );
      },
    );
  }
}

// ❌ רע - קריאת Provider ב-build ללא Consumer
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ לא יעדכן את הUI כשהמצב משתנה
    final provider = context.read<ShoppingListsProvider>();
    return Text(provider.lists.length.toString());
  }
}
```

### Immutability

```dart
// ✅ טוב - מודלים immutable
@JsonSerializable()
class ShoppingList {
  final String id;
  final String name;
  final List<ReceiptItem> items;

  const ShoppingList({
    required this.id,
    required this.name,
    required this.items,
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
}

// ❌ רע - mutable models
class ShoppingList {
  String id;
  String name;
  List<ReceiptItem> items;

  ShoppingList(this.id, this.name, this.items);
}
```

---

## 🧭 Navigation Patterns

### Push vs PushReplacement vs PushAndRemoveUntil

```dart
// ✅ טוב - שימוש נכון בפונקציות ניווט

// 1. push - מוסיף מסך לstack (יכול לחזור אחורה)
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => DetailsScreen()),
);

// 2. pushReplacement - מחליף את המסך הנוכחי (לא יכול לחזור)
// שימוש: Login → Home, Welcome → Login
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => HomeScreen()),
);

// 3. pushAndRemoveUntil - מנקה את כל ה-stack
// שימוש: אחרי Logout, אחרי השלמת רכישה
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => WelcomeScreen()),
  (route) => false,  // מוחק הכל
);

// 4. pushNamedAndRemoveUntil - עם routes בשם
Navigator.pushNamedAndRemoveUntil(
  context,
  '/home',
  (route) => false,
);
```

### Back Button Handling

דוגמה מהפרויקט: מסך הבית עם יציאה בלחיצה כפולה

```dart
// ✅ טוב - טיפול בלחיצת Back
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? _lastBackPress;

  Future<bool> _onWillPop() async {
    // אם לא בטאב הראשון - חזור אליו
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;  // לא לצאת
    }

    // אם בטאב הראשון - בדוק לחיצה כפולה
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > Duration(seconds: 2)) {
      _lastBackPress = now;

      // הצג הודעה
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('לחץ שוב כדי לצאת')),
      );
      return false;  // לא לצאת
    }

    // לחיצה שנייה בתוך 2 שניות - אשר יציאה
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(/* ... */),
    );
  }
}
```

### Passing Data Between Screens

```dart
// ✅ טוב - העברת נתונים דרך constructor
class DetailsScreen extends StatelessWidget {
  final ShoppingList list;

  const DetailsScreen({required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(/* use list */);
  }
}

// שימוש:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DetailsScreen(list: myList),
  ),
);

// ✅ טוב - העברת נתונים דרך arguments (named routes)
Navigator.pushNamed(
  context,
  '/details',
  arguments: {'listId': '123', 'listName': 'My List'},
);

// בonGenerateRoute:
case '/details':
  final args = settings.arguments as Map<String, dynamic>;
  return MaterialPageRoute(
    builder: (_) => DetailsScreen(
      listId: args['listId'],
      listName: args['listName'],
    ),
  );
```

---

## 🛡️ Error Handling

### SharedPreferences Errors

```dart
// ✅ טוב - טיפול בשגיאות
Future<void> saveUserData(String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  } catch (e) {
    debugPrint('Error saving user data: $e');
    // הצג הודעה למשתמש או שלח ל-error tracking
  }
}

// ❌ רע - אין טיפול בשגיאות
Future<void> saveUserData(String userId) async {
  final prefs = await SharedPreferences.getInstance();  // עלול לזרוק!
  await prefs.setString('userId', userId);
}
```

### Provider Errors

```dart
// ✅ טוב - error handling ב-provider
class ShoppingListsProvider extends ChangeNotifier {
  List<ShoppingList> _lists = [];
  String? _errorMessage;
  bool _isLoading = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadLists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lists = await _repository.fetchLists();
    } catch (e) {
      _errorMessage = 'שגיאה בטעינת רשימות: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ב-UI:
Consumer<ShoppingListsProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }

    if (provider.errorMessage != null) {
      return Text(provider.errorMessage!);
    }

    return ListView(/* ... */);
  },
)
```

### Mounted Checks

```dart
// ✅ טוב - בדיקת mounted
Future<void> loadData() async {
  final data = await fetchData();

  if (mounted) {  // ✅ בודק שה-widget עדיין קיים
    setState(() {
      _data = data;
    });
  }
}

// ✅ טוב - mounted גם בניווט
Future<void> navigateToDetails() async {
  final result = await someAsyncOperation();

  if (mounted) {  // ✅
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailsScreen()),
    );
  }
}
```

---

## ⚡ Performance

### List Performance

```dart
// ✅ טוב - ListView.builder עם key
ListView.builder(
  key: PageStorageKey('shopping_lists'),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),
      title: Text(items[index].name),
    );
  },
)

// ❌ רע - Column עם children רבים
Column(
  children: items.map((item) => ListTile(/* ... */)).toList(),
)
```

### Image Loading

```dart
// ✅ טוב - Cache network images
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// ❌ רע - Image.network ללא cache
Image.network(url)
```

### Async Operations

```dart
// ✅ טוב - FutureBuilder
FutureBuilder<List<ShoppingList>>(
  future: provider.fetchLists(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return ListView(children: /* ... */);
  },
)

// ❌ רע - Blocking UI
void loadData() {
  // ❌ סנכרוני - יקפיא את הUI
  final data = expensiveOperation();
  setState(() => this.data = data);
}
```

---

## 💾 Storage & Persistence

### Local Storage Options

```dart
// ✅ מותר - SharedPreferences (key-value)
import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();
await prefs.setString('user_id', userId);
final userId = prefs.getString('user_id');

// ✅ מותר - Path Provider (files)
import 'package:path_provider/path_provider.dart';

final directory = await getApplicationDocumentsDirectory();
final file = File('${directory.path}/data.json');
await file.writeAsString(jsonEncode(data));

// ✅ מותר בעתיד - Hive/SQLite (structured data)
// import 'package:hive/hive.dart';
// import 'package:sqflite/sqflite.dart';

// ❌ אסור - Web storage
// localStorage.setItem('key', 'value');  // ❌
// sessionStorage.getItem('key');  // ❌
```

### File Paths

```dart
// ✅ טוב - שימוש ב-path_provider
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

final appDir = await getApplicationDocumentsDirectory();
final filePath = path.join(appDir.path, 'receipts', 'receipt_123.jpg');

// ❌ רע - hard-coded paths
final filePath = '/Users/username/Documents/file.txt';  // ❌
```

---

## 📱 Platform-Specific

### Permissions

```dart
// ✅ טוב - בדיקת הרשאות
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkCameraPermission() async {
  final status = await Permission.camera.status;
  if (status.isDenied) {
    final result = await Permission.camera.request();
    return result.isGranted;
  }
  return status.isGranted;
}
```

### Platform Channels (Native Code)

```dart
// ✅ טוב - בדיקת פלטפורמה לפני שימוש
import 'dart:io';

if (Platform.isAndroid) {
  // Android-specific code
  methodChannel.invokeMethod('androidMethod');
} else if (Platform.isIOS) {
  // iOS-specific code
  methodChannel.invokeMethod('iosMethod');
}
```

### Android-specific

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <!-- ✅ טוב - הגדרת permissions -->
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.INTERNET" />

  <!-- ✅ טוב - minSdkVersion מינימלי -->
  <uses-sdk android:minSdkVersion="21" />
</manifest>
```

### iOS-specific

```xml
<!-- ios/Runner/Info.plist -->
<dict>
  <!-- ✅ טוב - הגדרת usage descriptions -->
  <key>NSCameraUsageDescription</key>
  <string>אנחנו צריכים גישה למצלמה כדי לסרוק קבלות</string>

  <key>NSPhotoLibraryUsageDescription</key>
  <string>אנחנו צריכים גישה לתמונות כדי לשמור קבלות</string>
</dict>
```

---

## 🧪 Testing

### Unit Tests

```dart
// ✅ טוב - בדיקות למודלים
void main() {
  group('ShoppingList', () {
    test('should calculate total amount correctly', () {
      final list = ShoppingList(
        id: '1',
        name: 'Test',
        items: [
          ReceiptItem(name: 'Item1', price: 10, quantity: 2),
          ReceiptItem(name: 'Item2', price: 5, quantity: 1),
        ],
        createdBy: 'user1',
        updatedDate: DateTime.now(),
      );

      expect(list.totalAmount, equals(25.0));
    });
  });
}
```

### Widget Tests

```dart
// ✅ טוב - בדיקות ל-widgets
void main() {
  testWidgets('ShoppingListTile displays list name', (tester) async {
    final list = ShoppingList(/* ... */);

    await tester.pumpWidget(
      MaterialApp(
        home: ShoppingListTile(list: list),
      ),
    );

    expect(find.text(list.name), findsOneWidget);
  });
}
```

---

## ✅ Code Review Checklist

לפני commit, וודא ש:

### General

- [ ] אין import של `dart:html` או web packages
- [ ] אין שימוש ב-`localStorage` או `sessionStorage`
- [ ] כל המסכים עוטפים ב-`SafeArea`
- [ ] כל הרשימות משתמשות ב-`ListView.builder`
- [ ] אין גדלים קבועים (hard-coded dimensions)
- [ ] יש הערת תיעוד בראש כל קובץ (נתיב + תיאור)

### Splash/Index Screens

- [ ] סדר בדיקות: userId → seenOnboarding → fallback
- [ ] אין עיכובים מלאכותיים מיותרים
- [ ] יש try-catch עם fallback route
- [ ] יש mounted checks לפני ניווט
- [ ] משתמש ב-StatefulWidget + initState (לא FutureBuilder)

### UI/UX

- [ ] כפתורים בגודל מינימלי 48x48
- [ ] פונטים בגדלים 14-24 (לא פחות, לא יותר מדי)
- [ ] ריווחים בכפולות של 8 (8, 16, 24, 32)
- [ ] תמיכה ב-RTL (שימוש ב-`symmetric` ולא `only`)
- [ ] אין overflow errors (כל התוכן scrollable)

### State Management

- [ ] Providers מוגדרים ב-`main.dart`
- [ ] שימוש ב-`Consumer` או `context.watch` לקריאת state
- [ ] שימוש ב-`context.read` לפעולות בלבד
- [ ] מודלים immutable עם `copyWith`

### Navigation

- [ ] שימוש נכון ב-push/pushReplacement/pushAndRemoveUntil
- [ ] mounted checks לפני ניווט async
- [ ] טיפול נכון בלחיצת Back (אם נדרש)

### Error Handling

- [ ] try-catch לכל פעולות SharedPreferences
- [ ] mounted checks לפני setState ו-Navigator
- [ ] טיפול בשגיאות ב-Providers
- [ ] debugPrint לכל שגיאות

### Performance

- [ ] תמונות עם cache
- [ ] אין blocking operations ב-UI thread
- [ ] Keys ל-list items
- [ ] Dispose של controllers

### Data & Storage

- [ ] שימוש ב-`SharedPreferences` או `path_provider`
- [ ] אין hard-coded paths
- [ ] JSON serialization עם `json_serializable`

### Platform

- [ ] בדיקות `Platform.isAndroid` / `Platform.isIOS` בלבד
- [ ] permissions מוגדרות ב-`AndroidManifest.xml` / `Info.plist`
- [ ] אין קוד specific ל-Web/Desktop

### Code Quality

- [ ] `flutter analyze` עובר ללא שגיאות
- [ ] `dart format` הורץ על כל הקבצים
- [ ] אין unused imports
- [ ] יש documentation comments ל-public APIs

---

## 🔍 איך לזהות קוד לא מתאים

### דוגמאות לבעיות נפוצות

#### 1. Web Imports

```dart
// 🔍 חפש:
import 'dart:html';
import 'package:flutter_web';

// ✅ תקן ל:
// הסר את הimport והשתמש בחלופה mobile
```

#### 2. Browser APIs

```dart
// 🔍 חפש:
window.
document.
localStorage.
sessionStorage.

// ✅ תקן ל:
SharedPreferences / path_provider
```

#### 3. Desktop Checks

```dart
// 🔍 חפש:
Platform.isWindows
Platform.isMacOS
Platform.isLinux
Platform.isFuchsia

// ✅ תקן ל:
// הסר או החלף ב-Platform.isAndroid / Platform.isIOS
```

#### 4. Fixed Dimensions

```dart
// 🔍 חפש:
width: 1920
height: 1080
width: 800

// ✅ תקן ל:
width: MediaQuery.of(context).size.width
width: double.infinity
```

#### 5. Small Touch Targets

```dart
// 🔍 חפש:
width: 20
height: 30
IconButton(iconSize: 12)

// ✅ תקן ל:
// הגדל לגודל מינימלי 48x48
```

#### 6. Missing Mounted Checks

```dart
// 🔍 חפש:
await someAsyncFunction();
setState(() {});  // ❌ אין בדיקת mounted

// ✅ תקן ל:
await someAsyncFunction();
if (mounted) {
  setState(() {});
}
```

---

## 🤖 הנחיות ל-Claude Code

כאשר אתה (Claude Code) עובד על פרוייקט זה:

1. **תמיד בדוק** אם הקוד שאתה כותב תואם למובייל
2. **אל תציע** שימוש ב-web packages או APIs
3. **תזכיר** למשתמש אם הוא מבקש משהו שלא תואם למובייל
4. **תציע חלופות** mobile-friendly אוטומטית
5. **תשתמש** ב-checklist למעלה לפני הצעת שינויים
6. **תוסיף תיעוד** - כל קובץ חייב הערה בראש עם נתיב ותיאור
7. **תבדוק mounted** - תמיד לפני setState או ניווט async
8. **תטפל בשגיאות** - try-catch לכל פעולות async

### דוגמה לתגובה טובה

```
❌ לא יכול להשתמש ב-localStorage במובייל.

✅ במקום זאת, אשתמש ב-SharedPreferences:

import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();
await prefs.setString('key', 'value');
```

---

## 📚 משאבים נוספים

- [Flutter Mobile Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Material Design - Mobile](https://m3.material.io/)
- [Human Interface Guidelines (iOS)](https://developer.apple.com/design/human-interface-guidelines/)
- [Android Design Guidelines](https://developer.android.com/design)

---

**עדכון אחרון:** ספטמבר 2025  
**גרסה:** 1.1.0  
**שינויים בגרסה זו:**

- ✅ הוספת חלק "Splash & Initial Navigation"
- ✅ הוספת חלק "Navigation Patterns"
- ✅ הוספת חלק "Error Handling"
- ✅ עדכון Checklist עם בדיקות נוספות
- ✅ כל הדוגמאות מבוססות על קוד אמיתי מהפרויקט

# 📘 לקחים נוספים - הימנע משגיאות נפוצות

## 🔴 שגיאות נפוצות ב-Provider Integration

### ❌ שגיאה: שימוש ישיר ב-SharedPreferences

```dart
// ❌ רע - bypass של Provider
final prefs = await SharedPreferences.getInstance();
final items = prefs.getString('pantry_items');
setState(() => pantryItems = jsonDecode(items));
```

```dart
// ✅ טוב - דרך Provider
Consumer<InventoryProvider>(
  builder: (context, provider, child) {
    final items = provider.items;
    return ListView(...);
  },
)
```

**למה זה רע:**

- שובר את הארכיטקטורה (bypassing State Management)
- אין סנכרון בין מסכים
- קשה לדיבוג
- אין single source of truth

---

### ❌ שגיאה: הנחות על API של Provider

```dart
// ❌ רע - הנחה שיש updateItemQuantity
await provider.updateItemQuantity(itemId, newQuantity);

// ❌ רע - הנחה שיש addItem
await provider.addItem(newItem);
```

```dart
// ✅ טוב - בדוק את הAPI האמיתי תחילה
// ב-InventoryProvider האמיתי:

// עדכון
final updatedItem = item.copyWith(quantity: newQuantity);
await provider.updateItem(updatedItem);

// יצירה
await provider.createItem(
  productName: "חלב",
  category: "חלב ומוצריו",  // חובה!
  location: "refrigerator",
  quantity: 2,
);

// מחיקה
await provider.deleteItem(itemId);
```

**כלל:** **תמיד בדוק את הקובץ של ה-Provider לפני שאתה משתמש בו!**

---

### ❌ שגיאה: שימוש ב-Map במקום Model

```dart
// ❌ רע - גישה לא type-safe
Map<String, dynamic> item = {
  "id": "1",
  "name": "חלב",  // שדה שגוי!
  "quantity": 2
};
```

```dart
// ✅ טוב - שימוש ב-Model
InventoryItem item = InventoryItem(
  id: "1",
  productName: "חלב",  // שדה נכון
  category: "חלב ומוצריו",
  location: "refrigerator",
  quantity: 2,
  unit: "ליטר",
);
```

**למה זה חשוב:**

- Type safety - שגיאות בזמן קומפילציה
- Auto-complete ב-IDE
- תיעוד מובנה
- copyWith() מובנה

---

## 🔴 שגיאות BuildContext נפוצות

### ❌ שגיאה: שימוש ב-context אחרי async בתוך dialog

```dart
// ❌ רע - context.mounted לא מספיק בתוך dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    actions: [
      ElevatedButton(
        onPressed: () async {
          await someAsyncOperation();
          if (mounted) {  // ❌ זה בודק את State, לא את Dialog!
            Navigator.pop(context);
          }
        },
      ),
    ],
  ),
);
```

```dart
// ✅ טוב - שמור את ה-dialogContext
showDialog(
  context: context,
  builder: (dialogContext) => AlertDialog(  // שם נפרד!
    actions: [
      ElevatedButton(
        onPressed: () async {
          Navigator.pop(dialogContext);  // סגור תחילה

          await someAsyncOperation();

          if (!context.mounted) return;  // בדוק אחרי
          ScaffoldMessenger.of(context).showSnackBar(...);
        },
      ),
    ],
  ),
);
```

**כלל חשוב:**

1. סגור את ה-dialog **לפני** async operations
2. השתמש ב-`dialogContext` בתוך ה-builder
3. בדוק `context.mounted` לפני שימוש ב-context אחרי async

---

### ❌ שגיאה: קריאה ל-Provider בתוך build

```dart
// ❌ רע - יוצר infinite loop
@override
Widget build(BuildContext context) {
  context.read<InventoryProvider>().loadItems();  // ❌
  return Container();
}
```

```dart
// ✅ טוב - קרא ב-initState או addPostFrameCallback
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      context.read<InventoryProvider>().loadItems();
    }
  });
}
```

---

## 🔴 שגיאות Model נפוצות

### ❌ שגיאה: שדות שגויים במודל

```dart
// ❌ רע - הנחה על שם השדות
InventoryItem(
  id: "1",
  name: "חלב",  // ❌ שדה לא קיים!
  location: "fridge",
  quantity: 2,
);
```

```dart
// ✅ טוב - שדות נכונים לפי המודל
InventoryItem(
  id: "1",
  productName: "חלב",  // ✅ השדה האמיתי
  category: "חלב ומוצריו",  // ✅ חובה
  location: "refrigerator",
  quantity: 2,
  unit: "ליטר",
);
```

**איך לבדוק:**

1. פתח את `lib/models/inventory_item.dart`
2. תסתכל על ה-constructor
3. בדוק אילו שדות required ואילו optional

---

### ❌ שגיאה: שכחת שדות חובה

```dart
// ❌ רע - חסר category
InventoryItem(
  id: "1",
  productName: "חלב",
  location: "refrigerator",
  quantity: 2,
  unit: "ליטר",
);
// Error: The named parameter 'category' is required
```

```dart
// ✅ טוב - כל השדות החובה
InventoryItem(
  id: "1",
  productName: "חלב",
  category: "חלב ומוצריו",  // ✅ הוספנו
  location: "refrigerator",
  quantity: 2,
  unit: "ליטר",
);
```

---

## 🔴 שגיאות Deprecated API

### ❌ שגיאה: שימוש ב-withOpacity

```dart
// ❌ deprecated
color: Colors.blue.withOpacity(0.5)
```

```dart
// ✅ נכון
color: Colors.blue.withValues(alpha: 0.5)
```

---

### ❌ שגיאה: value במקום initialValue

```dart
// ❌ deprecated
DropdownButtonFormField<String>(
  value: selectedLocation,  // ❌
  onChanged: (val) => setState(() => selectedLocation = val),
)
```

```dart
// ✅ נכון
DropdownButtonFormField<String>(
  initialValue: selectedLocation,  // ✅
  onChanged: (val) => setState(() => selectedLocation = val),
)
```

---

## ✅ Checklist לפני תיקון מסך קיים

כשאתה מתקן מסך שמשתמש ב-SharedPreferences ישירות:

- [ ] **בדוק איזה Provider צריך** - Inventory? ShoppingLists? Receipts?
- [ ] **פתח את הקובץ של ה-Provider** - תסתכל על ה-methods הזמינים
- [ ] **פתח את המודל** - תסתכל על השדות (required/optional)
- [ ] **החלף Map ב-Model** - בכל מקום שמשתמש ב-Map
- [ ] **החלף SharedPreferences ב-Provider calls**
- [ ] **תקן deprecated APIs** - withOpacity, value, WillPopScope
- [ ] **תקן BuildContext issues** - dialogContext, context.mounted
- [ ] **הוסף error handling** - try-catch + SnackBar
- [ ] **בדוק שאין שגיאות compilation**
- [ ] **רוץ flutter analyze** - וודא שאין warnings

---

## 📝 Template לתיקון מסך

```dart
// 📄 File: lib/screens/example/example_screen.dart - FIXED
// Description: [תיאור המסך] - מחובר ל-[Provider Name]
//
// ✅ שיפורים:
// 1. החלפת Map ב-[Model Name]
// 2. שימוש ב-[Provider Name] במקום SharedPreferences
// 3. תיקון deprecated APIs
// 4. הוספת error handling

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/[model_name].dart';
import '../../providers/[provider_name].dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  void initState() {
    super.initState();
    // טעינה ראשונית דרך Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ExampleProvider>().loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExampleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Example')),
          body: ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return ListTile(
                title: Text(item.propertyName),  // לא map['key']
              );
            },
          ),
        );
      },
    );
  }
}
```

---

**עדכון אחרון:** 01/10/2025  
**הוסף לקח חדש:** כשאתה מגלה שגיאה חוזרת - תעדכן את המסמך הזה!
