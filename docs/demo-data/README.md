# Demo Data - MemoZap

## Overview

This folder contains:
- User profiles for demo accounts
- 3-month activity timeline
- Ready-to-import JSON files for Firebase

---

## Demo Users

| User | Email | Role | Description |
|------|-------|------|-------------|
| **יוגב כהן** | yogev@demo.com | Admin | Main user, creates lists, shops |
| **שרה כהן** | sara@demo.com | Editor | Spouse, edits lists, shops sometimes |
| **דני לוי** | dani@demo.com | Viewer | Friend, invited to event group only |

---

## Timeline Overview

```
חודש 1 (אוקטובר 2025)
├── שבוע 1: יוגב נרשם, יוצר בית
├── שבוע 2: רשימות ראשונות
├── שבוע 3: שרה מצטרפת
└── שבוע 4: קניות משותפות

חודש 2 (נובמבר 2025)
├── שבוע 1-2: קניות שבועיות
├── שבוע 3: סופ"ש גדול
└── שבוע 4: חנוכה

חודש 3 (דצמבר 2025)
├── שבוע 1: יצירת קבוצת אירוע
├── שבוע 2: הזמנת דני
├── שבוע 3: מסיבה
└── שבוע 4: סיכום
```

---

## Folder Structure

```
docs/demo-data/
├── README.md              ← (הקובץ הזה)
├── users/
│   ├── yogev.md           ← פרופיל יוגב
│   ├── sara.md            ← פרופיל שרה
│   └── dani.md            ← פרופיל דני
├── timeline/
│   ├── month-1.md         ← אוקטובר - התחלה
│   ├── month-2.md         ← נובמבר - שימוש יומיומי
│   └── month-3.md         ← דצמבר - פיצ'רים מתקדמים
└── firebase-data/
    ├── users.json         ← נתוני משתמשים
    ├── households.json    ← נתוני משקי בית
    ├── shopping_lists.json← רשימות קניות
    ├── inventory.json     ← מזווה
    ├── receipts.json      ← קבלות
    └── groups.json        ← קבוצות
```

---

## How to Use

### 1. Read User Profiles
Start with `users/` folder to understand each character.

### 2. Follow Timeline
Read `timeline/` folder chronologically to see how data builds up.

### 3. Import to Firebase
Use files in `firebase-data/` to populate your Firebase instance.

---

## Quick Stats (After 3 Months)

| Metric | יוגב | שרה | דני |
|--------|------|-----|-----|
| Lists Created | 15 | 5 | 0 |
| Shopping Sessions | 12 | 4 | 0 |
| Items Purchased | ~180 | ~45 | 0 |
| Receipts | 16 | 4 | 0 |
| Groups | 2 | 2 | 1 |
