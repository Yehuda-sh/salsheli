// 📄 File: lib/widgets/common/sticky_note.dart
// 🎯 Purpose: פתק צבעוני בסגנון Post-it
//
// 📋 Features:
// - פתק צבעוני עם צללים מציאותיים
// - סיבוב קל (rotation) לאפקט אותנטי
// - צבעים ניתנים להתאמה
// - אנימציות fadeIn + slideY מובנות
// - שימוש בקבועים מ-ui_constants.dart
//
// 🔗 Related:
// - ui_constants.dart - קבועי גדלים וצללים
// - app_theme.dart - AppBrand
// - flutter_animate - אנימציות
//
// 🎨 Design:
// - צללים כפולים לעומק
// - פינות מעוקלות קלות (2px)
// - סיבוב קל (+/- 0.03 רדיאנים)
// - אנימציות כניסה חלקות
//
// Usage:
// ```dart
// StickyNote(
//   color: kStickyYellow,
//   rotation: 0.01,
//   child: Text('תוכן הפתק'),
// )
// ```
//
// Version: 1.0 - Sticky Notes Design System (15/10/2025)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/ui_constants.dart';

/// פתק צבעוני בסגנון Post-it עם צללים וסיבוב
/// 
/// מציג תוכן בתוך פתק צבעוני שנראה כאילו הודבק על המסך.
/// כולל צללים מציאותיים וסיבוב קל לאפקט אותנטי.
/// 
/// Parameters:
/// - [color]: צבע הפתק (השתמש בקבועים כמו kStickyYellow)
/// - [child]: התוכן בתוך הפתק
/// - [rotation]: זווית סיבוב ברדיאנים (ברירת מחדל: 0.0)
///   המלצה: השתמש בערכים קטנים כמו 0.01, -0.015 וכו'
/// 
/// דוגמה:
/// ```dart
/// StickyNote(
///   color: kStickyPink,
///   rotation: -0.02,
///   child: Column(
///     children: [
///       Icon(Icons.star),
///       Text('תוכן יפה'),
///     ],
///   ),
/// )
/// ```
class StickyNote extends StatelessWidget {
  /// צבע הפתק
  final Color color;

  /// התוכן בתוך הפתק
  final Widget child;

  /// זווית סיבוב ברדיאנים (ברירת מחדל: 0.0)
  /// 
  /// ערכים מומלצים: -0.03 עד 0.03
  /// דוגמה: 0.01 = סיבוב קל ימינה, -0.02 = סיבוב קל שמאלה
  final double rotation;

  /// Padding פנימי (ברירת מחדל: kSpacingMedium)
  final double padding;

  const StickyNote({
    super.key,
    required this.color,
    required this.child,
    this.rotation = 0.0,
    this.padding = kSpacingMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(kStickyNoteRadius),
          boxShadow: [
            // צל ראשי - אפקט הדבקה חזק
            BoxShadow(
              color: Colors.black.withValues(alpha: kStickyShadowPrimaryOpacity),
              blurRadius: kStickyShadowPrimaryBlur,
              offset: const Offset(
                kStickyShadowPrimaryOffsetX,
                kStickyShadowPrimaryOffsetY,
              ),
            ),
            // צל משני - עומק
            BoxShadow(
              color: Colors.black.withValues(alpha: kStickyShadowSecondaryOpacity),
              blurRadius: kStickyShadowSecondaryBlur,
              offset: const Offset(0, kStickyShadowSecondaryOffsetY),
            ),
          ],
        ),
        child: child,
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }
}

/// פתק לוגו מיוחד - מרובע עם אייקון במרכז
/// 
/// גרסה מיוחדת של פתק לשימוש בלוגו או אייקונים מרכזיים.
/// כולל צללים חזקים יותר ואנימציות כניסה דרמטיות.
/// 
/// Parameters:
/// - [color]: צבע הפתק
/// - [icon]: אייקון להצגה במרכז
/// - [iconColor]: צבע האייקון
/// - [rotation]: זווית סיבוב (ברירת מחדל: -0.03)
/// 
/// דוגמה:
/// ```dart
/// StickyNoteLogo(
///   color: kStickyYellow,
///   icon: Icons.shopping_basket_outlined,
///   iconColor: Colors.green,
/// )
/// ```
class StickyNoteLogo extends StatelessWidget {
  /// צבע הפתק
  final Color color;

  /// אייקון להצגה
  final IconData icon;

  /// צבע האייקון
  final Color iconColor;

  /// זווית סיבוב ברדיאנים (ברירת מחדל: -0.03)
  final double rotation;

  const StickyNoteLogo({
    super.key,
    required this.color,
    required this.icon,
    required this.iconColor,
    this.rotation = -0.03,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: kStickyLogoSize,
        height: kStickyLogoSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(kStickyNoteRadius),
          boxShadow: [
            // צל ראשי חזק - אפקט הדבקה
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: kStickyLogoShadowPrimaryOpacity),
              blurRadius: kStickyLogoShadowPrimaryBlur,
              offset: const Offset(
                kStickyShadowPrimaryOffsetX,
                kStickyLogoShadowPrimaryOffsetY,
              ),
            ),
            // צל רך - עומק
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: kStickyLogoShadowSecondaryOpacity),
              blurRadius: kStickyLogoShadowSecondaryBlur,
              offset: const Offset(0, kStickyLogoShadowSecondaryOffsetY),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: kStickyLogoIconSize,
            color: iconColor,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .scale(
          begin: const Offset(0.8, 0.8),
          curve: Curves.elasticOut,
        );
  }
}
