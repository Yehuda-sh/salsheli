# 📋 TEST_PLAN.md — MemoZap Testing Strategy

## 📊 מצב נוכחי (עדכון 12/3/2026)
- **272 unit tests** ב-10 קבצים ✅ (כולם עוברים)
- **0 widget tests** ❌
- **0 integration tests** ❌
- **0 E2E tests** ❌

## 🎯 Coverage Map

### ✅ מכוסה (Unit Tests)
| Area | File | Tests |
|------|------|-------|
| Models | shopping_list_test.dart | ✅ CRUD, serialization |
| Models | shopping_list_permissions_test.dart | ✅ Role-based access |
| Models | inventory_item_test.dart | ✅ Pantry item logic |
| Models | active_shopper_test.dart | ✅ Shopping session |
| Models | smart_suggestion_test.dart | ✅ AI suggestions |
| Providers | user_context_test.dart | ✅ Auth state |
| Services | suggestions_service_test.dart | ✅ Suggestion engine |
| Screens | widget_tests_integration.dart | ✅ Basic widget rendering |

### ❌ חסר — Priority 1: Widget Tests (UX)
| Widget | מה לבדוק | Priority |
|--------|----------|----------|
| **TappableCard** | Scale animation, haptic, ripple, accessibility | 🔴 High |
| **StickyNote** | Colors, dark mode, tap response | 🔴 High |
| **NotebookBackground** | Lines render, red line position | 🟡 Medium |
| **ShoppingListTile** | Status colors, urgency badge, side strip | 🔴 High |
| **PantryItemDialog** | Form validation, category picker, save/cancel | 🔴 High |
| **ProductSelectionSheet** | Search, filter, add product, feedback | 🔴 High |
| **EmptyState** | Illustration, CTA button | 🟢 Low |
| **SkeletonLoader** | Animation, shimmer | 🟢 Low |

### ❌ חסר — Priority 2: Integration Tests
| Flow | מה לבדוק | Priority |
|------|----------|----------|
| **Create List** | Type selection → name → items → save to Firebase | 🔴 High |
| **Shopping Session** | Start → scan items → complete → receipt | 🔴 High |
| **Pantry Management** | Add item → edit quantity → set minimum → alert | 🔴 High |
| **Sharing** | Invite user → accept → shared list visible | 🟡 Medium |
| **Onboarding** | Welcome → preferences → household → done | 🟡 Medium |
| **Auth Flow** | Login → session → logout → re-login | 🟡 Medium |

### ❌ חסר — Priority 3: E2E Tests
| Scenario | Description | Priority |
|----------|-------------|----------|
| **Happy Path — Shopping** | Login → create list → add products → shop → complete → receipt | 🔴 High |
| **Happy Path — Pantry** | Login → add pantry items → track quantities → get suggestions | 🔴 High |
| **Multi-User** | User A creates list → invites User B → B adds items → both see updates | 🟡 Medium |
| **Offline → Online** | Add items offline → reconnect → sync verification | 🟡 Medium |
| **Edge Cases** | Empty states, max limits, Hebrew RTL, long product names | 🟢 Low |

## 🧪 UX Quality Checks (Manual + Automated)

### Accessibility (a11y)
- [ ] **Screen reader**: כל widget עם semanticLabel
- [ ] **Tap targets**: minimum 48x48dp
- [ ] **Color contrast**: WCAG AA compliance
- [ ] **RTL**: כל הטקסט והlayout עובדים ב-RTL
- [ ] **Dynamic text size**: UI doesn't break at 200% font

### Performance
- [ ] **List scroll**: 200+ items smooth (60fps)
- [ ] **Search**: <300ms response with debounce
- [ ] **Animation**: No jank on scale/elevation transitions
- [ ] **Memory**: No leaks on navigation back/forth
- [ ] **Cold start**: <3 seconds to interactive

### Visual Consistency
- [ ] **Dark Mode**: All sticky colors use desaturated variants
- [ ] **Notebook theme**: Lines, red margin consistent across screens
- [ ] **Watercolor illustrations**: Correct for each context
- [ ] **Typography**: Caveat for brand, Assistant for body

### Error Handling UX
- [ ] **Offline**: Banner shown, local saves work
- [ ] **Firebase errors**: User-friendly Hebrew messages
- [ ] **Empty states**: Illustration + CTA for every list/pantry
- [ ] **Loading states**: Skeleton loaders, not spinners
- [ ] **Validation**: Real-time form validation with clear errors

## 🏗️ Implementation Plan

### Phase 1: Widget Tests (1-2 days)
```dart
// test/widgets/tappable_card_test.dart
testWidgets('TappableCard scales on press', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: TappableCard(
      onTap: () {},
      child: Card(child: Text('Test')),
    ),
  ));
  
  // Verify initial state
  expect(find.byType(TappableCard), findsOneWidget);
  
  // Press and verify scale animation
  await tester.press(find.byType(TappableCard));
  await tester.pump(const Duration(milliseconds: 100));
  // Verify scale changed
});
```

### Phase 2: Integration Tests (2-3 days)
```dart
// integration_test/shopping_flow_test.dart
testWidgets('Complete shopping flow', (tester) async {
  // 1. Navigate to create list
  // 2. Select type (supermarket)
  // 3. Add products from catalog
  // 4. Save list
  // 5. Start shopping
  // 6. Mark items as bought
  // 7. Complete shopping → receipt
  // 8. Verify receipt data
});
```

### Phase 3: E2E Tests (3-5 days)
```dart
// integration_test/e2e_happy_path_test.dart
testWidgets('Full happy path - new user', (tester) async {
  // 1. Login with test account
  // 2. Complete onboarding
  // 3. Create first shopping list
  // 4. Add pantry items
  // 5. Get smart suggestions
  // 6. Complete shopping
  // 7. Verify all data persisted
});
```

## 📈 KPIs
| Metric | Current | Target |
|--------|---------|--------|
| Unit tests | 272 | 350+ |
| Widget tests | 0 | 30+ |
| Integration tests | 0 | 10+ |
| E2E tests | 0 | 3+ |
| Code coverage | ~40% | 70%+ |
| Test runtime | ~10s | <60s |

## 🔧 Test Infrastructure Needed
1. **Mock Firebase** — `fake_cloud_firestore` + `firebase_auth_mocks`
2. **Golden tests** — snapshot testing for UI consistency
3. **Test fixtures** — shared test data (products, lists, users)
4. **CI pipeline** — run tests on every PR

---
*Created: 2026-03-12 | Last updated: 2026-03-12*
