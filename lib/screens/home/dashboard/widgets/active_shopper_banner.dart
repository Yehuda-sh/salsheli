// 📄 lib/screens/home/dashboard/widgets/active_shopper_banner.dart
//
// באנר קניות פעילות - מוצג ב-2 מקרים:
// 1. המשתמש הנוכחי יש לו קנייה פעילה → "להמשיך קנייה?"
// 2. מישהו אחר קונה מרשימה משותפת → "קניות מתבצעות!"
//
// ✅ Features:
//    - אנימציית כניסה לבאנר (flutter_animate)
//    - מעבר חלק בין מצבי באנר (AnimatedSwitcher)
//
// Version: 3.1 (22/02/2026)
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
  ShoppingList? _findMyActiveShopping(
    ShoppingListsProvider listsProvider,
    String? currentUserId,
  ) {
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
  ShoppingList? _findOthersActiveShopping(
    ShoppingListsProvider listsProvider,
    String? currentUserId,
  ) {
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
        child: _MyActiveShoppingBanner(key: const ValueKey('my_active'), list: myList)
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.2, end: 0.0, curve: Curves.easeOut),
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
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: -0.2, end: 0.0, curve: Curves.easeOut),
    );
  }
}

/// באנר: יש לך קנייה פעילה - להמשיך?
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
            // ✅ FIX: Theme-aware colors
            accentColor,
            accentColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: [
          BoxShadow(
            // ✅ FIX: Theme-aware shadow
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
                        strings.myActiveTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          // ✅ FIX: Theme-aware color
                          color: cs.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        // ✅ FIX: Overflow protection
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        strings.myActiveSubtitle(list.name, uncheckedCount),
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

                // כפתור המשך
                ElevatedButton.icon(
                  onPressed: () => _onContinue(context),
                  icon: Icon(Icons.play_arrow, size: 18),
                  label: Text(strings.continueButton),
                  style: ElevatedButton.styleFrom(
                    // ✅ FIX: Theme-aware colors
                    backgroundColor: cs.onPrimary,
                    foregroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.bold,
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
    Navigator.pushNamed(
      context,
      '/active-shopping',
      arguments: list,
    );
  }
}

/// באנר: מישהו אחר קונה מרשימה משותפת
class _OthersShoppingBanner extends StatelessWidget {
  final ShoppingList list;
  final int shopperCount;
  final String? firstShopperName;

  const _OthersShoppingBanner({
    super.key,
    required this.list,
    required this.shopperCount,
    this.firstShopperName,
  });

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
                      SizedBox(height: 2),
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
                    SizedBox(width: 8),
                    // כפתור צפה
                    IconButton(
                      onPressed: () => _onViewList(context),
                      icon: Icon(Icons.visibility_outlined),
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
            backgroundColor: StatusColors.pending,
          ),
        );
        return;
      }
    }

    // ✅ FIX: unawaited for fire-and-forget
    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(
      context,
      '/active-shopping',
      arguments: list,
    );
  }

  void _onViewList(BuildContext context) {
    // ✅ FIX: unawaited for fire-and-forget
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
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        // ✅ FIX: Theme-aware colors
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        textStyle: const TextStyle(
          fontSize: kFontSizeSmall,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// אייקון פועם
class _PulsingIcon extends StatefulWidget {
  /// ✅ FIX: Theme-aware color parameter
  final Color backgroundColor;

  const _PulsingIcon({required this.backgroundColor});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // ✅ FIX: Theme-aware color
              color: widget.backgroundColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Icon(
              Icons.shopping_cart,
              // ✅ FIX: Theme-aware color
              color: widget.backgroundColor,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
