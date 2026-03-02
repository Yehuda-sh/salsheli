// 📄 lib/widgets/common/benefit_tile.dart
//
// פתק צבעוני שמציג יתרון של האפליקציה (אייקון + כותרת + תיאור).
// משמש במסך הפתיחה להצגת 3 היתרונות המרכזיים.
//
// ✨ Features:
// - אנימציית כניסה מבוססת flutter_animate
// - Icon Container בעיצוב Glassmorphic עדין
// - משוב Haptic חכם ב-onTap
// - אופטימיזציית RepaintBoundary
//
// ✅ תיקונים:
//    - הוספת Semantics לנגישות
//    - הוספת onTap / onLongPress לאינטראקטיביות אופציונלית
//    - הוספת tooltip / semanticLabel לנגישות
//    - הוספת elevation להעברה ל-StickyNote
//    - הוספת maxLines + TextOverflow.ellipsis למניעת overflow
//
// 🔗 Related: StickyNote, SimpleTappableCard, welcome_screen.dart
//
// Version: 4.0 - Hybrid Premium (Sensory + Glassmorphic Polish)
// Last Updated: 22/02/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/ui_constants.dart';
import 'sticky_note.dart';
import 'tappable_card.dart';

/// כרטיס יתרון/פיצ'ר בסגנון פתק מודבק (Sticky Notes)
///
/// מציג יתרון או פיצ'ר בעיצוב פתק צבעוני עם אייקון במעגל + טקסט בצד.
/// משמש ב-welcome_screen לתצוגת שלושה יתרונות.
///
/// Features:
/// - עיצוב פתק צבעוני עם צללים
/// - סיבוב קל לאפקט אותנטי
/// - אייקון במעגל 56x56px (Glassmorphic)
/// - RTL Support מלא
/// - אנימציות כניסה (flutter_animate)
///
/// Parameters:
/// - [icon]: אייקון היתרון
/// - [title]: כותרת היתרון (bold, titleMedium)
/// - [subtitle]: תיאור קצר (bodyMedium)
/// - [color]: צבע הפתק (ברירת מחדל: kStickyYellow)
/// - [rotation]: סיבוב ברדיאנים (ברירת מחדל: 0.01)
/// - [iconColor]: צבע אייקון מותאם (אופציונלי)
/// - [iconSize]: גודל אייקון (ברירת מחדל: kIconSizeLarge = 32)
/// - [onTap]: פונקציה לקריאה בלחיצה (אופציונלי)
/// - [onLongPress]: פונקציה לקריאה בלחיצה ארוכה (אופציונלי)
/// - [semanticLabel]: תווית לנגישות (ברירת מחדל: title - subtitle)
/// - [tooltip]: טקסט tooltip לנגישות (אופציונלי)
/// - [elevation]: רמת צל (0.0-1.0, ברירת מחדל: 1.0)
/// - [titleMaxLines]: מספר שורות מקסימלי לכותרת (ברירת מחדל: 1)
/// - [subtitleMaxLines]: מספר שורות מקסימלי לתיאור (ברירת מחדל: 2)
///
/// דוגמה:
/// ```dart
/// BenefitTile(
///   icon: Icons.check_circle,
///   title: 'רשימות חכמות',
///   subtitle: 'עיצוב אינטואיטיבי וקל לשימוש',
///   color: kStickyPink,
///   rotation: -0.015,
/// )
/// ```
class BenefitTile extends StatelessWidget {
  /// אייקון היתרון
  final IconData icon;

  /// כותרת היתרון
  final String title;

  /// תיאור קצר
  final String subtitle;

  /// צבע הפתק (ברירת מחדל: kStickyYellow)
  final Color? color;

  /// סיבוב ברדיאנים (ברירת מחדל: 0.01)
  final double? rotation;

  /// צבע אייקון מותאם אישית (אופציונלי)
  final Color? iconColor;

  /// גודל אייקון (ברירת מחדל: kIconSizeLarge = 32)
  final double iconSize;

  /// פונקציה לקריאה בלחיצה על הכרטיס (אופציונלי)
  final VoidCallback? onTap;

  /// פונקציה לקריאה בלחיצה ארוכה (אופציונלי)
  final VoidCallback? onLongPress;

  /// תווית לנגישות (ברירת מחדל: title - subtitle)
  final String? semanticLabel;

  /// טקסט tooltip לנגישות (אופציונלי)
  final String? tooltip;

  /// רמת צל (0.0-1.0, ברירת מחדל: 1.0)
  final double elevation;

  /// מספר שורות מקסימלי לכותרת (ברירת מחדל: 1)
  final int titleMaxLines;

  /// מספר שורות מקסימלי לתיאור (ברירת מחדל: 2)
  final int subtitleMaxLines;

  const BenefitTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.rotation,
    this.iconColor,
    this.iconSize = kIconSizeLarge,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.tooltip,
    this.elevation = 1.0,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // 🌓 תמיכה במצב אפל: בחירת צבע מותאם
    final cardColor = color ?? (isDark ? kStickyYellowDark : kStickyYellow);
    final cardRotation = rotation ?? 0.01;

    // צבע אייקון: מותאם אישית > primary
    final effectiveIconColor = iconColor ?? cs.primary;

    // 📱 גמישות לפי גודל מסך
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    final circleSize = isSmallScreen ? 56.0 : 64.0;
    final iconSizeValue = isSmallScreen ? 28.0 : 36.0;
    final titleStyle = isSmallScreen ? theme.textTheme.titleMedium : theme.textTheme.titleLarge;
    final bodyStyle = isSmallScreen ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge;

    // ✅ תווית נגישות ברירת מחדל
    final effectiveSemanticLabel = semanticLabel ?? '$title - $subtitle';

    // 📳 Haptic-aware onTap wrapper
    final effectiveOnTap = onTap != null
        ? () {
            unawaited(HapticFeedback.lightImpact());
            onTap!();
          }
        : null;

    final content = StickyNote(
      color: cardColor,
      rotation: cardRotation,
      elevation: elevation,
      animate: false, // ❌ StickyNote animation disabled - flutter_animate handles it
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // אייקון במעגל - Glassmorphic עדין
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: effectiveIconColor.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Icon(icon, size: iconSizeValue, color: effectiveIconColor),
          ),
          const SizedBox(width: kSpacingMedium),

          // טקסט - גמיש
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                  maxLines: titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(kSpacingTiny),
                Text(
                  subtitle,
                  style: bodyStyle?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                  maxLines: subtitleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // ✅ עטוף ב-SimpleTappableCard אם יש אינטראקטיביות
    // SimpleTappableCard כבר כולל haptic feedback מובנה (tap-down),
    // אז ה-effectiveOnTap מוסיף haptic רק ברמת ה-callback
    Widget result = Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmallPlus),
      child: effectiveOnTap != null || onLongPress != null
          ? SimpleTappableCard(
              onTap: effectiveOnTap,
              onLongPress: onLongPress,
              haptic: ButtonHaptic.none, // ❌ נמנע מכפילות - haptic מנוהל ב-effectiveOnTap
              tooltip: tooltip,
              semanticLabel: effectiveSemanticLabel,
              child: content,
            )
          : content,
    );

    // ✅ הוסף Semantics אם אין אינטראקטיביות (SimpleTappableCard כבר מטפל)
    if (onTap == null && onLongPress == null) {
      result = Semantics(
        label: effectiveSemanticLabel,
        container: true,
        child: result,
      );
    }

    // 🎬 אנימציית כניסה - "The Landed Feel"
    return RepaintBoundary(
      child: result
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOutBack)
          .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutBack)
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
