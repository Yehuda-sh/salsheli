# 📋 TEST_PLAN.md — MemoZap Testing Strategy

## 📊 מצב נוכחי (עדכון 9/4/2026)
- **396 unit tests** ב-15 קבצים ✅ (כולם עוברים)
- **16 demo users** with edge case coverage ✅
- **E2E test guide** — `docs/E2E_TEST_GUIDE.md` ✅ (11 flows, כולל Activity Log)
- **0 widget tests** — post-launch
- **0 integration tests** — post-launch

## 🎯 Coverage Map

### ✅ מכוסה (Unit Tests)
| Area | File | Status |
|------|------|--------|
| ShoppingList (CRUD, permissions, serialization) | `shopping_list_test.dart`, `shopping_list_permissions_test.dart` | ✅ |
| UnifiedListItem (list items) | `unified_list_item_test.dart` | ✅ |
| InventoryItem (pantry logic) | `inventory_item_test.dart` | ✅ |
| ActiveShopper (shopping session) | `active_shopper_test.dart` | ✅ |
| SmartSuggestion (AI suggestions) | `smart_suggestion_test.dart` | ✅ |
| Notification (model) | `notification_test.dart` | ✅ |
| UserContext (auth state, dispose safety) | `user_context_test.dart` | ✅ |
| InventoryProvider (low stock) | `inventory_provider_test.dart` | ✅ |
| SuggestionsService (engine) | `suggestions_service_test.dart` | ✅ |
| AuthService DTOs | `auth_dto_test.dart` | ✅ |
| NotificationQueryResult | `notification_query_result_test.dart` | ✅ |
| HomeDashboard (screen logic) | `home_dashboard_screen_test.dart` | ✅ |
| MainNavigation (screen logic) | `main_navigation_screen_test.dart` | ✅ |
| Large List Performance | `large_list_test.dart` | ✅ |

### ✅ Demo Users — Edge Cases (16 users)
| משתמש | תרחיש |
|--------|--------|
| אבי כהן | Owner, התראות, הזמנה נכנסת |
| רונית כהן | Admin, קנייה פעילה |
| יובל כהן | Editor, pending requests |
| נועה כהן | Editor, rejected request |
| אורי שלום | Viewer ב-Cohen, 0 מזווה |
| דן לוי | Admin, הזמנה יוצאת |
| מאיה לוי | Admin, רשימה פעילה |
| תומר בר | Solo, private pharmacy list |
| שירן גל | Solo, מזווה בלבד |
| נעמה רוזן | Power user (35 מזווה, 30 קבלות, budget list) |
| ליאור דהן | לא פעיל 45 ימים |
| יעל חדשה | **0 הכל — empty states** |
| גיל גוגל | Google Sign-In, no phone, profile image |
| apple_user | Apple Sign-In, no phone, no display name |
| Mike Johnson | English locale, international phone (+972) |
| ג'ורג' חביב | Hebrew name with geresh character |

### Post-launch
| Area | Priority |
|------|----------|
| Widget tests (TappableCard, StickyNote, ShoppingListTile) | 🟡 |
| Integration tests (shopping flow, pantry, sharing) | 🟡 |
| E2E automated tests | 🟢 |

## 📈 KPIs
| Metric | Current | Target (post-launch) |
|--------|---------|--------|
| Unit tests (passing) | 396 | 400+ |
| Unit tests (failing) | 0 | 0 |
| Test files | 15 | 25+ |
| Widget tests | 0 | 30+ |
| Demo users | 16 | 16 |
| Analyze errors | 0 | 0 |
| Analyze warnings | 2 (W1) | 0 |

---
*Updated: 2026-04-09*
