// File: lib/widgets/common/skeleton_loading.dart
// Purpose: Reusable skeleton loading widget with shimmer effect

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/ui_constants.dart';

/// Base Skeleton widget with Shimmer effect
/// 
/// Universal loading placeholder that can be used across the app
/// for consistent loading states.
/// 
/// Example:
/// ```dart
/// SkeletonBox(width: 100, height: 20)
/// SkeletonBox(width: double.infinity, height: 50, borderRadius: BorderRadius.circular(8))
/// ```
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height ?? 20,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(kBorderRadiusSmall),
        ),
      ),
    );
  }
}
