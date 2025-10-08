// 📄 File: lib/widgets/common/dashboard_card.dart
//
// ✅ רכיב משותף: DashboardCard
// - עיצוב אחיד לכל כרטיסי הדשבורד
// - תמיכה בכותרת, אייקון, actions
// - Material 3 Design
//
// 🆕 עדכונים (08/10/2025):
// - תמיכה ב-elevation parameter
// - Visual depth משופר

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double elevation; // 🆕

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.actions,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 2.0, // 🆕 default
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final cardContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.surface,
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        border: Border.all(
          color: borderColor ?? cs.outline.withValues(alpha: 0.2),
          width: kBorderWidth,
        ),
        boxShadow: [
          // 🆕 BoxShadow מבוסס elevation
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08 * elevation),
            blurRadius: 4 * elevation,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // כותרת + אייקון + actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(kSpacingSmall),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                  child: Icon(
                    icon,
                    color: accent,
                    size: kIconSizeSmall + 4, // 20px
                  ),
                ),
                const SizedBox(width: kBorderRadius),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),

            const SizedBox(height: kSpacingMedium),

            // תוכן
            child,
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
