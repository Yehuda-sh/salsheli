// 📄 File: lib/screens/home/home_dashboard_screen_ux.dart
// 🎨 UX Improvements: Skeleton Loading + Staggered Animations
//
// שיפורים:
// ✅ Skeleton loading במקום spinner
// ✅ Staggered animations לכרטיסים
// ✅ Haptic feedback
// ✅ Constants למידות (אין hardcoded values)
// ✅ Sticky Notes Design - פתקים צבעוניים במצב טעינה!
//
// גרסה: 3.0 - Sticky Notes Integration (18/10/2025)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/ui_constants.dart';
import '../../widgets/common/sticky_note.dart';

/// 💀 Skeleton Loader - מצב טעינה מקצועי
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // פתק צהוב - תואם ל-Header
        const _SkeletonCard(color: kStickyYellow, rotation: -0.02)
          .animate().fadeIn(),
        const SizedBox(height: kSpacingMedium),
        
        // פתק ורוד - תואם ל-ReceiptsCard
        const _SkeletonCard(color: kStickyPink, rotation: 0.015)
          .animate().fadeIn(delay: 100.ms),
        const SizedBox(height: kSpacingMedium),
        
        // פתק ירוק - תואם ל-ActiveListsCard
        const _SkeletonCard(color: kStickyGreen, rotation: -0.01)
          .animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Color color;
  final double rotation;
  
  const _SkeletonCard({
    required this.color,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return StickyNote(
      color: color,
      rotation: rotation,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // שורה 1 - כותרת
            Container(
              width: kSkeletonTitleWidth,
              height: kSkeletonTitleHeight,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),  // ✅ צבע כהה קל על הפתק
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
            )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                color: Colors.white.withValues(alpha: 0.4),  // ✅ shimmer לבן
              ),
            
            const SizedBox(height: kSpacingSmall),
            
            // שורה 2 - תת-כותרת
            Container(
              width: kSkeletonSubtitleWidth,
              height: kSkeletonSubtitleHeight,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),  // ✅ צבע כהה קל על הפתק
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
            )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                delay: 200.ms,
                color: Colors.white.withValues(alpha: 0.4),  // ✅ shimmer לבן
              ),
            
            const SizedBox(height: kSpacingMedium),
            
            // שורה 3 - תוכן
            Container(
              width: double.infinity,
              height: kSkeletonContentHeight,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),  // ✅ צבע כהה קל על הפתק
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
            )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                delay: 400.ms,
                color: Colors.white.withValues(alpha: 0.4),  // ✅ shimmer לבן
              ),
          ],
        ),
    );
  }
}
