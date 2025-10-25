# 🎨 DESIGN.md - MemoZap UI/UX Guide
> **For AI Agents** | Focus: Sticky Notes Design System | Updated: 25/10/2025

---

## 🎯 Design Philosophy

**UI First → Functionality Second**
- Always render full visual before connecting logic
- Every screen must feel part of same system
- Light, fluid, RTL-native experience

---

## 🌟 Sticky Notes Design System

### Core Concept
מערכת עיצוב המבוססת על **פתקיות דביקות** (Post-it Notes):
- צבעים זוהרים
- סיבוב קל (rotation)
- צללים עדינים
- רקע מחברת משובצת

### Color Palette

```dart
// Primary Colors
kStickyYellow  = #FFF59D  // Logo, Primary actions
kStickyPink    = #F48FB1  // Alerts, Delete
kStickyGreen   = #A5D6A7  // Success, Add
kStickyCyan    = #80DEEA  // Info, Secondary
kStickyPurple  = #CE93D8  // Creative features
kStickyOrange  = #FFAB91  // Warnings

// Background
kPaperBackground     = #F5F5F5  // Light mode
kDarkPaperBackground = #1E1E1E  // Dark mode
```

**Rules:**
- Max 3 colors per screen
- Yellow = main actions
- Pink = delete/alerts
- Green = success/add
- Cyan = info
- Purple = creative
- Orange = warnings

### Spacing (8dp Grid)

```dart
kSpacingXTiny  = 4px   // Extra tiny
kSpacingTiny   = 6px   // Tiny
kSpacingSmall  = 8px   // Small
kSpacingMedium = 16px  // Default ⭐
kSpacingLarge  = 24px  // Large
kSpacingXLarge = 32px  // Extra large
```

### Sizes

```dart
kButtonHeight       = 48px  // Standard
kButtonHeightSmall  = 36px  // Compact
kButtonHeightLarge  = 56px  // Prominent
kMinTouchTarget     = 44px  // Accessibility
```

---

## 🧱 Core Components

### 1️⃣ NotebookBackground

```dart
// ✅ CORRECT - with Stack
Scaffold(
  body: Stack(
    children: [
      const NotebookBackground(),
      CustomScrollView(...),
    ],
  ),
)

// ❌ WRONG - with child
NotebookBackground(child: ...) // No child parameter!
```

### 2️⃣ StickyNote

```dart
StickyNote(
  color: kStickyYellow,
  rotation: 0.01,  // -0.03 to 0.03
  width: 200,
  child: Text('תוכן'),
)
```

### 3️⃣ StickyButton

```dart
// ✅ Standard
StickyButton(
  text: 'הוסף',
  color: kStickyGreen,
  onPressed: () {},
)

// ✅ With icon
StickyButton.icon(
  icon: Icons.add,
  text: 'הוסף',
  color: kStickyGreen,
  onPressed: () {},
)
```

### 4️⃣ StickyNoteLogo

```dart
StickyNoteLogo(
  icon: Icons.shopping_cart,
  color: kStickyCyan,
  size: 48,
)
```

---

## 🇮🇱 RTL & Hebrew

### Text Direction

```dart
// ✅ ALWAYS for Hebrew
Directionality(
  textDirection: TextDirection.rtl,
  child: Text('עברית'),
)

// ✅ Auto from l10n
Text(AppLocalizations.of(context)!.title)
```

### Layout Direction

```dart
// ✅ Use EdgeInsetsDirectional
Padding(
  padding: EdgeInsetsDirectional.only(
    start: 16,  // Right in RTL
    end: 8,     // Left in RTL
  ),
)

// ✅ Icon mirroring
Icon(Icons.arrow_forward) // Auto-mirrors
```

---

## 🌓 Dark Mode

**CRITICAL:** Sticky colors stay FIXED in both modes!

```dart
// ✅ Adaptive text
Text(
  'טקסט',
  style: TextStyle(
    color: Theme.of(context).textTheme.bodyLarge?.color,
  ),
)

// ❌ NEVER change Sticky colors
Container(
  color: kStickyCyan, // Same in both modes!
)
```

---

## 📐 Layout Patterns

### Standard Screen

```dart
Scaffold(
  backgroundColor: kPaperBackground,
  appBar: AppBar(title: Text('כותרת')),
  body: Stack(
    children: [
      const NotebookBackground(),
      CustomScrollView(...),
    ],
  ),
)
```

### Grid (2 columns)

```dart
GridView.builder(
  padding: EdgeInsets.all(kSpacingMedium),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.0,
    crossAxisSpacing: kSpacingMedium,
    mainAxisSpacing: kSpacingMedium,
  ),
  itemBuilder: (context, index) {
    return StickyNote(
      color: colors[index % colors.length],
      rotation: rotations[index % rotations.length],
      child: _buildCard(items[index]),
    );
  },
)
```

### List (vertical)

```dart
ListView.separated(
  padding: EdgeInsets.all(kSpacingMedium),
  itemCount: items.length,
  separatorBuilder: (_, __) => SizedBox(height: kSpacingSmall),
  itemBuilder: (context, index) {
    return StickyNote(
      color: kStickyYellow,
      child: ListTile(
        title: Text(items[index].name),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  },
)
```

---

## 🎭 UI States

### Empty State

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.inbox, size: 64, color: Colors.grey),
      SizedBox(height: kSpacingMedium),
      Text('אין פריטים', style: TextStyle(fontSize: 18)),
      SizedBox(height: kSpacingSmall),
      Text('לחץ על + להוספה', style: TextStyle(color: Colors.grey)),
    ],
  ),
)
```

### Loading State

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircularProgressIndicator(),
      SizedBox(height: kSpacingMedium),
      Text('טוען...'),
    ],
  ),
)
```

### Error State

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.error_outline, size: 64, color: kStickyPink),
      SizedBox(height: kSpacingMedium),
      Text('שגיאה', style: TextStyle(fontSize: 18)),
      SizedBox(height: kSpacingSmall),
      StickyButton(
        text: 'נסה שוב 🔄',
        color: kStickyCyan,
        onPressed: () => _retry(),
      ),
    ],
  ),
)
```

---

## ✨ Animations

### Fade In

```dart
AnimatedOpacity(
  opacity: _visible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 250),
  child: Widget,
)
```

### Slide In

```dart
SlideTransition(
  position: _animation.drive(
    Tween(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ),
  ),
  child: Widget,
)
```

### Scale In

```dart
ScaleTransition(
  scale: CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  ),
  child: Widget,
)
```

**Rules:**
- Duration: 150-300ms
- Use easing curves (easeOut, easeInOut)
- Micro-animations only (subtle)

---

## 🔤 Typography

### Font Family

```dart
GoogleFonts.assistant()  // Hebrew
GoogleFonts.montserrat() // English
```

### Text Styles

```dart
// Headline
style: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
)

// Body
style: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
)

// Caption
style: TextStyle(
  fontSize: 12,
  color: Colors.grey[600],
)
```

### Contrast

- Minimum ratio: 4.5:1 (WCAG AA)
- Use `Theme.of(context).textTheme` for adaptive colors

---

## 🎯 Icons

### Sources

1. **Material Icons** (built-in)
2. **Lucide Icons** (package)
3. **Custom SVG** (assets/)

### Usage

```dart
// ✅ Standard
Icon(Icons.shopping_cart, size: 24)

// ✅ With color
Icon(Icons.add, color: kStickyGreen)

// ✅ In button
IconButton(
  icon: Icon(Icons.delete, color: kStickyPink),
  onPressed: () {},
)
```

---

## ♿ Accessibility

### Touch Targets

- Minimum: 44x44 dp (iOS) / 48x48 dp (Android)
- Use `kMinTouchTarget = 44.0`

### Semantic Labels

```dart
Semantics(
  label: 'הוסף פריט לרשימה',
  button: true,
  child: IconButton(...),
)
```

### Focus Order

```dart
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(...),
)
```

---

## ❌ Common Mistakes

### 1. Background Usage

```dart
// ❌ WRONG
NotebookBackground(
  child: CustomScrollView(...),
)

// ✅ CORRECT
Stack(
  children: [
    const NotebookBackground(),
    CustomScrollView(...),
  ],
)
```

### 2. Hardcoded Strings

```dart
// ❌ WRONG
Text('רשימת קניות')

// ✅ CORRECT
Text(AppLocalizations.of(context)!.shoppingList)
```

### 3. Fixed Colors

```dart
// ❌ WRONG
Text('טקסט', style: TextStyle(color: Colors.black))

// ✅ CORRECT
Text('טקסט', style: Theme.of(context).textTheme.bodyLarge)
```

### 4. Non-RTL Padding

```dart
// ❌ WRONG
EdgeInsets.only(left: 16)

// ✅ CORRECT
EdgeInsetsDirectional.only(start: 16)
```

### 5. Wrong Button Type

```dart
// ❌ WRONG
ElevatedButton(...)
TextButton(...)

// ✅ CORRECT
StickyButton(...)
```

---

## ✅ Design Checklist

### Before Shipping Screen:
- [ ] Uses NotebookBackground with Stack
- [ ] All text wrapped in Directionality(RTL)
- [ ] No hardcoded Hebrew strings
- [ ] Uses Sticky colors (max 3 per screen)
- [ ] Spacing uses kSpacing* constants
- [ ] Buttons are StickyButton (not ElevatedButton)
- [ ] Icons use Material Icons or custom
- [ ] Handles Empty/Loading/Error states
- [ ] Touch targets ≥ 44x44 dp
- [ ] Works in Dark Mode
- [ ] Tested with Hebrew text
- [ ] Animations < 300ms
- [ ] Text contrast ratio ≥ 4.5:1

---

## 🔗 Related Docs

| Need | See |
|------|-----|
| Code patterns | `CODE.md` |
| Firebase/Security | `TECH.md` |
| MCP tools | `GUIDE.md` |
| Past mistakes | `LESSONS_LEARNED.md` |

---

**📍 Location:** `C:\projects\salsheli\docs\DESIGN.md`  
**📅 Version:** 1.0  
**✍️ Updated:** 25/10/2025

---

## 💡 Quick Tips

1. **Start with UI** - Build skeleton first, logic later
2. **3 colors max** - Keep it simple
3. **RTL always** - Test with Hebrew immediately
4. **States matter** - Empty, Loading, Error are mandatory
5. **Sticky buttons only** - No ElevatedButton/TextButton
6. **Dark mode** - Sticky colors stay fixed
7. **Animation subtle** - < 300ms, easing curves
8. **Touch targets** - Minimum 44x44 dp

**🎨 Design = Consistency + Simplicity + RTL Support**
