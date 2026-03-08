# 📋 תוכנית מלאה — MemoZap: מפיתוח להפצה

> נוצר: 8 מרץ 2026 | עדכון אחרון: 8 מרץ 2026
> מטרה: **אפליקציה מוכנה ל-App Store + Google Play**

---

## 📊 מצב נוכחי — סיכום ביקורת

### קוד
| מדד | ערך | בעיה? |
|-----|-----|-------|
| קבצי Dart | ~100 | |
| שורות קוד | ~56,000 | |
| widgets מתים | 18 קבצים (6,600 שורות) | 🔴 |
| מודולים מתים | 3 קבצים (867 שורות) | 🔴 |
| debug prints | **1,105** | 🔴 |
| TODO/FIXME | 5 | 🟡 |
| קבצים > 1,000 שורות | 8 (screens) + 2 (modules) | 🟡 |

### עיצוב
| מדד | ערך | בעיה? |
|-----|-----|-------|
| סגנונות עיצוב שונים | 5 | 🔴 |
| `Colors.xxx` ישירים | **316** | 🔴 |
| Border radius ערכים | 11 (צריך 4) | 🔴 |
| Font sizes | 18 (צריך 6-8) | 🔴 |
| Hero animations | 0 | 🟡 |
| Page transitions | 0 | 🟡 |
| Slivers | 0 | 🟡 |

### הפצה
| מדד | ערך | בעיה? |
|-----|-----|-------|
| applicationId | `com.example.memozap` | 🔴 חייב לשנות! |
| Release signing | debug key בלבד | 🔴 |
| logo.png | **4,760KB** | 🔴 צריך <200KB |
| Native splash | ❌ | 🟡 |
| ProGuard/R8 | ❌ | 🟡 |
| Ads SDK | ❌ | 🟡 |
| Tests | 9 קבצים, 0 integration | 🟡 |
| i18n | עברית בלבד | ✅ (בינתיים) |
| Firebase rules | ✅ | |
| Crashlytics | ✅ | |
| Analytics | ✅ | |

---

# 🗺️ שלבי העבודה

## 🔴 שלב 1 — ניקוי (יום 1-2)
> סיכון: אפס. מוחקים רק מה שלא בשימוש.

### 1.1 מחיקת 18 widgets מתים (~6,600 שורות)

```
lib/widgets/common/animated_button.dart         (145)
lib/widgets/common/benefit_tile.dart            (262)
lib/widgets/common/dashboard_card.dart          (222)
lib/widgets/common/offline_banner.dart          (258)
lib/widgets/common/painters/perforation_painter.dart (70)
lib/widgets/common/product_image_widget.dart    (211)
lib/widgets/dev_banner.dart                     (183)
lib/widgets/dialogs/expiry_alert_dialog.dart    (504)
lib/widgets/dialogs/inventory_settings_dialog.dart (546)
lib/widgets/dialogs/legal_content_dialog.dart   (232)
lib/widgets/dialogs/low_stock_alert_dialog.dart (424)
lib/widgets/dialogs/recurring_product_dialog.dart (400)
lib/widgets/dialogs/select_list_dialog.dart     (455)
lib/widgets/inventory/pantry_filters.dart       (217)
lib/widgets/inventory/storage_location_manager.dart (1,300)
lib/widgets/shopping/product_filter_section.dart (864)
lib/widgets/shopping/shopping_list_tags.dart     (207)
lib/widgets/shopping/shopping_list_urgency.dart  (114)
```

### 1.2 מחיקת 3 מודולים מתים (867 שורות)

```
lib/services/contact_picker_service.dart    (464)
lib/mixins/connectivity_mixin.dart          (274)
lib/services/prefs_service.dart             (129)
```

### 1.3 ניקוי core + config

```
ui_constants.dart: kAvatarRadiusSmall, kBorderRadiusSuper, kBorderWidthExtraThick,
  kButtonHeightLarge, kFabMargin, kFieldWidthNarrow, kGlassBlurHigh,
  kHapticFeedbackDelay, kHapticLongPressDelay, kStickyGray,
  kMinTouchTarget, kSnackBarDurationShort

constants.dart: isNearLimit(), canAddItem(), getLimitUsage(), kChildrenAgeDescriptions

app_config.dart: AppEnvironment enum
list_types_config.dart: ListTypeConfig class, configKeys
stores_config.dart: StoreInfo class
storage_locations_config.dart: isInvalid
filters_config.dart: resolved
```

### 1.4 הסרת `_getCategoryEmoji` כפול

4 קבצים → `getCategoryEmoji()` מ-`filters_config.dart`

### 1.5 ניקוי 1,105 debug prints

- **שמור:** `debugPrint` (נעלם ב-release mode)
- **מחק:** `print()` (נשאר ב-production!)
- **הוסף:** `kDebugMode` guard או logger service

```dart
// במקום print() בכל מקום:
import 'package:flutter/foundation.dart';
if (kDebugMode) debugPrint('...');
```

### 1.6 טיפול ב-5 TODOs

```
pending_requests_section.dart:360 — TODO: approveRequest()
pending_requests_section.dart:398 — TODO: rejectRequest()
my_pantry_screen.dart:356 — TODO: household low stock notifications
notifications_center_screen.dart:360 — TODO: navigate to list details
list_types_config.dart:16 — TODO(i18n): move to AppStrings
```

---

## 🟡 שלב 2 — Design System (יום 3-5)
> המטרה: שכל המסכים ירגישו כמו אפליקציה אחת.

### 2.1 Design Tokens

**צור `lib/theme/design_tokens.dart`:**
```dart
class AppTokens {
  AppTokens._();

  // ═══ Spacing (4-point grid) ═══
  static const s4  = 4.0;
  static const s8  = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;

  // ═══ Border Radius (4 sizes only!) ═══
  static const radiusS  = 8.0;   // chips, badges
  static const radiusM  = 12.0;  // cards, inputs
  static const radiusL  = 16.0;  // bottom sheets
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

### 2.2 Context Extensions

**צור `lib/theme/context_extensions.dart`:**
```dart
extension ContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get cs => Theme.of(this).colorScheme;
  AppBrand get brand => Theme.of(this).extension<AppBrand>()!;
}
```

### 2.3 החלפת 316 × `Colors.xxx` → Theme

| לפני | אחרי |
|------|-------|
| `Colors.green` | `cs.primary` |
| `Colors.red` | `cs.error` |
| `Colors.grey[300]` | `cs.surfaceVariant` |
| `Colors.white` | `cs.surface` |
| `Colors.black54` | `cs.onSurface.withOpacity(0.6)` |
| `Color(0xFF...)` | `brand.stickyYellow` / `brand.success` |

**עדיפות (הכי נראים למשתמש):**
1. `home_dashboard_screen.dart`
2. `shopping_lists_screen.dart`
3. `active_shopping_screen.dart`
4. `my_pantry_screen.dart`
5. `settings_screen.dart`

### 2.4 Typography — מ-18 גדלים ל-TextTheme

| שימוש | TextTheme |
|-------|-----------|
| כותרת מסך | `headlineMedium` |
| כותרת סקשן | `titleLarge` |
| כותרת כרטיס | `titleMedium` |
| טקסט רגיל | `bodyMedium` |
| טקסט משני | `bodySmall` |
| כפתור | `labelLarge` |
| badge/chip | `labelSmall` |

### 2.5 Border Radius — מ-11 ל-4

```dart
// Search & Replace:
// 2,3,4,6,8 → AppTokens.radiusS (8)
// 10,12      → AppTokens.radiusM (12)
// 14,16      → AppTokens.radiusL (16)
// 20,24      → AppTokens.radiusXL (24)
```

### 2.6 איחוד סגנון עיצובי — Notebook + Sticky

**מסכים לעדכן:**
| מסך | מצב נוכחי | שינוי |
|-----|-----------|-------|
| `settings_screen.dart` | 🃏 Cards | + NotebookBackground + Sticky |
| `manage_users_screen.dart` | 🃏 Cards | + NotebookBackground |
| `checklist_screen.dart` | 📦 Basic | + NotebookBackground + Sticky |
| `contact_selector_dialog.dart` | 📦 Basic | + Sticky colors |
| `register_screen.dart` | 🔮 Glass | + Notebook (כמו login) |
| `my_pantry_screen.dart` | 🔮 Glass | + NotebookBackground |
| `shopping_history_screen.dart` | 🃏 Cards | + NotebookBackground |
| `onboarding_screen.dart` | 📦 Basic | + Sticky colors |

### 2.7 Widgets משותפים חדשים

```dart
// AppSnackBar — במקום ~160 SnackBar ידניים
AppSnackBar.success(context, 'נשמר');
AppSnackBar.error(context, 'שגיאה');

// EmptyState — במקום לבנות מחדש בכל מסך
EmptyState(emoji: '🛒', title: 'אין רשימות', action: ...);

// SectionHeader — כותרת קטגוריה אחידה
SectionHeader(emoji: '🥛', title: 'חלב', count: 3, onTap: ...);
```

---

## 🟠 שלב 3 — ריפקטור מבני (יום 5-10)
> סיכון: בינוני. שינויים בקבצים פעילים.

### 3.1 פיצול מסכים ארוכים

| קובץ | שורות | פיצול |
|------|-------|-------|
| `active_shopping_screen.dart` | 2,020 | → screen (800) + item_tile (400) + progress_header (200) + dialogs (300) |
| `my_pantry_screen.dart` | 1,328 | → screen (600) + item_card (300) + header (200) |
| `settings_screen.dart` | 1,219 | → screen (400) + sections/ (5 × 150) |
| `shopping_lists_screen.dart` | 1,197 | → screen (500) + list_card (300) + filter_bar (200) |
| `shopping_list_details_screen.dart` | 1,166 | → screen (500) + item_row (300) + header (200) |
| `login_screen.dart` | 1,157 | → screen (400) + auth_form (300) + social_buttons (200) |
| `create_list_screen.dart` | 1,032 | → screen (500) + type_selector (300) |

### 3.2 פיצול providers ענקיים

**`shopping_lists_provider.dart` (1,520 שורות → 3 קבצים):**
```dart
// shopping_items_mixin.dart (~400 שורות)
mixin ShoppingItemsMixin on ChangeNotifier {
  addItemToList, addUnifiedItem, removeItemFromList,
  updateItemAt, updateItemById, toggleAllItemsChecked,
  markItemAsChecked, updateItemStatus
}

// collaborative_shopping_mixin.dart (~400 שורות)
mixin CollaborativeShoppingMixin on ChangeNotifier {
  startCollaborativeShopping, joinCollaborativeShopping,
  finishCollaborativeShopping, leaveCollaborativeShopping,
  cleanupAbandonedSessions, shareListToHousehold
}

// shopping_lists_provider.dart (~500 שורות)
class ShoppingListsProvider extends ChangeNotifier
    with ShoppingItemsMixin, CollaborativeShoppingMixin {
  loadLists, createList, deleteList, restoreList, updateList,
  archiveList, completeList, activateList, addToNextList,
  getRecentLists, getById, getListStats, getUnpurchasedItems
}
```

**`auth_service.dart` (1,159 → 2 קבצים):**
```
auth_service.dart (~600) — email login, register, session, password
social_auth_service.dart (~500) — Google Sign-In, Apple Sign-In
```

### 3.3 העברת ~150 מחרוזות hardcoded ל-AppStrings

| מסך | מחרוזות HC |
|-----|-----------|
| `login_screen.dart` | ~43 |
| `shopping_list_details_screen.dart` | ~42 |
| `settings_screen.dart` | ~31 |
| `who_brings_screen.dart` | ~16 |
| `shopping_summary_screen.dart` | ~15 |

### 3.4 מבנה תיקיות מעודכן

```
lib/screens/
├── auth/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── widgets/                ← auth_form, social_buttons
├── home/
│   ├── home_dashboard_screen.dart
│   └── widgets/                ← banners, cards
├── shopping/
│   ├── active/
│   │   ├── active_shopping_screen.dart
│   │   └── widgets/            ← item_tile, progress_header
│   ├── lists/
│   │   ├── shopping_lists_screen.dart
│   │   └── widgets/            ← list_card, filter_bar
│   ├── details/
│   │   └── widgets/            ← item_row, header
│   └── create/
├── pantry/
│   ├── my_pantry_screen.dart
│   └── widgets/                ← item_card, header
├── settings/
│   ├── settings_screen.dart
│   └── sections/               ← account, appearance, notifications
└── ...
```

---

## ⭐ שלב 4 — חווית משתמש מקצועית (יום 10-15)
> מה שהמשתמש **באמת מרגיש**.

### 4.1 Page Transitions

```dart
// lib/theme/app_transitions.dart
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required Widget page})
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

### 4.2 AnimatedList — מוצרים נכנסים/יוצאים עם אנימציה

```dart
// במקום ListView.builder רגיל ברשימת קניות
AnimatedList(
  key: _listKey,
  itemBuilder: (context, index, animation) =>
    SlideTransition(
      position: animation.drive(
        Tween(begin: Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: ItemTile(...),
    ),
)
```

### 4.3 Hero Animations — מעברים חלקים

```dart
// ברשימת קניות (shopping_list_tile):
Hero(
  tag: 'list-${list.id}',
  child: Material(child: ListTile(...)),
)

// בפרטי רשימה (details header):
Hero(
  tag: 'list-${widget.list.id}',
  child: Material(child: Header(...)),
)
```

### 4.4 Collapsing Headers (Slivers)

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(list.name),
        background: NotebookHeader(stats: stats),
      ),
    ),
    SliverPadding(
      padding: EdgeInsets.all(AppTokens.s16),
      sliver: SliverList(delegate: ...),
    ),
  ],
)
```

### 4.5 Platform-Adaptive UI

```dart
// iOS: Cupertino dialogs, bounce physics
// Android: Material dialogs, glow physics
showAdaptiveDialog(
  context: context,
  builder: (_) => AlertDialog.adaptive(...),
);

// Scroll physics
ListView(
  physics: Platform.isIOS
    ? BouncingScrollPhysics()
    : ClampingScrollPhysics(),
)
```

### 4.6 Lottie Animations

**מיקומים:**
| איפה | אנימציה | קובץ |
|------|---------|------|
| סיום קניות | confetti 🎉 | `shopping_complete.json` |
| רשימה ריקה | עגלה ריקה 🛒 | `empty_cart.json` |
| Onboarding | אנימציה לכל שלב | `onboarding_1-4.json` |
| Loading | לוגו מסתובב | `loading.json` |
| Error | 😕 פרצוף עצוב | `error.json` |
| הצלחת שיתוף | חמישייה ✋ | `high_five.json` |

**מקור:** lottiefiles.com (חינם, JSON קלילים)

### 4.7 Micro-Interactions

| פעולה | אפקט |
|-------|-------|
| הוספת מוצר | bounce-in + haptic light |
| סימון "קניתי" ✅ | check animation + strikethrough + haptic |
| מחיקה | slide-out + undo SnackBar |
| Pull to refresh | custom indicator עם לוגו |
| רשימה חדשה | scale-up + fade-in |
| שיתוף הצליח | confetti |
| scroll לסוף | "🎉 סיימת!" toast |

### 4.8 Native Splash Screen

```yaml
# pubspec.yaml
flutter_native_splash:
  color: "#FFF8E1"  # Sticky yellow background
  image: assets/images/splash_logo.png
  android_12:
    icon_background_color: "#FFF8E1"
    image: assets/images/splash_logo.png
```

### 4.9 Skeleton Loading (כבר חלקית ✅)

**להרחיב ל:**
- רשימת קניות ראשית
- מסך בית (dashboard cards)
- מזווה

### 4.10 Empty States מרשימים

```dart
EmptyState(
  lottie: 'assets/lottie/empty_cart.json', // במקום רק emoji
  title: 'עוד לא יצרת רשימה',
  subtitle: 'בוא ניצור את הרשימה הראשונה שלך! 🛒',
  action: StickyButton(
    label: 'צור רשימה',
    color: brand.stickyYellow,
    onTap: () => ...,
  ),
)
```

---

## 🔵 שלב 5 — הכנה להפצה (יום 15-20)
> בלי זה — לא נכנסים ל-Store.

### 5.1 🔴 Application ID (חובה!)

```kotlin
// android/app/build.gradle.kts
// לפני:
applicationId = "com.example.memozap"
// אחרי:
applicationId = "com.memozap.app"  // או "il.co.memozap"
```

**⚠️ חייבים לבחור לפני פרסום — לא ניתן לשנות אחר כך!**

```
// iOS: Bundle Identifier
// Runner.xcodeproj → Build Settings → PRODUCT_BUNDLE_IDENTIFIER
com.memozap.app
```

### 5.2 🔴 Release Signing

**Android:**
```bash
# צור keystore
keytool -genkey -v -keystore ~/memozap-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias memozap

# android/key.properties (לא ב-Git!)
storePassword=...
keyPassword=...
keyAlias=memozap
storeFile=/path/to/memozap-release.jks
```

```kotlin
// android/app/build.gradle.kts
val keystoreProperties = Properties().apply {
    load(FileInputStream(rootProject.file("key.properties")))
}

android {
    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true   // R8/ProGuard
            isShrinkResources = true
        }
    }
}
```

**iOS:**
- Apple Developer Account ($99/שנה)
- Certificates + Provisioning Profiles ב-Xcode
- או Fastlane לאוטומציה

### 5.3 🔴 אופטימיזציית תמונות

```
logo.png:     4,760KB → צריך ~150KB (WebP או PNG מוקטן)
snichel.png:    822KB → צריך ~100KB
```

**פתרון:**
```bash
# המר ל-WebP
cwebp -q 80 assets/images/logo.png -o assets/images/logo.webp
# או דחוס PNG
pngquant --quality=65-80 assets/images/logo.png
```

### 5.4 ProGuard / R8

```
# android/app/proguard-rules.pro
-keep class com.google.firebase.** { *; }
-keep class io.flutter.** { *; }
-dontwarn com.google.**
```

### 5.5 🔴 מודעות (AdMob)

```yaml
# pubspec.yaml
google_mobile_ads: ^5.1.0
```

```dart
// lib/services/ads_service.dart
class AdsService {
  static const _bannerAdUnit = 'ca-app-pub-XXXX/YYYY'; // real
  static const _rewardedAdUnit = 'ca-app-pub-XXXX/ZZZZ';
  static const _testBannerAdUnit = 'ca-app-pub-3940256099942544/6300978111'; // test

  // וידאו לפני קנייה
  Future<void> showRewardedAd({required VoidCallback onComplete}) async {
    await RewardedAd.load(
      adUnitId: kReleaseMode ? _rewardedAdUnit : _testRewardedAdUnit,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => ad.show(onUserEarnedReward: (_, __) => onComplete()),
        onAdFailedToLoad: (_) => onComplete(), // fallback: skip ad
      ),
    );
  }
}
```

**תוכנית מודעות:**
- וידאו מתוגמל לפני תחילת קנייה (כמו שתכננת)
- Banner קטן במסך הבית (לא invasive)
- **אין** interstitials באמצע פעולות (מעצבן משתמשים)

### 5.6 Privacy Policy + Terms

**חובה לשני ה-Stores:**
- [ ] דף Privacy Policy (אפשר ב-GitHub Pages)
- [ ] דף Terms of Use
- [ ] קישור מתוך האפליקציה (settings)
- [ ] GDPR compliance: כפתור "מחק את החשבון שלי"

### 5.7 Store Listing

**Google Play:**
- [ ] App name: `MemoZap – רשימת קניות משפחתית`
- [ ] Short description (80 chars): `ניהול קניות חכם: רשימות משותפות, מזווה, והצעות מותאמות`
- [ ] Full description (4000 chars)
- [ ] Feature graphic (1024×500 px)
- [ ] Screenshots (8 מסכים, טלפון + טאבלט)
- [ ] App icon (512×512 px)
- [ ] Category: Shopping
- [ ] Content rating questionnaire
- [ ] Data safety form

**App Store:**
- [ ] App name
- [ ] Subtitle (30 chars)
- [ ] Keywords (100 chars)
- [ ] Screenshots (6.7" + 5.5" + iPad)
- [ ] App Preview video (אופציונלי אבל מומלץ!)
- [ ] Privacy details
- [ ] Age rating

### 5.8 App Icon מקצועי

```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"  # 1024×1024
  adaptive_icon_background: "#FFF8E1"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
```

**צריך:**
- [ ] אייקון 1024×1024 (חד, פשוט, זכיר)
- [ ] Adaptive icon ל-Android (foreground + background)
- [ ] הנוכחי מספיק טוב? אם לא — Fiverr/Canva

### 5.9 Firebase Performance + Remote Config

```yaml
firebase_performance: ^0.10.0
firebase_remote_config: ^5.0.0
```

**Remote Config — לשלוט בלי עדכון:**
- min_app_version (Force update)
- ad_frequency
- feature_flags (הפעל/כבה פיצ'רים)
- maintenance_mode

---

## 🟢 שלב 6 — בדיקות (יום 20-25)

### 6.1 Unit Tests (מינימום לפני הפצה)

| תחום | מה לבדוק | עדיפות |
|------|---------|--------|
| Models | fromMap/toMap/copyWith | 🔴 |
| Providers | CRUD operations | 🔴 |
| Services | auth, sharing | 🟡 |
| Utils | formatters, validators | 🟡 |

**כבר יש:** 9 test files — להרחיב ל-~20

### 6.2 Widget Tests

```dart
testWidgets('shopping list shows items', (tester) async {
  await tester.pumpWidget(MaterialApp(home: ShoppingListsScreen()));
  expect(find.text('רשימת קניות'), findsOneWidget);
});
```

### 6.3 Integration Tests

```dart
// test_driver/app_test.dart
void main() {
  group('Full shopping flow', () {
    testWidgets('create list → add items → shop → complete', ...);
  });
}
```

### 6.4 Manual Testing Checklist

- [ ] **אנדרואיד:** Pixel (מודרני) + Samsung ישן (תאימות)
- [ ] **iOS:** iPhone 15 + iPhone SE (מסך קטן)
- [ ] **RTL:** כל המסכים נראים טוב בעברית
- [ ] **Dark mode:** כל המסכים
- [ ] **Offline:** מה קורה בלי אינטרנט?
- [ ] **Rotation:** מסכים ראשיים עובדים ב-landscape?
- [ ] **Accessibility:** font size גדול, screen reader
- [ ] **Low memory:** אפליקציה לא קורסת
- [ ] **First launch:** onboarding חלק
- [ ] **Deep links:** (אם יש)

---

## 🟣 שלב 7 — פיצ'רים לפני הפצה (יום 25-35)

### 7.1 מזווה → רשימת קניות
- כפתור "חסר? הוסף לרשימה" בכרטיס מזווה
- בחירת רשימה קיימת
- **ROI גבוה:** מחבר שני חלקי האפליקציה

### 7.2 חיפוש גלובלי
- search bar ב-home
- חיפוש ברשימות + מזווה + קטלוג
- תוצאות מקובצות לפי מקור

### 7.3 Delete Account (חובה GDPR + App Store)
- כפתור בהגדרות
- מוחק: user, data, auth
- confirmation dialog
- re-authentication נדרש

### 7.4 Force Update
- Remote Config: `min_version`
- מסך "יש גרסה חדשה" עם קישור ל-Store

### 7.5 Rate App / Feedback
- אחרי 5 קניות מוצלחות → "אהבת? דרג אותנו!"
- `in_app_review` package

### 7.6 Onboarding שיפור
- Lottie animations
- skip button
- progress indicator

### 7.7 Share App
- "הזמן חברים" → deep link ל-Store

---

## ⏱️ הערכת זמנים

| שלב | זמן | תיאור |
|-----|------|-------|
| 1. ניקוי | 2 ימים | מחיקת ~8,500 שורות מתות |
| 2. Design System | 3 ימים | tokens, colors, typography |
| 3. ריפקטור מבני | 5 ימים | פיצול קבצים, providers |
| 4. חווית משתמש | 5 ימים | animations, transitions, Lottie |
| 5. הכנה להפצה | 5 ימים | signing, ads, store listing |
| 6. בדיקות | 5 ימים | unit + widget + manual |
| 7. פיצ'רים | 10 ימים | מזווה→רשימה, חיפוש, delete account |
| **סה"כ** | **~35 ימים** | |

---

## 📋 Checklist להפצה

### לפני Google Play:
- [ ] applicationId ≠ com.example
- [ ] Release keystore + signing
- [ ] ProGuard/R8
- [ ] App icon (adaptive)
- [ ] Screenshots (6+ מסכים)
- [ ] Privacy policy URL
- [ ] Data safety form
- [ ] Content rating
- [ ] Feature graphic
- [ ] Remove all print() statements
- [ ] logo.png < 200KB
- [ ] `flutter build appbundle --release`

### לפני App Store:
- [ ] Apple Developer Account
- [ ] Bundle ID ≠ com.example
- [ ] Certificates + Profiles
- [ ] App icon 1024×1024
- [ ] Screenshots (3 sizes)
- [ ] Privacy details
- [ ] "Delete Account" button
- [ ] Age rating
- [ ] `flutter build ipa --release`

### לשניהם:
- [ ] Crashlytics working
- [ ] Analytics events defined
- [ ] Remote Config setup
- [ ] Ads tested with test IDs
- [ ] No debug prints in release
- [ ] All TODO/FIXME resolved
- [ ] Dark mode tested
- [ ] RTL tested
- [ ] Offline behavior tested

---

## ✅ כללי עבודה

1. **commit אחרי כל שינוי** — קל ל-revert
2. **בדוק באמולטור** אחרי כל שלב
3. **לא לשנות לוגיקה בזמן ריפקטור** — רק מבנה ועיצוב
4. **קובץ אחד בכל פעם**
5. **`dart analyze`** אחרי כל commit
6. **`flutter test`** לפני push
7. **Branch per step** — שלב 1 ב-branch, merge ל-main
