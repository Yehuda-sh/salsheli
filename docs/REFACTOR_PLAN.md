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

---

## 🔵 שלב 5 — ריפקטור מודולים (providers / repositories / services)

> סיכון: בינוני-גבוה. לוגיקה עסקית.

### 5.1 מחיקת מודולים מתים (867 שורות)

```
lib/services/contact_picker_service.dart    (464 שורות) — לא מיובא
lib/mixins/connectivity_mixin.dart          (274 שורות) — לא מיובא (offline_banner שמשתמש בו גם מת)
lib/services/prefs_service.dart             (129 שורות) — לא מיובא
```

### 5.2 ניקוי exports מתים ב-config

| קובץ | מה למחוק |
|------|---------|
| `app_config.dart` | `AppEnvironment` enum |
| `list_types_config.dart` | `ListTypeConfig` class, `configKeys` |
| `stores_config.dart` | `StoreInfo` class |
| `storage_locations_config.dart` | `isInvalid` method |
| `filters_config.dart` | `resolved` method |

### 5.3 פיצול `shopping_lists_provider.dart` (1,520 שורות → 3 קבצים)

**הקובץ הכי בעייתי בפרויקט — 35 methods, עושה הכל:**

```
📂 CRUD (7): loadLists, createList, deleteList, restoreList, updateList, retry, clearAll
📂 Items (9): addItemToList, addUnifiedItem, removeItemFromList, updateItemAt, updateItemById,
              toggleAllItemsChecked, updateListStatus, markItemAsChecked, updateItemStatus
📂 Collaborative (5): startCollaborativeShopping, joinCollaborativeShopping,
                       finishCollaborativeShopping, leaveCollaborativeShopping, cleanupAbandonedSessions
📂 Sharing (2): shareListToHousehold, updateUserContext
📂 Query (4): getRecentLists, getById, getListStats, getUnpurchasedItems
📂 Lifecycle (4): archiveList, completeList, activateList, addToNextList
📂 Other (4): חדש, כללי, Function, dispose
```

**פיצול מומלץ:**
```
lib/providers/
├── shopping_lists_provider.dart              (~500 שורות)
│   └── CRUD + Query + Lifecycle + dispose
├── shopping_items_mixin.dart                 (~400 שורות)
│   └── addItem, removeItem, updateItem, toggleAll, updateStatus
└── collaborative_shopping_mixin.dart         (~400 שורות)
    └── start, join, finish, leave, cleanup, shareToHousehold
```

**איך לפצל עם mixins:**
```dart
// shopping_items_mixin.dart
mixin ShoppingItemsMixin on ChangeNotifier {
  // כל ה-methods שקשורים לפריטים
}

// collaborative_shopping_mixin.dart
mixin CollaborativeShoppingMixin on ChangeNotifier {
  // כל ה-methods שקשורים לקניות שיתופיות
}

// shopping_lists_provider.dart
class ShoppingListsProvider extends ChangeNotifier
    with ShoppingItemsMixin, CollaborativeShoppingMixin {
  // CRUD + Query + Lifecycle בלבד
}
```

### 5.4 פיצול `auth_service.dart` (1,159 שורות → 2 קבצים)

```
lib/services/
├── auth_service.dart           (~600 שורות) — login, register, session, password
└── social_auth_service.dart    (~500 שורות) — Google Sign-In, Apple Sign-In
```

### 5.5 providers אחרים לשיפור

| Provider | שורות | בעיה | המלצה |
|----------|-------|------|-------|
| `user_context.dart` | 704 | auth + theme + preferences מעורבבים | פצל: auth ב-provider, theme/prefs ב-service |
| `inventory_provider.dart` | 737 | סביר | ✅ בינתיים OK |
| `products_provider.dart` | 592 | 3 repos שונים | ✅ הגיוני (local + firebase + interface) |

### 5.6 Repositories — מצב

**✅ מבנה מצוין — Repository Pattern נכון:**

| Domain | Interface | Firebase Impl | Local Impl | סה"כ |
|--------|-----------|--------------|------------|------|
| shopping_lists | ✅ 351 | ✅ 826 | — | 1,177 |
| inventory | ✅ 175 | ✅ 655 | — | 830 |
| user | ✅ 383 | ✅ 609 | — | 992 |
| products | ✅ 178 | ✅ 429 | ✅ 282 | 889 |
| receipt | ✅ 184 | ✅ 288 | — | 472 |
| locations | ✅ 117 | ✅ 145 | — | 262 |
| **shared** | — | — | — | 175 |
| **סה"כ** | | | | **4,797** |

**ממצאים:**
- כל domain יש interface + Firebase implementation ✅
- products הוא היחיד עם local impl (לטעינת JSON) ✅
- `repository_constants.dart` — collection names מרוכזים ✅
- `firestore_utils.dart` — helpers משותפים ✅
- **אין צורך בריפקטור** — הארכיטקטורה נקייה 👏

### 5.7 Models — שיפורים קטנים

| Model | בעיה | פתרון |
|-------|------|-------|
| `selected_contact.dart` | חסר `fromMap`/`toMap` | להוסיף (אם נשמר ב-Firestore) |

---

## ⏱️ הערכת זמנים

| שלב | זמן | שורות מושפעות |
|-----|------|--------------|
| 1. ניקוי קוד מת | 1-2 ימים | -6,600 (מחיקה) |
| 2. איחוד סגנון | 2-3 ימים | ~500 (שינוי) |
| 3. ריפקטור מבני | 3-5 ימים | ~5,000 (העברה) |
| 4. פיצ'רים | בהתאם | +2,000 (חדש) |
| 5. ריפקטור מודולים | 2-3 ימים | ~2,400 (פיצול + מחיקה) |
| 6. ליטוש מקצועי + UX | 5-7 ימים | ~3,000 (שיפור + חדש) |

**סדר עבודה מומלץ:** 1 → 5.1 → 5.2 → 1.3 → **6.1** → **6.2** → 2.3 → 2.2 → **6.7** → 3.1 → 5.3 → 5.4 → 3.2 → **6.3** → **6.4** → **6.6** → **6.5** → 4

### 📊 סיכום כולל — קוד מת

| מקור | קבצים/פריטים | שורות |
|------|-------------|-------|
| widgets מתים | 18 קבצים | 6,600 |
| מחרוזות מתות (l10n) | 233 מחרוזות | 271 (כבר נמחקו ✅) |
| מודולים מתים | 3 קבצים | 867 |
| קבועים מתים (core) | 17 קבועים | ~50 |
| config exports מתים | 5 פריטים | ~80 |
| **סה"כ למחיקה** | | **~7,600 שורות** |

---

---

## ⭐ שלב 6 — ליטוש מקצועי + UX (מה שהמשתמש באמת מרגיש)

> המטרה: שהאפליקציה **תרגיש** כמו אפליקציה של חברה גדולה, לא פרויקט צד.

### 📊 UX Audit — מצב נוכחי

| תחום | ציון | הערה |
|------|------|------|
| Loading states | ✅ 28 | מצוין |
| Error handling | ✅ 57 | מצוין |
| Empty states | ✅ 34 | מצוין |
| Animations | ✅ 29 | טוב |
| Haptic feedback | ✅ 86 | מצוין! |
| Pull to refresh | ✅ 6 | טוב |
| Shimmer/Skeleton | ✅ 17 | מצוין |
| Undo actions | ✅ 12 | טוב |
| Responsive layout | ✅ 248 | מצוין |
| Text overflow | ✅ 103 | מצוין |
| Keyboard handling | ✅ 83 | מצוין |
| Swipe actions | ✅ 18 | טוב |
| **Hero animations** | **❌ 0** | חסר לגמרי |
| **Page transitions** | **❌ 0** | ברירת מחדל בלבד |
| **Lottie/Rive** | **❌ 0** | אין אנימציות מורכבות |
| **AnimatedList** | **❌ 0** | רשימות לא מונפשות |
| **Slivers** | **❌ 0** | אין collapsing headers |
| **Platform-specific** | **❌ 2** | iOS ו-Android נראים אותו דבר |

### ⚠️ בעיות עקביות (מה שהורס תחושת מקצועיות)

#### 🔴 1. צבעים ישירים — 316 שימושים ב-`Colors.xxx`!
```
במקום: Colors.green, Colors.red.shade100, Colors.grey[300]
צריך:  cs.primary, cs.error, cs.surfaceVariant
```
**למה זה רע:** כל מסך נראה קצת אחרת. Dark mode נשבר.

#### 🔴 2. Border radius — 11 ערכים שונים!
```
נמצא: 2, 3, 4, 6, 8, 10, 12, 14, 16, 20, 24
צריך:  kRadiusS (8), kRadiusM (12), kRadiusL (16), kRadiusXL (24)
```
**למה זה רע:** כפתורים/כרטיסים מרגישים לא אחידים.

#### 🔴 3. Font sizes — 18 גדלים שונים!
```
נמצא: 9, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24, 26, 28, 32, 36, 40, 48
צריך:  Theme.of(context).textTheme.bodySmall / bodyMedium / titleLarge / etc.
```
**למה זה רע:** היררכיה טיפוגרפית לא עקבית.

### 🎯 6.1 Design Tokens — מערכת עיצוב אחידה

צור `lib/theme/design_tokens.dart`:
```dart
/// 🎨 Design Tokens — מקום אחד לכל ערכי העיצוב
class AppTokens {
  AppTokens._();

  // ═══ Spacing ═══
  static const spacing4  = 4.0;
  static const spacing8  = 8.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;

  // ═══ Border Radius ═══
  static const radiusS  = 8.0;   // כפתורים, chips
  static const radiusM  = 12.0;  // כרטיסים, inputs
  static const radiusL  = 16.0;  // bottom sheets, dialogs
  static const radiusXL = 24.0;  // cards מיוחדים

  // ═══ Font Sizes (fallback — prefer TextTheme) ═══
  static const fontXS = 11.0;
  static const fontS  = 13.0;
  static const fontM  = 15.0;
  static const fontL  = 18.0;
  static const fontXL = 22.0;
  static const fontXXL = 28.0;

  // ═══ Durations ═══
  static const durationFast   = Duration(milliseconds: 200);
  static const durationMedium = Duration(milliseconds: 350);
  static const durationSlow   = Duration(milliseconds: 500);

  // ═══ Elevation ═══
  static const elevationNone = 0.0;
  static const elevationLow  = 2.0;
  static const elevationMed  = 4.0;
  static const elevationHigh = 8.0;
}
```

### 🎯 6.2 החלפת 316 × `Colors.xxx` → Theme

**עדיפות:** מסכים ראשיים קודם:
1. `active_shopping_screen.dart`
2. `shopping_lists_screen.dart`
3. `home_dashboard_screen.dart`
4. `my_pantry_screen.dart`
5. `settings_screen.dart`

**Pattern:**
```dart
// לפני:
color: Colors.green

// אחרי:
final cs = Theme.of(context).colorScheme;
color: cs.primary  // או cs.error, cs.surface, etc.

// Sticky colors (מותג):
final brand = Theme.of(context).extension<AppBrand>()!;
color: brand.stickyYellow
```

### 🎯 6.3 אנימציות שעושות הבדל

#### Page Transitions (כל הניווטים)
```dart
// lib/theme/app_page_transitions.dart
class AppPageTransition extends PageRouteBuilder {
  AppPageTransition({required Widget page})
    : super(
        transitionDuration: AppTokens.durationMedium,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      );
}
```

#### AnimatedList (רשימת קניות)
```dart
// כשמוסיפים מוצר — הוא נכנס עם אנימציה
// כשמסירים — יוצא עם slide
AnimatedList(
  key: _listKey,
  itemBuilder: (context, index, animation) =>
    SizeTransition(sizeFactor: animation, child: ...),
)
```

#### Hero Animation (מוצר → פרטים)
```dart
// ברשימה:
Hero(tag: 'product-${item.id}', child: ProductTile(...))

// בפרטים:
Hero(tag: 'product-${item.id}', child: ProductHeader(...))
```

#### Collapsing AppBar עם Slivers
```dart
// מסכי רשימה עם header שמתכווץ בגלילה
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('רשימת קניות'),
        background: NotebookHeader(),
      ),
    ),
    SliverList(delegate: ...),
  ],
)
```

### 🎯 6.4 Platform-Specific Polish

```dart
// iOS: Cupertino dialogs, swipe-back, bounce scroll
// Android: Material dialogs, predictive back, glow scroll

showAdaptiveDialog(
  context: context,
  builder: (_) => AlertDialog.adaptive(
    title: Text('מחיקה'),
    content: Text('בטוח?'),
    actions: [
      adaptiveAction(context, 'ביטול', () => Navigator.pop(context)),
      adaptiveAction(context, 'מחק', () => delete(), isDestructive: true),
    ],
  ),
);
```

### 🎯 6.5 Lottie Animations (ליטוש אחרון)

**איפה Lottie עושה הבדל:**
- ✅ סיום קניות — אנימציית "כל הכבוד!" (confetti)
- ✅ רשימה ריקה — אנימציית עגלה ריקה
- ✅ Onboarding — אנימציות בכל שלב
- ✅ Loading — לוגו מונפש במקום spinner

**מקורות חינמיים:** lottiefiles.com (אלפי אנימציות JSON קלות)

### 🎯 6.6 Micro-interactions שעושות "wow"

| פעולה | אפקט |
|-------|-------|
| מוסיף מוצר לרשימה | bounce-in + haptic |
| מסמן "קניתי" | ✅ check animation + strikethrough |
| מוחק מוצר | slide-out + undo snackbar |
| pull-to-refresh | custom indicator עם לוגו |
| גלילה לסוף | "הכל פה!" micro-animation |
| רשימה חדשה | scale-up entrance |
| שיתוף רשימה | confetti/celebration |

### 🎯 6.7 Typography — מערכת אחידה

```dart
// במקום fontSize: 14 בכל מקום:
Text('כותרת', style: context.textTheme.titleMedium)
Text('תוכן', style: context.textTheme.bodyMedium)
Text('הערה', style: context.textTheme.bodySmall)

// Extension לנוחות:
extension ContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  AppBrand get brand => Theme.of(this).extension<AppBrand>()!;
}
```

---

## ⏱️ הערכת זמנים (כולל שלב 6)

1. **commit אחרי כל שינוי** — קל ל-revert
2. **בדוק אמולטור** אחרי כל שלב
3. **לא לשנות לוגיקה** בזמן ריפקטור — רק מבנה ועיצוב
4. **קובץ אחד בכל פעם** — לא לפתוח 10 קבצים במקביל
5. **dart analyze** אחרי כל commit
