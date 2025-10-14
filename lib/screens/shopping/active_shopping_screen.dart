// 📄 File: lib/screens/shopping/active_shopping_screen.dart
//
// 🎯 Purpose: מסך קנייה פעילה - המשתמש בחנות וקונה מוצרים
//
// ✨ Features:
// - ⏱️ טיימר - מודד כמה זמן עובר מתחילת הקנייה
// - 📊 מונים - כמה נקנה / כמה נשאר / כמה לא היה
// - 🗂️ סידור לפי קטגוריות
// - ✅ סימון מוצרים: נקנה / לא במלאי / דחוי
// - 📱 כפתורי פעולה מהירה
// - 🏁 סיכום מפורט בסיום
//
// 🎨 UI:
// - Header עם טיימר וסטטיסטיקות
// - רשימת מוצרים לפי קטגוריות
// - כפתורים לסימון מהיר
// - מסך סיכום בסוף
//
// Usage:
// ```dart
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => ActiveShoppingScreen(list: shoppingList),
//   ),
// );
// ```

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../models/enums/shopping_item_status.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/products_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';
import '../../core/status_colors.dart';

class ActiveShoppingScreen extends StatefulWidget {
  final ShoppingList list;

  const ActiveShoppingScreen({super.key, required this.list});

  @override
  State<ActiveShoppingScreen> createState() => _ActiveShoppingScreenState();
}

class _ActiveShoppingScreenState extends State<ActiveShoppingScreen> {
  // ⏱️ טיימר
  late DateTime _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // 📊 מצבי פריטים (item.id → status)
  final Map<String, ShoppingItemStatus> _itemStatuses = {};

  @override
  void initState() {
    super.initState();
    debugPrint('🛒 ActiveShoppingScreen.initState: התחלה');
    _startTime = DateTime.now();

    // התחל טיימר שמתעדכן כל שנייה
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime);
      });
    });

    // אתחל את כל הפריטים כ-pending
    for (final item in widget.list.items) {
      _itemStatuses[item.id] = ShoppingItemStatus.pending;
    }

    debugPrint('✅ ActiveShoppingScreen.initState: ${widget.list.items.length} פריטים');
  }

  @override
  void dispose() {
    debugPrint('🗑️ ActiveShoppingScreen.dispose');
    _timer?.cancel();
    super.dispose();
  }

  /// עדכון סטטוס פריט
  void _updateItemStatus(ReceiptItem item, ShoppingItemStatus newStatus) {
    debugPrint('📝 _updateItemStatus: ${item.name} → ${newStatus.label}');
    setState(() {
      _itemStatuses[item.id] = newStatus;
    });
    debugPrint('✅ _updateItemStatus: עודכן בהצלחה');
  }

  /// סיום קנייה - מעבר למסך סיכום
  Future<void> _finishShopping() async {
    debugPrint('🏁 _finishShopping: מתחיל סיכום');
    final purchased = _itemStatuses.values
        .where((s) => s == ShoppingItemStatus.purchased)
        .length;
    final outOfStock = _itemStatuses.values
        .where((s) => s == ShoppingItemStatus.outOfStock)
        .length;
    final deferred =
        _itemStatuses.values.where((s) => s == ShoppingItemStatus.deferred).length;
    final notNeeded =
        _itemStatuses.values.where((s) => s == ShoppingItemStatus.notNeeded).length;  // חדש!
    final pending =
        _itemStatuses.values.where((s) => s == ShoppingItemStatus.pending).length;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ShoppingSummaryDialog(
        listName: widget.list.name,
        duration: _elapsed,
        total: widget.list.items.length,
        purchased: purchased,
        outOfStock: outOfStock,
        deferred: deferred,
        notNeeded: notNeeded,  // חדש!
        pending: pending,
      ),
    );

    if (result == true && mounted) {
      debugPrint('✅ _finishShopping: משתמש אישר סיום');
      // סמן את הרשימה כהושלמה
      final provider = context.read<ShoppingListsProvider>();
      await provider.updateListStatus(
        widget.list.id,
        ShoppingList.statusCompleted,
      );
      debugPrint('✅ _finishShopping: רשימה סומנה כהושלמה');

      if (mounted) {
        debugPrint('🚪 _finishShopping: חוזר למסך קודם');
        Navigator.pop(context);
      }
    } else {
      debugPrint('❌ _finishShopping: משתמש ביטל');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // Empty State - אם אין פריטים
    if (widget.list.items.isEmpty) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          title: Text(
            widget.list.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: kIconSizeXLarge * 2,
                color: cs.onSurfaceVariant,
              ),
              SizedBox(height: kSpacingMedium),
              Text(
                'הרשימה ריקה',
                style: TextStyle(
                  fontSize: kFontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: kSpacingSmall),
              Text(
                'אין פריטים לקנייה',
                style: TextStyle(
                  fontSize: kFontSizeBody,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // חשב סטטיסטיקות
    final purchased = _itemStatuses.values
        .where((s) => s == ShoppingItemStatus.purchased)
        .length;
    final notNeeded = _itemStatuses.values
        .where((s) => s == ShoppingItemStatus.notNeeded)
        .length;
    final completed = purchased + notNeeded; // סה"כ מה שהושלם
    final total = widget.list.items.length;

    // קבץ לפי קטגוריה
    final productsProvider = context.watch<ProductsProvider>();
    final itemsByCategory = <String, List<ReceiptItem>>{};
    for (final item in widget.list.items) {
      // שליפת קטגוריה מ-ProductsProvider
      final product = productsProvider.getByName(item.name ?? '');
      final category = product?['category'] as String? ?? 'כללי';
      itemsByCategory.putIfAbsent(category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.list.name,
              style: const TextStyle(
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              '⏱️ ${_formatDuration(_elapsed)}',
              style: const TextStyle(fontSize: kFontSizeSmall),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _finishShopping,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'סיום',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 📊 Header - סטטיסטיקות
          Container(
            padding: const EdgeInsets.all(kSpacingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.1),
                  cs.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.check_circle,
                  label: 'קנוי',  // שונה!
                  value: '$purchased',
                  color: StatusColors.success,
                ),
                _StatCard(
                  icon: Icons.block,
                  label: 'לא צריך',  // חדש!
                  value: '$notNeeded',
                  color: Colors.grey.shade600,
                ),
                _StatCard(
                  icon: Icons.shopping_cart,
                  label: 'נותרו',
                  value: '${total - completed}',  // שונה - מוריד גם notNeeded
                  color: StatusColors.info,
                ),
                _StatCard(
                  icon: Icons.inventory_2,
                  label: 'סה״כ',
                  value: '$total',
                  color: StatusColors.pending,
                ),
              ],
            ),
          ),

          // 🗂️ רשימת מוצרים לפי קטגוריות
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(kSpacingMedium),
              itemCount: itemsByCategory.length,
              itemBuilder: (context, index) {
                final category = itemsByCategory.keys.elementAt(index);
                final items = itemsByCategory[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // כותרת קטגוריה
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: kFontSizeMedium,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    ),

                    // פריטים בקטגוריה
                    ...items.map((item) => _ActiveShoppingItemTile(
                          item: item,
                          status: _itemStatuses[item.id]!,
                          onStatusChanged: (newStatus) =>
                              _updateItemStatus(item, newStatus),
                        )),

                    const SizedBox(height: kSpacingMedium),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// פורמט משך זמן (HH:MM:SS)
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

// ========================================
// Widget: כרטיס סטטיסטיקה
// ========================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: kIconSizeLarge),
        const SizedBox(height: kSpacingTiny),
        Text(
          value,
          style: TextStyle(
            fontSize: kFontSizeXLarge,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: kFontSizeSmall,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: פריט בקנייה פעילה
// ========================================

class _ActiveShoppingItemTile extends StatelessWidget {
  final ReceiptItem item;
  final ShoppingItemStatus status;
  final Function(ShoppingItemStatus) onStatusChanged;

  const _ActiveShoppingItemTile({
    required this.item,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 💰 שליפת מחיר אמיתי מ-ProductsProvider
    final productsProvider = context.watch<ProductsProvider>();
    final product = productsProvider.getByName(item.name ?? '');
    final realPrice = product?['price'] as double? ?? item.unitPrice;

    // 🎨 צבע רקע לפי סטטוס
    Color cardColor;
    switch (status) {
      case ShoppingItemStatus.purchased:
        cardColor = StatusColors.success.withValues(alpha: 0.1);
        break;
      case ShoppingItemStatus.outOfStock:
        cardColor = StatusColors.error.withValues(alpha: 0.1);
        break;
      case ShoppingItemStatus.deferred:
        cardColor = StatusColors.warning.withValues(alpha: 0.1);
        break;
      default:
        cardColor = cs.surface;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      elevation: status == ShoppingItemStatus.purchased ? 1 : kCardElevation,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingSmallPlus),
        child: Column(
          children: [
            // שורה עליונה: שם + מחיר
            Row(
              children: [
                // אייקון סטטוס - גדול יותר לפריטים שסומנו
                Icon(
                  status.icon,
                  color: status.color,
                  size: status == ShoppingItemStatus.pending
                      ? kIconSizeMedium + 4
                      : kIconSizeLarge,
                ),
                const SizedBox(width: kSpacingSmallPlus),

                // שם המוצר
                Expanded(
                  child: Text(
                    item.name ?? 'ללא שם',
                    style: TextStyle(
                      fontSize: kFontSizeBody,
                      fontWeight: FontWeight.w600,
                      decoration: status == ShoppingItemStatus.purchased
                          ? TextDecoration.lineThrough
                          : null,
                      color: status == ShoppingItemStatus.pending
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),

                // כמות × מחיר אמיתי
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity}×',
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: status == ShoppingItemStatus.pending
                            ? cs.onSurfaceVariant
                            : cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      realPrice > 0
                          ? '₪${realPrice.toStringAsFixed(2)}'
                          : 'אין מחיר',
                      style: TextStyle(
                        fontSize: kFontSizeBody,
                        fontWeight: FontWeight.bold,
                        color: realPrice > 0
                            ? (status == ShoppingItemStatus.pending
                                ? status.color
                                : status.color.withValues(alpha: 0.8))
                            : cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: kSpacingSmallPlus),

            // שורה תחתונה: 4 כפתורי פעולה
            Column(
              children: [
                // שורה 1: קנוי + אזל
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.check_circle,
                        label: 'קנוי',  // שונה!
                        color: StatusColors.success,
                        isSelected: status == ShoppingItemStatus.purchased,
                        onTap: () => onStatusChanged(ShoppingItemStatus.purchased),
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.remove_shopping_cart,
                        label: 'אזל',
                        color: StatusColors.error,
                        isSelected: status == ShoppingItemStatus.outOfStock,
                        onTap: () => onStatusChanged(ShoppingItemStatus.outOfStock),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingSmall),
                // שורה 2: דחה לאחר כך + לא צריך
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.schedule,
                        label: 'דחה לאחר כך',  // שונה!
                        color: StatusColors.warning,
                        isSelected: status == ShoppingItemStatus.deferred,
                        onTap: () => onStatusChanged(ShoppingItemStatus.deferred),
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.block,
                        label: 'לא צריך',  // חדש!
                        color: Colors.grey.shade700,
                        isSelected: status == ShoppingItemStatus.notNeeded,
                        onTap: () => onStatusChanged(ShoppingItemStatus.notNeeded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Widget: כפתור פעולה
// ========================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: kSpacingSmall,
          horizontal: kSpacingTiny,
        ),
        constraints: const BoxConstraints(
          minHeight: kButtonHeight,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : cs.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : cs.onSurfaceVariant,
              size: kIconSizeSmall,
            ),
            const SizedBox(width: kSpacingTiny),
            Text(
              label,
              style: TextStyle(
                fontSize: kFontSizeTiny + 1,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Dialog: סיכום קנייה
// ========================================

class _ShoppingSummaryDialog extends StatelessWidget {
  final String listName;
  final Duration duration;
  final int total;
  final int purchased;
  final int outOfStock;
  final int deferred;
  final int notNeeded;  // חדש!
  final int pending;

  const _ShoppingSummaryDialog({
    required this.listName,
    required this.duration,
    required this.total,
    required this.purchased,
    required this.outOfStock,
    required this.deferred,
    required this.notNeeded,  // חדש!
    required this.pending,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes דק\' $seconds שנ\'';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: StatusColors.success, size: kIconSizeLarge),
          const SizedBox(width: kSpacingSmallPlus),
          Expanded(
            child: Text(
              'סיכום קנייה',
              style: TextStyle(
                fontSize: kFontSizeLarge + 4,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listName,
              style: TextStyle(
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: kSpacingMedium),

            // ⏱️ זמן קנייה
            _SummaryRow(
              icon: Icons.timer,
              label: 'זמן קנייה',
              value: _formatDuration(duration),
              color: StatusColors.info,
            ),

            const Divider(height: kSpacingLarge),

            // ✅ קנוי
            _SummaryRow(
              icon: Icons.check_circle,
              label: 'קנוי',  // שונה!
              value: '$purchased מתוך $total',
              color: StatusColors.success,
            ),

            // 🚫 לא צריך
            if (notNeeded > 0)  // חדש!
              _SummaryRow(
                icon: Icons.block,
                label: 'לא צריך',
                value: '$notNeeded',
                color: Colors.grey.shade700,
              ),

            // ❌ אזלו
            if (outOfStock > 0)
              _SummaryRow(
                icon: Icons.remove_shopping_cart,
                label: 'אזלו בחנות',  // שונה!
                value: '$outOfStock',
                color: StatusColors.error,
              ),

            // ⏭️ נדחו
            if (deferred > 0)
              _SummaryRow(
                icon: Icons.schedule,
                label: 'נדחו לפעם הבאה',
                value: '$deferred',
                color: StatusColors.warning,
              ),

            // ⏸️ לא סומנו
            if (pending > 0)
              _SummaryRow(
                icon: Icons.radio_button_unchecked,
                label: 'לא סומנו',
                value: '$pending',
                color: StatusColors.pending,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('חזור'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.check),
          label: const Text('סיים קנייה'),
        ),
      ],
    );
  }
}

// ========================================
// Widget: שורת סיכום
// ========================================

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      child: Row(
        children: [
          Icon(icon, color: color, size: kIconSizeMedium + 2),
          const SizedBox(width: kSpacingSmallPlus),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: kFontSizeBody),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: kFontSizeBody,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
