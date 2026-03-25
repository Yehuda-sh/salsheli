// 📄 lib/widgets/common/section_header.dart
//
// כותרת מדור אחידה — סגנון notebook highlighter.

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';

/// 📑 כותרת מדור אחידה — סגנון notebook highlighter
///
/// שימוש:
/// ```dart
/// SectionHeader(
///   title: 'פריטים פעילים',
///   count: 5,
///   trailing: Icon(Icons.filter_list),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Widget? trailing;
  final Widget? leading;
  final Color? highlightColor;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
    this.leading,
    this.highlightColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: kSpacingMedium,
      vertical: kSpacingSmall,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = theme.textTheme;
    final bgColor = highlightColor ?? cs.primaryContainer.withValues(alpha: kOpacityLight);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: kSpacingSmall),
          ],
          Expanded(
            child: Text(
              title,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
              child: Text(
                '$count',
                style: t.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (trailing != null) ...[
            const SizedBox(width: kSpacingSmall),
            trailing!,
          ],
        ],
      ),
    );
  }
}
