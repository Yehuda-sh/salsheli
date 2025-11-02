# 🧾 CODE REVIEW CHECKLIST – MemoZap

**גרסה:** 2.5 | **עודכן:** 02/11/2025  
**שימוש:** סריקה אוטומטית לכל קובץ חדש/מעודכן  
**מטרה:** זיהוי חכם של בעיות, קוד ישן, ופיצ'רים חלקיים

---

## 🧠 תהליך סקירה חכם

### לפני הסקירה:
1. **זיהוי תלויות** - האם צריך קבצים נוספים? (Repository, Model, Provider)
2. **בקש מהמשתמש** - רק תלויות קריטיות
3. **המתן לקבלת כל התלויות** - אחרת הסקירה חלקית

### במהלך הסקירה:
- ✅ **תקין** - עובד כמצופה
- ⚠️ **בעיה** - דורש תיקון
- 💀 **קוד ישן** - למחיקה (+ הסבר למה)
- 🔧 **הצעה** - שיפור מומלץ
- 🧠 **תובנה** - insight חשוב
- ❓ **לא ברור** - צריך הבהרה

### סגנון תשובה:
- **עברית בלבד** (ללא קוד בתשובה)
- **קצר וממוקד** - רק הנקודות החשובות
- **פורמט אחיד** - ראה דוגמה בסוף

---

## 🚨 CRITICAL CHECKS (ראשון!)

### 🔒 אבטחה
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **household_id בכל query** | 💀 CRITICAL | כל `.collection()` חייב `.where('household_id', ...)` |
| **Firebase Rules מיושמים** | 💀 CRITICAL | בדוק שיש 4 רמות גישה (owner/admin/editor/viewer) |
| **לא חושף מידע רגיש** | 🔴 HIGH | אין passwords/tokens/personal data בלוגים |

**Details:** → TECH.md (Security Rules section)

---

### 🧹 Provider Cleanup (Memory Leaks!)
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **removeListener() ב-dispose** | 💀 CRITICAL | כל `addListener` צריך `removeListener` |
| **Controllers disposed** | 🔴 HIGH | TextController, AnimationController, ScrollController |
| **Timers canceled** | 🔴 HIGH | `_timer?.cancel()` ב-dispose |
| **Streams canceled** | 🔴 HIGH | `_subscription?.cancel()` ב-dispose |
| **Platform resources closed** | 🟡 MEDIUM | ML Kit, ImageLabeler וכו' |

**Details:** → CODE.md (Provider Cleanup section)

---

### ⚡ Performance Critical
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **const על widgets סטטיים** | 🔴 HIGH | SizedBox, EdgeInsets, Text, Icon עם literals |
| **Lazy loading ל-Providers כבדים** | 🟡 MEDIUM | `ensureInitialized()` במקום constructor |
| **Unmodifiable getters** | 🟡 MEDIUM | `List.unmodifiable(_items)` |

**Details:** → CODE.md (const Usage section)

---

### 💥 Context After Await (Common Crash!)
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **Context captured לפני await** | 💀 CRITICAL | Navigator/ScaffoldMessenger לפני async |
| **`if (!mounted) return;` אחרי await** | 💀 CRITICAL | בדיקה שה-widget עדיין חי |

**Details:** → CODE.md (Common Mistakes - Context After Await)

---

## 🔧 Component Reuse & Tools

### 🎨 Component Decision Tree
| מצב | פתרון | הסבר |
|-----|--------|------|
| **כפתור רגיל** | StickyButton | ✅ תמיד! (לא ElevatedButton) |
| **כרטיס ללחיצה** | SimpleTappableCard | Scale animation + haptic |
| **צ'קבוקס/toggle** | AnimatedButton | Wrapper + haptic |
| **Loading state** | SkeletonLoading | במקום CircularProgressIndicator |
| **כרטיס סטטיסטיקה** | DashboardCard | Dashboard screens |
| **כרטיס יתרון** | BenefitTile | Onboarding/features |

**מיקום:** `lib/widgets/common/`

**דוגמאות מהפרויקט (Session 49):**
```yaml
settings_screen.dart:
  לפני: GestureDetector + AnimatedScale (15 שורות)
  אחרי: SimpleTappableCard (wrapper)
  
populate_list_screen.dart:
  לפני: InkWell (manual ripple)
  אחרי: SimpleTappableCard
  
shopping_list_details_screen.dart:
  לפני: GestureDetector על checkbox
  אחרי: AnimatedButton
```

**Decision Protocol:**
1. ✅ בדוק `widgets/common/` לפני יצירת אנימציה ידנית
2. ✅ StickyButton תמיד לכפתורים (לא Elevated/Text)
3. ✅ SimpleTappableCard לכרטיסים אינטראקטיביים
4. ✅ AnimatedButton לאלמנטים קטנים (checkbox, toggle)
5. ❌ אל תיצור GestureDetector + AnimatedScale ידנית

**Details:** → DESIGN.md (Advanced Components section)

---

### ⚠️ bash_tool Warning (CRITICAL!)
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **NEVER bash_tool + Windows paths** | 💀 CRITICAL | bash_tool = Linux shell (/bin/sh) |
| **Error pattern** | ALWAYS FAILS | "can't cd to C:projects..." |
| **Correct tools** | MANDATORY | Filesystem:search_files / read_file |

**למה זה שגיאה #1:**
- 🔥 Frequency: VERY HIGH (חוזר כל הזמן!)
- 💥 Impact: Wastes tool calls, breaks workflow
- 🚫 bash_tool = Linux shell, לא מבין C:\

**דוגמאות:**
```yaml
❌ WRONG:
bash_tool("cd C:\\projects\\salsheli && findstr ...")
→ Error: /bin/sh: cd: can't cd to C:projects

✅ CORRECT:
search_files("C:\\projects\\salsheli\\lib", "pattern")
read_file("C:\\projects\\salsheli\\lib\\file.dart")
```

**Details:** → PROJECT_INSTRUCTIONS v4.9 (LEARNING FROM MISTAKES - error_9)

---

### 📦 YAGNI Principle
| Pattern | Priority | הסבר |
|---------|----------|------|
| **Over-planning systems** | 🔴 HIGH | אל תיצור קובץ גדול לפני צורך |
| **Trigger rule** | 3+ TIMES | רק כשפטרן חוזר 3 פעמים |
| **Examples** | COSTLY | ui_constants (600), constants (430) |

**What happened:**
- Session 40: ui_constants.dart - 600 lines unused config
- Session 41: constants.dart - 430 lines comprehensive system
- Total: 1030+ lines dead code from over-planning

**Rule:**
```yaml
IF pattern appears 1 time:
  → Write inline (no extraction)

IF pattern appears 2 times:
  → Consider extraction (maybe)

IF pattern appears 3+ times:
  → Extract to shared constant/config
```

**Prevent:**
- ❌ Creating "perfect system" upfront
- ❌ 500+ line config files before features
- ❌ Comprehensive constants "for future use"

**Details:** → PROJECT_INSTRUCTIONS v4.9 (error_7)

---

### 🔍 Undefined Identifiers
| Issue | Priority | הסבר |
|-------|----------|------|
| **Using constants before verify** | 🟡 MEDIUM | Check existence first |
| **Pattern** | COMPILATION ERROR | Assume constant exists |
| **Fix** | CHECK FIRST | Read constants file |

**Example (Session 45):**
```yaml
File: main_navigation_screen.dart
Error: kDoubleTapTimeout undefined
       kSnackBarBottomMargin undefined
       kBorderRadiusSmall undefined

Cause: Used constants without checking ui_constants.dart

Fix: Added 4 missing constants to ui_constants.dart
```

**Protocol:**
1. Check constants file BEFORE using new constant
2. If missing → add it
3. If exists → use it
4. Never assume "it's probably there"

**Details:** → PROJECT_INSTRUCTIONS v4.9 (error_12)

---

### 🚫 Broken Tools
| Tool | Status | הסבר |
|------|--------|------|
| **Filesystem:create_file** | ❌ BROKEN | Always fails |
| **Replacement** | write_file | Use this instead |
| **Impact** | LOW | Wastes 1 tool call |

**Why it fails:**
- Tool exists in function list
- Implementation is broken
- Returns: "Tool not found" error

**Solution:**
```yaml
❌ create_file(path, content) # FAILS
✅ write_file(path, content)  # WORKS
```

**Confirmed:** Session 47

**Details:** → PROJECT_INSTRUCTIONS v4.7

---

### 🔗 Component Import Checks
| Check | Priority | הסבר |
|-------|----------|------|
| **widgets/common/ imports** | 🟡 MEDIUM | Shared components import each other |
| **Example pattern** | FALSE POSITIVE | sticky_button imports animated_button |
| **Search strategy** | BOTH | Filename AND classname |

**Why this matters (Session 49):**
```yaml
File: animated_button.dart (98 lines)
Claim: search_files('AnimatedButton') = 0 results
Reality: Used by sticky_button.dart (line 36, 116)

PowerShell found: 11 matches across project

Pattern missed:
  - search_files only searched filename
  - Missed class name usage
  - Missed component imports

Result: Almost deleted core animation wrapper!
```

**Protocol for shared components:**
1. Search filename: `animated_button`
2. Search class name: `AnimatedButton`
3. Check `widgets/common/` files specifically
4. Use PowerShell for definitive proof

**This was False Positive #5!**

---

## 📁 ארגון ומבנה

### תיקיות ושמות
| בדיקה | הסבר |
|-------|------|
| 📂 **מיקום תקין** | screens/providers/models/services/widgets/utils |
| 🏷️ **שם קובץ snake_case** | `shopping_list_provider.dart` |
| 🪞 **שם מחלקה = שם קובץ** | `ShoppingListProvider` ב-`shopping_list_provider.dart` |
| 📦 **Package imports** | `package:memozap/...` (NOT `../...`) |
| 🧩 **קבצים כפולים?** | אותו תפקיד בשני קבצים |

---

### Imports
| בדיקה | הסבר |
|-------|------|
| 🚫 **אין imports מיותרים** | unused imports |
| 📦 **Package imports בלבד** | `package:memozap/` (לא `../`) |
| 🎯 **סדר נכון** | Dart → Flutter → Packages → Project |

---

## 🔄 State Management

### Provider Pattern
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **notifyListeners() אחרי שינוי** | 🔴 HIGH | תמיד אחרי `_items.add()` וכו' |
| **Getters מוגנים** | 🟡 MEDIUM | `List.unmodifiable()` |
| **Try-catch על async** | 🔴 HIGH | כל async operation |
| **Loading/Error states** | 🟡 MEDIUM | `_isLoading`, `_errorMessage` |

---

### Lazy Loading Pattern
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **אין טעינה ב-constructor** | 🟡 MEDIUM | רק אם Provider כבד |
| **`ensureInitialized()`** | 🟡 MEDIUM | טעינה רק כשנדרש |
| **`_isInitialized` flag** | 🟡 MEDIUM | מונע טעינה כפולה |

**Details:** → CODE.md (Lazy Provider Pattern section)

---

## 🎨 UI/UX (Sticky Notes Design)

### חובה
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **NotebookBackground עם Stack** | 🔴 HIGH | לא child property! |
| **StickyButton** | 🔴 HIGH | לא ElevatedButton/TextButton |
| **RTL + Directionality** | 🔴 HIGH | כל טקסט עברי |
| **EdgeInsetsDirectional** | 🟡 MEDIUM | לא EdgeInsets.only(left:) |
| **AppStrings בלבד** | 🔴 HIGH | אין hardcoded strings |

**Details:** → DESIGN.md (NotebookBackground section)

---

### 4 מצבי UI (חובה!)
| מצב | Priority | הסבר |
|-----|----------|------|
| **Loading** | 🔴 HIGH | CircularProgressIndicator + טקסט |
| **Error** | 🔴 HIGH | Icon + Message + Retry button |
| **Empty** | 🔴 HIGH | Icon + Message + CTA |
| **Content** | 🔴 HIGH | הנתונים עצמם |

---

### Dark Mode
| בדיקה | הסבר |
|-------|------|
| ✅ **Sticky colors קבועים** | kStickyCyan וכו' לא משתנים |
| ✅ **Text adaptive** | `Theme.of(context).textTheme.bodyLarge?.color` |

---

## 🧪 Testing

### Widget Testing
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **bySemanticsLabel** | 🔴 HIGH | לא byWidgetPredicate! |
| **4 states tested** | 🟡 MEDIUM | Loading/Error/Empty/Content |
| **Mock stubs complete** | 🟡 MEDIUM | כל property צריך stub |

**Details:** → CODE.md (Testing Patterns - Widget Finders)

---

## 📊 Logging

### כללים
| בדיקה | Priority | הסבר |
|-------|----------|------|
| **מקסימום 15 debugPrint** | 🟡 MEDIUM | לקובץ |
| **Emoji prefix** | ⚪ LOW | ✅/⚠️/❌ |
| **[Component] suffix** | ⚪ LOW | [TasksProvider] |

**מה לשמור:**
- ✅ Lifecycle (initState, dispose)
- ✅ Errors (catch blocks)
- ✅ Critical actions (logout, delete)

**מה למחוק:**
- ❌ Function start/end
- ❌ Routine CRUD
- ❌ UI button presses

---

## 📝 Outdated Documentation

### פרוטוקול תיקון תיעוד מיושן
| שלב | Priority | הסבר |
|------|----------|------|
| **זיהוי הבעיה** | 💀 CRITICAL | היפוך לקובץ שלא קיים / פיצ'ר שהוסר |
| **read_file מלא** | 💀 CRITICAL | אסור קריאה חלקית! קרא את כל הקובץ |
| **זיהוי כל המופעים** | 💀 CRITICAL | רשום את כל המקומות שצריך לתקן |
| **תיקון מלא** | 💀 CRITICAL | תקן הכל בקריאה אחת של edit_file |

**דוגמה:**
```yaml
מצאתי: "add_receipt_dialog.dart" בשורה 27
צעד 1: read_file מלא (לא חלקי!)
צעד 2: מצאתי עוד היפוך בשורה 95
צעד 3: רשימה = [שורה 27, שורה 95]
צעד 4: edit_file עם 2 תיקונים
```

**אסור בהחלט:**
- ❌ תיקון חלקי (רק מקום אחד)
- ❌ read_file חלקי (view_range)
- ❌ אי בדיקה של מופעים נוספים

**למה זה קריטי:**
- תיקון חלקי = המשתמש תופס = איבוד אמון
- תיעוד לא מעודכן = בלבול עתידי
- המשתמש לא אמור לתפוס טעויות שלנו

---

## 💀 Dead Code Detection

### ⚠️ CRITICAL: False-Positive Prevention

**הבעיה:** `search_files` לא מוצא 3 סוגי שימוש:

1. **שימוש בתוך הקובץ עצמו** (in-file usage)
2. **שימוש דרך קונסטנטות** (`kMinFamilySize`, `kValidChildrenAges`)
3. **שימוש דרך מחלקות סטטיות** (`StoresConfig.isValid`, `FirestoreFields.userId`)

**דוגמה 1 - in-file usage (session 42):**
```yaml
קובץ: app_strings.dart
טעות: "0 imports = dead code"
מציאות: 10+ קבצים משתמשים
סיבה: AppStrings.layout.appTitle - שימוש פנימי בתוך הקובץ
```

**דוגמה 2 - constants usage (session 43):**
```yaml
קובץ: constants.dart
טעות: "0 imports = dead code"
מציאות: onboarding_data.dart משתמש
סיבה: kMinFamilySize, kMaxFamilySize, kValidChildrenAges
שימוש: if (size < kMinFamilySize)
```

**דוגמה 3 - static class usage (session 43):**
```yaml
קובץ: stores_config.dart
טעות: "0 imports = dead code"
מציאות: onboarding_data.dart משתמש
סיבה: StoresConfig.isValid
שימוש: stores.where(StoresConfig.isValid)
```

**פרוטוקול נכון (6 שלבים חובה!):**

| שלב | Priority | מה לעשות |
|------|----------|----------|
| **1. search_files** | 💀 CRITICAL | חפש imports בכל הפרויקט |
| **2. read_file מלא** | 💀 CRITICAL | קרא את הקובץ כולו (לא חלקי!) |
| **3. in-file usage** | 💀 CRITICAL | חפש שימוש בתוך הקובץ עצמו |
| **4. constants usage** | 💀 CRITICAL | חפש `k[ClassName]` patterns בפרויקט |
| **5. static usage** | 💀 CRITICAL | חפש `ClassName.method` patterns |
| **6. אישור סופי** | 💀 CRITICAL | רק אחרי 5 בדיקות שליליות |

**דוגמה לבדיקה מלאה:**
```yaml
# שלב 1: search_files
מצא: 0 imports ל-constants.dart

# שלב 2: read_file מלא
קרא: כל 40 שורות
מצא: kMinFamilySize = 1, kMaxFamilySize = 10, kValidChildrenAges

# שלב 3: in-file usage
לא מצא שימוש פנימי

# שלב 4: constants usage (קריטי!)
חיפוש: search_files("kMinFamilySize")
מצא: onboarding_data.dart שורה 129
חיפוש: search_files("kValidChildrenAges")
מצא: onboarding_data.dart שורה 165
→ קובץ פעיל!

# שלב 5: (דילוג - אין מחלקות)

# שלב 6: אישור
תוצאה: NOT dead code (משמש דרך קונסטנטות)
```

**אסור בהחלט:**
- ❌ טענת "dead code" רק לפי search_files
- ❌ אי קריאת הקובץ המלא
- ❌ אי בדיקת שימוש פנימי
- ❌ אי חיפוש קונסטנטות (`kXxx`)
- ❌ אי חיפוש מחלקות סטטיות (`ClassName.method`)
- ❌ מחיקה מהירה בלי 6 השלבים

**למה זה קריטי:**
- 💥 מחיקת קוד פעיל = איבוד אמון מוחלט
- 🔥 compilation errors בכל הפרויקט
- ⏰ בזבוז זמן בשחזור קוד
- 😤 תסכול משתמש ("למה מחקת?!")
- 📉 4 קבצים פעילים כמעט נמחקו (sessions 40-43, 48-49)

**חוק ברזל: כשיש ספק - אל תמחק!**

**מקרי False-Positive שאירעו:**
| Session | קובץ | מה חיפשנו | מה פספסנו |
|---------|------|-----------|----------|
| 40 | ui_constants.dart | imports | ✅ Dead code נכון |
| 41 | constants.dart | imports | ❌ kMinFamilySize ב-onboarding |
| 43 | stores_config.dart | imports | ❌ StoresConfig.isValid ב-onboarding |
| 48 | storage_location_manager.dart | imports | ❌ StorageLocationManager ב-my_pantry_screen |
| 49 | animated_button.dart | imports | ❌ AnimatedButton ב-sticky_button (98 שורות) |

---

### 🔍 שלב 7: בקש אימות PowerShell מהמשתמש (חובה!)

**💀 CRITICAL: תמיד שלח פקודת PowerShell למשתמש לפני קביעת dead code!**

**מתי חובה להשתמש:**
- **תמיד** כש-search_files מחזיר 0 תוצאות
- **תמיד** לפני הצהרה על dead code
- **תמיד** כשיש ספק אם קובץ בשימוש

**הפרוטוקול:**

```yaml
שלב 7.1: הכן פקודת PowerShell
  תבנית:
    Get-ChildItem -Path "C:\projects\salsheli\lib" -Recurse -Filter "*.dart" | Select-String "[FILE_NAME]|[CLASS_NAME]" | Select-Object Path, LineNumber, Line
  
  דוגמה:
    Get-ChildItem -Path "C:\projects\salsheli\lib" -Recurse -Filter "*.dart" | Select-String "storage_location_manager|StorageLocationManager" | Select-Object Path, LineNumber, Line

שלב 7.2: בקש מהמשתמש (חובה!)
  טקסט:
    "לפני שאני קובע אם זה dead code, אנא הרץ את הפקודה הבאה ב-PowerShell והדבק את התוצאה:
    
    [הפקודה כאן]
    
    זה יוודא בדיוק איפה הקובץ משמש (5 false positives קרו בעבר!)."

שלב 7.3: נתח תוצאה
  אם יש תוצאות:
    ✅ הקובץ בשימוש! בדוק את הנתיבים
  אם אין תוצאות:
    ⚠️ ספק נוסף - בדוק class name בנפרד
  אם גם class name מחזיר 0:
    💀 ככל הנראה dead code (אבל עדיין - כשיש ספק אל תמחק!)
```

**למה זה עובד טוב יותר מ-MCP search_files:**
1. ✅ PowerShell מחפש גם בתוך שורות (לא רק שמות קבצים)
2. ✅ מציג LineNumber + Line המלא
3. ✅ תומך בחיפוש מרובה (file|class name)
4. ✅ יותר מהימן למציאת שימוש אמיתי

**דוגמה מהפרקטיקה (Session 48):**

```yaml
מצב התחלתי:
  קובץ: storage_location_manager.dart (990 שורות)
  search_files: 0 imports נמצאו
  מסקנה מוטעית: "קובץ לא בשימוש"

פקודת PowerShell:
  Get-ChildItem -Path "C:\projects\salsheli\lib" -Recurse -Filter "*.dart" | Select-String "StorageLocationManager" | Select-Object Path, LineNumber, Line

תוצאה:
  my_pantry_screen.dart:17 - תיעוד
  my_pantry_screen.dart:754 - StorageLocationManager(inventory: items, onEditItem: _editItemDialog)
  → קובץ בשימוש פעיל!

למידה:
  search_files חיפש רק "storage_location_manager" (שם קובץ)
  PowerShell חיפש גם "StorageLocationManager" (שם class)
  → הבדל קריטי שהציל 990 שורות קוד פעיל!
```

**טיפים לחיפוש יעיל:**

```powershell
# 1️⃣ חיפוש שם קובץ + שם class
Get-ChildItem -Path "C:\projects\salsheli\lib" -Recurse -Filter "*.dart" | Select-String "my_file|MyClassName" | Select-Object Path, LineNumber, Line

# 2️⃣ ספירת מופעים
Get-ChildItem -Path "C:\projects\salsheli\lib" -Recurse -Filter "*.dart" | Select-String "MyClassName" | Measure-Object | Select-Object Count

# 3️⃣ חיפוש בתיקיית screens בלבד
Get-ChildItem -Path "C:\projects\salsheli\lib\screens" -Recurse -Filter "*.dart" | Select-String "MyWidget"

# 4️⃣ חיפוש imports ישירות
Get-ChildItem -Path "C:\projects\salsheli\lib" -Recurse -Filter "*.dart" | Select-String "import.*my_file.dart" | Select-Object Path, LineNumber
```

**מתי אפשר לדלג על שלב 7:**
- **רק** אם כבר יש 3+ מופעים ב-search_files (בטוח בשימוש)
- **אחרת - תמיד שלח פקודה למשתמש!**
- זכור: 5 false positives קרו כי דילגנו על שלב זה

---

### סימנים לקוד ישן
| סימן | הסבר אנושי נדרש |
|------|----------------|
| **פונקציה לא נקראת** | הסבר: למה נוצרה ומה החליף אותה |
| **Import לא בשימוש** | מתי היה בשימוש |
| **TODO/FIXME ישנים** | סטטוס עדכני |
| **printDebug/console.log** | למה היה צריך |

**פורמט תיעוד:**
```markdown
💀 `getTasks()` - שלפה ישירות מ-DB לפני המעבר ל-Repository. 
   כיום משתמשים ב-`TasksRepository.getTasks()`.
```

---

## 🧠 Top 5 שגיאות נפוצות

עדיפות לבדיקה לפי תדירות:

1. 💀 **household_id חסר** → SECURITY BREACH
2. 💀 **removeListener חסר** → MEMORY LEAK  
3. 💀 **context after await** → CRASH
4. 🔴 **const חסר** → 5-10% rebuilds
5. 🔴 **edit_file without read** → NO MATCH

---

## 💬 פורמט תשובה

```
📄 קובץ: lib/providers/tasks_provider.dart
סטטוס: ⚠️ בעיות בינוניות
סיכום: Provider תקין לוגית אך יש 2 בעיות קריטיות

🚨 CRITICAL:
⚠️ חסר removeListener ב-dispose → memory leak
⚠️ context משמש אחרי await → potential crash

⚡ PERFORMANCE:
⚠️ 8 מקומות חסר const → rebuilds מיותרים

💀 DEAD CODE:
💀 getTasks() - שלפה ישירות מ-DB לפני Repository.
   כיום: TasksRepository.getTasks()

🔧 צעדים:
1. הוסף dispose מלא (removeListener)
2. capture context לפני await
3. הוסף const ב-8 מקומות
4. מחק getTasks()
```

---

## 📋 Checklist מהיר

לפני Commit:
- [ ] household_id בכל query
- [ ] dispose מלא (listeners/timers/streams)
- [ ] context captured לפני await
- [ ] const על widgets סטטיים
- [ ] package imports (לא relative)
- [ ] bySemanticsLabel בטסטים
- [ ] 4 UI states קיימים
- [ ] מקסימום 15 debugPrint
- [ ] NotebookBackground עם Stack
- [ ] StickyButton (לא Elevated)

---

**🎯 זכור:** הסקירה צריכה להיות **חכמה** (לא מכנית), **קצרה** (ממוקד), ו**אנושית** (הסבר למה, לא רק מה).

**End of Checklist v2.5**

**עדכונים מ-v2.4:**
- 🆕 סעיף חדש: Component Reuse & Tools (6 תתי-סעיפים)
- 🔴 bash_tool Warning: שגיאה #1 הנפוצה ביותר!
- 📦 YAGNI Principle: 1030+ שורות dead code נמנעו
- 🔍 Undefined Identifiers: בדיקת constants לפני שימוש
- 🚫 Broken Tools: create_file לא עובד, השתמש ב-write_file
- 🔗 Component Import Checks: shared components מייבאים זה את זה
- 📊 Impact: מונע 3 סוגי שגיאות נפוצות (bash_tool, over-planning, false positives)

**עדכונים מ-v2.3:**
- 🆕 False Positive #5: animated_button.dart (session 49, 98 lines saved)
- 📊 טבלת False-Positives: 4→5 מקרים
- 📈 סה"כ קוד שניצל: 98+990+430+... = 2000+ שורות

**עדכונים מ-v2.2:**
- 🆕 שלב 7: בקשת אימות PowerShell מהמשתמש (המלצה!)
- 🆕 דוגמה מעשית: storage_location_manager.dart (session 48)
- 🆕 4 פקודות PowerShell יעילות לחיפוש
- 🆕 הסבר מתי לדלג על שלב 7
- 📊 טבלת False-Positives: 3→4 מקרים

**עדכונים מ-v2.1:**
- הרחבת פרוטוקול Dead Code: 4→6 שלבים
- הוספת בדיקות: constants usage + static class usage
- 3 דוגמאות מסשנים 42-43
- טבלת False-Positives
