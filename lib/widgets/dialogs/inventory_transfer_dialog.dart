// 📄 lib/widgets/dialogs/inventory_transfer_dialog.dart
//
// דיאלוג לבחירת מה לעשות עם מזווה אישי בעת הצטרפות לקבוצה.
// 3 אפשרויות: העבר למזווה הקבוצה, מחק, או ביטול. כולל עיצוב sticky note.
//
// 🔗 Related: InventoryProvider, GroupsProvider, StickyNote

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    // ✅ צבעים מה-Theme
    final successColor = brand?.success ?? scheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: StickyNote(
            color: kStickyYellow,
            // ✅ SingleChildScrollView למניעת overflow
            child: SingleChildScrollView(
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
                          color: scheme.primaryContainer,
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
                            Text(
                              AppStrings.inventory.transferDialogTitle,
                              style: TextStyle(
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                            Text(
                              AppStrings.inventory.transferDialogItemCount(itemCount),
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: scheme.onSurfaceVariant,
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
                      color: scheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      AppStrings.inventory.transferDialogDescription(groupName, itemCount),
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        height: 1.4,
                        color: scheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: kSpacingLarge),

                  // === אפשרות 1: העברה ===
                  _OptionButton(
                    icon: Icons.move_to_inbox,
                    iconColor: successColor,
                    title: AppStrings.inventory.transferOptionTitle,
                    subtitle: AppStrings.inventory.transferOptionSubtitle,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop(InventoryTransferChoice.transfer);
                    },
                    isPrimary: true,
                    primaryColor: successColor,
                  ),

                  const SizedBox(height: kSpacingSmall),

                  // === אפשרות 2: מחיקה ===
                  _OptionButton(
                    icon: Icons.delete_outline,
                    iconColor: brand?.warning ?? scheme.tertiary,
                    title: AppStrings.inventory.deleteOptionTitle,
                    subtitle: AppStrings.inventory.deleteOptionSubtitle,
                    onTap: () => _handleDeleteOption(context, itemCount),
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === ביטול ===
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(InventoryTransferChoice.cancel);
                    },
                    child: Text(
                      AppStrings.inventory.cancelJoinOption,
                      style: TextStyle(color: scheme.onSurfaceVariant),
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

    final scheme = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final warningColor = brand?.warning ?? scheme.tertiary;

    // ✅ RTL בדיאלוג הפנימי
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: warningColor),
              const SizedBox(width: 8),
              Text(AppStrings.inventory.deleteConfirmTitle),
            ],
          ),
          content: Text(
            AppStrings.inventory.deleteConfirmMessage(itemCount),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppStrings.common.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              child: Text(AppStrings.inventory.deleteConfirmButton),
            ),
          ],
        ),
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
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: isPrimary
          ? (primaryColor ?? scheme.primary).withValues(alpha: 0.1)
          : scheme.surface.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          decoration: BoxDecoration(
            border: Border.all(
              color: isPrimary
                  ? (primaryColor ?? scheme.primary)
                  : scheme.outlineVariant,
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
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
