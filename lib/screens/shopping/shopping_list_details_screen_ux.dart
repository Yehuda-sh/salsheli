// 📄 File: lib/screens/shopping/shopping_list_details_screen_ux.dart
// 🎨 UX Improvements: Skeleton Loading & States for Shopping List Details
//
// 🔗 Purpose: Helper file for shopping_list_details_screen.dart
// 📦 Contains: Loading skeletons, empty states, error states
// 🎯 Used by: shopping_list_details_screen.dart
//
// 💡 Why separate file?
// - Keeps main screen file manageable (1258 → 1100 lines)
// - Reusable state components
// - Easier to maintain loading/error/empty states
// - Consistent with home_dashboard pattern
//
// 📐 Structure:
// - ShoppingDetailsLoadingSkeleton: Skeleton loading for items
// - ShoppingDetailsErrorState: Error state with retry
// - ShoppingDetailsEmptyState: Empty list state
// - ShoppingDetailsEmptySearch: Empty search results
//
// 🎨 Design:
// - Matches sticky note colors from main screen
// - Consistent animations with main app
// - RTL support built-in

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';

/// 💀 Skeleton Screen לטעינה
class ShoppingDetailsLoadingSkeleton extends StatelessWidget {
  const ShoppingDetailsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final stickyColors = [kStickyYellow, kStickyPink, kStickyGreen];
    final stickyRotations = [0.01, -0.015, 0.01];

    return ListView.builder(
      padding: const EdgeInsets.all(kSpacingMedium),
      itemCount: 8,
      itemBuilder: (context, index) {
        final colorIndex = index % stickyColors.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: kSpacingMedium),
          child: StickyNote(
            color: stickyColors[colorIndex],
            rotation: stickyRotations[colorIndex],
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Row(
                children: [
                  // אייקון
                  _SkeletonBox(width: 40, height: 40, borderRadius: 20, delay: index * 100),
                  const SizedBox(width: kSpacingMedium),
                  // תוכן
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(width: double.infinity, height: 16, delay: index * 100 + 50),
                        const SizedBox(height: kSpacingSmall),
                        _SkeletonBox(width: 120, height: 14, delay: index * 100 + 100),
                      ],
                    ),
                  ),
                  // כפתורים
                  Row(
                    children: [
                      _SkeletonBox(width: 40, height: 40, borderRadius: 20, delay: index * 100 + 150),
                      const SizedBox(width: kSpacingSmall),
                      _SkeletonBox(width: 40, height: 40, borderRadius: 20, delay: index * 100 + 200),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 💀 Skeleton Box עם Shimmer
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final int delay;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = kBorderRadius,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ],
                stops: [0.0, value, 1.0],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// ❌ מצב שגיאה
class ShoppingDetailsErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ShoppingDetailsErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: StickyNote(
            color: kStickyPink,
            rotation: -0.02,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: kIconSizeXXLarge, color: Colors.red.shade700),
                  const SizedBox(height: kSpacingMedium),
                  Text(
                    AppStrings.listDetails.errorTitle,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kSpacingSmall),
                  Text(
                    AppStrings.listDetails.errorMessage(errorMessage),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpacingLarge),
                  StickyButton(
                    color: Colors.red.shade100,
                    textColor: Colors.red.shade700,
                    label: AppStrings.common.retry,
                    icon: Icons.refresh,
                    onPressed: onRetry,
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

/// 📋 מצב ריק
class ShoppingDetailsEmptyState extends StatelessWidget {
  final VoidCallback onAddFromCatalog;

  const ShoppingDetailsEmptyState({
    super.key,
    required this.onAddFromCatalog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: StickyNote(
            color: kStickyGreen,
            rotation: -0.015,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: kIconSizeXXLarge, color: Colors.green.shade700),
                  const SizedBox(height: kSpacingXLarge),
                  Text(
                    AppStrings.listDetails.emptyListTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kSpacingMedium),
                  Text(AppStrings.listDetails.emptyListMessage, style: const TextStyle(fontSize: kFontSizeMedium)),
                  const SizedBox(height: kSpacingSmall),
                  Text(AppStrings.listDetails.emptyListSubMessage, style: const TextStyle(fontSize: kFontSizeSmall)),
                  const SizedBox(height: kSpacingLarge),
                  StickyButton(
                    color: kStickyCyan,
                    label: AppStrings.listDetails.populateFromCatalog,
                    icon: Icons.library_add,
                    onPressed: onAddFromCatalog,
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

/// 📭 תוצאות חיפוש ריקות
class ShoppingDetailsEmptySearch extends StatelessWidget {
  final VoidCallback onClearSearch;

  const ShoppingDetailsEmptySearch({
    super.key,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: StickyNote(
            color: kStickyYellow,
            rotation: 0.015,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: kIconSizeXXLarge, color: Colors.orange.shade700),
                  const SizedBox(height: kSpacingLarge),
                  Text(
                    AppStrings.listDetails.noSearchResultsTitle,
                    style: const TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kSpacingSmall),
                  Text(AppStrings.listDetails.noSearchResultsMessage),
                  const SizedBox(height: kSpacingLarge),
                  StickyButtonSmall(
                    color: Colors.orange.shade100,
                    textColor: Colors.orange.shade700,
                    label: AppStrings.listDetails.clearSearchButton,
                    icon: Icons.clear_all,
                    onPressed: onClearSearch,
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
