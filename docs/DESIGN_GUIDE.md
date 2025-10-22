# 📝 Sticky Notes Design System - AI Reference

> **Purpose:** Quick design reference for AI assistants  
> **Updated:** 22/10/2025 | **Version:** 2.2 - File Locations Enhanced

---

## 🎯 Quick Reference - 30 Seconds

### Core Rules

1. **All UI screens:** `kPaperBackground` + `NotebookBackground()`
2. **All content:** Wrap in `StickyNote`
3. **All buttons:** Use `StickyButton` (NOT ElevatedButton)
4. **Max 3 colors** per screen
5. **Rotations:** -0.03 to 0.03 radians

### File Locations

#### 🎨 Core Components
| Component | Path |
|-----------|------|
| **Constants** | `lib/core/ui_constants.dart` |
| **Theme** | `lib/theme/app_theme.dart` |

#### 📝 Sticky Notes System
| Component | Path |
|-----------|------|
| **NotebookBackground** | `lib/widgets/common/notebook_background.dart` |
| **StickyNote** | `lib/widgets/common/sticky_note.dart` |
| **StickyButton** | `lib/widgets/common/sticky_button.dart` |

#### 🧩 Reusable Widgets
| Component | Path |
|-----------|------|
| **DashboardCard** | `lib/widgets/common/dashboard_card.dart` |
| **TappableCard** | `lib/widgets/common/tappable_card.dart` |
| **BenefitTile** | `lib/widgets/common/benefit_tile.dart` |
| **AnimatedButton** | `lib/widgets/common/animated_button.dart` |

#### ⏳ Loading States
| Component | Path |
|-----------|------|
| **Skeleton** | `lib/widgets/skeleton_loading.dart` |

---

## 📊 Complete Constants Reference

### Colors

```dart
// Base
kPaperBackground = Color(0xFFFAF8F3)  // Cream paper
kNotebookBlue = Color(0xFF9FC5E8)     // Blue lines
kNotebookRed = Color(0xFFE57373)      // Red margin line

// Sticky Notes
kStickyYellow = Color(0xFFFFF59D)     // Logo, primary actions
kStickyPink = Color(0xFFF8BBD0)       // Reminders, alerts
kStickyGreen = Color(0xFFC5E1A5)      // Success, confirmations
kStickyCyan = Color(0xFF80DEEA)       // Info, help
kStickyPurple = Color(0xFFCE93D8)     // Creative, new
kStickyOrange = Color(0xFFFFCC80)     // Warnings
```

### Spacing

```dart
kSpacingTiny = 4.0         // Minimal
kSpacingXTiny = 6.0        // Very small
kSpacingSmall = 8.0        // Small ⭐ (default compact)
kSpacingXSmall = 10.0      // Small-medium
kSpacingSmallPlus = 12.0   // Between small-medium
kSpacingMedium = 16.0      // Standard ⭐
kSpacingLarge = 24.0       // Large ⭐ (sections)
kSpacingXLarge = 32.0      // Extra large
kSpacingXXLarge = 40.0     // Huge
kSpacingXXXLarge = 48.0    // Massive
```

### Sizes

```dart
// Buttons
kButtonHeight = 48.0            // Standard (accessibility)
kButtonHeightSmall = 36.0       // Small button
kButtonHeightLarge = 56.0       // Large button

// Sticky Notes
kStickyLogoSize = 120.0         // Logo note size
kStickyLogoIconSize = 60.0      // Icon inside logo
kStickyNoteRadius = 2.0         // Corner radius
kStickyButtonRadius = 4.0       // Button radius
kStickyMaxRotation = 0.03       // Max rotation (radians)

// Icons
kIconSize = 24.0                // Standard
kIconSizeMedium = 20.0          //  Medium
kIconSizeSmall = 16.0           // Small
kIconSizeLarge = 32.0           // Large

// Accessibility
kMinTouchTarget = 48.0          // Minimum clickable size
```

### Shadows

```dart
// Primary Shadow
BoxShadow(
  color: Colors.black.withValues(alpha: 0.2),  // kStickyShadowPrimaryOpacity
  blurRadius: 10.0,                             // kStickyShadowPrimaryBlur
  offset: Offset(2.0, 6.0),                     // Primary offset
)

// Secondary Shadow
BoxShadow(
  color: Colors.black.withValues(alpha: 0.1),  // kStickyShadowSecondaryOpacity
  blurRadius: 20.0,                             // kStickyShadowSecondaryBlur
  offset: Offset(0, 12.0),                      // Secondary offset
)
```

### Animations

```dart
kAnimationDurationFast = Duration(milliseconds: 150)    // Buttons ⭐
kAnimationDurationShort = Duration(milliseconds: 200)   // Quick
kAnimationDurationMedium = Duration(milliseconds: 300)  // Cards ⭐
kAnimationDurationLong = Duration(milliseconds: 500)    // Transitions
kAnimationDurationSlow = Duration(milliseconds: 2500)   // Shimmer

// Curves (Flutter built-in)
Curves.easeInOut   // Default ⭐
Curves.easeOut     // Entrance
Curves.easeIn      // Exit
```

### Opacity Values

```dart
kOpacityMinimal = 0.05      // Very subtle effects
kOpacityVeryLow = 0.15      // Subtle glow
kOpacityLight = 0.2         // Gentle borders
kOpacityLow = 0.3           // Light backgrounds
kOpacityMedium = 0.5        // Overlays
kOpacityHigh = 0.6          // Secondary text
kOpacityMediumHigh = 0.85   // Light secondary text
kOpacityVeryHigh = 0.9      // Almost full
```

---

## 🧩 Components - When to Use

### Decision Tree

```
Need background? → NotebookBackground
Need content card? → StickyNote
Need button? → StickyButton (primary) or StickyButtonSmall (secondary)
Need logo? → StickyNoteLogo
Need loading? → Skeleton widgets
Need error? → StickyNote (pink) + error message
```

### NotebookBackground

**When:** Every screen with Sticky Notes design  
**Location:** `lib/widgets/common/notebook_background.dart`

```dart
Scaffold(
  backgroundColor: kPaperBackground, // ⚠️ REQUIRED!
  body: Stack(
    children: [
      NotebookBackground(), // ⚠️ FIRST in Stack!
      SafeArea(child: YourContent()),
    ],
  ),
)
```

### StickyNote

**When:** Any content card, info box, text field wrapper  
**Location:** `lib/widgets/common/sticky_note.dart`

```dart
StickyNote(
  color: kStickyPink,
  rotation: -0.02,          // Vary between notes
  child: YourContent(),
)
```

**Rotation patterns:**

- Logo: `-0.03`
- Note 1: `0.01`
- Note 2: `-0.015`
- Note 3: `0.01`
- Alternate direction between adjacent notes!

### StickyButton

**When:** All buttons (NOT ElevatedButton)  
**Location:** `lib/widgets/common/sticky_button.dart`

```dart
// Primary button (48px height)
StickyButton(
  color: Colors.green,
  label: 'התחברות',
  icon: Icons.login,
  onPressed: () => _handleLogin(), // ⚠️ WRAP async functions!
)

// Secondary button (white background)
StickyButton(
  color: Colors.white,
  textColor: Colors.green,
  label: 'הרשמה',
  onPressed: () => _handleRegister(),
)

// Small button (36px height)
StickyButtonSmall(
  label: 'ביטול',
  icon: Icons.close,
  onPressed: () => Navigator.pop(context),
)

// Compact button (44px - still accessible)
StickyButton(
  label: 'המשך',
  height: 44,
  onPressed: () => _handleNext(),
)
```

**⚠️ CRITICAL - Async callbacks:**

```dart
// ❌ WRONG - Type error!
onPressed: _handleLogin  // Future<void> Function()

// ✅ CORRECT - Wrapped!
onPressed: () => _handleLogin()  // void Function()
```

### StickyNoteLogo

**When:** Logo or central icon on screen  
**Location:** `lib/widgets/common/sticky_note.dart`

```dart
StickyNoteLogo(
  color: kStickyYellow,
  icon: Icons.shopping_basket_outlined,
  iconColor: Colors.green,
  rotation: -0.03,
)

// Compact version (15% smaller)
Transform.scale(
  scale: 0.85,
  child: StickyNoteLogo(...),
)
```

---

## 🎨 Color Usage Guide

### Color Decision Tree

```
Primary action? → kStickyYellow
Success/confirmation? → kStickyGreen
Alert/reminder? → kStickyPink
Info/help? → kStickyCyan
Creative/new? → kStickyPurple
Warning? → kStickyOrange
```

### Color Combinations (Max 3 per screen)

```dart
// Example 1: Welcome screen
kStickyYellow (logo) + kStickyPink (feature) + kStickyGreen (feature)

// Example 2: Login screen
kStickyYellow (logo) + kStickyGreen (login button) + kStickyPink (link)

// Example 3: Dashboard
kStickyCyan (info cards) + kStickyYellow (action) + kStickyGreen (status)
```

---

## 📐 Compact Design Pattern

**Goal:** Fit entire screen without scrolling

### Techniques

1. **Padding:** `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`
2. **Spacing:** `SizedBox(height: 8)` between elements
3. **Logo:** `Transform.scale(scale: 0.85)`
4. **Buttons:** `height: 44` (instead of 48)
5. **Font sizes:** `24` (title), `14` (body), `11` (small)
6. **Backup:** Always wrap in `SingleChildScrollView`

### Template

```dart
SafeArea(
  child: Center( // ⚠️ Centers vertically!
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Transform.scale(scale: 0.85, child: StickyNoteLogo(...)),
          SizedBox(height: 8),
          StickyNote(...),
          SizedBox(height: 8),
          StickyButton(height: 44, ...),
        ],
      ),
    ),
  ),
)
```

**See:** `lib/screens/auth/login_screen.dart` (perfect example!)

---

## 🔄 State Patterns

### Loading States

**Use:** Skeleton screens (NOT CircularProgressIndicator)  
**Location:** `lib/widgets/skeleton_loading.dart`

```dart
if (provider.isLoading && provider.isEmpty) {
  return ShoppingListSkeleton(); // ⭐ USE THIS!
}
```

**Available skeletons:**

- `ShoppingListSkeleton()` - Shopping lists
- `ProductsSkeletonList()` - Product list
- `ProductsSkeletonGrid()` - Product grid
- `CategoriesSkeleton()` - Categories
- `SkeletonBox()` - Custom

### Error States

**Pattern:**

```dart
if (provider.hasError) {
  return StickyNote(
    color: kStickyPink, // Pink for alerts
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48),
        SizedBox(height: 8),
        Text(
          provider.errorMessage ?? 'שגיאה',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        StickyButton(
          label: 'נסה שוב',
          height: 44,
          onPressed: () => provider.retry(),
        ),
      ],
    ),
  );
}
```

### Empty States

**Pattern:**

```dart
if (provider.isEmpty) {
  return Center(
    child: StickyNote(
      color: kStickyCyan, // Cyan for info
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64),
          SizedBox(height: 8),
          Text('אין פריטים'),
        ],
      ),
    ),
  );
}
```

### Data State

```dart
// Normal content display
return ListView.builder(
  itemCount: provider.items.length,
  itemBuilder: (context, index) {
    return StickyNote(
      color: _getColorForIndex(index),
      rotation: _getRotationForIndex(index),
      child: ItemContent(provider.items[index]),
    );
  },
);
```

---

## 🌙 Dark Mode

**Full support!** App adapts automatically.

### What Changes

- Backgrounds (surfaces)
- Text colors
- Borders and shadows

### What Stays Fixed

- Sticky Notes colors (kStickyYellow, kStickyPink, etc.)
- Notebook background (kPaperBackground)
- Notebook lines (kNotebookBlue, kNotebookRed)

**Implementation:** `lib/theme/app_theme.dart`

```dart
// Light and Dark themes available
AppTheme.lightTheme
AppTheme.darkTheme

// + Dynamic Color support (Android 12+ Material You)
AppTheme.fromDynamicColors(dynamicScheme, dark: true)
```

---

## 🎬 Animation Guidelines

### Duration Selection

```dart
// Buttons, quick interactions
duration: kAnimationDurationFast // 150ms ⭐

// Cards, standard transitions
duration: kAnimationDurationMedium // 300ms ⭐

// Skeleton shimmer
duration: kAnimationDurationSlow // 2500ms
```

### Curve Selection

```dart
// Default (most cases)
curve: Curves.easeInOut ⭐

// Element appearing
curve: Curves.easeOut

// Element disappearing
curve: Curves.easeIn
```

### Example

```dart
AnimatedOpacity(
  opacity: _visible ? 1.0 : 0.0,
  duration: kAnimationDurationMedium,
  curve: Curves.easeInOut,
  child: child,
)
```

---

## ♿ Accessibility Requirements

### Touch Targets

- **Buttons:** 48px minimum (44px acceptable for compact)
- **All interactive elements:** 48x48px minimum
- **Spacing:** Consider for tap accuracy

### Text Sizes

- **Minimum:** 11px (links, captions)
- **Body:** 14-16px
- **Titles:** 24px

### Contrast

- All Sticky Notes colors tested with WCAG 2.0
- Black text (87% opacity) on light backgrounds ✅
- Dark text (54% opacity) for secondary text ✅

### Semantics

- All StickyButton widgets include `Semantics` automatically
- Use clear labels for screen readers

---

## ❌ Anti-Patterns - DO NOT

### 1. Wrong Components

```dart
// ❌ NEVER use regular Material buttons
ElevatedButton(...)
TextButton(...)
OutlinedButton(...)

// ✅ ALWAYS use StickyButton
StickyButton(...)
```

### 2. Missing Background

```dart
// ❌ WRONG - No background!
Scaffold(
  body: SafeArea(child: Content()),
)

// ✅ CORRECT - Full sticky notes design!
Scaffold(
  backgroundColor: kPaperBackground,
  body: Stack(
    children: [
      NotebookBackground(),
      SafeArea(child: Content()),
    ],
  ),
)
```

### 3. Too Many Colors

```dart
// ❌ WRONG - 5 colors!
kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan, kStickyPurple

// ✅ CORRECT - Max 3 colors!
kStickyYellow, kStickyPink, kStickyGreen
```

### 4. Extreme Rotations

```dart
// ❌ WRONG - Too much rotation!
rotation: 0.1 // 5.7 degrees - looks broken

// ✅ CORRECT - Subtle rotation!
rotation: -0.02 // 1.1 degrees - looks natural
```

### 5. Deprecated APIs

```dart
// ❌ DEPRECATED (Flutter 3.22+)
Colors.black.withOpacity(0.5)

// ✅ USE INSTEAD
Colors.black.withValues(alpha: 0.5)
```

### 6. Async Callback Errors

```dart
// ❌ TYPE ERROR
StickyButton(onPressed: _handleLogin) // Future<void> Function()

// ✅ CORRECT
StickyButton(onPressed: () => _handleLogin()) // void Function()
```

### 7. No Skeleton Screens

```dart
// ❌ OLD PATTERN
if (isLoading) return CircularProgressIndicator();

// ✅ NEW PATTERN
if (isLoading) return ShoppingListSkeleton();
```

---

## 🔧 Screen Update Checklist

When converting existing screen to Sticky Notes design:

### 1. Background

- [ ] `backgroundColor: kPaperBackground` on Scaffold
- [ ] `Stack` + `NotebookBackground()` as first child
- [ ] `SafeArea` wraps content

### 2. Content

- [ ] All `Card` → `StickyNote`
- [ ] All `Container` with content → `StickyNote`
- [ ] Colors: max 3 per screen
- [ ] Rotations: vary between adjacent notes (-0.03 to 0.03)

### 3. Buttons

- [ ] All `ElevatedButton` → `StickyButton`
- [ ] All `TextButton` → `StickyButton(color: Colors.white)`
- [ ] All async callbacks wrapped: `() => func()`
- [ ] Height: 48px (or 44px for compact)

### 4. Loading/Error/Empty

- [ ] Loading: `ShoppingListSkeleton()` (not CircularProgressIndicator)
- [ ] Error: `StickyNote` (pink) + error message + retry button
- [ ] Empty: `StickyNote` (cyan) + icon + message

### 5. Compact (if needed)

- [ ] Padding: `symmetric(horizontal: 16, vertical: 8)`
- [ ] Spacing: `SizedBox(height: 8)`
- [ ] Logo: `Transform.scale(scale: 0.85)`
- [ ] Buttons: `height: 44`

---

## 🐛 Common Issues & Solutions

### Issue 1: withOpacity deprecated

```dart
// ❌ Error
Colors.white.withOpacity(0.7)

// ✅ Fix
Colors.white.withValues(alpha: 0.7)
```

### Issue 2: Async callback error

```dart
// ❌ Error
StickyButton(onPressed: _handleLogin)

// ✅ Fix
StickyButton(onPressed: () => _handleLogin())
```

### Issue 3: Content doesn't fit on screen

```dart
// ✅ Apply compact pattern:
1. Reduce padding: horizontal: 16, vertical: 8
2. Reduce spacing: SizedBox(height: 8)
3. Scale logo: Transform.scale(scale: 0.85)
4. Reduce button height: 44
5. Wrap in SingleChildScrollView as backup
```

### Issue 4: Too much scrolling

```dart
// ✅ Use Center to vertically center content
SafeArea(
  child: Center( // ← This centers vertically!
    child: SingleChildScrollView(...),
  ),
)
```

---

## 📋 Code Examples Index

| Need                         | See File                                          |
| ---------------------------- | ------------------------------------------------- |
| **Perfect compact screen**   | `lib/screens/auth/login_screen.dart`              |
| **Welcome screen**           | `lib/screens/welcome_screen.dart`                 |
| **All constants**            | `lib/core/ui_constants.dart`                      |
| **Theme & Dark Mode**        | `lib/theme/app_theme.dart`                        |
| **StickyButton usage**       | `lib/widgets/common/sticky_button.dart`           |
| **StickyNote usage**         | `lib/widgets/common/sticky_note.dart`             |
| **Skeleton screens**         | `lib/widgets/skeleton_loading.dart`               |
| **State management pattern** | `lib/screens/shopping/shopping_lists_screen.dart` |

---

## 🎯 Quick Debugging

### Screen doesn't look right?

```
Check order:
1. ✅ Scaffold backgroundColor: kPaperBackground
2. ✅ Stack with NotebookBackground FIRST
3. ✅ SafeArea wraps content
4. ✅ All content in StickyNote
5. ✅ All buttons are StickyButton
```

### Colors look wrong?

```
1. Max 3 colors per screen?
2. Using kSticky* constants?
3. Colors from ui_constants.dart?
```

### Buttons not working?

```
1. Async functions wrapped? () => func()
2. Using StickyButton (not ElevatedButton)?
3. Height reasonable? (44-56px)
```

### Content too cramped/spaced?

```
Cramped → Increase spacing: kSpacingMedium (16px)
Too spaced → Use compact pattern: kSpacingSmall (8px)
```

---

## 📈 Version History

### v2.2 - 22/10/2025 🆕 **LATEST - File Locations Enhanced**

- 🎯 Reorganized File Locations with clear categories
- ➕ Added missing widgets: DashboardCard, TappableCard, BenefitTile, AnimatedButton
- 📂 Better organization: Core Components, Sticky Notes System, Reusable Widgets, Loading States
- 💡 Result: Easier to find components!

---

**Version:** 2.2  
**Created:** 15/10/2025 | **Updated:** 22/10/2025  
**Purpose:** AI-optimized Sticky Notes Design System reference  
**Target:** Claude and AI assistants - understand design in 2 minutes
