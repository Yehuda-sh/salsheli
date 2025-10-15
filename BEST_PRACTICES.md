# 📚 Best Practices - סל שלי
## מדריך פיתוח ועיצוב

---

## 🎯 סקירה כללית

מסמך זה מרכז את כל ה-Best Practices והלקחים שנלמדו במהלך פיתוח האפליקציה.

**📌 למפתחים חדשים:** קרא את `LESSONS_LEARNED.md` לפני מסמך זה!  
**🤖 לסוכני AI:** קרא את `AI_QUICK_START.md` בתחילת כל שיחה!

---

## 📖 תוכן עניינים

- [🎨 עיצוב UI/UX](#-עיצוב-uiux)
- [💻 קוד וארכיטקטורה](#-קוד-וארכיטקטורה)
- [🎯 UX Best Practices](#-ux-best-practices)
- [📱 ביצועים ונגישות](#-ביצועים-ונגישות)
- [🧪 בדיקות ודיבאג](#-בדיקות-ודיבאג)
- [🤖 עבודה עם AI](#-עבודה-עם-ai)
- [📋 Code Review Checklist](#-code-review-checklist)
- [✅ Checklist למסך חדש](#-checklist-למסך-חדש)

---

## 🎨 עיצוב UI/UX

### 1. עיצוב מסכים Compact 📐

**מטרה:** להכניס מקסימום תוכן במסך אחד ללא גלילה, תוך שמירה על קריאות.

#### טבלת רווחים מומלצת

| מקום | רווח גדול | רווח compact | שימוש |
|------|-----------|--------------|--------|
| Padding מסך | 24px | 16px אופקי, 8px אנכי | padding כללי של המסך |
| בין אלמנטים קטנים | 8px | 4-6px | בין אייקון לטקסט |
| בין אלמנטים רגילים | 16px | 8px | בין שדות טקסט |
| בין סקציות | 24px | 12-16px | בין קבוצות תוכן |
| גובה כפתור | 48px | 44px | עדיין נגיש |
| טקסט כותרת | 28-32px | 24px | קריא ומצומצם |
| טקסט רגיל | 16px | 14px | body text |
| טקסט קטן | 14px | 11px | קישורים, הערות |

#### דוגמה מעשית

```dart
// ❌ גדול מדי:
SingleChildScrollView(
  padding: EdgeInsets.all(24),
  child: Column(
    children: [
      SizedBox(height: 32),
      BigLogo(size: 120),
      SizedBox(height: 32),
      TextField(),
      SizedBox(height: 24),
      // ... עוד אלמנטים
    ],
  ),
)

// ✅ מצומצם נכון:
SingleChildScrollView(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Column(
    children: [
      SizedBox(height: 8),
      Transform.scale(
        scale: 0.85,
        child: Logo(size: 120),
      ),
      SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      SizedBox(height: 8),
      // ... עוד אלמנטים
    ],
  ),
)
```

#### כלל אצבע 👍

- **צמצם ב-30-50%** מהרווחים המקוריים
- **אל תרד מתחת ל-44px** לכפתורים (נגישות)
- **אל תרד מתחת ל-11px** לטקסט (קריאות)
- **שמור על 16px** padding אופקי מינימלי (נוחות)

---

### 2. Sticky Notes Design System

**ראה:** `STICKY_NOTES_DESIGN.md` למדריך מלא

**עקרונות מרכזיים:**
- 🎨 3 צבעים מקסימום במסך
- 🔄 סיבובים קלים (-0.03 עד 0.03)
- 📱 תמיד עטוף ב-Stack עם NotebookBackground
- ♿ נגישות: 48px מינימום (או 44px compact)

---

## 💻 קוד וארכיטקטורה

### 1. עבודה עם Async Functions

**בעיה נפוצה:** העברת פונקציה אסינכרונית לכפתור שמצפה ל-`VoidCallback`.

```dart
// ❌ לא עובד - Type error:
StickyButton(
  onPressed: _handleLogin, // Future<void> Function()
  label: 'התחבר',
)

// ✅ פתרון 1 - עטיפה בלמבדה:
StickyButton(
  onPressed: () => _handleLogin(),
  label: 'התחבר',
)

// ✅ פתרון 2 - עם loading state:
StickyButton(
  onPressed: _isLoading ? () {} : () => _handleLogin(),
  label: _isLoading ? 'מתחבר...' : 'התחבר',
)

// ✅ פתרון 3 - פונקציה עוטפת:
void _onLoginPressed() {
  _handleLogin();
}

StickyButton(
  onPressed: _onLoginPressed,
  label: 'התחבר',
)
```

**כלל זהב:** אם הפונקציה מסומנת `async` או מחזירה `Future`, עטוף אותה בלמבדה.

---

### 2. שימוש נכון ב-withValues

**Flutter החדש (2024+):** `withOpacity` הוא deprecated.

```dart
// ❌ ישן (deprecated):
Colors.white.withOpacity(0.7)
Colors.black.withOpacity(0.2)

// ✅ חדש (מומלץ):
Colors.white.withValues(alpha: 0.7)
Colors.black.withValues(alpha: 0.2)

// ✅ אפשר גם לשנות ערכים אחרים:
Colors.red.withValues(
  alpha: 0.5,
  red: 0.8,
  green: 0.2,
)
```

**למה זה חשוב?**
- `withValues` שומר על דיוק מתמטי
- תואם לעתיד (withOpacity יוסר)
- תמיכה טובה יותר ב-color spaces שונים

**חיפוש והחלפה מהיר:**
```bash
# מצא את כל המקומות:
grep -r "withOpacity" lib/

# החלף אוטומטית (בזהירות!):
find lib/ -type f -name "*.dart" -exec sed -i 's/\.withOpacity(\([0-9.]*\))/.withValues(alpha: \1)/g' {} +
```

---

### 3. Deprecated APIs נוספים

#### 3.1 DropdownButtonFormField - value → initialValue

```dart
// ❌ ישן (deprecated):
DropdownButtonFormField<String>(
  value: selectedValue,
  items: [...],
)

// ✅ חדש (מומלץ):
DropdownButtonFormField<String>(
  initialValue: selectedValue,
  items: [...],
)
```

#### 3.2 UI Constants - שמות חדשים

```dart
// ❌ ישן:
kQuantityFieldWidth
kBorderRadiusFull

// ✅ חדש:
kFieldWidthNarrow
kRadiusPill

// דוגמה:
Container(
  width: kFieldWidthNarrow,  // במקום kQuantityFieldWidth
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(kRadiusPill),  // במקום kBorderRadiusFull
  ),
)
```

**🔍 חיפוש והחלפה:**
```bash
# מצא שימושים ישנים:
grep -r "kQuantityFieldWidth" lib/
grep -r "kBorderRadiusFull" lib/

# או ב-VS Code:
# Find: kQuantityFieldWidth → Replace: kFieldWidthNarrow
# Find: kBorderRadiusFull → Replace: kRadiusPill
```

---

### 4. Context Management בפונקציות אסינכרוניות

**בעיה:** אחרי `await`, ה-BuildContext עלול להיות לא valid.

```dart
// ❌ בעייתי:
Future<void> _handleLogin() async {
  await userContext.signIn(...);
  
  // ⚠️ Context עלול להיות לא valid כאן!
  Navigator.push(context, ...);
  ScaffoldMessenger.of(context).showSnackBar(...);
}

// ✅ פתרון 1 - שמירת references:
Future<void> _handleLogin() async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  
  await userContext.signIn(...);
  
  // בטוח - השתמשנו ב-references
  if (mounted) {
    navigator.push(...);
    messenger.showSnackBar(...);
  }
}

// ✅ פתרון 2 - בדיקת mounted לפני שימוש:
Future<void> _handleLogin() async {
  await userContext.signIn(...);
  
  if (!mounted) return;
  
  Navigator.push(context, ...);
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

**Best Practice:**
1. שמור את ה-context/navigator/messenger **לפני** await
2. תמיד בדוק `mounted` **אחרי** await
3. השתמש ב-references שנשמרו, לא ב-context ישירות

---

### 5. State Management עם Loading States

```dart
class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;
  
  Future<void> _handleAction() async {
    // ✅ הגדר loading בהתחלה
    setState(() => _isLoading = true);
    
    try {
      await someAsyncOperation();
      
      // ✅ בדוק mounted לפני ניווט
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.push(...);
      }
    } catch (e) {
      // ✅ בדוק mounted גם בשגיאה
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(...);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return StickyButton(
      // ✅ השתמש ב-loading state
      onPressed: _isLoading ? () {} : () => _handleAction(),
      label: _isLoading ? 'טוען...' : 'המשך',
    );
  }
}
```

**טיפים:**
- תמיד אתחל את `_isLoading` ב-`false`
- עדכן את ה-state בתחילת הפונקציה
- אל תשכח לבטל את ה-loading גם במקרה של שגיאה
- השתמש ב-ternary operator לכפתור disabled

---

### 6. Form Validation

```dart
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  void dispose() {
    // ✅ תמיד dispose controllers!
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _handleSubmit() async {
    // ✅ בדוק validation לפני המשך
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final email = _emailController.text.trim(); // ✅ trim רווחים
    // ... המשך הלוגיקה
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: (value) {
              // ✅ בדיקות validation ברורות
              if (value == null || value.isEmpty) {
                return 'שדה חובה';
              }
              if (!value.contains('@')) {
                return 'אימייל לא תקין';
              }
              return null; // ✅ null = valid
            },
          ),
        ],
      ),
    );
  }
}
```

**Best Practices:**
- השתמש ב-`GlobalKey<FormState>` לטפסים
- תמיד dispose את ה-controllers
- השתמש ב-`trim()` על קלט טקסט
- החזר `null` כש-validation עובר
- החזר string עם הודעת שגיאה כש-validation נכשל

---

### 7. תיעוד פונקציות

#### תיעוד פונקציות ציבוריות

```dart
/// Creates a shopping list with the given parameters.
///
/// Parameters:
/// - [name]: The name of the shopping list
/// - [type]: The type of list (see [ListType])
/// - [items]: Optional initial items
///
/// Returns a [Future<ShoppingList>] with the created list.
///
/// Throws [FirebaseException] if creation fails.
Future<ShoppingList> createList({
  required String name,
  required ListType type,
  List<ShoppingItem>? items,
}) async {
  // Implementation...
}
```

#### תיעוד פונקציות פרטיות

```dart
/// Validates the email format and checks if it's already in use.
/// Returns true if valid and available, false otherwise.
/// Internal helper for registration validation.
Future<bool> _validateEmail(String email) async {
  // Implementation...
}

/// Calculates the total price of items in the cart.
/// Used by [checkout] and [updateCartSummary].
double _calculateTotal(List<CartItem> items) {
  // Implementation...
}
```

**כללים:**
- ✅ **פונקציות ציבוריות:** תיעוד מפורט עם `///`
- ✅ **פונקציות פרטיות:** תיעוד קצר אבל ברור
- ✅ תאר **מה** הפונקציה עושה, לא **איך**
- ✅ ציין **parameters** חשובים
- ✅ ציין **return type** ו**exceptions**
- ✅ השתמש ב-`[ClassName]` לקישורים

---

## 🎯 UX Best Practices

### 1. הודעות משתמש (SnackBars)

```dart
// ✅ הודעת הצלחה
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 8),
        Expanded(child: Text('הפעולה הצליחה!')),
      ],
    ),
    backgroundColor: Colors.green.shade700,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.all(16),
  ),
);

// ✅ הודעת שגיאה
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.white),
        SizedBox(width: 8),
        Expanded(child: Text(errorMessage)),
      ],
    ),
    backgroundColor: Colors.red.shade700,
    duration: Duration(seconds: 5), // יותר זמן לשגיאות
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.all(16),
  ),
);
```

**עקרונות:**
- 🎨 צבע ירוק להצלחה, אדום לשגיאה
- 🎯 אייקון מתאים לכל סוג הודעה
- ⏱️ הצלחה: 2-3 שניות, שגיאה: 4-5 שניות
- 📱 `floating` + `margin` למראה מודרני

---

### 2. Loading States

```dart
// ✅ כפתור עם loading
StickyButton(
  onPressed: _isLoading ? () {} : () => _handleAction(),
  label: _isLoading ? 'טוען...' : 'המשך',
  icon: _isLoading ? null : Icons.arrow_forward,
)

// ✅ Spinner במרכז
if (_isLoading)
  Center(
    child: CircularProgressIndicator(),
  )
else
  YourContent(),

// ✅ Overlay loading על כל המסך
Stack(
  children: [
    YourContent(),
    if (_isLoading)
      Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
  ],
)
```

---

### 3. שגיאות וvalidation

```dart
// ✅ אנימציה על שגיאה
late AnimationController _shakeController;

void _showError() {
  _shakeController.forward(from: 0); // רועד על שגיאה
  // + הצג SnackBar
}

// ✅ הדגשה ויזואלית
TextFormField(
  decoration: InputDecoration(
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
  ),
)
```

---

## 📱 ביצועים ונגישות

### 1. ביצועים

```dart
// ✅ השתמש ב-const כשאפשר
const SizedBox(height: 16)
const Icon(Icons.check)

// ✅ מנע rebuild מיותר
class MyWidget extends StatelessWidget {
  final String title;
  
  const MyWidget({Key? key, required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Widget לא יבנה מחדש אלא אם title משתנה
  }
}

// ✅ Lazy loading לרשימות
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

### 2. נגישות

```dart
// ✅ Semantics לכפתורים מותאמים אישית
Semantics(
  button: true,
  label: 'התחבר למערכת',
  enabled: !_isLoading,
  child: MyCustomButton(...),
)

// ✅ גודל מגע מינימלי
Container(
  height: 48, // מינימום לנגישות
  width: 48,
  child: IconButton(...),
)

// ✅ Tooltip להסבר
IconButton(
  icon: Icon(Icons.info),
  tooltip: 'מידע נוסף על התכונה',
  onPressed: () {},
)
```

---

## 🧪 בדיקות ודיבאג

### 1. Debug Prints

```dart
// ✅ שימוש נכון ב-debugPrint
debugPrint('🔐 _handleLogin() | Starting login process...');
debugPrint('✅ _handleLogin() | Login successful');
debugPrint('❌ _handleLogin() | Error: $e');

// ⚠️ הסר לפני production!
```

**פורמט מומלץ:**
- 🎯 אימוג'י לסוג הודעה
- 📍 שם הפונקציה
- 📝 תיאור קצר
- ✅/❌ סטטוס

### 2. Error Handling

```dart
// ✅ Catch מפורט
try {
  await riskyOperation();
} on FirebaseAuthException catch (e) {
  // טיפול ספציפי ל-Firebase
  print('Firebase error: ${e.code}');
} on NetworkException catch (e) {
  // טיפול בבעיות רשת
  print('Network error: $e');
} catch (e) {
  // Fallback כללי
  print('Unexpected error: $e');
}
```

---

## 🤖 עבודה עם AI

### משפט הקסם לסוכן AI

**תן לסוכן את המשפט הזה בתחילת כל שיחה:**
```
📌 קרא תחילה: C:\projects\salsheli\AI_QUICK_START.md - הוראות חובה לפני עבודה
```

### מה הסוכן יעשה אוטומטית

כשקורא קובץ, הסוכן יבצע **Code Review אוטומטי**:

#### 1️⃣ שגיאות טכניות (תיקון מיידי!)
- ✅ `withOpacity(0.5)` → `withValues(alpha: 0.5)`
- ✅ `value` (DropdownButtonFormField) → `initialValue`
- ✅ `kQuantityFieldWidth` → `kFieldWidthNarrow`
- ✅ `kBorderRadiusFull` → `kRadiusPill`
- ✅ async function ב-onPressed → עטוף ב-lambda
- ✅ widgets שלא משתנים → הוסף `const`
- ✅ imports לא נעשים → תקן
- ✅ deprecated APIs → החלף ל-modern API

#### 2️⃣ עיצוב לא תואם STICKY_NOTES_DESIGN.md (תיקון מיידי!)

**אם המסך הוא מסך UI ולא מעוצב עם Sticky Notes:**
→ **הסוכן יחליף את כל העיצוב מיידית!**

**העיצוב החדש יכלול:**
- ✅ `NotebookBackground()` + `kPaperBackground`
- ✅ `StickyNoteLogo()` עבור לוגו
- ✅ `StickyNote()` עבור כותרות ושדות
- ✅ `StickyButton()` עבור כפתורים
- ✅ סיבובים: -0.03 עד 0.03
- ✅ צבעים: `kStickyYellow`, `kStickyPink`, `kStickyGreen`

#### 3️⃣ קוד לא עוקב BEST_PRACTICES.md (תיקון מיידי!)
- ✅ חסר תיעוד בראש הקובץ → הוסף header comment
- ✅ פונקציות פרטיות ללא documentation → הוסף `///` comments
- ✅ פונקציות ציבוריות ללא documentation → הוסף `///` comments
- ✅ naming לא עקבי → תקן
- ✅ magic numbers → הגדר constants

#### 4️⃣ TODO/FIXME
- אם הסוכן יכול לפתור מיידית → יפתור
- אם לא → ידווח למשתמש

### כללי עבודה עם AI

**מה הסוכן יעשה:**
- ✅ קרא קבצים → עבוד → דווח תמציתי
- ✅ תקן שגיאות טכניות מיידית (ללא שאלות)
- ✅ תקן עיצוב שלא תואם (ללא שאלות)
- ✅ שאל רק שאלות חשובות (החלטות עיצוביות)

**מה הסוכן לא יעשה:**
- ❌ לא יסביר כל שלב בפירוט
- ❌ לא ישאל אישור לתיקונים טכניים
- ❌ לא יצטט קוד ארוך בתשובות

**למידע מפורט:** ראה `AI_QUICK_START.md`

---

## 📋 Code Review Checklist

### 🔍 לפני Commit - בדוק:

#### שגיאות טכניות
- [ ] אין `withOpacity` - הוחלף ב-`withValues(alpha:)`
- [ ] אין `value` ב-DropdownButtonFormField - הוחלף ב-`initialValue`
- [ ] אין `kQuantityFieldWidth` - הוחלף ב-`kFieldWidthNarrow`
- [ ] אין `kBorderRadiusFull` - הוחלף ב-`kRadiusPill`
- [ ] async functions עטופות בלמבדה ב-onPressed
- [ ] widgets קבועים מסומנים `const`
- [ ] כל ה-imports נעשים בהצלחה
- [ ] אין deprecated APIs

#### עיצוב Sticky Notes (למסכי UI)
- [ ] יש `NotebookBackground()` + `kPaperBackground`
- [ ] משתמש ב-`StickyNote()` לכותרות ושדות
- [ ] משתמש ב-`StickyButton()` לכפתורים
- [ ] משתמש ב-`StickyNoteLogo()` ללוגו
- [ ] סיבובים בטווח -0.03 עד 0.03
- [ ] צבעים מ-`kSticky*` constants
- [ ] מקסימום 3 צבעים במסך

#### תיעוד וקוד נקי
- [ ] יש תיעוד בראש הקובץ (מה הקובץ עושה)
- [ ] פונקציות ציבוריות מתועדות (`///`)
- [ ] פונקציות פרטיות מתועדות (`///`) - קצר אבל ברור
- [ ] naming עקבי (PascalCase לclasses, camelCase למשתנים)
- [ ] אין magic numbers - הוחלפו בconstants
- [ ] אין קוד מת (commented out code)
- [ ] context נשמר לפני await
- [ ] `mounted` נבדק אחרי await

#### ביצועים
- [ ] `const` בכל מקום שאפשר
- [ ] אין rebuild מיותר
- [ ] ListView.builder לרשימות ארוכות
- [ ] Controllers מקבלים dispose

#### UX
- [ ] יש loading states
- [ ] הודעות שגיאה ברורות
- [ ] הודעות הצלחה
- [ ] כפתורים נגישים (44-48px)
- [ ] טקסט קריא (מינימום 11px)

---

## ✅ Checklist למסך חדש

לפני שמסיימים מסך חדש, ודא:

### עיצוב
- [ ] משתמש ב-Sticky Notes Design System
- [ ] רקע: `kPaperBackground` + `NotebookBackground`
- [ ] רווחים: compact אם צריך להיכנס במסך אחד
- [ ] צבעים: מקסימום 3 צבעים שונים
- [ ] סיבובים: בטווח -0.03 עד 0.03
- [ ] Logo: `StickyNoteLogo` במקום Container
- [ ] כפתורים: `StickyButton` במקום ElevatedButton
- [ ] שדות: `StickyNote` לעטיפה

### קוד
- [ ] Async functions עטופות בלמבדה
- [ ] Context נשמר לפני await
- [ ] בדיקת `mounted` אחרי await
- [ ] withValues במקום withOpacity
- [ ] initialValue במקום value (DropdownButtonFormField)
- [ ] kFieldWidthNarrow במקום kQuantityFieldWidth
- [ ] kRadiusPill במקום kBorderRadiusFull
- [ ] Controllers מקבלים dispose
- [ ] Form validation מוגדר
- [ ] תיעוד בראש הקובץ
- [ ] תיעוד לכל פונקציה (ציבורית + פרטית)

### UX
- [ ] Loading states מוגדרים
- [ ] הודעות שגיאה ברורות
- [ ] הודעות הצלחה
- [ ] כפתורים נגישים (44-48px)
- [ ] טקסט קריא (מינימום 11px)
- [ ] 3-4 Empty States (Loading/Error/Empty/Initial)

### ביצועים
- [ ] const בכל מקום שאפשר
- [ ] Lazy loading לרשימות
- [ ] אין rebuild מיותר
- [ ] Debug prints מוסרים בproduction

### בדיקה אחרונה
- [ ] `flutter analyze` - 0 issues
- [ ] `dart format lib/ -w` - קוד מפורמט
- [ ] המסך עובד בהצלחה
- [ ] המסך עובד עם Dark mode
- [ ] המסך נראה טוב במכשיר אמיתי

---

## 🎓 לקחים שנלמדו

### מעיצוב מסך ההתחברות

1. **צמצום בחכמה** - לא צריך להקריב קריאות בשביל קומפקטיות
2. **Transform.scale** - כלי מעולה להקטנת אלמנטים גרפיים
3. **Padding מותאם** - אופקי/אנכי שונים חוסכים מקום
4. **contentPadding** - הקטנת padding פנימי בשדות טקסט עוזרת הרבה
5. **Center + SingleChildScrollView** - שילוב מושלם למסכים compact

### מתיקון שגיאות

1. **Type checking** - תמיד בדוק את הטיפוסים לפני העברה
2. **Async wrapper** - לעטוף Future בלמבדה זה הכי פשוט
3. **Deprecated APIs** - עקוב אחרי העדכונים של Flutter
4. **Migration strategy** - שנה בהדרגה, לא הכל בבת אחת

### מעבודה עם AI

1. **Code Review אוטומטי** - הסוכן מתקן שגיאות מיידית
2. **תקשורת ברורה** - תן לסוכן את `AI_QUICK_START.md`
3. **תיקונים מיידיים** - שגיאות טכניות מתוקנות ללא שאלות
4. **תיעוד חשוב** - הסוכן מוסיף תיעוד חסר אוטומטית

---

## 📚 משאבים נוספים

### מסמכים פנימיים
- `AI_QUICK_START.md` - הוראות מהירות לסוכן AI ⚡
- `STICKY_NOTES_DESIGN.md` - מדריך מלא לעיצוב
- `LESSONS_LEARNED.md` - דפוסים טכניים וארכיטקטורה
- `README.md` - תיעוד כללי של הפרויקט
- `lib/core/ui_constants.dart` - כל הקבועים

### דוגמאות קוד
- `lib/screens/auth/login_screen.dart` - מסך compact מלא + Sticky Notes
- `lib/widgets/auth/demo_login_button.dart` - רכיב compact
- `lib/widgets/common/` - כל רכיבי העיצוב Sticky Notes

### דוקומנטציה חיצונית
- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design](https://material.io/design)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

---

**גרסה:** 1.1  
**תאריך:** 15/10/2025  
**מעודכן לאחרונה:** 15/10/2025

💻 **Happy Coding!** 🚀
