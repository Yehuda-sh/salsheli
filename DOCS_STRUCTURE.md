# 📚 מבנה מסמכי הפרויקט

> **עדכון:** 18/10/2025 - הוספת מדריך התחלה מהירה למתחילים!

## 📋 מסמכים פעילים

### 🚀 למתחילים - התחל כאן!
- **`GETTING_STARTED.md`** - מדריך התחלה מהירה (5-10 דק') 🆕
  - טבלת קיצורי דרך
  - איך לדבר עם Claude
  - Claude Code - התקנה ושימוש
  - דוגמאות מהפרויקט
  - קישורים למדריכים המפורטים

### 🎯 מדריכים מהירים (Quick References)
- **`AI_MASTER_GUIDE.md`** - מדריך מלא למערכות AI (10 דק')
- **`CLAUDE_TECHNICAL_GUIDE.md`** - מדריך טכני מקוצר (5 דק')
- **`QUICK_REFERENCE.md`** - TL;DR של כל הנושאים החשובים (2-3 דק')

### 💻 פיתוח ועיצוב
- **`BEST_PRACTICES.md`** - דוגמאות קוד ו-checklists (15 דק')
- **`STICKY_NOTES_DESIGN.md`** - מערכת העיצוב הייחודית (10 דק')
- **`LESSONS_LEARNED.md`** - דפוסים טכניים וארכיטקטורה (10 דק')

### ⚡ ביצועים ואופטימיזציה
- **`PERFORMANCE_TEST.md`** - מדריך שיפורי ביצועים (5 דק')
  - Debouncing pattern - מניעת קריאות מרובות
  - Isolate - חישובים כבדים ברקע
  - Batch Processing - טעינה מדורגת
  - Performance benchmarks - מדדים ומדידות
  - דוגמאות טסט מהירות

### 🔒 אבטחה ובדיקות
- **`SECURITY_GUIDE.md`** - Auth + Firestore Rules (10 דק')
- **`TESTING_GUIDE.md`** - Unit + Widget + Integration tests (10 דק')
  - **חדש:** סעיף Quick Commands עם פקודות לבדיקות מהירות

### 📖 תיעוד כללי
- **`README.md`** - תיעוד ראשי של הפרויקט
- **`DOCS_STRUCTURE.md`** - המסמך הזה

## ♻️ מסמכים שהועברו/מוחקו

### הועברו למסמכים אחרים (16/10/2025):
- ~~`QUICK_FIX_SUMMARY.md`~~ → התוכן הועבר ל-`TESTING_GUIDE.md`
- ~~`WORK_LOG.md`~~ → התוכן הועבר ל-`LESSONS_LEARNED.md`, `BEST_PRACTICES.md`, `QUICK_REFERENCE.md`
- ~~`FIX_USER_ENTITY.md`~~ → כפול עם QUICK_FIX_SUMMARY (מחוק)
- ~~`IMPROVEMENTS_SUMMARY.md`~~ → סיכום זמני של שיפורים (מחוק)
- ~~`fix_user_context_test.dart`~~ → סקריפט תיקון זמני (מחוק)

### אוחדו למדריך אחד (18/10/2025):
- ~~`AI_DEVELOPER_INTERACTION_GUIDE.md`~~ → אוחד ל-`AI_MASTER_GUIDE.md`
- ~~`AI_DEV_GUIDELINES.md`~~ → אוחד ל-`AI_MASTER_GUIDE.md`
- ~~`AI_QUICK_START.md`~~ → אוחד ל-`AI_MASTER_GUIDE.md`

**תוצאה:** כל המידע הטכני וה-AI Behavior Instructions כעת ב-`AI_MASTER_GUIDE.md` אחד מאוחד!

**הערה:** קבצים אלו נמחקו לגמרי מהפרויקט. התוכן החשוב שלהם הועבר למסמכים הרלוונטיים.

### קבצים שנמחקו היום (17/10/2025) - Hive ו-Dead Code:
- `lib/models/product_entity.dart` → מודל Hive (נמחק)
- `lib/models/product_entity.g.dart` → Generated code (נמחק)
- `lib/repositories/local_products_repository.dart` → Repository של Hive (נמחק)
- `lib/repositories/hybrid_products_repository.dart` → Repository היברידי (נמחק)
- `test/models/product_entity_test.dart` → בדיקות של product_entity (הועבר ל-.bak)

### קבצים ששמרנו:
- ✅ `AI_DEV_GUIDELINES.md` - מקיף ומפנה לכל המסמכים
- ✅ `AI_QUICK_START.md` - הוראות מהירות לעבודה עם AI
- ✅ `DEPENDENCY_NOTE.md` - תיעוד חשוב על dependencies

## 🎓 סדר קריאה מומלץ

### 🆕 למפתח מתחיל:
1. **`GETTING_STARTED.md`** - ⭐ **התחל כאן!** (5-10 דק')
2. `QUICK_REFERENCE.md` - תשובות מהירות (2-3 דק')
3. `LESSONS_LEARNED.md` - עקרונות (10 דק')
4. `BEST_PRACTICES.md` - איך לכתוב קוד (15 דק')
5. `STICKY_NOTES_DESIGN.md` - עיצוב (10 דק')

### למפתח מנוסה:
1. `README.md` - הכרת הפרויקט
2. `DOCS_STRUCTURE.md` - מפת דרכים
3. `LESSONS_LEARNED.md` - עקרונות
4. `BEST_PRACTICES.md` - איך לכתוב קוד
5. `STICKY_NOTES_DESIGN.md` - עיצוב

### לעבודה עם AI:
1. `AI_MASTER_GUIDE.md` - **חובה בתחילת כל שיחה!** (מדריך מלא)
2. `CLAUDE_TECHNICAL_GUIDE.md` - אלטרנטיבה מקוצרת (רק טכני)

### לפיתוח features חדשים:
1. `BEST_PRACTICES.md`
2. `STICKY_NOTES_DESIGN.md`
3. `TESTING_GUIDE.md`
4. `SECURITY_GUIDE.md`

### לשיפור ביצועים:
1. `PERFORMANCE_TEST.md` - דפוסים וטסטים
2. `LESSONS_LEARNED.md` - עקרונות ארכיטקטורה
3. `BEST_PRACTICES.md` - דוגמאות קוד

---

**עודכן:** 18/10/2025 (21:45) | **מעודכן ע"י:** AI Assistant | **שינוי:** הוספת PERFORMANCE_TEST.md למדריכי ביצועים
