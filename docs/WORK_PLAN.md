# 📋 MemoZap Complete System - Work Plan
> תוכנית עבודה מלאה | מערכת רשימות + מזווה חכם
> Created: 27/10/2025 | Updated: 29/10/2025

---

## 🎯 Strategic Goals

### Primary Goals
1. **ניהול רשימות קניות חכם** - לא השוואת מחירים!
2. **מזווה חכם מבוסס מיקומים** - עדכון אוטומטי ולמידת הרגלים

### Core Principles
1. ✅ **אין מחירים חובה** - מחירים לשלב מתקדם בלבד
2. ✅ **אין ברקוד חובה** - רק אופציונלי למי שרוצה
3. ✅ **פשטות מעל הכל** - הוספה מהירה של מוצרים
4. ✅ **שימוש חכם ב-API קיים** - 5000 מוצרים משופרסל מספיקים

### Target Features
- 🛒 רשימות לפי סוג חנות
- 🔍 סינון חכם של מוצרים
- 📝 הוספת מוצרים ללא מחיר/ברקוד
- 🥬 ירקות ופירות - רק שם וכמות

---

## 📊 Master Timeline

```yaml
סה"כ זמן: 8 שבועות
- Part A (Lists): 4 שבועות
- Part B (Inventory): 3 שבועות  
- Part C (Integration): 1 שבוע
```

---

# Part A: Lists System 🛒

## 📅 Implementation Phases

### ✅ Phase 0: Research & Planning (COMPLETED)
**Status:** ✅ DONE  
**Date:** 27/10/2025

- ✅ Analyzed existing system
- ✅ Verified UnifiedListItem supports no-price products
- ✅ Created ListTypeFilterService
- ✅ Documented strategy in memory

---

### ✅ Phase 1: Extend List Types (COMPLETED)
**Timeline:** Week 1 (28/10 - 03/11/2025)  
**Priority:** HIGH  
**Status:** ✅ DONE (27/10/2025)

#### Completed Tasks:
- ✅ Updated ShoppingList model with 8 types
- ✅ Extended Firebase schema
- ✅ Created and executed DB migration (1 list updated)
- ✅ Backward compatibility maintained
- ✅ Migration script: `scripts/migrate_types.js`

#### New Types:
```dart
- supermarket (סופרמרקט) - all 5000 products
- pharmacy (בית מרקחת) - hygiene & cleaning only
- greengrocer (ירקן) - fruits & vegetables only
- butcher (אטליז) - meat & poultry only
- bakery (מאפייה) - bread & pastries only
- market (שוק) - mixed fresh products
- household (כלי בית) - custom items
- other (אחר) - fallback
```

---

### ✅ Phase 2: Smart Product Filtering (COMPLETED)
**Timeline:** Week 1-2 (28/10 - 10/11/2025)  
**Priority:** HIGH  
**Status:** ✅ DONE (27/10/2025)

#### Completed Tasks:
- ✅ Created `ListTypeFilterService`
- ✅ Category mapping defined (7 list types)
- ✅ Connected to ProductsProvider
- ✅ Lazy loading in ProductsProvider (100 initial, then background)

---

### 🟢 Phase 3: UI/UX Updates (IN PROGRESS)
**Timeline:** Week 2 (04/11 - 10/11/2025)  
**Priority:** MEDIUM  
**Status:** 🟢 IN PROGRESS  
**Started:** 29/10/2025

#### Completed Tasks:
- ✅ List type selection UI (CreateListDialog with 8 types)
- ✅ Type icons and Hebrew labels (kListTypes config)
- ✅ Add type indicator to list cards (shopping_list_tile.dart)
- ✅ Type filtering in shopping_lists_screen.dart (Drawer + Dropdown)

#### Remaining Tasks:
- [ ] Update product search dialog (filter by list type)
- [ ] Add type-based product suggestions
- [ ] Polish animations and transitions
- [ ] Test all 8 types end-to-end

---

### 🆕 Phase 3A: Shopping Frequency & Reminders
**Timeline:** Week 2 (04/11 - 10/11/2025)  
**Priority:** LOW (Future)

#### Model Changes:
- [ ] ShoppingList: add `frequency` field (int - times per week)
- [ ] ShoppingList: add `lastShoppingDate` field (DateTime)
- [ ] Run build_runner after model changes

#### Tasks:
- [ ] UI: Frequency selector in create list (1-7 times/week)
- [ ] Service: ReminderService (calculate next shopping date)
- [ ] Notifications: Push reminder based on frequency
- [ ] Logic: Smart reminder (3 days before if frequency=weekly)
- [ ] Settings: Enable/disable reminders per list

**Note:** Currently marked as TODO in specification - implement when needed.

---

### 🆕 Phase 3B: User Sharing System
**Timeline:** Week 2-3 (04/11 - 17/11/2025)  
**Priority:** HIGH

> **Based on:** MemoZap Sharing System - Creator Flow (29/10/2025)

#### Models (✅ DONE):
- ✅ SharedUser (userId, role, sharedAt)
- ✅ PendingRequest (id, requesterId, itemData, status, requestedAt)
- ✅ UserRole enum (owner, admin, editor, viewer)

#### Permission Levels:
1. **Owner (יוצר הרשימה):**
   - מוסיף מוצרים ישירות (ללא אישור)
   - מאשר/דחה בקשות מ-Editors
   - יכול למחוק רשימה
   - מנהל הרשאות משתמשים

2. **Admin (מנהל):**
   - מוסיף מוצרים ישירות (ללא אישור)
   - מאשר/דחה בקשות מ-Editors
   - לא יכול למחוק רשימה (רק Owner)
   - יכול לנהל הרשאות משתמשים אחרים

3. **Editor (עורך):**
   - רואה את הרשימה המלאה
   - מוסיף מוצרים → הופך ל-'מוצר ממתין' (Pending)
   - צריך אישור מ-Owner/Admin
   - המוצר לא מופיע ברשימה עד האישור
   - לא יכול לערוך/מחוק מוצרים קיימים

4. **Viewer (צופה):**
   - רק צופה ברשימה (read-only)
   - לא יכול להוסיף בקשות
   - לא יכול לערוך כלום

#### Tasks:
- [ ] UI: Invite users screen (email + role selector)
- [ ] UI: Manage users screen (list of shared users + edit roles)
- [ ] UI: Pending requests section (badge with count)
- [ ] UI: Approve/reject pending request dialog
- [ ] Service: ShareListService (invite, remove, update role)
- [ ] Service: PendingRequestsService (create, approve, reject)
- [ ] Logic: Permission validation (who can do what)
- [ ] Logic: Badge counter for Owner/Admin (pending requests)
- [ ] Notifications: Push when request approved/rejected
- [ ] Notifications: Push when new user invited
- [ ] Firebase Security: Enforce permission rules
- [ ] Testing: All 4 permission levels

#### User Flow:
1. **Owner creates list** → invites users → assigns roles
2. **Editor adds item** → creates PendingRequest → waits for approval
3. **Owner/Admin sees badge** → reviews request → approves/rejects
4. **Approved** → item added to list + notification to Editor
5. **Rejected** → request deleted + notification to Editor

---

### 🔄 Phase 4: Product Management
**Timeline:** Week 3 (11/11 - 17/11/2025)  
**Priority:** MEDIUM

#### Tasks:
- [ ] Create ProductsManager singleton
- [ ] Implement lazy loading per type
- [ ] Hive cache integration
- [ ] Memory optimization
- [ ] Offline support

---

### 🔄 Phase 5: Testing & Polish
**Timeline:** Week 3-4 (11/11 - 24/11/2025)  
**Priority:** HIGH

#### Tasks:
- [ ] Test scenarios (filtering, no-price products, performance)
- [ ] Loading animations
- [ ] Empty state messages
- [ ] Error handling
- [ ] Hebrew translations
- [ ] RTL support verification

---

## 📊 Success Metrics

- ✅ 7 list types working
- ✅ Filter reduces products by 80%+
- ⏳ UI selection < 2 taps
- ⏳ Cache hit rate > 90%
- ⏳ All tests passing

---

## ⚠️ Important Notes

### What We're NOT Building:
- ❌ Price comparison app
- ❌ Barcode scanner (maybe later)
- ❌ Complex inventory system
- ❌ Store-specific prices

### What We ARE Building:
- ✅ Simple list manager
- ✅ Quick product addition
- ✅ Smart categorization
- ✅ Offline support

---

## 📚 Related Documents

- `CODE.md` - Code patterns (500 lines)
- `DESIGN.md` - UI/UX guidelines (300 lines)
- `TECH.md` - Technical reference (400 lines)
- `PROJECT_INSTRUCTIONS_v4.md` - Complete AI instructions (500 lines)
- `CODE_REVIEW_CHECKLIST.md` - Review protocols (300 lines)

**Total:** 5 files, 2000 lines (optimized for machine)

---

**Last Updated:** 29/10/2025  
**Status:** 🟢 ACTIVE - Phase 3 UI/UX Updates

---

## 🔍 Recent Work History

### ✅ Stability Phase (Sessions 25-46)

**Focus:** Infrastructure before features - fixing bugs, cleaning code, documenting properly.

#### 1. Bug Fixes (Sessions 25-33)
- Fixed compilation errors across 10+ files
- Fixed RangeError in navigation
- Fixed product loading (0 products → 1758 products)
- Added View/Edit modes to PopulateListScreen

#### 2. Documentation Evolution (Sessions 34-46)
- **Phase 1 (34, 39-43):** Reduced 10→7 files (-38% redundancy)
- **Phase 2 (45-46):** Reduced 7→5 files (-60% total redundancy)
- **PROJECT_INSTRUCTIONS:** v4.0 → v4.6
  - v4.0: Full YAML format
  - v4.1: Removed GUIDE.md references
  - v4.2: Added bash_tool Windows warning
  - v4.3: Enhanced dead code detection (4→6 steps)
  - v4.4: Added token management system
  - v4.5: Removed CHANGELOG.md (Memory replaces it!)
  - v4.6: Removed LESSONS_LEARNED.md (zero duplication)
- **CODE_REVIEW_CHECKLIST:** v2.0 → v2.2
- **TECH.md:** v1.0 → v1.1

#### 3. Code Cleanup (Sessions 35-41)
- Removed dead code: 1500+ lines across 9 files
- Cleaned: config/ directory, test/ directory, scripts/
- Created: 6-step dead code verification protocol
- **Critical lessons:** 3 false-positive incidents prevented deletion of active code

#### 4. Repository Work (Session 38)
- Created repository_constants.dart
- Migrated 6 repositories to constants
- Eliminated magic strings

#### 5. Testing (Sessions 44-45)
- Fixed tests from 61 failures → 0 failures
- 179 passing tests (90%+ model coverage)
- Added missing test data

#### 6. Memory System (Session 46)
- Implemented 10-entity knowledge graph
- Automatic checkpoint protocol (no manual docs!)
- Session rotation (keep last 3-5)
- Zero maintenance overhead

---

## 🎯 Current Status (Session 46+)

### Infrastructure: ✅ COMPLETE
1. ✅ All compilation errors resolved
2. ✅ Documentation stabilized (5 files, 2000 lines)
3. ✅ Testing infrastructure solid (179 passing)
4. ✅ Memory system operational (10 entities)
5. ✅ Token management system active

### Next: 🟢 Phase 3 UI/UX Updates
**Status:** IN PROGRESS  
**Started:** 29/10/2025

**Completed:**
- ✅ List type selection UI (CreateListDialog with 8 types)
- ✅ Type icons and Hebrew labels (kListTypes config)
- ✅ Type indicator in list cards (shopping_list_tile.dart)
- ✅ Type filtering in shopping_lists_screen.dart (Drawer + Dropdown)

**Remaining:**
- [ ] Update product search dialog (filter by list type)
- [ ] Add type-based product suggestions
- [ ] Polish animations and transitions
- [ ] Test all 8 types end-to-end

### Future Roadmap:
1. **Phase 4:** Product Management (lazy loading, caching)
2. **Phase 5:** Testing & Polish
3. **Phase 6-8:** Inventory System (storage locations, thresholds)
4. **Phase 9:** Lists ↔️ Inventory Integration
5. **Phase 10-14:** Receipt to Inventory System

---

---

# Part B: Inventory System 🏠

## 📅 Implementation Phases

### 🔄 Phase 6: Storage Location Infrastructure
**Timeline:** Week 5 (25/11 - 01/12/2025)  
**Priority:** HIGH

#### Model Changes:
- [ ] InventoryItem: add `minimumThreshold` field (int, default: 0)
- [ ] InventoryItem: add `lastUpdated` field (DateTime)
- [ ] Run build_runner after model changes

#### Tasks:
- [ ] Update InventoryItem model
- [ ] Create StorageLocationService
- [ ] Add location field to Firebase
- [ ] Create migration for existing items
- [ ] Update repositories

---

### 🆕 Phase 6A: Minimum Threshold System
**Timeline:** Week 5 (25/11 - 01/12/2025)  
**Priority:** HIGH

#### Tasks:
- [ ] UI: Threshold editor in inventory item (default: 0)
- [ ] Service: ThresholdMonitorService (check inventory < threshold)
- [ ] Logic: When quantity < minimumThreshold → auto-add to shopping list
- [ ] Logic: Route to correct list type (milk → supermarket)
- [ ] UI: Badge showing "auto-added" items in list
- [ ] Settings: Enable/disable auto-add per item
- [ ] Notifications: "Low stock: X items added to list"

---

### 🔄 Phase 7: Inventory UI/UX + Custom Locations
**Timeline:** Week 6 (02/12 - 08/12/2025)  
**Priority:** HIGH

#### Tasks:
- [ ] Create inventory_screen.dart
- [ ] Build UnassignedItemsBar widget
- [ ] Location-based item display
- [ ] Quick assignment UI (single row, all options)
- [ ] Animations for item assignment
- [ ] Empty states for each location

#### Custom Locations:
- [ ] Model: CustomLocation (id, name, icon, householdId, createdBy)
- [ ] Service: CustomLocationsService (CRUD operations)
- [ ] UI: Add custom location dialog (name + icon picker)
- [ ] UI: Edit/delete custom locations
- [ ] Logic: Custom locations appear in quick assignment row
- [ ] Firebase: Store in `custom_locations` collection
- [ ] Validation: Max 20 locations per household

---

### 🔄 Phase 8: Smart Stock Management
**Timeline:** Week 7 (09/12 - 15/12/2025)  
**Priority:** MEDIUM

#### Tasks:
- [ ] Implement StockUpdateService
- [ ] Create unpack shopping flow
- [ ] Build physical check flow  
- [ ] Location learning algorithm
- [ ] Auto-assignment logic
- [ ] Testing with real data

---

### 🆕 Phase 8A: Learning Algorithm - Predictive Stock
**Timeline:** Week 7 (09/12 - 15/12/2025)  
**Priority:** LOW (Future)

#### Tasks:
- [ ] Service: StockPredictionService
- [ ] Algorithm: Track purchase frequency per item
- [ ] Algorithm: Calculate average consumption rate
- [ ] Logic: Predict when item will run out
- [ ] Logic: Auto-add to list before running out
- [ ] UI: Show "predicted low stock" badge
- [ ] Testing: 2 weeks of data needed for accuracy

**Note:** Currently marked as TODO in specification - implement after basic system works.

---

# Part C: Integration 🔄

## 📅 Implementation Phase

### 🔄 Phase 9: Lists ↔️ Inventory Connection
**Timeline:** Week 8 (16/12 - 22/12/2025)  
**Priority:** HIGH

#### Integration Points:

#### Tasks:
- [ ] Connect inventory to suggestions
- [ ] Auto-routing to list types
- [ ] Shopping completion flow
- [ ] Weekly list generation
- [ ] Cross-system notifications
- [ ] End-to-end testing

---

### 🆕 Phase 9A: Cumulative Inventory System
**Timeline:** Week 8 (16/12 - 22/12/2025)  
**Priority:** HIGH

#### Tasks:
- [ ] Logic: Cumulative calculation (existing + purchased = total)
- [ ] Example: 2 in pantry + 5 bought = 7 total
- [ ] UI: Show before/after quantities in update confirmation
- [ ] UI: "You had 2, bought 5, now have 7" message
- [ ] Service: InventoryCumulativeService
- [ ] Validation: Prevent negative quantities
- [ ] History: Track quantity changes (optional)

---

# Part D: Receipt to Inventory System 🧾→🏠

> **Based on:** Receipt to Inventory System - Final Design (29/10/2025)

## 🎯 Overview

**מטרה:** מעבר חלק מקנייה משותפת לעדכון מלאי אוטומטי

### Core Concept:
1. **קנייה משותפת** - כמה אנשים קונים יחד בו-זמנית
2. **קבלה וירטואלית** - נוצרת אוטומטית בסיום קנייה
3. **חיבור לקבלה אמיתית** - משתמש סורק אחר כך ומחבר
4. **עדכון מלאי** - מוצרים שנקנו עוברים אוטומטית למזווה

---

## 📅 Implementation Phases

### 🔄 Phase 10: Shopping Session Management
**Timeline:** Week 9 (23/12 - 29/12/2025)  
**Priority:** HIGH

#### Models (✅ DONE - 29/10/2025):
- ✅ ActiveShopper (userId, joinedAt, isStarter, isActive)
- ✅ ShoppingList: added activeShoppers field + 8 helper getters
- ✅ ReceiptItem: added checkedBy, checkedAt (who marked as purchased)
- ✅ Receipt: added linkedShoppingListId, isVirtual, createdBy

#### Tasks:
- [ ] UI: Start Shopping screen with "Join Shopping" button
- [ ] Service: ShoppingSessionService (join, leave, timeout)
- [ ] Logic: Starter assignment (first person = starter)
- [ ] Logic: Power transfer (starter leaves → first helper becomes starter)
- [ ] Timeout: 6 hours inactive → auto-end shopping
- [ ] Notifications: Push when someone joins/leaves

---

### 🔄 Phase 11: Virtual Receipt Creation
**Timeline:** Week 10 (30/12 - 05/01/2026)  
**Priority:** HIGH

#### Tasks:
- [ ] Service: VirtualReceiptService
- [ ] Logic: On "Finish Shopping" → create virtual receipt
- [ ] Filter: Only purchased items (isChecked=true) in receipt
- [ ] Connection: linkedShoppingListId stored in receipt
- [ ] Model: Receipt.virtual() factory (already created ✅)
- [ ] UI: Show virtual receipt after shopping
- [ ] Validation: Only starter can finish shopping

---

### 🔄 Phase 12: Real Receipt Connection (OCR)
**Timeline:** Week 11 (06/01 - 12/01/2026)  
**Priority:** MEDIUM

#### Tasks:
- [ ] Service: ReceiptOCRService (scan & parse)
- [ ] Matching: Compare OCR items to virtual receipt items
- [ ] Update: Add real prices + fileUrl to virtual receipt
- [ ] UI: Scan receipt screen
- [ ] UI: Manual price editing (if OCR fails)
- [ ] Validation: Prevent duplicate receipt linking

---

### 🔄 Phase 13: Purchased → Inventory Flow
**Timeline:** Week 12 (13/01 - 19/01/2026)  
**Priority:** HIGH

#### Tasks:
- [ ] Service: PurchasedToInventoryService
- [ ] Logic: Purchased items → add to inventory (location: "no location")
- [ ] Logic: Unpurchased items → stay in list
- [ ] Cumulative inventory: existing 2 + purchased 5 = total 7
- [ ] UI: Notification to assign locations
- [ ] UI: Quick location assignment from notification

---

## 🔄 Phase 14: Integration Testing
**Timeline:** Week 13 (20/01 - 26/01/2026)  
**Priority:** HIGH

#### Scenarios:
1. **Solo Shopping:**
   - User starts shopping alone
   - Marks items as purchased
   - Finishes shopping
   - Virtual receipt created
   - Items move to inventory

2. **Collaborative Shopping:**
   - User A starts shopping (starter)
   - User B joins (helper)
   - Both mark items
   - User A finishes
   - Receipt shows who bought what

3. **Starter Leaving:**
   - User A starts (starter)
   - User B joins (helper)
   - User A leaves → User B becomes starter
   - User B finishes shopping

4. **Timeout:**
   - User starts shopping
   - 6 hours pass
   - Auto-end shopping
   - Virtual receipt created

5. **OCR Connection:**
   - Scan real receipt
   - Match to virtual receipt
   - Update prices
   - Inventory already updated

#### Tasks:
- [ ] Write integration tests for all 5 scenarios
- [ ] Test edge cases (network failure, app crash)
- [ ] Test permissions (only starter can finish)
- [ ] Test concurrent shoppers (2-3 people)
- [ ] Performance testing (100+ items)

---

## 🎯 Success Metrics

- ⏳ 100% purchased items auto-added to inventory
- ⏳ 95% virtual receipt creation success rate
- ⏳ 80% OCR matching accuracy
- ⏳ < 2 taps to assign location
- ⏳ 70% less manual updates
- ⏳ 80% accuracy in stock prediction  
- ⏳ 90% of essential items never run out
- ⏳ Seamless flow between lists and inventory
- ⏳ Smart learning after 2 weeks

---

---

**Version:** 1.3  
**Last Updated:** 29/10/2025  
**Status:** 🟢 ACTIVE - Phase 3 in progress

---

## 📊 Updated Timeline Summary

```yaml
סה"כ זמן: 13 שבועות
- Part A (Lists): 4 שבועות (Phases 0-5)
- Part B (Inventory): 3 שבועות (Phases 6-8)
- Part C (Integration): 1 שבוע (Phase 9)
- Part D (Receipt to Inventory): 5 שבועות (Phases 10-14)

New Features Added:
- 🆕 Phase 3A: Shopping Frequency & Reminders (LOW priority)
- 🆕 Phase 6A: Minimum Threshold System (HIGH priority)
- 🆕 Phase 7: Custom Locations (HIGH priority)
- 🆕 Phase 8A: Learning Algorithm (LOW priority - future)
- 🆕 Phase 9A: Cumulative Inventory (HIGH priority)
- 🆕 Part D: Receipt to Inventory System (Phases 10-14)
```

---

## 📦 What's New in v1.3

### Completed Since v1.2 (Sessions 25-46):
1. **Infrastructure Stability:**
   - All compilation errors fixed
   - 179 passing tests (0 failures)
   - Documentation: 10→5 files (-60% redundancy)
   - PROJECT_INSTRUCTIONS: v4.0→v4.6 (6 iterations!)

2. **Phase 3 Progress (UI/UX):**
   - ✅ List type selection UI (8 types working)
   - ✅ Type filtering in list screen
   - ✅ Type indicators on list cards
   - ⏳ Product search dialog (next step)

3. **Memory System:**
   - 10-entity knowledge graph
   - Auto-checkpoint every 3-5 files
   - Session rotation (last 3-5 kept)
   - Zero manual maintenance

4. **Critical Lessons:**
   - 6-step dead code verification (prevents false positives)
   - bash_tool Windows paths warning (most common error!)
   - YAGNI principle (don't over-design)

---

## 📦 What Was in v1.2

### Model Changes Required:
1. **ShoppingList:**
   - Add `frequency` (int) - times per week
   - Add `lastShoppingDate` (DateTime)

2. **InventoryItem:**
   - Add `minimumThreshold` (int, default: 0)
   - Add `lastUpdated` (DateTime)

3. **CustomLocation (new model):**
   - id, name, icon, householdId, createdBy

### New Services:
- ReminderService (frequency-based notifications)
- ThresholdMonitorService (auto-add to list)
- CustomLocationsService (CRUD for locations)
- StockPredictionService (future - learning algorithm)
- InventoryCumulativeService (quantity calculations)
- ShoppingSessionService (collaborative shopping)
- VirtualReceiptService (receipt creation)
- ReceiptOCRService (scan & match)
- PurchasedToInventoryService (auto-update inventory)

### Priority Order:
1. **HIGH:** Phases 6A, 7, 9A, 10-11, 13-14
2. **MEDIUM:** Phase 12 (OCR)
3. **LOW:** Phases 3A, 8A (future features)

---

**Remember:** The goals are SIMPLE LIST MANAGEMENT + SMART INVENTORY, not complex systems! 🎯

**Next Steps:**
1. Complete stability phase (documentation + testing) ✅
2. Resume Phase 3 (UI/UX Updates)
3. Implement Phase 6A (Minimum Threshold) - HIGH PRIORITY
4. Continue with original roadmap + new features
5. Keep focus on simplicity & user value
