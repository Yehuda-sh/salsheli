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
import '../../theme/app_theme.dart';

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

    debugPrint('🛒 ActiveShoppingScreen: התחלה - ${widget.list.items.length} פריטים');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// עדכון סטטוס פריט
  void _updateItemStatus(ReceiptItem item, ShoppingItemStatus newStatus) {
    setState(() {
      _itemStatuses[item.id] = newStatus;
    });
    debugPrint('   📝 ${item.name}: ${newStatus.label}');
  }

  /// סיום קנייה - מעבר למסך סיכום
  Future<void> _finishShopping() async {
    final purchased = _itemStatuses.values
        .where((s) => s == ShoppingItemStatus.purchased)
        .length;
    final outOfStock = _itemStatuses.values
        .where((s) => s == ShoppingItemStatus.outOfStock)
        .length;
    final deferred =
        _itemStatuses.values.where((s) => s == ShoppingItemStatus.deferred).length;
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
        pending: pending,
      ),
    );

    if (result == true && mounted) {
      // סמן את הרשימה כהושלמה
      final provider = context.read<ShoppingListsProvider>();
      await provider.updateListStatus(
        widget.list.id,
        ShoppingList.statusCompleted,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // חשב סטטיסטיקות
    final purchased = _itemStatuses.values
        .where((s) => s == ShoppingItemStatus.purchased)
        .length;
    final total = widget.list.items.length;

    // קבץ לפי קטגוריה
    final itemsByCategory = <String, List<ReceiptItem>>{};
    for (final item in widget.list.items) {
      // TODO: בעתיד ניקח את הקטגוריה מ-ProductsProvider
      final category = 'כללי'; // זמני
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '⏱️ ${_formatDuration(_elapsed)}',
              style: const TextStyle(fontSize: 14),
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
            padding: const EdgeInsets.all(16),
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
                  label: 'נקנו',
                  value: '$purchased',
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.shopping_cart,
                  label: 'נותרו',
                  value: '${total - purchased}',
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.inventory_2,
                  label: 'סה״כ',
                  value: '$total',
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          // 🗂️ רשימת מוצרים לפי קטגוריות
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: itemsByCategory.length,
              itemBuilder: (context, index) {
                final category = itemsByCategory.keys.elementAt(index);
                final items = itemsByCategory[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // כותרת קטגוריה
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
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

                    const SizedBox(height: 16),
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
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: status == ShoppingItemStatus.purchased ? 0 : 2,
      color: status == ShoppingItemStatus.purchased
          ? cs.surfaceContainerHighest
          : cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // שורה עליונה: שם + מחיר
            Row(
              children: [
                // אייקון סטטוס
                Icon(
                  status.icon,
                  color: status.color,
                  size: 28,
                ),
                const SizedBox(width: 12),

                // שם המוצר
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: status == ShoppingItemStatus.purchased
                          ? TextDecoration.lineThrough
                          : null,
                      color: status == ShoppingItemStatus.purchased
                          ? cs.onSurfaceVariant
                          : cs.onSurface,
                    ),
                  ),
                ),

                // כמות × מחיר
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity}×',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '₪${item.unitPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // שורה תחתונה: כפתורי פעולה
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.check_circle,
                    label: 'נקנה',
                    color: Colors.green,
                    isSelected: status == ShoppingItemStatus.purchased,
                    onTap: () => onStatusChanged(ShoppingItemStatus.purchased),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.remove_shopping_cart,
                    label: 'אזל',
                    color: Colors.red,
                    isSelected: status == ShoppingItemStatus.outOfStock,
                    onTap: () => onStatusChanged(ShoppingItemStatus.outOfStock),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.schedule,
                    label: 'דחה',
                    color: Colors.orange,
                    isSelected: status == ShoppingItemStatus.deferred,
                    onTap: () => onStatusChanged(ShoppingItemStatus.deferred),
                  ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
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
  final int pending;

  const _ShoppingSummaryDialog({
    required this.listName,
    required this.duration,
    required this.total,
    required this.purchased,
    required this.outOfStock,
    required this.deferred,
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
          Icon(Icons.check_circle, color: Colors.green, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'סיכום קנייה',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 16),

            // ⏱️ זמן קנייה
            _SummaryRow(
              icon: Icons.timer,
              label: 'זמן קנייה',
              value: _formatDuration(duration),
              color: Colors.blue,
            ),

            const Divider(height: 24),

            // ✅ נקנו
            _SummaryRow(
              icon: Icons.check_circle,
              label: 'נקנו',
              value: '$purchased מתוך $total',
              color: Colors.green,
            ),

            // ❌ לא במלאי
            if (outOfStock > 0)
              _SummaryRow(
                icon: Icons.remove_shopping_cart,
                label: 'לא היו במלאי',
                value: '$outOfStock',
                color: Colors.red,
              ),

            // ⏭️ דחוי
            if (deferred > 0)
              _SummaryRow(
                icon: Icons.schedule,
                label: 'נדחו לפעם הבאה',
                value: '$deferred',
                color: Colors.orange,
              ),

            // ⏸️ לא סומנו
            if (pending > 0)
              _SummaryRow(
                icon: Icons.radio_button_unchecked,
                label: 'לא סומנו',
                value: '$pending',
                color: Colors.grey,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
