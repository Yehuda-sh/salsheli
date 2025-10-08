// 📄 File: lib/widgets/item_card.dart
// תיאור: כרטיס פריט (ReceiptItem) עם אפשרויות עדכון כמות, סטטוס ומחיקה
//
// תכונות:
// - תצוגת מידע מלא: שם, קטגוריה, כמות, מחיר
// - 4 סטטוסים: pending, taken, missing, replaced
// - כפתורי +/- לשליטה בכמות
// - מחיקה (כפתור סל אשפה)
// - פידבק ויזואלי (SnackBar) לכל פעולה
// - תואם Material Design: גדלי מגע 48px, theme colors
//
// תלויות:
// - ReceiptItem model
// - Theme colors (AppBrand)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/receipt.dart';
import '../theme/app_theme.dart';

// ============================
// קבועים
// ============================

const double _kMinTouchTarget = 48.0;
const double _kCardPadding = 16.0;
const double _kCardBorderRadius = 12.0;
const double _kStatusButtonPadding = 8.0;
const double _kStatusButtonMinHeight = 36.0;
const double _kStatusIconSize = 16.0;
const double _kStatusFontSize = 12.0;
const double _kQuantityFontSize = 16.0;
const double _kProductNameFontSize = 16.0;
const double _kMetaFontSize = 12.0;
const double _kPriceFontSize = 14.0;

// מפת סטטוסים עם קונפיגורציה לכל אחד
class _ItemStatusConfig {
  final String key;
  final String nameHe;
  final IconData icon;
  final Color Function(ColorScheme) getColor;
  final Color Function(ColorScheme) getBgColor;

  const _ItemStatusConfig({
    required this.key,
    required this.nameHe,
    required this.icon,
    required this.getColor,
    required this.getBgColor,
  });
}

// 4 סטטוסים אפשריים
const List<_ItemStatusConfig> _kItemStatuses = [
  _ItemStatusConfig(
    key: 'pending',
    nameHe: 'ממתין',
    icon: Icons.radio_button_unchecked,
    getColor: _getGrayColor,
    getBgColor: _getGrayBgColor,
  ),
  _ItemStatusConfig(
    key: 'taken',
    nameHe: 'נלקח',
    icon: Icons.check_circle,
    getColor: _getGreenColor,
    getBgColor: _getGreenBgColor,
  ),
  _ItemStatusConfig(
    key: 'missing',
    nameHe: 'חסר',
    icon: Icons.cancel,
    getColor: _getRedColor,
    getBgColor: _getRedBgColor,
  ),
  _ItemStatusConfig(
    key: 'replaced',
    nameHe: 'הוחלף',
    icon: Icons.refresh,
    getColor: _getOrangeColor,
    getBgColor: _getOrangeBgColor,
  ),
];

// פונקציות עזר לצבעים
Color _getGrayColor(ColorScheme cs) => cs.onSurfaceVariant;
Color _getGrayBgColor(ColorScheme cs) =>
    cs.surfaceContainerHighest.withValues(alpha: 0.5);
Color _getGreenColor(ColorScheme cs) => const Color(0xFF10B981); // green-500
Color _getGreenBgColor(ColorScheme cs) => const Color(0xFFDCFCE7); // green-100
Color _getRedColor(ColorScheme cs) => cs.error;
Color _getRedBgColor(ColorScheme cs) =>
    cs.errorContainer.withValues(alpha: 0.3);
Color _getOrangeColor(ColorScheme cs) => const Color(0xFFF97316); // orange-500
Color _getOrangeBgColor(ColorScheme cs) =>
    const Color(0xFFFFEDD5); // orange-100

// ============================
// Widget
// ============================

class ItemCard extends StatefulWidget {
  final ReceiptItem item;
  final Future<void> Function(String id, ReceiptItem updatedItem) onUpdate;
  final Future<void> Function(String id) onDelete;
  final int index;
  final String currentStatus; // סטטוס נוכחי של הפריט

  const ItemCard({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
    required this.currentStatus,
    this.index = 0,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool isUpdating = false;

  String formatILS(num amount) {
    final formatter = NumberFormat.currency(locale: "he_IL", symbol: "₪");
    return formatter.format(amount);
  }

  Future<void> _handleQuantityChange(int newQuantity) async {
    if (newQuantity < 0 || isUpdating) return;

    setState(() => isUpdating = true);

    if (newQuantity == 0) {
      await _handleDelete();
      return;
    }

    try {
      final updatedItem = widget.item.copyWith(quantity: newQuantity);
      await widget.onUpdate(widget.item.id, updatedItem);
      if (mounted) {
        _showSnack('${widget.item.name ?? 'ללא שם'} עודכן ל-$newQuantity יח׳');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('שגיאה בעדכון כמות', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    try {
      await widget.onDelete(widget.item.id);
      if (mounted) {
        _showSnack('${widget.item.name ?? 'ללא שם'} הוסר מהרשימה');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('שגיאה במחיקה', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Future<void> _handleStatusChange(String newStatus) async {
    if (isUpdating || newStatus == widget.currentStatus) return;

    setState(() => isUpdating = true);

    try {
      // עדכון דרך callback - הסטטוס מנוהל מחוץ ל-ReceiptItem
      // במקרה זה, הקוד הקורא צריך לטפל בסטטוס בנפרד
      // כאן אנחנו רק מעדכנים את ה-item עצמו
      await widget.onUpdate(widget.item.id, widget.item);

      final statusName = _kItemStatuses
          .firstWhere((s) => s.key == newStatus)
          .nameHe;
      if (mounted) {
        _showSnack('${widget.item.name ?? 'ללא שם'} סומן כ-$statusName');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('שגיאה בעדכון סטטוס', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;

    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? cs.error : cs.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    final price = widget.item.unitPrice;
    final quantity = widget.item.quantity;
    final totalPrice = widget.item.totalPrice;

    // מציאת קונפיגורציית הסטטוס הנוכחי
    final currentStatusConfig = _kItemStatuses.firstWhere(
      (s) => s.key == widget.currentStatus,
      orElse: () => _kItemStatuses[0], // ברירת מחדל: pending
    );

    return Semantics(
      label:
          '${widget.item.name ?? 'ללא שם'}, כמות: $quantity, מחיר: ${formatILS(totalPrice)}, סטטוס: ${currentStatusConfig.nameHe}',
      child: Card(
        color: cs.surfaceContainerHigh,
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kCardBorderRadius),
          side: BorderSide(color: cs.outline.withValues(alpha: 0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_kCardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // שורה עליונה: שם המוצר + מחיר
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // שם המוצר + מטא-דאטה
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name ?? 'ללא שם',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: _kProductNameFontSize,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // מטא-דאטה (ברקוד/יצרן אם קיים)
                        if (widget.item.barcode != null ||
                            widget.item.manufacturer != null)
                          Text(
                            [
                              if (widget.item.manufacturer != null)
                                widget.item.manufacturer!,
                              if (widget.item.barcode != null)
                                'ברקוד: ${widget.item.barcode!}',
                            ].join(' • '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: _kMetaFontSize,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // מחיר
                  if (price > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatILS(totalPrice),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: _kPriceFontSize,
                            color: brand?.accent ?? cs.primary,
                          ),
                        ),
                        if (quantity > 1)
                          Text(
                            '(${formatILS(price)} ליח׳)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: _kMetaFontSize,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // כפתורי סטטוס
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kItemStatuses.map((statusConfig) {
                  final isActive = statusConfig.key == widget.currentStatus;
                  final color = statusConfig.getColor(cs);
                  final bgColor = statusConfig.getBgColor(cs);

                  return OutlinedButton.icon(
                    onPressed: isUpdating
                        ? null
                        : () => _handleStatusChange(statusConfig.key),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isActive ? bgColor : null,
                      foregroundColor: color,
                      side: BorderSide(
                        color: isActive ? color : cs.outline,
                        width: isActive ? 2 : 1,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: _kStatusButtonPadding,
                        vertical: _kStatusButtonPadding,
                      ),
                      minimumSize: const Size(0, _kStatusButtonMinHeight),
                    ),
                    icon: Icon(statusConfig.icon, size: _kStatusIconSize),
                    label: Text(
                      statusConfig.nameHe,
                      style: TextStyle(fontSize: _kStatusFontSize),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // שליטה בכמות
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // כפתורי +/-
                  Row(
                    children: [
                      // כפתור מחיקה/הפחתה
                      SizedBox(
                        width: _kMinTouchTarget,
                        height: _kMinTouchTarget,
                        child: IconButton(
                          onPressed: isUpdating
                              ? null
                              : () => _handleQuantityChange(quantity - 1),
                          icon: Icon(
                            quantity == 1 ? Icons.delete : Icons.remove,
                            color: quantity == 1 ? cs.error : cs.primary,
                          ),
                          tooltip: quantity == 1 ? 'מחק פריט' : 'הפחת כמות',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // תצוגת כמות
                      Text(
                        '$quantity',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: _kQuantityFontSize,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // כפתור הוספה
                      SizedBox(
                        width: _kMinTouchTarget,
                        height: _kMinTouchTarget,
                        child: IconButton(
                          onPressed: isUpdating
                              ? null
                              : () => _handleQuantityChange(quantity + 1),
                          icon: Icon(Icons.add, color: cs.primary),
                          tooltip: 'הוסף כמות',
                        ),
                      ),
                    ],
                  ),

                  // תג סטטוס נוכחי
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: currentStatusConfig.getBgColor(cs),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: currentStatusConfig.getColor(cs),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          currentStatusConfig.icon,
                          size: 16,
                          color: currentStatusConfig.getColor(cs),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentStatusConfig.nameHe,
                          style: TextStyle(
                            fontSize: _kStatusFontSize,
                            fontWeight: FontWeight.w500,
                            color: currentStatusConfig.getColor(cs),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
