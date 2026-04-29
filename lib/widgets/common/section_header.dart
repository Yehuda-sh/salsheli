// lib/widgets/common/section_header.dart — Section header — reusable header with icon, title, and optional action button

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';

/// 📑 כותרת מדור אחידה — סגנון notebook highlighter
///
/// הכותרת עטופה ב-highlighter — צבע עדין מאחורי הטקסט בלבד, כמו טוש
/// סימון על נייר. תואם את שפת ה-Notebook + Sticky Notes של האפליקציה.
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

  /// Highlighter color behind the title text. Defaults to the brand's
  /// `stickyYellow` — the marker-stroke look that fits the notebook +
  /// sticky-notes design language. Override for category-specific tints
  /// (e.g., `stickyCyan` for active sections).
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
    final brand = theme.extension<AppBrand>();
    final hlColor = highlightColor ?? brand?.stickyYellow ?? kStickyYellow;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: kSpacingSmall),
          ],
          // Highlighter — color only behind the title, like a marker
          // stroke on notebook paper. Reuses kHighlightOpacity (0.3),
          // the same constant the shopping_lists header uses for its
          // own marker effect.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmall,
              vertical: kSpacingXTiny,
            ),
            decoration: BoxDecoration(
              color: hlColor.withValues(alpha: kHighlightOpacity),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Text(
              title,
              // titleMedium + bold instead of titleSmall + bold —
              // titleSmall already ships at FontWeight.w500, so adding
              // bold on top was a style-on-style escalation. titleMedium
              // is the proper Material 3 step up for a section title.
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: kSpacingSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                // Bumped from kOpacitySoft (0.15) to kOpacityLight (0.3)
                // — count is meaningful info ("you have 5 active
                // items"), not decoration. It needs to read at a glance.
                color: cs.primary.withValues(alpha: kOpacityLight),
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
          ],
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}
