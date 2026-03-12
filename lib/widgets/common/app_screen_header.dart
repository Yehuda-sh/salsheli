// 📄 lib/widgets/common/app_screen_header.dart
//
// 🎯 Inline screen header — Template מבוסס Settings Screen
// ✅ Icon + Title (no AppBar)
// ✅ Consistent across all screens

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';

/// 🏷️ Inline screen header — מבוסס Settings Screen template
class AppScreenHeader extends StatelessWidget {
  /// Header icon
  final IconData icon;

  /// Header title
  final String title;

  /// Optional trailing widget
  final Widget? trailing;

  const AppScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingMedium),
      child: Row(
        children: [
          Icon(icon, size: 24, color: cs.primary),
          const SizedBox(width: kSpacingSmall),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
