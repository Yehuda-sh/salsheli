# 🤖 AI Development Guidelines - salsheli Project

> **מטרה:** מדריך מהיר לסוכני AI - כל מה שצריך בעמוד אחד  
> **עדכון:** 09/10/2025 | **גרסה:** 7.1 - False Positive 2: Provider Usage  
> 💡 **לדוגמאות מפורטות:** ראה [LESSONS_LEARNED.md](LESSONS_LEARNED.md)

---

## 📖 ניווט מהיר

**🚀 [Quick Start](#-quick-start)** | **🤖 [AI Instructions](#-הוראות-למערכות-ai)** | **✅ [Code Review](#-code-review-checklist)** | **🔗 [למידע מפורט](#-למידע-מפורט)**

---

## 🚀 Quick Start

### 📋 טבלת בעיות נפוצות (פתרון תוך 30 שניות)

| בעיה | פתרון | קישור |
|------|-------|-------|
| 🔴 קובץ לא בשימוש | חפש imports → 0 = **חפש Provider!** | [→](#dead-code-3-step) |
| 🔴 Provider לא מתעדכן | `addListener()` + `removeListener()` | [LESSONS](LESSONS_LEARNED.md#usercontext-pattern) |
| 🔴 Timestamp שגיאות | `@TimestampConverter()` | [LESSONS](LESSONS_LEARNED.md#timestamp-management) |
| 🔴 Race condition Auth | זרוק Exception בשגיאה | [LESSONS](LESSONS_LEARNED.md#race-condition) |
| 🔴 Mock Data בקוד | חיבור ל-Provider אמיתי | [LESSONS](LESSONS_LEARNED.md#אין-mock-data) |
| 🔴 Context אחרי async | שמור `dialogContext` נפרד | [LESSONS](LESSONS_LEARNED.md#navigation--routing) |
| 🔴 Color deprecated | `.withValues(alpha:)` | [LESSONS](LESSONS_LEARNED.md#deprecated-apis) |
| 🔴 אפליקציה איטית | `.then()` ברקע | [LESSONS](LESSONS_LEARNED.md#hybrid-strategy) |
| 🔴 Empty state חסר | Loading/Error/Empty/Initial | [LESSONS](LESSONS_LEARNED.md#3-4-empty-states) |
| 🔴 Hardcoded values | constants מ-lib/core/ | [→](#constants-organization) |

### 🎯 15 כללי הזהב

1. **קרא WORK_LOG.md** - בתחילת כל שיחה על הפרויקט
2. **עדכן WORK_LOG.md** - רק שינויים משמעותיים (שאל קודם!)
3. **בדוק Dead Code קודם!** - לפני רפקטור: 3-Step + חפש Provider
4. **חפש בעצמך** - אל תבקש מהמשתמש לחפש קבצים
5. **תמציתי** - ישר לעניין, פחות הסברים
6. **Logging** - 🗑️ ✏️ ➕ 🔄 ✅ ❌ בכל method
7. **3-4 States** - Loading/Error/Empty/Initial בכל widget
8. **Error Recovery** - `hasError` + `retry()` + `clearAll()`
9. **Undo** - 5 שניות למחיקה
10. **Cache** - O(1) במקום O(n)
11. **Timestamps** - `@TimestampConverter()` אוטומטי
12. **Dead Code אחרי** - 0 imports = מחיקה מיידית (אחרי בדיקה!)
13. **Constants** - `kSpacingMedium` לא `16.0`
14. **Config Files** - patterns/constants במקום אחד
15. **UI Review** - "בדוק קובץ" = בדוק גם UI ([→](LESSONS_LEARNED.md#uiux-review))

### ⚡ בדיקה מהירה (5 דק')

```powershell
# Deprecated APIs
Ctrl+Shift+F → ".withOpacity"  # 0 תוצאות = ✅
Ctrl+Shift+F → "WillPopScope"  # 0 תוצאות = ✅

# Dead Code
Ctrl+Shift+F → "import.*my_file.dart"  # 0 = בדוק ידנית!

# Code Quality
flutter analyze  # 0 issues = ✅

# Constants
Ctrl+Shift+F → "height: 16"   # צריך kSpacingMedium
Ctrl+Shift+F → "padding: 8"   # צריך kSpacingSmall
```

---

## 🤖 הוראות למערכות AI

### 1️⃣ התחלת שיחה

**בכל שיחה על הפרויקט:**

```
1. קרא WORK_LOG.md
2. הצג סיכום (2-3 שורות) של העבודה האחרונה
3. שאל מה לעשות היום
```

**✅ דוגמה:**
```
[קורא אוטומטית]
בשיחה האחרונה: Home Dashboard Modern Design + 140 פריטים מוצעים.
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

### 4️⃣ Dead Code 3-Step Verification

**🔴 כלל זהב: לפני רפקטור/תיקון - בדוק אם הקובץ בשימוש!**

```powershell
# שלב 1: חיפוש imports (30 שניות)
Ctrl+Shift+F → "import.*my_widget.dart"
# → 0 תוצאות = חשד ל-Dead Code

# שלב 2: חיפוש שם המחלקה
Ctrl+Shift+F → "MyWidget"
# → 0 תוצאות = חשד חזק

# שלב 3: בדיקה ידנית במסכים מרכזיים (חובה!)
# קרא: home_dashboard_screen.dart, main.dart, app.dart
# → אין import = Dead Code מאומת!
```

**החלטה:**
```
אם 0 imports + 0 שימושים + בדיקה ידנית:
  ├─ אופציה 1: 🗑️ מחיקה (מומלץ!)
  ├─ אופציה 2: 📝 שאל משתמש אם לשמור
  └─ אופציה 3: 🚫 אל תתחיל לעבוד!
```

**⚠️ False Positive 1:** כלי חיפוש לפעמים לא מוצא imports → בדיקה ידנית חובה!

**⚠️ False Positive 2: Provider Usage**

מודל עשוי להשתמש דרך Provider ללא import ישיר:

```powershell
# חיפוש רגיל
Ctrl+Shift+F → "import.*custom_location.dart"
# → 0 תוצאות

# ⚠️ אבל! חפש בשם מחלקת Provider
Ctrl+Shift+F → "LocationsProvider"
Ctrl+Shift+F → "List<CustomLocation>"
# → יש שימוש דרך Provider!
```

**דוגמה מהפרויקט:**
- `custom_location.dart` - 0 imports ישירים
- אבל: `LocationsProvider` משתמש ב-`List<CustomLocation>`
- התוצאה: המודל בשימוש דרך Provider!

**כלל נוסף:** לפני קביעת Dead Code, חפש:
1. Import ישיר של הקובץ
2. שם המחלקה בקוד
3. שם המחלקה ב-**Providers** (חשוב!)
4. שימוש ב-`List<ClassName>` או `Map<String, ClassName>`
5. רישום ב-**main.dart** (Providers)

📖 **למידע מפורט:** [LESSONS_LEARNED - Dead Code Detection](LESSONS_LEARNED.md#dead-code-detection)

---

### 5️⃣ פורמט תשובות

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
שלב 1: הכנה (5 דק')...
[3 פסקאות הסבר]
```

**PowerShell בלבד:**
```powershell
# ✅ Windows
Remove-Item -Recurse -Force lib/old/

# ❌ Linux/Mac - אסור!
rm -rf lib/old/
```

---

## ✅ Code Review Checklist

### 🔍 בדיקות אוטומטיות

| חפש | בעיה | פתרון |
|-----|------|-------|
| `dart:html` | Browser | ❌ אסור Mobile-only |
| `localStorage` | Web | SharedPreferences |
| `.withOpacity` | Deprecated | `.withValues(alpha:)` |
| `TODO 2023` | ישן | מחק/תקן |
| `mockResults` / `mock` | Mock Data | Provider אמיתי |
| `padding: 16` | Hardcoded | `kSpacingMedium` |

---

### 📦 Checklist לפי סוג קובץ

#### **Provider (2-3 דק')**

```dart
class MyProvider extends ChangeNotifier {
  // ✅ חובה לבדוק:
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
  
  // ✅ Error Recovery
  Future<void> retry() async { _errorMessage = null; await load(); }
  void clearAll() { _items = []; _errorMessage = null; notifyListeners(); }
  
  // ✅ Logging
  debugPrint('📥 load() | ✅ success | ❌ error');
  
  // ✅ Dispose
  @override
  void dispose() { debugPrint('🗑️ dispose()'); super.dispose(); }
}
```

**בדוק:** Repository? Error handling? Logging? Getters? Recovery?

📖 **דוגמה מלאה:** [LESSONS - Provider Structure](LESSONS_LEARNED.md#provider-structure)

---

#### **Screen (3-4 דק')**

```dart
// ✅ חובה לבדוק:
- SafeArea + SingleChildScrollView
- Consumer לקריאה | context.read לפעולות
- כפתורים 48x48 מינימום
- padding symmetric (RTL)
- 3-4 Empty States (Loading/Error/Empty/Initial)
- dispose חכם (שמור provider ב-initState)
```

📖 **UI/UX Review מלא:** [LESSONS - UI/UX Review](LESSONS_LEARNED.md#uiux-review)

---

#### **Model (1-2 דק')**

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

**בדוק:** `@JsonSerializable()` | שדות `final` | `copyWith()` | `*.g.dart` קיים

---

#### **Service (3 דק')**

| סוג | מתי | דוגמה |
|-----|-----|--------|
| 🟢 Static | פונקציות טהורות | `OcrService.extract()` |
| 🔵 Instance | HTTP + state | `AuthService(_auth)` |
| 🟡 Mock | ⚠️ פיתוח בלבד | בדוק Dead Code! |

---

### 🎨 דפוסים חובה

#### 1. אין Mock Data

```dart
// ❌ אסור
final mockResults = [{"product": "...", "price": 8.9}];

// ✅ חובה
final provider = context.read<MyProvider>();
final results = await provider.searchItems(term);
```

📖 [LESSONS - אין Mock Data](LESSONS_LEARNED.md#אין-mock-data-בקוד-production)

---

#### 2. 3-4 Empty States

```dart
if (provider.isLoading) return _buildLoading();
if (provider.hasError) return _buildError();
if (provider.isEmpty && searched) return _buildEmptyResults();
if (provider.isEmpty) return _buildEmptyInitial();
return _buildContent();
```

📖 [LESSONS - 3-4 Empty States](LESSONS_LEARNED.md#3-4-empty-states)

---

#### 3. Undo Pattern

```dart
SnackBar(
  content: Text('${item.name} נמחק'),
  duration: Duration(seconds: 5),
  backgroundColor: Colors.red,
  action: SnackBarAction(
    label: 'ביטול',
    onPressed: () => restore(),
  ),
)
```

📖 [LESSONS - Undo Pattern](LESSONS_LEARNED.md#undo-pattern)

---

#### 4. Visual Feedback

```dart
// ✅ הצלחה = ירוק | ❌ שגיאה = אדום | ⚠️ אזהרה = כתום
SnackBar(backgroundColor: Colors.green, ...)
```

📖 [LESSONS - Visual Feedback](LESSONS_LEARNED.md#visual-feedback)

---

### 📐 Constants Organization

```
lib/core/
├── constants.dart       ← ListType, categories, storage
├── ui_constants.dart    ← Spacing, buttons, borders

lib/l10n/
└── app_strings.dart     ← UI strings (i18n ready)

lib/config/
├── list_type_mappings.dart      ← Type → Categories
├── filters_config.dart          ← Filter texts
├── stores_config.dart           ← Store names
└── receipt_patterns_config.dart ← OCR Regex
```

**שימוש:**
```dart
// ✅ טוב
SizedBox(height: kSpacingMedium)
Text(AppStrings.common.logout)

// ❌ רע
SizedBox(height: 16.0)
Text('התנתק')
```

📖 [LESSONS - Constants Organization](LESSONS_LEARNED.md#constants-organization)

---

## 🔗 למידע מפורט

### 📚 קבצים נוספים

| קובץ | תוכן | מתי לקרוא |
|------|------|-----------|
| **[LESSONS_LEARNED.md](LESSONS_LEARNED.md)** | דפוסים טכניים מפורטים + דוגמאות קוד | כשצריך הסבר עמוק |
| **[WORK_LOG.md](WORK_LOG.md)** | היסטוריה + שינויים אחרונים | בתחילת כל שיחה |
| **[README.md](README.md)** | Overview + Setup + Dependencies | Setup ראשוני |

### 🎓 נושאים מפורטים ב-LESSONS_LEARNED

- **ארכיטקטורה:** [Firebase Integration](LESSONS_LEARNED.md#מעבר-ל-firebase) | [Timestamp Management](LESSONS_LEARNED.md#timestamp-management) | [household_id Pattern](LESSONS_LEARNED.md#householdid-pattern)
- **דפוסי קוד:** [UserContext Pattern](LESSONS_LEARNED.md#usercontext-pattern) | [Provider Structure](LESSONS_LEARNED.md#provider-structure) | [Cache Pattern](LESSONS_LEARNED.md#cache-pattern) | [Config Files](LESSONS_LEARNED.md#config-files-pattern)
- **UX & UI:** [3-4 Empty States](LESSONS_LEARNED.md#3-4-empty-states) | [Undo Pattern](LESSONS_LEARNED.md#undo-pattern) | [UI/UX Review](LESSONS_LEARNED.md#uiux-review)
- **Troubleshooting:** [Dead Code Detection](LESSONS_LEARNED.md#dead-code-detection) | [Race Conditions](LESSONS_LEARNED.md#race-condition-firebase-auth) | [Deprecated APIs](LESSONS_LEARNED.md#deprecated-apis)

---

## 📊 זמני Code Review

| קובץ | זמן | בדיקה |
|------|-----|--------|
| Provider | 2-3' | Repository? Error handling? Logging? |
| Screen | 3-4' | SafeArea? 3-4 States? RTL? |
| Model | 1-2' | JsonSerializable? copyWith? |
| Service | 3' | Static/Instance? dispose()? |
| Dead Code | 5-10' | 0 imports? בדיקה ידנית? |

---

## 🎓 סיכום מהיר

### ✅ עשה תמיד
- קרא WORK_LOG בתחילה
- Dead Code 3-Step לפני עבודה
- חפש בעצמך (אל תבקש מהמשתמש)
- Logging מפורט
- 3-4 Empty States
- Error Recovery
- Constants

### ❌ אל תעשה
- אל תעבוד על קובץ לפני בדיקת Dead Code
- אל תבקש מהמשתמש לחפש
- אל תשתמש ב-Web APIs
- אל תשאיר Dead Code
- אל תשכח SafeArea
- אל תתעלם משגיאות

---

**גרסה:** 7.1 - False Positive 2: Provider Usage (380 שורות)  
**תאימות:** Flutter 3.27+ | Mobile Only  
**עדכון:** 09/10/2025  
**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻
