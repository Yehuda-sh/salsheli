// lib/screens/home/dashboard/widgets/action_center_card.dart — Action center — compact inline status row: pin icon + tappable segments separated by middots

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/shopping_list.dart';
import '../../../../providers/inventory_provider.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../../theme/app_theme.dart';
import '../../../pantry/my_pantry_screen.dart' show MyPantryScreen, PantryStockFilter;

/// Action Center — single-line "notebook status strip" of things needing
/// attention. Pin icon at the start, then bold colored count + short label
/// per category, separated by middots. Each segment is independently
/// tappable; the whole strip occupies one line on standard screen widths.
///
/// Categories: out-of-stock (red), overdue lists (orange), pending join
/// requests (yellow). Tapping a segment opens a bottom sheet OR — for the
/// out-of-stock segment — switches to the pantry tab with the filter pre-applied.
class ActionCenterCard extends StatelessWidget {
  final void Function(ShoppingList list)? onNavigateToList;
  final VoidCallback? onNavigateToPantry;

  const ActionCenterCard({
    super.key,
    this.onNavigateToList,
    this.onNavigateToPantry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final isLoggedIn = context.select<UserContext, bool>((u) => u.isLoggedIn);
    final listsProvider = context.watch<ShoppingListsProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    if (!isLoggedIn) return const SizedBox.shrink();

    // Single pass over the lists: bucket overdue, collect pending lists,
    // and tally total pending requests — all in one loop.
    final pendingLists = <ShoppingList>[];
    final overdueLists = <ShoppingList>[];
    var pendingCount = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final list in listsProvider.lists) {
      if (list.status != ShoppingList.statusActive) continue;

      if (list.canCurrentUserApprove) {
        final pending =
            list.pendingRequests.where((r) => r.status.isPending).length;
        if (pending > 0) {
          pendingLists.add(list);
          pendingCount += pending;
        }
      }

      final target = list.targetDate;
      if (target != null) {
        final tLocal = target.toLocal();
        final tDay = DateTime(tLocal.year, tLocal.month, tLocal.day);
        if (today.isAfter(tDay)) overdueLists.add(list);
      }
    }

    final criticalCount =
        inventoryProvider.items.where((i) => i.quantity <= 0).length;

    // Hide the whole bar when there's nothing to action.
    if (pendingCount == 0 && overdueLists.isEmpty && criticalCount == 0) {
      return const SizedBox.shrink();
    }

    final strings = AppStrings.actionCenter;
    // Colors must be foreground-visible on white now that the highlighter
    // band behind the digits was removed. The sticky-note palette is
    // optimized for *backgrounds*; sticky-yellow as a foreground icon on
    // light surface is essentially invisible. Each color here is a theme
    // accent that carries enough chroma to render as a foreground:
    //  - critical → cs.error            (red, urgent)
    //  - overdue  → brand.warning       (deep orange — Orange 700)
    //  - pending  → brand.notebookBlue  (the literal color of the
    //                                    notebook ruling lines that already
    //                                    fill the app background — reusing
    //                                    it as a foreground for "social"
    //                                    items is maximally on-brand)
    final criticalColor = cs.error;
    final overdueColor = brand?.warning ?? cs.tertiary;
    final pendingColor = brand?.notebookBlue ?? kNotebookBlue;

    // Build interleaved segments + middot separators. The pin icon at the
    // very start anchors the row visually ("pinned for you") and ties it to
    // the notebook design language without competing with the segments.
    //
    // Per-segment icons restore semantic context that the short labels
    // ("נגמר"/"באיחור"/"ממתינות") alone don't carry — a new user shouldn't
    // need to guess whether "נגמר" refers to a product, a battery, or a
    // coupon. Iconography does the disambiguation in <14px.
    final segments = <Widget>[];
    if (criticalCount > 0) {
      segments.add(_StatusSegment(
        icon: Icons.inventory_2_outlined,
        count: criticalCount,
        label: strings.criticalShort(criticalCount),
        color: criticalColor,
        onTap: _openCriticalStock,
      ));
    }
    if (overdueLists.isNotEmpty) {
      if (segments.isNotEmpty) segments.add(const _DotSeparator());
      segments.add(_StatusSegment(
        icon: Icons.event_busy,
        count: overdueLists.length,
        label: strings.overdueShort,
        color: overdueColor,
        onTap: () => _openListsAction(
          context: context,
          lists: overdueLists,
          title: strings.overdueListsCount(overdueLists.length),
          icon: Icons.event_busy,
        ),
      ));
    }
    if (pendingCount > 0) {
      if (segments.isNotEmpty) segments.add(const _DotSeparator());
      segments.add(_StatusSegment(
        icon: Icons.person_add_alt_1_outlined,
        count: pendingCount,
        label: strings.pendingShort(pendingCount),
        color: pendingColor,
        onTap: () => _openListsAction(
          context: context,
          lists: pendingLists,
          title: strings.pendingRequests(pendingCount),
          icon: Icons.pending_actions,
        ),
      ));
    }

    return Padding(
      // Top padding gives breathing room from the invite banner above;
      // without it the row glues to the banner and reads as one block.
      padding: const EdgeInsets.only(
        top: kSpacingXTiny,
        bottom: kSpacingSmall,
      ),
      // Wrap (not Row) is the safety net for unusually narrow screens or
      // very large counts — on 360dp+ all segments fit one line.
      // The pin icon was removed in this iteration: with three colored
      // category icons (📦/📅/👤) already anchoring the row, an extra pin
      // was redundant decoration competing for the same role.
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: kSpacingXTiny,
        children: segments,
      ),
    );
  }

  /// Out-of-stock chip → switch to the pantry tab with the matching
  /// filter pre-applied. The pantry consumes the static intent on its
  /// next build, so order matters: set the filter, THEN switch tabs.
  void _openCriticalStock() {
    unawaited(HapticFeedback.lightImpact());
    MyPantryScreen.pendingStockFilter = PantryStockFilter.outOfStock;
    onNavigateToPantry?.call();
  }

  /// Shared handler for overdue + pending chips. Fast-path single list to
  /// jump straight into it; otherwise open the picker sheet.
  void _openListsAction({
    required BuildContext context,
    required List<ShoppingList> lists,
    required String title,
    required IconData icon,
  }) {
    unawaited(HapticFeedback.lightImpact());
    if (lists.length == 1) {
      onNavigateToList?.call(lists.first);
      return;
    }
    _showListsSheet(
      context: context,
      title: title,
      icon: icon,
      lists: lists,
    );
  }

  void _showListsSheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<ShoppingList> lists,
  }) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) {
        // Background colour and rounded-top shape come from the global
        // bottomSheetTheme — passing them explicitly here would only
        // override the theme to an inconsistent cs.surface tone.
        final cs = Theme.of(sheetCtx).colorScheme;
        // Trailing chevron flips with locale: chevron_left is "forward"
        // in Hebrew RTL, but reads as "back" in English LTR.
        final isRtl = Directionality.of(sheetCtx) == TextDirection.rtl;
        final forwardChevron =
            isRtl ? Icons.chevron_left : Icons.chevron_right;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: kSpacingSmall),
              // Drag handle
              Container(
                width: kSpacingXLarge,
                height: kSpacingXTiny,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
              ),
              const SizedBox(height: kSpacingMedium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                child: Row(
                  children: [
                    Icon(icon, color: cs.primary, size: kIconSizeMedium),
                    const SizedBox(width: kSpacingSmall),
                    Text(
                      title,
                      style: Theme.of(sheetCtx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kSpacingSmall),
              ...lists.map((list) => ListTile(
                    leading: Icon(Icons.shopping_bag_outlined, color: cs.primary),
                    title: Text(list.name),
                    trailing: Icon(forwardChevron),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      onNavigateToList?.call(list);
                    },
                  )),
              const SizedBox(height: kSpacingSmall),
            ],
          ),
        );
      },
    );
  }
}

/// One inline segment: icon + bold count + space + short label.
/// Independently tappable.
///
/// The icon is the sole color carrier — the digit and label render in
/// onSurface for readability. Earlier iterations painted a highlighter
/// band behind the digit; with three distinct theme accent colors on the
/// icons, the highlighter became redundant visual noise.
class _StatusSegment extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatusSegment({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '$count $label',
      // The InkWell's vertical padding is intentionally larger than the
      // visible content height: it expands the hit area toward 36-40dp
      // without growing the rendered text, mitigating the sub-44dp tap
      // target without breaking the compact one-line look.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingXTiny,
            vertical: kSpacingSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(icon, size: kIconSizeSmallPlus, color: color),
              ),
              const SizedBox(width: kSpacingXTiny),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: kFontSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: kSpacingXTiny),
              Text(
                label,
                style: TextStyle(
                  fontSize: kFontSizeMedium,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative middot "·" between segments. Excluded from semantics so
/// screen readers hear "1 out, 2 overdue, 4 pending" without dot noise.
class _DotSeparator extends StatelessWidget {
  const _DotSeparator();

  @override
  Widget build(BuildContext context) {
    // Match the segment digit font size so the middot sits on the same
    // visual baseline.
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
        child: Text(
          '·',
          style: TextStyle(
            fontSize: kFontSizeMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
