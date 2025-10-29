# 🧾 CODE REVIEW CHECKLIST – MemoZap

**גרסה:** 2.1 | **עודכן:** 29/10/2025  
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

**הבעיה:** `search_files` לא מוצא שימוש **בתוך הקובץ עצמו** (in-file usage)

**דוגמה אמיתית (session 42):**
```yaml
קובץ: app_strings.dart
טעות: claimed "0 imports = dead code"
מציאות: 10+ קבצים משתמשים (app_layout, welcome_screen, login_screen...)
סיבה: AppStrings.layout.appTitle - שימוש פנימי בתוך app_strings.dart
```

**פרוטוקול נכון (4 שלבים חובה!):**

| שלב | Priority | מה לעשות |
|------|----------|----------|
| **1. search_files** | 💀 CRITICAL | חפש imports בכל הפרויקט |
| **2. read_file מלא** | 💀 CRITICAL | קרא את הקובץ כולו (לא חלקי!) |
| **3. בדיקה ידנית** | 💀 CRITICAL | חפש שימוש **בתוך הקובץ** |
| **4. אישור סופי** | 💀 CRITICAL | רק אם **גם** 0 imports **וגם** 0 in-file usage |

**דוגמה לבדיקה נכונה:**
```yaml
# שלב 1: search_files
מצא: 0 imports ל-app_strings.dart

# שלב 2: read_file מלא
קרא: כל 1100 שורות

# שלב 3: בדיקה ידנית
מצא: AppStrings.layout.appTitle בשורה 50
מצא: AppStrings.auth.loginButton בשורה 150
מצא: AppStrings.home.welcome בשורה 250
→ קובץ פעיל!

# שלב 4: אישור
תוצאה: NOT dead code (שימוש פנימי קיים)
```

**אסור בהחלט:**
- ❌ טענת "dead code" רק לפי search_files
- ❌ אי קריאת הקובץ המלא
- ❌ אי בדיקת שימוש פנימי
- ❌ מחיקה מהירה בלי אימות

**למה זה קריטי:**
- 💥 מחיקת קוד פעיל = איבוד אמון מוחלט
- 🔥 compilation errors בכל הפרויקט
- ⏰ בזבוז זמן בשחזור קוד
- 😤 תסכול משתמש ("למה מחקת?!")

**כשיש ספק - אל תמחק!**

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

🧠 תובנה:
בעיית dispose חוזרת ב-5 Providers → לעדכן LESSONS_LEARNED
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

**End of Checklist v2.0**
