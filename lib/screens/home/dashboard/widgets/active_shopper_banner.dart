// lib/screens/home/dashboard/widgets/active_shopper_banner.dart — Active shopper banner — green bar showing current shopping session with continue button

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/status_colors.dart';
import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/shopping_list.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../../theme/app_theme.dart';

// Banner appearance — kept here so the my/others variants share tuning.
const double _kGradientEndAlpha = 0.85;
const double _kBannerShadowAlpha = 0.3;
const double _kSubtleOnPrimaryAlpha = 0.9;
const double _kIconButtonAlpha = 0.8;
const double _kBannerShadowBlur = 8.0;
const Offset _kBannerShadowOffset = Offset(0, 2);

// Pulsing-cart icon. The compact variant gets a smaller box + smaller
// icon so it fits the single-line "my active" pill.
const double _kPulsingIconRegularSize = 40.0;
const double _kPulsingIconBgAlpha = 0.2;
const Duration _kPulsingDuration = Duration(milliseconds: 1500);
const double _kPulsingMinScale = 0.95;
const double _kPulsingMaxScale = 1.05;

// Switcher / entry animations.
const Duration _kSwitcherDuration = Duration(milliseconds: 400);
const Duration _kEnterDuration = Duration(milliseconds: 300);
const double _kEnterSlideOffset = -0.2;

/// Compact vs regular sizing for [_PulsingIcon] — replaces the previous
/// `size >= 40` heuristic with an explicit choice.
enum _PulsingIconSize { regular, compact }

/// באנר קניות פעילות - מציג:
/// 1. כשהמשתמש הנוכחי יש לו קנייה פעילה (עדיפות גבוהה)
/// 2. כשמישהו אחר קונה מרשימה משותפת
class ActiveShopperBanner extends StatelessWidget {
  const ActiveShopperBanner({super.key});

  /// Single pass — find the user's own active shopping first; only fall
  /// back to "others" if there is no personal session in flight.
  ({ShoppingList? mine, ShoppingList? others}) _scan(
    List<ShoppingList> lists,
    String? currentUserId,
  ) {
    ShoppingList? others;
    for (final list in lists) {
      if (!list.isBeingShopped) continue;
      final activeShoppers = list.activeShoppers.where((s) => s.isActive);
      final isMineHere = activeShoppers.any((s) => s.userId == currentUserId);
      if (isMineHere) {
        // Mine wins — stop scanning.
        return (mine: list, others: null);
      }
      others ??= list;
    }
    return (mine: null, others: others);
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ShoppingListsProvider>();
    final currentUserId = context.select<UserContext, String?>((u) => u.userId);

    final result = _scan(listsProvider.lists, currentUserId);

    // 1. עדיפות גבוהה: קנייה פעילה של המשתמש
    if (result.mine != null) {
      return AnimatedSwitcher(
        duration: _kSwitcherDuration,
        child: _MyActiveShoppingBanner(
          key: const ValueKey('my_active'),
          list: result.mine!,
        )
            .animate()
            .fadeIn(duration: _kEnterDuration)
            .slideY(begin: _kEnterSlideOffset, end: 0.0, curve: Curves.easeOut),
      );
    }

    // 2. קנייה פעילה של אחרים
    final othersList = result.others;
    if (othersList == null) {
      return const AnimatedSwitcher(
        duration: _kSwitcherDuration,
        child: SizedBox.shrink(key: ValueKey('none')),
      );
    }

    final activeShoppers =
        othersList.activeShoppers.where((s) => s.isActive).toList();
    final shopperCount = activeShoppers.length;

    // Resolve first shopper name from sharedUsers (may be null when the
    // shopper isn't in the local sharedUsers cache yet).
    final firstShopperName = activeShoppers.isEmpty
        ? null
        : othersList.sharedUsers[activeShoppers.first.userId]?.userName;

    // Hide the "Join" CTA from viewers — they can't accept shopping
    // invites anyway, so the snack-bar-after-tap was pure friction.
    final canJoin = currentUserId == null
        ? false
        : (othersList.getUserRole(currentUserId)?.canShop ?? false);

    return AnimatedSwitcher(
      duration: _kSwitcherDuration,
      child: _OthersShoppingBanner(
        key: const ValueKey('others_active'),
        list: othersList,
        shopperCount: shopperCount,
        firstShopperName: firstShopperName,
        canJoin: canJoin,
      )
          .animate()
          .fadeIn(duration: _kEnterDuration)
          .slideY(begin: _kEnterSlideOffset, end: 0.0, curve: Curves.easeOut),
    );
  }
}

/// באנר: יש לך קנייה פעילה - להמשיך?
///
/// Compact single-line pill (~50px tall). Displays:
///   🛒  "שם הרשימה · N פריטים"                  ➜
/// The generic "you have active shopping" title is omitted on purpose —
/// the green accent background + cart icon already convey that state,
/// and the list name is what the user actually needs to recognize it.
class _MyActiveShoppingBanner extends StatelessWidget {
  final ShoppingList list;

  const _MyActiveShoppingBanner({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.activeShopperBanner;
    // Theme-aware accent color (replaces hardcoded blue)
    final accentColor = theme.extension<AppBrand>()?.accent ?? cs.primary;
    final uncheckedCount = list.items.where((i) => !i.isChecked).length;
    // All items checked but session not finished — switch the CTA from
    // "Continue" to "Finish" so the user has a clear next step instead of
    // a stale "0 items remaining · Continue".
    final isDone = uncheckedCount == 0;
    final mainText = isDone
        ? strings.myActiveCompactDone(list.name)
        : strings.myActiveCompact(list.name, uncheckedCount);
    final ctaText = isDone ? strings.finishButton : strings.continueButton;
    final ctaIcon = isDone ? Icons.check_circle : Icons.play_arrow;
    final radius = BorderRadius.circular(kBorderRadiusLarge);

    return Semantics(
      button: true,
      label: '$mainText, $ctaText',
      child: Container(
        margin: const EdgeInsets.only(bottom: kSpacingSmall),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor,
              accentColor.withValues(alpha: _kGradientEndAlpha),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: _kBannerShadowAlpha),
              blurRadius: _kBannerShadowBlur,
              offset: _kBannerShadowOffset,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _onContinue(context),
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmallPlus,
                vertical: kSpacingSmall,
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: _PulsingIcon(
                      backgroundColor: cs.onPrimary,
                      variant: _PulsingIconSize.compact,
                    ),
                  ),
                  const SizedBox(width: kSpacingSmallPlus),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        mainText,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  // Trailing CTA affordance — visual only; the whole
                  // banner is the actual tap target.
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingSmallPlus,
                        vertical: kSpacingTiny,
                      ),
                      decoration: BoxDecoration(
                        color: cs.onPrimary,
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ctaText,
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: kFontSizeSmall,
                            ),
                          ),
                          const SizedBox(width: kSpacingXTiny),
                          Icon(
                            ctaIcon,
                            size: kIconSizeSmall,
                            color: accentColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue(BuildContext context) {
    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(context, '/active-shopping', arguments: list);
  }
}

/// באנר: מישהו אחר קונה מרשימה משותפת
class _OthersShoppingBanner extends StatelessWidget {
  final ShoppingList list;
  final int shopperCount;
  final String? firstShopperName;
  final bool canJoin;

  const _OthersShoppingBanner({
    super.key,
    required this.list,
    required this.shopperCount,
    required this.canJoin,
    this.firstShopperName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.activeShopperBanner;
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;
    final radius = BorderRadius.circular(kBorderRadius);

    // Title: prefer the resolved shopper name; fall back to a generic
    // "מישהו" rather than accidentally displaying the list name as a
    // person's name (the previous `firstShopperName ?? list.name` bug).
    final title = shopperCount == 1
        ? (firstShopperName != null
            ? strings.othersActiveTitle(firstShopperName!)
            : strings.someoneShopping)
        : strings.othersActiveTitleMultiple(shopperCount);
    final subtitle = shopperCount == 1
        ? strings.othersActiveSingle(list.name)
        : strings.othersActiveMultiple(shopperCount, list.name);

    return Semantics(
      // explicitChildNodes so the join/view buttons stay separate
      // accessibility nodes.
      explicitChildNodes: true,
      label: '$title, $subtitle',
      child: Container(
        margin: const EdgeInsets.only(bottom: kSpacingSmall),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              successColor.withValues(alpha: _kSubtleOnPrimaryAlpha),
              successColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: successColor.withValues(alpha: _kBannerShadowAlpha),
              blurRadius: _kBannerShadowBlur,
              offset: _kBannerShadowOffset,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            // Tap on empty area = view (the Join CTA is a button of
            // its own; "view" is the safer fall-through for ambiguous taps).
            onTap: () => _onViewList(context),
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: _PulsingIcon(
                      backgroundColor: cs.onPrimary,
                      variant: _PulsingIconSize.regular,
                    ),
                  ),
                  const SizedBox(width: kSpacingMedium),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: kSpacingXTiny / 2),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onPrimary
                                  .withValues(alpha: _kSubtleOnPrimaryAlpha),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show "Join" only to roles that can actually shop.
                      // Viewers fall through to the eye-icon "view" button.
                      if (canJoin) ...[
                        _ActionButton(
                          label: strings.joinButton,
                          icon: Icons.group_add,
                          onPressed: () => _onJoin(context),
                          backgroundColor: cs.onPrimary,
                          foregroundColor: successColor,
                        ),
                        const SizedBox(width: kSpacingSmall),
                      ],
                      IconButton(
                        onPressed: () => _onViewList(context),
                        icon: const Icon(Icons.visibility_outlined),
                        color: cs.onPrimary
                            .withValues(alpha: _kIconButtonAlpha),
                        tooltip: strings.viewListTooltip,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onJoin(BuildContext context) {
    // Defense in depth — the parent already hides the button when
    // canJoin is false, but if a screen reader / future caller bypasses
    // that, we still refuse and surface a friendly error.
    final userId = context.read<UserContext>().userId;
    if (userId != null) {
      final userRole = list.getUserRole(userId);
      if (userRole != null && !userRole.canShop) {
        final messenger = ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppStrings.shopping.viewerCannotShop),
            backgroundColor:
                StatusColors.getColor(StatusType.pending, context),
          ),
        );
        return;
      }
    }

    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(context, '/active-shopping', arguments: list);
  }

  void _onViewList(BuildContext context) {
    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(
      context,
      '/active-shopping',
      arguments: {'list': list, 'readOnly': true},
    );
  }
}

/// כפתור פעולה קטן
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: kIconSizeSmall),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingSmallPlus,
          vertical: kSpacingSmall,
        ),
        minimumSize: Size.zero,
        textStyle: const TextStyle(
          fontSize: kFontSizeSmall,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// אייקון פועם - מבוסס flutter_animate.
class _PulsingIcon extends StatelessWidget {
  final Color backgroundColor;
  final _PulsingIconSize variant;

  const _PulsingIcon({
    required this.backgroundColor,
    this.variant = _PulsingIconSize.regular,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = variant == _PulsingIconSize.compact;
    final boxSize = isCompact ? kSpacingXLarge : _kPulsingIconRegularSize;
    final iconSize = isCompact ? kIconSizeSmallPlus : kIconSizeMedium;

    return Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: _kPulsingIconBgAlpha),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Icon(
            Icons.shopping_cart,
            color: backgroundColor,
            size: iconSize,
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: _kPulsingMinScale,
          end: _kPulsingMaxScale,
          duration: _kPulsingDuration,
          curve: Curves.easeInOut,
        );
  }
}
