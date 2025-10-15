// 📄 File: lib/widgets/common/dashboard_card.dart
//
// 🎯 מטרה: Card wrapper לדשבורד עם כותרת, אייקון ו-elevation
//
// ✨ Features:
// - כותרת עם אייקון
// - elevation מותאם אישית
// - onTap אופציונלי
// - תוכן מותאם אישית (child)
//
// 📋 Related:
// - upcoming_shop_card.dart - משתמש ב-DashboardCard
// - smart_suggestions_card.dart - משתמש ב-DashboardCard (אם קיים)
//
// 💡 Usage:
// ```dart
// DashboardCard(
//   title: "כותרת",
//   icon: Icons.shopping_cart,
//   elevation: 3,
//   onTap: () { /* action */ },
//   child: Widget(...),
// )
// ```
//
// Version: 1.0
// Created: 12/10/2025

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';

/// כרטיס דשבורד עם כותרת, אייקון ותוכן מותאם אישית
/// 
/// רכיב wrapper לכרטיסים בממשק הדשבורד.
/// מציג כותרת עם אייקון, תוכן ואופציונלי - חץ ל-action.
/// 
/// Parameters:
/// - [title]: כותרת הכרטיס
/// - [icon]: אייקון להצגה ליד הכותרת
/// - [elevation]: גובה הצל (ברירת מחדל: kCardElevation = 2.0)
/// - [onTap]: פונקציה לקריאה בלחיצה (אופציונלי - אם null אין חץ)
/// - [child]: תוכן הכרטיס (widget)
/// 
/// Features:
/// - כותרת עם אייקון בולט
/// - חץ ימנה כשיש onTap (עיגון ל-action)
/// - Elevation מותאם אישית
/// - Material Design compliant
/// 
/// דוגמה:
/// ```dart
/// DashboardCard(
///   title: "רשימות הקנייה",
///   icon: Icons.shopping_list,
///   elevation: 2,
///   onTap: () => Navigator.pushNamed(context, '/lists'),
///   child: ListContent(),
/// )
/// ```
class DashboardCard extends StatelessWidget {
  /// כותרת הכרטיס
  final String title;
  
  /// אייקון להצגה ליד הכותרת
  final IconData icon;
  
  /// גובה הצל טהור (ברירת מחדל: 2.0)
  final double elevation;
  
  /// פונקציה לקריאה בלחיצה על הכרטיס (אופציונלי)
  final VoidCallback? onTap;
  
  /// תוכן הכרטיס (חובה)
  final Widget child;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    this.elevation = kCardElevation,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
  /// בנייה של כרטיס דשבורד עם כותרת, אייקון ותוכן מותאם אישית
  /// 
  /// פריסה:
  /// 1. Header: אייקון + כותרת + חץ (אם יש onTap)
  /// 2. Content: התוכן (child)
  /// 
  /// Interactions:
  /// - InkWell עטוף להשפעת גלים
  /// - onTap optional - אם קיים, מציג חץ
  /// - RoundedRectangle עם kBorderRadius
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: elevation,
      margin: const EdgeInsets.symmetric(
        vertical: kCardMarginVertical,
        horizontal: 0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
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
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: kIconSizeSmall,
                      color: cs.onSurfaceVariant,
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
