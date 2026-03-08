# 📋 תוכנית ריפקטור — MemoZap (salsheli)

> נוצר: 8 מרץ 2026
> מצב: טיוטה לאישור

---

## 📊 מצב נוכחי

| מדד | ערך |
|-----|-----|
| קבצי Dart | 179 |
| שורות קוד (screens) | 21,385 |
| שורות קוד (widgets) | 14,900 |
| widgets מתים | 18 (6,600 שורות) |
| מחרוזות hardcoded | ~150 |
| סגנונות עיצוב שונים | 5 |
| קבצים מעל 1,000 שורות | 8 |

---

## 🔴 שלב 1 — ניקוי קוד מת (יום 1-2)

> סיכון: אפס. מוחקים רק דברים שלא בשימוש.

### 1.1 מחיקת 18 widgets מתים (~6,600 שורות)

**למחוק:**
```
lib/widgets/common/animated_button.dart         (145 שורות)
lib/widgets/common/benefit_tile.dart            (262 שורות)
lib/widgets/common/dashboard_card.dart          (222 שורות)
lib/widgets/common/offline_banner.dart          (258 שורות)
lib/widgets/common/painters/perforation_painter.dart (70 שורות)
lib/widgets/common/product_image_widget.dart    (211 שורות)
lib/widgets/dev_banner.dart                     (183 שורות)
lib/widgets/dialogs/expiry_alert_dialog.dart    (504 שורות)
lib/widgets/dialogs/inventory_settings_dialog.dart (546 שורות)
lib/widgets/dialogs/legal_content_dialog.dart   (232 שורות)
lib/widgets/dialogs/low_stock_alert_dialog.dart (424 שורות)
lib/widgets/dialogs/recurring_product_dialog.dart (400 שורות)
lib/widgets/dialogs/select_list_dialog.dart     (455 שורות)
lib/widgets/inventory/pantry_filters.dart       (217 שורות)
lib/widgets/inventory/storage_location_manager.dart (1,300 שורות)
lib/widgets/shopping/product_filter_section.dart (864 שורות)
lib/widgets/shopping/shopping_list_tags.dart     (207 שורות)
lib/widgets/shopping/shopping_list_urgency.dart  (114 שורות)
```

**לפני מחיקה — לוודא:**
- [ ] `grep -rl "ClassName" lib/` לכל widget
- [ ] בדוק imports שמפנים לקובץ

### 1.2 מחיקת קוד מת מ-core/ (17 קבועים)

```
ui_constants.dart: kAvatarRadiusSmall, kBorderRadiusSuper, kBorderWidthExtraThick,
  kButtonHeightLarge, kFabMargin, kFieldWidthNarrow, kGlassBlurHigh,
  kHapticFeedbackDelay, kHapticLongPressDelay, kStickyGray
  kMinTouchTarget, kSnackBarDurationShort

constants.dart: isNearLimit(), canAddItem(), getLimitUsage(),
  kChildrenAgeDescriptions
```

### 1.3 הסרת `_getCategoryEmoji` כפול

**מצב נוכחי:** אותו switch מופיע ב-4 מקומות:
1. `product_selection_bottom_sheet.dart`
2. `pantry_product_selection_sheet.dart`
3. `product_filter_section.dart` (נמחק ב-1.1)
4. `my_pantry_screen.dart`

**פתרון:** `filters_config.dart` כבר מגדיר `getCategoryEmoji()` גלובלי.
- [ ] מחק `_getCategoryEmoji` מ-3 הקבצים שנשארו
- [ ] החלף בקריאה ל-`getCategoryEmoji(hebrewCategoryToEnglish(category) ?? 'other')`

---

## 🟡 שלב 2 — איחוד סגנון עיצובי (יום 3-5)

> סיכון: נמוך. שינויים ויזואליים בלבד.

### 2.1 הגדרת "שפת עיצוב" אחידה

**הסגנון הנבחר: Notebook + Sticky (בלי Glass)**

```dart
// כל מסך צריך:
Stack(
  children: [
    const NotebookBackground(),  // 📓 רקע מחברת
    Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, ...),
      body: ...
    ),
  ],
)
```

**למה בלי Glass (BackdropFilter)?**
- כבד על ביצועים (במיוחד רשימות ארוכות)
- 13 מסכים כבר עובדים בלעדיו
- Glass שמור למסכים "מיוחדים" (welcome, loading)

### 2.2 מסכים שצריכים עדכון סגנון

| מסך | מצב נוכחי | שינוי |
|-----|-----------|-------|
| `settings_screen.dart` | 🃏 Cards בלבד | + NotebookBackground + Sticky headers |
| `manage_users_screen.dart` | 🃏 Cards + FAB | + NotebookBackground |
| `checklist_screen.dart` | 📦 Basic | + NotebookBackground + Sticky |
| `contact_selector_dialog.dart` | 📦 Basic | + Sticky colors |
| `register_screen.dart` | 🔮 Glass | לאחד עם login (Notebook+Glass) |
| `my_pantry_screen.dart` | 🔮 Glass בלבד | + NotebookBackground |
| `onboarding_screen.dart` | 📦 Basic | + Sticky colors |
| `shopping_history_screen.dart` | 🃏 Cards | + NotebookBackground |

### 2.3 יצירת widgets משותפים חדשים

#### `lib/widgets/common/app_snackbar.dart`
```dart
// במקום לכתוב בכל מסך:
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('...'), backgroundColor: Colors.green, ...)
);

// נכתוב:
AppSnackBar.success(context, 'נשמר בהצלחה');
AppSnackBar.error(context, 'שגיאה');
AppSnackBar.info(context, 'עודכן');
```

#### `lib/widgets/common/empty_state.dart`
```dart
// widget אחיד ל-"אין תוכן" — במקום לבנות מחדש בכל מסך
EmptyState(
  emoji: '🛒',
  title: 'אין רשימות',
  subtitle: 'צור רשימה חדשה כדי להתחיל',
  action: TextButton(onPressed: ..., child: Text('צור רשימה')),
)
```

#### `lib/widgets/common/section_header.dart`
```dart
// כותרת קטגוריה/סקשן אחידה בסגנון Highlighter
SectionHeader(
  emoji: '🥛',
  title: 'מוצרי חלב',
  count: 3,
  collapsed: false,
  onTap: () => toggle(),
)
```

---

## 🟠 שלב 3 — ריפקטור מבני (יום 5-10)

> סיכון: בינוני. שינויים בקבצים פעילים.

### 3.1 פיצול קבצים ארוכים

| קובץ | שורות | פיצול מוצע |
|------|-------|-----------|
| `active_shopping_screen.dart` | 2,020 | → `active_shopping_screen.dart` (800) + `active_item_tile.dart` (400) + `shopping_progress_header.dart` (200) + `finish_shopping_dialog.dart` (300) |
| `my_pantry_screen.dart` | 1,328 | → `my_pantry_screen.dart` (600) + `pantry_item_card.dart` (300) + `pantry_header.dart` (200) |
| `settings_screen.dart` | 1,219 | → `settings_screen.dart` (400) + `settings_sections/` (5 קבצים × 150) |
| `shopping_lists_screen.dart` | 1,197 | → `shopping_lists_screen.dart` (500) + `list_card.dart` (300) + `lists_filter_bar.dart` (200) |
| `shopping_list_details_screen.dart` | 1,166 | → `details_screen.dart` (500) + `details_item_row.dart` (300) + `details_header.dart` (200) |
| `login_screen.dart` | 1,157 | → `login_screen.dart` (400) + `auth_form.dart` (300) + `social_login_buttons.dart` (200) |
| `create_list_screen.dart` | 1,032 | → `create_list_screen.dart` (500) + `list_type_selector.dart` (300) |

**כלל אצבע:** קובץ > 500 שורות = שקול פיצול. > 800 = חובה.

### 3.2 העברת מחרוזות hardcoded ל-AppStrings

**עדיפות גבוהה (מסכים עם הכי הרבה):**
1. `login_screen.dart` — ~43 מחרוזות
2. `shopping_list_details_screen.dart` — ~42
3. `settings_screen.dart` — ~31
4. `who_brings_screen.dart` — ~16
5. `shopping_summary_screen.dart` — ~15

**סה"כ:** ~150 מחרוזות להעביר

### 3.3 מבנה תיקיות מומלץ

```
lib/screens/
├── auth/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── widgets/               ← חדש: auth form, social buttons
├── home/
│   ├── home_dashboard_screen.dart
│   └── widgets/               ← כבר קיים
├── shopping/
│   ├── active/
│   │   ├── active_shopping_screen.dart
│   │   └── widgets/           ← חדש: item_tile, progress_header
│   ├── lists/
│   │   ├── shopping_lists_screen.dart
│   │   └── widgets/           ← חדש: list_card, filter_bar
│   ├── create/                ← כבר קיים
│   ├── details/
│   │   ├── shopping_list_details_screen.dart
│   │   └── widgets/           ← חדש: item_row, header
│   └── ...
├── pantry/
│   ├── my_pantry_screen.dart
│   └── widgets/               ← חדש: item_card, header
├── settings/
│   ├── settings_screen.dart
│   └── sections/              ← חדש: account, appearance, notifications...
└── ...
```

---

## 🟢 שלב 4 — פיצ'רים חדשים (יום 10+)

> רק אחרי שהבסיס נקי ומסודר.

### 4.1 מזווה → רשימת קניות
- כפתור "חסר? הוסף לרשימה" בכרטיס מוצר במזווה
- בחירת רשימה קיימת או יצירת חדשה
- **ROI גבוה:** מחבר בין שני חלקי האפליקציה

### 4.2 חיפוש מוצרים גלובלי
- שדה חיפוש ב-home שמחפש בכל הרשימות + המזווה + הקטלוג
- "תוצאות: נמצא ברשימת שבועית, יש במזווה (3 יחידות)"

### 4.3 Dark Mode עקבי
- לוודא שכל המסכים תומכים
- Sticky colors ל-dark mode כבר מוגדרים ב-theme

### 4.4 אנימציות מעבר
- Hero animation על מוצרים (מרשימה → פרטים)
- Shared element על כותרות

---

## ⏱️ הערכת זמנים

| שלב | זמן | שורות מושפעות |
|-----|------|--------------|
| 1. ניקוי קוד מת | 1-2 ימים | -6,600 (מחיקה) |
| 2. איחוד סגנון | 2-3 ימים | ~500 (שינוי) |
| 3. ריפקטור מבני | 3-5 ימים | ~5,000 (העברה) |
| 4. פיצ'רים | בהתאם | +2,000 (חדש) |

**סדר עבודה מומלץ:** 1 → 1.3 → 2.3 → 2.2 → 3.1 → 3.2 → 4

---

## ✅ כללי עבודה

1. **commit אחרי כל שינוי** — קל ל-revert
2. **בדוק אמולטור** אחרי כל שלב
3. **לא לשנות לוגיקה** בזמן ריפקטור — רק מבנה ועיצוב
4. **קובץ אחד בכל פעם** — לא לפתוח 10 קבצים במקביל
5. **dart analyze** אחרי כל commit
