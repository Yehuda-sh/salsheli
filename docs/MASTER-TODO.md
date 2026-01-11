# תוכנית עבודה כללית - MemoZap

מסמך זה מרכז את כל הפערים והתיקונים הנדרשים בקוד.

**תאריך יצירה:** ינואר 2026

---

## סיכום מהיר

| קטגוריה | כמות משימות |
|---------|-------------|
| 🔴 באגים קריטיים | 3 |
| 🔴 דרישות חוק (GDPR) | 2 |
| 🟡 פונקציונליות חסרה | 12 |
| 🟢 שיפורים | 8 |
| **סה"כ** | **25** |

---

## 🔴 עדיפות קריטית - חייב לתקן

### באגים

| # | בעיה | קובץ | שורה | תיאור |
|---|------|------|------|-------|
| 1 | **צופה יכול להיכנס לקנייה** | `active_shopping_screen.dart` | - | אין בדיקת הרשאות - צופה לא צריך להיכנס למסך קנייה בכלל |
| 2 | **העברת בעלות חסומה** | `firebase_group_repository.dart` | 318 | הקוד חוסם שינוי לתפקיד owner - בעלים לא יכול להעביר בעלות |
| 3 | **checkedBy/checkedAt לא נשמרים** | `shopping_lists_provider.dart` | 1099 | כשמסמנים פריט - לא נשמר מי סימן ומתי |

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
| 10 | קבוצות | `groups_list_screen.dart` | הודעה + קריאה בלבד |
| 11 | הגדרות | `settings_screen.dart` | הגדרות מקומיות עובדות, שרת - לא |

**המלצה:** ליצור widget משותף `OfflineBanner` ו-mixin `ConnectivityMixin`

### עדכון בזמן אמת

| # | פיצ'ר | קובץ | מה לממש |
|---|-------|------|---------|
| 12 | רשימות משותפות | `shopping_list_details_screen.dart` | StreamBuilder במקום Provider.watch |
| 13 | קנייה משותפת | `active_shopping_screen.dart` | סנכרון בזמן אמת בין קונים |

### הגבלות

| # | הגבלה | ערך | קובץ | מה לממש |
|---|-------|-----|------|---------|
| 14 | פריטים ברשימה | 200 | `shopping_lists_provider.dart` | בדיקה ב-`addItemToList` |
| 15 | פריטים במזווה | 500 | `inventory_provider.dart` | בדיקה לפני הוספה |
| 16 | חברים בקבוצה | 100 | `groups_provider.dart` | בדיקה לפני הזמנה |
| 17 | קבוצות למשתמש | 50 | `groups_provider.dart` | בדיקה לפני יצירה |

---

## 🟡 עדיפות בינונית - פיצ'רים חסרים

### הגדרות וחשבון

| # | פיצ'ר | קובץ | תיאור |
|---|-------|------|-------|
| 18 | עריכת פרופיל | `edit_profile_screen.dart` (חדש) | שם, תמונה, טלפון |
| 19 | שינוי סיסמה | `settings_screen.dart` | רק למשתמשי אימייל+סיסמה |
| 20 | הגדרות התראות | `notification_settings_screen.dart` (חדש) | מתגים לכל סוג התראה |

### קבוצות

| # | פיצ'ר | קובץ | תיאור |
|---|-------|------|-------|
| 21 | העברת בעלות | `firebase_group_repository.dart`, `group_details_screen.dart` | לאפשר לבעלים להעביר |
| 22 | בעלים עוזב | `group_details_screen.dart` | לחסום יציאה בלי העברה |
| 23 | יציאה מקבוצה | `group_details_screen.dart` | אישור + הודעה למנהלים |

### רשימות קניות

| # | פיצ'ר | קובץ | תיאור |
|---|-------|------|-------|
| 24 | מצב "מי מביא מה" | `shopping_list_details_screen.dart`, `unified_list_item.dart` | שדה claimedBy, UI, נעילה |
| 25 | כפתור toggle קיבוץ | `shopping_list_details_screen.dart` | המשתמש יבחר אם לקבץ |

### מזווה

| # | פיצ'ר | קובץ | תיאור |
|---|-------|------|-------|
| 26 | הוספה מקנייה | `shopping_summary_screen.dart` | שאלה "להוסיף למזווה?" בסיום |
| 27 | תאריך תפוגה | `my_pantry_screen.dart` | סימון אדום (לא מחיקה אוטומטית) |

### קנייה פעילה

| # | פיצ'ר | קובץ | תיאור |
|---|-------|------|-------|
| 28 | הודעה על קנייה פעילה | `home_dashboard_screen.dart` | banner "יש לך קנייה פעילה" |
| 29 | קנייה משותפת | `active_shopping_screen.dart` | הצטרפות, אישור, סנכרון |
| 30 | timeout 6 שעות | `active_shopping_screen.dart` | ניקוי סשן אוטומטי |

---

## 🟢 עדיפות נמוכה - שיפורים

| # | שיפור | קובץ | תיאור |
|---|-------|------|-------|
| 31 | Timeout לפעולות Firebase | `auth_service.dart` | 30 שניות timeout |
| 32 | Retry אוטומטי | `auth_service.dart` | ניסיון חוזר בכשל רשת |
| 33 | מיון רשימות בדף הבית | `home_dashboard_screen.dart` | לפי תאריך/שם/אחוז |
| 34 | מצב עריכה בדף הבית | `home_dashboard_screen.dart` | מחיקה/עריכה מהירה |
| 35 | התראות Push | `notification_service.dart` | FCM לכל סוגי ההתראות |
| 36 | ביטול מחיקה במזווה | `my_pantry_screen.dart` | undo 5 שניות |
| 37 | תבניות נוספות | `assets/templates/` | שבת, פיקניק, מסיבת ילדים |
| 38 | Onboarding | `onboarding_screen.dart` | להחליט אם צריך + לחבר |

---

## 📋 סדר עבודה מומלץ

### שלב 1: תיקון באגים קריטיים
```
1. תיקון הרשאות בקנייה (צופה לא נכנס)
2. תיקון העברת בעלות בקבוצות
3. תיקון שמירת checkedBy/checkedAt
```

### שלב 2: דרישות חוק
```
4. מימוש מחיקת חשבון (כולל Cloud Function)
5. קישור תנאי שימוש ופרטיות
```

### שלב 3: תשתית משותפת
```
6. יצירת OfflineBanner widget
7. יצירת ConnectivityMixin
8. הטמעה בכל המסכים
```

### שלב 4: הגבלות
```
9. הגבלת 200 פריטים ברשימה
10. הגבלת 500 פריטים במזווה
11. הגבלת 100 חברים בקבוצה
12. הגבלת 50 קבוצות למשתמש
```

### שלב 5: עדכון בזמן אמת
```
13. StreamBuilder לרשימות משותפות
14. סנכרון קנייה משותפת
```

### שלב 6: פיצ'רים חסרים
```
15-30. לפי סדר העדיפות למעלה
```

### שלב 7: שיפורים
```
31-38. לפי זמן פנוי
```

---

## 📁 קבצים עיקריים לשינוי (לפי תדירות)

| קובץ | כמות שינויים | מה לשנות |
|------|--------------|----------|
| `shopping_list_details_screen.dart` | 6 | offline, real-time, toggle, מי מביא מה |
| `active_shopping_screen.dart` | 5 | הרשאות, offline, משותפת, timeout |
| `settings_screen.dart` | 4 | סיסמה, התראות, offline, מחיקה |
| `home_dashboard_screen.dart` | 3 | offline, מיון, קנייה פעילה |
| `groups_provider.dart` | 3 | הגבלות, העברת בעלות |
| `group_details_screen.dart` | 3 | יציאה, העברה, הרשאות |
| `shopping_lists_provider.dart` | 2 | הגבלות, checkedBy |
| `firebase_group_repository.dart` | 1 | תיקון שורה 318 |
| `my_pantry_screen.dart` | 2 | offline, תפוגה |
| `inventory_provider.dart` | 2 | הגבלות, התראות |

---

## 🔗 קישורים למסמכי פערים מפורטים

- [01-auth/GAPS-AND-FIXES.md](./explanations/01-auth/GAPS-AND-FIXES.md)
- [02-home/GAPS-AND-FIXES.md](./explanations/02-home/GAPS-AND-FIXES.md)
- [03-shopping-lists/GAPS-AND-FIXES.md](./explanations/03-shopping-lists/GAPS-AND-FIXES.md)
- [04-active-shopping/GAPS-AND-FIXES.md](./explanations/04-active-shopping/GAPS-AND-FIXES.md)
- [05-pantry/GAPS-AND-FIXES.md](./explanations/05-pantry/GAPS-AND-FIXES.md)
- [06-groups/GAPS-AND-FIXES.md](./explanations/06-groups/GAPS-AND-FIXES.md)
- [07-settings/GAPS-AND-FIXES.md](./explanations/07-settings/GAPS-AND-FIXES.md)

---

## ✅ הערות סיום

**מה עובד טוב:**
- הרשמה והתחברות
- יצירת ורשימות
- הוספת מוצרים
- קנייה פעילה (בסיסית)
- מזווה
- קבוצות ושיתוף
- עיצוב RTL
- תיעוד בעברית

**עיקרון מנחה:**
- לתקן באגים לפני הוספת פיצ'רים
- לעמוד בדרישות חוק (GDPR)
- להוסיף תשתיות משותפות פעם אחת
- לבדוק כל שינוי לפני מעבר לבא

---

**עודכן לאחרונה:** ינואר 2026
