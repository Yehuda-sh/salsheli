// 📄 lib/widgets/common/skeleton_loader.dart
//
// Skeleton widgets לטעינה חזותית - SkeletonBox, SkeletonListCard, SkeletonListView.
// אנימציית gradient מהבהבת, עיצוב StickyNote, ושימוש משותף לכל האפליקציה.
//
// 🔗 Related: StickyNote, ui_constants

import 'package:flutter/material.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/widgets/common/sticky_note.dart';

/// 💀 קופסה בסיסית מהבהבת (Skeleton Box)
/// 
/// משמשת כבניין יסוד ל-skeleton screens.
/// מציגה אנימציה של gradient מהבהב.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest.withValues(alpha: 0.3),
            cs.surfaceContainerHighest.withValues(alpha: 0.1),
            cs.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(kBorderRadiusSmall),
      ),
    );
  }
}

/// 💀 Skeleton של כרטיס רשימת קניות
/// 
/// מציג "שלד" של כרטיס רשימה בזמן טעינה.
/// משתמש ב-StickyNote לעיצוב עקבי.
class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 צבעים לפתקים (rotation)
    final stickyColors = [kStickyYellow, kStickyPink, kStickyGreen];
    final stickyRotations = [0.01, -0.015, 0.01];

    // בחר צבע אקראי לפי timestamp
    final index = DateTime.now().millisecond % 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      child: StickyNote(
        color: stickyColors[index],
        rotation: stickyRotations[index],
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // אייקון
                  SkeletonBox(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(width: kSpacingMedium),
                  // כותרת
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: double.infinity, height: 18),
                        SizedBox(height: kSpacingSmall),
                        SkeletonBox(width: 100, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingMedium),
              // סטטיסטיקות
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < 3; i++)
                    const Column(
                      children: [
                        SkeletonBox(width: 40, height: 12),
                        SizedBox(height: kSpacingTiny),
                        SkeletonBox(width: 50, height: 10),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 💀 רשימת Skeleton Cards
/// 
/// מציגה מספר כרטיסי skeleton ברצף.
/// שימושי למסכי רשימות בזמן טעינה.
class SkeletonListView extends StatelessWidget {
  final int itemCount;

  const SkeletonListView({
    super.key,
    this.itemCount = 5,
  });

  /// Constructor עם שם - לתאימות לאחור
  const SkeletonListView.listCards({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonListCard(),
    );
  }
}
