# 🕒 CHANGELOG - MemoZap Project

> **Updated:** 24/10/2025  
> **Purpose:** Track main documentation, logic, and structural updates for AI coordination.

---

## 🚀 v2.8 - 24/10/2025

### Major Features Completed

#### ✅ Mסלול 1: Tasks + Products (Hybrid) - 100% Complete
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

## 🚧 v2.9 - [In Progress] 24/10/2025

### מסלול 3: UX חדש - שלב 3.1 (Models + Logic) - 🟡 50% Complete

#### ✅ Completed:
- 📝 **SuggestionStatus enum** - pending/added/dismissed/deleted
- 🧩 **SmartSuggestion model** - advanced suggestion with stock tracking
- 🧠 **SuggestionsService** - generates suggestions from inventory
- 🧪 **Unit tests** - comprehensive tests for model and service
- ⏱️ **Started:** 24/10/2025

#### 🟡 In Progress:
- 📦 Running build_runner to generate JSON serialization
- 🔄 Next: Complete Day 1-2 tasks

#### ⏳ Remaining:
- ShoppingList status field update (if needed)
- Provider layer integration (Day 2)
- UI components (Days 3-8)

---

**Next planned version:** v3.0 — מסלול 3 (UX חדש: מסך ראשי + המלצות חכמות - Full)  
**Maintainer:** MemoZap AI Documentation System  
**Location:** `C:\projects\salsheli\docs\CHANGELOG.md`
