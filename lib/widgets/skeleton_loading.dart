// 📄 File: lib/widgets/skeleton_loading.dart
// 🎯 Purpose: Skeleton Loading Components - מחליף CircularProgressIndicator
// ✨ מספק חוויית טעינה חלקה ויפה יותר

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/ui_constants.dart';

/// 🦴 Base Skeleton widget עם Shimmer effect
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

/// 📋 Skeleton לרשימת מוצרים
class ProductsSkeletonList extends StatelessWidget {
  final int itemCount;
  
  const ProductsSkeletonList({
    super.key,
    this.itemCount = 6,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: const EdgeInsets.all(kSpacingMedium),
      itemBuilder: (context, index) {
        return const ProductSkeletonCard();
      },
    );
  }
}

/// 🎴 Skeleton לכרטיס מוצר בודד
class ProductSkeletonCard extends StatelessWidget {
  const ProductSkeletonCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Row(
            children: [
              // תמונה
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
              ),
              const SizedBox(width: kSpacingMedium),
              
              // טקסט
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              
              // כפתור
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 📊 Skeleton Grid למוצרים
class ProductsSkeletonGrid extends StatelessWidget {
  final int itemCount;
  
  const ProductsSkeletonGrid({
    super.key,
    this.itemCount = 6,
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: kSpacingSmall,
        mainAxisSpacing: kSpacingSmall,
      ),
      itemCount: itemCount,
      padding: const EdgeInsets.all(kSpacingMedium),
      itemBuilder: (context, index) {
        return const ProductSkeletonGridCard();
      },
    );
  }
}

/// 🎴 Skeleton Grid Card
class ProductSkeletonGridCard extends StatelessWidget {
  const ProductSkeletonGridCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(kSpacingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // תמונה
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
              ),
              const SizedBox(height: kSpacingSmall),
              
              // שם המוצר
              Container(
                width: double.infinity,
                height: 14,
                color: Colors.white,
              ),
              const SizedBox(height: 6),
              
              // מותג
              Container(
                width: 100,
                height: 12,
                color: Colors.white,
              ),
              const Spacer(),
              
              // מחיר
              Container(
                width: 60,
                height: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 📝 Skeleton לרשימת קניות
class ShoppingListSkeleton extends StatelessWidget {
  const ShoppingListSkeleton({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      padding: const EdgeInsets.all(kSpacingMedium),
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: kSpacingMedium),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              title: Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
              ),
              subtitle: Container(
                width: 120,
                height: 12,
                color: Colors.white,
              ),
              trailing: Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🏷️ Skeleton לקטגוריות
class CategoriesSkeleton extends StatelessWidget {
  const CategoriesSkeleton({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 80,
              height: 32,
              margin: const EdgeInsets.only(right: kSpacingSmall),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}
