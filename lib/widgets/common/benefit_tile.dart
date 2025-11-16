// 📄 File: lib/widgets/common/benefit_tile.dart
// 🎯 Purpose: כרטיס יתרון/פיצ'ר בסגנון Sticky Notes
//
// 📋 Features:
// - עיצוב פתק מודבק (Post-it style)
// - סיבוב קל לאפקט אותנטי
// - צללים מציאותיים
// - אייקון במעגל + כותרת + תיאור
// - RTL Support מלא
// - אנימציות כניסה
//
// 🔗 Related:
// - StickyNote - הרכיב הבסיסי
// - welcome_screen.dart - השימוש העיקרי (3 יתרונות)
// - ui_constants.dart - צבעי פתקים וקבועים
//
// 🎨 Design:
// - צבעים: kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan
// - סיבוב: -0.02 עד 0.02 רדיאנים
// - אייקון: במעגל 56x56px
//
// Usage:
// ```dart
// // שימוש בסיסי
// BenefitTile(
//   icon: Icons.check_circle,
//   title: 'יתרון',
//   subtitle: 'תיאור קצר',
// )
//
// // עם צבע מותאם
// BenefitTile(
//   icon: Icons.star,
//   title: 'מעולה',
//   subtitle: 'זה עובד מצוין',
//   color: kStickyPink,
//   rotation: -0.015,
// )
// ```
//
// Version: 3.0 - Sticky Notes Design System
// Updated: 18/10/2025

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import 'sticky_note.dart';

/// כרטיס יתרון/פיצ'ר בסגנון פתק מודבק (Sticky Notes)
/// 
/// מציג יתרון או פיצ'ר בעיצוב פתק צבעוני עם אייקון במעגל + טקסט בצד.
/// משמש ב-welcome_screen לתצוגת שלושה יתרונות.
/// 
/// Features:
/// - עיצוב פתק צבעוני עם צללים
/// - סיבוב קל לאפקט אותנטי
/// - אייקון במעגל 56x56px
/// - RTL Support מלא
/// - אנימציות כניסה
/// 
/// Parameters:
/// - [icon]: אייקון היתרון
/// - [title]: כותרת היתרון (bold, titleMedium)
/// - [subtitle]: תיאור קצר (bodyMedium)
/// - [color]: צבע הפתק (ברירת מחדל: kStickyYellow)
/// - [rotation]: סיבוב ברדיאנים (ברירת מחדל: 0.01)
/// - [iconColor]: צבע אייקון מותאם (אופציונלי)
/// - [iconSize]: גודל אייקון (ברירת מחדל: kIconSizeLarge = 32)
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

  const BenefitTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.rotation,
    this.iconColor,
    this.iconSize = kIconSizeLarge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cardColor = color ?? kStickyYellow;
    final cardRotation = rotation ?? 0.01;

    // צבע אייקון: מותאם אישית > primary
    final effectiveIconColor = iconColor ?? cs.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmallPlus),
      child: StickyNote(
        color: cardColor,
        rotation: cardRotation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // אייקון במעגל - מוגדל
            Container(
              width: 64, // מוגדל מ-56px
              height: 64,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: effectiveIconColor), // מוגדל מ-32
            ),
            const SizedBox(width: kSpacingMedium),

            // טקסט - מוגדל
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith( // שונה מ-titleMedium
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: kSpacingTiny),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith( // שונה מ-bodyMedium
                      color: cs.onSurfaceVariant,
                      height: 1.5, // מוגדל מ-1.4
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
