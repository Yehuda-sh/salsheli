// 📄 lib/widgets/common/sticky_note.dart
// Version 4.0 - Hybrid Premium | 22/02/2026
//
// פתק צבעוני בסגנון Post-it עם צללים וסיבוב.
// - StickyNote - פתק כללי עם child
// - StickyNoteLogo - פתק מרובע עם אייקון (ללוגו)
//
// Features:
//   - עומק פיזי באמצעות גרדיאנט נייר (Paper Gradient)
//   - אופטימיזציית RepaintBoundary לבידוד צללים
//   - משוב Haptic מבוסס הקשר (selectionClick)
//   - אנימציות Elastic מלוטשות
//
// 🔗 Related: ui_constants.dart, flutter_animate, sticky_button.dart

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/ui_constants.dart';

/// פתק צבעוני בסגנון Post-it עם צללים וסיבוב
///
/// מציג תוכן בתוך פתק צבעוני שנראה כאילו הודבק על המסך.
/// כולל צללים מציאותיים, גרדיאנט נייר וסיבוב קל לאפקט אותנטי.
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

    // 🎨 RepaintBoundary isolates shadow calculations from parent repaints
    Widget noteWidget = RepaintBoundary(
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            // 📜 Paper gradient - subtle lighting for physical depth
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                Color.lerp(color, Colors.black, 0.04)!,
              ],
            ),
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
                      offset:
                          Offset(0, kStickyShadowSecondaryOffsetY * elevation),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );

    // ✅ הוסף אנימציה רק אם animate == true
    if (animate) {
      noteWidget = noteWidget
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, curve: Curves.easeOut);
    }

    // ✅ הוסף onTap אם הוגדר
    if (onTap != null) {
      noteWidget = GestureDetector(
        onTap: () {
          // ✨ selectionClick - "תקתוק" עדין שמתאים לפתקיות
          unawaited(HapticFeedback.selectionClick());
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
/// כולל צללים חזקים יותר, גרדיאנט מודגש ואנימציות כניסה דרמטיות.
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

    // 🎨 RepaintBoundary isolates logo shadow calculations
    Widget logoWidget = RepaintBoundary(
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: kStickyLogoSize,
          height: kStickyLogoSize,
          decoration: BoxDecoration(
            // 📜 Stronger paper gradient for logo emphasis (0.08)
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                Color.lerp(color, Colors.black, 0.08)!,
              ],
            ),
            borderRadius: BorderRadius.circular(kStickyNoteRadius),
            boxShadow: elevation > 0
                ? [
                    // צל ראשי חזק - אפקט הדבקה
                    BoxShadow(
                      color: shadowColor.withValues(
                          alpha:
                              kStickyLogoShadowPrimaryOpacity * elevation),
                      blurRadius: kStickyLogoShadowPrimaryBlur * elevation,
                      offset: Offset(
                        kStickyShadowPrimaryOffsetX,
                        kStickyLogoShadowPrimaryOffsetY * elevation,
                      ),
                    ),
                    // צל רך - עומק
                    BoxShadow(
                      color: shadowColor.withValues(
                          alpha:
                              kStickyLogoShadowSecondaryOpacity * elevation),
                      blurRadius:
                          kStickyLogoShadowSecondaryBlur * elevation,
                      offset: Offset(
                          0, kStickyLogoShadowSecondaryOffsetY * elevation),
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
      ),
    );

    // ✅ אנימציית כניסה "קפיצית" - Elastic bounce
    if (animate) {
      logoWidget = logoWidget
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            curve: Curves.elasticOut,
            duration: 800.ms,
          );
    }

    // ✅ הוסף onTap אם הוגדר
    if (onTap != null) {
      logoWidget = GestureDetector(
        onTap: () {
          // ✨ selectionClick - "תקתוק" עדין שמתאים לפתקיות
          unawaited(HapticFeedback.selectionClick());
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
