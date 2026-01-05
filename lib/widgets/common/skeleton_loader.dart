// 📄 lib/widgets/common/skeleton_loader.dart
//
// Skeleton widgets לטעינה חזותית - SkeletonBox, SkeletonCircle, SkeletonListCard, SkeletonListView.
// אנימציית shimmer אמיתית עם TweenAnimationBuilder, עיצוב StickyNote, ושימוש משותף לכל האפליקציה.
//
// ✅ תיקונים:
//    - אנימציית shimmer אמיתית עם TweenAnimationBuilder (לא AnimatedContainer סטטי)
//    - הוספת Semantics עם excludeFromSemantics לנגישות
//    - הוספת פרמטר animate לשליטה באנימציה
//    - הוספת SkeletonCircle helper לצורות עגולות
//    - תמיכה ב-Dark Mode עם צבעי sticky מותאמים
//    - הסרת DateTime.now() מ-build לביצועים טובים
//
// 🔗 Related: StickyNote, ui_constants

import 'package:flutter/material.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/widgets/common/sticky_note.dart';

/// 💀 קופסה בסיסית מהבהבת (Skeleton Box)
///
/// משמשת כבניין יסוד ל-skeleton screens.
/// מציגה אנימציית shimmer אמיתית עם TweenAnimationBuilder.
///
/// Parameters:
/// - [width]: רוחב הקופסה
/// - [height]: גובה הקופסה
/// - [borderRadius]: רדיוס פינות (ברירת מחדל: kBorderRadiusSmall)
/// - [animate]: האם להפעיל אנימציית shimmer (ברירת מחדל: true)
class SkeletonBox extends StatefulWidget {
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
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseColor = cs.surfaceContainerHighest;
    final highlightColor = cs.surface;

    // ✅ Semantics - הסתר מקוראי מסך
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // shimmer effect from left to right
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: widget.animate
                    ? [
                        (_animation.value - 1).clamp(0.0, 1.0),
                        _animation.value.clamp(0.0, 1.0),
                        (_animation.value + 1).clamp(0.0, 1.0),
                      ]
                    : const [0.0, 0.5, 1.0],
              ),
              borderRadius:
                  widget.borderRadius ?? BorderRadius.circular(kBorderRadiusSmall),
            ),
          );
        },
      ),
    );
  }
}

/// 💀 עיגול מהבהב (Skeleton Circle)
///
/// גרסה עגולה של SkeletonBox לאייקונים ותמונות פרופיל.
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

/// 💀 Skeleton של כרטיס רשימת קניות
///
/// מציג "שלד" של כרטיס רשימה בזמן טעינה.
/// משתמש ב-StickyNote לעיצוב עקבי.
///
/// Parameters:
/// - [index]: אינדקס לבחירת צבע וסיבוב (ברירת מחדל: 0)
/// - [animate]: האם להפעיל אנימציית shimmer (ברירת מחדל: true)
class SkeletonListCard extends StatelessWidget {
  /// אינדקס לבחירת צבע וסיבוב הפתק (0-2)
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎨 צבעים לפתקים - תמיכה ב-Dark Mode
    final stickyColors = isDark
        ? [kStickyYellowDark, kStickyPinkDark, kStickyGreenDark]
        : [kStickyYellow, kStickyPink, kStickyGreen];
    final stickyRotations = [0.01, -0.015, 0.01];

    // ✅ שימוש ב-index במקום DateTime.now() לביצועים טובים
    final colorIndex = index % 3;

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kSpacingMedium, vertical: kSpacingSmall),
        child: StickyNote(
          color: stickyColors[colorIndex],
          rotation: stickyRotations[colorIndex],
          animate: false, // ✅ ללא אנימציה כפולה - ה-shimmer מספיק
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // אייקון - עיגול
                    SkeletonCircle(size: 40, animate: animate),
                    const SizedBox(width: kSpacingMedium),
                    // כותרת
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                              width: double.infinity, height: 18, animate: animate),
                          const SizedBox(height: kSpacingSmall),
                          SkeletonBox(width: 100, height: 14, animate: animate),
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
                      Column(
                        children: [
                          SkeletonBox(width: 40, height: 12, animate: animate),
                          const SizedBox(height: kSpacingTiny),
                          SkeletonBox(width: 50, height: 10, animate: animate),
                        ],
                      ),
                  ],
                ),
              ],
            ),
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

  /// Constructor עם שם - לתאימות לאחור
  const SkeletonListView.listCards({
    super.key,
    this.itemCount = 5,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ ExcludeSemantics - הסתר את כל הרשימה מקוראי מסך
    return ExcludeSemantics(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
        itemCount: itemCount,
        itemBuilder: (context, index) => SkeletonListCard(
          index: index, // ✅ מעביר index לגיוון צבעים
          animate: animate,
        ),
      ),
    );
  }
}
