# 📋 TEST_PLAN.md — MemoZap Testing Strategy

## 📊 מצב נוכחי (עדכון 16/3/2026)
- **335 unit tests** ב-10 קבצים ✅ (כולם עוברים)
- **12 demo users** with edge case coverage ✅
- **E2E test guide** — `docs/E2E_TEST_GUIDE.md` ✅
- **0 widget tests** — post-launch
- **0 integration tests** — post-launch

## 🎯 Coverage Map

### ✅ מכוסה (Unit Tests)
| Area | Tests |
|------|-------|
| ShoppingList (CRUD, permissions, serialization) | ✅ |
| InventoryItem (pantry logic) | ✅ |
| ActiveShopper (shopping session) | ✅ |
| SmartSuggestion (AI suggestions) | ✅ |
| UserContext (auth state, dispose safety) | ✅ |
| SuggestionsService (engine) | ✅ |
| InventoryProvider (low stock) | ✅ |

### ✅ Demo Users — Edge Cases
| משתמש | תרחיש |
|--------|--------|
| אבי כהן | Owner, התראות, הזמנה נכנסת |
| רונית כהן | Admin, קנייה פעילה |
| יובל כהן | Editor, pending requests |
| נועה כהן | Editor, rejected request |
| דן לוי | Admin, הזמנה יוצאת |
| מאיה לוי | Admin, רשימה פעילה |
| תומר בר | Solo, private pharmacy list |
| שירן גל | Solo, מזווה בלבד |
| אורי שלום | Viewer, 0 מזווה |
| ליאור דהן | לא פעיל 45 ימים |
| נעמה רוזן | Power user (35 מזווה, 30 קבלות, budget list) |
| יעל חדשה | **0 הכל — empty states** |

### Post-launch
| Area | Priority |
|------|----------|
| Widget tests (TappableCard, StickyNote, ShoppingListTile) | 🟡 |
| Integration tests (shopping flow, pantry, sharing) | 🟡 |
| E2E automated tests | 🟢 |

## 📈 KPIs
| Metric | Current | Target (post-launch) |
|--------|---------|--------|
| Unit tests | 335 | 400+ |
| Widget tests | 0 | 30+ |
| Demo users | 12 | 12 |
| Analyze errors | 0 | 0 |
| Analyze warnings | 2 | 0 |

---
*Updated: 2026-03-16*
