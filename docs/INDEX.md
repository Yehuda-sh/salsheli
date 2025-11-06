# 📚 מדריך תיעוד MemoZap - Index

> **גרסה:** 1.0 | **תאריך:** 04/11/2025  
> **מטרה:** ניווט מהיר בין המסמכים

---

## 🗂️ מבנה התיעוד

### 📁 מסמכים חדשים (נקיים מאפס)

| קובץ | מטרה | גודל | מתי להשתמש |
|------|------|------|------------|
| **MCP_GUIDE.md** | טכני - כלי MCP | 539 שורות | כשצריך לדעת איך להשתמש בכלי |
| **CLAUDE_GUIDE.md** | מעשי - עבודה יומית | 310 שורות | הנחיות מהירות לעבודה |
| **INDEX.md** | מפת דרכים | זה הקובץ | איפה למצוא מה |

### 📁 מסמכים קיימים (מהפרויקט)

| קובץ | מטרה | שימוש נוכחי |
|------|------|-------------|
| **CODE.md** | Patterns + Architecture | ⚠️ ישן - לבדיקה |
| **DESIGN.md** | UI/UX + Sticky Notes | ✅ רלוונטי |
| **TECH.md** | Firebase + Models | ✅ רלוונטי |
| **CODE_REVIEW_CHECKLIST.md** | Checklist סקירה | ⚠️ ישן - לבדיקה |
| **WORK_PLAN.md** | Roadmap פרויקט | ✅ רלוונטי |

---

## 🎯 מתי להשתמש במה?

### אני רוצה לדעת...

#### **איך להשתמש בכלי MCP?**
→ `MCP_GUIDE.md`
- קריאת קבצים
- כתיבת קבצים
- חיפוש
- הרצת פקודות
- מלכודות נפוצות

#### **איך לעבוד עם Claude?**
→ `CLAUDE_GUIDE.md`
- פקודות מהירות
- קונבנציות
- Checklist
- דוגמאות

#### **איך לעצב UI?**
→ `DESIGN.md`
- Sticky Notes colors
- Components מוכנים
- RTL
- Dark mode

#### **איך Firebase עובד?**
→ `TECH.md`
- Firestore structure
- Security rules
- Models
- household_id (קריטי!)

#### **מה הסטטוס של הפרויקט?**
→ `WORK_PLAN.md`
- Phase נוכחי
- מה נעשה
- מה נשאר

---

## 🔄 תהליך עבודה מומלץ

### 1️⃣ התחלת Session חדש

```markdown
1. קרא: WORK_PLAN.md → מה הסטטוס?
2. בדוק: Memory entities → מה היה בסשן הקודם?
3. שאל: "מה הצעד הבא?"
```

### 2️⃣ בעבודה על קוד

```markdown
1. לפני כתיבה: DESIGN.md + TECH.md
2. בזמן כתיבה: MCP_GUIDE.md (לכלים)
3. אחרי כתיבה: CODE_REVIEW_CHECKLIST.md
```

### 3️⃣ סיום Session

```markdown
1. עדכן: WORK_PLAN.md (אם רלוונטי)
2. עדכן: Memory entities
3. כתוב: Next Steps ברור
```

---

## 📖 מדריך מהיר לפי נושא

### 🔧 כלים טכניים

| צריך | קובץ | חלק |
|------|------|-----|
| לקרוא קובץ | MCP_GUIDE.md | פעולות קבצים → read_file |
| לכתוב קובץ | MCP_GUIDE.md | פעולות קבצים → write_file |
| לחפש בפרויקט | MCP_GUIDE.md | חיפוש קבצים |
| להריץ פקודה | MCP_GUIDE.md | הרצת פקודות |

### 🎨 עיצוב UI

| צריך | קובץ | חלק |
|------|------|-----|
| צבעים | DESIGN.md | Color Palette |
| כפתור | DESIGN.md | StickyButton |
| כרטיס אינטראקטיבי | DESIGN.md | SimpleTappableCard |
| Loading state | DESIGN.md | SkeletonLoading |
| 4 מצבי UI | DESIGN.md | UI States |

### 🔐 אבטחה

| צריך | קובץ | חלק |
|------|------|-----|
| household_id | TECH.md | Security Rules |
| Firebase Rules | TECH.md | Security Rules |
| 4 רמות הרשאה | TECH.md | Permission Levels |

### 📊 State Management

| צריך | קובץ | חלק |
|------|------|-----|
| Provider pattern | CODE.md | Provider Pattern |
| dispose cleanup | CODE.md | Provider Cleanup |
| Lazy loading | CODE.md | Lazy Loading |

---

## 🚨 בעיות נפוצות

### ❌ "הקובץ לא נוצר"
→ `MCP_GUIDE.md` → מלכודות → create_file

### ❌ "bash_tool לא עובד"
→ `MCP_GUIDE.md` → מלכודות → bash_tool

### ❌ "memory leak ב-Provider"
→ `CODE.md` → Provider Cleanup

### ❌ "חיפוש לא מצא כלום"
→ `MCP_GUIDE.md` → חיפוש קבצים

### ❌ "context crash אחרי await"
→ `CODE.md` → Context After Await

---

## 🔍 חיפוש מהיר

### לפי מילת מפתח:

| מילה | איפה |
|------|------|
| **read_file** | MCP_GUIDE.md |
| **write_file** | MCP_GUIDE.md |
| **start_process** | MCP_GUIDE.md |
| **household_id** | TECH.md, CLAUDE_GUIDE.md |
| **dispose** | CODE.md, CLAUDE_GUIDE.md |
| **StickyButton** | DESIGN.md, CLAUDE_GUIDE.md |
| **const** | CODE.md, CLAUDE_GUIDE.md |
| **Phase 3B** | WORK_PLAN.md |
| **false positive** | MCP_GUIDE.md |

---

## 📝 עדכוני גרסאות

### v1.0 (04/11/2025) - נקי מאפס
- ✅ יצירת MCP_GUIDE.md (539 שורות)
- ✅ יצירת CLAUDE_GUIDE.md (310 שורות)
- ✅ יצירת INDEX.md (זה)
- ✅ מבוסס על בדיקה אמיתית של כלים

### מסמכים קודמים (לבדיקה)
- ⚠️ CODE.md - צריך לבדוק עדכניות
- ⚠️ CODE_REVIEW_CHECKLIST.md - צריך לבדוק עדכניות
- ✅ DESIGN.md - רלוונטי
- ✅ TECH.md - רלוונטי
- ✅ WORK_PLAN.md - רלוונטי

---

## 🎯 מסלולי קריאה מומלצים

### חדש בפרויקט?
1. INDEX.md (זה)
2. WORK_PLAN.md → Current Phase
3. CLAUDE_GUIDE.md → עקרונות יסוד
4. MCP_GUIDE.md → דוגמאות מעשיות

### עובד על Feature חדש?
1. WORK_PLAN.md → Phase רלוונטי
2. DESIGN.md → UI components
3. TECH.md → Firebase structure
4. CODE.md → Patterns

### מתקן Bug?
1. MCP_GUIDE.md → איך לקרוא/לערוך
2. CODE.md → Common Mistakes
3. CODE_REVIEW_CHECKLIST.md → וידוא איכות

### עובד על UI?
1. DESIGN.md → Components + Colors
2. CLAUDE_GUIDE.md → קונבנציות UI
3. MCP_GUIDE.md → איך ליצור קבצים

---

## 🔗 קישורים מהירים

### טכני:
- [פעולות קבצים](MCP_GUIDE.md#פעולות-קבצים)
- [חיפוש](MCP_GUIDE.md#חיפוש-קבצים)
- [PowerShell](MCP_GUIDE.md#הרצת-פקודות-powershell)
- [מלכודות](MCP_GUIDE.md#מלכודות-נפוצות)

### מעשי:
- [פקודות](CLAUDE_GUIDE.md#פקודות-מהירות)
- [Components](CLAUDE_GUIDE.md#קונבנציות-ui)
- [Checklist](CLAUDE_GUIDE.md#checklist-לפני-commit)
- [דוגמה](CLAUDE_GUIDE.md#דוגמה-מלאה-תיקון-bug)

### פרויקט:
- [Roadmap](WORK_PLAN.md)
- [Security](TECH.md#security-rules)
- [UI System](DESIGN.md#sticky-notes-design-system)
- [Patterns](CODE.md)

---

## ✅ Todo - עדכוני תיעוד

### קריטי:
- [ ] בדוק CODE.md - האם עדכני?
- [ ] בדוק CODE_REVIEW_CHECKLIST.md - האם עדכני?
- [ ] מזג מידע רלוונטי למסמכים החדשים

### אופציונלי:
- [ ] הוסף דוגמאות נוספות ל-MCP_GUIDE
- [ ] הוסף screenshots ל-DESIGN
- [ ] צור TROUBLESHOOTING.md נפרד

---

**📍 קובץ:** `C:\projects\salsheli\docs\INDEX.md`  
**🎯 מטרה:** ניווט מהיר ויעיל בתיעוד  
**✍️ נוצר:** 04/11/2025  
**📊 כיסוי:** 5 מסמכים (2 חדשים + 3 קיימים)
