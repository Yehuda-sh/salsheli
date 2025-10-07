# 🤖 AI Development Guidelines - salsheli Project

> **מטרה:** מדריך מהיר לסוכני AI ומפתחים - הכל בעמוד אחד  
> **עדכון:** 07/10/2025 | **גרסה:** 6.0 - גרסה תמציתית  
> 💡 **לדוגמאות מפורטות:** ראה [LESSONS_LEARNED.md](LESSONS_LEARNED.md)

---

## 📖 ניווט מהיר

**🚀 [Quick Start](#-quick-start)** | **🤖 [AI Instructions](#-חלק-a-הוראות-למערכות-ai)** | **📱 [Technical Rules](#-חלק-b-כללים-טכניים)** | **✅ [Code Review](#-חלק-c-code-review)** | **💡 [Project Lessons](#-חלק-d-לקחים-מהפרויקט)**

---

## 🚀 Quick Start

### 📋 טבלת בעיות נפוצות (פתרון תוך 30 שניות)

| בעיה | פתרון | קוד | מקור |
|------|-------|-----|------|
| 🔴 Provider לא מתעדכן | `addListener()` + `removeListener()` | [→](#usercontext-pattern) | [LESSONS](LESSONS_LEARNED.md#usercontext-pattern) |
| 🔴 Timestamp שגיאות | `@TimestampConverter()` | [→](#timestamp-management) | [LESSONS](LESSONS_LEARNED.md#timestamp-management) |
| 🔴 Race condition Auth | זרוק Exception בשגיאה | [→](#auth-flow) | [LESSONS](LESSONS_LEARNED.md#race-condition) |
| 🔴 קובץ לא בשימוש | Ctrl+Shift+F imports → 0 = מחק | [→](#dead-code) | סעיף 14 |
| 🔴 Context אחרי async | שמור `dialogContext` נפרד | [→](#dialogs) | סעיף 8 |
| 🔴 Color deprecated | `.withValues(alpha:)` | [→](#modern-apis) | סעיף 10 |
| 🔴 אפליקציה איטית | `.then()` ברקע | [→](#hybrid-strategy) | [LESSONS](LESSONS_LEARNED.md#hybrid-strategy) |
| 🔴 Empty state חסר | Loading/Error/Empty | [→](#3-empty-states) | סעיף 13 |

### 🎯 16 כללי הזהב (חובה!)

1. **קרא WORK_LOG.md** - בתחילת כל שיחה על הפרויקט
2. **עדכן WORK_LOG.md** - רק שינויים משמעותיים (שאל קודם!)
3. **חפש בעצמך** - אל תבקש מהמשתמש לחפש קבצים
4. **תמציתי** - ישר לעניין, פחות הסברים
5. **Logging** - 🗑️ ✏️ ➕ 🔄 ✅ ❌ בכל method
6. **3 States** - Loading/Error/Empty בכל widget
7. **Error Recovery** - `hasError` + `retry()` + `clearAll()`
8. **Undo** - 5 שניות למחיקה
9. **Cache** - O(1) במקום O(n)
10. **Timestamps** - `@TimestampConverter()` אוטומטי
11. **Dead Code** - 0 imports = מחיקה מיידית
12. **Feedback** - צבעים לפי סטטוס (ירוק/אדום/כתום)
13. **Constants** - `kSpacingMedium` לא `16.0`
14. **Null Safety** - בדוק כל `nullable`
15. **Fallback** - תכנן למקרה כשל
16. **Dependencies** - `flutter pub get` אחרי שינויים

### ⚡ בדיקה מהירה (5 דק')

```powershell
# Deprecated APIs
Ctrl+Shift+F → ".withOpacity"  # 0 תוצאות = ✅
Ctrl+Shift+F → "WillPopScope"  # 0 תוצאות = ✅

# Dead Code
Ctrl+Shift+F → "import.*my_file.dart"  # 0 = מחק הקובץ!

# Code Quality
flutter analyze  # 0 issues = ✅

# Constants
Ctrl+Shift+F → "height: 16"   # צריך להיות kSpacingMedium
Ctrl+Shift+F → "padding: 8"   # צריך להיות kSpacingSmall
```

---

## 🤖 חלק A: הוראות למערכות AI

### 1️⃣ התחלת שיחה

**בכל שיחה על הפרויקט:**

```
1. קרא WORK_LOG.md
2. הצג סיכום (2-3 שורות) של העבודה האחרונה
3. שאל מה לעשות היום
```

**✅ דוגמה נכונה:**
```
[קורא אוטומטית]
בשיחה האחרונה: OCR מקומי + Dead Code ניקוי.
במה נעבוד היום?
```

**❌ חריג:** שאלה כללית לא קשורה → אל תקרא

---

### 2️⃣ עדכון יומן

**✅ כן:** באג קריטי | פיצ'ר | רפקטור משמעותי | שינוי ארכיטקטורה  
**❌ לא:** שאלות | דיונים | הסברים | שינויים קוסמטיים

**תהליך:**
```
✅ סיימתי! לעדכן את WORK_LOG.md?
```

**פורמט:** [ראה WORK_LOG.md](WORK_LOG.md) - העתק המבנה המדויק!

---

### 3️⃣ עקרונות עבודה

**כלל זהב:** אסור לבקש מהמשתמש לחפש!

```dart
// ✅ נכון
אני מחפש את PopulateListScreen...
[search_files]
מצאתי! הפרמטרים הם X, Y, Z

// ❌ שגוי
תוכל לחפש את PopulateListScreen ולספר לי מה הפרמטרים?
```

**אסטרטגיה:** חפש → נסה שוב → חפש רחב → רק אז שאל

---

### 4️⃣ פורמט תשובות

**✅ טוב - ישר לעניין:**
```
אני מתקן 3 דברים:
1. constants.dart - מוסיף X
2. Provider - יוצר Y
3. Widget - מחבר Z
מוכן?
```

**❌ רע - תכנון ארוך:**
```
בואו נתכנן...
שלב 1: הכנה (5 דק') - נעשה X כי Y...
[3 פסקאות הסבר]
שלב 2: Provider (15 דק')...
```

**PowerShell בלבד:**
```powershell
# ✅ Windows
Remove-Item -Recurse -Force lib/old/

# ❌ Linux/Mac
rm -rf lib/old/
```

---

## 📱 חלק B: כללים טכניים

### 5️⃣ Mobile-First

**⚠️ Mobile Only!** Android + iOS בלבד

```dart
// ✅ חובה
Scaffold(body: SafeArea(child: SingleChildScrollView(...)))

// ✅ RTL Support
padding: EdgeInsets.symmetric(horizontal: 16)  // לא only

// ✅ Responsive
final width = MediaQuery.of(context).size.width;
const minTouch = 48.0;
```

---

### 6️⃣ אסור בהחלט

```dart
// 🚫 אסור
import 'dart:html';           // Web only
window.localStorage           // Web only
Platform.isWindows            // Desktop
Container(width: 1920)        // Fixed size

// ✅ מותר
import 'package:shared_preferences/...';
Platform.isAndroid / Platform.isIOS
MediaQuery.of(context).size.width
```

---

### 7️⃣ ארכיטקטורה

```
UI → Providers → Services → Repositories → Data Sources
```

**הפרדת אחריות:**
- **UI:** רק display + user input
- **Provider:** state management
- **Service:** business logic
- **Repository:** data access
- **Data Source:** Firebase/Hive/HTTP

---

### 8️⃣ Navigation & Routing

**3 סוגי Navigation:**

```dart
Navigator.push(...)                 // הוסף לstack
Navigator.pushReplacement(...)      // החלף
Navigator.pushAndRemoveUntil(...)   // מחק stack
```

**Splash Screen Pattern:**

```dart
// סדר נכון: 1. מחובר? 2. ראה onboarding? 3. ברירת מחדל
if (userId != null) → /home
else if (!seenOnboarding) → /welcome
else → /login
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
          await _operation();
          if (!context.mounted) return;  // בדוק mounted
          ScaffoldMessenger.of(context).show(...);
        },
      ),
    ],
  ),
);
```

**💡 דוגמאות מלאות:** [LESSONS_LEARNED.md - Navigation](LESSONS_LEARNED.md#navigation--routing)

---

### 9️⃣ State Management

**Provider Pattern:**

```dart
// קריאה + האזנה
Consumer<MyProvider>(builder: (ctx, provider, _) => ...)

// קריאה בלבד (פעולה)
context.read<MyProvider>().save()
```

**ProxyProvider:**

```dart
ChangeNotifierProxyProvider<UserContext, MyProvider>(
  lazy: false,  // ← קריטי!
  create: (_) => MyProvider(),
  update: (_, user, prev) {
    if (user.isLoggedIn && !prev.hasInit) prev.init();
    return prev;
  },
)
```

**💡 UserContext Pattern מלא:** [LESSONS_LEARNED.md - UserContext](LESSONS_LEARNED.md#usercontext-pattern)

---

### 🔟 UI/UX Standards

**Measurements:**

```dart
// Touch: 48x48 מינימום
// Font: 14 (body) | 16 (large) | 20 (heading)
// Spacing: 8 (small) | 16 (medium) | 24 (large)

SizedBox(height: kSpacingMedium)  // ✅ לא 16.0
```

**Modern APIs (Flutter 3.27+):**

```dart
// ❌ Deprecated
color.withOpacity(0.5)

// ✅ Modern
color.withValues(alpha: 0.5)
```

---

## ✅ חלק C: Code Review

### 1️⃣1️⃣ בדיקות אוטומטיות

| חפש | בעיה | פתרון |
|-----|------|-------|
| `dart:html` | Browser | ❌ אסור |
| `localStorage` | Web | SharedPreferences |
| `.withOpacity` | Deprecated | `.withValues` |
| `TODO 2023` | ישן | מחק/תקן |

---

### 1️⃣2️⃣ Checklist לפי סוג

#### 📦 Provider

```dart
class MyProvider with ChangeNotifier {
  // ✅ חובה
  final MyRepository _repo;          // Repository (לא ישיר)
  List<Item> _items = [];             // Private state
  bool _isLoading = false;
  String? _errorMessage;
  
  // ✅ Getters
  List<Item> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  
  // ✅ CRUD + Logging
  Future<void> load() async {
    debugPrint('📥 load()');
    _isLoading = true; notifyListeners();
    try {
      _items = await _repo.fetch();
      _errorMessage = null;
      debugPrint('✅ ${_items.length} loaded');
    } catch (e) {
      _errorMessage = 'שגיאה: $e';
      debugPrint('❌ Error: $e');
      notifyListeners(); // ← חשוב!
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
  
  // ✅ Recovery
  Future<void> retry() async { _errorMessage = null; await load(); }
  void clearAll() { _items = []; _errorMessage = null; notifyListeners(); }
  
  @override
  void dispose() { debugPrint('🗑️ dispose()'); super.dispose(); }
}
```

**💡 דוגמה מלאה:** [LESSONS_LEARNED.md - Provider Structure](LESSONS_LEARNED.md#provider-structure)

---

#### 📱 Screen

- [ ] `SafeArea` + scrollable
- [ ] `Consumer` לקריאה | `context.read` לפעולות
- [ ] כפתורים 48x48 מינימום
- [ ] padding `symmetric` (RTL)
- [ ] dispose חכם (שמור provider ב-initState)

---

#### 📋 Model

```dart
@JsonSerializable()
class MyModel {
  final String id;
  const MyModel({required this.id});
  
  MyModel copyWith({String? id}) => MyModel(id: id ?? this.id);
  
  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}
```

- [ ] `@JsonSerializable()` | שדות `final` | `copyWith()` | `*.g.dart` קיים

---

#### 🛠️ Service

**3 סוגים:**

| סוג | מתי | דוגמה |
|-----|-----|--------|
| 🟢 Static | פונקציות טהורות | `UserService.getUser()` |
| 🔵 Instance | HTTP + state | `AuthService(client)` |
| 🟡 Mock | פיתוח בלבד | `⚠️ MOCK - בדוק Dead Code!` |

---

### 1️⃣3️⃣ דפוסים חובה

#### 🎭 3 Empty States

```dart
if (provider.isLoading) return Center(child: Spinner());
if (provider.hasError) return ErrorWidget(provider.retry);
if (provider.isEmpty) return EmptyWidget();
return ListView.builder(...);
```

**💡 דוגמה מלאה:** [LESSONS_LEARNED.md - 3 Empty States](LESSONS_LEARNED.md#3-empty-states)

---

#### ↩️ Undo Pattern

```dart
SnackBar(
  content: Text('${item.name} נמחק'),
  duration: Duration(seconds: 5),
  backgroundColor: Colors.red,
  action: SnackBarAction(label: 'ביטול', onPressed: () => restore()),
)
```

---

#### 🎨 Visual Feedback

```dart
// ✅ הצלחה = ירוק | ❌ שגיאה = אדום | ⚠️ אזהרה = כתום
SnackBar(backgroundColor: Colors.green, ...)
```

---

### 1️⃣4️⃣ Dead Code Detection

```powershell
# 1. חיפוש imports
Ctrl+Shift+F → "import.*my_file.dart"  # 0 = מחק!

# 2. Providers ב-main.dart
# בדוק אם רשום

# 3. Routes
# חפש ב-onGenerateRoute

# 4. Analyze
flutter analyze
```

**תוצאות:** 3,000+ שורות נמחקו (07/10/2025)

---

## 💡 חלק D: לקחים מהפרויקט

### 1️⃣5️⃣ Firebase Integration

**Timestamp Converter:**

```dart
// lib/models/timestamp_converter.dart
@JsonSerializable()
class MyModel {
  @TimestampConverter()  // ← אוטומטי!
  @JsonKey(name: 'created_date')
  final DateTime createdDate;
}
```

**household_id Pattern:**

```dart
// Repository מוסיף household_id, לא המודל
await _firestore
  .collection('items')
  .where('household_id', isEqualTo: householdId)
  .get();
```

**💡 הסבר מלא:** [LESSONS_LEARNED.md - Firebase](LESSONS_LEARNED.md#firebase-integration)

---

### 1️⃣6️⃣ Provider Patterns

**Error Recovery:**

```dart
bool get hasError => _errorMessage != null;
Future<void> retry() async { _errorMessage = null; await load(); }
void clearAll() { _items = []; _errorMessage = null; notifyListeners(); }
```

**Logging:**

```dart
debugPrint('📥 load() | ✅ success | ❌ error | 🔔 notify | 🔄 retry');
```

---

### 1️⃣7️⃣ Data & Storage

**Cache Pattern:**

```dart
String _cacheKey = "";
List<Item> _cached = [];

List<Item> get filtered {
  final key = "$filter1|$filter2";
  if (key == _cacheKey) return _cached;  // O(1) ⚡
  _cached = _items.where(...).toList();
  _cacheKey = key;
  return _cached;
}
```

**Hybrid Strategy:**

```dart
// טען מקומי מיידית
final items = await _hive.getAll();

// עדכן מחירים ברקע
_api.updatePrices(items).then((_) => debugPrint('✅'));

return items;  // 4s → 1s (פי 4 מהיר יותר!)
```

**💡 דוגמאות מלאות:** [LESSONS_LEARNED.md - Data & Storage](LESSONS_LEARNED.md#data--storage)

---

### 1️⃣8️⃣ Services Architecture

| סוג | תכונות | דוגמה |
|-----|---------|-------|
| 🟢 Static | כל methods `static` | `OcrService.extract()` |
| 🔵 Instance | יש state + `dispose()` | `AuthService(_auth)` |
| 🟡 Mock | לפיתוח בלבד | בדוק Dead Code! |

---

## 📚 קבצים נוספים

| קובץ | תוכן |
|------|------|
| **[LESSONS_LEARNED.md](LESSONS_LEARNED.md)** | דוגמאות מפורטות + הסברים |
| **[WORK_LOG.md](WORK_LOG.md)** | היסטוריה - קרא בתחילת שיחה! |
| **[README.md](README.md)** | Overview + Setup |

---

## 📊 זמני Code Review

| קובץ | זמן | בדיקה |
|------|-----|--------|
| Provider | 2-3' | Repository? Error handling? Logging? |
| Screen | 3-4' | SafeArea? 3 States? RTL? |
| Model | 1-2' | JsonSerializable? copyWith? |
| Service | 3' | Static/Instance? dispose()? |
| Dead Code | 5-10' | 0 imports? |

---

## 🎓 סיכום מהיר

### ✅ עשה תמיד
- קרא WORK_LOG בתחילה
- חפש בעצמך
- Logging מפורט
- 3 Empty States
- Error Recovery
- Constants

### ❌ אל תעשה
- אל תבקש מהמשתמש לחפש
- אל תשתמש ב-Web APIs
- אל תשאיר Dead Code
- אל תשכח SafeArea
- אל להתעלם משגיאות

### 🔗 קישורים מהירים
- **בעיה?** → [טבלת בעיות](#-טבלת-בעיות-נפוצות)
- **דוגמה?** → [LESSONS_LEARNED.md](LESSONS_LEARNED.md)
- **היסטוריה?** → [WORK_LOG.md](WORK_LOG.md)

---

**גרסה:** 6.0 - תמציתי + קישורים  
**תאימות:** Flutter 3.27+ | Mobile Only  
**עדכון:** 07/10/2025  
**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻
