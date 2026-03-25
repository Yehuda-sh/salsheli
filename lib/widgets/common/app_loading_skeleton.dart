// 📄 lib/widgets/common/app_loading_skeleton.dart
//
// 🎯 Loading skeleton אחיד — Template מבוסס Settings Screen
// ✅ Consistent shimmer layout across all screens
// ✅ Configurable sections count

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import 'skeleton_loader.dart';

/// 💀 Loading skeleton — מבוסס Settings Screen template
class AppLoadingSkeleton extends StatelessWidget {
  /// Number of card sections to show (default: 4)
  final int sectionCount;

  /// Show hero section at top (taller, elevation 2 feel)
  final bool showHero;

  const AppLoadingSkeleton({
    super.key,
    this.sectionCount = 3,
    this.showHero = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(kSpacingMedium),
      children: [
        // Hero section (profile-like)
        if (showHero) ...[
          const SkeletonBox(width: double.infinity, height: 120),
          const SizedBox(height: kSpacingMedium),
        ],

        // Card sections
        for (int i = 0; i < sectionCount; i++) ...[
          const SkeletonBox(width: double.infinity, height: 80),
          const SizedBox(height: kSpacingSmallPlus),
        ],
      ],
    );
  }
}
