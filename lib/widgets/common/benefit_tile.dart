// 📄 File: lib/widgets/common/benefit_tile.dart
// תיאור: רכיב משותף להצגת פריט יתרון (אייקון + כותרת + תיאור)
//
// שימוש: מסך Welcome, עמוד About, Help וכו'
// תומך ב-RTL, גדלי מגע נכונים, ו-Theme colors

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BenefitTile extends StatelessWidget {
  /// אייקון היתרון
  final IconData icon;

  /// כותרת היתרון
  final String title;

  /// תיאור קצר
  final String subtitle;

  /// צבע אייקון מותאם אישית (אופציונלי)
  final Color? iconColor;

  /// גודל אייקון (ברירת מחדל: 32)
  final double iconSize;

  const BenefitTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // צבע אייקון: מותאם אישית > ענבר מהמותג > primary
    final effectiveIconColor = iconColor ?? brand?.accent ?? cs.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // אייקון במעגל
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: effectiveIconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: effectiveIconColor),
          ),
          const SizedBox(width: 16),

          // טקסט
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
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
