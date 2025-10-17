// 📄 File: lib/widgets/common/dashboard_card.dart
// 🎯 Purpose: כרטיס דשבורד בסגנון Sticky Notes
//
// 📋 Features:
// - כרטיס בסגנון פתק צבעוני (Post-it)
// - סיבוב קל לאפקט אותנטי
// - צללים מציאותיים
// - כותרת עם אייקון
// - onTap אופציונלי
// - תוכן מותאם אישית (child)
//
// 🔗 Related:
// - StickyNote - הרכיב הבסיסי
// - upcoming_shop_card.dart - משתמש ב-DashboardCard
// - ui_constants.dart - צבעי פתקים וקבועים
//
// 🎨 Design:
// - צבעים: kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan
// - סיבוב: -0.02 עד 0.02 רדיאנים
// - צללים: אוטומטיים מ-StickyNote
//
// Usage:
// ```dart
// DashboardCard(
//   title: "כותרת",
//   icon: Icons.shopping_cart,
//   color: kStickyYellow,
//   rotation: 0.01,
//   onTap: () { /* action */ },
//   child: Widget(...),
// )
// ```
//
// Version: 2.0 - Sticky Notes Design System
// Updated: 18/10/2025

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import 'sticky_note.dart';

/// כרטיס דשבורד בסגנון פתק מודבק (Sticky Notes)
/// 
/// רכיב wrapper לכרטיסים בממשק הדשבורד.
/// מציג כותרת עם אייקון, תוכן ואופציונלי - חץ ל-action.
/// 
/// Parameters:
/// - [title]: כותרת הכרטיס
/// - [icon]: אייקון להצגה ליד הכותרת
/// - [color]: צבע הפתק (ברירת מחדל: kStickyYellow)
/// - [rotation]: סיבוב ברדיאנים (ברירת מחדל: 0.01)
/// - [onTap]: פונקציה לקריאה בלחיצה (אופציונלי)
/// - [child]: תוכן הכרטיס (widget)
/// 
/// Features:
/// - עיצוב פתק צבעוני עם צללים
/// - סיבוב קל לאפקט אותנטי
/// - כותרת עם אייקון בולט
/// - חץ ימנה כשיש onTap
/// - אנימציות כניסה
/// 
/// דוגמה:
/// ```dart
/// DashboardCard(
///   title: "רשימות הקנייה",
///   icon: Icons.shopping_list,
///   color: kStickyPink,
///   rotation: -0.015,
///   onTap: () => Navigator.pushNamed(context, '/lists'),
///   child: ListContent(),
/// )
/// ```
class DashboardCard extends StatelessWidget {
  /// כותרת הכרטיס
  final String title;
  
  /// אייקון להצגה ליד הכותרת
  final IconData icon;
  
  /// צבע הפתק (ברירת מחדל: kStickyYellow)
  final Color? color;
  
  /// סיבוב ברדיאנים (ברירת מחדל: 0.01)
  final double? rotation;
  
  /// פונקציה לקריאה בלחיצה על הכרטיס (אופציונלי)
  final VoidCallback? onTap;
  
  /// תוכן הכרטיס (חובה)
  final Widget child;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.rotation,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cardColor = color ?? kStickyYellow;
    final cardRotation = rotation ?? 0.01;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: kCardMarginVertical,
        horizontal: 0,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: StickyNote(
          color: cardColor,
          rotation: cardRotation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🏷️ Header: אייקון + כותרת
              Row(
                children: [
                  Icon(
                    icon,
                    size: kIconSize,
                    color: cs.primary,
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: kIconSizeSmall,
                      color: Colors.black54,
                    ),
                ],
              ),
              const SizedBox(height: kSpacingMedium),
              
              // 📦 Content
              child,
            ],
          ),
        ),
      ),
    );
  }
}
