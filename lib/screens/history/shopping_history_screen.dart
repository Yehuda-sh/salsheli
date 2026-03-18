// 📄 lib/screens/history/shopping_history_screen.dart
//
// מסך היסטוריית קניות - צפייה בקבלות קודמות.
// כולל מיון, סינון וסטטיסטיקות הוצאות.
// שילוב: רקע מחברת + Glass AppBar + אנימציות מדורגות
//
// ✅ Features:
//    - Glass blur AppBar
//    - אנימציות כניסה מדורגות (AnimationController + Interval, פעם ראשונה בלבד)
//    - סטטיסטיקות: קניות, פריטים, סה"כ, ממוצע
//    - Empty state אנימטיבי עם CTA
//    - Haptic feedback ב-refresh וסינון
//    - נגישות משופרת
//
// Version: 5.0 (18/03/2026)
// 🔗 Related: ReceiptProvider, Receipt

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/receipt.dart';
import '../../providers/receipt_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/app_loading_skeleton.dart';

class ShoppingHistoryScreen extends StatefulWidget {
  /// אם מועבר, הקבלה הזו תוצג מורחבת אוטומטית
  final String? initialReceiptId;

  const ShoppingHistoryScreen({super.key, this.initialReceiptId});

  @override
  State<ShoppingHistoryScreen> createState() => _ShoppingHistoryScreenState();
}

class _ShoppingHistoryScreenState extends State<ShoppingHistoryScreen>
    with SingleTickerProviderStateMixin {
  String _filterPeriod = 'month'; // month, 3months, all
  String _sortBy = 'date'; // date, store, amount

  /// אנימציות מדורגות — רצות רק בפעם הראשונה (כמו בהגדרות)
  late final AnimationController _animController;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 4; // filters, stats, list, empty

  /// דגל — אנימציה כבר רצה?
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    // אם פתחו עם קבלה ספציפית - הצג הכל כדי שהיא תהיה גלויה
    if (widget.initialReceiptId != null) {
      _filterPeriod = 'all';
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.15;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.15;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
          .animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// עוטף widget באנימציית כניסה מדורגת (רק בפעם הראשונה)
  Widget _staggered(Widget child, int index) {
    if (_hasAnimated || index >= _sectionCount) return child;
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(
        position: _slideAnims[index],
        child: child,
      ),
    );
  }

  /// מפעיל את האנימציה פעם אחת
  void _triggerEntryAnimation() {
    if (!_hasAnimated) {
      _animController.forward().then((_) {
        if (mounted) setState(() => _hasAnimated = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.shoppingHistory;

    return Stack(
      children: [
        const NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // 🧊 Glass blur effect
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: kGlassBlurSigma,
                  sigmaY: kGlassBlurSigma,
                ),
                child: Container(
                  color: cs.surface.withValues(alpha: 0.7),
                ),
              ),
            ),
            title: Text(strings.title),
            centerTitle: true,
            actions: [
              // מיון
              PopupMenuButton<String>(
                icon: Icon(Icons.sort, color: cs.primary),
                tooltip: strings.sortTooltip,
                onSelected: (value) {
                  unawaited(HapticFeedback.lightImpact());
                  setState(() => _sortBy = value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'date',
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: kSpacingSmall),
                        Text(strings.sortByDate),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'store',
                    child: Row(
                      children: [
                        const Icon(Icons.list_alt, size: 18),
                        const SizedBox(width: kSpacingSmall),
                        Text(strings.sortByList),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'amount',
                    child: Row(
                      children: [
                        const Icon(Icons.attach_money, size: 18),
                        const SizedBox(width: kSpacingSmall),
                        Text(strings.sortByAmount),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Consumer<ReceiptProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const AppLoadingSkeleton(
                  sectionCount: 4,
                  showHero: false,
                );
              }

              if (provider.hasError) {
                return _ErrorState(
                  message: provider.errorMessage ?? strings.defaultError,
                  onRetry: () => provider.retry(),
                );
              }

              final receipts = _filterAndSortReceipts(provider.receipts);

              if (provider.receipts.isEmpty) {
                return const _EmptyState();
              }

              // 🎬 הפעל אנימציה פעם אחת כשיש דאטא
              _triggerEntryAnimation();

              // 📊 סטטיסטיקות
              final totalItems = receipts.fold<int>(
                0,
                (sum, r) => sum + r.items.where((i) => i.isChecked).length,
              );
              final totalAmount = receipts.fold<double>(
                0,
                (sum, r) => sum + r.totalAmount,
              );
              final averageAmount =
                  receipts.isNotEmpty ? totalAmount / receipts.length : 0.0;

              return Column(
                children: [
                  // 🔍 סינון לפי תקופה
                  _staggered(
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingMedium,
                        vertical: kSpacingSmall,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilterChip(
                            label: Text(strings.filterThisMonth),
                            selected: _filterPeriod == 'month',
                            selectedColor:
                                cs.primary.withValues(alpha: 0.15),
                            checkmarkColor: cs.primary,
                            onSelected: (_) {
                              unawaited(HapticFeedback.lightImpact());
                              setState(() => _filterPeriod = 'month');
                            },
                          ),
                          const SizedBox(width: kSpacingSmall),
                          FilterChip(
                            label: Text(strings.filterThreeMonths),
                            selected: _filterPeriod == '3months',
                            selectedColor:
                                cs.primary.withValues(alpha: 0.15),
                            checkmarkColor: cs.primary,
                            onSelected: (_) {
                              unawaited(HapticFeedback.lightImpact());
                              setState(() => _filterPeriod = '3months');
                            },
                          ),
                          const SizedBox(width: kSpacingSmall),
                          FilterChip(
                            label: Text(strings.filterAll),
                            selected: _filterPeriod == 'all',
                            selectedColor:
                                cs.primary.withValues(alpha: 0.15),
                            checkmarkColor: cs.primary,
                            onSelected: (_) {
                              unawaited(HapticFeedback.lightImpact());
                              setState(() => _filterPeriod = 'all');
                            },
                          ),
                        ],
                      ),
                    ),
                    0,
                  ),

                  // 📊 סטטיסטיקות
                  _staggered(
                    Semantics(
                      label: '${strings.shoppingsLabel}: ${receipts.length}, '
                          '${strings.totalItemsLabel}: $totalItems, '
                          '${strings.totalLabel}: ₪${totalAmount.toStringAsFixed(0)}, '
                          '${strings.averageLabel}: ₪${averageAmount.toStringAsFixed(0)}',
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: kSpacingMedium,
                        ),
                        padding: const EdgeInsets.all(kSpacingMedium),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(kBorderRadiusLarge),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              icon: Icons.receipt_long,
                              label: strings.shoppingsLabel,
                              value: '${receipts.length}',
                              color: cs.onPrimaryContainer,
                            ),
                            _StatItem(
                              icon: Icons.shopping_bag,
                              label: strings.totalItemsLabel,
                              value: '$totalItems',
                              color: cs.onPrimaryContainer,
                            ),
                            _StatItem(
                              icon: Icons.payments_outlined,
                              label: strings.totalLabel,
                              value: '₪${totalAmount.toStringAsFixed(0)}',
                              color: cs.onPrimaryContainer,
                            ),
                            _StatItem(
                              icon: Icons.balance,
                              label: strings.averageLabel,
                              value: '₪${averageAmount.toStringAsFixed(0)}',
                              color: cs.onPrimaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ),
                    1,
                  ),

                  const SizedBox(height: kSpacingSmall),

                  // 📋 רשימת קבלות
                  Expanded(
                    child: receipts.isEmpty
                        ? _staggered(
                            Center(
                              child: Text(
                                strings.noResults,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                            2,
                          )
                        : _staggered(
                            RefreshIndicator(
                              onRefresh: () async {
                                unawaited(HapticFeedback.mediumImpact());
                                await context
                                    .read<ReceiptProvider>()
                                    .loadReceipts();
                              },
                              child: ListView.builder(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.all(kSpacingMedium),
                                itemCount: receipts.length,
                                itemBuilder: (context, index) {
                                  final receipt = receipts[index];
                                  final clampedDelay =
                                      (50 * index).clamp(0, 500);
                                  return RepaintBoundary(
                                    child: _ReceiptTile(
                                      receipt: receipt,
                                      initiallyExpanded: receipt.id ==
                                          widget.initialReceiptId,
                                    )
                                        .animate()
                                        .fadeIn(
                                          duration: 250.ms,
                                          delay: clampedDelay.ms,
                                        )
                                        .slideY(
                                          begin: 0.15,
                                          end: 0.0,
                                          duration: 250.ms,
                                          delay: clampedDelay.ms,
                                          curve: Curves.easeOut,
                                        ),
                                  );
                                },
                              ),
                            ),
                            2,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// סינון ומיון קבלות
  List<Receipt> _filterAndSortReceipts(List<Receipt> receipts) {
    var filtered = receipts.toList();

    // סינון לפי תקופה (לפי חודש קלנדרי, לא חלון נע)
    final now = DateTime.now();
    switch (_filterPeriod) {
      case 'month':
        final firstOfMonth = DateTime(now.year, now.month, 1);
        filtered =
            filtered.where((r) => !r.date.isBefore(firstOfMonth)).toList();
        break;
      case '3months':
        // בטוח גם בינואר/פברואר — Dart מנרמל חודשים שליליים
        final threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
        filtered =
            filtered.where((r) => !r.date.isBefore(threeMonthsAgo)).toList();
        break;
      case 'all':
        break;
    }

    // מיון
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'store':
        filtered.sort((a, b) => a.storeName.compareTo(b.storeName));
        break;
      case 'amount':
        filtered.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
    }

    return filtered;
  }
}

// ========================================
// Widget: כרטיס קבלה מתרחב
// ========================================

class _ReceiptTile extends StatelessWidget {
  final Receipt receipt;
  final bool initiallyExpanded;

  const _ReceiptTile({required this.receipt, this.initiallyExpanded = false});

  /// Format quantity to avoid "1.0" display
  String _formatQuantity(num quantity) {
    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    }
    return quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.shoppingHistory;
    final locale = Localizations.localeOf(context).languageCode;
    final successColor = theme.extension<AppBrand>()?.success ?? cs.primary;

    final leadingColor = receipt.isVirtual ? successColor : cs.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Card(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          side: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: leadingColor,
          collapsedIconColor: leadingColor,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: kSpacingMedium,
            vertical: kSpacingSmall,
          ),
          childrenPadding: const EdgeInsets.only(
            left: kSpacingMedium,
            right: kSpacingMedium,
            bottom: kSpacingMedium,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: receipt.isVirtual
                  ? successColor.withValues(alpha: 0.2)
                  : cs.primaryContainer,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Icon(
              receipt.isVirtual ? Icons.shopping_cart : Icons.receipt,
              color: receipt.isVirtual ? successColor : cs.primary,
            ),
          ),
          title: Text(
            receipt.storeName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: kFontSizeMedium,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyyy  HH:mm', locale).format(receipt.date),
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: cs.onSurfaceVariant,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              // ✅ FIX: theme-aware color instead of kStickyGreen
              color: successColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Text(
              strings.itemsCount(
                receipt.items.where((i) => i.isChecked).length,
              ),
              style: TextStyle(
                fontSize: kFontSizeSmall,
                fontWeight: FontWeight.w600,
                // ✅ FIX: theme-aware color instead of kStickyGreen
                color: successColor,
              ),
            ),
          ),
          // רשימת פריטים בהרחבה
          children: [
            const Divider(height: 1),
            const SizedBox(height: kSpacingSmall),
            if (receipt.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Text(
                  AppStrings.receiptDetails.noItemsMessage,
                  style: TextStyle(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...receipt.items.map(
                (item) => _buildItemRow(context, item, cs, successColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    ReceiptItem item,
    ColorScheme cs,
    Color successColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Row(
        children: [
          // Checkbox indicator
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: item.isChecked
                  ? successColor
                  : cs.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: item.isChecked
                ? Icon(Icons.check, color: cs.onPrimary, size: 14)
                : null,
          ),
          const SizedBox(width: kSpacingSmall),
          // כמות
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Text(
              '×${_formatQuantity(item.quantity)}',
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: kFontSizeSmall,
              ),
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          // שם פריט
          Expanded(
            child: Text(
              item.name ?? '?',
              style: TextStyle(
                decoration:
                    item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked
                    ? cs.onSurface.withValues(alpha: 0.5)
                    : cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // מחיר
          Text(
            '₪${item.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: cs.primary,
              fontSize: kFontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: סטטיסטיקה
// ========================================

class _StatItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void didUpdateWidget(_StatItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
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

    // Extract numeric value for animation
    final numericStr = widget.value.replaceAll(RegExp(r'[^\d.]'), '');
    final targetNum = double.tryParse(numericStr) ?? 0;
    final prefix = widget.value.contains('₪') ? '₪' : '';

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: widget.color, size: 20),
            const SizedBox(width: 4),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final current = (targetNum * _animation.value);
                final display = targetNum == targetNum.toInt().toDouble()
                    ? '$prefix${current.toInt()}'
                    : '$prefix${current.toStringAsFixed(0)}';
                return Text(
                  display,
                  style: TextStyle(
                    fontSize: kFontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                );
              },
            ),
          ],
        ),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: kFontSizeSmall,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: Empty State (אנימטיבי + CTA)
// ========================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.shoppingHistory;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // תמונה עם אנימציית נשימה עדינה
            ClipOval(
              child: Image.asset(
                'assets/images/empty_history.webp',
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0,
                  end: 1.05,
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: kSpacingLarge),
            Text(
              strings.emptyTitle,
              style: TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              strings.emptySubtitle,
              style: TextStyle(
                fontSize: kFontSizeBody,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            // 🎯 CTA — כפתור יצירת רשימה ראשונה
            FilledButton.icon(
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                Navigator.pushNamed(context, '/create-list');
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(AppStrings.homeDashboard.newListButton),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

// ========================================
// Widget: Error State
// ========================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.shoppingHistory;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: cs.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              message,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingMedium),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(strings.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
