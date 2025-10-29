# 📋 MemoZap Complete System - Work Plan
> תוכנית עבודה מלאה | מערכת רשימות + מזווה חכם
> Created: 27/10/2025 | Updated: 27/10/2025

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

### 🔄 Phase 3: UI/UX Updates
**Timeline:** Week 2 (04/11 - 10/11/2025)  
**Priority:** MEDIUM

#### Tasks:
- [ ] List type selection screen (sticky notes style)
- [ ] Type icons and Hebrew labels
- [ ] Update create_list_screen.dart
- [ ] Update product search dialog
- [ ] Add type indicator to list cards

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

- `GUIDE.md` - Development guide
- `CODE.md` - Code patterns  
- `DESIGN.md` - UI/UX guidelines
- `TECH.md` - Technical reference

---

**Last Updated:** 29/10/2025  
**Status:** 🟢 ACTIVE

---

---

# Part B: Inventory System 🏠

## 📅 Implementation Phases

### 🔄 Phase 6: Storage Location Infrastructure
**Timeline:** Week 5 (25/11 - 01/12/2025)  
**Priority:** HIGH

#### Tasks:
- [ ] Update InventoryItem model
- [ ] Create StorageLocationService
- [ ] Add location field to Firebase
- [ ] Create migration for existing items
- [ ] Update repositories

---

### 🔄 Phase 7: Inventory UI/UX
**Timeline:** Week 6 (02/12 - 08/12/2025)  
**Priority:** HIGH

#### Tasks:
- [ ] Create inventory_screen.dart
- [ ] Build UnassignedItemsBar widget
- [ ] Location-based item display
- [ ] Quick assignment UI (single row, all options)
- [ ] Animations for item assignment
- [ ] Empty states for each location

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

## 🎯 Success Metrics

- ⏳ 70% less manual updates
- ⏳ 80% accuracy in stock prediction  
- ⏳ 90% of essential items never run out
- ⏳ Seamless flow between lists and inventory
- ⏳ Smart learning after 2 weeks

---

**Remember:** The goals are SIMPLE LIST MANAGEMENT + SMART INVENTORY, not complex systems! 🎯
