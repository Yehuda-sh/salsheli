// 📄 lib/widgets/common/dashboard_card.dart
//
// כרטיס צבעוני לדשבורד עם כותרת, אייקון ותוכן מותאם.
// לחיץ (אופציונלי) - מציג חץ כשיש onTap.
//
// ✅ תיקונים:
//    - הוספת onLongPress parameter ללחיצה ארוכה
//    - הוספת tooltip parameter לנגישות
//    - הוספת semanticLabel parameter לקוראי מסך (ברירת מחדל: title)
//    - הוספת elevation parameter לשליטה בצללים (0.0-1.0)
//    - הוספת animate parameter לשליטה באנימציות
//    - העברת פרמטרים ל-SimpleTappableCard ו-StickyNote
//
// 🔗 Related: StickyNote, SimpleTappableCard, upcoming_shop_card.dart

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
/// - [onLongPress]: פונקציה לקריאה בלחיצה ארוכה (אופציונלי)
/// - [child]: תוכן הכרטיס (widget)
/// - [semanticLabel]: תווית לנגישות (ברירת מחדל: title)
/// - [tooltip]: טקסט tooltip לנגישות (אופציונלי)
/// - [elevation]: רמת צל (0.0-1.0, ברירת מחדל: 1.0)
/// - [animate]: האם להפעיל אנימציית כניסה (ברירת מחדל: true)
///
/// Features:
/// - עיצוב פתק צבעוני עם צללים (נשלט ע"י elevation)
/// - סיבוב קל לאפקט אותנטי
/// - כותרת עם אייקון בולט
/// - חץ ימנה כשיש onTap
/// - אנימציות כניסה (נשלט ע"י animate)
/// - תמיכה בלחיצה ארוכה
/// - נגישות מלאה (Semantics, Tooltip)
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

  /// פונקציה לקריאה בלחיצה ארוכה (אופציונלי)
  final VoidCallback? onLongPress;

  /// תוכן הכרטיס (חובה)
  final Widget child;

  /// תווית לנגישות (ברירת מחדל: title)
  final String? semanticLabel;

  /// טקסט tooltip לנגישות (אופציונלי)
  final String? tooltip;

  /// רמת צל (0.0-1.0, ברירת מחדל: 1.0)
  final double elevation;

  /// האם להפעיל אנימציית כניסה (ברירת מחדל: true)
  final bool animate;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.rotation,
    this.onTap,
    this.onLongPress,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.elevation = 1.0,
    this.animate = true,
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
      elevation: elevation,
      animate: animate,
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
      padding: const EdgeInsets.symmetric(vertical: kCardMarginVertical),
      child: onTap != null || onLongPress != null
          ? SimpleTappableCard(
              onTap: onTap,
              onLongPress: onLongPress,
              tooltip: tooltip,
              semanticLabel: semanticLabel ?? title,
              child: content,
            )
          : content,
    );
  }
}
