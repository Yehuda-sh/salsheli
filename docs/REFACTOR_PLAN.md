# תוכנית עבודה: ריפקטור רשימות + דמו דאטה

> תאריך: 16/02/2026
> גרסה: 3.5

---

## 📋 תוכן עניינים

1. [סיכום מנהלים](#סיכום-מנהלים)
2. [סטטוס נוכחי](#-סטטוס-נוכחי-16022026)
3. [החלטות שהתקבלו](#החלטות-שהתקבלו)
4. [שלב 1: Config - שמות ברירת מחדל](#שלב-1-config---שמות-ברירת-מחדל)
5. [שלב 2: Models - הרחבת ShoppingList](#שלב-2-models---הרחבת-shoppinglist)
6. [שלב 3: Repository - שכבת נתונים](#שלב-3-repository---שכבת-נתונים)
7. [שלב 4: Provider - ניהול State](#שלב-4-provider---ניהול-state)
8. [שלב 5: Screens - ממשק משתמש](#שלב-5-screens---ממשק-משתמש)
9. [שלב 6: Strings - תרגומים](#שלב-6-strings---תרגומים)
10. [שלב 7: Auth Flow - זרימת הרשמה](#שלב-7-auth-flow---זרימת-הרשמה)
11. [שלב 8: Demo Data - נתוני בדיקה](#שלב-8-demo-data---נתוני-בדיקה)
12. [שלב 9: בדיקות וסיום](#שלב-9-בדיקות-וסיום)
13. [נספחים](#נספחים)

---

## סיכום מנהלים

### המטרה
הרחבת `ShoppingList` לתמיכה בסקשנים גמישים:
- **מודל אחד** - `ShoppingList` מטפל בכל סוגי הרשימות
- **סקשנים גמישים** - המשתמש בוחר אילו סקשנים להפעיל (קניות, מי מביא מה, משימות, הצבעות)
- **פשטות UX** - הכל במקום אחד, לא צריך לנהל שני דברים נפרדים

### תוצאות צפויות
- UX משופר - רשימה אחת עם סקשנים לפי הצורך
- הוספה מהמזווה לרשימות עם בחירה מרובה
- Cross-list sync - כשקונים מוצר ברשימה אחת, הוא מסומן ברשימות אחרות
- Auth flow שלם - השלמת פרופיל, הזמנות, משק בית
- Demo data מלא - 7 חבילות בדיקה

---

## 📊 סטטוס נוכחי (02/03/2026)

### עבודת הכנה (בוצעה 02-04/02/2026)
ניקויים, תיקוני באגים, והמרות UI שבוצעו **לפני** תחילת 9 השלבים:
- ✅ המרת hardcoded strings → AppStrings (כ-15 מסכים)
- ✅ המרה מ-Sticky Notes/Notebook ל-Material Design (manage_users, pantry)
- ✅ תיקוני באגים (Undo, חיפוש, `_isProcessing`, `_showError`)
- ✅ הסרת haptic מניווטים (רק CTA לפי guardrails)
- ✅ Cache context לפני async gaps
- ✅ מחיקת קוד מת (`smart_suggestions_card`, `quick_add_field`, `upcoming_shop_card`)
- ✅ באנר הזמנות ממתינות + צבעי רשימות ב-Config

### עבודה לאחר תכנון (22/02–02/03/2026)
ניקויים ושיפורים שבוצעו **לאחר** כתיבת התוכנית אבל **לפני** תחילת 9 השלבים:
- ✅ `unified_list_item.dart` v2.2 - הוסרו: `isVoting`, `fromReceiptItem()` (קוד מת)
- ✅ `shopping_lists_repository.dart` v4.0 - נוסף `getListById`, תיעוד מלא, ארגון לפי קטגוריות (22/02)
- ✅ `firebase_shopping_lists_repository.dart` - מימוש `getListById`
- ✅ `voting_screen.dart` - נמחק לחלוטין (968 שורות)
- ✅ `shopping_list_tags.dart` - ווידג'ט תגיות חדש
- ✅ `shopping_list_urgency.dart` - ווידג'ט דחיפות חדש
- ✅ `firestore.rules` - עדכון כללי אבטחה מקיף

### סטטוס 9 השלבים

| שלב | תיאור | סטטוס |
|-----|--------|--------|
| **1** | Config - `defaultListName` | ❌ לא התחיל |
| **2** | Models - `enabledSections`, cross-list sync, sections config | ❌ לא התחיל |
| **3** | Repository - cross-list sync | ❌ לא התחיל |
| **4** | Provider - sync, מזווה→רשימות, template service | ❌ לא התחיל |
| **5** | Screens - מיגרציית eventMode, הוספה מרובה מהמזווה | ❌ לא התחיל |
| **6** | Strings - `sectionPreset*` (עדיין `eventMode*`) | ❌ לא התחיל |
| **7** | Auth Flow - השלמת פרופיל, הזמנות, משק בית | ❌ לא התחיל |
| **8** | Demo Data - חבילות בדיקה | ❌ לא התחיל |
| **9** | בדיקות וסיום | ❌ לא התחיל |

---

## החלטות שהתקבלו

### 1. ארכיטקטורת מודל אחד עם סקשנים
| לפני | אחרי |
|------|------|
| `ShoppingList` - רק פריטי קנייה | `ShoppingList` - עם סקשנים גמישים |

**סקשנים זמינים:**
| סקשן | תיאור | ברירת מחדל |
|------|-------|-------------|
| `shopping` | 🛒 פריטים לקנייה | ✅ תמיד פעיל |
| `assignments` | 👥 מי מביא מה | ⬜ לפי בחירה |
| `voting` | 🗳️ הצבעות | ⬜ לפי בחירה |
| `tasks` | ✅ משימות | ⬜ לפי בחירה |

**דוגמה - רשימת אירוע:**
```
┌─────────────────────────────────────┐
│  🎉 מנגל יום העצמאות                │
│  📆 14/05/2026                       │
├─────────────────────────────────────┤
│                                     │
│  🛒 לקנות:                          │
│  ☐ בשר טחון (2 ק"ג)                 │
│  ☐ פחמים                            │
│  ☐ כוסות חד פעמי                    │
│                                     │
│  👥 מי מביא:                        │
│  ✓ יובל ← סלטים                     │
│  ✓ דני ← שתייה                      │
│  ☐ מיכל ← קינוח                     │
│                                     │
└─────────────────────────────────────┘
```

### 2. שמות ברירת מחדל
| סוג | שם ברירת מחדל |
|-----|---------------|
| supermarket | קניות סופר |
| pharmacy | קניות מרקחת |
| greengrocer | קניות ירקן |
| butcher | קניות אטליז |
| bakery | קניות מאפייה |
| market | קניות שוק |
| household | ציוד לבית |

- **ללא תאריך** בשם ברירת המחדל
- **המשתמש יכול לערוך** את השם
- **לא זוכרים** העדפות קודמות

### 3. סוגי רשימות
- **סוגים קבועים + "אחר"** - המשתמש בוחר מרשימה סגורה, או "אחר" עם שם חופשי

### 4. הוספה מהמזווה לרשימות
- **ידני לגמרי** - המשתמש לוחץ "הוסף לרשימה"
- **בחירה מרובה** - אפשר להוסיף לכמה רשימות במקביל
- **כל פעם מסך בחירה** - לא זוכרים העדפות

### 5. Cross-List Sync (סנכרון בין רשימות)
כשמוצר נקנה ברשימה אחת:
- **לא נמחק** מרשימות אחרות
- **מסומן כ-"נקנה במקום אחר"** עם תאריך ושם הרשימה
- **המשתמש יכול לבטל** אם רוצה לקנות בכל זאת

**דוגמה בUI:**
```
┌─────────────────────────────────────┐
│  🥩 קניות אטליז                     │
│                                     │
│  ☐ סטייק                            │
│  ☐ נקניקיות                         │
│  ─────────────────────────────────  │
│  ✓ בשר טחון                         │
│    📍 נקנה בסופר • 02/02            │
└─────────────────────────────────────┘
```

### 6. Auth Flow - השלמת פרופיל והזמנות
| נושא | החלטה |
|------|--------|
| **טלפון אחרי OAuth** | חובה! מסך "השלם פרופיל" |
| **בדיקת הזמנות** | לפי email + phone |
| **הצטרפות למשפחה** | ארכוב נתונים (לא מיזוג!) |
| **אין הזמנה** | יצירת משק בית אוטומטית |

### 7. סקשנים גמישים
| נושא | החלטה |
|------|--------|
| **מודלים** | מודל אחד (`ShoppingList`) לכל סוגי הרשימות |
| **סקשנים** | המשתמש מפעיל מה שצריך (קניות/מי מביא/הצבעות/משימות) |
| **ברירת מחדל** | רק "פריטים לקנייה" פעיל |
| **לאירועים** | אפשר להוסיף סקשנים נוספים |
| **עריכה** | אפשר להוסיף/להסיר סקשנים בכל עת |

### 8. שימוש במנגנונים קיימים (נוסף 02/02)
| נושא | החלטה |
|------|--------|
| **`eventMode` → `enabledSections`** | מחליפים! `eventMode` יימחק, `enabledSections` יחליף |
| **`ItemKind` חדש** | ❌ לא מוסיפים! משתמשים ב-`itemSubType` הקיים |
| **זיהוי סוג פריט** | `item.isWhoBrings`, `item.isVoting`, `item.isRegularTask` - כבר עובד |
| **מיגרציה** | Helper שממיר `eventMode` ישן ל-`enabledSections` |
| **חיפוש הזמנות** | ✅ מרחיבים `pending_invites_service.dart` קיים (לא יוצרים repository חדש!) |
| **Cross-list + קבלות** | ❌ לא ליצור קבלה כש-item מסומן "נקנה במקום אחר" (מונע כפל בסטטיסטיקות) |
| **ספירת פריטים בדאשבורד** | ✅ לספור הכל - כל הפריטים מכל הסקשנים (לא צריך לשנות קוד) |
| **כפתור פעולה ב-tile** | ✅ לפי עדיפות: shopping > assignments > tasks > voting |
| **UI בחירת סקשנים** | ✅ 3 presets (קנייה רגילה / מי מביא מה / משימות) - פשוט כמו WhatsApp |
| **Backward compatibility** | ✅ ב-`fromJson`: בדוק `enabled_sections` קודם, fallback ל-`migrateEventMode(event_mode)` |
| **template_service.dart** | ✅ `getEventModeForTemplate()` → `getSectionsForTemplate()` מחזיר `List<String>` |

---

## שלב 1: Config - שמות ברירת מחדל

### קבצים לשינוי
| קובץ | שינוי |
|------|-------|
| `lib/config/list_types_config.dart` | הוסף `defaultListName` |

### קוד לדוגמה

```dart
// lib/config/list_types_config.dart

class ListTypeConfig {
  final String key;
  final String emoji;
  final IconData icon;
  final String fullName;      // "סופרמרקט"
  final String shortName;     // "סופר"
  final String defaultListName; // 🆕 "קניות סופר"
  final Color stickyColor;

  const ListTypeConfig({
    required this.key,
    required this.emoji,
    required this.icon,
    required this.fullName,
    required this.shortName,
    required this.defaultListName, // 🆕
    required this.stickyColor,
  });
}

// עדכון הרשימה:
static const List<ListTypeConfig> _types = [
  ListTypeConfig(
    key: 'supermarket',
    emoji: '🛒',
    icon: Icons.shopping_cart,
    fullName: 'סופרמרקט',
    shortName: 'סופר',
    defaultListName: 'קניות סופר', // 🆕
    stickyColor: Color(0xFFFFF59D),
  ),
  ListTypeConfig(
    key: 'pharmacy',
    emoji: '💊',
    icon: Icons.local_pharmacy,
    fullName: 'בית מרקחת',
    shortName: 'מרקחת',
    defaultListName: 'קניות מרקחת', // 🆕
    stickyColor: Color(0xFF80DEEA),
  ),
  // ... המשך לכל הסוגים
];
```

### Acceptance Criteria
- [ ] כל `ListTypeConfig` כולל `defaultListName`
- [ ] `flutter analyze` עובר ללא שגיאות
- [ ] `ListTypes.getByKey('supermarket')?.defaultListName` מחזיר "קניות סופר"

---

## שלב 2: Models - הרחבת ShoppingList

### קבצים לשינוי
| קובץ | פעולה |
|------|-------|
| `lib/models/shopping_list.dart` | ✏️ החלפת `eventMode` ב-`enabledSections` |
| `lib/models/unified_list_item.dart` | ✏️ הוספת שדות cross-list sync בלבד |
| `lib/config/list_sections_config.dart` | 🆕 הגדרת סקשנים |

### 2.1 הגדרת סקשנים (Config חדש)

```dart
// lib/config/list_sections_config.dart

/// סוגי סקשנים ברשימה
enum ListSection {
  shopping,      // 🛒 פריטים לקנייה (ברירת מחדל - תמיד פעיל)
  assignments,   // 👥 מי מביא מה
  voting,        // 🗳️ הצבעות
  tasks,         // ✅ משימות כלליות
}

/// מידע על סקשן
class SectionConfig {
  final ListSection section;
  final String key;
  final String emoji;
  final String displayName;
  final bool isDefault; // האם פעיל כברירת מחדל

  const SectionConfig({
    required this.section,
    required this.key,
    required this.emoji,
    required this.displayName,
    this.isDefault = false,
  });
}

class ListSections {
  static const List<SectionConfig> all = [
    SectionConfig(
      section: ListSection.shopping,
      key: 'shopping',
      emoji: '🛒',
      displayName: 'פריטים לקנייה',
      isDefault: true, // תמיד פעיל
    ),
    SectionConfig(
      section: ListSection.assignments,
      key: 'assignments',
      emoji: '👥',
      displayName: 'מי מביא מה',
    ),
    SectionConfig(
      section: ListSection.voting,
      key: 'voting',
      emoji: '🗳️',
      displayName: 'הצבעות',
    ),
    SectionConfig(
      section: ListSection.tasks,
      key: 'tasks',
      emoji: '✅',
      displayName: 'משימות',
    ),
  ];
}
```

### 2.2 עדכון UnifiedListItem

**✅ שימוש במנגנון קיים:** לא מוסיפים `ItemKind` - משתמשים ב-`itemSubType` שכבר קיים!

```dart
// lib/models/unified_list_item.dart

@JsonSerializable()
class UnifiedListItem {
  // ... שדות קיימים (לא משתנים) ...

  // ✅ כבר קיים ועובד:
  // - item.type (ItemType: product/task)
  // - item.itemSubType (task/whoBrings/voting)
  // - item.isWhoBrings, item.isVoting, item.isRegularTask
  // - item.assignedTo, item.volunteers, item.votesFor/Against

  // 🆕 Cross-List Sync בלבד (שדות חדשים)
  @JsonKey(name: 'bought_elsewhere', defaultValue: false)
  final bool boughtElsewhere;

  @JsonKey(name: 'bought_in_list_id')
  final String? boughtInListId;

  @JsonKey(name: 'bought_in_list_name')
  final String? boughtInListName;

  @JsonKey(name: 'bought_at')
  @NullableTimestampConverter()
  final DateTime? boughtAt;
}
```

**Helper חדש (נוחות):**
```dart
/// מחזיר את סוג הסקשן של הפריט
String get sectionType {
  if (type == ItemType.product) return 'shopping';
  return itemSubType; // task/whoBrings/voting → tasks/assignments/voting
}
```

### 2.3 עדכון ShoppingList

**🔄 מיגרציה:** `eventMode` → `enabledSections`

```dart
// lib/models/shopping_list.dart

@JsonSerializable()
class ShoppingList {
  final String id;
  final String name;

  // === סוג רשימה ===
  final String type;

  // === סטטוס ===
  final String status;

  // ❌ eventMode - נמחק! (היה: 'who_brings'/'shopping'/'tasks')
  // @JsonKey(name: 'event_mode')
  // final String? eventMode;

  // 🆕 === סקשנים פעילים (מחליף את eventMode) ===
  /// ברירת מחדל: ['shopping']
  /// לאירוע עם "מי מביא": ['shopping', 'assignments']
  @JsonKey(name: 'enabled_sections', defaultValue: ['shopping'])
  final List<String> enabledSections;

  // === תקציב ===
  final double? budget;

  // === תאריכים ===
  final DateTime createdDate;
  final DateTime updatedDate;
  final DateTime? targetDate;
  final DateTime? eventDate; // קיים - לאירועים

  // === בעלות ושיתוף ===
  final String createdBy;
  final bool isPrivate;
  final bool isShared;
  final Map<String, SharedUser> sharedUsers;
  final List<PendingRequest> pendingRequests;

  // === פריטים (כל הסקשנים ביחד) ===
  final List<UnifiedListItem> items;

  // === קנייה משותפת ===
  final List<ActiveShopper> activeShoppers;

  // === תבניות ===
  final String? templateId;
  final String format;
  final bool createdFromTemplate;

  // === Helpers ===

  /// פריטי קנייה בלבד (משתמש ב-ItemType הקיים)
  List<UnifiedListItem> get shoppingItems =>
      items.where((i) => i.type == ItemType.product).toList();

  /// פריטי "מי מביא מה" בלבד (משתמש ב-isWhoBrings הקיים)
  List<UnifiedListItem> get assignmentItems =>
      items.where((i) => i.isWhoBrings).toList();

  /// פריטי הצבעה בלבד
  List<UnifiedListItem> get votingItems =>
      items.where((i) => i.isVoting).toList();

  /// משימות רגילות בלבד
  List<UnifiedListItem> get taskItems =>
      items.where((i) => i.isRegularTask).toList();

  /// האם סקשן מסוים פעיל?
  bool hasSectionEnabled(String sectionKey) =>
      enabledSections.contains(sectionKey);
}

/// 🔄 מיגרציה: eventMode → enabledSections
static List<String> migrateEventMode(String? eventMode) {
  switch (eventMode) {
    case 'who_brings':
      return ['shopping', 'assignments'];
    case 'shopping':
      return ['shopping'];
    case 'tasks':
      return ['shopping', 'tasks'];
    default:
      return ['shopping']; // ברירת מחדל
  }
}

// 🔙 Backward Compatibility ב-fromJson:
factory ShoppingList.fromJson(Map<String, dynamic> json) {
  // 1. נסה לקרוא enabled_sections חדש
  List<String>? sections = (json['enabled_sections'] as List?)?.cast<String>();

  // 2. אם אין - נסה למגרר מ-event_mode ישן
  if (sections == null || sections.isEmpty) {
    final oldEventMode = json['event_mode'] as String?;
    sections = migrateEventMode(oldEventMode);
  }

  return ShoppingList(
    // ... שאר השדות ...
    enabledSections: sections,
  );
}
```

### Acceptance Criteria
- [ ] `ListSection` enum נוצר עם 4 סקשנים (config)
- [ ] `ShoppingList.enabledSections` קיים עם ברירת מחדל `['shopping']`
- [ ] `ShoppingList.eventMode` נמחק (או deprecated)
- [ ] `migrateEventMode()` ממיר ערכים ישנים
- [ ] `UnifiedListItem` מכיל שדות cross-list sync חדשים
- [ ] `flutter analyze` עובר
- [ ] JSON serialization עובד (fromJson/toJson)

---

## שלב 3: Repository - שכבת נתונים

### קבצים לשינוי
| קובץ | פעולה |
|------|-------|
| `lib/repositories/shopping_lists_repository.dart` | ✏️ עדכן interface לסקשנים |
| `lib/repositories/firebase_shopping_lists_repository.dart` | ✏️ הוסף cross-list sync + סקשנים |

### 3.1 Cross-List Sync ב-Repository

```dart
// lib/repositories/firebase_shopping_lists_repository.dart

/// מסמן פריט כנקנה ומעדכן רשימות אחרות
Future<void> markItemAsBoughtAndSyncOtherLists({
  required String listId,
  required String itemId,
  required String listName,
  required String userId,
  required String householdId,
}) async {
  final now = DateTime.now();

  // 1. עדכון הפריט ברשימה הנוכחית
  await updateItemInList(
    listId: listId,
    itemId: itemId,
    updates: {
      'is_checked': true,
      'checked_by': userId,
      'checked_at': now,
    },
  );

  // 2. חיפוש אותו פריט ברשימות אחרות
  final otherLists = await _findListsWithSameItem(
    itemName: itemName, // שם המוצר
    excludeListId: listId,
    householdId: householdId,
  );

  // 3. עדכון כל הרשימות האחרות
  for (final otherList in otherLists) {
    await updateItemInList(
      listId: otherList.id,
      itemId: otherList.itemId,
      updates: {
        'is_checked': true,
        'bought_elsewhere': true,
        'bought_in_list_id': listId,
        'bought_in_list_name': listName,
        'bought_at': now,
      },
    );
  }
}
```

### Acceptance Criteria
- [ ] `markItemAsBoughtAndSyncOtherLists` עובד
- [ ] רשימות אחרות מתעדכנות עם `boughtElsewhere=true`
- [ ] `flutter analyze` עובר

---

## שלב 4: Provider - ניהול State

### קבצים לשינוי
| קובץ | פעולה |
|------|-------|
| `lib/providers/shopping_lists_provider.dart` | ✏️ הוסף cross-list sync + ניהול סקשנים |
| `lib/providers/inventory_provider.dart` | ✏️ הוסף הוספה מרובה |
| `lib/services/template_service.dart` | ✏️ החלף `getEventModeForTemplate` → `getSectionsForTemplate` |

### 4.1 Cross-List Sync ב-Provider

```dart
// lib/providers/shopping_lists_provider.dart

/// מסמן פריט כנקנה ומסנכרן עם רשימות אחרות
Future<void> markItemAsBoughtWithSync({
  required String listId,
  required String itemId,
}) async {
  final list = getListById(listId);
  if (list == null) return;

  final item = list.items.firstWhere((i) => i.id == itemId);

  await _repository.markItemAsBoughtAndSyncOtherLists(
    listId: listId,
    itemId: itemId,
    itemName: item.name,
    listName: list.name,
    userId: _userContext.userId!,
    householdId: _userContext.householdId!,
  );

  notifyListeners();
}
```

### 4.2 הוספה מרובה מהמזווה

```dart
// lib/providers/inventory_provider.dart

/// מוסיף פריטי מזווה לרשימות קניות
Future<void> addInventoryItemsToLists({
  required List<String> inventoryItemIds,
  required List<String> listIds,
}) async {
  final itemsToAdd = <UnifiedListItem>[];

  // המרת פריטי מזווה לפריטי רשימה
  for (final itemId in inventoryItemIds) {
    final invItem = getItemById(itemId);
    if (invItem != null) {
      itemsToAdd.add(UnifiedListItem.fromInventoryItem(invItem));
    }
  }

  // הוספה לכל רשימה שנבחרה
  final shoppingProvider = _ref.read(shoppingListsProvider);
  for (final listId in listIds) {
    await shoppingProvider.addItemsToList(
      listId: listId,
      items: itemsToAdd,
    );
  }
}
```

### 4.3 עדכון Template Service

```dart
// lib/services/template_service.dart

// ❌ לפני:
static String? getEventModeForTemplate(String templateId, {required bool isPrivate}) {
  if (!isEventTemplate(templateId)) return null;
  return isPrivate ? 'tasks' : 'who_brings';
}

// ✅ אחרי:
/// מחזיר סקשנים מתאימים לתבנית
static List<String> getSectionsForTemplate(String templateId, {required bool isPrivate}) {
  if (!isEventTemplate(templateId)) {
    return ['shopping']; // ברירת מחדל
  }

  // תבניות אירוע:
  // - פרטי (private) → קנייה + משימות
  // - משותף (shared) → קנייה + מי מביא מה
  return isPrivate
      ? ['shopping', 'tasks']
      : ['shopping', 'assignments'];
}
```

### Acceptance Criteria
- [ ] `markItemAsBoughtWithSync` מעדכן את כל הרשימות
- [ ] `addInventoryItemsToLists` מוסיף לכמה רשימות
- [ ] `getSectionsForTemplate` מחזיר סקשנים נכונים
- [ ] UI מתעדכן אחרי כל פעולה
- [ ] `flutter analyze` עובר

---

## שלב 5: Screens - ממשק משתמש

### קבצים לשינוי
| קובץ | שינוי |
|------|-------|
| `lib/screens/shopping/create/create_list_screen.dart` | 🔴 **מורכב:** מיגרציה `_eventMode` → `_enabledSections`, UI 3 presets, לוגיקת auto-switch |
| `lib/screens/shopping/lists/shopping_lists_screen.dart` | `_getScreenForList` - eventMode → enabledSections |
| `lib/screens/shopping/active/active_shopping_screen.dart` | cross-list sync |
| `lib/screens/shopping/details/shopping_list_details_screen.dart` | UI ל-"נקנה במקום אחר" |
| `lib/screens/pantry/my_pantry_screen.dart` | הוספה מרובה לרשימות |
| `lib/widgets/shopping/shopping_list_tile.dart` | `_getActionButtonConfig` - eventMode → enabledSections |

### 5.1 יצירת רשימה - שם ברירת מחדל

```dart
// lib/screens/shopping/create/create_list_screen.dart

void _onListTypeChanged(String? newType) {
  if (newType == null) return;

  setState(() {
    _selectedType = newType;

    // 🆕 עדכון שם ברירת מחדל
    if (_nameController.text.isEmpty || _isDefaultName) {
      final config = ListTypes.getByKey(newType);
      _nameController.text = config?.defaultListName ?? 'רשימה חדשה';
      _isDefaultName = true;
    }
  });
}

// כשהמשתמש מקליד שם ידני
void _onNameChanged(String value) {
  _isDefaultName = false; // המשתמש שינה, לא לדרוס
}
```

### 5.2 פריט "נקנה במקום אחר"

```dart
// lib/screens/shopping/details/shopping_list_details_screen.dart

Widget _buildItem(UnifiedListItem item) {
  return ListTile(
    leading: Checkbox(
      value: item.isChecked,
      onChanged: (val) => _onItemChecked(item, val),
    ),
    title: Text(
      item.name,
      style: item.isChecked
        ? TextStyle(decoration: TextDecoration.lineThrough)
        : null,
    ),
    // 🆕 הערה אם נקנה במקום אחר
    subtitle: item.boughtElsewhere
      ? Text(
          '📍 נקנה ב${item.boughtInListName} • ${_formatDate(item.boughtAt)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        )
      : null,
  );
}
```

### 5.3 הוספה מהמזווה לרשימות קניות

**שינויים נדרשים ב-`my_pantry_screen.dart`:**

1. **כפתור "הוסף לרשימה" בכל פריט** - long-press על פריט, או אייקון `+` בשורת הפריט
2. **Multi-select mode** - אפשרות לבחור כמה פריטים ואז "הוסף לרשימה"
3. **Bottom Sheet בחירת רשימות** - רשימת רשימות פעילות עם checkboxes

**שינויים נדרשים ב-Model:**
- `UnifiedListItem.fromInventoryItem(InventoryItem)` - factory constructor חדש

**שינויים נדרשים ב-Provider:**
- `InventoryProvider.addInventoryItemsToLists()` או
- `ShoppingListsProvider.addItemsFromPantry()`

```dart
// lib/screens/pantry/my_pantry_screen.dart

void _showAddToListsDialog(List<InventoryItem> selectedItems) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => _AddToListsSheet(
      selectedItems: selectedItems,
      availableLists: context.read<ShoppingListsProvider>().activeLists,
      onConfirm: (selectedListIds) async {
        await context.read<InventoryProvider>().addInventoryItemsToLists(
          inventoryItemIds: selectedItems.map((i) => i.id).toList(),
          listIds: selectedListIds,
        );
        Navigator.pop(ctx);
        _showSuccessSnackbar('נוסף ל-${selectedListIds.length} רשימות');
      },
    ),
  );
}

// Bottom Sheet עם checkboxes לבחירת רשימות
class _AddToListsSheet extends StatefulWidget {
  // ...
}
```

**✅ בוצע (04/02):** תיקוני באגים ב-`my_pantry_screen.dart`:
- תיקון Undo deletion (כפתור ביטול עכשיו משחזר פריט)
- תיקון ניקוי חיפוש (הוספת TextEditingController)
- הסרת `_isProcessing` גלובלי (חסם כל הפעולות)
- המרה מ-Notebook ל-Material Design

### 5.4 יצירת רשימה - מיגרציית eventMode → enabledSections

**📝 שינויים ב-`create_list_screen.dart`:**

```dart
// ❌ לפני - משתנה state:
String? _eventMode;

// ✅ אחרי - משתנה state:
List<String> _enabledSections = ['shopping']; // ברירת מחדל
```

**🔄 לוגיקת auto-switch (שורות 581-588, 649-654):**

```dart
// ❌ לפני:
if (type == ShoppingList.typeEvent) {
  _eventMode = _visibility == ListVisibility.private
      ? ShoppingList.eventModeTasks
      : ShoppingList.eventModeWhoBrings;
} else {
  _eventMode = null;
}

// ✅ אחרי:
if (type == ShoppingList.typeEvent) {
  _enabledSections = _visibility == ListVisibility.private
      ? ['shopping', 'tasks']        // צ'קליסט אישי
      : ['shopping', 'assignments']; // מי מביא מה
} else {
  _enabledSections = ['shopping'];   // רשימת קניות רגילה
}
```

**🎨 UI בחירת סקשנים (3 presets - פשוט!):**

```dart
// שורות 701-755 - במקום 3 כפתורי eventMode, עכשיו 3 presets לסקשנים:

// Preset 1: קנייה רגילה
_SectionPresetOption(
  sections: ['shopping'],
  icon: Icons.shopping_cart,
  title: strings.sectionPresetShopping,       // 'קנייה רגילה'
  description: strings.sectionPresetShoppingDesc, // 'אדם אחד קונה את כל הרשימה'
  isSelected: _enabledSections.length == 1 && _enabledSections.contains('shopping'),
  onTap: () => setState(() => _enabledSections = ['shopping']),
),

// Preset 2: מי מביא מה
_SectionPresetOption(
  sections: ['shopping', 'assignments'],
  icon: Icons.people,
  title: strings.sectionPresetWhoBrings,      // 'מי מביא מה'
  description: strings.sectionPresetWhoBringsDesc, // 'כל משתתף מתנדב להביא פריטים'
  isSelected: _enabledSections.contains('assignments'),
  onTap: () => setState(() => _enabledSections = ['shopping', 'assignments']),
),

// Preset 3: משימות
_SectionPresetOption(
  sections: ['shopping', 'tasks'],
  icon: Icons.checklist,
  title: strings.sectionPresetTasks,          // 'משימות אישיות'
  description: strings.sectionPresetTasksDesc,   // 'צ\'קליסט פשוט רק לי'
  isSelected: _enabledSections.contains('tasks'),
  onTap: () => setState(() => _enabledSections = ['shopping', 'tasks']),
),
```

**🔗 שימוש ב-Template Service:**

```dart
// שורה 261 - כשבוחרים תבנית:
// ❌ לפני:
_eventMode = TemplateService.getEventModeForTemplate(templateId, isPrivate: isPrivate);

// ✅ אחרי:
_enabledSections = TemplateService.getSectionsForTemplate(templateId, isPrivate: isPrivate);
```

### Acceptance Criteria
- [ ] יצירת רשימה מציגה שם ברירת מחדל
- [ ] שינוי סוג משנה את השם (אם לא נערך ידנית)
- [ ] `_eventMode` הוחלף ב-`_enabledSections`
- [ ] לוגיקת auto-switch עובדת (visibility ↔ sections)
- [ ] 3 presets מוצגים ועובדים
- [ ] פריט "נקנה במקום אחר" מציג הערה
- [ ] הוספה מהמזווה תומכת בחירה מרובה
- [ ] `flutter analyze` עובר

---

## שלב 6: Strings - תרגומים

### קובץ לשינוי
| קובץ | שינוי |
|------|-------|
| `lib/l10n/app_strings.dart` | עדכון ומחרוזות חדשות |

### 6.1 מחרוזות לעדכון (שורות 1422-1428 הקיימות)

```dart
// ❌ מחרוזות ישנות להסיר/עדכן:
String get eventModeLabel => 'איך תנהלו את הרשימה?';
String get eventModeWhoBrings => 'מי מביא מה';
String get eventModeWhoBringsDesc => 'כל משתתף מתנדב להביא פריטים';
String get eventModeShopping => 'קנייה רגילה';
String get eventModeShoppingDesc => 'אדם אחד קונה את כל הרשימה';
String get eventModeTasks => 'משימות אישיות';
String get eventModeTasksDesc => 'צ\'קליסט פשוט רק לי';

// ✅ מחרוזות חדשות (מחליפות):
String get sectionPresetLabel => 'איך תנהלו את הרשימה?';
String get sectionPresetShopping => 'קנייה רגילה';
String get sectionPresetShoppingDesc => 'אדם אחד קונה את כל הרשימה';
String get sectionPresetWhoBrings => 'מי מביא מה';
String get sectionPresetWhoBringsDesc => 'כל משתתף מתנדב להביא פריטים';
String get sectionPresetTasks => 'משימות אישיות';
String get sectionPresetTasksDesc => 'צ\'קליסט פשוט רק לי';
```

### 6.2 מחרוזות חדשות

```dart
// lib/l10n/app_strings.dart

class AppStrings {
  // === Cross-List Sync ===
  static const String boughtElsewhere = 'נקנה במקום אחר';
  static String boughtInList(String listName) => 'נקנה ב$listName';
  static String boughtAt(String date) => 'ב-$date';

  // === הוספה מהמזווה ===
  static const String addToLists = 'הוסף לרשימות';
  static const String selectLists = 'בחר רשימות';
  static String addedToLists(int count) => 'נוסף ל-$count רשימות';

  // === יצירת רשימה ===
  static const String shoppingList = 'רשימת קניות';
  static const String eventList = 'רשימת אירוע';
  static const String chooseListType = 'בחר סוג רשימה';

  // === סוגי אירועים ===
  static const String birthdayEvent = 'יום הולדת';
  static const String weddingEvent = 'חתונה';
  static const String partyEvent = 'מסיבה';
  static const String meetingEvent = 'פגישה';
  static const String projectEvent = 'פרויקט';
  static const String otherEvent = 'אחר';

  // === סקשנים (חדש!) ===
  static const String sectionShopping = 'פריטים לקנייה';
  static const String sectionAssignments = 'מי מביא מה';
  static const String sectionVoting = 'הצבעות';
  static const String sectionTasks = 'משימות';
}
```

### Acceptance Criteria
- [ ] כל המחרוזות החדשות קיימות
- [ ] אין hardcoded strings ב-UI
- [ ] `flutter analyze` עובר

---

## שלב 7: Auth Flow - זרימת הרשמה

### סיכום הזרימה

```
פתיחת אפליקציה
       │
       ▼
┌─────────────────┐
│  IndexScreen    │
│  (Splash)       │
└────────┬────────┘
         │
         ▼
    מחובר? ────Yes──► /home
         │
        No
         │
         ▼
  ראה Onboarding? ────No──► WelcomeScreen
         │
        Yes
         │
         ▼
      /login
```

### קבצים לשינוי/ליצור
| קובץ | פעולה |
|------|-------|
| `lib/screens/auth/complete_profile_screen.dart` | 🆕 יצירה |
| `lib/screens/auth/register_screen.dart` | ✏️ הוסף ניתוב ל-CompleteProfile |
| `lib/screens/auth/login_screen.dart` | ✏️ הוסף ניתוב ל-CompleteProfile |
| `lib/providers/user_context.dart` | ✏️ הוסף `needsProfileCompletion` |
| `lib/services/pending_invites_service.dart` | ✏️ הוסף חיפוש לפי phone (email כבר קיים) |

### 7.1 מסך "השלם פרופיל" (חובה אחרי Google/Apple)

**מתי מופיע:**
- אחרי הרשמה/התחברות עם Google או Apple
- כאשר **חסר מספר טלפון**

**שדות:**
- טלפון (חובה!)
- שם מלא (אם חסר)

```dart
// lib/screens/auth/complete_profile_screen.dart

class CompleteProfileScreen extends StatefulWidget {
  final String userId;
  final String? email;
  final String? displayName;

  const CompleteProfileScreen({
    required this.userId,
    this.email,
    this.displayName,
    super.key,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // מילוי שם אם קיים מ-OAuth
    if (widget.displayName != null) {
      _nameController.text = widget.displayName!;
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userContext = context.read<UserContext>();

      // 1. עדכון הפרופיל
      await userContext.updateProfile(
        phone: _phoneController.text.trim(),
        name: _nameController.text.trim(),
      );

      // 2. בדיקת הזמנות ממתינות
      await _checkPendingInvites();

    } catch (e) {
      _showError('שגיאה בשמירת הפרופיל');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkPendingInvites() async {
    final invitesService = context.read<PendingInvitesService>();

    // חיפוש לפי email + phone (מתודה חדשה בservice הקיים)
    final invites = await invitesService.findInvitesByEmailOrPhone(
      email: widget.email,
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (invites.isNotEmpty) {
      // יש הזמנה - הצג דיאלוג
      await _showInviteDialog(invites.first);
    } else {
      // אין הזמנה - צור משק בית חדש
      await _createNewHousehold();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('השלמת פרופיל'),
        automaticallyImplyLeading: false, // אין חזרה - חובה להשלים!
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'כדי להמשיך, נצטרך עוד כמה פרטים',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // שם
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'שם מלא',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v?.isEmpty == true ? 'חובה' : null,
              ),
              const SizedBox(height: 16),

              // טלפון (חובה!)
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'מספר טלפון',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '050-1234567',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v?.isEmpty == true) return 'מספר טלפון הוא שדה חובה';
                  if (!_isValidPhone(v!)) return 'מספר לא תקין';
                  return null;
                },
              ),

              const Spacer(),

              // כפתור המשך
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('המשך'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length >= 9 && cleaned.length <= 10;
  }
}
```

### 7.2 בדיקת הזמנות ממתינות

**לוגיקה:**
1. חיפוש לפי **email** (אם קיים)
2. חיפוש לפי **phone** (אם קיים)
3. אם נמצאה הזמנה → הצג דיאלוג קבלה/דחייה
4. אם אין הזמנה → צור משק בית חדש

```dart
// lib/services/pending_invites_service.dart
// 📝 הוספה לservice הקיים (לא repository חדש!)

/// חיפוש הזמנות לפי email ו/או phone
/// 🆕 מתודה חדשה - מוסיפים לservice הקיים
Future<List<PendingInvite>> findInvitesByEmailOrPhone({
  String? email,
  String? phone,
}) async {
  final results = <PendingInvite>[];

  // חיפוש לפי email
  if (email != null && email.isNotEmpty) {
    final byEmail = await _firestore
        .collectionGroup('pending_invites')
        .where('invited_email', isEqualTo: email.toLowerCase())
        .where('status', isEqualTo: 'pending')
        .get();
    results.addAll(byEmail.docs.map((d) => PendingInvite.fromJson(d.data())));
  }

  // חיפוש לפי phone (אם לא נמצא ב-email)
  if (results.isEmpty && phone != null && phone.isNotEmpty) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final byPhone = await _firestore
        .collectionGroup('pending_invites')
        .where('invited_phone', isEqualTo: cleanPhone)
        .where('status', isEqualTo: 'pending')
        .get();
    results.addAll(byPhone.docs.map((d) => PendingInvite.fromJson(d.data())));
  }

  return results;
}
```

### 7.3 דיאלוג הזמנה למשק בית

```dart
Future<void> _showInviteDialog(PendingInvite invite) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('הוזמנת להצטרף!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${invite.inviterName} מזמין אותך להצטרף למשפחת ${invite.householdName}'),
          const SizedBox(height: 16),
          const Text(
            'אם תצטרף, הנתונים האישיים שלך יועברו לארכיון.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('לא עכשיו'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('הצטרף'),
        ),
      ],
    ),
  );

  if (result == true) {
    await _joinHousehold(invite);
  } else {
    await _createNewHousehold();
  }
}
```

### 7.4 הצטרפות למשק בית קיים

**כאשר משתמש מצטרף למשפחה קיימת:**
- הנתונים האישיים שלו **מועברים לארכיון** (לא נמחקים!)
- הוא מקבל גישה לנתוני המשפחה החדשה
- **אין מיזוג** של נתונים (מונע באגים)

```dart
Future<void> _joinHousehold(PendingInvite invite) async {
  final userContext = context.read<UserContext>();

  // 1. ארכוב הנתונים האישיים (לא מחיקה!)
  await userContext.archivePersonalData();

  // 2. הצטרפות למשק בית
  await userContext.joinHousehold(
    householdId: invite.householdId,
    inviteId: invite.id,
  );

  // 3. ניווט הביתה
  if (mounted) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
```

### 7.5 יצירת משק בית חדש

```dart
Future<void> _createNewHousehold() async {
  final userContext = context.read<UserContext>();

  // יצירת משק בית אוטומטית
  await userContext.createHousehold(
    name: '${_nameController.text} - משפחה',
  );

  // ניווט הביתה
  if (mounted) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
```

### 7.6 עדכון UserContext

```dart
// lib/providers/user_context.dart

/// האם צריך להשלים פרופיל?
bool get needsProfileCompletion {
  if (!isLoggedIn) return false;
  if (currentUser == null) return false;

  // חסר טלפון = צריך להשלים
  return currentUser!.phone == null || currentUser!.phone!.isEmpty;
}

/// ארכוב נתונים אישיים (לפני הצטרפות למשפחה)
Future<void> archivePersonalData() async {
  if (_userId == null) return;

  await _repository.archiveUserData(
    userId: _userId!,
    timestamp: DateTime.now(),
  );
}
```

### תרשים זרימה מלא

```
┌─────────────────────────────────────────────────────────────────┐
│                    Auth Flow - Complete                          │
└─────────────────────────────────────────────────────────────────┘

     פתיחת אפליקציה
            │
            ▼
     ┌─────────────┐
     │ IndexScreen │
     └──────┬──────┘
            │
            ▼
     ┌─────────────┐    Yes    ┌──────────┐
     │  מחובר?     │──────────►│  /home   │
     └──────┬──────┘           └──────────┘
            │ No
            ▼
     ┌─────────────┐    No     ┌───────────────┐
     │ראה Welcome?│──────────►│ WelcomeScreen │
     └──────┬──────┘           └───────┬───────┘
            │ Yes                      │
            ▼                          ▼
     ┌─────────────┐           ┌───────────────┐
     │   /login    │◄──────────│ לחיצה: התחבר  │
     └──────┬──────┘           └───────────────┘
            │
            ▼
     ┌─────────────────────────────────┐
     │         הזדהות                   │
     │  ┌─────────┐   ┌──────────────┐ │
     │  │Email/PW │   │Google/Apple  │ │
     │  └────┬────┘   └──────┬───────┘ │
     └───────┼───────────────┼─────────┘
             │               │
             │               ▼
             │        ┌─────────────────┐
             │        │ חסר טלפון?      │
             │        └────────┬────────┘
             │                 │ Yes
             │                 ▼
             │        ┌─────────────────────┐
             │        │ CompleteProfileScreen│
             │        │  (טלפון + שם)        │
             │        └──────────┬──────────┘
             │                   │
             └─────────┬─────────┘
                       │
                       ▼
              ┌────────────────────┐
              │ בדיקת הזמנות        │
              │ (email + phone)    │
              └─────────┬──────────┘
                        │
           ┌────────────┼────────────┐
           │            │            │
           ▼            │            ▼
    ┌──────────────┐    │    ┌──────────────────┐
    │  נמצאה הזמנה │    │    │  אין הזמנה       │
    └───────┬──────┘    │    └────────┬─────────┘
            │           │             │
            ▼           │             ▼
    ┌──────────────┐    │    ┌──────────────────┐
    │ דיאלוג:      │    │    │ יצירת משק בית    │
    │ הצטרף/דחה   │    │    │ חדש אוטומטית     │
    └──────┬───────┘    │    └────────┬─────────┘
           │            │             │
     ┌─────┴─────┐      │             │
     ▼           ▼      │             │
 ┌───────┐  ┌────────┐  │             │
 │ הצטרף │  │ דחה    │  │             │
 └───┬───┘  └───┬────┘  │             │
     │          │       │             │
     ▼          └───────┼─────────────┤
 ┌─────────────┐        │             │
 │ ארכוב נתונים│        │             │
 │ אישיים      │        │             │
 └──────┬──────┘        │             │
        │               │             │
        ▼               │             │
 ┌──────────────┐       │             │
 │ הצטרפות      │       │             │
 │ למשק בית     │       │             │
 └───────┬──────┘       │             │
         │              │             │
         └──────────────┼─────────────┘
                        │
                        ▼
                 ┌─────────────┐
                 │   /home     │
                 └─────────────┘
```

### Acceptance Criteria
- [ ] `CompleteProfileScreen` נוצר ועובד
- [ ] טלפון הוא שדה **חובה** במסך השלמת פרופיל
- [ ] אחרי Google/Apple נשלח ל-CompleteProfile אם חסר טלפון
- [ ] `findInvites` מחפש לפי email **ו** phone
- [ ] דיאלוג הזמנה מציג אפשרות קבלה/דחייה
- [ ] הצטרפות למשפחה **מארכבת** נתונים (לא מוחקת!)
- [ ] אם אין הזמנה - נוצר משק בית חדש אוטומטית
- [ ] `seenOnboarding` נדלק אחרי login/register מוצלח
- [ ] `flutter analyze` עובר

---

## שלב 8: Demo Data - נתוני בדיקה

### קובץ לשינוי
| קובץ | שינוי |
|------|-------|
| `scripts/demo_data_cohen_family.dart` | הוסף 7 חבילות בדיקה |

### חבילה 1: משתמש Empty State

```dart
// משתמש חדש לגמרי - 0 רשימות, 0 מזווה
const String alonUserId = 'demo_alon_empty_999';
const String alonHouseholdId = 'household_alon_999';

final Map<String, dynamic> alonUser = {
  'id': alonUserId,
  'name': 'אלון דהן',
  'email': 'alon.dahan@demo.com',
  'phone': '0509999999',
  'household_id': alonHouseholdId,
  'seen_onboarding': true,
  // 0 רשימות, 0 מזווה, 0 קבלות
};
```

**מטרה:** בדיקת UI של משתמש חדש לגמרי

### חבילה 2: מצב קנייה משותף

```dart
// יובל ואבי קונים ביחד בסופר
{
  'id': 'list_concurrent_shopping',
  'name': 'קניות שבועיות',
  'type': 'supermarket',
  'status': 'active',
  'active_shoppers': [
    {
      'user_id': yuvalUid,
      'joined_at': now.subtract(Duration(minutes: 15)),
      'is_starter': true,
      'is_active': true,
    },
    {
      'user_id': aviUid,
      'joined_at': now.subtract(Duration(minutes: 8)),
      'is_starter': false,
      'is_active': true,
    },
  ],
  'items': [
    {
      'name': 'חלב',
      'is_checked': true,
      'checked_by': yuvalUid,  // יובל קנה
    },
    {
      'name': 'לחם',
      'is_checked': true,
      'checked_by': aviUid,   // אבי קנה
    },
    {
      'name': 'ביצים',
      'is_checked': false,    // עדיין לא נקנה
    },
  ],
}
```

**מטרה:** בדיקת realtime sync בין 2 קונים

### חבילה 3: רשימות Archived + Overdue

```dart
// רשימה בארכיון
{
  'id': 'list_archived_bbq',
  'name': 'מנגל קיץ 2025',
  'status': 'archived',
  'type': 'supermarket',
}

// רשימה באיחור (target_date עבר)
{
  'id': 'list_overdue_birthday',
  'name': 'יום הולדת לדני',
  'status': 'active',
  'target_date': now.subtract(Duration(days: 3)), // 3 ימים באיחור!
}
```

**מטרה:** בדיקת UI של ארכיון ואיחורים

### חבילה 4: מזווה - פריטים פגי תוקף

```dart
// פריטים עם תאריכי תפוגה שונים
[
  {
    'product_name': 'חלב תנובה 3%',
    'quantity': 1,
    'expiry_date': now.subtract(Duration(days: 1)), // פג אתמול!
  },
  {
    'product_name': 'ביצים',
    'quantity': 6,
    'expiry_date': now, // פג היום!
  },
  {
    'product_name': 'לחם',
    'quantity': 1,
    'expiry_date': now.add(Duration(days: 2)), // פג בעוד יומיים
  },
]
```

**מטרה:** בדיקת התראות תפוגה

### חבילה 5: אירוע עם סקשנים מרובים

```dart
// מנגל עם קניות + מי מביא מה
{
  'id': 'list_bbq_event',
  'name': 'מנגל יום העצמאות',
  'type': 'event',
  'enabled_sections': ['shopping', 'assignments'], // 🆕 סקשנים פעילים
  'event_date': DateTime(2026, 5, 14),
  'items': [
    // פריטי קנייה
    {'name': 'בשר טחון', 'kind': 'shopping', 'is_checked': false},
    {'name': 'פחמים', 'kind': 'shopping', 'is_checked': true},
    {'name': 'כוסות חד פעמי', 'kind': 'shopping', 'is_checked': false},
    // מי מביא מה
    {'name': 'סלטים', 'kind': 'assignment', 'assigned_to': yuvalUid, 'assigned_to_name': 'יובל', 'is_checked': true},
    {'name': 'שתייה', 'kind': 'assignment', 'assigned_to': daniUid, 'assigned_to_name': 'דני', 'is_checked': true},
    {'name': 'קינוח', 'kind': 'assignment', 'assigned_to': michalUid, 'assigned_to_name': 'מיכל', 'is_checked': false},
  ],
}
```

**מטרה:** בדיקת UI של רשימה עם סקשנים מרובים

### חבילה 6: כל סוגי הרשימות

```dart
// רשימות מכל הסוגים
[
  {'type': 'supermarket', 'name': 'קניות סופר'},
  {'type': 'pharmacy', 'name': 'קניות מרקחת'},
  {'type': 'greengrocer', 'name': 'קניות ירקן'},
  {'type': 'butcher', 'name': 'קניות אטליז'},
  {'type': 'bakery', 'name': 'קניות מאפייה'},
  {'type': 'market', 'name': 'קניות שוק'},
  {'type': 'household', 'name': 'ציוד לבית'},
  {'type': 'event', 'name': 'מסיבת יום הולדת'},
]
```

**מטרה:** בדיקת כל סוגי הרשימות

### חבילה 7: Edge Cases

```dart
// Cross-list sync - אותו מוצר ב-2 רשימות
{
  'list_supermarket': {
    'items': [{'name': 'בשר טחון', 'is_checked': false}],
  },
  'list_butcher': {
    'items': [{'name': 'בשר טחון', 'is_checked': false}],
  },
}

// רשימה עם 30 פריטים (performance)
{
  'name': 'רשימה גדולה',
  'items': List.generate(30, (i) => {'name': 'פריט $i'}),
}

// פריט עם שם ארוך (overflow)
{
  'name': 'חלב תנובה טרי 3% אחוז שומן בבקבוק פלסטיק 1 ליטר',
}

// תקציב - קרוב לחריגה
{
  'budget': 100.0,
  'items': [/* סה"כ 95₪ - 95% מהתקציב */],
}
```

**מטרה:** בדיקת מקרי קצה

### Acceptance Criteria
- [ ] כל 7 החבילות נוספו לקובץ הדמו
- [ ] `dart run scripts/demo_data_cohen_family.dart` עובד
- [ ] הנתונים נטענים ב-Emulator
- [ ] ה-UI מציג את כל הסוגים נכון

---

## שלב 9: בדיקות וסיום

### בדיקות לביצוע

```bash
# 1. בדיקת קוד
flutter analyze

# 2. בדיקות יחידה
flutter test

# 3. הרצת הדמו
dart run scripts/demo_data_cohen_family.dart --clean

# 4. הרצת האפליקציה
flutter run
```

### Checklist סופי

- [ ] כל הקבצים עודכנו
- [ ] `flutter analyze` עובר ללא שגיאות
- [ ] `flutter test` עובר
- [ ] הדמו נטען בהצלחה
- [ ] Cross-list sync עובד
- [ ] הוספה מהמזווה עובדת
- [ ] שמות ברירת מחדל מופיעים
- [ ] UI מציג "נקנה במקום אחר"

---

## נספחים

### נספח א: מבנה Firestore

```
/users/{userId}/
  └── private_shopping_lists/{listId}    // רשימות פרטיות (כולל אירועים)

/households/{householdId}/
  └── shopping_lists/{listId}            // רשימות משפחתיות (כולל אירועים)
  └── inventory/{itemId}                 // מזווה
```

### נספח ב: רשימת קבצים לשינוי

#### קבצים לריפקטור (שלבים 1-9)

| שלב | קובץ | פעולה | סטטוס |
|-----|------|-------|--------|
| 1 | `lib/config/list_types_config.dart` | ✏️ הוסף `defaultListName` | ❌ |
| 2 | `lib/config/list_sections_config.dart` | 🆕 חדש | ❌ |
| 2 | `lib/models/shopping_list.dart` | ✏️ `eventMode` → `enabledSections` | ❌ |
| 2 | `lib/models/unified_list_item.dart` | ✏️ שדות cross-list sync | 🔄 ניקוי voting בוצע, cross-list עדיין לא |
| 3 | `lib/repositories/shopping_lists_repository.dart` | ✏️ interface לסקשנים | 🔄 `getListById` נוסף (v4.0), interface לסקשנים עדיין לא |
| 3 | `lib/repositories/firebase_shopping_lists_repository.dart` | ✏️ cross-list sync | 🔄 `getListById` ממומש, cross-list sync עדיין לא |
| 4 | `lib/providers/shopping_lists_provider.dart` | ✏️ `markItemAsBoughtWithSync` | ❌ |
| 4 | `lib/providers/inventory_provider.dart` | ✏️ `addInventoryItemsToLists` | ❌ |
| 4 | `lib/services/template_service.dart` | ✏️ `getEventModeForTemplate` → `getSectionsForTemplate` | ❌ |
| 5 | `lib/screens/shopping/create/create_list_screen.dart` | ✏️ `_eventMode` → `_enabledSections` | ❌ |
| 5 | `lib/screens/shopping/lists/shopping_lists_screen.dart` | ✏️ eventMode → enabledSections | ❌ |
| 5 | `lib/screens/shopping/active/active_shopping_screen.dart` | ✏️ cross-list sync | ❌ |
| 5 | `lib/screens/shopping/details/shopping_list_details_screen.dart` | ✏️ UI "נקנה במקום אחר" | ❌ |
| 5 | `lib/screens/pantry/my_pantry_screen.dart` | ✏️ הוספה מרובה לרשימות | ❌ |
| 5 | `lib/widgets/shopping/shopping_list_tile.dart` | ✏️ eventMode → enabledSections | ❌ |
| 6 | `lib/l10n/app_strings.dart` | ✏️ `eventMode*` → `sectionPreset*` | ❌ |
| 7 | `lib/screens/auth/complete_profile_screen.dart` | 🆕 חדש | ❌ |
| 7 | `lib/screens/auth/register_screen.dart` | ✏️ ניתוב ל-CompleteProfile | ❌ |
| 7 | `lib/screens/auth/login_screen.dart` | ✏️ ניתוב ל-CompleteProfile | ❌ |
| 7 | `lib/providers/user_context.dart` | ✏️ `needsProfileCompletion` | ❌ |
| 7 | `lib/services/pending_invites_service.dart` | ✏️ חיפוש לפי phone | ❌ |
| 8 | `scripts/demo_data_cohen_family.dart` | ✏️ 7 חבילות בדיקה | ❌ |

#### עבודת הכנה (בוצעה 02-04/02/2026)

| קובץ | מה בוצע |
|------|---------|
| `lib/screens/settings/settings_screen.dart` | ✅ תיקון hardcoded strings, הוספת מודול "ניהול משפחה" |
| `lib/l10n/app_strings.dart` | ✅ הוספת מחרוזות התראות, הגדרות כלליות, ניהול משפחה |
| `lib/screens/settings/manage_users_screen.dart` | ✅ תיקון באג _showError(), המרה מ-Sticky Notes ל-Material Design |
| `lib/screens/pantry/my_pantry_screen.dart` | ✅ תיקון 3 באגים (Undo/חיפוש/_isProcessing), המרה מ-Notebook ל-Material Design |
| `lib/screens/home/dashboard/home_dashboard_screen.dart` | ✅ תיקון haptic, באנר הזמנות, ריפקטור צבעי רשימות, תאריך ל-AppStrings |
| `lib/screens/home/dashboard/widgets/pending_invites_banner.dart` | ✅ באנר הזמנות ממתינות חדש |
| `lib/config/list_types_config.dart` | ✅ הוספת צבעים לכל סוג רשימה + `getColor()` מרכזי |
| `lib/screens/home/dashboard/widgets/active_shopper_banner.dart` | ✅ שם קונה, כפתור הצטרפות, כפתור צפייה |
| `lib/screens/home/dashboard/widgets/suggestions_today_card.dart` | ✅ מחרוזות → AppStrings, הסרת haptic |
| `lib/screens/home/dashboard/widgets/upcoming_shop_card.dart` | ✅ נמחק (קוד מת) |
| `lib/screens/home/dashboard/widgets/smart_suggestions_card.dart` | ✅ נמחק (קוד מת) |
| `lib/screens/home/dashboard/widgets/quick_add_field.dart` | ✅ נמחק (הוסר) |
| `lib/screens/onboarding/onboarding_screen.dart` | ✅ מחרוזות → AppStrings, הסרת haptic מניווט |
| `lib/screens/onboarding/widgets/onboarding_steps.dart` | ✅ ~20 מחרוזות → AppStrings, תיקון באג TextEditingController |
| `lib/screens/notifications/notifications_center_screen.dart` | ✅ הסרת haptic מניווט |
| `lib/screens/sharing/invite_users_screen.dart` | ✅ ~10 מחרוזות → AppStrings, Dark Mode fixes |
| `lib/screens/sharing/pending_invites_screen.dart` | ✅ ~20 מחרוזות → AppStrings, cache context |
| `lib/screens/sharing/pending_requests_screen.dart` | ✅ 8 מחרוזות → AppStrings |
| `lib/screens/shopping/checklist/checklist_screen.dart` | ✅ 7 מחרוזות → AppStrings, Dark Mode fixes |
| `lib/screens/shopping/create/contact_selector_dialog.dart` | ✅ ~20 מחרוזות → AppStrings, cache async |
| `lib/screens/shopping/create/create_list_screen.dart` | ✅ cache async (ריפקטור eventMode עדיין ❌) |
| `lib/screens/shopping/active/active_shopping_screen.dart` | ✅ 3 Semantics → AppStrings, הסרת haptic, cache async |

#### עבודה לאחר תכנון (22/02–02/03/2026)

| קובץ | מה בוצע |
|------|---------|
| `lib/models/unified_list_item.dart` | ✅ הוסרו `isVoting` + `fromReceiptItem()` (v2.2, 22/02) |
| `lib/repositories/shopping_lists_repository.dart` | ✅ נוסף `getListById`, תיעוד מלא, ארגון לפי קטגוריות (v4.0, 22/02) |
| `lib/repositories/firebase_shopping_lists_repository.dart` | ✅ מימוש `getListById` |
| `lib/screens/shopping/voting/voting_screen.dart` | ✅ נמחק לחלוטין (968 שורות) |
| `lib/widgets/shopping/shopping_list_tags.dart` | ✅ ווידג'ט תגיות חדש |
| `lib/widgets/shopping/shopping_list_urgency.dart` | ✅ ווידג'ט דחיפות חדש |
| `firestore.rules` | ✅ עדכון כללי אבטחה מקיף |

### נספח ג: רמת מורכבות

| שלב | מורכבות |
|-----|----------|
| שלב 1: Config | נמוכה |
| שלב 2: Models | נמוכה-בינונית (משתמש במנגנונים קיימים) |
| שלב 3: Repository | בינונית-גבוהה |
| שלב 4: Provider | בינונית |
| שלב 5: Screens | גבוהה |
| שלב 6: Strings | נמוכה |
| שלב 7: Auth Flow | בינונית |
| שלב 8: Demo Data | בינונית |
| שלב 9: בדיקות | נמוכה |

---

## היסטוריית שינויים

| תאריך | גרסה | שינוי |
|-------|-------|-------|
| 02/02/2026 | 1.0 | יצירת התוכנית |
| 02/02/2026 | 1.1 | הוספת שלב 7: Auth Flow (השלמת פרופיל, הזמנות, משק בית) |
| 02/02/2026 | 1.2 | שינוי ארכיטקטורה: מודל אחד עם סקשנים גמישים (במקום ShoppingList + EventList) |
| 02/02/2026 | 1.3 | שימוש במנגנונים קיימים: `eventMode`→`enabledSections`, ללא `ItemKind` (יש `itemSubType`) |
| 02/02/2026 | 1.4 | חיפוש הזמנות: הרחבת `pending_invites_service.dart` קיים (במקום יצירת repository חדש) |
| 02/02/2026 | 1.5 | Cross-list sync: לא ליצור קבלה כש-item מסומן "נקנה במקום אחר" |
| 02/02/2026 | 1.6 | Dashboard: לספור כל הפריטים מכל הסקשנים (לא צריך שינוי) |
| 02/02/2026 | 1.7 | הוספת `shopping_list_tile.dart` + כפתור לפי עדיפות סקשנים |
| 02/02/2026 | 1.8 | סריקה מקיפה: הוספת `template_service.dart`, פירוט `create_list_screen.dart`, strings לעדכון, backward compatibility, UI 3 presets |
| 02/02/2026 | 1.9 | שיפורי הגדרות: תיקון hardcoded strings, הוספת מודול "ניהול משפחה" |
| 04/02/2026 | 2.0 | manage_users_screen: תיקון באג _showError() כפול, המרה מ-Sticky Notes ל-Material Design |
| 04/02/2026 | 2.1 | my_pantry_screen: תיקון 3 באגים (Undo/חיפוש/_isProcessing), המרה מ-Notebook ל-Material Design, תכנון "הוסף לרשימה" |
| 04/02/2026 | 2.2 | home_dashboard: תיקון haptic (רק CTA), באנר הזמנות ממתינות, ריפקטור צבעי רשימות ל-ListTypeConfig, תאריך ל-AppStrings |
| 04/02/2026 | 2.3 | active_shopper_banner: הצגת שם קונה בכותרת, כפתור "להצטרף" (שני מינים), כפתור צפייה → active-shopping read-only |
| 04/02/2026 | 2.4 | suggestions_today_card: מחרוזות → AppStrings, צבעים → kStickyOrangeDark, הסרת haptic מ-dismiss. מחיקת upcoming_shop_card (קוד מת). demo_data: תיקון נתיב inventory לאבי (households → users) |
| 04/02/2026 | 2.5 | מחיקת smart_suggestions_card (קוד מת) + quick_add_field (הוסר). onboarding_screen: מחרוזות → AppStrings (stepProgress, stepAccessibilityLabel), הסרת haptic מניווט (לא CTA), ניקוי _haptic() וimports מיותרים |
| 04/02/2026 | 2.6 | onboarding_steps: ~20 מחרוזות hardcoded → AppStrings (משפחה, ילדים, תדירות, סיכום). תיקון באג TextEditingController ב-_ChildForm (TextField → TextFormField+initialValue) |
| 04/02/2026 | 2.7 | notifications_center_screen: הסרת haptic מניווט (לחיצה על התראה = ניווט, לא CTA) |
| 04/02/2026 | 2.8 | invite_users_screen: ~10 מחרוזות hardcoded → AppStrings (אנשי קשר, אישור, הצלחה). Colors.blue → cs.primary, Colors.black → cs.outline (Dark Mode) |
| 04/02/2026 | 2.9 | pending_invites_screen: ~20 מחרוזות hardcoded → AppStrings (כותרת, טעינה, ריק, כרטיס הזמנה, דיאלוג דחייה). Cache context לפני async gaps |
| 04/02/2026 | 3.0 | pending_requests_screen: 8 מחרוזות hardcoded → AppStrings (fallbacks: מנהל, משתמש לא ידוע, פריט לא ידוע, חזור, סוגי בקשות). שימוש חוזר ב-roleAdmin קיים |
| 04/02/2026 | 3.1 | checklist_screen: 7 מחרוזות hardcoded → AppStrings (subtitle, popup menu, progress, empty state). Colors.grey.shade600 → cs.onSurfaceVariant, Colors.amber → StatusColors.warning, הסרת const מ-PopupMenuItem (Dark Mode) |
| 04/02/2026 | 3.2 | contact_selector_dialog: ~20 מחרוזות hardcoded → AppStrings (כותרת, חיפוש, validation, empty states, כפתורים, תפקידים). Cache ScaffoldMessenger לפני async ב-_addByEmail/_addByPhone |
| 04/02/2026 | 3.3 | create_list_screen: Cache ScaffoldMessenger + StatusColors לפני async ב-_selectTemplate(). מסך נקי - כל המחרוזות כבר ב-AppStrings |
| 04/02/2026 | 3.4 | active_shopping_screen: 3 Semantics labels hardcoded → AppStrings. הסרת 3 haptics ניווט (cancel/back). Cache ScaffoldMessenger לפני async ב-_retrySyncAll() |
| 16/02/2026 | 3.5 | סקירת סטטוס: הוספת סקשן "סטטוס נוכחי" עם טבלת מעקב, הפרדת עבודת הכנה מריפקטור בנספח ב', תיקון כפילות חבילה 6→7 |
