# ⚡ Quick Reference - 2 דקות Max

> **מטרה:** מצא תשובה תוך 30 שניות, לא קרא 15 עמודים!  
> **גרסה:** 1.0 | **עדכון:** 15/10/2025

---

## 🔴 Dead Code? (30 שניות)

**שלב 1:** חיפוש import
```powershell
Ctrl+Shift+F → "import.*my_file.dart"
# → 0 תוצאות = חשד!
```

**שלב 2:** חיפוש class
```powershell
Ctrl+Shift+F → "MyClass"
# → 0 תוצאות = חזק!
```

**שלב 3:** בדיקה ידנית (חובה!)
```
קרא את:
  - home_dashboard_screen.dart
  - main.dart
  - app.dart
# → אין import = Dead Code מאומת!
```

**החלטה:**
- 0 imports + 0 uses + בדיקה ✅ → **🗑️ מחק!**

📖 **לעומק:** [AI_DEV_GUIDELINES.md - Dead Code Detection](AI_DEV_GUIDELINES.md#-dead-code-מחק-מיד)

---

## ⚠️ Dead Code - מלכודות נפוצות! (חדש - 16/10/2025)

### המלכודת של onboarding_data.dart

**בעיה:** קובץ נראה כמו Dead Code אבל בעצם בשימוש!

```powershell
# חיפוש רגיל - 0 תוצאות ❌
Ctrl+Shift+F → "import.*onboarding_data"
Ctrl+Shift+F → "OnboardingData"

# אבל! חיפוש נתיב יחסי מוצא! ✅
Ctrl+Shift+F → "data/onboarding_data"
# מצא: import '../../data/onboarding_data.dart';
```

### בדיקה משופרת - 5 שלבים

1. **חיפוש import מלא:**
   ```powershell
   "import.*my_file.dart"
   ```

2. **חיפוש import יחסי:**
   ```powershell
   "folder_name/my_file"
   ```

3. **חיפוש שם המחלקה:**
   ```powershell
   "MyClassName"
   ```

4. **בדוק מסכים קשורים:**
   - אם זה data → חפש במסך שמשתמש בdata
   - אם זה config → חפש בproviders
   - אם זה model → חפש בrepositories

5. **קרא את הקובץ עצמו:**
   - חפש comments כמו "דוגמה בלבד"
   - חפש "DO NOT USE"
   - חפש "EXAMPLE"

### דוגמאות מהפרויקט

| קובץ | נראה Dead? | באמת? | סיבה |
|------|------------|--------|-------|
| `onboarding_data.dart` | ✅ כן | ❌ **בשימוש!** | import יחסי ב-onboarding_screen |
| `create_list_dialog_usage_example.dart` | ✅ כן | ✅ **Dead** | מסומן "דוגמה בלבד" |
| `cleanup_screen.dart` | ✅ כן | ✅ **Dead** | מסך debug לא בroutes |

### כלל זהב 🏆

> **אף פעם אל תמחק קובץ רק בגלל 0 imports!**  
> תמיד בדוק 5 שלבים + קרא את הקובץ

---

## 🟡 Dormant Code? (2 דקות)

**בדוק 4 שאלות:**

```
1. האם המודל תומך? (יש שדה בפרויקט)
   ✅ כן → נקודה 1
   ❌ לא → תוצאה: מחק

2. האם זה UX שימושי?
   ✅ כן → נקודה 2
   ❌ לא → תוצאה: מחק

3. האם הקוד איכותי? (90+ / 100)
   ✅ כן → נקודה 3
   ❌ לא → תוצאה: מחק

4. כמה זמן ליישם? (< 30 דקות)
   ✅ כן → נקודה 4
   ❌ לא → תוצאה: מחק
```

**תוצאה:**
- **4/4** → 🚀 הפעל! (דוגמה: `filters_config.dart` → `PantryFilters`)
- **0-3/4** → 🗑️ מחק

📖 **לעומק:** [AI_DEV_GUIDELINES.md - Dormant Code](AI_DEV_GUIDELINES.md#-dormant-code-הפעל-או-מחק)

---

## ⚙️ Constants - איפה?

| סוג | מיקום | דוגמה |
|-----|-------|--------|
| **Spacing** | `lib/core/ui_constants.dart` | `kSpacingSmall` (8px) |
| **Colors** | `lib/core/ui_constants.dart` | `AppBrand.accent` |
| **UI** | `lib/core/ui_constants.dart` | `kButtonHeight` (48px) |
| **Business** | `lib/config/` | `HouseholdConfig`, `ListTypeMappings` |
| **Strings** | `lib/l10n/app_strings.dart` | `AppStrings.common.logout` |

**✅ נכון:**
```dart
SizedBox(height: kSpacingMedium)
Text(AppStrings.common.logout)
```

**❌ שגוי:**
```dart
SizedBox(height: 16)
Text('התנתק')
```

📖 **לעומק:** [AI_DEV_GUIDELINES.md - Constants](AI_DEV_GUIDELINES.md#-constants-organization)

---

## 🎨 i18n - AppStrings

**סדרה של קבועים הטקסטים**

```dart
// ✅ נכון
Text(AppStrings.common.logout)
SnackBar(content: Text(AppStrings.auth.loginFailed))

// ❌ שגוי
Text('התנתק')
SnackBar(content: Text('התחברות נכשלה'))
```

**מבנה:**
```
lib/l10n/
├── app_strings.dart (imports)
└── strings/ (implementations)
    ├── common_strings.dart
    ├── auth_strings.dart
    ├── shopping_strings.dart
    └── ... כל סקשן
```

📖 **לעומק:** [AI_DEV_GUIDELINES.md - i18n](AI_DEV_GUIDELINES.md#i18n---תמיכה-בתרגום)

---

## 🟣 withValues - לא withOpacity!

**❌ ישן (Deprecated):**
```dart
Colors.blue.withOpacity(0.5)
```

**✅ חדש:**
```dart
Colors.blue.withValues(alpha: 0.5)
```

**למה?** `withOpacity` הוסר ב-Flutter 3.22+

---

## 🔄 Deprecated APIs נוספים

### DropdownButtonFormField
**❌ ישן:**
```dart
DropdownButtonFormField(
  value: selectedValue,  // deprecated!
)
```

**✅ חדש:**
```dart
DropdownButtonFormField(
  initialValue: selectedValue,
)
```

### UI Constants
| ישן ❌ | חדש ✅ |
|--------|--------|
| `kQuantityFieldWidth` | `kFieldWidthNarrow` |
| `kBorderRadiusFull` | `kRadiusPill` |

---

## 📱 Async Callbacks - עטוף בlambda!

**❌ שגוי - Type Error:**
```dart
onPressed: _asyncFunction  // אפילו שזה async!
```

**✅ נכון - Lambda:**
```dart
onPressed: () => _asyncFunction()
```

**או:**
```dart
onPressed: () async {
  await _asyncFunction();
}
```

---

## 📦 Context Management - שמור לפני await!

**❌ סכנה:**
```dart
await someAsyncOperation();
Navigator.push(context, ...); // Context לא valid!
```

**✅ נכון:**
```dart
final navigator = Navigator.of(context); // שמור לפני!
await someAsyncOperation();
if (mounted) {
  navigator.push(...);
}
```

**כלל זהב:**
1. שמור context/navigator לפני await
2. בדוק `mounted` אחרי await
3. השתמש ב-reference שנשמר

---

## 🏠 household_id Pattern - Security Rule #1!

**⛔ חובה בכל שאילתה Firestore:**
```dart
// Repository מוסיף household_id
await _firestore
  .collection('items')
  .where('household_id', isEqualTo: householdId)
  .get();
```

**Security Rules:**
```firestore
match /items/{itemId} {
  allow read: if isHouseholdMember(resource.data.household_id);
}
```

**למה?** Multi-tenant security - כל household רואה רק את שלו!

---

## 🏗️ Repository Pattern - לא Firebase ישירות!

**❌ שגוי:**
```dart
class MyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;  // ❌ ישיר!
  
  Future<void> load() async {
    final docs = await _firestore.collection('items').get();
  }
}
```

**✅ נכון:**
```dart
abstract class MyRepository {
  Future<List<Item>> fetch();
}

class MyProvider extends ChangeNotifier {
  final MyRepository _repo;  // ✅ Interface!
  
  Future<void> load() async {
    _items = await _repo.fetch();
  }
}
```

📖 **לעומק:** [AI_DEV_GUIDELINES.md - Repository Pattern](AI_DEV_GUIDELINES.md#repository-1)

---

## 🔄 Error Recovery Pattern

**חובה בכל Provider:**
```dart
class MyProvider extends ChangeNotifier {
  // ✅ retry() - לניסיון חוזר
  void retry() {
    _errorMessage = null;
    notifyListeners();
    _loadData();
  }
  
  // ✅ clearAll() - לניקוי מלא
  void clearAll() {
    _items.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
```

**למה?** UX טוב + ניקוי בהתנתקות

---

## 👥 UserContext Integration

**Pattern חובה:**
```dart
class MyProvider extends ChangeNotifier {
  MyProvider(this._userContext) {
    _userContext.addListener(_onUserChanged); // ✅ האזן
  }
  
  void _onUserChanged() {
    load(_userContext.currentHouseholdId);
  }
  
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged); // ✅ נקה
    super.dispose();
  }
}
```

**למה?** סינכרון אוטומטי עם household הנוכחי

---

## 🔄 Loading States Pattern

```dart
bool _isLoading = false;

Future<void> _handleAction() async {
  setState(() => _isLoading = true); // ✅ התחלה
  
  try {
    await operation();
  } finally {
    if (mounted) setState(() => _isLoading = false); // ✅ סיום
  }
}

// ב-UI:
ElevatedButton(
  onPressed: _isLoading ? null : () => _handleAction(),
  child: _isLoading ? CircularProgressIndicator() : Text('המשך'),
)
```

---

## 💾 Batch Processing - 100+ items?

**❌ איטי - Blocks UI:**
```dart
await box.putAll(items); // 1000+ items בבת אחת!
```

**✅ מהיר:**
```dart
for (int i = 0; i < items.length; i += 100) {
  final batch = items.sublist(i, min(i + 100, items.length));
  await box.putAll(batch);
  await Future.delayed(Duration(milliseconds: 10));
  onProgress?.call(i + batch.length, items.length);
}
```

**⚠️ Firestore Batch Limit:** מקסימום **500 פעולות** לבאץ'!
```dart
for (int i = 0; i < items.length; i += 500) {
  final batch = _firestore.batch();
  // ... הוספת פעולות
  await batch.commit();
}
```

**מתי?**
- ✅ שמירה/טעינה 100+ items
- ✅ פעולות I/O כבדות
- ❌ 10 items → בדלג!

📖 **לעומק:** [AI_DEV_GUIDELINES.md - Batch Processing](AI_DEV_GUIDELINES.md#6-batch-processing-performance)

---

## 💀 Skeleton Screens - למקום CircularProgressIndicator

**❌ ישן (משעמם):**
```dart
if (provider.isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

**✅ חדש (מהיר בעיניים):**
```dart
if (provider.isLoading && provider.items.isEmpty) {
  return ListView.builder(
    itemCount: 5, // 5 skeletons
    itemBuilder: (context, index) => ShoppingItemSkeleton(),
  );
}
```

**דוגמה - ShoppingItemSkeleton:**
```dart
class ShoppingItemSkeleton extends StatelessWidget {
  Widget build(context) {
    return Row([
      SkeletonBox(width: 50, height: 50), // תמונה
      SizedBox(width: 12),
      Expanded(child: Column([
        SkeletonBox(width: double.infinity, height: 16), // שם
        SizedBox(height: 8),
        SkeletonBox(width: 80, height: 12), // כמות
      ])),
    ]);
  }
}
```

📖 **לעומק:** [AI_DEV_GUIDELINES.md - Skeleton Screens](AI_DEV_GUIDELINES.md#-skeleton-screens)

---

## 🎨 Sticky Notes Design - Quick Guide

**מסך UI חייב:**
```dart
Scaffold(
  backgroundColor: kPaperBackground, // ✅ רקע
  body: Stack([
    NotebookBackground(), // ✅ קווי מחברת
    SafeArea(
      child: Column([
        StickyNoteLogo(...), // ✅ לוגו
        StickyNote(...),     // ✅ כותרת/שדות
        StickyButton(...),   // ✅ כפתורים
      ]),
    ),
  ]),
)
```

**עקרונות:**
- 🎨 3 צבעים מקסימום במסך
- 🔄 סיבובים: -0.03 עד 0.03
- 🟡 צבעים: kStickyYellow, kStickyPink, kStickyGreen
- 📱 תמיד Stack עם NotebookBackground

📖 **לעומק:** [STICKY_NOTES_DESIGN.md](STICKY_NOTES_DESIGN.md)

---

## ✨ Micro Animations - Button Taps

**❌ ישן (סטטי):**
```dart
ElevatedButton(
  onPressed: _onSave,
  child: Text('שמור'),
)
```

**✅ חדש (Alive):**
```dart
AnimatedButton(
  onPressed: _onSave,
  child: ElevatedButton(
    onPressed: null,
    child: Text('שמור'),
  ),
)
```

**Effect:** Scale 0.95 + Haptic (150ms)

📖 **לעומק:** [AI_DEV_GUIDELINES.md - Animations](AI_DEV_GUIDELINES.md#-micro-animations)

---

## 🟢 False Positive - חיפוש לא מצא!

**בעיה:** כלי החיפוש לא מצא ב-import, אבל שימוש דרך Provider!

```powershell
# חיפוש רגיל → 0 תוצאות ❌
Ctrl+Shift+F → "import.*custom_location.dart"

# ⚠️ אבל! משמש דרך Provider
Ctrl+Shift+F → "LocationsProvider"  → ✅ יש!
```

**דוגמאות בפרויקט:**
- `custom_location.dart` → דרך `LocationsProvider`
- `template.dart` → דרך `TemplatesProvider`
- `inventory_item.dart` → דרך `InventoryProvider`

**כלל:** לפני Dead Code, חפש גם בשמות Providers!

📖 **לעומק:** [AI_DEV_GUIDELINES.md - False Positive](AI_DEV_GUIDELINES.md#-false-positive-חיפוש-שלא-מצא)

---

## 🚫 File Paths - חשוב ביותר! ⭐

**🔴 בעיה:** שימוש בנתיבים שגויים → "Access denied"

**✅ הכלל:**
```
תמיד השתמש בנתיב מלא מהפרויקט:
C:\projects\salsheli\lib\core\ui_constants.dart
```

**❌ שגוי:**
```
lib\core\ui_constants.dart        ❌ יחסי
./lib/core/ui_constants.dart      ❌ יחסי
C:\Users\...\...\ui_constants.dart ❌ מחוץ לפרויקט
```

**אם קיבלת "Access denied":**
```
1. עצור מיד
2. בדוק את הנתיב בשגיאה
3. תקן ל: C:\projects\salsheli\...
4. נסה שוב
```

📖 **לעומק:** [AI_DEV_GUIDELINES.md - File Paths](AI_DEV_GUIDELINES.md#-31-נתיבי-קבצים---⚠️-חשוב-מאוד-file-paths)

---

## 📋 Code Review Checklist (5 דקות)

### Provider
- [ ] Repository (לא Firestore ישירות)?
- [ ] Error handling + Logging?
- [ ] Getters: items, isLoading, hasError, isEmpty?
- [ ] UserContext Integration?
- [ ] dispose()?

### Screen
- [ ] SafeArea + SingleChildScrollView?
- [ ] 3-4 Empty States (Loading/Error/Empty/Initial)?
- [ ] i18n (AppStrings)?
- [ ] Padding symmetric (RTL)?
- [ ] Skeleton במקום CircularProgressIndicator?
- [ ] Animations (buttons/lists/cards)?

### Model
- [ ] @JsonSerializable()?
- [ ] final fields?
- [ ] copyWith()?
- [ ] *.g.dart קיים?

### Repository
- [ ] Interface + Implementation?
- [ ] household_id filtering?
- [ ] Logging?

---

## 🎓 סיכום 20 עקרונות הזהב

1. ✅ בדוק Dead Code 5-Step (כולל import יחסי!)
2. ✅ Dormant Code = 4 שאלות
3. ✅ Constants ממרכז (lib/core/ + lib/config/)
4. ✅ 3-4 Empty States
5. ✅ UserContext + Listeners
6. ✅ Repository Pattern
7. ✅ i18n (AppStrings)
8. ✅ withValues (לא withOpacity!)
9. ✅ Async עטוף בlambda
10. ✅ Context Management (שמור לפני await)
11. ✅ household_id בכל Firestore query ⛔
12. ✅ Batch Processing (100+ items, Firestore: 500 max)
13. ✅ Skeleton Screens
14. ✅ Micro Animations (AnimatedButton, TappableCard)
15. ✅ Sticky Notes Design ⭐
16. ✅ Error Recovery (retry + clearAll)
17. ✅ Loading States Pattern
18. ✅ Race Condition Prevention (_isSigningUp flag)
19. ✅ mounted בדיקה אחרי await
20. ✅ **File Paths מלא: C:\projects\salsheli\...** ⭐

---

## 🆘 עדיין לא מצאת?

| זקוק ל- | קובץ |
|---------|------|
| 📚 הסבר עמוק | [LESSONS_LEARNED.md](LESSONS_LEARNED.md) |
| 🎨 עיצוב Sticky Notes | [STICKY_NOTES_DESIGN.md](STICKY_NOTES_DESIGN.md) |
| 💻 Best Practices | [BEST_PRACTICES.md](BEST_PRACTICES.md) |
| 🤖 הוראות AI מלאות | [AI_DEV_GUIDELINES.md](AI_DEV_GUIDELINES.md) |

---

## 🧪 Testing Quick Reference (חדש!)

### Provider Disposal Safety
```dart
// ✅ נכון - Disposal safe
class MyProvider extends ChangeNotifier {
  bool _isDisposed = false;
  
  void someMethod() {
    if (_isDisposed) return;  // Guard
    // ... do work
    if (!_isDisposed) {
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
```

### Race Condition Prevention
```dart
class UserContext extends ChangeNotifier {
  bool _isSigningUp = false;  // Prevent race during signup
  
  Future<void> signUp(...) async {
    _isSigningUp = true;
    try {
      // ... signup logic
    } finally {
      _isSigningUp = false;
    }
  }
  
  void _onAuthStateChange(User? user) {
    if (_isSigningUp) return;  // Skip during signup
    // ... handle auth change
  }
}
```

### Test Setup Pattern
```dart
// ✅ Setup with SharedPreferences mock
setUp(() {
  SharedPreferences.setMockInitialValues({
    'themeMode': ThemeMode.system.index,
    'compactView': false,
    'showPrices': true,
  });
  
  userContext = UserContext(...);
});

// ✅ Test disposal with separate instance
test('disposal safety', () async {
  final testContext = UserContext(...);  // Separate instance
  await Future.delayed(Duration(milliseconds: 100));  // Wait for init
  
  testContext.dispose();
  testContext.someMethod();  // Should be safe
});
```

### Quick Fixes מהניסיון

| בעיה | פתרון |
|------|-------|
| **Provider crashes after dispose** | → `_isDisposed` flag + check before notify |
| **Race condition בsignup** | → `_isSigningUp` flag |
| **Test double dispose** | → Use separate instance for disposal tests |
| **SharedPreferences in tests** | → `setMockInitialValues` in setUp |
| **Theme rapid changes** | → Async `_savePreferences()` |

---

**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻  
**Version:** 1.1 | **Last Updated:** 16/10/2025
