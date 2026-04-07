// 📄 lib/screens/history/shopping_history_screen.dart
//
// מסך היסטוריית קניות - צפייה בקבלות קודמות.
// כולל סינון וסטטיסטיקות הוצאות.
// שילוב: רקע מחברת + Glass AppBar + אנימציות מדורגות
//
// ✅ Features:
//    - Glass blur AppBar
//    - אנימציות כניסה מדורגות (AnimationController + Interval, פעם ראשונה בלבד)
//    - סטטיסטיקות 2×2: קניות, פריטים, סה"כ, ממוצע
//    - כרטיסי קבלות עם סכום + progress bar
//    - Empty state אנימטיבי עם CTA
//    - Haptic feedback ב-refresh וסינון
//    - נגישות משופרת
//
// Version: 5.1 (18/03/2026)
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
import '../../models/activity_event.dart';
import '../../models/receipt.dart';
import '../../providers/activity_log_provider.dart';
import '../../providers/receipt_provider.dart';
import '../../providers/user_context.dart';
import '../../services/household_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_error_state.dart';
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
    with TickerProviderStateMixin {
  String _filterPeriod = 'month'; // month, 3months, all

  /// שמות חברי הבית — לתצוגת "מי קנה"
  Map<String, String> _memberNames = {};
  bool _membersLoaded = false;

  /// Tab controller — קבלות | יומן פעילות
  late final TabController _tabController;

  /// אנימציות מדורגות — רצות רק בפעם הראשונה (כמו בהגדרות)
  late final AnimationController _animController;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 3; // filters, stats, list

  /// דגל — אנימציה כבר רצה?
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_membersLoaded) {
      _membersLoaded = true;
      _loadMemberNames();
    }
  }

  Future<void> _loadMemberNames() async {
    final householdId = context.read<UserContext>().user?.householdId;
    if (householdId == null || householdId.isEmpty) return;

    try {
      final names = await HouseholdService().getMemberNames(householdId);
      if (!mounted) return;
      setState(() => _memberNames = names);
    } catch (_) {
      // Silent fail — שמות לא קריטיים
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    final activityStrings = AppStrings.activityLog;

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
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: activityStrings.receiptsTab),
                Tab(text: activityStrings.tabTitle),
              ],
              indicatorColor: cs.primary,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // === Tab 1: Receipts ===
              _buildReceiptsTab(cs, strings),
              // === Tab 2: Activity Log ===
              _buildActivityTab(cs, activityStrings),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTab(ColorScheme cs, ActivityLogStrings strings) {
    return Consumer<ActivityLogProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const AppLoadingSkeleton(
            sectionCount: 4,
            showHero: false,
          );
        }

        if (provider.hasError) {
          return AppErrorState(
            message: strings.defaultError,
            onAction: () => provider.retry(),
            actionLabel: strings.retryButton,
          );
        }

        if (provider.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kSpacingXLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: kIconSizeXLarge,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: kSpacingMedium),
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
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            unawaited(HapticFeedback.mediumImpact());
            await provider.loadEvents();
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(kSpacingMedium),
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              final event = provider.events[index];
              return _ActivityEventTile(event: event);
            },
          ),
        );
      },
    );
  }

  Widget _buildReceiptsTab(ColorScheme cs, ShoppingHistoryStrings strings) {
    return Consumer<ReceiptProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const AppLoadingSkeleton(
                  sectionCount: 4,
                  showHero: false,
                );
              }

              if (provider.hasError) {
                return AppErrorState(
                  message: provider.errorMessage ?? strings.defaultError,
                  onAction: () => provider.retry(),
                  actionLabel: strings.retryButton,
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

                  // 📊 סטטיסטיקות — Grid 2×2
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSpacingMedium,
                          vertical: kSpacingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(kBorderRadiusLarge),
                        ),
                        child: Column(
                          children: [
                            // שורה עליונה: קניות | פריטים (כללי → פירוט)
                            Row(
                              children: [
                                Expanded(
                                  child: _StatItem(
                                    icon: Icons.receipt_long,
                                    label: strings.shoppingsLabel,
                                    value: '${receipts.length}',
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                                _buildStatDivider(cs),
                                Expanded(
                                  child: _StatItem(
                                    icon: Icons.shopping_bag,
                                    label: strings.totalItemsLabel,
                                    value: '$totalItems',
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: cs.onPrimaryContainer.withValues(alpha: 0.15),
                              height: kSpacingSmall,
                            ),
                            // שורה תחתונה: סה"כ | ממוצע (גדול → ממוצע)
                            Row(
                              children: [
                                Expanded(
                                  child: _StatItem(
                                    icon: Icons.payments_outlined,
                                    label: strings.totalLabel,
                                    value: '₪${totalAmount.toStringAsFixed(0)}',
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                                _buildStatDivider(cs),
                                Expanded(
                                  child: _StatItem(
                                    icon: Icons.balance,
                                    label: strings.averageLabel,
                                    value: '₪${averageAmount.toStringAsFixed(0)}',
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ],
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
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: kIconSizeXLarge,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(height: kSpacingSmall),
                                Text(
                                  strings.noResults,
                                  style: TextStyle(
                                    fontSize: kFontSizeBody,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: kSpacingXTiny),
                                Text(
                                  strings.noResultsSubtitle,
                                  style: TextStyle(
                                    fontSize: kFontSizeSmall,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
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
                                      memberNames: _memberNames,
                                      currentUserId: context.read<UserContext>().user?.id,
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
    );
  }

  /// קו מפריד אנכי בין סטטיסטיקות
  Widget _buildStatDivider(ColorScheme cs) {
    return Container(
      width: 1,
      height: kSpacingXLarge,
      color: cs.onPrimaryContainer.withValues(alpha: 0.15),
    );
  }

  /// סינון ומיון קבלות (מיון ברירת מחדל: חדש קודם)
  List<Receipt> _filterAndSortReceipts(List<Receipt> receipts) {
    var filtered = receipts.toList();

    // סינון לפי תקופה
    final now = DateTime.now();
    switch (_filterPeriod) {
      case 'month':
        final firstOfMonth = DateTime(now.year, now.month, 1);
        filtered =
            filtered.where((r) => !r.date.isBefore(firstOfMonth)).toList();
        break;
      case '3months':
        final threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
        filtered =
            filtered.where((r) => !r.date.isBefore(threeMonthsAgo)).toList();
        break;
      case 'all':
        break;
    }

    // מיון ברירת מחדל: חדש קודם
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }
}

// ========================================
// Widget: כרטיס קבלה מתרחב
// ========================================

class _ReceiptTile extends StatelessWidget {
  final Receipt receipt;
  final bool initiallyExpanded;
  final Map<String, String> memberNames;
  final String? currentUserId;

  const _ReceiptTile({
    required this.receipt,
    this.initiallyExpanded = false,
    this.memberNames = const {},
    this.currentUserId,
  });

  /// אוסף שמות קונים ייחודיים (createdBy + כל checkedBy)
  List<String> get _shopperNames {
    if (memberNames.isEmpty) return [];

    final uids = <String>{};
    if (receipt.createdBy != null) uids.add(receipt.createdBy!);
    for (final item in receipt.items) {
      if (item.checkedBy != null) uids.add(item.checkedBy!);
    }

    // סנן רק מי שיש לו שם ידוע
    return uids
        .where((uid) => memberNames.containsKey(uid))
        .map((uid) => memberNames[uid]!)
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// בונה אווטארים קטנים (עיגולי אותיות ראשונות) של הקונים
  List<Widget> _buildShopperAvatars(ColorScheme cs) {
    final names = _shopperNames;
    return names.take(3).map((name) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: kSpacingXTiny),
        child: Container(
          width: kIconSizeSmallPlus,
          height: kIconSizeSmallPlus,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            name[0],
            style: TextStyle(
              fontSize: kFontSizeTiny,
              fontWeight: FontWeight.bold,
              color: cs.onSecondaryContainer,
            ),
          ),
        ),
      );
    }).toList();
  }

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

    final checkedCount = receipt.items.where((i) => i.isChecked).length;

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
            padding: const EdgeInsets.all(kSpacingSmallPlus),
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kSpacingXTiny),
              // תאריך + מי קנה
              Row(
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy  HH:mm', locale)
                        .format(receipt.date),
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (_shopperNames.isNotEmpty) ...[
                    const SizedBox(width: kSpacingSmall),
                    ..._buildShopperAvatars(cs),
                  ],
                ],
              ),
              const SizedBox(height: kSpacingXTiny),
              // 💰 סכום הקנייה — שורה נפרדת ובולטת
              Text(
                '₪${receipt.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: kFontSizeBody,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingXTiny),
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Text(
              strings.itemsCount(checkedCount),
              style: TextStyle(
                fontSize: kFontSizeSmall,
                fontWeight: FontWeight.w600,
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
            width: kIconSizeSmallPlus,
            height: kIconSizeSmallPlus,
            decoration: BoxDecoration(
              color: item.isChecked
                  ? successColor
                  : cs.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: item.isChecked
                ? Icon(Icons.check, color: cs.onPrimary, size: kIconSizeSmall)
                : null,
          ),
          const SizedBox(width: kSpacingSmall),
          // כמות
          Container(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXTiny),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: kIconSizeSmallPlus),
              const SizedBox(width: kSpacingXTiny),
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
          const SizedBox(height: kSpacingXTiny),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: Activity Event Tile
// ========================================

class _ActivityEventTile extends StatelessWidget {
  final ActivityEvent event;

  const _ActivityEventTile({required this.event});

  IconData _iconForType(ActivityType type) {
    switch (type) {
      case ActivityType.shoppingCompleted:
        return Icons.check_circle;
      case ActivityType.shoppingStarted:
        return Icons.shopping_cart;
      case ActivityType.shoppingJoined:
        return Icons.group_add;
      case ActivityType.listCreated:
        return Icons.playlist_add;
      case ActivityType.itemAdded:
        return Icons.add_circle_outline;
      case ActivityType.stockUpdated:
        return Icons.inventory_2;
      case ActivityType.memberLeft:
        return Icons.person_remove;
      case ActivityType.roleChanged:
        return Icons.admin_panel_settings;
      case ActivityType.unknown:
        return Icons.info_outline;
    }
  }

  String _descriptionForEvent(ActivityLogStrings strings) {
    final actor = event.actorName.isNotEmpty ? event.actorName : '?';
    switch (event.type) {
      case ActivityType.shoppingCompleted:
        return strings.shoppingCompleted(actor, event.listName ?? '');
      case ActivityType.shoppingStarted:
        return strings.shoppingStarted(actor, event.listName ?? '');
      case ActivityType.shoppingJoined:
        return strings.shoppingJoined(actor, event.listName ?? '');
      case ActivityType.listCreated:
        return strings.listCreated(actor, event.listName ?? '');
      case ActivityType.itemAdded:
        return strings.itemAdded(actor, event.itemName ?? '', event.listName ?? '');
      case ActivityType.stockUpdated:
        return strings.stockUpdated(actor, event.productName ?? '');
      case ActivityType.memberLeft:
        return strings.memberLeft(actor);
      case ActivityType.roleChanged:
        return strings.roleChanged(actor, event.targetName ?? '', event.newRole ?? '');
      case ActivityType.unknown:
        return strings.unknownActivity(actor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.activityLog;
    final locale = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circle with icon
          Container(
            width: kIconSizeLarge,
            height: kIconSizeLarge,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              _iconForType(event.type),
              size: kIconSizeSmallPlus,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: kSpacingSmallPlus),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _descriptionForEvent(strings),
                  style: TextStyle(
                    fontSize: kFontSizeBody,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: kSpacingXTiny),
                Text(
                  DateFormat('dd/MM  HH:mm', locale).format(event.createdAt),
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

