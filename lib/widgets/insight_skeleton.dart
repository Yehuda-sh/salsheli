// 📄 File: lib/widgets/insight_skeleton.dart
// תיאור: Skeleton loader עם shimmer effect לכרטיסי תובנות בזמן טעינה

import 'package:flutter/material.dart';

// קבועים
const int _kSkeletonItemCount = 3;
const double _kSkeletonAspectRatio = 1.8;
const double _kSkeletonSpacing = 12.0;
const double _kCardBorderRadius = 12.0;
const double _kIconBoxSize = 40.0;
const double _kIconBorderRadius = 8.0;
const double _kTitleWidth = 100.0;
const double _kTitleHeight = 20.0;
const double _kValueWidth = 80.0;
const double _kValueHeight = 28.0;
const double _kDescriptionHeight = 16.0;
const int _kShimmerDurationMs = 1500;

class InsightSkeleton extends StatefulWidget {
  final int itemCount;

  const InsightSkeleton({super.key, this.itemCount = _kSkeletonItemCount});

  @override
  State<InsightSkeleton> createState() => _InsightSkeletonState();
}

class _InsightSkeletonState extends State<InsightSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kShimmerDurationMs),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      label: 'טוען תובנות',
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: _kSkeletonAspectRatio,
          crossAxisSpacing: _kSkeletonSpacing,
          mainAxisSpacing: _kSkeletonSpacing,
        ),
        itemBuilder: (context, index) {
          return Card(
            color: cs.surfaceContainerHigh,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kCardBorderRadius),
              side: BorderSide(
                color: cs.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔝 Header
                  Row(
                    children: [
                      _buildShimmerBox(
                        cs,
                        width: _kIconBoxSize,
                        height: _kIconBoxSize,
                        radius: _kIconBorderRadius,
                      ),
                      const SizedBox(width: 12),
                      _buildShimmerBox(
                        cs,
                        width: _kTitleWidth,
                        height: _kTitleHeight,
                        radius: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 📊 Main Content
                  _buildShimmerBox(
                    cs,
                    width: _kValueWidth,
                    height: _kValueHeight,
                    radius: 6,
                  ),
                  const SizedBox(height: 8),
                  _buildShimmerBox(
                    cs,
                    width: double.infinity,
                    height: _kDescriptionHeight,
                    radius: 4,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerBox(
    ColorScheme cs, {
    required double width,
    required double height,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                cs.surfaceContainerHighest,
                cs.surfaceContainerHighest.withValues(alpha: 0.5),
                cs.surfaceContainerHighest,
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
