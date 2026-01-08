# Month 1: October 2025 - Getting Started

## Overview

First month of using MemoZap. Yogev sets up the account, Sara joins, they start using the app together.

---

## Week 1 (Oct 1-7): Yogev Registers

### Day 1 (Wednesday, Oct 1)

**10:00 - Registration**
```
יוגב:
  - Downloads MemoZap from Play Store
  - Opens app → Welcome Screen
  - Goes through Onboarding:
    - Family size: 4
    - Shopping frequency: 2/week
    - Stores: רמי לוי, שופרסל
    - Has children: Yes
    - Share lists: Yes
  - Registers:
    - Name: יוגב כהן
    - Email: yogev@demo.com
    - Password: ******
  - Account created!
  - Household "משפחת כהן" auto-created
  - Redirected to Home Dashboard
```

**Data Created:**
- `users/user_yogev_001`
- `households/house_cohen_001`

---

### Day 3 (Friday, Oct 3)

**09:00 - First Shopping List**
```
יוגב:
  - Opens app
  - Clicks "+ רשימה חדשה"
  - Creates list:
    - Name: "קניות שבועיות"
    - Type: supermarket
    - Visibility: Household
  - Adds 15 items:
    - חלב 3% x2
    - לחם פרוס x1
    - ביצים L x1
    - גבינה צהובה x1
    - יוגורט x4
    - עגבניות קג x1
    - מלפפונים קג x1
    - תפוחים קג x1
    - בננות קג x1
    - עוף שלם x1
    - פרגיות x0.5
    - אורז 1 קג x1
    - שמן זית x1
    - סוכר x1
    - קפה נמס x1
```

**14:00 - Goes Shopping**
```
יוגב:
  - At רמי לוי
  - Opens list
  - Clicks "התחל קנייה"
  - Timer starts: 00:00:00
  - Checks items as he shops:
    - ✅ חלב 3%
    - ✅ לחם פרוס
    - ✅ ביצים L
    - ... (12 more)
    - ❌ קפה נמס (out of stock)
  - After 35 minutes
  - Clicks "סיים קנייה"
  - Summary:
    - Bought: 14
    - Missing: 1
    - Duration: 35:12
```

**Data Created:**
- `households/house_cohen_001/shared_lists/list_001`
- `households/house_cohen_001/receipts/rcpt_001`
- `households/house_cohen_001/inventory/` (14 items added)

---

## Week 2 (Oct 8-14): Building Routine

### Day 10 (Friday, Oct 10)

**08:30 - Pharmacy List**
```
יוגב:
  - Creates new list:
    - Name: "בית מרקחת"
    - Type: pharmacy
  - Adds 6 items:
    - אקמול x1
    - ויטמין C x1
    - משחת שיניים x2
    - סבון ידיים x2
    - שמפו x1
    - מרכך x1
```

**10:00 - Pharmacy Shopping**
```
יוגב:
  - At סופר-פארם
  - Shopping session: 15 minutes
  - All items found ✅
```

**Data Created:**
- `households/house_cohen_001/shared_lists/list_002`
- `households/house_cohen_001/receipts/rcpt_002`

---

## Week 3 (Oct 15-21): Sara Joins

### Day 15 (Wednesday, Oct 15)

**09:00 - Yogev Invites Sara**
```
יוגב:
  - Goes to Settings → Household
  - Clicks "הזמן חבר"
  - Enters Sara's email: sara@demo.com
  - Role: Admin
  - Sends invitation
```

**14:00 - Sara Receives Invitation**
```
שרה:
  - Downloads MemoZap
  - Registers:
    - Name: שרה כהן
    - Email: sara@demo.com
  - Sees notification: "יוגב הזמין אותך למשפחת כהן"
  - Clicks "אשר"
  - Joins household!
  - Now sees all Yogev's lists
```

**Data Created:**
- `users/user_sara_001`
- `households/house_cohen_001/members/` (Sara added)

---

### Day 17 (Friday, Oct 17)

**09:00 - Weekend Shopping**
```
יוגב:
  - Creates list: "קניות סוף שבוע"
  - Type: supermarket
  - Adds 22 items (big shopping)
```

**10:00 - Sara Adds Items**
```
שרה:
  - Opens the list (sees it in her app)
  - Adds 3 more items:
    - חטיפים לילדים x2
    - מיץ תפוזים x2
    - עוגיות x1
```

**14:00 - Yogev Shops**
```
יוגב:
  - At שופרסל
  - Duration: 45 minutes
  - Bought: 20/22
  - Missing: 2
```

---

### Day 20 (Monday, Oct 20)

**10:00 - Sara's First List**
```
שרה:
  - Creates her first list: "מוצרי ניקיון"
  - Type: household
  - Adds 8 items:
    - אקונומיקה x1
    - מרכך כביסה x1
    - סבון כלים x2
    - מגבות נייר x2
    - שקיות זבל x1
    - ספוגים x1
```

**14:30 - Sara Goes Shopping**
```
שרה:
  - First shopping session
  - Duration: 20 minutes
  - All items found ✅
```

**Data Created:**
- `households/house_cohen_001/shared_lists/list_004` (Sara's list)
- `households/house_cohen_001/receipts/rcpt_004`

---

## Week 4 (Oct 22-28): Regular Use

### Day 24 (Friday, Oct 24)

**09:00 - Greengrocer List**
```
יוגב:
  - Creates list: "ירקות ופירות"
  - Type: greengrocer
  - Adds 10 items:
    - עגבניות שרי x0.5
    - מלפפונים x0.5
    - פלפל אדום x0.3
    - בצל x1
    - שום x0.2
    - תפוחי אדמה x1
    - גזר x0.5
    - לימון x0.3
    - תפוחים x1
    - אבוקדו x0.5
```

**10:30 - Yogev at Market**
```
יוגב:
  - At שוק הכרמל
  - Duration: 20 minutes
  - All fresh! ✅
```

---

### Day 27 (Monday, Oct 27)

**Evening - Checking Pantry**
```
יוגב:
  - Opens Pantry tab
  - Sees inventory:
    - 🥛 חלב 3%: 1 (low!)
    - 🥚 ביצים: 6
    - 🧀 גבינה צהובה: 0.5 (low!)
    - 🍅 עגבניות: plenty
    - ... more items
  - Notices low stock alerts
  - Creates quick list from suggestions
```

---

## End of Month 1 Summary

### Users
- Yogev: Active, 4 shopping sessions
- Sara: Joined, 1 shopping session

### Lists Created
| # | Name | Creator | Type |
|---|------|---------|------|
| 1 | קניות שבועיות | Yogev | supermarket |
| 2 | בית מרקחת | Yogev | pharmacy |
| 3 | קניות סוף שבוע | Yogev | supermarket |
| 4 | מוצרי ניקיון | Sara | household |
| 5 | ירקות ופירות | Yogev | greengrocer |

### Receipts
- Total: 5
- Total spent: ~₪850

### Inventory Status
- Items tracked: 35
- Low stock: 5
- Expired: 0
