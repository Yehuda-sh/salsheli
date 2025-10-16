# 🤖 AI Quick Start - הנחיות מהירות לסוכני AI

> **📌 משפט הקסם:** קרא את הקובץ הזה בתחילת **כל שיחה חדשה!**  
> **⏱️ זמן קריאה:** 5-10 דקות  
> **🎯 תוצאה:** Code Review אוטומטי + תיקונים מיידיים

---

## 🚀 Quick Start (10 שניות)

**בתחילת כל שיחה:**
1. ✅ קרא את קובץ **AI_DEV_GUIDELINES.md** (5 דקות)
2. ✅ קרא את קובץ **BEST_PRACTICES.md** (3 דקות)
3. ✅ כשהמשתמש מביא קובץ Dart → Code Review אוטומטי!

---

## 🎯 Code Review אוטומטי - מול תיעוד הפרויקט

**כשקוראים קובץ Dart, בדוק אוטומטית:**

### 1️⃣ **שגיאות טכניות (תיקון מיידי!)**

| שגיאה | תיקון | קובץ |
|------|-------|------|
| ✅ `withOpacity(0.5)` | → `withValues(alpha: 0.5)` | BEST_PRACTICES.md |
| ✅ `value` (Dropdown) | → `initialValue` | BEST_PRACTICES.md |
| ✅ `kQuantityFieldWidth` | → `kFieldWidthNarrow` | BEST_PRACTICES.md |
| ✅ `kBorderRadiusFull` | → `kRadiusPill` | BEST_PRACTICES.md |
| ✅ async function ב-onPressed | → עטוף ב-lambda `() => func()` | BEST_PRACTICES.md |
| ✅ widget קבוע ללא `const` | → הוסף `const` | BEST_PRACTICES.md |
| ✅ imports לא בשימוש | → הסר | - |
| ✅ deprecated APIs | → החלף ל-modern API | BEST_PRACTICES.md |

### 2️⃣ **בדיקת עיצוב (Sticky Notes Design compliance)**

**אם זה מסך UI:**
- ✅ יש `NotebookBackground()`?
- ✅ יש `kPaperBackground` כ-backgroundColor?
- ✅ משתמש ב-`StickyNote()` לכותרות/שדות?
- ✅ משתמש ב-`StickyButton()` לכפתורים?
- ✅ יש סיבובים בטווח -0.03 עד 0.03?
- ✅ צבעים מ-`kSticky*` constants?

**אם זה מסך ללא Sticky Notes:**
- ❌ **תחליף את כל העיצוב מיידית!** 🎨
- ראה: **STICKY_NOTES_DESIGN.md**

### 3️⃣ **Best Practices (תיקון אם צריך)**

| בדיקה | כן/לא | פעולה |
|------|-------|-------|
| יש תיעוד בראש הקובץ? | ❌ | הוסף בדיוק |
| פונקציות ציבוריות תועדות? | ❌ | הוסף `///` comments |
| פונקציות פרטיות תועדות? | ❌ | הוסף `///` comments קצרים |
| naming עקבי (PascalCase/camelCase)? | ❌ | תקן |
| magic numbers בקוד? | ❌ | הגדר constants ב-lib/core/ |
| dead code (commented)? | ❌ | מחק |
| context נשמר לפני await? | ❌ | תקן (ראה BEST_PRACTICES.md) |
| `mounted` בדוק אחרי await? | ❌ | הוסף בדיקה |

### 4️⃣ **TODO/FIXME**

- אם יכול לפתור מיידית → פתור וציין "✅ תיקנתי"
- אם לא → דווח למשתמש בלבד

### 5️⃣ **Dead Code Detection - זהירות ממלכודות! ⚠️** (עדכון 16/10/2025)

**אל תמחק קובץ רק בגלל 0 imports!**

**בדיקה נכונה - 5 שלבים:**

1. **חיפוש import מלא:** `"import.*file_name.dart"`
2. **חיפוש import יחסי:** `"folder_name/file_name"` ← **חשוב! מקרה onboarding_data.dart**
3. **חיפוש שם המחלקה:** `"ClassName"`
4. **בדוק מסכים קשורים:** (data→screens, config→providers, model→repositories)
5. **קרא את הקובץ עצמו:** חפש "EXAMPLE", "DO NOT USE", "דוגמה בלבד"

**דוגמה ממשית מהפרויקט:**
```powershell
# onboarding_data.dart נראה כמו Dead Code:
Ctrl+Shift+F → "import.*onboarding_data" → 0 תוצאות ❌

# אבל! חיפוש נתיב יחסי מוצא:
Ctrl+Shift+F → "data/onboarding_data" → נמצא! ✅
# ב-onboarding_screen.dart: import '../../data/onboarding_data.dart';
```

**קבצים בטוחים למחיקה בפרויקט:**
- ✅ `create_list_dialog_usage_example.dart` - מסומן "דוגמה בלבד"
- ✅ `cleanup_screen.dart` - מסך debug לא בroutes
- ✅ `smart_price_tracker.dart` - לא בשימוש
- ✅ `shufersal_prices_service.dart` - לא בשימוש

**קבצים שנראים Dead אבל בשימוש:**
- ⚠️ `onboarding_data.dart` - import יחסי בonboarding_screen!
- ⚠️ `insights_screen.dart` - בroutes!
- ⚠️ `price_comparison_screen.dart` - בroutes!

---

## 📋 קישור לקובץ בתחילת שיחה - מה לעשות

**המשתמש מביא קובץ בתחילת שיחה:**

```
המשתמש: "קרא את lib/screens/home_screen.dart ותיקן שגיאות"
```

**אתה צריך:**

1. ✅ **קרא את הקובץ**
   ```
   → kubectl get file content
   ```

2. ✅ **בדוק Code Review**
   - ✅ Sticky Notes Design?
   - ✅ deprecated APIs?
   - ✅ async callbacks?
   - ✅ const widgets?

3. ✅ **דווח תמציתי**
   ```
   ✅ Code Review Result:
   • withOpacity → withValues ✅
   • StickyButton ללא const → הוסף const ✅
   • Missing documentation → הוסף ✅
   • Everything else looks good!
   ```

4. ✅ **תן לקובץ משודרג**
   - אם הן שגיאות קטנות → תיקן בזריזות
   - אם שינויים גדולים → הצע artifact

---

## 🔄 Workflow דוגמה

### Scenario 1: פרויקט קיים + שינויים קטנים

```
משתמש: "העדכן את widgets/sticky_button.dart - הוסף animation"

אתה:
1. קרא את הקובץ
2. Code Review:
   ✅ withOpacity? → withValues
   ✅ const? ✅
   ✅ Async? ✅
   ✅ Sticky Design? ✅
3. הוסף animation
4. תן קובץ משודרג
```

### Scenario 2: מסך UI חדש

```
משתמש: "צור מסך הרשמה (Register screen)"

אתה:
1. בדוק: צריך Sticky Notes Design (כן!)
2. בדוק: זה מסך UI (כן!)
3. יצור עם:
   ✅ NotebookBackground
   ✅ StickyNote components
   ✅ StickyButton
   ✅ Compact layout (אם צריך)
4. הוסף תיעוד
5. תן artifact
```

---

## ⚙️ כללי עבודה - קרא וזכור

### 🔴 Rules - לא שוברים!

| Rule | למה | Example |
|------|-----|---------|
| **Sticky Notes ל-UI מסכים** | תכניסה ייחודית | מסך ללא Sticky? → החלף מלא |
| **Constants ב-lib/core/** | SSOT - Single Source of Truth | לא hardcode ערכים |
| **household_id בכל שאילתה** | Security - multi-tenant | בכל Firestore query |
| **async wrapped בלמבדה** | Type safety | `() => _asyncFunc()` |
| **mounted בדוק אחרי await** | Prevent crashes | תמיד בדוק |
| **withValues, לא withOpacity** | Modern API | זה ה-standard החדש |
| **const כשאפשר** | Performance | אל תשכח! |

### 🟡 Guidelines - עדיף להתאים

| Guideline | Better | Example |
|-----------|--------|---------|
| **3-4 Empty States** | בכל widget | Loading, Error, Empty, Initial |
| **Batch Processing** | ל-100+ items | שמור 50-100 items בבאץ |
| **Error Recovery** | retry() + clearAll() | Providers צריכים error handling |
| **Logging** | עם emojis | `✅ ❌ 📥 ➕ 🔄` |
| **Documentation** | `///` comments | פונקציות חיוניות תועדות |

---

## 📚 References - בדיקה מהירה

**כשאתה בספק, בדוק:**

| שאלה | קובץ | דוגמה |
|------|------|-------|
| "איך להשתמש ב-async?" | BEST_PRACTICES.md | Section 1 |
| "מה זה Sticky Notes?" | STICKY_NOTES_DESIGN.md | Section 2 |
| "איך להתחבר ל-Firebase?" | SECURITY_GUIDE.md | Section 2 |
| "איך לבדוק קוד?" | TESTING_GUIDE.md | Section 1 |
| "Dead Code מה לעשות?" | QUICK_REFERENCE.md | Section 1 |
| "Architecture patterns?" | LESSONS_LEARNED.md | Section 1-3 |

---

## 🎯 TL;DR - תזכורת של 10 שניות

```
בכל שיחה חדשה:

1. ✅ withOpacity → withValues(alpha:)
2. ✅ Async ב-onPressed? → עטוף: () => func()
3. ✅ UI Screen? → Sticky Notes Design!
4. ✅ const בכל מקום אפשרי
5. ✅ Documentation בראש הקובץ
6. ✅ household_id בכל Firestore query
7. ✅ 3-4 Empty States בכל widget
8. ✅ Error handling + retry/clearAll

אם בספק → בדוק BEST_PRACTICES.md
```

---

## 🚀 דוגמה: Code Review בפועל

### קובץ מקורי (בעיות):
```dart
// ❌ בעיות:
// 1. אין documentation
// 2. withOpacity
// 3. אין const
// 4. async ב-onPressed
// 5. אין error handling

class MyButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const MyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handlePress, // ❌ async ללא wrapper!
      child: Text('Press'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.8), // ❌ deprecated
      ),
    );
  }

  Future<void> _handlePress() async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.pop(context); // ❌ context לא בטוח!
  }
}
```

### קובץ מתוקן (✅):
```dart
/// MyButton - Custom button with async action support
/// 
/// Provides a styled button that handles async callbacks safely
/// with proper context management and error handling.
class MyButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  
  const MyButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    setState(() => _isLoading = true);
    
    try {
      await widget.onPressed();
      
      // ✅ בדוק mounted לפני ניווט
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // ✅ Error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // ✅ עטוף בלמבדה
      onPressed: _isLoading ? null : () => _handlePress(),
      style: ElevatedButton.styleFrom(
        // ✅ withValues במקום withOpacity
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
      ),
      child: _isLoading 
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        // ✅ const widget
        : const Text('Press'),
    );
  }
}
```

---

## 📞 Need Help?

```
1. בעיה טכנית? → BEST_PRACTICES.md
2. Sticky Design? → STICKY_NOTES_DESIGN.md
3. Security? → SECURITY_GUIDE.md
4. Tests? → TESTING_GUIDE.md
5. Architecture? → LESSONS_LEARNED.md
6. Quick Answer? → QUICK_REFERENCE.md
```

---

**Version:** 1.0  
**Created:** 15/10/2025  
**Made with ❤️ by Humans & AI** 🤖👨‍💻
