# 🤖 AI Development Guidelines - salsheli Project

> **מטרה:** מדריך טכני מקיף לסוכני AI - טבלת בעיות + Code Review + Modern UI/UX  
> **עדכון:** 17/10/2025 | **גרסה:** 10.0 - Documentation Cleanup & Structure  
> 💡 **לדוגמאות מפורטות:** ראה [LESSONS_LEARNED.md](LESSONS_LEARNED.md)  
> 📁 **למבנה המסמכים המלא:** ראה [DOCS_STRUCTURE.md](DOCS_STRUCTURE.md) ⭐  
> ⚡ **לתשובות מהירות:** ראה [QUICK_REFERENCE.md](QUICK_REFERENCE.md) ⭐ (חדש!)

---

## 📖 ניווט מהיר

**🚀 [Quick Start](#-quick-start)** | **⚡ [Quick Reference](#new-quick-reference)** | **🤖 [AI Instructions](#-הוראות-למערכות-ai)** | **✅ [Code Review](#-code-review-checklist)** | **🎨 [Modern UI/UX](#-modern-uiux-patterns)** | **📊 [Project Stats](#-project-stats)** | **🔗 [Resources](#-למידע-מפורט)**

---

## ⚡ NEW: Quick Reference

**🎯 תשובה תוך 30 שניות - בלי קריאת 15 עמודים!**

→ [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - דוגמה: Dead Code? 3 Steps. Dormant Code? 4 שאלות. Constants? lib/core/. ✅

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
| 🔴 Loading עיגול משעמם       | **Skeleton Screen** במקום!           | [→](#skeleton-screens)                                 |
| 🔴 אין אנימציות              | **Micro Animations** להוספה          | [→](#micro-animations)                                 |
| 🔴 Hardcoded values          | constants מ-lib/core/                | [→](#constants-organization)                           |
| 🔴 Templates לא נטענות       | `npm run create-system-templates`    | [→](#templates-system)                                 |
| 🔴 Access denied שגיאה       | **נתיח מלא מהפרויקט!**               | [QUICK_REFERENCE](QUICK_REFERENCE.md#-file-paths---חשוב-ביותר-) |

---

## 🤖 הוראות למערכות AI

### 1️⃣ התחלת שיחה

**בכל שיחה על הפרויקט:**

```
1. קרא את הקבצים הרלוונטיים (ראה DOCS_STRUCTURE.md)
2. בדוק את השינויים האחרונים
3. שאל מה לעשות היום
```

**✅ דוגמה:**

```
[קורא אוטומטית את הקבצים הרלוונטיים]
מצאתי את העדכונים האחרונים בפרויקט.
במה נעבוד היום?
```

---

### 2️⃣ הפקודות הנחוצות

```bash
# 🔍 Validate paths - בדוק שגיאות נתיבים
npm run validate:paths

# 🧪 Run tests
flutter test                       # All unit tests
flutter test test/widget/         # Widget tests only
flutter test integration_test/     # Integration tests

# 📦 Build
flutter build apk --release
flutter build ios --release

# 📊 Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## ✅ Code Review Checklist

### 🔍 בדיקות אוטומטיות

[See QUICK_REFERENCE.md for quick checks]

---

## 📚 New Files (v9.0)

### ⭐ חדש 15/10/2025!

| קובץ | תוכן | זמן | שימוש |
|------|------|-----|--------|
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | ⚡ תשובות מהירות (30 שניות) | 2 דק' | Dead Code? i18n? File Paths? |
| **[STICKY_NOTES_DESIGN.md](STICKY_NOTES_DESIGN.md)** | 🎨 מערכת עיצוב מלאה + דוגמאות קוד | 10 דק' | StickyButton, StickyCard, Dialog |
| **[DOCS_STRUCTURE.md](DOCS_STRUCTURE.md)** | 📁 מבנה המסמכים המלא | 2 דק' | איזה קובץ לקרוא ומתי |
| **[AnimatedButton.dart](lib/widgets/common/animated_button.dart)** | 🔘 Widget מוכן | - | Copy & Use! |
| **[TappableCard.dart](lib/widgets/common/tappable_card.dart)** | 🃏 Widget מוכן | - | Copy & Use! |
| **[TESTING_GUIDE.md](TESTING_GUIDE.md)** | 🧪 Test Strategy | 10 דק' | Unit + Widget + Integration |
| **[SECURITY_GUIDE.md](SECURITY_GUIDE.md)** | 🔒 Security Best Practices | 10 דק' | Auth + Firestore Rules + Validation |
| **[validate-paths.js](scripts/validate-paths.js)** | 🔍 Path Validator Script | - | `npm run validate:paths` |

---

### 📊 Project Stats

**סה"כ 8 שיפורים בגרסה 10.0:**

- ✅ QUICK_REFERENCE.md - ⚡ 2 דק' ל-30 שניות
- ✅ DOCS_STRUCTURE.md - 📁 מבנה מסמכים ברור
- ✅ AnimatedButton + TappableCard - 🎬 Widgets מוכנים
- ✅ TESTING_GUIDE.md - 🧪 Comprehensive testing
- ✅ SECURITY_GUIDE.md - 🔒 Firebase + Auth
- ✅ validate-paths.js - 🔍 Automated validation
- ✅ Documentation Cleanup - 🗑️ הסרת קבצים כפולים
- ✅ Update AI_DEV_GUIDELINES - 📖 Complete reference

---

## 🔗 למידע מפורט

### 📚 קבצים ייעודיים לפי נושא

| נושא | קובץ | תוכן |
|------|------|------|
| ⚡ **Quick Help** | [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | 2 דק' max answers |
| 📋 **Dead Code** | [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-dead-code-30-שניות) | 3-Step Process |
| 🟡 **Dormant Code** | [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-dormant-code-2-דקות) | 4 Questions Framework |
| 🎨 **Sticky Notes** | [STICKY_NOTES_DESIGN.md](STICKY_NOTES_DESIGN.md) | Code + Design System |
| 🎬 **Animations** | [STICKY_NOTES_DESIGN.md](STICKY_NOTES_DESIGN.md#animations) | AnimatedButton + TappableCard |
| 🧪 **Testing** | [TESTING_GUIDE.md](TESTING_GUIDE.md) | Unit + Widget + Integration |
| 🔒 **Security** | [SECURITY_GUIDE.md](SECURITY_GUIDE.md) | Auth + Rules + Best Practices |
| 💻 **Architecture** | [LESSONS_LEARNED.md](LESSONS_LEARNED.md) | Deep Dives + Patterns |
| 📖 **Best Practices** | [BEST_PRACTICES.md](BEST_PRACTICES.md) | Compact Design + UX |
| 🎨 **Design System** | [STICKY_NOTES_DESIGN.md](STICKY_NOTES_DESIGN.md) | Full Design Spec |
| 📁 **Structure** | [DOCS_STRUCTURE.md](DOCS_STRUCTURE.md) | Documentation map + when to use |

---

**גרסה:** 10.0 - Documentation Cleanup & Structure  
**תאימות:** Flutter 3.27+ | Mobile Only | Node.js 16+  
**עדכון:** 17/10/2025  

**שינויים ב-v9.1 → v10.0 (Documentation Cleanup):**
- ✅ DOCS_STRUCTURE.md - 📁 **חדש!** מבנה מסמכים מלא
- ✅ AI_QUICK_START.md - 🔄 **עודכן** למבנה חדש
- ✅ STICKY_NOTES_EXAMPLES.md - 🗑️ **נמחק** (תוכן עבר ל-DESIGN)
- ✅ WORK_LOG.md - 🗑️ **נמחק** (לא רלוונטי יותר)
- ✅ IMPROVEMENTS_SUMMARY.md - 🗑️ **נמחק** (לא רלוונטי)
- ✅ WELCOME_SCREEN_UPGRADE.md - 🗑️ **נמחק** (ישן)
- ✅ תיקון כל הקישורים השבורים
- ✅ עדכון טבלאות והפניות
- ✅ Documentation cleanup - הסרת כפילויות

**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻
