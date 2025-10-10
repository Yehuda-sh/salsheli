// file: AI_DEV_GUIDELINES.md

# 🤖 AI Development Guidelines - salsheli Project

> **מטרה:** מדריך מהיר לסוכני AI - כל מה שצריך בעמוד אחד  
> **עדכון:** 10/10/2025 | **גרסה:** 7.4 - File Paths Fix  
> 💡 **לדוגמאות מפורטות:** ראה [LESSONS_LEARNED.md](LESSONS_LEARNED.md)

---

## 📖 ניווט מהיר

**🚀 [Quick Start](#-quick-start)** | **🤖 [AI Instructions](#-הוראות-למערכות-ai)** | **✅ [Code Review](#-code-review-checklist)** | **📊 [Project Stats](#-project-stats)** | **🔗 [למידע מפורט](#-למידע-מפורט)**

---

## 🚀 Quick Start

### 📋 טבלת בעיות נפוצות (פתרון תוך 30 שניות)

| בעיה                         | פתרון                                | קישור                                                  |
| ---------------------------- | ------------------------------------ | ------------------------------------------------------ |
| 🔴 קובץ לא בשימוש            | חפש imports → 0 = **חפש Provider!**  | [→](#dead-code-3-types)                                |
| 🟡 קובץ איכותי אבל לא בשימוש | 4 שאלות → **הפעל או מחק?**           | [→](#dormant-code)                                     |
| 🔴 Provider לא מתעדכן        | `addListener()` + `removeListener()` | [LESSONS](LESSONS_LEARNED.md#usercontext-pattern)      |
| 🔴 Timestamp שגיאות          | `@TimestampConverter()`              | [LESSONS](LESSONS_LEARNED.md#timestamp-management)     |
| 🔴 Race condition Auth       | זרוק Exception בשגיאה                | [LESSONS](LESSONS_LEARNED.md#race-condition)           |
| 🔴 Mock Data בקוד            | חיבור ל-Provider אמיתי               | [LESSONS](LESSONS_LEARNED.md#אין-mock-data)            |
| 🔴 Context אחרי async        | שמור `dialogContext` נפרד            | [LESSONS](LESSONS_LEARNED.md#navigation--routing)      |
| 🔴 Color deprecated          | `.withValues(alpha:)`                | [LESSONS](LESSONS_LEARNED.md#deprecated-apis)          |
| 🔴 אפליקציה איטית (UI)       | `.then()` ברקע                       | [LESSONS](LESSONS_LEARNED.md#hybrid-strategy)          |
| 🔴 אפליקציה איטית (שמירה)    | **Batch Processing** (50-100 items)  | [LESSONS](LESSONS_LEARNED.md#batch-processing-pattern) |
| 🔴 Empty state חסר           | Loading/Error/Empty/Initial          | [LESSONS](LESSONS_LEARNED.md#3-4-empty-states)         |
| 🔴 Hardcoded values          | constants מ-lib/core/                | [→](#constants-organization)                           |
| 🔴 Templates לא נטענות       | `npm run create-system-templates`    | [→](#templates-system)                                 |
| 🔴 Access denied שגיאה       | **נתיב מלא מהפרויקט!**               | [→](#file-paths)                                       |

### 🎯 13 עקרונות הזהב (מ-LESSONS_LEARNED)

1. **בדוק Dead Code לפני עבודה!** → 3-Step + חפש Provider + קרא מסכים
2. **Dormant Code = פוטנציאל** → בדוק 4 שאלות לפני מחיקה (אולי שווה להפעיל!)
3. **Dead Code אחרי = חוב טכני** → מחק מיד (אחרי בדיקה 3-step!)
4. **3-4 Empty States חובה** → Loading / Error / Empty / Initial בכל widget
5. **UserContext** → `addListener()` + `removeListener()` בכל Provider
6. **Firebase Timestamps** → `@TimestampConverter()` אוטומטי
7. **Constants מרכזיים** → `lib/core/` + `lib/config/` לא hardcoded
8. **Undo למחיקה** → 5 שניות עם SnackBar
9. **Async ברקע** → `.then()` לפעולות לא-קריטיות (UX פי 4 מהיר)
10. **Logging מפורט** → 🗑️ ✏️ ➕ 🔄 emojis לכל פעולה
11. **Error Recovery** → `retry()` + `hasError` בכל Provider
12. **Cache למהירות** → O(1) במקום O(n) עם `_cachedFiltered`
13. **Config Files** → patterns/constants במקום אחד = maintainability
14. **נתיבי קבצים מלאים!** → `C:\projects\salsheli\...` תמיד! ⭐ (חדש!)

📖 **מקור:** [LESSONS_LEARNED - 13 עקרונות הזהב](LESSONS_LEARNED.md#-13-עקרונות-הזהב)

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
בשיחה האחרונה: Templates System Phase 2 Complete + 6 תבניות מערכת.
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

### 3️⃣.1 נתיבי קבצים - ⚠️ חשוב מאוד! {#file-paths}

**🔴 בעיה נפוצה:** שימוש בנתיב שגוי לקריאת קבצים

**הכלל:** תמיד השתמש בנתיב המלא של הפרויקט!

```powershell
# ✅ נכון - נתיב מלא מהפרויקט
C:\projects\salsheli\lib\core\ui_constants.dart
C:\projects\salsheli\lib\models\template.dart
C:\projects\salsheli\lib\providers\templates_provider.dart

# ❌ שגוי - נתיבים אחרים
C:\Users\...\AppData\Local\AnthropicClaude\...
lib\core\ui_constants.dart  # נתיב יחסי לא עובד!
```

**אם קיבלת שגיאת "Access denied":**

```
1. עצור מיד
2. בדוק את הנתיב בשגיאה
3. תקן לנתיב מלא: C:\projects\salsheli\...
4. נסה שוב
```

**דוגמה מהפרויקט (10/10/2025):**

```
❌ טעות:
Filesystem:read_file("lib/core/ui_constants.dart")
→ Error: Access denied - path outside allowed

✅ תיקון:
Filesystem:read_file("C:\projects\salsheli\lib\core\ui_constants.dart")
→ Success!
```

**זכור:** הנתיב המותר היחיד הוא `C:\projects\salsheli\`

**💡 טיפ:** אם לא בטוח, קרא קודם את `list_allowed_directories` לראות מה מותר!

---

### 4️⃣ Dead Code: 3 סוגים

**הכרת הסוגים:**

| סוג                   | תיאור                      | פעולה                   | זמן      |
| --------------------- | -------------------------- | ----------------------- | -------- |
| 🔴 **Dead Code**      | 0 imports, לא בשימוש       | מחק מיד                 | 30 שניות |
| 🟡 **Dormant Code**   | 0 imports, אבל איכותי      | בדוק 4 שאלות → הפעל/מחק | 5 דקות   |
| 🟢 **False Positive** | כלי חיפוש לא מצא, אבל קיים | קרא מסך ידנית!          | 2 דקות   |

---

#### 🔴 Dead Code: מחק מיד

**תהליך בדיקה (30 שניות):**

```powershell
# שלב 1: חיפוש imports
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

**דוגמה מהפרויקט (08/10/2025):**

- 🗑️ 5,000+ שורות Dead Code נמחקו
- חיסכון: 19 דקות רפקטור מיותר (smart_search_input)

📖 [LESSONS - Dead Code Detection](LESSONS_LEARNED.md#dead-code-detection)

---

#### 🟡 Dormant Code: הפעל או מחק?

**Dormant Code** = קוד שלא בשימוש אבל איכותי ועם פוטנציאל.

**תהליך החלטה (4 שאלות):**

```dart
// שאלה 1: האם המודל תומך?
InventoryItem.category  // ✅ כן!

// שאלה 2: האם זה UX שימושי?
// משתמש עם 100+ פריטים רוצה סינון  // ✅ כן!

// שאלה 3: האם הקוד איכותי?
filters_config.dart: 90/100  // ✅ כן!

// שאלה 4: כמה זמן ליישם?
20 דקות  // ✅ כן! (< 30 דק')
```

**תוצאה:**

```
4/4 = הפעל! 🚀
0-3/4 = מחק
```

**דוגמה מהפרויקט (08/10/2025):**

`filters_config.dart`:

- 0 imports (לא בשימוש!)
- אבל: i18n ready, 11 קטגוריות, API נקי
- וגם: InventoryItem.category קיים!
- החלטה: 4/4 → הפעלנו!
- תוצאה: PantryFilters widget + UX +30% תוך 20 דק'

**מתי להפעיל ומתי למחוק:**

| קריטריון   | הפעל    | מחק       |
| ---------- | ------- | --------- |
| מודל תומך  | ✅      | ❌        |
| UX שימושי  | ✅      | ❌        |
| קוד איכותי | ✅      | ❌        |
| < 30 דק'   | ✅      | ❌        |
| **סה"כ**   | **4/4** | **0-3/4** |

📖 [LESSONS - Dormant Code](LESSONS_LEARNED.md#-dormant-code-הפעל-או-מחק)

---

#### 🟢 False Positive: חיפוש לא מצא

**⚠️ False Positive 1: כלי חיפוש לא מצא**

```
❌ AI חיפש:
Ctrl+Shift+F → "import.*upcoming_shop_card.dart"
→ 0 תוצאות

✅ מציאות:
home_dashboard_screen.dart שורה 18:
import '../../widgets/home/upcoming_shop_card.dart';  ← קיים!
```

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

**דוגמאות מהפרויקט:**

- `custom_location.dart` - משמש דרך `LocationsProvider`
- `template.dart` - משמש דרך `TemplatesProvider`
- `habit_preference.dart` - משמש דרך `HabitsProvider`
- `inventory_item.dart` - משמש דרך `InventoryProvider`
- `shopping_list.dart` - משמש דרך `ShoppingListsProvider`
- `receipt.dart` - משמש דרך `ReceiptProvider`

**✅ כלל זהב:**

לפני קביעת Dead Code, חפש:

1. Import ישיר של הקובץ
2. שם המחלקה בקוד
3. שם המחלקה ב-**Providers** (חשוב!)
4. שימוש ב-`List<ClassName>` או `Map<String, ClassName>`
5. רישום ב-**main.dart** (Providers)

📖 [LESSONS - False Positive](LESSONS_LEARNED.md#-false-positive-חיפוש-שלא-מצא)

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

| חפש                      | בעיה        | פתרון                 |
| ------------------------ | ----------- | --------------------- |
| `dart:html`              | Browser     | ❌ אסור Mobile-only   |
| `localStorage`           | Web         | SharedPreferences     |
| `.withOpacity`           | Deprecated  | `.withValues(alpha:)` |
| `TODO 2023`              | ישן         | מחק/תקן               |
| `mockResults` / `mock`   | Mock Data   | Provider אמיתי        |
| `padding: 16`            | Hardcoded   | `kSpacingMedium`      |
| `await saveAll()` בלולאה | Performance | Batch Processing      |

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

📖 **דוגמאות מלאות:**

- [LESSONS - Provider Structure](LESSONS_LEARNED.md#provider-structure)
- `templates_provider.dart` - TemplatesProvider (470 שורות)
- `shopping_lists_provider.dart` - ShoppingListsProvider

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

**דוגמאות מהפרויקט:**

- `template.dart` + `template.g.dart` - Template + TemplateItem
- `shopping_list.dart` + `shopping_list.g.dart`
- `receipt.dart` + `receipt.g.dart`

---

#### **Repository (2-3 דק')**

```dart
// ✅ Interface
abstract class MyRepository {
  Future<List<MyModel>> fetch(String householdId);
  Future<void> save(MyModel item, String householdId);
  Future<void> delete(String id, String householdId);
}

// ✅ Firebase Implementation
class FirebaseMyRepository implements MyRepository {
  final FirebaseFirestore _firestore;

  @override
  Future<List<MyModel>> fetch(String householdId) async {
    final snapshot = await _firestore
        .collection('my_collection')
        .where('household_id', isEqualTo: householdId)
        .get();
    return snapshot.docs.map((doc) => MyModel.fromJson(doc.data())).toList();
  }
}
```

**בדוק:** Interface + Implementation? household_id filtering? Logging?

**דוגמאות מהפרויקט:**

- `templates_repository.dart` + `firebase_templates_repository.dart`
- `shopping_lists_repository.dart` + `firebase_shopping_lists_repository.dart`

📖 [LESSONS - Repository Pattern](LESSONS_LEARNED.md#repository-pattern)

---

#### **Service (3 דק')**

| סוג         | מתי             | דוגמה                  |
| ----------- | --------------- | ---------------------- |
| 🟢 Static   | פונקציות טהורות | `OcrService.extract()` |
| 🔵 Instance | HTTP + state    | `AuthService(_auth)`   |
| 🟡 Mock     | ⚠️ פיתוח בלבד   | בדוק Dead Code!        |

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

#### 5. Batch Processing (Performance)

```dart
// ❌ איטי - שומר 1000+ items בבת אחת
await box.putAll(items); // UI blocking!

// ✅ מהיר - batches של 100
for (int i = 0; i < items.length; i += 100) {
  final batch = items.sublist(i, min(i + 100, items.length));
  await box.putAll(batch);
  await Future.delayed(Duration(milliseconds: 10)); // UI update
  onProgress?.call(i + batch.length, items.length);
}
```

**מתי להשתמש:**

- ✅ שמירה/טעינה של 100+ items
- ✅ פעולות I/O כבדות (Hive, DB)
- ✅ כל פעולה שגורמת ל-Skipped Frames

📖 [LESSONS - Batch Processing](LESSONS_LEARNED.md#batch-processing-pattern)

---

### 📐 Constants Organization

```
lib/core/
├── constants.dart       ← ListType, categories, storage, collections
├── ui_constants.dart    ← Spacing, buttons, borders, durations
└── status_colors.dart   ← Status colors

lib/l10n/
├── app_strings.dart     ← UI strings (i18n ready)
└── strings/
    └── list_type_mappings_strings.dart

lib/config/
├── household_config.dart        ← 11 household types
├── list_type_mappings.dart      ← Type → Categories (140+ items)
├── list_type_groups.dart        ← 3 groups (Shopping/Specialty/Events)
├── filters_config.dart          ← Filter texts
├── stores_config.dart           ← Store names + variations
└── receipt_patterns_config.dart ← OCR Regex patterns
```

**שימוש:**

```dart
// ✅ טוב
SizedBox(height: kSpacingMedium)
Text(AppStrings.common.logout)
final type = HouseholdConfig.getLabel('family')
final suggestions = ListTypeMappings.getSuggestedItemsForType(ListType.super_)

// ❌ רע
SizedBox(height: 16.0)
Text('התנתק')
final type = 'משפחה'
final suggestions = ['חלב', 'לחם']
```

📖 [LESSONS - Constants Organization](LESSONS_LEARNED.md#constants-organization)

---

## 📊 Project Stats

### **מבנה הפרויקט (10/10/2025)**

| קטגוריה            | כמות | הערות                                                                                                                                               |
| ------------------ | ---- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Models**         | 11   | UserEntity, ShoppingList, **Template** ⭐, Receipt, InventoryItem, ProductEntity, Suggestion, HabitPreference, CustomLocation + enums               |
| **Providers**      | 9    | UserContext, ShoppingLists, **Templates** ⭐, Inventory, Receipt, Products, Suggestions, Habits, Locations                                          |
| **Repositories**   | 15   | 8 Firebase + 7 interfaces (כולל **Templates** ⭐)                                                                                                   |
| **Services**       | 7    | Auth, Shufersal, OCR, Parser, Stats, Onboarding, Prefs                                                                                              |
| **Screens**        | 30+  | Auth(2), Home(3), Shopping(8), Lists(3), Receipts(2), Pantry(1), Price(1), Habits(1), Insights(1), Settings(1), Onboarding(2), Welcome(1), Index(1) |
| **Widgets**        | 25+  | Common(2), Home(2), Auth(2) + 19 נוספים                                                                                                             |
| **Config Files**   | 6    | Household, Mappings, Groups, Filters, Stores, Patterns                                                                                              |
| **Core Constants** | 3    | constants, ui_constants, status_colors                                                                                                              |

### **Templates System (חדש! 10/10/2025)** ⭐

| רכיב                 | תיאור                                                                          |
| -------------------- | ------------------------------------------------------------------------------ |
| **Model**            | `template.dart` (400+ שורות) - Template + TemplateItem                         |
| **Provider**         | `templates_provider.dart` (470 שורות) - CRUD + Getters                         |
| **Repository**       | `templates_repository.dart` + `firebase_templates_repository.dart` (360 שורות) |
| **Formats**          | system, personal, shared, assigned                                             |
| **System Templates** | 6 תבניות (66 פריטים): סופר, בית מרקחת, יום הולדת, אירוח, משחקים, קמפינג        |
| **npm Script**       | `npm run create-system-templates`                                              |

### **נתונים**

| סוג                 | כמות                     |
| ------------------- | ------------------------ |
| **מוצרים**          | 1,758 (Hive + Firestore) |
| **סוגי רשימות**     | 21                       |
| **פריטים מוצעים**   | 140+ (לכל סוג)           |
| **תבניות מערכת**    | 6 (66 פריטים)            |
| **משתמשי דמו**      | 3                        |
| **Household Types** | 11                       |

---

## 🔗 למידע מפורט

### 📚 קבצים נוספים

| קובץ                                         | תוכן                                | מתי לקרוא        |
| -------------------------------------------- | ----------------------------------- | ---------------- |
| **[LESSONS_LEARNED.md](LESSONS_LEARNED.md)** | דפוסים טכניים מפורטים + דוגמאות קוד | כשצריך הסבר עמוק |
| **[WORK_LOG.md](WORK_LOG.md)**               | היסטוריה + שינויים אחרונים          | בתחילת כל שיחה   |
| **[README.md](README.md)**                   | Overview + Setup + Dependencies     | Setup ראשוני     |

### 🎓 נושאים מפורטים ב-LESSONS_LEARNED

- **ארכיטקטורה:** [Firebase Integration](LESSONS_LEARNED.md#מעבר-ל-firebase) | [Timestamp Management](LESSONS_LEARNED.md#timestamp-management) | [household_id Pattern](LESSONS_LEARNED.md#householdid-pattern) | [Repository Pattern](LESSONS_LEARNED.md#repository-pattern)
- **דפוסי קוד:** [UserContext Pattern](LESSONS_LEARNED.md#usercontext-pattern) | [Provider Structure](LESSONS_LEARNED.md#provider-structure) | [Cache Pattern](LESSONS_LEARNED.md#cache-pattern) | [Config Files](LESSONS_LEARNED.md#config-files-pattern) | **[Batch Processing](LESSONS_LEARNED.md#batch-processing-pattern)**
- **UX & UI:** [3-4 Empty States](LESSONS_LEARNED.md#3-4-empty-states) | [Undo Pattern](LESSONS_LEARNED.md#undo-pattern) | [UI/UX Review](LESSONS_LEARNED.md#uiux-review)
- **Troubleshooting:** [Dead Code Detection](LESSONS_LEARNED.md#dead-code-detection) | **[Dormant Code](LESSONS_LEARNED.md#dormant-code-הפעל-או-מחק)** | [Race Conditions](LESSONS_LEARNED.md#race-condition-firebase-auth) | [Deprecated APIs](LESSONS_LEARNED.md#deprecated-apis)

### 🆕 Templates System Deep Dive

**Phase 1 (10/10/2025):** Foundation - Models + Repository + Provider

**לקחים:**

- Repository Pattern = הפרדת אחריות (DB access vs State management)
- 4 שאילתות נפרדות: system, personal, shared, assigned
- Security: אסור לשמור/למחוק `is_system=true`
- UserContext Integration: Listener Pattern לעדכון אוטומטי

**קבצים:**

```
lib/models/template.dart + template.g.dart
lib/providers/templates_provider.dart
lib/repositories/templates_repository.dart
lib/repositories/firebase_templates_repository.dart
scripts/create_system_templates.js
```

**Usage:**

```dart
// קריאת תבניות
final provider = context.read<TemplatesProvider>();
await provider.loadTemplates();

// תבניות מערכת בלבד
final systemTemplates = provider.systemTemplates;

// יצירת תבנית אישית
await provider.createTemplate(template);
```

---

## 📊 זמני Code Review

| קובץ         | זמן   | בדיקה                                             |
| ------------ | ----- | ------------------------------------------------- |
| Provider     | 2-3'  | Repository? Error handling? Logging? UserContext? |
| Screen       | 3-4'  | SafeArea? 3-4 States? RTL?                        |
| Model        | 1-2'  | JsonSerializable? copyWith?                       |
| Repository   | 2-3'  | Interface? household_id? Logging?                 |
| Service      | 3'    | Static/Instance? dispose()?                       |
| Config       | 1-2'  | i18n ready? Constants?                            |
| Dead Code    | 5-10' | 0 imports? בדיקה ידנית? Provider usage?           |
| Dormant Code | 5'    | 4 שאלות? הפעל או מחק?                             |

---

## 🎓 סיכום מהיר

### ✅ עשה תמיד

- קרא WORK_LOG בתחילה
- **נתיב מלא לקבצים: C:\projects\salsheli\...** ⭐ (חדש!)
- Dead Code 3-Step לפני עבודה (3 סוגים!)
- Dormant Code? בדוק 4 שאלות (אולי שווה להפעיל!)
- חפש בעצמך (אל תבקש מהמשתמש)
- Logging מפורט (🗑️ ✏️ ➕ 🔄 ✅ ❌)
- 3-4 Empty States
- Error Recovery (retry + clearAll)
- Constants (lib/core/ + lib/config/)
- UserContext Integration ב-Providers
- Batch Processing לפעולות כבדות (100+ items)

### ❌ אל תעשה

- **אל תשתמש בנתיבים יחסיים או שגויים!** ⭐ (חדש!)
- אל תעבוד על קובץ לפני בדיקת Dead Code
- אל תמחק Dormant Code ללא בדיקת 4 שאלות
- אל תבקש מהמשתמש לחפש
- אל תשתמש ב-Web APIs (Mobile-only!)
- אל תשאיר Dead Code
- אל תשכח SafeArea + SingleChildScrollView
- אל תתעלם משגיאות
- אל תשתמש ב-Mock Data
- אל תשכח Repository Pattern (לא Firebase ישירות ב-Provider!)
- אל תשמור 1000+ items בבת אחת (Batch Processing!)

### 🆕 Templates System

- ✅ 6 תבניות מערכת: `npm run create-system-templates`
- ✅ 4 formats: system/personal/shared/assigned
- ✅ Security Rules: רק Admin יכול ליצור `is_system=true`
- ✅ TemplatesProvider: UserContext Integration + CRUD מלא

### 🟡 Dormant Code Pattern

- ✅ 4 שאלות: מודל תומך? UX שימושי? קוד איכותי? < 30 דק'?
- ✅ 4/4 = הפעל! (דוגמה: filters_config → PantryFilters)
- ✅ 0-3/4 = מחק

---

**גרסה:** 7.4 - File Paths Fix (640 שורות)  
**תאימות:** Flutter 3.27+ | Mobile Only  
**עדכון:** 10/10/2025  
**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻
