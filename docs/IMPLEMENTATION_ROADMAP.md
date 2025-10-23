# 📋 תוכנית משימות - MemoZap

> **תאריך:** 23/10/2025  
> **גרסה:** 1.4 - מסלול 2 הושלם במלואו! 🎉  
> **בסיס:** UX_REQUIREMENTS.md + TASK_SUPPORT_OPTIONS.md

---

## 🎯 מבט על

### סה"כ פרויקט:

```
📊 3 מסלולים מרכזיים:
1️⃣ Tasks + Products (אופציה D - Hybrid)
2️⃣ שיתוף משתמשים (4 הרשאות)
3️⃣ UX חדש (מסך ראשי + המלצות)

⏱️ זמן משוער: 5-6 שבועות עבודה מלאים
```

---

## 📅 מסלול 1: Tasks + Products (Hybrid) ✅ הושלם 22/10/2025

### ⏱️ זמן: 7-10 ימי עבודה → **הושלם!**

### יעדים:
- ✅ תמיכה ברשימות מעורבות (משימות + מוצרים)
- ✅ אופציה D (Hybrid) מ-TASK_SUPPORT_OPTIONS.md

---

### שלב 1.1: Models + Migration (2 ימים) ✅ הושלם

**קבצים:**
- ✅ `lib/models/unified_list_item.dart` (חדש) - **הושלם**
- ✅ `lib/models/enums/item_type.dart` (חדש) - **הושלם**
- ✅ עדכון `lib/models/shopping_list.dart` - **הושלם**

**מה לעשות:**
1. צור `UnifiedListItem`:
   - שדות משותפים: id, name, type, isChecked, category, notes
   - `productData: Map<String, dynamic>?` (quantity, unitPrice, barcode, unit)
   - `taskData: Map<String, dynamic>?` (dueDate, assignedTo, priority)
   - Helpers: quantity, totalPrice, dueDate, isUrgent
   - Factory constructors: `.product()`, `.task()`
   - Migration: `.fromReceiptItem()`

2. עדכן `ShoppingList`:
   - החלף `List<ReceiptItem>` ב-`List<UnifiedListItem>`
   - הוסף helpers: `products`, `tasks`, `productCount`, `taskCount`

3. רוץ build_runner:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

---

### שלב 1.2: Repository + Provider (2 ימים) ✅ הושלם

**קבצים:**
- ✅ `lib/repositories/shopping_lists_repository.dart` (עדכון) - **הושלם**
- ✅ `lib/repositories/firebase_shopping_lists_repository.dart` (עדכון) - **הושלם**
- ✅ `lib/providers/shopping_lists_provider.dart` (עדכון) - **הושלם**

**מה לעשות:**
1. Repository:
   - עדכן signatures: `List<ReceiptItem>` → `List<UnifiedListItem>`
   - בדוק queries ל-Firestore

2. Provider:
   - עדכן logic: הוספה/עריכה/מחיקה
   - הוסף methods לטיפול בשני סוגים

3. בדיקות:
   - Unit tests למודלים
   - Unit tests ל-repository

---

### שלב 1.3: UI Updates (3-4 ימים) ✅ הושלם

**קבצים:**
- ✅ `lib/screens/shopping/shopping_list_details_screen.dart` (עדכון) - **הושלם**
- ✅ `lib/widgets/add_item_dialog.dart` (חדש/עדכון) - **הושלם**
- ✅ `lib/widgets/add_task_dialog.dart` (חדש) - **הושלם**

**מה לעשות:**
1. Details Screen:
   - תמיכה בשני סוגי items
   - איקונים שונים (🛒 vs ✅)
   - צבעים שונים (kStickyYellow vs kStickyCyan)
   - subtitle שונה (מחיר vs תאריך יעד)

2. Dialogs:
   - Dialog להוספת מוצר (קיים - צריך עדכון קל)
   - Dialog להוספת משימה (חדש!)

3. Widget tests

---

### שלב 1.4: Migration + Testing (1-2 ימים) ✅ הושלם

**מה לעשות:**
1. Migration script:
   ```dart
   Future<void> migrateReceiptItemsToUnified() async {
     // קרא כל הרשימות
     // המר: ReceiptItem → UnifiedListItem.fromReceiptItem()
     // שמור חזרה
   }
   ```

2. Manual testing:
   - יצירת רשימה חדשה
   - הוספת מוצר
   - הוספת משימה
   - סימון ✅
   - מחיקה

---

## 📅 מסלול 2: שיתוף משתמשים 🟡 בתהליך (התחלנו 23/10/2025)

### ⏱️ זמן: 7 ימי עבודה (26 שעות) → **התחלנו!**

### יעדים:
- 🟡 4 רמות הרשאות: Owner/Admin/Editor/Viewer
- 🟡 מערכת בקשות ואישורים
- 🟡 רשימת חברים

---

### שלב 2.1: Models + Enums (יום 1 - 4 שעות) ✅ הושלם 23/10/2025

**קבצים:**
- ✅ `lib/models/enums/user_role.dart` - **הושלם 23/10**
- ✅ `lib/models/enums/request_type.dart` - **הושלם 23/10**
- ✅ `lib/models/enums/request_status.dart` - **הושלם 23/10**
- ✅ `lib/models/shared_user.dart` - **הושלם 23/10**
- ✅ `lib/models/pending_request.dart` - **הושלם 23/10**
- ✅ עדכון `lib/models/shopping_list.dart` - **הושלם 23/10** (sharedUsers, pendingRequests, currentUserRole + helpers)

**פירוט ב-TASK_SUPPORT_OPTIONS.md חלק 2**

---

### שלב 2.2: Repository Layer (יום 2 - 5 שעות) ✅ הושלם 23/10/2025

**קבצים:**
- ✅ `lib/repositories/shopping_lists_repository.dart` - **הושלם 23/10** (8 methods חדשים)
- ✅ `lib/repositories/firebase_shopping_lists_repository.dart` - **הושלם 23/10** (מימוש מלא)

**Methods שהוספו:**
- ✅ `addSharedUser()` - הוספת משתמש משותף
- ✅ `removeSharedUser()` - הסרת משתמש משותף
- ✅ `updateUserRole()` - שינוי תפקיד משתמש
- ✅ `transferOwnership()` - העברת בעלות
- ✅ `createRequest()` - יצירת בקשה חדשה
- ✅ `approveRequest()` - אישור בקשה
- ✅ `rejectRequest()` - דחיית בקשה עם סיבה
- ✅ `getPendingRequests()` - קבלת רשימת בקשות ממתינות

---

### שלב 2.3: Provider Layer (יום 3 - 4 שעות) ✅ הושלם 23/10/2025

**קבצים:**
- ✅ `lib/providers/shared_users_provider.dart` - **הושלם 23/10** (ניהול משתמשים משותפים)
- ✅ `lib/providers/pending_requests_provider.dart` - **הושלם 23/10** (ניהול בקשות ואישורים)

**מה בוצע:**
1. SharedUsersProvider:
   - ✅ ניהול משתמשים משותפים
   - ✅ הוספה/הסרה/עדכון תפקיד
   - ✅ העברת בעלות
   - ✅ notifyListeners על שינויים
   - ✅ אינטגרציה מלאה עם UserContext

2. PendingRequestsProvider:
   - ✅ ניהול תור בקשות
   - ✅ יצירת בקשות חדשות
   - ✅ אישור/דחיית בקשות
   - ✅ ביצוע הפעולה בפועל לאחר אישור
   - ✅ חיבור אוטומטי ל-ShoppingListsProvider

---

### שלב 2.4: UI Screens (יום 4-5 - 8 שעות) ✅ הושלם 23/10/2025

**קבצים:**
- ✅ `lib/screens/lists/share_list_screen.dart` - **הושלם 23/10** (מסך ניהול משתמשים)
- ✅ `lib/widgets/lists/pending_requests_section.dart` - **הושלם 23/10** (Widget תצוגת בקשות)
- ✅ עדכון `lib/screens/shopping/shopping_list_details_screen.dart` - **הושלם 23/10** (כפתור Share + PendingRequestsSection)

**מה בוצע:**
- ✅ ShareListScreen מלא עם רשימת משתמשים + הרשאות
- ✅ PendingRequestsSection עם כרטיסי בקשות
- ✅ אינטגרציה עם Providers
- ✅ כפתור Share ב-AppBar
- ✅ PendingRequestsSection מוטמע בראש הרשימה

---

### שלב 2.5: Security Rules + Testing (יום 6-7 - 5 שעות) ✅ הושלם 23/10/2025

**קבצים:**
- ✅ `firestore.rules` - **הושלם 23/10** (הרשאות מלאות)

**מה בוצע:**
- ✅ פונקציות עזר: getUserRole(), isListOwner(), isListAdmin(), isListMember(), canApproveRequests()
- ✅ עדכון Shopping Lists Rules:
  - Read: household member או shared user
  - Update: Owner/Admin (כל עדכון), Editor (רק pendingRequests)
  - Delete: רק Owner
- ✅ אבטחה: מניעת שינוי household_id
- ✅ הערות מסכמות בראש הקובץ

---

## 📅 מסלול 3: UX חדש (מסך ראשי + המלצות)

### ⏱️ זמן: 10-12 ימי עבודה

### יעדים:
- מסך ראשי מחודש (רק פעילות)
- המלצות חכמות ממזווה
- הזדמנות אחרונה
- מסך רשימות (פעילות + היסטוריה)
- הסרת סריקת קבלות

---

### שלב 3.1: מודלים ולוגיקה (2 ימים)

**קבצים:**
- ✅ `lib/models/smart_suggestion.dart` (חדש)
- ✅ `lib/services/suggestions_service.dart` (חדש)
- ✅ עדכון `lib/models/shopping_list.dart` (status: active/completed)

**מה לעשות:**
1. SmartSuggestion model:
   ```dart
   class SmartSuggestion {
     final String productId;
     final String productName;
     final int currentStock;
     final int threshold;
     final DateTime suggestedAt;
     final SuggestionStatus status; // pending/added/dismissed/deleted
     final DateTime? dismissedUntil; // למחיקה זמנית
   }
   ```

2. SuggestionsService:
   - `generateSuggestions()` - מייצר המלצות מהמזווה
   - `dismissSuggestion(duration)` - דחייה זמנית
   - `deleteSuggestion(duration)` - מחיקה (יום/שבוע/חודש/לעולם)
   - `getNextSuggestion()` - מביא המלצה הבאה מהתור

---

### שלב 3.2: Providers (2 ימים)

**קבצים:**
- ✅ `lib/providers/suggestions_provider.dart` (חדש)
- ✅ עדכון `lib/providers/shopping_lists_provider.dart`
- ✅ עדכון `lib/providers/inventory_provider.dart`

**מה לעשות:**
1. SuggestionsProvider:
   - ניהול תור המלצות
   - קריאה ל-SuggestionsService
   - notifyListeners על שינויים

2. ShoppingListsProvider:
   - `completeList()` - סיום רשימה
   - `getActiveLists()` - רק פעילות
   - `getCompletedLists()` - היסטוריה
   - `getUnpurchasedItems()` - פריטים שלא נקנו

3. InventoryProvider:
   - `updateStockAfterPurchase()` - עדכון אוטומטי
   - `getLowStockItems()` - מוצרים שאוזלים

---

### שלב 3.3: מסך ראשי חדש (2 ימים)

**קבצים:**
- ✅ עדכון `lib/screens/home/home_dashboard_screen.dart`
- ✅ `lib/widgets/home/smart_suggestions_card.dart` (חדש)
- ✅ `lib/widgets/home/active_lists_section.dart` (חדש)

**מה לעשות:**
1. Dashboard:
   - רק רשימות פעילות
   - SmartSuggestionsCard (כרטיס גדול)
   - אם אין המלצות: "תזכורת - עדכן מלאי"

2. SmartSuggestionsCard:
   ```dart
   ┌─────────────────────────┐
   │ 💡 המלצות לקניה         │
   │ 🥛 חלב - נשארו 2       │
   │ [הוסף] [דחה] [מחק]     │
   └─────────────────────────┘
   ```
   - כפתור הוסף → מוסיף לרשימה הבאה + טוען המלצה חדשה
   - כפתור דחה → דוחה לשבוע הבא + טוען המלצה חדשה
   - כפתור מחק → פותח dialog + טוען המלצה חדשה

---

### שלב 3.4: הזדמנות אחרונה (1 יום)

**קבצים:**
- ✅ `lib/widgets/shopping/last_chance_banner.dart` (חדש)
- ✅ עדכון `lib/screens/shopping/shopping_list_details_screen.dart`

**מה לעשות:**
1. LastChanceBanner:
   ```dart
   ┌─────────────────────────┐
   │ ⚠️ עוד לא הוספת:       │
   │ • חלב (נשארו 2)        │
   │ [הוסף] [הבא]           │
   └─────────────────────────┘
   ```
   - רק במצב "קנייה פעילה"
   - מציג המלצות שלא הוספו
   - כפתור הוסף → מוסיף לרשימה הנוכחית
   - כפתור הבא → עובר למוצר הבא

---

### שלב 3.5: מסך רשימות (1 יום)

**קבצים:**
- ✅ עדכון `lib/screens/shopping/shopping_lists_screen.dart`

**מה לעשות:**
1. תצוגה אחת:
   - פעילות למעלה (🔵)
   - היסטוריה למטה (✅)
   - 10 שורות היסטוריה + "טען עוד"

2. חיפוש:
   - שדה חיפוש למעלה
   - עובד על כל הרשימות

---

### שלב 3.6: סיום קנייה (2 ימים)

**קבצים:**
- ✅ עדכון `lib/screens/shopping/active_shopping_screen.dart`
- ✅ עדכון `lib/providers/shopping_lists_provider.dart`
- ✅ עדכון `lib/providers/inventory_provider.dart`

**מה לעשות:**
1. לוגיקת סיום קנייה:
   - פריטים שסומנו ✅ → עדכן מלאי (חיבור!)
   - פריטים שלא סומנו → שמור לרשימה הבאה
   - בדיקה: האם יש מלאי במזווה? (אם כן - אל תוסיף)

2. עדכון מלאי אוטומטי:
   ```dart
   Future<void> completePurchase(ShoppingList list) async {
     for (var item in list.items) {
       if (item.isChecked && item.type == ItemType.product) {
         // עדכון מלאי: חיבור!
         await _inventoryProvider.addStock(
           item.productId, 
           item.quantity,
         );
       }
     }
     
     // פריטים שלא נקנו → רשימה הבאה
     final unpurchasedItems = list.items.where((i) => !i.isChecked);
     if (unpurchasedItems.isNotEmpty) {
       await _addToNextList(unpurchasedItems);
     }
     
     // סיים רשימה
     await _shoppingListsProvider.completeList(list.id);
   }
   ```

---

### שלב 3.7: הסרת סריקת קבלות (1 יום)

**קבצים למחיקה:**
- ❌ `lib/screens/receipts/scan_receipt_screen.dart`
- ❌ `lib/screens/receipts/receipt_import_screen.dart`
- ❌ `lib/screens/receipts/receipt_view_screen.dart`
- ❌ `lib/services/ocr_service.dart`
- ❌ `lib/services/receipt_parser_service.dart`
- ❌ `lib/widgets/add_receipt_dialog.dart`

**קבצים לעדכון:**
- ✅ `lib/main.dart` (הסר routes)
- ✅ `lib/screens/home/home_screen.dart` (הסר Bottom Nav item)
- ✅ `pubspec.yaml` (הסר google_mlkit_text_recognition)

**מה לעשות:**
1. מחק קבצים
2. הסר routes מ-main.dart
3. הסר Bottom Navigation item
4. הסר dependencies מיותרות
5. רוץ `flutter clean && flutter pub get`

---

### שלב 3.8: Testing + Polish (1-2 ימים)

**מה לעשות:**
1. Unit tests:
   - SuggestionsService
   - SuggestionsProvider
   - Complete purchase logic

2. Widget tests:
   - SmartSuggestionsCard
   - LastChanceBanner
   - Active lists section

3. Manual testing:
   - תרחישי משתמש מלאים
   - המלצות + הוסף/דחה/מחק
   - קנייה + סיום + עדכון מלאי
   - הזדמנות אחרונה

---

## 📊 סדר יישום מומלץ

### אופציה A: לפי מסלולים (מומלץ!)

```
שבוע 1-2:  מסלול 1 (Tasks + Products)
שבוע 3:     מסלול 2 (שיתוף משתמשים)
שבוע 4-5:   מסלול 3 (UX חדש)
שבוע 6:     Integration + Polish
```

**יתרונות:**
- כל מסלול סגור ועצמאי
- אפשר לבדוק כל מסלול בנפרד
- קל לנהל

---

### אופציה B: לפי עדיפות UX

```
שבוע 1-2:  מסלול 3 (UX חדש) - ללא Tasks
שבוע 3-4:  מסלול 1 (Tasks + Products)
שבוע 5:    מסלול 2 (שיתוף משתמשים)
שבוע 6:    Integration + Polish
```

**יתרונות:**
- משתמש רואה שינויים מהר
- UX משתפר מיד
- Tasks אופציונלי יותר

---

### אופציה C: Hybrid

```
שבוע 1:    מסלול 3.7 (הסרת קבלות) + 3.1-3.2 (מודלים)
שבוע 2:    מסלול 3.3-3.4 (מסך ראשי + המלצות)
שבוע 3:    מסלול 3.5-3.6 (רשימות + סיום קנייה)
שבוע 4-5:  מסלול 1 (Tasks + Products)
שבוע 6:    מסלול 2 (שיתוף)
```

**יתרונות:**
- UX קודם כל
- מורכבות נבנית הדרגתית

---

## 🎯 המלצה סופית

**אופציה C (Hybrid)** - הכי מאוזנת!

**סיבות:**
1. ✅ מסיר מיד דברים מיותרים (קבלות)
2. ✅ משתמש רואה שיפור UX מהר
3. ✅ מסלול Tasks נשאר לסוף (הכי מורכב)
4. ✅ שיתוף נשאר אופציונלי

---

## 📋 Checklist כללי

### לפני שמתחילים:
- [ ] קראתי UX_REQUIREMENTS.md
- [ ] קראתי TASK_SUPPORT_OPTIONS.md
- [ ] הבנתי את 3 המסלולים
- [ ] בחרתי סדר יישום

### כל שלב:
- [ ] צור/עדכן מודלים
- [ ] רוץ build_runner
- [ ] צור/עדכן repository
- [ ] צור/עדכן provider
- [ ] צור/עדכן UI
- [ ] כתוב tests
- [ ] בדוק ידנית
- [ ] commit + push

### בסוף כל מסלול:
- [ ] כל ה-tests עוברים
- [ ] בדיקה ידנית מקיפה
- [ ] עדכון documentation
- [ ] PR + code review

---

## 📝 הערות חשובות

### זכור:
1. 🎯 **UX קודם כל** - המשתמש צריך לראות שיפור
2. 🧪 **Tests חשובים** - אל תדלג!
3. 📚 **תיעוד** - עדכן מסמכים תוך כדי
4. 🔄 **Iterative** - תתחיל קטן, תבנה הדרגתית
5. ⚡ **ביצועים** - שמור על אפליקציה מהירה

### שאלות?
- קרא קודם את המסמכים (AI_MASTER_GUIDE, DEVELOPER_GUIDE, DESIGN_GUIDE)
- בדוק דוגמאות בקוד הקיים
- שאל את Claude אם משהו לא ברור!

---

**גרסה:** 1.2  
**תאריך יצירה:** 22/10/2025  
**עדכון אחרון:** 23/10/2025 (ערב)  
**מטרה:** תוכנית עבודה מפורטת ליישום כל התכונות החדשות

---

## 📈 היסטוריית עדכונים

### v1.4 - 24/10/2025 (לילה)
- 🎉 **מסלול 2 הושלם במלואו!** - מערכת שיתוף משתמשים 100%
- ✅ שלב 2.4: UI Screens - **הושלם 100%**
  - ✅ shopping_list_details_screen.dart עודכן עם כפתור Share
  - ✅ PendingRequestsSection מוטמע בראש הרשימה
- ✅ שלב 2.5: Security Rules - **הושלם 100%**
  - ✅ פונקציות עזר: getUserRole, isListOwner, isListAdmin, isListMember
  - ✅ Shopping Lists Rules עודכנו למערכת הרשאות
  - ✅ אבטחה מלאה: Owner/Admin/Editor/Viewer
- 🎯 הבא: מסלול 3 (UX חדש) או בדיקות מסלול 2

### v1.3 - 23/10/2025 (לילה)
- ✅ מסלול 2 שלב 2.3: **הושלם 100%** - Provider Layer מלא
- ✅ SharedUsersProvider + PendingRequestsProvider יצרו ופועלים
- 🟡 מסלול 2 שלב 2.4: **התחיל** - ShareListScreen ו-PendingRequestsSection יצרו
- ⏳ הבא: סיום שלב 2.4 - עדכון shopping_list_details_screen.dart

### v1.2 - 23/10/2025 (ערב)
- ✅ מסלול 2 שלב 2.1: **הושלם 100%** - כל ה-Models והשדות הנדרשים
- ✅ מסלול 2 שלב 2.2: **הושלם 100%** - Repository Layer מלא
- ✅ מסלול 2 שלב 2.3: **הושלם 100%** - Provider Layer מלא

### v1.1 - 23/10/2025 (בוקר)
- ✅ עדכון סטטוס מסלול 1: **הושלם לחלוטין**
- 🟡 עדכון סטטוס מסלול 2 שלב 2.1: **90% - Enums+Models הושלמו**

### v1.0 - 22/10/2025
- 📝 תוכנית ראשונית
