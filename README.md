# 🛒 סל שלי (Salsheli) - README v1.4.0

> **🆕 חדש! מפתח מתחיל? התחל כאן:** [**GETTING_STARTED.md**](GETTING_STARTED.md) - מדריך התחלה מהירה (5-10 דקות) 🚀

> **עדכון 18/10/2025:** מדריך התחלה חדש + תיעוד מאוחד!
> - 🆕 **GETTING_STARTED.md** - מדריך התחלה מהירה למתחילים!
> - ✅ **DOCS_STRUCTURE.md** - מפת דרכים למסמכים
> - ✅ **10 מסמכים מאורגנים** - במקום 14 עם כפילויות
> - ✅ **Claude Code** - מדריך להתקנה ושימוש
> - ✅ **עדכון כל המסמכים** - imports נכונים, constants מעודכנים

---

## 📚 קבצי התיעוד המעודכנים

### 1. **LESSONS_LEARNED.md** 📖
**חובה! הקרא קודם!**
- דפוסים טכניים + ארכיטקטורה
- 15 עקרונות זהב
- Firebase Integration, Repository Pattern, Templates System

### 2. **BEST_PRACTICES.md** 💡
**חובה לכל מפתח!**
- Best practices לקוד ועיצוב
- עיצוב Compact למסכים
- Async callbacks, withValues, Context Management
- Loading States, UX Best Practices

### 3. **SECURITY_GUIDE.md** 🔒
**חובה להבנת Auth/Security!**
- Firebase Auth Setup
- Firestore Security Rules
- Sensitive Data Handling
- User Context & Access Control
- Deployment Checklist

### 4. **STICKY_NOTES_DESIGN.md** 🎨
**למערכת העיצוב!**
- מדריך מלא למערכת העיצוב
- רכיבים: NotebookBackground, StickyNote, StickyButton
- עיצוב Compact - מסכים ללא גלילה
- דוגמאות קוד מלאות

### 5. **QUICK_REFERENCE.md** ⚡
**תשובות מהירות (30 שניות)!**
- Dead Code (3-Step Process)
- Dormant Code (4 Questions Framework)
- File Paths - בדיקה
- i18n + Constants

### 6. **TESTING_GUIDE.md** 🧪
**כתיבת בדיקות!**
- Unit Tests
- Widget Tests
- Integration Tests
- Coverage Goals (80%+)

### 7. **AI_MASTER_GUIDE.md** 🤖
**מדריך מלא למערכות AI!**
- התחל כל שיחה: `📌 קרא תחילה: C:\projects\salsheli\AI_MASTER_GUIDE.md`
- כל ה-AI Behavior Instructions במקום אחד
- Code Review אוטומטי + Dead Code Detection
- Response Guidelines + Workflow + Technical Rules

### 8. **CLAUDE_TECHNICAL_GUIDE.md** 🛠️
**מדריך טכני מקוצר!**
- רק המידע הטכני הנדרש
- ללא הדרכות למשתמש
- בינלאומי (English) עם תשובות בעברית

### 9. **DOCS_STRUCTURE.md** 📋
**מפת דרכים למסמכים! 🆕**
- רשימת כל המסמכים הפעילים
- סדר קריאה מומלץ לכל מקרה
- מסמכים שהועברו/מוחקו
- עדכון: 16/10/2025

---

## 🎯 סדר קריאה מומלץ

### 🆕 למפתח מתחיל:
**התחל מ-[GETTING_STARTED.md](GETTING_STARTED.md)** - מדריך התחלה מהירה (5-10 דקות)!
- טבלת קיצורי דרך
- איך לדבר עם Claude
- Claude Code - התקנה ושימוש
- דוגמאות מהפרויקט

### 👨‍💻 למפתח מנוסה:
**התחל מ-DOCS_STRUCTURE.md** כדי להבין את מבנה המסמכים, אחר כך עבור ל-LESSONS_LEARNED.md.

### 🤖 לסוכן AI:
**התחל מ-AI_MASTER_GUIDE.md** - מדריך מלא בקובץ אחד!  
**או:** CLAUDE_TECHNICAL_GUIDE.md - גרסה מקוצרת טכנית

### 👥 מסלול מלא:

```
0️⃣ GETTING_STARTED.md       🚀 התחלה מהירה (מתחילים מכאן!) 🆕
   ↓
1️⃣ LESSONS_LEARNED.md       🏗️ הבסיס הטכני
   ↓
2️⃣ BEST_PRACTICES.md        💻 איך לכתוב קוד נכון
   ↓
3️⃣ SECURITY_GUIDE.md        🔐 אבטחה + Auth (חובה!)
   ↓
4️⃣ STICKY_NOTES_DESIGN.md   🎨 איך לעצב UI
   ↓
5️⃣ QUICK_REFERENCE.md       ⚡ תשובות מהירות
   ↓
6️⃣ TESTING_GUIDE.md         🧪 בדיקות
   ↓
7️⃣ AI_MASTER_GUIDE.md       🤖 לסוכן AI (מדריך מלא!)
   ↓
8️⃣ DOCS_STRUCTURE.md        📋 מפת דרכים למסמכים
```

---

## 🔗 קישורים מהירים לפתרונות

### 🎯 מתי להשתמש בכל קובץ?

| שאלה | קובץ | דוגמה |
|------|------|-------|
| **Dead Code?** | QUICK_REFERENCE.md | קובץ עם 0 imports? |
| **Async callback שגיאה?** | BEST_PRACTICES.md | `onPressed: _handleLogin` → `() => _handleLogin()` |
| **מחברת Firebase?** | LESSONS_LEARNED.md | `household_id` pattern |
| **Color deprecated?** | BEST_PRACTICES.md | `.withOpacity()` → `.withValues(alpha:)` |
| **UI Sticky Notes?** | STICKY_NOTES_DESIGN.md | NotebookBackground + StickyNote |
| **Auth בעיה?** | SECURITY_GUIDE.md | Firebase Auth Setup |
| **צריך בדיקות?** | TESTING_GUIDE.md | Unit/Widget/Integration Tests |
| **AI סוכן?** | AI_MASTER_GUIDE.md | Code Review + Behavior Instructions |

---

## 🔥 שינויים מרכזיים ב-v1.3.0 (16/10/2025)

✅ **ארגון מחדש של המסמכים**
- מחקנו 5 קבצים כפולים/זמניים
- יצרנו DOCS_STRUCTURE.md חדש
- עדכנו TESTING_GUIDE.md עם Quick Commands
- תיקנו STICKY_NOTES_DESIGN.md (imports + constants)

✅ **SECURITY_GUIDE.md**
- Firebase Auth Setup + Error Handling
- Firestore Security Rules (household-based)
- Sensitive Data Handling
- Deployment Checklist

✅ **הוספת TESTING_GUIDE.md**
- Unit Tests Examples
- Widget Tests Examples
- Integration Tests Examples
- Coverage Goals (80%+)

✅ **הוספת QUICK_REFERENCE.md**
- Dead Code (30 שניות)
- Dormant Code (2 דקות)
- File Paths - בדיקה
- i18n + Constants

✅ **עדכון קישורים**
- קישורים מהירים לכל קובץ
- ניווט טוב יותר
- טבלאות חיפוש

---

## 📊 סטטיסטיקות מעודכנות (16/10/2025)

| קטגוריה | כמות |
|---------|------|
| **מסמכי תיעוד פעילים** | **9** (מ-14) |
| **קבצי Dart** | **100+** |
| **Models** | **11** |
| **Providers** | **9** |
| **Repositories** | **17** |
| **Services** | **7** |
| **Screens** | **30+** |
| **Widgets** | **25+** |
| **Tests** | **50+** |
| **קבצים שמוחקו** | **5** (.deleted) |

---

## ✅ מה עובד היום (16/10/2025)

- ✅ Firebase Auth + Firestore
- ✅ Templates System (6 תבניות, 66 פריטים)
- ✅ Sticky Notes Design System
- ✅ AI Code Review אוטומטי
- ✅ Security Rules (household-based)
- ✅ OCR מקומי (ML Kit)
- ✅ Shufersal API (1,758 מוצרים)
- ✅ 21 סוגי רשימות
- ✅ Batch Processing (100+ items)
- ✅ LocationsProvider Firebase Migration
- ✅ מסמכים מאורגנים ונקיים 🆕

---

**תאריך עדכון:** 18/10/2025  
**גרסה:** 1.4.0 - AI Master Guide (Unified Documentation)  
**Made with ❤️ in Israel** 🇮🇱

## 📦 פרטי הפרויקט

- **שם:** סל שלי (Salsheli)
- **תיאור:** אפליקציית ניהול קניות משותפת למשפחה
- **טכנולוגיות:** Flutter, Firebase, Dart
- **מיקום:** C:\projects\salsheli\

> 💡 **להתחלה מהירה:** פתח את DOCS_STRUCTURE.md להתמצאות!

---

## 🚀 Quick Start Commands

```bash
# Clone the project
git clone https://github.com/yourusername/salsheli.git
cd salsheli

# Install dependencies
flutter pub get

# Generate code (models)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Run specific tests
flutter test test/models/         # Model tests
flutter test test/providers/      # Provider tests
flutter test test/widget/         # Widget tests
```

---

## 📧 יצירת קשר

יש שאלות? צור קשר:
- **Email:** your.email@example.com
- **GitHub:** https://github.com/yourusername/salsheli
- **Issues:** https://github.com/yourusername/salsheli/issues

---

**© 2025 Salsheli Team | All Rights Reserved**
