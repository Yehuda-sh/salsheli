// 📄 lib/theme/design_tokens.dart
//
// 🎨 Design Tokens — מקום אחד לכל ערכי העיצוב
// כל ערך שחוזר על עצמו (spacing, radius, duration) מוגדר כאן פעם אחת.
//
// 📜 כללים:
// - אין מספרים "קסומים" בקוד — רק tokens
// - 8-point grid ל-spacing
// - 4 ערכי radius בלבד
// - durations אחידים לכל האנימציות
//
// 🔗 Related: app_theme.dart, context_extensions.dart, ui_constants.dart

/// 🎨 Design Tokens — ערכי עיצוב אחידים לכל האפליקציה
class AppTokens {
  AppTokens._();

  // ═══════════════════════════════════════
  // 📏 Spacing (8-point grid)
  // ═══════════════════════════════════════

  /// 4px — רווח מינימלי (בין אייקון לטקסט)
  static const space4 = 4.0;

  /// 8px — רווח קטן (padding פנימי)
  static const space8 = 8.0;

  /// 12px — רווח בינוני-קטן
  static const space12 = 12.0;

  /// 16px — רווח סטנדרטי (padding מסך, בין אלמנטים)
  static const space16 = 16.0;

  /// 24px — רווח גדול (בין סקשנים)
  static const space24 = 24.0;

  /// 32px — רווח גדול מאוד (header, hero)
  static const space32 = 32.0;

  /// 48px — רווח מקסימלי (top padding מיוחד)
  static const space48 = 48.0;

  // ═══════════════════════════════════════
  // 🔘 Border Radius
  // ═══════════════════════════════════════

  /// 8px — chips, badges, small buttons
  static const radiusS = 8.0;

  /// 12px — cards, inputs, list items
  static const radiusM = 12.0;

  /// 16px — bottom sheets, dialogs
  static const radiusL = 16.0;

  /// 24px — special cards, FABs
  static const radiusXL = 24.0;

  // ═══════════════════════════════════════
  // ⏱️ Animation Durations
  // ═══════════════════════════════════════

  /// 150ms — micro-interactions (opacity, scale)
  static const durationFast = Duration(milliseconds: 150);

  /// 300ms — standard transitions (expand, collapse)
  static const durationMedium = Duration(milliseconds: 300);

  /// 500ms — dramatic transitions (page, hero)
  static const durationSlow = Duration(milliseconds: 500);

  // ═══════════════════════════════════════
  // 📐 Elevation
  // ═══════════════════════════════════════

  /// 0 — flat (no shadow)
  static const elevNone = 0.0;

  /// 2 — subtle (cards, tiles)
  static const elevLow = 2.0;

  /// 4 — medium (floating buttons, dialogs)
  static const elevMed = 4.0;

  /// 8 — high (modals, bottom sheets)
  static const elevHigh = 8.0;

  // ═══════════════════════════════════════
  // 📱 Layout
  // ═══════════════════════════════════════

  /// Touch target מינימלי (Material guidelines)
  static const minTouchTarget = 48.0;

  /// רוחב מקסימלי לתוכן (tablet)
  static const maxContentWidth = 600.0;

  /// גובה AppBar
  static const appBarHeight = 56.0;

  // ═══════════════════════════════════════
  // 🎭 Opacity
  // ═══════════════════════════════════════

  /// disabled state
  static const opacityDisabled = 0.38;

  /// subtle hint
  static const opacityHint = 0.6;

  /// semi-transparent overlay
  static const opacityOverlay = 0.12;
}
