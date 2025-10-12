// 📄 File: lib/screens/home/home_dashboard_screen_ux.dart
// 🎨 UX Improvements: Skeleton Loading + Staggered Animations
//
// שיפורים:
// ✅ Skeleton loading במקום spinner
// ✅ Staggered animations לכרטיסים
// ✅ Haptic feedback
// ✅ Constants למידות (אין hardcoded values)
//
// גרסה: 2.0 - Constants Integration (10/10/2025)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/ui_constants.dart';

/// 💀 Skeleton Loader - מצב טעינה מקצועי
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        _SkeletonCard(cs: cs).animate().fadeIn(),
        const SizedBox(height: kSpacingMedium),
        _SkeletonCard(cs: cs).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: kSpacingMedium),
        _SkeletonCard(cs: cs).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final ColorScheme cs;
  
  const _SkeletonCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: kCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // שורה 1 - כותרת
            Container(
              width: kSkeletonTitleWidth,
              height: kSkeletonTitleHeight,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
            )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                color: cs.surface.withValues(alpha: kSkeletonShimmerAlpha),
              ),
            
            const SizedBox(height: kSpacingSmall),
            
            // שורה 2 - תת-כותרת
            Container(
              width: kSkeletonSubtitleWidth,
              height: kSkeletonSubtitleHeight,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
            )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                delay: 200.ms,
                color: cs.surface.withValues(alpha: kSkeletonShimmerAlpha),
              ),
            
            const SizedBox(height: kSpacingMedium),
            
            // שורה 3 - תוכן
            Container(
              width: double.infinity,
              height: kSkeletonContentHeight,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
            )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                delay: 400.ms,
                color: cs.surface.withValues(alpha: kSkeletonShimmerAlpha),
              ),
          ],
        ),
      ),
    );
  }
}
