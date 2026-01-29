# תוכנית עבודה כללית - MemoZap

מסמך זה מרכז את כל הפערים והתיקונים הנדרשים בקוד.

**תאריך יצירה:** ינואר 2026

---

## סיכום מהיר

| קטגוריה | כמות משימות |
|---------|-------------|
| 🔴 באגים קריטיים | 2 |
| 🔴 דרישות חוק (GDPR) | 2 |
| 🟠 עדיפות גבוהה (offline, limits, real-time) | 9 |
| 🟡 עדיפות בינונית (פיצ'רים) | 9 |
| 🟢 שיפורים | 8 |
| **סה"כ** | **30** |

---

## 🔴 עדיפות קריטית - חייב לתקן

### באגים

| # | בעיה | קובץ | שורה | תיאור |
|---|------|------|------|-------|
| 1 | **צופה יכול להיכנס לקנייה** | `active_shopping_screen.dart` | - | אין בדיקת הרשאות - צופה לא צריך להיכנס למסך קנייה בכלל |
| 2 | **checkedBy/checkedAt לא נשמרים** | `shopping_lists_provider.dart` | 1099 | כשמסמנים פריט - לא נשמר מי סימן ומתי |

### דרישות חוק (GDPR)

| # | דרישה | קובץ | תיאור |
|---|-------|------|-------|
| 4 | **מחיקת חשבון** | `settings_screen.dart` + Cloud Function | משתמש חייב יכולת למחוק את החשבון שלו |
| 5 | **תנאי שימוש ופרטיות** | `welcome_screen.dart` שורות 190-216 | כפתורים קיימים אבל לא עובדים |

---

## 🟠 עדיפות גבוהה - פונקציונליות חסרה

### טיפול ב-Offline (כל המסכים)

| # | מסך | קובץ | מה לממש |
|---|-----|------|---------|
| 6 | דף הבית | `home_dashboard_screen.dart` | הודעה + קריאה בלבד |
| 7 | רשימות קניות | `shopping_list_details_screen.dart` | הודעה + קריאה בלבד |
| 8 | קנייה פעילה | `active_shopping_screen.dart` | שמירה מקומית + סנכרון בחזרה |
| 9 | מזווה | `my_pantry_screen.dart` | הודעה + קריאה בלבד |
| 10 | הגדרות | `settings_screen.dart` | הגדרות מקומיות עובדות, שרת - לא |

**המלצה:** ליצור widget משותף `OfflineBanner` ו-mixin `ConnectivityMixin`

### עדכון בזמן אמת

| # | פיצ'ר | קובץ | מה לממש |
|---|-------|------|---------|
| 13 | רשימות משותפות | `shopping_list_details_screen.dart` | StreamBuilder במקום Provider.watch |
| 14 | קנייה משותפת | `active_shopping_screen.dart` | סנכרון בזמן אמת בין קונים |

### הגבלות

| # | הגבלה | ערך | קובץ | מה לממש |
|---|-------|-----|------|---------|
| 11 | פריטים ברשימה | 200 | `shopping_lists_provider.dart` | בדיקה ב-`addItemToList` |
| 12 | פריטים במזווה | 500 | `inventory_provider.dart` | בדיקה לפני הוספה |

---

## 🟡 עדיפות בינונית - פיצ'רים חסרים

### הגדרות וחשבון

| # | פיצ'ר | קובץ | תיאור |
|---|-------|------|-------|
| 15 | עריכת פרופיל | `edit_profile_screen.dart` (חדש) | שם, תמונה, טלפון |
| 16 | שינוי סיסמה | `settings_screen.dart` | רק למשתמשי אימייל+סיסמה |
| 17 | הגדרות התראות | `notification_settings_screen.dart` (חדש) | מתגים לכל סוג התראה |

### רשימות קניות

| # | פיצ'ר | קובץ | תיאור |
|---|-------|------|-------|
| 18 | כפתור toggle קיבוץ | `shopping_list_details_screen.dart` | המשתמש יבחר אם לקבץ |

### מזווה

| # | פיצ'ר | קובץ | תיאור |
|---|-------|------|-------|
| 19 | הוספה מקנייה | `shopping_summary_screen.dart` | שאלה "להוסיף למזווה?" בסיום |
| 20 | תאריך תפוגה | `my_pantry_screen.dart` | סימון אדום (לא מחיקה אוטומטית) |

### קנייה פעילה

| # | פיצ'ר | קובץ | תיאור |
|---|-------|------|-------|
| 21 | הודעה על קנייה פעילה | `home_dashboard_screen.dart` | banner "יש לך קנייה פעילה" |
| 22 | קנייה משותפת | `active_shopping_screen.dart` | הצטרפות, אישור, סנכרון |
| 23 | timeout 6 שעות | `active_shopping_screen.dart` | ניקוי סשן אוטומטי |

---

## 🟢 עדיפות נמוכה - שיפורים

| # | שיפור | קובץ | תיאור |
|---|-------|------|-------|
| 24 | Timeout לפעולות Firebase | `auth_service.dart` | 30 שניות timeout |
| 25 | Retry אוטומטי | `auth_service.dart` | ניסיון חוזר בכשל רשת |
| 26 | מיון רשימות בדף הבית | `home_dashboard_screen.dart` | לפי תאריך/שם/אחוז |
| 27 | מצב עריכה בדף הבית | `home_dashboard_screen.dart` | מחיקה/עריכה מהירה |
| 28 | התראות Push | `notification_service.dart` | FCM לכל סוגי ההתראות |
| 29 | ביטול מחיקה במזווה | `my_pantry_screen.dart` | undo 5 שניות |
| 30 | תבניות נוספות | `assets/templates/` | שבת, פיקניק, מסיבת ילדים |
| 31 | Onboarding | `onboarding_screen.dart` | להחליט אם צריך + לחבר |

---

## 📋 סדר עבודה מומלץ

### שלב 1: תיקון באגים קריטיים
```
1. תיקון הרשאות בקנייה (צופה לא נכנס)
2. תיקון שמירת checkedBy/checkedAt
```

### שלב 2: דרישות חוק
```
3. מימוש מחיקת חשבון (כולל Cloud Function)
4. קישור תנאי שימוש ופרטיות
```

### שלב 3: תשתית משותפת
```
5. יצירת OfflineBanner widget
6. יצירת ConnectivityMixin
7. הטמעה בכל המסכים
```

### שלב 4: הגבלות
```
8. הגבלת 200 פריטים ברשימה
9. הגבלת 500 פריטים במזווה
```

### שלב 5: עדכון בזמן אמת
```
10. StreamBuilder לרשימות משותפות
11. סנכרון קנייה משותפת
```

### שלב 6: פיצ'רים חסרים
```
15-23. לפי סדר העדיפות למעלה
```

### שלב 7: שיפורים
```
24-31. לפי זמן פנוי
```

---

## 📁 קבצים עיקריים לשינוי (לפי תדירות)

| קובץ | כמות שינויים | מה לשנות |
|------|--------------|----------|
| `shopping_list_details_screen.dart` | 4 | offline, real-time, toggle |
| `active_shopping_screen.dart` | 4 | הרשאות, offline, משותפת, timeout |
| `settings_screen.dart` | 4 | סיסמה, התראות, offline, מחיקה |
| `home_dashboard_screen.dart` | 3 | offline, מיון, קנייה פעילה |
| `shopping_lists_provider.dart` | 2 | הגבלות, checkedBy |
| `my_pantry_screen.dart` | 2 | offline, תפוגה |
| `inventory_provider.dart` | 2 | הגבלות, התראות |

---

## 🔗 קישורים למסמכי פערים מפורטים

- [01-auth/GAPS-AND-FIXES.md](./explanations/01-auth/GAPS-AND-FIXES.md)
- [02-home/GAPS-AND-FIXES.md](./explanations/02-home/GAPS-AND-FIXES.md)
- [03-shopping-lists/GAPS-AND-FIXES.md](./explanations/03-shopping-lists/GAPS-AND-FIXES.md)
- [04-active-shopping/GAPS-AND-FIXES.md](./explanations/04-active-shopping/GAPS-AND-FIXES.md)
- [05-pantry/GAPS-AND-FIXES.md](./explanations/05-pantry/GAPS-AND-FIXES.md)
- [06-settings/GAPS-AND-FIXES.md](./explanations/06-settings/GAPS-AND-FIXES.md)

---

## ✅ הערות סיום

**מה עובד טוב:**
- הרשמה והתחברות
- יצירת רשימות
- הוספת מוצרים
- קנייה פעילה (בסיסית)
- מזווה
- שיתוף רשימות
- היסטוריית קניות
- עיצוב RTL
- תיעוד בעברית

**עיקרון מנחה:**
- לתקן באגים לפני הוספת פיצ'רים
- לעמוד בדרישות חוק (GDPR)
- להוסיף תשתיות משותפות פעם אחת
- לבדוק כל שינוי לפני מעבר לבא

---

**עודכן לאחרונה:** ינואר 2026
