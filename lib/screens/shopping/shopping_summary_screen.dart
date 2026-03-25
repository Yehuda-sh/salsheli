// 📄 lib/screens/shopping/shopping_summary_screen.dart
//
// מסך סיכום קנייה — מוצג לאחר סיום רשימת קניות.
// Version: 6.0 — Receipt-style redesign with torn paper edges
// Last Updated: 22/03/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_error_state.dart';
import '../../widgets/common/app_loading_skeleton.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/painters/perforation_painter.dart';

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
      backgroundColor: theme.extension<AppBrand>()?.paperBackground ?? kPaperBackground,
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
                  return AppErrorState(
                    title: AppStrings.shoppingSummary.loadError,
                    message: provider.errorMessage!,
                    onAction: () => Navigator.of(context).pop(),
                    actionLabel: AppStrings.common.goBack,
                    actionIcon: Icons.arrow_back,
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
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  child: Column(
                    children: [
                      const SizedBox(height: kSpacingLarge),

                      // 🎉 כותרת חגיגית (מעל הקבלה)
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.3, end: 1.0).animate(_scaleEmoji),
                        child: Text(celebrationEmoji, style: const TextStyle(fontSize: 72)),
                      ),
                      const SizedBox(height: kSpacingSmall),
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

                      const SizedBox(height: kSpacingLarge),

                      // 🧾 קבלה — receipt style with torn edges
                      SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(_slideUp),
                        child: FadeTransition(
                          opacity: _slideUp,
                          child: _ReceiptCard(
                            listName: list.name,
                            purchased: purchased,
                            missing: missing,
                            total: total,
                            successRate: successRate,
                            successColor: successColor,
                            spentAmount: spentAmount,
                            budget: budget,
                            budgetDiff: budgetDiff,
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
// 🧾 Receipt Card — torn paper receipt
// ========================================

class _ReceiptCard extends StatelessWidget {
  final String listName;
  final int purchased;
  final int missing;
  final int total;
  final double successRate;
  final Color successColor;
  final double spentAmount;
  final double budget;
  final double budgetDiff;

  const _ReceiptCard({
    required this.listName,
    required this.purchased,
    required this.missing,
    required this.total,
    required this.successRate,
    required this.successColor,
    required this.spentAmount,
    required this.budget,
    required this.budgetDiff,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.shoppingSummary;

    return Column(
      children: [
        // ═══ Top torn edge ═══
        ClipPath(
          clipper: _TornEdgeClipper(isTop: true),
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),

        // ═══ Receipt body ═══
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cs.surface,
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge, vertical: kSpacingMedium),
            child: Column(
              children: [
                // ── Header: שם רשימה + תאריך ──
                Icon(Icons.receipt_long, size: kIconSizeMedium, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: kSpacingTiny),
                Text(
                  listName,
                  style: TextStyle(
                    fontSize: kFontSizeTitle,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpacingXTiny),
                Text(
                  _formattedDate(),
                  style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
                ),

                const SizedBox(height: kSpacingMedium),

                // ── Perforation ──
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: PerforationPainter(
                    color: cs.outline.withValues(alpha: 0.25),
                    dashWidth: 6,
                    dashGap: 4,
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // ── Success circle ──
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: successRate / 100,
                          strokeWidth: 8,
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
                              fontSize: kFontSizeLarge,
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

                const SizedBox(height: kSpacingMedium),

                // ── Perforation ──
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: PerforationPainter(
                    color: cs.outline.withValues(alpha: 0.25),
                    dashWidth: 6,
                    dashGap: 4,
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // ── Stats row ──
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
                      height: kIconSizeLarge,
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
                      height: kIconSizeLarge,
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

                // ── Budget section (only if set) ──
                if (budget > 0) ...[
                  const SizedBox(height: kSpacingMedium),

                  // ── Perforation ──
                  CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: PerforationPainter(
                      color: cs.outline.withValues(alpha: 0.25),
                      dashWidth: 6,
                      dashGap: 4,
                    ),
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // ── Budget row ──
                  Row(
                    children: [
                      Icon(
                        budgetDiff >= 0 ? Icons.savings : Icons.money_off,
                        color: budgetDiff >= 0 ? successColor : cs.error,
                        size: kIconSizeMedium,
                      ),
                      const SizedBox(width: kSpacingSmall),
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
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingTiny),
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
                ],

                const SizedBox(height: kSpacingSmall),
              ],
            ),
          ),
        ),

        // ═══ Bottom torn edge ═══
        ClipPath(
          clipper: _TornEdgeClipper(isTop: false),
          child: Container(
            height: 14,
            color: cs.surface,
          ),
        ),
      ],
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}

// ========================================
// ✂️ Torn edge clipper — zigzag paper effect
// ========================================

class _TornEdgeClipper extends CustomClipper<Path> {
  final bool isTop;

  _TornEdgeClipper({required this.isTop});

  @override
  Path getClip(Size size) {
    final path = Path();
    const zigzagHeight = 7.0;
    const zigzagWidth = 12.0;

    if (isTop) {
      // Top edge: zigzag at top, straight at bottom
      path.moveTo(0, zigzagHeight);
      var x = 0.0;
      while (x < size.width) {
        path.lineTo(x + zigzagWidth / 2, 0);
        path.lineTo(x + zigzagWidth, zigzagHeight);
        x += zigzagWidth;
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      // Bottom edge: straight at top, zigzag at bottom
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height - zigzagHeight);
      var x = size.width;
      while (x > 0) {
        path.lineTo(x - zigzagWidth / 2, size.height);
        path.lineTo(x - zigzagWidth, size.height - zigzagHeight);
        x -= zigzagWidth;
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TornEdgeClipper oldClipper) => isTop != oldClipper.isTop;
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
        Icon(icon, color: iconColor, size: kIconSizeMedium),
        const SizedBox(height: kSpacingXTiny),
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
