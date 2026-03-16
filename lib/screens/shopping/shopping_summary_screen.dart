// 📄 lib/screens/shopping/shopping_summary_screen.dart
//
// מסך סיכום קנייה — מוצג לאחר סיום רשימת קניות.
// Version: 5.0 — Celebration redesign
// Last Updated: 16/03/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_loading_skeleton.dart';
import '../../widgets/common/notebook_background.dart';

class ShoppingSummaryScreen extends StatefulWidget {
  final String listId;

  const ShoppingSummaryScreen({super.key, required this.listId});

  @override
  State<ShoppingSummaryScreen> createState() => _ShoppingSummaryScreenState();
}

class _ShoppingSummaryScreenState extends State<ShoppingSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _scaleEmoji;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _slideUp = CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeOut));
    _scaleEmoji = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut));

    _controller.forward();
    unawaited(HapticFeedback.mediumImpact());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.shoppingSummary;

    return Scaffold(
      backgroundColor: kPaperBackground,
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: Consumer<ShoppingListsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const AppLoadingSkeleton(sectionCount: 3, showHero: false);
                }

                if (provider.errorMessage != null) {
                  return _ErrorState(
                    message: provider.errorMessage!,
                    onBack: () => Navigator.of(context).pop(),
                  );
                }

                final list = provider.getById(widget.listId);
                if (list == null) {
                  return _NotFoundState(
                    onBack: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  );
                }

                // סטטיסטיקות
                final total = list.items.length;
                final purchased = list.items.where((item) => item.isChecked).length;
                final missing = total - purchased;
                final spentAmount = list.items
                    .where((item) => item.isChecked)
                    .fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));
                final budget = list.budget ?? 0.0;
                final budgetDiff = budget - spentAmount;
                final successRate = total > 0 ? (purchased / total) * 100 : 0.0;
                final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;

                // אימוג'י לפי הצלחה
                final celebrationEmoji = successRate >= 90
                    ? '🎉'
                    : successRate >= 70
                        ? '👍'
                        : '💪';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Column(
                    children: [
                      const SizedBox(height: kSpacingLarge),

                      // 🎉 כותרת חגיגית
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.3, end: 1.0).animate(_scaleEmoji),
                        child: Text(celebrationEmoji, style: const TextStyle(fontSize: 72)),
                      ),
                      const SizedBox(height: kSpacingMedium),
                      FadeTransition(
                        opacity: _fadeIn,
                        child: Text(
                          strings.title,
                          style: TextStyle(
                            fontSize: kFontSizeXLarge,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpacingTiny),
                      FadeTransition(
                        opacity: _fadeIn,
                        child: Text(
                          list.name,
                          style: TextStyle(fontSize: kFontSizeTitle, color: cs.onSurfaceVariant),
                        ),
                      ),

                      const SizedBox(height: kSpacingXLarge),

                      // 📊 כרטיס סטטיסטיקות ראשי
                      SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(_slideUp),
                        child: FadeTransition(
                          opacity: _slideUp,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                            child: Padding(
                              padding: const EdgeInsets.all(kSpacingLarge),
                              child: Column(
                                children: [
                                  // אחוז הצלחה — עיגול גדול
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          height: 120,
                                          child: CircularProgressIndicator(
                                            value: successRate / 100,
                                            strokeWidth: 10,
                                            backgroundColor: cs.surfaceContainerHighest,
                                            valueColor: AlwaysStoppedAnimation(
                                              successRate >= 80 ? successColor : cs.tertiary,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${successRate.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontSize: kFontSizeXLarge,
                                                fontWeight: FontWeight.bold,
                                                color: cs.onSurface,
                                              ),
                                            ),
                                            Text(
                                              strings.successRate,
                                              style: TextStyle(fontSize: kFontSizeTiny, color: cs.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: kSpacingLarge),
                                  Divider(height: 1, color: cs.outline.withValues(alpha: 0.1)),
                                  const SizedBox(height: kSpacingMedium),

                                  // שורת מספרים
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _StatColumn(
                                        icon: Icons.check_circle,
                                        iconColor: successColor,
                                        value: '$purchased',
                                        label: strings.purchasedLabel,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: cs.outline.withValues(alpha: 0.1),
                                      ),
                                      _StatColumn(
                                        icon: Icons.remove_shopping_cart,
                                        iconColor: cs.error,
                                        value: '$missing',
                                        label: strings.missingLabel,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: cs.outline.withValues(alpha: 0.1),
                                      ),
                                      _StatColumn(
                                        icon: Icons.shopping_bag,
                                        iconColor: cs.primary,
                                        value: '$total',
                                        label: strings.totalLabel,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: kSpacingMedium),

                      // 💰 תקציב (רק אם הוגדר)
                      if (budget > 0)
                        SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(_slideUp),
                          child: FadeTransition(
                            opacity: _slideUp,
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                              child: Padding(
                                padding: const EdgeInsets.all(kSpacingMedium),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: (budgetDiff >= 0 ? successColor : cs.error).withValues(alpha: 0.15),
                                      child: Icon(
                                        budgetDiff >= 0 ? Icons.savings : Icons.money_off,
                                        color: budgetDiff >= 0 ? successColor : cs.error,
                                      ),
                                    ),
                                    const SizedBox(width: kSpacingMedium),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            strings.budgetTitle,
                                            style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
                                          ),
                                          Text(
                                            '₪${spentAmount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: kFontSizeLarge,
                                              fontWeight: FontWeight.bold,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: (budgetDiff >= 0 ? successColor : cs.error).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(kBorderRadius),
                                      ),
                                      child: Text(
                                        budgetDiff >= 0
                                            ? strings.budgetRemaining('₪${budgetDiff.toStringAsFixed(0)}')
                                            : strings.budgetOver('₪${budgetDiff.abs().toStringAsFixed(0)}'),
                                        style: TextStyle(
                                          fontSize: kFontSizeSmall,
                                          fontWeight: FontWeight.w600,
                                          color: budgetDiff >= 0 ? successColor : cs.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: kSpacingXLarge),

                      // 🔙 כפתור חזרה
                      FadeTransition(
                        opacity: _fadeIn,
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              unawaited(HapticFeedback.lightImpact());
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            icon: const Icon(Icons.home),
                            label: Text(strings.backToHome),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: kSpacingMedium),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: kSpacingLarge),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widgets
// ========================================

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        Text(
          label,
          style: TextStyle(fontSize: kFontSizeTiny, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _ErrorState({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.shoppingSummary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error.withValues(alpha: 0.7)),
            const SizedBox(height: kSpacingMedium),
            Text(strings.loadError, style: TextStyle(fontSize: kFontSizeTitle, color: cs.onSurface)),
            const SizedBox(height: kSpacingSmall),
            Text(message, style: TextStyle(fontSize: kFontSizeMedium, color: cs.onSurfaceVariant)),
            const SizedBox(height: kSpacingLarge),
            FilledButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: Text(AppStrings.common.goBack),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  final VoidCallback onBack;

  const _NotFoundState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.shoppingSummary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: cs.onSurfaceVariant),
            const SizedBox(height: kSpacingMedium),
            Text(strings.notFound, style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: kSpacingSmall),
            Text(strings.notFoundSubtitle, style: TextStyle(fontSize: kFontSizeMedium, color: cs.onSurfaceVariant)),
            const SizedBox(height: kSpacingLarge),
            FilledButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.home),
              label: Text(strings.backToHome),
            ),
          ],
        ),
      ),
    );
  }
}
