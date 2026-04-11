// 📄 lib/screens/home/dashboard/widgets/active_shopper_banner.dart
//
// באנר קניות פעילות - מוצג ב-2 מקרים:
// 1. המשתמש הנוכחי יש לו קנייה פעילה → "להמשיך קנייה?"
// 2. מישהו אחר קונה מרשימה משותפת → "קניות מתבצעות!"
//
// ✅ Features:
//    - אנימציית כניסה לבאנר (flutter_animate)
//    - מעבר חלק בין מצבי באנר (AnimatedSwitcher)
//    - קוד נקי עם אנימציות חכמות ללא Boilerplate
//
// Version: 3.2 (22/02/2026)
// 🔗 Related: ShoppingList, ActiveShopper

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

/// באנר קניות פעילות - מציג:
/// 1. כשהמשתמש הנוכחי יש לו קנייה פעילה (עדיפות גבוהה)
/// 2. כשמישהו אחר קונה מרשימה משותפת
class ActiveShopperBanner extends StatelessWidget {
  const ActiveShopperBanner({super.key});

  /// מציאת רשימה עם קנייה פעילה של המשתמש הנוכחי
  ShoppingList? _findMyActiveShopping(ShoppingListsProvider listsProvider, String? currentUserId) {
    for (final list in listsProvider.lists) {
      if (list.isBeingShopped) {
        final activeShoppers = list.activeShoppers.where((s) => s.isActive).toList();
        final myActiveShopper = activeShoppers.where((s) => s.userId == currentUserId).firstOrNull;
        if (myActiveShopper != null) return list;
      }
    }
    return null;
  }

  /// מציאת רשימה עם קנייה פעילה של מישהו אחר
  ShoppingList? _findOthersActiveShopping(ShoppingListsProvider listsProvider, String? currentUserId) {
    for (final list in listsProvider.lists) {
      if (list.isBeingShopped) {
        final activeShoppers = list.activeShoppers.where((s) => s.isActive).toList();
        final isCurrentUserShopping = activeShoppers.any((s) => s.userId == currentUserId);
        if (!isCurrentUserShopping) return list;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ShoppingListsProvider>();
    final currentUserId = context.watch<UserContext>().userId;

    // 1. עדיפות גבוהה: קנייה פעילה של המשתמש
    final myList = _findMyActiveShopping(listsProvider, currentUserId);
    if (myList != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _MyActiveShoppingBanner(
          key: const ValueKey('my_active'),
          list: myList,
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0.0, curve: Curves.easeOut),
      );
    }

    // 2. קנייה פעילה של אחרים
    final othersList = _findOthersActiveShopping(listsProvider, currentUserId);
    if (othersList == null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: const SizedBox.shrink(key: ValueKey('none')),
      );
    }

    final activeShoppers = othersList.activeShoppers.where((s) => s.isActive).toList();
    final shopperCount = activeShoppers.length;

    // Resolve first shopper name from sharedUsers
    String? firstShopperName;
    if (activeShoppers.isNotEmpty) {
      final firstShopper = activeShoppers.first;
      firstShopperName = othersList.sharedUsers[firstShopper.userId]?.userName;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _OthersShoppingBanner(
        key: const ValueKey('others_active'),
        list: othersList,
        shopperCount: shopperCount,
        firstShopperName: firstShopperName,
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0.0, curve: Curves.easeOut),
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
    // ✅ FIX: Theme-aware accent color (replaces hardcoded blue)
    final accentColor = theme.extension<AppBrand>()?.accent ?? cs.primary;
    final uncheckedCount = list.items.where((i) => !i.isChecked).length;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onContinue(context),
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmallPlus,
              vertical: kSpacingSmall,
            ),
            child: Row(
              children: [
                // 🛒 Compact pulsing cart icon (32px — down from 40)
                _PulsingIcon(backgroundColor: cs.onPrimary, size: 32),
                const SizedBox(width: kSpacingSmallPlus),

                // Single-line content — list name · items remaining
                Expanded(
                  child: Text(
                    strings.myActiveCompact(list.name, uncheckedCount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: kSpacingSmall),

                // Trailing "continue" arrow — icon-only for compactness.
                // Accessible via Semantics label.
                Semantics(
                  button: true,
                  label: strings.continueButton,
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
                          strings.continueButton,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: kFontSizeSmall,
                          ),
                        ),
                        const SizedBox(width: kSpacingXTiny),
                        Icon(
                          Icons.play_arrow,
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
    );
  }

  void _onContinue(BuildContext context) {
    // ✅ FIX: unawaited for fire-and-forget
    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(context, '/active-shopping', arguments: list);
  }
}

/// באנר: מישהו אחר קונה מרשימה משותפת
class _OthersShoppingBanner extends StatelessWidget {
  final ShoppingList list;
  final int shopperCount;
  final String? firstShopperName;

  const _OthersShoppingBanner({super.key, required this.list, required this.shopperCount, this.firstShopperName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.activeShopperBanner;
    // ✅ FIX: Theme-aware success color
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // ✅ FIX: Theme-aware colors
            successColor.withValues(alpha: 0.9),
            successColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: [
          BoxShadow(
            // ✅ FIX: Theme-aware shadow
            color: successColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onViewList(context),
          borderRadius: BorderRadius.circular(kBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Row(
              children: [
                // אייקון מונפש
                _PulsingIcon(backgroundColor: cs.onPrimary),
                const SizedBox(width: kSpacingMedium),

                // טקסט
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopperCount == 1
                            ? strings.othersActiveTitle(firstShopperName ?? list.name)
                            : strings.othersActiveTitleMultiple(shopperCount),
                        style: theme.textTheme.titleSmall?.copyWith(
                          // ✅ FIX: Theme-aware color
                          color: cs.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        // ✅ FIX: Overflow protection
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shopperCount == 1
                            ? strings.othersActiveSingle(list.name)
                            : strings.othersActiveMultiple(shopperCount, list.name),
                        style: theme.textTheme.bodySmall?.copyWith(
                          // ✅ FIX: Theme-aware color
                          color: cs.onPrimary.withValues(alpha: 0.9),
                        ),
                        // ✅ FIX: Overflow protection
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // כפתורי פעולה
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // כפתור הצטרף
                    _ActionButton(
                      label: strings.joinButton,
                      icon: Icons.group_add,
                      onPressed: () => _onJoin(context),
                      // ✅ FIX: Theme-aware colors
                      backgroundColor: cs.onPrimary,
                      foregroundColor: successColor,
                    ),
                    const SizedBox(width: kSpacingSmall),
                    // כפתור צפה
                    IconButton(
                      onPressed: () => _onViewList(context),
                      icon: const Icon(Icons.visibility_outlined),
                      // ✅ FIX: Theme-aware color
                      color: cs.onPrimary.withValues(alpha: 0.8),
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
    );
  }

  void _onJoin(BuildContext context) {
    // 🔐 בדיקת הרשאות - צופה לא יכול להצטרף לקנייה
    final userId = context.read<UserContext>().userId;
    if (userId != null) {
      final userRole = list.getUserRole(userId);
      if (userRole != null && !userRole.canShop) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.shopping.viewerCannotShop),
            backgroundColor: StatusColors.getColor(StatusType.pending, context),
          ),
        );
        return;
      }
    }

    // ✅ FIX: unawaited for fire-and-forget
    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(context, '/active-shopping', arguments: list);
  }

  void _onViewList(BuildContext context) {
    // ✅ FIX: unawaited for fire-and-forget
    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(context, '/active-shopping', arguments: {'list': list, 'readOnly': true});
  }
}

/// כפתור פעולה קטן
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  /// ✅ FIX: Theme-aware color parameters
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
        // ✅ FIX: Theme-aware colors
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingSmall),
        minimumSize: Size.zero,
        textStyle: const TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// אייקון פועם - נכתב מחדש באמצעות flutter_animate לקיצור קוד (Clean Code)
class _PulsingIcon extends StatelessWidget {
  /// ✅ FIX: Theme-aware color parameter
  final Color backgroundColor;

  /// Outer container size (defaults to the legacy 40px).
  /// The compact banner passes 32 for a tighter layout.
  final double size;

  const _PulsingIcon({required this.backgroundColor, this.size = 40});

  @override
  Widget build(BuildContext context) {
    // Scale the icon down alongside the container so it keeps its optical
    // weight when the caller asks for a smaller badge.
    final iconSize = size >= 40 ? kIconSizeMedium : kIconSizeSmallPlus;
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Icon(
            Icons.shopping_cart,
            color: backgroundColor,
            size: iconSize,
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.95, end: 1.05, duration: 1500.ms, curve: Curves.easeInOut);
  }
}
