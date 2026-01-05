// 📄 lib/widgets/common/sticky_note.dart
//
// פתק צבעוני בסגנון Post-it עם צללים וסיבוב.
// - StickyNote - פתק כללי עם child
// - StickyNoteLogo - פתק מרובע עם אייקון (ללוגו)
//
// ✅ תיקונים:
//    - הוספת Semantics לנגישות
//    - הוספת animate parameter לשליטה באנימציה
//    - הוספת elevation parameter לשליטה בצללים
//    - הוספת onTap callback לאינטראקטיביות
//    - שימוש בצבעי צללים מ-Theme (לא Colors.black)
//
// 🔗 Related: ui_constants.dart, flutter_animate, sticky_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// - [animate]: האם להפעיל אנימציית כניסה (ברירת מחדל: true)
/// - [elevation]: רמת צל (0.0-1.0, ברירת מחדל: 1.0)
/// - [onTap]: callback ללחיצה (אופציונלי)
/// - [semanticLabel]: תווית לנגישות (אופציונלי)
///
/// דוגמה:
/// ```dart
/// StickyNote(
///   color: kStickyPink,
///   rotation: -0.02,
///   semanticLabel: 'פתק משימות',
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

  /// האם להפעיל אנימציית כניסה (ברירת מחדל: true)
  final bool animate;

  /// רמת צל (0.0-1.0, ברירת מחדל: 1.0)
  /// 0.0 = ללא צל, 1.0 = צל מלא
  final double elevation;

  /// callback ללחיצה (אופציונלי)
  final VoidCallback? onTap;

  /// תווית לנגישות (אופציונלי)
  final String? semanticLabel;

  const StickyNote({
    super.key,
    required this.color,
    required this.child,
    this.rotation = 0.0,
    this.padding = kSpacingMedium,
    this.animate = true,
    this.elevation = 1.0,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ✅ צבע צל מ-Theme במקום Colors.black
    final shadowColor = theme.shadowColor;

    Widget noteWidget = Transform.rotate(
      angle: rotation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(kStickyNoteRadius),
          boxShadow: elevation > 0
              ? [
                  // צל ראשי - אפקט הדבקה חזק
                  BoxShadow(
                    color: shadowColor.withValues(
                        alpha: kStickyShadowPrimaryOpacity * elevation),
                    blurRadius: kStickyShadowPrimaryBlur * elevation,
                    offset: Offset(
                      kStickyShadowPrimaryOffsetX,
                      kStickyShadowPrimaryOffsetY * elevation,
                    ),
                  ),
                  // צל משני - עומק
                  BoxShadow(
                    color: shadowColor.withValues(
                        alpha: kStickyShadowSecondaryOpacity * elevation),
                    blurRadius: kStickyShadowSecondaryBlur * elevation,
                    offset: Offset(0, kStickyShadowSecondaryOffsetY * elevation),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );

    // ✅ הוסף אנימציה רק אם animate == true
    if (animate) {
      noteWidget = noteWidget
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 400))
          .slideY(begin: 0.1, curve: Curves.easeOut);
    }

    // ✅ הוסף onTap אם הוגדר
    if (onTap != null) {
      noteWidget = GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        child: noteWidget,
      );
    }

    // ✅ הוסף Semantics לנגישות
    if (semanticLabel != null) {
      noteWidget = Semantics(
        label: semanticLabel,
        container: true,
        child: noteWidget,
      );
    }

    return noteWidget;
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
/// - [animate]: האם להפעיל אנימציית כניסה (ברירת מחדל: true)
/// - [elevation]: רמת צל (0.0-1.0, ברירת מחדל: 1.0)
/// - [onTap]: callback ללחיצה (אופציונלי)
/// - [semanticLabel]: תווית לנגישות (אופציונלי)
///
/// דוגמה:
/// ```dart
/// StickyNoteLogo(
///   color: kStickyYellow,
///   icon: Icons.shopping_basket_outlined,
///   iconColor: Colors.green,
///   semanticLabel: 'לוגו האפליקציה',
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

  /// האם להפעיל אנימציית כניסה (ברירת מחדל: true)
  final bool animate;

  /// רמת צל (0.0-1.0, ברירת מחדל: 1.0)
  final double elevation;

  /// callback ללחיצה (אופציונלי)
  final VoidCallback? onTap;

  /// תווית לנגישות (אופציונלי)
  final String? semanticLabel;

  const StickyNoteLogo({
    super.key,
    required this.color,
    required this.icon,
    required this.iconColor,
    this.rotation = -0.03,
    this.animate = true,
    this.elevation = 1.0,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ✅ צבע צל מ-Theme במקום Colors.black
    final shadowColor = theme.shadowColor;

    Widget logoWidget = Transform.rotate(
      angle: rotation,
      child: Container(
        width: kStickyLogoSize,
        height: kStickyLogoSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(kStickyNoteRadius),
          boxShadow: elevation > 0
              ? [
                  // צל ראשי חזק - אפקט הדבקה
                  BoxShadow(
                    color: shadowColor.withValues(
                        alpha: kStickyLogoShadowPrimaryOpacity * elevation),
                    blurRadius: kStickyLogoShadowPrimaryBlur * elevation,
                    offset: Offset(
                      kStickyShadowPrimaryOffsetX,
                      kStickyLogoShadowPrimaryOffsetY * elevation,
                    ),
                  ),
                  // צל רך - עומק
                  BoxShadow(
                    color: shadowColor.withValues(
                        alpha: kStickyLogoShadowSecondaryOpacity * elevation),
                    blurRadius: kStickyLogoShadowSecondaryBlur * elevation,
                    offset: Offset(0, kStickyLogoShadowSecondaryOffsetY * elevation),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: kStickyLogoIconSize,
            color: iconColor,
          ),
        ),
      ),
    );

    // ✅ הוסף אנימציה רק אם animate == true
    if (animate) {
      logoWidget = logoWidget
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 600))
          .scale(
            begin: const Offset(0.8, 0.8),
            curve: Curves.elasticOut,
          );
    }

    // ✅ הוסף onTap אם הוגדר
    if (onTap != null) {
      logoWidget = GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        child: logoWidget,
      );
    }

    // ✅ הוסף Semantics לנגישות
    if (semanticLabel != null) {
      logoWidget = Semantics(
        label: semanticLabel,
        image: true,
        child: logoWidget,
      );
    }

    return logoWidget;
  }
}
