// 📄 lib/screens/home/dashboard/widgets/active_shopper_banner.dart
//
// באנר קניות פעילות - מוצג ב-2 מקרים:
// 1. המשתמש הנוכחי יש לו קנייה פעילה → "להמשיך קנייה?"
// 2. מישהו אחר קונה מרשימה משותפת → "קניות מתבצעות!"
//
// Version: 2.0 (11/01/2026) - הוספת באנר לקנייה פעילה של המשתמש
// 🔗 Related: ShoppingList, ActiveShopper

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../models/shopping_list.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/user_context.dart';

/// באנר קניות פעילות - מציג:
/// 1. כשהמשתמש הנוכחי יש לו קנייה פעילה (עדיפות גבוהה)
/// 2. כשמישהו אחר קונה מרשימה משותפת
class ActiveShopperBanner extends StatelessWidget {
  const ActiveShopperBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ShoppingListsProvider>();
    final userContext = context.watch<UserContext>();
    final currentUserId = userContext.userId;

    // 1. עדיפות גבוהה: בדוק אם המשתמש הנוכחי יש לו קנייה פעילה
    ShoppingList? myActiveShoppingList;
    for (final list in listsProvider.lists) {
      if (list.isBeingShopped) {
        final activeShoppers = list.activeShoppers.where((s) => s.isActive).toList();
        final myActiveShopper = activeShoppers.where((s) => s.userId == currentUserId).firstOrNull;
        if (myActiveShopper != null) {
          myActiveShoppingList = list;
          break;
        }
      }
    }

    // אם למשתמש יש קנייה פעילה - מציג באנר "להמשיך"
    if (myActiveShoppingList != null) {
      return _MyActiveShoppingBanner(list: myActiveShoppingList);
    }

    // 2. בדוק אם מישהו אחר קונה מרשימה משותפת
    ShoppingList? othersShoppingList;
    for (final list in listsProvider.lists) {
      if (list.isBeingShopped) {
        final activeShoppers = list.activeShoppers.where((s) => s.isActive).toList();
        final isCurrentUserShopping = activeShoppers.any((s) => s.userId == currentUserId);
        if (!isCurrentUserShopping) {
          othersShoppingList = list;
          break;
        }
      }
    }

    // אם אין רשימה עם קנייה פעילה של אחרים - לא מציג
    if (othersShoppingList == null) {
      return const SizedBox.shrink();
    }

    final shopperCount = othersShoppingList.activeShoppers.where((s) => s.isActive).length;

    return _OthersShoppingBanner(
      list: othersShoppingList,
      shopperCount: shopperCount,
    );
  }
}

/// באנר: יש לך קנייה פעילה - להמשיך?
class _MyActiveShoppingBanner extends StatelessWidget {
  final ShoppingList list;

  const _MyActiveShoppingBanner({required this.list});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uncheckedCount = list.items.where((i) => !i.isChecked).length;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onContinue(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Row(
              children: [
                // אייקון מונפש
                const _PulsingIcon(),
                const SizedBox(width: kSpacingMedium),

                // טקסט
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'יש לך קנייה פעילה',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"${list.name}" - נותרו $uncheckedCount פריטים',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // כפתור המשך
                ElevatedButton.icon(
                  onPressed: () => _onContinue(context),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('המשך'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 13,
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
    HapticFeedback.lightImpact();
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

  const _OthersShoppingBanner({
    required this.list,
    required this.shopperCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kStickyGreen.withValues(alpha: 0.9),
            kStickyGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kStickyGreen.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onViewList(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Row(
              children: [
                // אייקון מונפש
                const _PulsingIcon(),
                const SizedBox(width: kSpacingMedium),

                // טקסט
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'קניות מתבצעות!',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shopperCount == 1
                            ? 'מישהו קונה מ"${list.name}"'
                            : '$shopperCount אנשים קונים מ"${list.name}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
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
                      label: 'הצטרף',
                      icon: Icons.group_add,
                      onPressed: () => _onJoin(context),
                    ),
                    const SizedBox(width: 8),
                    // כפתור צפה
                    IconButton(
                      onPressed: () => _onViewList(context),
                      icon: const Icon(Icons.visibility_outlined),
                      color: Colors.white.withValues(alpha: 0.8),
                      tooltip: 'צפה ברשימה',
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
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/active-shopping',
      arguments: list,
    );
  }

  void _onViewList(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/list-details',
      arguments: list,
    );
  }
}

/// כפתור פעולה קטן
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kStickyGreen,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// אייקון פועם
class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon();

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

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
