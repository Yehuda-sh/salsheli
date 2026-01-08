# Month 3: December 2025 - Advanced Features

## Overview

Third month - Yogev creates an event group for his son's birthday, invites a friend (Dani), uses "Who Brings" feature.

---

## Week 1 (Dec 1-7): Creating Event Group

### Day 1 (Monday, Dec 1)

**19:00 - Sara Creates Gift List**
```
שרה:
  - Creates: "מתנות לתומר"
  - Type: event
  - Private list (only she can see)
  - Adds 5 secret gift ideas:
    - לגו נינג'גו x1
    - ספר הארי פוטר x1
    - משחק קופסה x1
    - בגד חדש x1
    - ציוד לכדורגל x1
```

---

### Day 5 (Friday, Dec 5)

**10:00 - Yogev Creates Birthday Group**
```
יוגב:
  - Goes to Groups tab
  - Clicks "+ צור קבוצה"
  - Fills form:
    - Name: "יום הולדת תומר"
    - Type: event
    - Description: "תומר בן 8! 🎂"
    - Emoji: 🎉
  - Group created!
  - Yogev is Owner
```

**10:30 - Inviting Sara**
```
יוגב:
  - In group details
  - Clicks "הזמן חברים"
  - Selects Sara from household
  - Role: Admin
  - Sara automatically added (same household)
```

**11:00 - Inviting Dani**
```
יוגב:
  - Clicks "הזמן חברים"
  - Enters Dani's info:
    - Phone: 052-9876543
    - Role: Viewer
  - Invitation sent via SMS!
```

**11:30 - Dani Receives Invitation**
```
דני:
  - Gets SMS: "יוגב הזמין אותך ליום הולדת תומר"
  - Clicks link
  - Opens Play Store
  - Downloads MemoZap
  - Registers:
    - Name: דני לוי
    - Email: dani@demo.com
  - Sees pending invitation
  - Clicks "אשר"
  - Joined group! (Viewer role)
```

**Data Created:**
- `users/user_dani_001`
- `households/house_dani_001` (Dani's own)
- `groups/grp_birthday_001`
- `group_invites/invite_001` (accepted)

---

### Day 6 (Saturday, Dec 6)

**10:00 - Creating Party Shopping List**
```
יוגב:
  - In birthday group
  - Creates list: "קניות ליום הולדת"
  - Type: event
  - Mode: shopping (regular)
  - Adds 12 items:
    - עוגת יום הולדת x1
    - חטיפים מתוקים x3
    - חטיפים מלוחים x2
    - משקאות קלים x6
    - מיץ x4
    - כוסות חד פעמי x30
    - צלחות חד פעמי x30
    - סכום חד פעמי x30
    - מפיות x50
    - בלונים x20
    - שרשראות x5
    - נרות יום הולדת x1
```

**14:00 - Creating "Who Brings" List**
```
יוגב:
  - Creates another list: "מי מביא מה"
  - Type: event
  - Mode: who_brings
  - Adds items for guests to volunteer:
    - עוגה (needs: 1)
    - סלט פירות (needs: 1)
    - פיצה (needs: 2)
    - בלונים (needs: 1)
    - משקאות (needs: 2)
    - חטיפים (needs: 2)
```

---

### Day 7 (Sunday, Dec 7)

**Morning - Dani Views Lists**
```
דני:
  - Opens app
  - Sees birthday group
  - Views "מי מביא מה" list
  - Can see but not edit (Viewer)
```

---

## Week 2 (Dec 8-14): Preparing

### Day 8 (Monday, Dec 8)

**10:00 - Dani Volunteers**
```
דני:
  - Opens "מי מביא מה"
  - Clicks on "עוגה"
  - Clicks "אני מביא!"
  - His name appears under item

יוגב + שרה:
  - Get notification: "דני מביא עוגה"
```

**14:00 - Collaborative Shopping**
```
יוגב ושרה:
  - Both at supermarket together
  - יוגב starts shopping on "קניות ליום הולדת"
  - שרה joins the session!
  - Both check items in real-time:
    - יוגב: חטיפים, משקאות
    - שרה: כלים חד פעמיים, קישוטים
  - Duration: 35 minutes
  - All items found! ✅
```

---

### Day 10 (Wednesday, Dec 10)

**Evening - More Volunteers**
```
Guest 1 (via SMS link - not registered):
  - Opens link
  - Sees list without registering
  - Selects "פיצה"
  - Enters name: "רונית"
  - Volunteered!

Guest 2:
  - Same process
  - Volunteers for "משקאות"
```

---

### Day 14 (Sunday, Dec 14)

**Morning - Checking Status**
```
יוגב:
  - Opens "מי מביא מה"
  - Status:
    - ✅ עוגה: דני
    - ✅ סלט פירות: שרה
    - ✅ פיצה: רונית (1/2)
    - ❓ פיצה: needs 1 more
    - ✅ בלונים: יוגב
    - ✅ משקאות: אבי (1/2)
    - ❓ משקאות: needs 1 more
    - ❓ חטיפים: needs 2
```

---

### Day 15 (Monday, Dec 15)

**10:00 - Dani Adds More**
```
דני:
  - Opens app
  - Volunteers for "בלונים" too
  - Now bringing: עוגה, בלונים
```

---

## Week 3 (Dec 15-21): Party Week

### Day 18 (Thursday, Dec 18)

**Evening - Final Check**
```
יוגב:
  - All items covered!
  - Status:
    - עוגה: דני ✅
    - סלט פירות: שרה ✅
    - פיצה: רונית, מיכל ✅
    - בלונים: דני ✅
    - משקאות: אבי, דוד ✅
    - חטיפים: יוגב, שרה ✅
```

---

### Day 20 (Saturday, Dec 20) - PARTY DAY! 🎉

**10:00 - Morning Prep**
```
שרה:
  - Makes fruit salad
  - Marks "סלט פירות" as brought ✅

יוגב:
  - Picks up decorations
  - Marks items as ready
```

**12:00 - Guests Arrive**
```
דני:
  - Arrives with cake 🎂
  - Arrives with balloons 🎈
  - Marks his items as brought ✅

Other guests:
  - Mark their items ✅
```

**14:00 - Party! 🎂**
```
- All items delivered
- Party successful!
- Tomer is happy! 🎉
```

---

### Day 21 (Sunday, Dec 21)

**Morning - Post-Party**
```
יוגב:
  - Archives birthday lists
  - Group remains for memories
  - Views statistics:
    - 8 volunteers
    - 15 items brought
    - ₪0 spent on Who Brings items!
```

---

## Week 4 (Dec 22-28): Regular & Year End

### Day 24 (Wednesday, Dec 24)

**Regular Weekly Shopping**
```
יוגב:
  - Back to normal routine
  - Creates: "קניות לסוף שנה"
  - Uses template
  - Shopping as usual
```

---

### Day 28 (Sunday, Dec 28)

**Year-End Review**
```
יוגב:
  - Opens Statistics
  - 3 months of data:

    Lists Created: 18
    ├── Yogev: 12
    ├── Sara: 5
    └── Dani: 1

    Shopping Sessions: 16
    ├── Yogev: 12
    ├── Sara: 4
    └── Dani: 0

    Total Spent: ~₪3,200

    Inventory Items: 65

    Groups: 2
    ├── משפחת כהן (household)
    └── יום הולדת תומר (event)
```

---

## End of Month 3 Summary

### New Features Used
- Group creation (event type)
- Inviting external users (SMS)
- Who Brings feature
- Collaborative shopping (2 people)
- Volunteer tracking
- Guest volunteers (no account)

### Groups

| Group | Type | Members | Owner |
|-------|------|---------|-------|
| משפחת כהן | household | 2 | Yogev |
| יום הולדת תומר | event | 3+ guests | Yogev |

### Birthday Party Stats

- Lists: 2 (Shopping + Who Brings)
- Volunteers: 8 people
- Items covered: 100%
- Cost to Yogev: ~₪200 (decorations, some food)
- Cost to guests: ~₪600 (volunteers)

### All-Time Summary (3 Months)

| Metric | Value |
|--------|-------|
| Users | 3 |
| Lists Created | 18 |
| Shopping Sessions | 16 |
| Items Purchased | ~250 |
| Receipts | 16 |
| Inventory Items | 65 |
| Groups | 2 |
| Total Spent | ~₪3,200 |
