// 📄 File: lib/widgets/dialogs/inventory_transfer_dialog.dart
// 🎯 Purpose: דיאלוג לבחירת מה לעשות עם מזווה אישי בעת הצטרפות לקבוצה
//
// 📋 Features:
// - הצגת מספר פריטים במזווה האישי
// - 3 אפשרויות: העברה, מחיקה, ביטול
// - אנימציות ועיצוב sticky note
//
// 🔗 Related:
// - inventory_provider.dart - לוגיקת העברה/מחיקה
// - groups_provider.dart - הצטרפות לקבוצה
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../common/sticky_note.dart';

/// תוצאת הדיאלוג
enum InventoryTransferChoice {
  /// העבר את כל הפריטים לקבוצה
  transfer,

  /// מחק את כל הפריטים
  delete,

  /// ביטול - לא להצטרף לקבוצה
  cancel,
}

/// מציג דיאלוג לבחירת מה לעשות עם מזווה אישי בעת הצטרפות לקבוצה
///
/// Example:
/// ```dart
/// final choice = await showInventoryTransferDialog(
///   context: context,
///   itemCount: 15,
///   groupName: 'משפחת כהן',
/// );
///
/// switch (choice) {
///   case InventoryTransferChoice.transfer:
///     await inventoryProvider.transferToGroup(groupId);
///     break;
///   case InventoryTransferChoice.delete:
///     await inventoryProvider.deletePersonalInventory();
///     break;
///   case InventoryTransferChoice.cancel:
///     return; // לא מצטרף
/// }
/// ```
Future<InventoryTransferChoice?> showInventoryTransferDialog({
  required BuildContext context,
  required int itemCount,
  required String groupName,
}) {
  return showDialog<InventoryTransferChoice>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _InventoryTransferDialog(
      itemCount: itemCount,
      groupName: groupName,
    ),
  );
}

class _InventoryTransferDialog extends StatelessWidget {
  final int itemCount;
  final String groupName;

  const _InventoryTransferDialog({
    required this.itemCount,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: StickyNote(
            color: kStickyYellow,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // === כותרת ===
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: const Text(
                          '📦',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'המזווה שלך',
                              style: TextStyle(
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$itemCount פריטים',
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === הסבר ===
                  Container(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      'אתה מצטרף ל"$groupName" שיש לה מזווה משותף.\n'
                      'מה ברצונך לעשות עם $itemCount הפריטים במזווה האישי שלך?',
                      style: const TextStyle(
                        fontSize: kFontSizeMedium,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: kSpacingLarge),

                  // === אפשרות 1: העברה ===
                  _OptionButton(
                    icon: Icons.move_to_inbox,
                    iconColor: Colors.green,
                    title: 'העבר למזווה הקבוצה',
                    subtitle: 'כל הפריטים יועברו למזווה המשותף',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop(InventoryTransferChoice.transfer);
                    },
                    isPrimary: true,
                    primaryColor: cs.primary,
                  ),

                  const SizedBox(height: kSpacingSmall),

                  // === אפשרות 2: מחיקה ===
                  _OptionButton(
                    icon: Icons.delete_outline,
                    iconColor: Colors.orange,
                    title: 'מחק את המזווה האישי',
                    subtitle: 'התחל מחדש עם המזווה המשותף',
                    onTap: () => _handleDeleteOption(context, itemCount),
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === ביטול ===
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(InventoryTransferChoice.cancel);
                    },
                    child: const Text(
                      'ביטול - לא להצטרף',
                      style: TextStyle(color: Colors.black54),
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

  /// טיפול באפשרות מחיקה עם דיאלוג אישור
  void _handleDeleteOption(BuildContext context, int itemCount) async {
    await HapticFeedback.selectionClick();

    if (!context.mounted) return;

    // אישור נוסף למחיקה
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('אישור מחיקה'),
          ],
        ),
        content: Text(
          'האם אתה בטוח שברצונך למחוק $itemCount פריטים מהמזווה האישי?\n\nפעולה זו לא ניתנת לביטול.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('מחק הכל'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(InventoryTransferChoice.delete);
    }
  }
}

/// כפתור אפשרות בדיאלוג
class _OptionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color? primaryColor;

  const _OptionButton({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? (primaryColor ?? Colors.blue).withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          decoration: BoxDecoration(
            border: Border.all(
              color: isPrimary
                  ? (primaryColor ?? Colors.blue)
                  : Colors.grey.shade300,
              width: isPrimary ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
