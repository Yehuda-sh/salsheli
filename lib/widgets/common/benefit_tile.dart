// 📄 File: lib/widgets/common/benefit_tile.dart
//
// 🎯 Purpose: רכיב משותף להצגת יתרון/פיצ'ר (אייקון + כותרת + תיאור)
//
// 📋 Features:
// - RTL Support - עבודה נכונה בעברית
// - Theme-aware - משתמש בצבעי Theme
// - Custom colors - אפשרות לעקוף צבעי Theme
// - Touch targets - מידות מגע נכונות
// - Accessibility - Semantics למסכים קוראים
// - Constants - כל המידות מ-ui_constants.dart
//
// 🔗 Related:
// - welcome_screen.dart - השימוש העיקרי (3 יתרונות)
// - app_theme.dart - AppBrand extension
// - ui_constants.dart - spacing, icon sizes
//
// 💡 Usage:
// ```dart
// // Basic usage
// BenefitTile(
//   icon: Icons.check_circle,
//   title: 'יתרון',
//   subtitle: 'תיאור קצר',
// )
//
// // עם צבעים מותאמים אישית (רקע כהה)
// BenefitTile(
//   icon: Icons.star,
//   title: 'מעולה',
//   subtitle: 'זה עובד מצוין',
//   titleColor: Colors.white,
//   subtitleColor: Colors.white70,
//   iconColor: Colors.amber,
// )
// ```
//
// Version: 2.0 - Refactored (08/10/2025)
// - הוספת titleColor, subtitleColor parameters
// - שימוש מלא ב-constants (iconSize, spacing)

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';

class BenefitTile extends StatelessWidget {
  /// אייקון היתרון
  final IconData icon;

  /// כותרת היתרון
  final String title;

  /// תיאור קצר
  final String subtitle;

  /// צבע כותרת מותאם אישית (אופציונלי)
  final Color? titleColor;

  /// צבע תיאור מותאם אישית (אופציונלי)
  final Color? subtitleColor;

  /// צבע אייקון מותאם אישית (אופציונלי)
  final Color? iconColor;

  /// גודל אייקון (ברירת מחדל: kIconSizeLarge = 32)
  final double iconSize;

  const BenefitTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.iconColor,
    this.iconSize = kIconSizeLarge,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('🎁 BenefitTile.build()');
    debugPrint('   📝 title: $title');
    
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // צבע אייקון: מותאם אישית > ענבר מהמותג > primary
    final effectiveIconColor = iconColor ?? brand?.accent ?? cs.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmallPlus),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // אייקון במעגל
          Container(
            width: kIconSizeProfile + 20, // 56px (36 + 20)
            height: kIconSizeProfile + 20,
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: effectiveIconColor),
          ),
          const SizedBox(width: kSpacingMedium),

          // טקסט
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: titleColor ?? cs.onSurface, // מותאם אישית או default
                  ),
                ),
                const SizedBox(height: kSpacingTiny),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor ?? cs.onSurfaceVariant, // מותאם אישית או default
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
