# 🤖 AI Development Guidelines - salsheli Project

> **מטרה:** מדריך טכני מקיף לסוכני AI - טבלת בעיות + Code Review + Modern UI/UX  
> **עדכון:** 15/10/2025 | **גרסה:** 9.0 - Complete Resource Suite (חדש! 15/10/2025 ⭐)  
> 💡 **לדוגמאות מפורטות:** ראה [LESSONS_LEARNED.md](LESSONS_LEARNED.md)  
> 🤖 **להוראות התנהגות סוכן:** ראה [AI_QUICK_START.md](AI_QUICK_START.md) ⭐  
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
1. קרא WORK_LOG.md
2. הצג סיכום (2-3 שורות) של העבודה האחרונה
3. שאל מה לעשות היום
```

**✅ דוגמה:**

```
[קורא אוטומטית]
בשיחה האחרונה: Templates System Phase 2 Complete + 6 תבניות מערכת.
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
| **[AnimatedButton.dart](lib/widgets/common/animated_button.dart)** | 🔘 Widget מוכן | - | Copy & Use! |
| **[TappableCard.dart](lib/widgets/common/tappable_card.dart)** | 🃏 Widget מוכן | - | Copy & Use! |
| **[TESTING_GUIDE.md](TESTING_GUIDE.md)** | 🧪 Test Strategy | 10 דק' | Unit + Widget + Integration |
| **[SECURITY_GUIDE.md](SECURITY_GUIDE.md)** | 🔒 Security Best Practices | 10 דק' | Auth + Firestore Rules + Validation |
| **[validate-paths.js](scripts/validate-paths.js)** | 🔍 Path Validator Script | - | `npm run validate:paths` |

---

### 📊 Project Stats

**סה"כ 7 שיפורים בגרסה 9.0:**

- ✅ QUICK_REFERENCE.md - ⚡ 2 דק' ל-30 שניות
- ✅ STICKY_NOTES_EXAMPLES.md - 🎨 דוגמאות חיות
- ✅ AnimatedButton + TappableCard - 🎬 Widgets מוכנים
- ✅ TESTING_GUIDE.md - 🧪 Comprehensive testing
- ✅ SECURITY_GUIDE.md - 🔒 Firebase + Auth
- ✅ validate-paths.js - 🔍 Automated validation
- ✅ Update AI_DEV_GUIDELINES - 📖 Complete reference

---

## 🔗 למידע מפורט

### 📚 קבצים ייעודיים לפי נושא

| נושא | קובץ | תוכן |
|------|------|------|
| ⚡ **Quick Help** | [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | 2 דק' max answers |
| 📋 **Dead Code** | [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-dead-code-30-שניות) | 3-Step Process |
| 🟡 **Dormant Code** | [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-dormant-code-2-דקות) | 4 Questions Framework |
| 🎨 **Sticky Notes** | [STICKY_NOTES_EXAMPLES.md](STICKY_NOTES_EXAMPLES.md) | Code + Design System |
| 🎬 **Animations** | [STICKY_NOTES_EXAMPLES.md](STICKY_NOTES_EXAMPLES.md#-דוגמה-2-tappable-card) | AnimatedButton + TappableCard |
| 🧪 **Testing** | [TESTING_GUIDE.md](TESTING_GUIDE.md) | Unit + Widget + Integration |
| 🔒 **Security** | [SECURITY_GUIDE.md](SECURITY_GUIDE.md) | Auth + Rules + Best Practices |
| 💻 **Architecture** | [LESSONS_LEARNED.md](LESSONS_LEARNED.md) | Deep Dives + Patterns |
| 📖 **Best Practices** | [BEST_PRACTICES.md](BEST_PRACTICES.md) | Compact Design + UX |
| 🎨 **Design System** | [STICKY_NOTES_DESIGN.md](STICKY_NOTES_DESIGN.md) | Full Design Spec |
| 📰 **History** | [WORK_LOG.md](WORK_LOG.md) | All changes + decisions |

---

**גרסה:** 9.0 - Complete Resource Suite (1700+ שורות)  
**תאימות:** Flutter 3.27+ | Mobile Only | Node.js 16+  
**עדכון:** 15/10/2025  

**שינויים ב-v9.0 → v9.1 (Merged & Cleaned):**
- ✅ QUICK_REFERENCE.md - ⚡ עדיף ל-quick questions
- ✅ STICKY_NOTES_DESIGN.md - 🎨 עכשיו כולל דוגמאות קוד מלאות!
- ✅ STICKY_NOTES_EXAMPLES.md - 🗑️ **מחוק** (תוכן עבור ל-DESIGN)
- ✅ AI_QUICK_START.md - 🗑️ **מחוק** (תוכן עבור ל-QUICK_REFERENCE)
- ✅ IMPROVEMENTS_SUMMARY.md - 🗑️ **מחוק** (לא רלוונטי)
- ✅ WELCOME_SCREEN_UPGRADE.md - 🗑️ **מחוק** (ישן)
- ✅ AnimatedButton + TappableCard - 🔌 Ready to use
- ✅ TESTING_GUIDE.md - 🧪 Unit/Widget/Integration examples
- ✅ SECURITY_GUIDE.md - 🔒 Complete auth + rules
- ✅ validate-paths.js - 🔍 Automate validation
- ✅ Update AI_DEV_GUIDELINES - 📑 v9.1 with merged content

**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻
