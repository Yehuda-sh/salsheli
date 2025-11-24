// 📄 File: lib/widgets/common/benefit_tile.dart
// 🎯 Purpose: כרטיס יתרון/פיצ'ר בסגנון Sticky Notes
//
// 📋 Features:
// - עיצוב פתק מודבק (Post-it style)
// - סיבוב קל לאפקט אותנטי
// - צללים מציאותיים
// - אייקון במעגל + כותרת + תיאור
// - RTL Support מלא
// - 🌓 תמיכה במצב אפל (Dark Mode)
// - 📱 גמישות לפי גודל מסך (Responsive)
//
// 🔗 Related:
// - StickyNote - הרכיב הבסיסי
// - welcome_screen.dart - השימוש העיקרי (3 יתרונות)
// - ui_constants.dart - צבעי פתקים וקבועים
//
// 🎨 Design:
// - צבעים (Light): kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan
// - צבעים (Dark): kStickyYellowDark, kStickyPinkDark, kStickyGreenDark, kStickyCyanDark
// - סיבוב: -0.02 עד 0.02 רדיאנים
// - אייקון: במעגל 56px-64px (לפי גודל מסך)
//
// Usage:
// ```dart
// // שימוש בסיסי (צבע אוטומטי לפי מצב)
// BenefitTile(
//   icon: Icons.check_circle,
//   title: 'יתרון',
//   subtitle: 'תיאור קצר',
// )
//
// // עם צבע מותאם (ידני)
// BenefitTile(
//   icon: Icons.star,
//   title: 'מעולה',
//   subtitle: 'זה עובד מצוין',
//   color: kStickyPink, // ידני - לא משתנה במצב אפל
//   rotation: -0.015,
// )
// ```
//
// Version: 3.1 - Dark Mode + Responsive Support
// Updated: 24/11/2025

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmallPlus),
      child: StickyNote(
        color: cardColor,
        rotation: cardRotation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // אייקון במעגל - גמיש
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
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
                  ),
                  const SizedBox(height: kSpacingTiny),
                  Text(
                    subtitle,
                    style: bodyStyle?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
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
