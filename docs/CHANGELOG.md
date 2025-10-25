# 🕒 CHANGELOG - MemoZap Project

> **Updated:** 24/10/2025 (ערב)  
> **Purpose:** Track main documentation, logic, and structural updates for AI coordination.

---

## 🚀 v2.8 - 24/10/2025

### Major Features Completed

#### ✅ מסלול 1: Tasks + Products (Hybrid) - 100% Complete
- 🧩 **UnifiedListItem model** - supports mixed products + tasks in one list
- 📋 **ItemType enum** - distinguishes between product and task
- 🎨 **UI updates** - shopping_list_details_screen.dart now shows both types
- 🔄 **Migration script** - converts old ReceiptItem to UnifiedListItem
- ✅ **Unit tests** - 9/9 tests passing for UnifiedListItem
- 📊 **Helpers** - products, tasks, productCount, taskCount, totalAmount
- ⏱️ **Completed:** 22/10/2025 (2 days)

#### ✅ מסלול 2: User Sharing System - 100% Complete
- 👥 **4 permission levels** - Owner, Admin, Editor, Viewer
- 🔐 **SharedUser model** - user permissions + metadata
- 📨 **Request system** - PendingRequest with add/edit/delete workflows
- 🎛️ **Providers** - SharedUsersProvider + PendingRequestsProvider
- 🖥️ **UI screens** - ShareListScreen + PendingRequestsSection widget
- 🔒 **Security rules** - Firestore rules with full permissions logic
- 📊 **8 Repository methods** - addSharedUser, removeSharedUser, updateUserRole, transferOwnership, createRequest, approveRequest, rejectRequest, getPendingRequests
- ⏱️ **Completed:** 23-24/10/2025 (2 days)

### Technical Improvements
- 🧪 **Test cleanup** - removed 1,600+ lines of obsolete tests (receipt, template, habits)
- 📁 **File organization** - cleaner test structure focused on active features
- 🐛 **Bug fixes** - const usage errors in active_shopping_screen.dart

---

## 📦 v2.7 - 22/10/2025

- 🧩 Added **MEMOZAP_UI_REQUIREMENTS.md** (UX decisions file)
- 🔄 Unified all AI documentation under `C:\projects\salsheli\docs\ai\`
- 🧠 Defined cooperation logic between MCP tools and VS Code workflow
- 🎯 Introduced single main project path: `C:\projects\salsheli\`

---

## 🧱 v2.6 - 21/10/2025

- 🧩 Added **Hybrid UnifiedListItem model** for mixed products/tasks
- 👥 Added **Sharing System** (Owner/Admin/Editor/Viewer)
- 🔒 Defined Firestore rules + UI flows for approval requests
- 📦 Expanded `MCP_TOOLS_GUIDE.md` → full integration with MemoZap

---

## 🧩 v2.5 - 20/10/2025

- 🧠 Created **AI behavior and developer guides**
- 🔧 Fixed recurring edit_file mismatches
- 📋 Added memory consistency rules between sessions

---

## 📘 v2.4 - 19/10/2025

- 🛠 Introduced **MCP tools list** + setup instructions
- 🔄 Standardized file structure under `docs/`
- 🧠 Added error recovery principles and logging format

---

## 🚧 v2.9 - [In Progress] 24/10/2025 (ערב)

### ✅ מסלול 3 - שלב 3.1: Models + Logic - 100% Complete

#### Models & Services (✅ הושלם):
- 📝 **SuggestionStatus enum** - pending/added/dismissed/deleted
- 🧩 **SmartSuggestion model** - מודל מתקדם עם מעקב מלאי
- 🧠 **SuggestionsService** - יצירת המלצות מהמזווה (static methods)
- 🧪 **Unit tests** - בדיקות מקיפות למודל ול-service

#### Providers (✅ הושלם):
- 🔧 **SuggestionsProvider** - תוקן והותאם ל-static methods
  - ✅ refreshSuggestions()
  - ✅ addCurrentSuggestion()
  - ✅ dismissCurrentSuggestion()
  - ✅ deleteCurrentSuggestion()
  - ✅ _excludedProducts set (למוצרים שנמחקו לצמיתות)
- ✅ **ShoppingListsProvider** - כבר מוכן
  - ✅ activeLists getter
  - ✅ completedLists getter
  - ✅ completeList()
  - ✅ getUnpurchasedItems()
- ✅ **InventoryProvider** - כבר מוכן
  - ✅ getLowStockItems()
  - ✅ updateStockAfterPurchase()
  - ✅ addStock()

#### ⏳ Pending Action:
- 📦 **build_runner** - להריץ ידנית:
  ```bash
  cd C:\projects\salsheli
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

#### ⏱️ **Completed:** 24/10/2025 (ערב - 1 יום)

---

### ✅ מסלול 3 - שלב 3.3: UI Components - 100% Complete

#### Widgets (✅ הושלם):
- 🎨 **SmartSuggestionsCard** - כרטיס המלצות חכמות עם 3 כפתורים
  - ✅ כפתור הוסף → מוסיף לרשימה + טוען המלצה הבאה
  - ✅ כפתור דחה → דוחה לשבוע הבא + טוען המלצה הבאה
  - ✅ כפתור מחק → פותח dialog למחיקה לצמיתות
- 📋 **ActiveListsSection** - רשימת רשימות פעילות
  - ✅ הצגת רשימות נוספות (מלבד ה-upcoming)
  - ✅ כל רשימה clickable לניווט
  - ✅ עיצוב Sticky Note ירוק

#### Dashboard Integration (✅ הושלם):
- ✅ **home_dashboard_screen.dart** - עודכן להשתמש בwidgets החדשים
  - ✅ SmartSuggestionsCard מוטמע
  - ✅ ActiveListsSection מוטמע
  - ✅ הוסר _ActiveListsCard (ישן)
  - ✅ הוסר _DismissibleListTile (ישן)
  - ✅ אנימציות .animate() על כל הwidgets

#### ⏳ Pending Action:
- 📦 **build_runner** - להריץ ידנית (אותו כמו בשלב 3.1)
- 🧪 **בדיקה ידנית** - להריץ את האפליקציה ולבדוק

#### ⏱️ **Completed:** 24/10/2025 (לילה - 1 יום)

---

### 🔜 Next Steps:

**מסלול 3 - שלב 3.4:** הזדמנות אחרונה (1 יום)
- LastChanceBanner widget
- Integration עם active_shopping_screen

**מסלול 3 - שלב 3.5:** מסך רשימות (1 יום)
- עדכון shopping_lists_screen
- פעילות + היסטוריה ביחד

---

**Next planned version:** v3.0 — מסלול 3 מלא (מסך ראשי + המלצות חכמות)  
**Maintainer:** MemoZap AI Documentation System  
**Location:** `C:\projects\salsheli\docs\CHANGELOG.md`
