// 📄 lib/widgets/common/skeleton_loader.dart
//
//
// 🇮🇱 **Skeleton Widgets לטעינה חזותית** — SkeletonBox, SkeletonCircle,
//     SkeletonListCard, SkeletonListView.
//
// ✨ Features:
//     - שילוב shimmer package לביצועים גבוהים (replaces manual AnimationController)
//     - אפקט Shimmer מדורג בזווית 45° (Phased Shimmer)
//     - אופטימיזציית RepaintBoundary גלובלית — בידוד GPU לכל רכיב
//     - תמיכה מלאה ב-AppBrand Palette עם withValues(alpha:)
//     - flutter_animate fadeIn on list appearance
//     - Gap-based spacing
//
// 📅 History:
//                          45° angle, Gap spacing, StatelessWidget simplification
//     v3.0              — Manual shimmer with AnimationController, StickyNote cards,
//                          Dark Mode support, ExcludeSemantics
//
// 🔗 Related: StickyNote, ui_constants, DashboardCard

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';
import 'sticky_note.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SHIMMER GRADIENT (45° Diagonal)
// ═══════════════════════════════════════════════════════════════════════════

/// 🎨 v4.0: Shimmer gradient factory — 45° diagonal, subtle alpha
///
/// Uses `withValues(alpha:)` for precise opacity control.
/// baseColor (alpha: 0.7) → visible but subtle surface
/// highlightColor (alpha: 0.3) → lighter shimmer band
LinearGradient _shimmerGradient(ColorScheme cs) {
  final base = cs.surfaceContainerHighest.withValues(alpha: 0.7);
  final highlight = cs.surfaceContainerHighest.withValues(alpha: 0.3);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [base, highlight, base],
    stops: const [0.35, 0.5, 0.65],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON BOX
// ═══════════════════════════════════════════════════════════════════════════

/// 💀 קופסה בסיסית מהבהבת (Skeleton Box)
///
/// v4.0: StatelessWidget — האנימציה מנוהלת ע"י shimmer package.
/// כל box עטוף ב-RepaintBoundary לבידוד GPU.
///
/// Parameters:
/// - [width]: רוחב הקופסה
/// - [height]: גובה הקופסה
/// - [borderRadius]: רדיוס פינות (ברירת מחדל: kBorderRadius = 14px)
/// - [animate]: האם להפעיל אנימציית shimmer (ברירת מחדל: true)
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  /// האם להפעיל אנימציית shimmer (ברירת מחדל: true)
  final bool animate;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius:
            borderRadius ?? BorderRadius.circular(kBorderRadius),
      ),
    );

    // v4.0: shimmer package — replaces manual AnimationController + AnimatedBuilder
    if (animate) {
      box = Shimmer(
        gradient: _shimmerGradient(cs),
        child: box,
      );
    }

    // ✅ ExcludeSemantics — הסתר מקוראי מסך
    // ✅ RepaintBoundary — בידוד GPU (קריטי: shimmer רץ 60/120fps)
    return ExcludeSemantics(
      child: RepaintBoundary(child: box),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON CIRCLE
// ═══════════════════════════════════════════════════════════════════════════

/// 💀 עיגול מהבהב (Skeleton Circle)
///
/// v4.0: StatelessWidget + RepaintBoundary (via SkeletonBox).
///
/// Parameters:
/// - [size]: גודל העיגול (רוחב וגובה)
/// - [animate]: האם להפעיל אנימציית shimmer (ברירת מחדל: true)
class SkeletonCircle extends StatelessWidget {
  final double size;
  final bool animate;

  const SkeletonCircle({
    super.key,
    required this.size,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      animate: animate,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON LIST CARD (The Ghost Note)
// ═══════════════════════════════════════════════════════════════════════════

/// 💀 Skeleton של כרטיס רשימת קניות (The Ghost Note)
///
/// v4.0: כרטיס "שקוף" של DashboardCard:
///     - StickyNote בגרסה דוממת (rotation: 0, animate: false)
///     - Gap-based spacing
///     - kBorderRadius (14px)
///     - RepaintBoundary per card
///
/// Parameters:
/// - [index]: אינדקס לבחירת צבע (ברירת מחדל: 0)
/// - [animate]: האם להפעיל אנימציית shimmer (ברירת מחדל: true)
class SkeletonListCard extends StatelessWidget {
  /// אינדקס לבחירת צבע הפתק (0-2)
  final int index;

  /// האם להפעיל אנימציית shimmer
  final bool animate;

  const SkeletonListCard({
    super.key,
    this.index = 0,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<AppBrand>();

    // 🎨 צבעים לפתקים - AppBrand resolves dark variants internally
    final stickyColors = [
      brand?.stickyYellow ?? kStickyYellow,
      brand?.stickyPink ?? kStickyPink,
      brand?.stickyGreen ?? kStickyGreen,
    ];

    final colorIndex = index % 3;

    return ExcludeSemantics(
      // ✅ RepaintBoundary — בידוד כרטיס שלם מעץ הרינדור
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kSpacingMedium, vertical: kSpacingSmall),
          child: StickyNote(
            color: stickyColors[colorIndex],
            // v4.0: דוממת (default rotation: 0) למניעת ריצוד בזמן טעינה
            animate: false,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // אייקון - עיגול
                      SkeletonCircle(size: 40, animate: animate),
                      const Gap(kSpacingMedium),
                      // כותרת
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(
                                width: double.infinity,
                                height: 18,
                                animate: animate),
                            const Gap(kSpacingSmall),
                            SkeletonBox(
                                width: 100, height: 14, animate: animate),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(kSpacingMedium),
                  // סטטיסטיקות
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 0; i < 3; i++)
                        Column(
                          children: [
                            SkeletonBox(
                                width: 40, height: 12, animate: animate),
                            const Gap(kSpacingTiny),
                            SkeletonBox(
                                width: 50, height: 10, animate: animate),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON LIST VIEW
// ═══════════════════════════════════════════════════════════════════════════

/// 💀 רשימת Skeleton Cards
///
/// v4.0: flutter_animate fadeIn on first appearance — מונע "קפיצה" ויזואלית.
///
/// Parameters:
/// - [itemCount]: מספר הכרטיסים להצגה (ברירת מחדל: 5)
/// - [animate]: האם להפעיל אנימציית shimmer (ברירת מחדל: true)
class SkeletonListView extends StatelessWidget {
  final int itemCount;

  /// האם להפעיל אנימציית shimmer
  final bool animate;

  const SkeletonListView({
    super.key,
    this.itemCount = 5,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ ExcludeSemantics — הסתר את כל הרשימה מקוראי מסך
    return ExcludeSemantics(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
        itemCount: itemCount,
        itemBuilder: (context, index) => SkeletonListCard(
          index: index,
          animate: animate,
        ),
      ),
    )
        // v4.0: fadeIn עדין למניעת "קפיצה" ויזואלית חדה
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }
}
