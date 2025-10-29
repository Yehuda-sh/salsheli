// 📄 File: lib/screens/home/home_dashboard_screen_ux.dart
// 🎨 UX Improvements: Skeleton Loading with Sticky Notes Design

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/ui_constants.dart';
import '../../widgets/common/sticky_note.dart';

/// 💀 Skeleton Loader - מצב טעינה מקצועי
class DashboardSkeleton extends StatelessWidget {
  final bool showAll;
  const DashboardSkeleton({super.key, this.showAll = true});

  @override
  Widget build(BuildContext context) {
    if (!showAll) {
      // רק כרטיס אחד להצעות
      return const _SkeletonCard(color: kStickyGreen, rotation: -0.01)
        .animate().fadeIn();
    }
    
    return Column(
      children: [
        // פתק צהוב - תואם ל-UpcomingShopCard
        const _SkeletonCard(color: kStickyYellow, rotation: -0.02)
          .animate().fadeIn(),
        const SizedBox(height: kSpacingMedium),
        
        // פתק ורוד - תואם ל-SmartSuggestionsCard
        const _SkeletonCard(color: kStickyPink, rotation: 0.015)
          .animate().fadeIn(delay: 100.ms),
        const SizedBox(height: kSpacingMedium),
        
        // פתק ירוק - תואם ל-רשימות נוספות
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
          Container(
            width: 150.0,
            height: 20.0,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                color: Colors.white.withValues(alpha: 0.4),
              ),

          const SizedBox(height: kSpacingSmall),
          Container(
            width: 200.0,
            height: 16.0,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                delay: 200.ms,
                color: Colors.white.withValues(alpha: 0.4),
              ),

          const SizedBox(height: kSpacingMedium),
          Container(
            width: double.infinity,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                delay: 400.ms,
                color: Colors.white.withValues(alpha: 0.4),
              ),
        ],
      )
    );
  }
}
