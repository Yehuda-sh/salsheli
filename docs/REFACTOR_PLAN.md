# 📋 תוכנית מלאה — MemoZap: מקוד לחנות

> נוצר: 8 מרץ 2026
> מטרה: **אפליקציה מוכנה להפצה ב-App Store + Google Play**
> מצב: טיוטה לאישור

---

## 📊 מצב נוכחי — תמונת מצב

### ✅ מה עובד טוב
- Firebase (Auth, Firestore, Storage, Crashlytics, Analytics) ✅
- Repository Pattern נקי ✅
- Haptic feedback (86 מקומות!) ✅
- Loading/Error/Empty states ✅
- Shimmer loaders ✅
- RTL + Hebrew ✅
- Responsive layout ✅

### 🔴 מה חוסם הפצה
| בעיה | חומרה | פירוט |
|------|--------|-------|
| `com.example.memozap` | 🔴 | חייב שם חבילה אמיתי |
| Release signing = debug | 🔴 | לא יעבור ל-store |
| 1,105 debug prints | 🔴 | APK מנופח + מידע רגיש בלוגים |
| לוגו 4.7MB | 🔴 | זמן טעינה איטי |
| iOS permissions חסרים | 🔴 | קריסה בפתיחת אנשי קשר |
| אין google_mobile_ads | 🟡 | אין מקור הכנסה |
| אין טסטים | 🟡 | 9 בלבד, 0 integration |
| 5 סגנונות עיצוב | 🟡 | לא מקצועי |
| 316 × Colors.xxx | 🟡 | dark mode שבור |
| 7,600 שורות קוד מת | 🟡 | APK מנופח |

---

# 📍 Phase 1 — ניקוי ויציבות (שבוע 1)
> לפני שמוסיפים — מנקים. סיכון אפס.

## 1.1 מחיקת קוד מת

### Widgets מתים (18 קבצים, ~6,600 שורות)
```
lib/widgets/common/animated_button.dart              145
lib/widgets/common/benefit_tile.dart                 262
lib/widgets/common/dashboard_card.dart               222
lib/widgets/common/offline_banner.dart               258
lib/widgets/common/painters/perforation_painter.dart  70
lib/widgets/common/product_image_widget.dart         211
lib/widgets/dev_banner.dart                          183
lib/widgets/dialogs/expiry_alert_dialog.dart         504
lib/widgets/dialogs/inventory_settings_dialog.dart   546
lib/widgets/dialogs/legal_content_dialog.dart        232
lib/widgets/dialogs/low_stock_alert_dialog.dart      424
lib/widgets/dialogs/recurring_product_dialog.dart    400
lib/widgets/dialogs/select_list_dialog.dart          455
lib/widgets/inventory/pantry_filters.dart            217
lib/widgets/inventory/storage_location_manager.dart 1300
lib/widgets/shopping/product_filter_section.dart     864
lib/widgets/shopping/shopping_list_tags.dart          207
lib/widgets/shopping/shopping_list_urgency.dart       114
```

### מודולים מתים (3 קבצים, 867 שורות)
```
lib/services/contact_picker_service.dart     464
lib/mixins/connectivity_mixin.dart           274
lib/services/prefs_service.dart              129
```

### קבועים מתים (core + config)
```
ui_constants.dart:  kAvatarRadiusSmall, kBorderRadiusSuper, kBorderWidthExtraThick,
  kButtonHeightLarge, kFabMargin, kFieldWidthNarrow, kGlassBlurHigh,
  kHapticFeedbackDelay, kHapticLongPressDelay, kStickyGray,
  kMinTouchTarget, kSnackBarDurationShort
constants.dart:     isNearLimit(), canAddItem(), getLimitUsage(), kChildrenAgeDescriptions
app_config.dart:    AppEnvironment enum
list_types_config:  ListTypeConfig class, configKeys
stores_config.dart: StoreInfo class
storage_locations:  isInvalid method
filters_config:     resolved method
```

### כפילויות
- `_getCategoryEmoji` מופיע ב-4 קבצים → להשתמש ב-`getCategoryEmoji()` מ-`filters_config.dart`

## 1.2 ניקוי debug prints (1,105!)

**החלף `debugPrint`/`print()` במערכת logging:**
```dart
// lib/core/app_logger.dart
import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String tag, String msg) {
    if (kDebugMode) debugPrint('[$tag] $msg');
  }
  static void e(String tag, String msg, [Object? error]) {
    if (kDebugMode) debugPrint('❌ [$tag] $msg ${error ?? ""}');
    // בproduction — שלח ל-Crashlytics
    if (kReleaseMode && error != null) {
      FirebaseCrashlytics.instance.recordError(error, null, reason: msg);
    }
  }
}
```
- בrelease → אפס prints, שגיאות הולכות ל-Crashlytics
- בdebug → הכל עובד כרגיל

## 1.3 אופטימיזציית תמונות

| תמונה | לפני | אחרי | שינוי |
|-------|-------|-------|-------|
| `logo.png` | 4,760KB | ~100KB | WebP + resize 512px |
| `snichel.png` | 822KB | ~50KB | WebP + resize |

```bash
# המרה אוטומטית
flutter pub add flutter_image_compress
# או ידנית עם cwebp:
cwebp -q 80 -resize 512 0 logo.png -o logo.webp
```

## 1.4 TODO/FIXME — טיפול (5 פריטים)

| מיקום | TODO | פעולה |
|-------|------|-------|
| `pending_requests_section.dart:360` | Call approveRequest() | לחבר |
| `pending_requests_section.dart:398` | Call rejectRequest() | לחבר |
| `my_pantry_screen.dart:356` | Low stock notifications | דחה → Phase 4 |
| `notifications_center_screen.dart:360` | Navigate to list | לחבר |
| `list_types_config.dart:16` | i18n | דחה → Phase 5 |

---

# 📍 Phase 2 — מערכת עיצוב אחידה (שבוע 2)
> הבסיס לכל שינוי ויזואלי. עושים פעם אחת, משתמשים בכל מקום.

## 2.1 Design Tokens

```dart
// lib/theme/design_tokens.dart
class AppTokens {
  AppTokens._();

  // ═══ Spacing (8-point grid) ═══
  static const space4  = 4.0;
  static const space8  = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space24 = 24.0;
  static const space32 = 32.0;

  // ═══ Border Radius (4 בלבד!) ═══
  static const radiusS  = 8.0;   // chips, badges
  static const radiusM  = 12.0;  // cards, inputs
  static const radiusL  = 16.0;  // bottom sheets, dialogs
  static const radiusXL = 24.0;  // special cards

  // ═══ Durations ═══
  static const fast   = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 350);
  static const slow   = Duration(milliseconds: 500);

  // ═══ Elevation ═══
  static const elevLow  = 2.0;
  static const elevMed  = 4.0;
  static const elevHigh = 8.0;
}
```

## 2.2 Context Extensions (נוחות)

```dart
// lib/theme/context_extensions.dart
extension ContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get cs => Theme.of(this).colorScheme;
  AppBrand get brand => Theme.of(this).extension<AppBrand>()!;
}
```

## 2.3 החלפת 316 × `Colors.xxx` → Theme

| לפני | אחרי |
|------|-------|
| `Colors.green` | `cs.primary` / `brand.success` |
| `Colors.red` | `cs.error` |
| `Colors.grey[300]` | `cs.surfaceVariant` |
| `Colors.white` | `cs.surface` |
| `Colors.black54` | `cs.onSurface.withOpacity(0.6)` |
| `Color(0xFF...)` | `brand.stickyYellow` etc. |

**עדיפות:** active_shopping → shopping_lists → home → pantry → settings

## 2.4 Typography — 18 גדלים → TextTheme

| לפני | אחרי |
|------|-------|
| `fontSize: 11` | `textTheme.bodySmall` |
| `fontSize: 14` | `textTheme.bodyMedium` |
| `fontSize: 16` | `textTheme.bodyLarge` |
| `fontSize: 18` | `textTheme.titleMedium` |
| `fontSize: 22` | `textTheme.titleLarge` |
| `fontSize: 28` | `textTheme.headlineMedium` |

## 2.5 Border Radius — 11 ערכים → 4

כל `BorderRadius.circular(X)` → `AppTokens.radiusS/M/L/XL`

## 2.6 Widgets משותפים חדשים

```dart
// AppSnackBar — במקום 160 SnackBar שונים
AppSnackBar.success(context, 'נשמר!');
AppSnackBar.error(context, 'שגיאה');
AppSnackBar.undo(context, 'נמחק', onUndo: () => restore());

// EmptyState — במקום לבנות מחדש בכל מסך
EmptyState(emoji: '🛒', title: 'אין רשימות', action: 'צור רשימה');

// SectionHeader — כותרת קטגוריה אחידה
SectionHeader(emoji: '🥛', title: 'חלב', count: 3, onTap: toggle);
```

---

# 📍 Phase 3 — איחוד סגנון + ריפקטור מבני (שבוע 2-3)
> כל המסכים נראים כמו אותה אפליקציה.

## 3.1 סגנון אחיד — Notebook + Sticky

**כל מסך:**
```dart
Stack(
  children: [
    const NotebookBackground(),
    Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, ...),
      body: ...,
    ),
  ],
)
```

**מסכים שצריכים עדכון:**

| מסך | מצב נוכחי | שינוי |
|-----|-----------|-------|
| `settings_screen.dart` | Cards בלבד | + Notebook + Sticky headers |
| `manage_users_screen.dart` | Cards + FAB | + Notebook |
| `checklist_screen.dart` | Basic | + Notebook + Sticky |
| `contact_selector_dialog.dart` | Basic | + Sticky colors |
| `register_screen.dart` | Glass בלבד | + Notebook (כמו login) |
| `my_pantry_screen.dart` | Glass בלבד | + Notebook |
| `onboarding_screen.dart` | Basic | + Sticky colors |
| `shopping_history_screen.dart` | Cards | + Notebook |

## 3.2 פיצול קבצים ארוכים (8 קבצים)

| קובץ | שורות | פיצול |
|------|-------|-------|
| `active_shopping_screen.dart` | 2,020 | → screen (800) + item_tile (400) + progress_header (200) + dialogs (300) |
| `shopping_lists_provider.dart` | 1,520 | → provider (500) + items_mixin (400) + collaborative_mixin (400) |
| `my_pantry_screen.dart` | 1,328 | → screen (600) + item_card (300) + header (200) |
| `settings_screen.dart` | 1,219 | → screen (400) + sections/ (5×150) |
| `shopping_lists_screen.dart` | 1,197 | → screen (500) + list_card (300) + filter_bar (200) |
| `shopping_list_details_screen.dart` | 1,166 | → screen (500) + item_row (300) + header (200) |
| `auth_service.dart` | 1,159 | → auth (600) + social_auth (500) |
| `login_screen.dart` | 1,157 | → screen (400) + form (300) + social_buttons (200) |

**Mixins pattern לprovider:**
```dart
mixin ShoppingItemsMixin on ChangeNotifier { /* items logic */ }
mixin CollaborativeShoppingMixin on ChangeNotifier { /* collab logic */ }

class ShoppingListsProvider extends ChangeNotifier
    with ShoppingItemsMixin, CollaborativeShoppingMixin {
  // CRUD + Query only
}
```

## 3.3 העברת ~150 מחרוזות hardcoded ל-AppStrings

| קובץ | מחרוזות |
|------|---------|
| `login_screen.dart` | ~43 |
| `shopping_list_details_screen.dart` | ~42 |
| `settings_screen.dart` | ~31 |
| `who_brings_screen.dart` | ~16 |
| `shopping_summary_screen.dart` | ~15 |

## 3.4 מבנה תיקיות מומלץ

```
lib/screens/
├── auth/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── widgets/                ← form, social buttons
├── home/
│   ├── home_dashboard_screen.dart
│   └── widgets/                ← כבר קיים
├── shopping/
│   ├── active/
│   │   ├── active_shopping_screen.dart
│   │   └── widgets/            ← item_tile, progress_header
│   ├── lists/
│   │   ├── shopping_lists_screen.dart
│   │   └── widgets/            ← list_card, filter_bar
│   ├── details/
│   │   └── widgets/            ← item_row, header
│   └── create/                 ← כבר קיים
├── pantry/
│   ├── my_pantry_screen.dart
│   └── widgets/                ← item_card, header
└── settings/
    ├── settings_screen.dart
    └── sections/               ← account, appearance, notifications
```

---

# 📍 Phase 4 — ליטוש UX מקצועי (שבוע 3-4)
> מה שעושה את ההבדל בין "אפליקציה שעובדת" ל"אפליקציה שאוהבים".

## 4.1 Page Transitions

```dart
// lib/theme/app_transitions.dart
class AppPageTransition extends PageRouteBuilder {
  AppPageTransition({required Widget page})
    : super(
        transitionDuration: AppTokens.medium,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
      );
}
```

## 4.2 Hero Animations

```dart
// ברשימת קניות:
Hero(tag: 'product-${item.id}', child: ProductIcon(...))
// בפרטי מוצר:
Hero(tag: 'product-${item.id}', child: ProductHeader(...))
```

## 4.3 AnimatedList (רשימת קניות)

```dart
// מוצר נוסף — נכנס עם slide
_listKey.currentState?.insertItem(index, duration: AppTokens.medium);

// מוצר מוסר — יוצא עם fade
_listKey.currentState?.removeItem(index,
  (context, animation) => SizeTransition(
    sizeFactor: animation,
    child: tile,
  ),
);
```

## 4.4 Collapsing AppBar עם Slivers

```dart
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

## 4.5 Platform-Specific UI

```dart
// iOS = Cupertino dialogs, Android = Material
showAdaptiveDialog(
  context: context,
  builder: (_) => AlertDialog.adaptive(
    title: Text('מחיקה'),
    actions: [
      adaptiveAction(context, 'ביטול', onCancel),
      adaptiveAction(context, 'מחק', onDelete, isDestructive: true),
    ],
  ),
);
```

## 4.6 Micro-interactions

| פעולה | אפקט |
|-------|-------|
| מוסיף מוצר | bounce-in + haptic |
| מסמן "קניתי" | ✅ check animation + strikethrough |
| מוחק מוצר | slide-out + undo snackbar |
| pull-to-refresh | custom indicator |
| סיום קניות | 🎉 confetti animation (Lottie) |
| רשימה ריקה | 🛒 animated empty cart (Lottie) |
| רשימה חדשה | scale-up entrance |

## 4.7 Splash Screen מקצועי

```yaml
# pubspec.yaml
flutter_native_splash:
  color: "#FFFFFF"
  image: assets/images/logo.webp
  android_12:
    icon_background_color: "#FFFFFF"
    image: assets/images/logo.webp
```

## 4.8 Lottie Animations

**איפה:**
- סיום קניות → confetti
- רשימה ריקה → עגלה ריקה
- Onboarding → אנימציות בכל שלב
- Error state → אנימציית שגיאה

**מקור:** [lottiefiles.com](https://lottiefiles.com) (חינם)

---

# 📍 Phase 5 — הכנה ל-Store (שבוע 4-5)
> דרישות טכניות חובה להגשה.

## 5.1 שם חבילה

```kotlin
// android/app/build.gradle.kts
applicationId = "com.memozap.app"  // או: "il.co.memozap"
```
```
// iOS: Bundle Identifier
com.memozap.app
```
⚠️ **שים לב:** אחרי שינוי שם חבילה — כל ה-Firebase צריך עדכון!

## 5.2 App Signing

### Android:
```bash
keytool -genkey -v -keystore ~/memozap-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias memozap
```
```properties
# android/key.properties (לא ב-git!)
storePassword=***
keyPassword=***
keyAlias=memozap
storeFile=/path/to/memozap-release.jks
```
```kotlin
// build.gradle.kts
signingConfigs {
    create("release") {
        // load from key.properties
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        proguardFiles(...)
    }
}
```

### iOS:
- Apple Developer Account ($99/year)
- Certificates + Provisioning Profiles via Xcode
- TestFlight להפצת בטא

## 5.3 iOS Permissions

```xml
<!-- ios/Runner/Info.plist -->
<key>NSContactsUsageDescription</key>
<string>MemoZap צריכה גישה לאנשי הקשר שלך כדי לשתף רשימות</string>

<key>NSCameraUsageDescription</key>
<string>MemoZap צריכה גישה למצלמה לסריקת ברקודים</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>MemoZap צריכה גישה לתמונות להוספת תמונות מוצרים</string>
```

## 5.4 App Icons (כל הגדלים)

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/icon-1024.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/icon-foreground.png"
```
- Icon צריך להיות 1024×1024 PNG
- Android Adaptive Icon: foreground + background בנפרד
- **אין שקיפות** ב-iOS
- **אין טקסט קטן** — לא ייקרא ב-icon

## 5.5 ProGuard/R8 (Android)

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

## 5.6 Privacy Policy + Terms

- **חובה** ל-App Store ו-Google Play
- צריך URL נגיש (GitHub Pages / Firebase Hosting)
- חייב לכלול: איסוף נתונים, Firebase Analytics, אנשי קשר
- קישור מתוך האפליקציה (כבר יש ✅)

## 5.7 Store Listing

### Google Play:
- [ ] שם: MemoZap — רשימת קניות חכמה
- [ ] תיאור קצר (80 תווים)
- [ ] תיאור ארוך (4000 תווים)
- [ ] Screenshots: 4-8 (phone) + 1-4 (tablet)
- [ ] Feature graphic: 1024×500
- [ ] Icon: 512×512
- [ ] Content rating questionnaire
- [ ] Privacy policy URL
- [ ] Data safety form

### App Store:
- [ ] שם + כותרת משנה
- [ ] תיאור
- [ ] Screenshots: 6.7" + 5.5" (חובה)
- [ ] Keywords (100 תווים)
- [ ] Privacy policy URL
- [ ] App Review information
- [ ] Age rating

---

# 📍 Phase 6 — מוניטיזציה (שבוע 5-6)
> מקורות הכנסה.

## 6.1 פרסומות וידאו (תוכנן מראש)

```yaml
dependencies:
  google_mobile_ads: ^5.0.0
```

**איפה להציג:**
- לפני תחילת רשימת קניות חדשה (Rewarded interstitial)
- בסיום קניות — "צפה בפרסומת לקבל סטטיסטיקות מפורטות"
- **לא** באמצע קניות (UX רע)

**המלצה:**
- Rewarded ads (המשתמש בוחר לצפות) > Interstitial (כפוי)
- Banner קבוע בתחתית = הכנסה נמוכה + UX רע. הימנע.

## 6.2 Premium (אופציונלי — עתידי)

```yaml
dependencies:
  purchases_flutter: ^7.0.0  # RevenueCat
```

**מה Premium יכול לתת:**
- ללא פרסומות
- רשימות ללא הגבלה
- ניתוח הוצאות מתקדם
- ייצוא לExcel

---

# 📍 Phase 7 — בדיקות ואיכות (שבוע 6-7)
> אפליקציה מקצועית = אפליקציה שלא קורסת.

## 7.1 Unit Tests (עדיפות: providers + services)

```dart
// test/providers/shopping_lists_provider_test.dart
group('ShoppingListsProvider', () {
  test('createList adds to lists', () { ... });
  test('deleteList removes and supports undo', () { ... });
  test('updateItemStatus changes status', () { ... });
});
```

**יעד מינימלי:** 50 טסטים על providers + services

## 7.2 Widget Tests (עדיפות: מסכים ראשיים)

```dart
// test/screens/active_shopping_screen_test.dart
testWidgets('swipe right marks as out of stock', (tester) async { ... });
testWidgets('tap quantity badge opens editor', (tester) async { ... });
```

**יעד:** 20 widget tests על מסכים קריטיים

## 7.3 Integration Tests

```dart
// integration_test/shopping_flow_test.dart
testWidgets('full shopping flow', (tester) async {
  // Login → Create list → Add items → Start shopping
  // → Mark purchased → Finish → Check history
});
```

**יעד:** 3-5 integration tests על flows ראשיים

## 7.4 Performance Testing

```dart
// בדוק:
// 1. רשימה עם 100+ פריטים — גלילה חלקה?
// 2. 50+ רשימות — טעינה מהירה?
// 3. Offline mode — הכל עובד?
// 4. Cold start time < 3 שניות?
```

## 7.5 Firebase Performance Monitoring

```yaml
dependencies:
  firebase_performance: ^0.10.0
```

---

# 📍 Phase 8 — i18n + נגישות (שבוע 7-8)
> להגיע ליותר משתמשים.

## 8.1 i18n Infrastructure

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_he.arb
output-localization-file: app_localizations.dart
```

**שלב 1:** עברית (he) + אנגלית (en)
**שלב 2:** רוסית (ru) + ערבית (ar) — קהלים גדולים בישראל

## 8.2 נגישות (a11y)

```dart
// כל תמונה צריכה:
Semantics(label: 'לוגו MemoZap', child: Image.asset(...))

// כל כפתור צריך:
Tooltip(message: 'הוסף מוצר', child: IconButton(...))

// ניגודיות צבעים: WCAG AA minimum (4.5:1)
// גודל טקסט מינימלי: 12sp
// Touch target מינימלי: 48×48
```

---

# 📍 Phase 9 — השקה (שבוע 8-9)

## 9.1 Beta Testing

1. **Internal testing** (Google Play) — 5-10 חברים/משפחה
2. **TestFlight** (iOS) — אותם אנשים
3. **משוב** → תיקונים → גרסה חדשה
4. **לפחות 2 שבועות** בטא לפני השקה

## 9.2 ASO (App Store Optimization)

- **שם:** MemoZap — רשימת קניות משפחתית
- **מילות מפתח:** רשימת קניות, shopping list, grocery, משפחה, שיתוף
- **Screenshots:** מעוצבים עם טקסט הסבר, לא רק צילומי מסך
- **Video preview:** 30 שניות של flow ראשי (אופציונלי אבל עוזר מאוד)

## 9.3 Soft Launch

1. שחרר ל-**ישראל בלבד** (geo restriction)
2. עקוב אחרי Crashlytics + Analytics
3. Crash rate < 1% → הרחב לעוד מדינות
4. Rating > 4.0 → קדם עם ASO

---

# ⏱️ לוח זמנים

```
שבוע 1:  Phase 1 — ניקוי קוד מת + debug prints + תמונות
שבוע 2:  Phase 2 — design tokens + theme + widgets משותפים
שבוע 2-3: Phase 3 — איחוד סגנון + פיצול קבצים + מחרוזות
שבוע 3-4: Phase 4 — ליטוש UX: אנימציות, transitions, micro-interactions
שבוע 4-5: Phase 5 — הכנה ל-Store: signing, icons, permissions, listing
שבוע 5-6: Phase 6 — מוניטיזציה: google_mobile_ads
שבוע 6-7: Phase 7 — טסטים: unit + widget + integration
שבוע 7-8: Phase 8 — i18n (en) + נגישות
שבוע 8-9: Phase 9 — בטא → השקה
```

---

# 📊 סיכום במספרים

| מדד | לפני | אחרי |
|-----|-------|-------|
| קוד מת | 7,600 שורות | 0 |
| Debug prints | 1,105 | 0 (logger) |
| סגנונות עיצוב | 5 | 1 |
| Colors.xxx | 316 | 0 (theme) |
| Border radius ערכים | 11 | 4 |
| Font sizes | 18 | 6 (TextTheme) |
| Hero animations | 0 | ✅ |
| Page transitions | 0 | ✅ |
| Lottie animations | 0 | 4-6 |
| Tests | 9 | 70+ |
| Languages | 1 (he) | 2 (he, en) |
| Crash monitoring | partial | full |
| Revenue | $0 | ads ready |
| Store listing | ❌ | ✅ |

---

# ✅ כללי עבודה

1. **commit אחרי כל שינוי** — קל ל-revert
2. **בדוק אמולטור** אחרי כל Phase
3. **לא לשנות לוגיקה** בזמן ריפקטור — רק מבנה ועיצוב
4. **קובץ אחד בכל פעם** — לא לפתוח 10 קבצים במקביל
5. **`dart analyze`** אחרי כל commit
6. **Phase 1 לפני הכל** — אל תבנה על קוד מת
7. **UX > Code** — המשתמש לא רואה קוד נקי, הוא רואה אנימציות חלקות
