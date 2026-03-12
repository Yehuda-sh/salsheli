// 📄 lib/widgets/common/app_section_card.dart
//
// 🎯 Card section אחיד — Template מבוסס Settings Screen
// ✅ Consistent elevation, borderRadius, padding
// ✅ Optional SectionHeader integration
//
// Usage:
// ```dart
// AppSectionCard(
//   icon: Icons.notifications_outlined,
//   title: 'התראות',
//   children: [SwitchListTile(...), ...],
// )
// ```

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import 'section_header.dart';

/// 🎴 Card section אחיד — מבוסס Settings Screen template
class AppSectionCard extends StatelessWidget {
  /// Optional section icon (shown in SectionHeader)
  final IconData? icon;

  /// Optional section title (shown in SectionHeader)
  final String? title;

  /// Card elevation (default: 1, use 2 for hero sections)
  final double elevation;

  /// Card content
  final List<Widget> children;

  /// Optional custom header widget (overrides icon+title)
  final Widget? header;

  /// Card background color (default: theme surface)
  final Color? color;

  /// Inner padding (default: kSpacingMedium)
  final EdgeInsets padding;

  const AppSectionCard({
    super.key,
    this.icon,
    this.title,
    this.elevation = 1,
    required this.children,
    this.header,
    this.color,
    this.padding = const EdgeInsets.all(kSpacingMedium),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: elevation,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (header != null)
              header!
            else if (icon != null && title != null) ...[
              SectionHeader(
                leading: Icon(icon, color: cs.primary, size: kIconSizeMedium),
                title: title!,
              ),
              const SizedBox(height: kSpacingSmall),
            ],
            // Content
            ...children,
          ],
        ),
      ),
    );
  }
}
