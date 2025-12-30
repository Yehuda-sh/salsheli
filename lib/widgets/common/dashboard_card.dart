// 📄 lib/widgets/common/dashboard_card.dart
//
// כרטיס צבעוני לדשבורד עם כותרת, אייקון ותוכן מותאם.
// לחיץ (אופציונלי) - מציג חץ כשיש onTap.
//
// 🔗 Related: StickyNote, upcoming_shop_card.dart

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import 'sticky_note.dart';
import 'tappable_card.dart';

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

    // צבעים מבוססי Theme (תומך dark mode)
    final textColor = cs.onSurface;
    final secondaryColor = cs.onSurfaceVariant;

    final content = StickyNote(
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
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: kIconSizeSmall,
                  color: secondaryColor,
                ),
            ],
          ),
          const SizedBox(height: kSpacingMedium),

          // 📦 Content
          child,
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: kCardMarginVertical,
        horizontal: 0,
      ),
      child: onTap != null
          ? SimpleTappableCard(
              onTap: onTap,
              child: content,
            )
          : content,
    );
  }
}
