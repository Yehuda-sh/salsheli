// 📄 lib/widgets/common/dashboard_card.dart
// Version 4.0 - Hybrid Premium | 22/02/2026
//
// כרטיס צבעוני לדשבורד עם כותרת, אייקון ותוכן מותאם.
// לחיץ (אופציונלי) - מציג חץ כשיש onTap.
//
// Features:
//   - אנימציית 'נחיתה' (Elastic Drop) עם flutter_animate
//   - משוב Haptic מובנה (Selection vs Medium)
//   - ריווח סמנטי באמצעות Gap
//   - אופטימיזציית RepaintBoundary
//
// 🔗 Related: StickyNote, SimpleTappableCard, upcoming_shop_card.dart

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';
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
/// - [animate]: האם להפעיל אנימציית כניסה - Elastic Drop (ברירת מחדל: true)
///
/// Features:
/// - אנימציית "נחיתה" (Elastic Drop) - fadeIn + slideY + scale
/// - עיצוב פתק צבעוני עם צללים (נשלט ע"י elevation)
/// - סיבוב קל לאפקט אותנטי
/// - כותרת עם אייקון בולט
/// - חץ ימנה כשיש onTap
/// - משוב Haptic מובחן: selectionClick ל-tap, mediumImpact ל-longPress
/// - תמיכה בלחיצה ארוכה
/// - נגישות מלאה (Semantics, Tooltip)
/// - RepaintBoundary לביצועי גלילה אופטימליים
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

  /// צבע הפתק (ברירת מחדל: brand.stickyYellow - תומך dark mode)
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

  /// האם להפעיל אנימציית כניסה - Elastic Drop (ברירת מחדל: true)
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
    final brand = theme.extension<AppBrand>();

    // ✅ Theme-aware default color (supports dark mode)
    final cardColor = color ?? brand?.stickyYellow ?? kStickyYellow;
    final cardRotation = rotation ?? 0.01;

    // צבעים מבוססי Theme (תומך dark mode)
    final textColor = cs.onSurface;

    // ✅ RTL-aware arrow icon
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final arrowIcon = isRtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios;

    // 📌 StickyNote with animation disabled - DashboardCard handles its own
    Widget content = StickyNote(
      color: cardColor,
      rotation: cardRotation,
      elevation: elevation,
      animate: false, // Animation handled below (Elastic Drop)
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
              const Gap(kSpacingSmall),
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
                  arrowIcon,
                  size: kIconSizeSmall,
                  // ✅ Subtle arrow - doesn't steal focus from title
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
            ],
          ),
          const Gap(kSpacingMedium),

          // 📦 Content
          child,
        ],
      ),
    );

    // 🎬 Elastic Drop animation - card "lands" on the page
    if (animate) {
      content = content
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack)
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1.0, 1.0),
          );
    }

    final isInteractive = onTap != null || onLongPress != null;

    // 🎨 RepaintBoundary isolates card animations/shadows from scroll repaints
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: kCardMarginVertical),
        child: isInteractive
            ? SimpleTappableCard(
                onTap: onTap != null
                    ? () {
                        unawaited(HapticFeedback.selectionClick());
                        onTap!();
                      }
                    : null,
                onLongPress: onLongPress != null
                    ? () {
                        unawaited(HapticFeedback.mediumImpact());
                        onLongPress!();
                      }
                    : null,
                haptic: ButtonHaptic.none, // Handled above with specific patterns
                tooltip: tooltip,
                semanticLabel: semanticLabel ?? title,
                // ✅ Match ripple to sticky note's border radius
                borderRadius: kStickyNoteRadius,
                child: content,
              )
            : content,
      ),
    );
  }
}
