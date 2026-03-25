import 'package:flutter/material.dart';
import '../../../../widgets/common/sticky_button.dart';
import '../../../../core/ui_constants.dart';
import '../../../../widgets/common/skeleton_loader.dart';
import '../../../../l10n/app_strings.dart';

class ActiveShoppingLoadingSkeleton extends StatelessWidget {
  final Color accentColor;

  const ActiveShoppingLoadingSkeleton({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Stats Header Skeleton
        Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor.withValues(alpha: 0.1), cs.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (index) => const SkeletonBox(width: 60, height: 80),
            ),
          ),
        ),

        // Items List Skeleton
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(kSpacingMedium),
            itemCount: 5,
            itemBuilder: (context, index) => const Card(
              margin: EdgeInsets.only(bottom: kSpacingSmall),
              child: Padding(
                padding: EdgeInsets.all(kSpacingSmallPlus),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(width: kSpacingSmall),
                        Expanded(child: SkeletonBox(width: double.infinity, height: 20)),
                        SizedBox(width: kSpacingSmall),
                        SkeletonBox(width: 60, height: 30),
                      ],
                    ),
                    SizedBox(height: kSpacingSmall),
                    Row(
                      children: [
                        Expanded(child: SkeletonBox(width: double.infinity, height: kButtonHeight)),
                        SizedBox(width: kSpacingSmall),
                        Expanded(child: SkeletonBox(width: double.infinity, height: kButtonHeight)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: Error State Screen
// ========================================

class ActiveShoppingErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ActiveShoppingErrorState({super.key, required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: kIconSizeXLarge * 2, color: cs.error),
            SizedBox(height: kSpacingMedium),
            Text(
              AppStrings.shopping.oopsError,
              style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            SizedBox(height: kSpacingSmall),
            Text(
              errorMessage,
              style: TextStyle(fontSize: kFontSizeBody, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            Semantics(
              label: AppStrings.shopping.retryLoadSemantics,
              button: true,
              child: StickyButton(label: AppStrings.common.retry, icon: Icons.refresh, onPressed: onRetry, color: cs.tertiary),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Widget: Empty State Screen
// ========================================

class ActiveShoppingEmptyState extends StatelessWidget {
  final Color accentColor;

  const ActiveShoppingEmptyState({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: kIconSizeXLarge * 2, color: cs.onSurfaceVariant),
          SizedBox(height: kSpacingMedium),
          Text(
            AppStrings.shopping.listEmpty,
            style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: kSpacingSmall),
          Text(
            AppStrings.shopping.noItemsToBuy,
            style: TextStyle(fontSize: kFontSizeBody, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: סטטיסטיקה קומפקטית
// ========================================

class CompactStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final int? total;
  final Color color;
  final bool highlight;

  const CompactStat({super.key, 
    required this.icon,
    required this.value,
    this.total,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          total != null ? '$value/$total' : '$value',
          style: TextStyle(
            fontSize: highlight ? kFontSizeLarge : kFontSizeBody,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// קו מפריד אנכי - מקבל צבע מה-Theme
Widget buildDivider(Color color) {
  return Container(
    height: 24,
    width: 1,
    color: color.withValues(alpha: 0.3),
  );
}

// ========================================
// Widget: פריט בקנייה פעילה - שורה פשוטה על המחברת
// ========================================

