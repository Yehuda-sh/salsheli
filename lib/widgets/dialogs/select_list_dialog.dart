// 📄 File: lib/widgets/dialogs/select_list_dialog.dart
// 🎯 Purpose: דיאלוג בחירת רשימה להוספת פריט
//
// 📋 Features:
// - הצגת רשימות פעילות לבחירה
// - אפשרות ליצור רשימה חדשה
// - עיצוב sticky note
// - תמיכה בהוספה מהמזווה
//
// ✅ תיקונים:
//    - המרה ל-StatefulWidget עם _isProcessing flag
//    - תמיכה ב-Dark Mode (kStickyYellowDark)
//    - הוספת Semantics wrapper לדיאלוג ולפריטים
//    - הוספת Tooltips לכפתורים
//    - הוספת unawaited() לקריאות HapticFeedback
//    - החלפת Colors.* בצבעים מה-Theme
//
// 🔗 Related:
// - shopping_lists_provider.dart - ניהול רשימות
// - inventory_provider.dart - הוספה מהמזווה

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../theme/app_theme.dart';
import '../common/sticky_note.dart';

/// תוצאת הדיאלוג - רשימה שנבחרה או בקשה ליצירת רשימה חדשה
class SelectListResult {
  /// רשימה שנבחרה (null אם בחר ליצור חדשה)
  final ShoppingList? selectedList;

  /// האם המשתמש בחר ליצור רשימה חדשה
  final bool createNew;

  const SelectListResult({
    this.selectedList,
    this.createNew = false,
  });

  /// בחירת רשימה קיימת
  factory SelectListResult.selected(ShoppingList list) =>
      SelectListResult(selectedList: list);

  /// יצירת רשימה חדשה
  factory SelectListResult.newList() =>
      const SelectListResult(createNew: true);
}

/// מציג דיאלוג לבחירת רשימת קניות
///
/// Example:
/// ```dart
/// final result = await showSelectListDialog(
///   context: context,
///   title: 'הוסף לרשימה',
///   itemName: 'חלב',
/// );
///
/// if (result != null) {
///   if (result.createNew) {
///     // יצירת רשימה חדשה
///   } else if (result.selectedList != null) {
///     // הוספה לרשימה שנבחרה
///   }
/// }
/// ```
Future<SelectListResult?> showSelectListDialog({
  required BuildContext context,
  String title = 'בחר רשימה',
  String? itemName,
  String? subtitle,
}) async {
  return showDialog<SelectListResult>(
    context: context,
    builder: (context) => _SelectListDialog(
      title: title,
      itemName: itemName,
      subtitle: subtitle,
    ),
  );
}

class _SelectListDialog extends StatefulWidget {
  final String title;
  final String? itemName;
  final String? subtitle;

  const _SelectListDialog({
    required this.title,
    this.itemName,
    this.subtitle,
  });

  @override
  State<_SelectListDialog> createState() => _SelectListDialogState();
}

class _SelectListDialogState extends State<_SelectListDialog> {
  bool _isProcessing = false;

  /// בחירת רשימה
  void _selectList(ShoppingList list) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    unawaited(HapticFeedback.selectionClick());
    Navigator.of(context).pop(SelectListResult.selected(list));
  }

  /// יצירת רשימה חדשה
  void _createNewList() {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    unawaited(HapticFeedback.mediumImpact());
    Navigator.of(context).pop(SelectListResult.newList());
  }

  /// ביטול
  void _cancel() {
    if (_isProcessing) return;
    unawaited(HapticFeedback.lightImpact());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final isDark = theme.brightness == Brightness.dark;

    // ✅ צבעים מה-Theme + Dark Mode
    final stickyColor = isDark ? kStickyYellowDark : kStickyYellow;
    final successColor = brand?.success ?? scheme.primary;

    // ✅ Semantics label
    final dialogLabel = widget.itemName != null
        ? 'בחירת רשימה להוספת ${widget.itemName}'
        : 'בחירת רשימה';

    return Consumer<ShoppingListsProvider>(
      builder: (context, listsProvider, _) {
        final activeLists = listsProvider.activeLists;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Semantics(
            label: dialogLabel,
            container: true,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
                child: StickyNote(
                  color: stickyColor,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // === כותרת ===
                        Row(
                          children: [
                            Icon(Icons.playlist_add, color: scheme.primary),
                            const SizedBox(width: kSpacingSmall),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: kFontSizeLarge,
                                      fontWeight: FontWeight.bold,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  if (widget.itemName != null)
                                    Text(
                                      'מוסיף: ${widget.itemName}',
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

                        if (widget.subtitle != null) ...[
                          const SizedBox(height: kSpacingSmall),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        const SizedBox(height: kSpacingMedium),
                        const Divider(),

                        // === רשימת רשימות פעילות ===
                        if (listsProvider.isLoading)
                          Padding(
                            padding: const EdgeInsets.all(kSpacingLarge),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: scheme.primary,
                              ),
                            ),
                          )
                        else if (activeLists.isEmpty)
                          // אין רשימות - הצג הודעה
                          Padding(
                            padding: const EdgeInsets.all(kSpacingMedium),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  size: 48,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: kSpacingSmall),
                                Text(
                                  'אין רשימות פעילות',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: kSpacingSmall),
                                Text(
                                  'צור רשימה חדשה כדי להוסיף פריטים',
                                  style: TextStyle(
                                    fontSize: kFontSizeSmall,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          // רשימת רשימות
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: activeLists.length,
                              itemBuilder: (context, index) {
                                final list = activeLists[index];
                                return _ListTile(
                                  list: list,
                                  onTap: _isProcessing
                                      ? null
                                      : () => _selectList(list),
                                  successColor: successColor,
                                );
                              },
                            ),
                          ),

                        const Divider(),
                        const SizedBox(height: kSpacingSmall),

                        // === כפתור יצירת רשימה חדשה ===
                        Tooltip(
                          message: 'צור רשימת קניות חדשה',
                          child: OutlinedButton.icon(
                            onPressed: _isProcessing ? null : _createNewList,
                            icon: const Icon(Icons.add),
                            label: const Text('צור רשימה חדשה'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.primary,
                              side: BorderSide(color: scheme.primary),
                              padding: const EdgeInsets.symmetric(
                                vertical: kSpacingSmall,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: kSpacingSmall),

                        // === כפתור ביטול ===
                        Tooltip(
                          message: 'ביטול בחירת רשימה',
                          child: TextButton(
                            onPressed: _isProcessing ? null : _cancel,
                            child: Text(
                              'ביטול',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// כרטיס רשימה בחירה
///
/// ✅ תמיכה ב-onTap nullable + Semantics + צבעים מה-Theme
class _ListTile extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback? onTap;
  final Color successColor;

  const _ListTile({
    required this.list,
    required this.successColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final itemCount = list.items.length;
    final checkedCount = list.items.where((i) => i.isChecked).length;
    final isEnabled = onTap != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: '${list.name}, $itemCount פריטים${checkedCount > 0 ? ', $checkedCount סומנו' : ''}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: kSpacingTiny),
        color: list.stickyColor.withValues(alpha: isEnabled ? 0.3 : 0.15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingSmall),
            child: Row(
              children: [
                // אמוג'י סוג רשימה
                Container(
                  padding: const EdgeInsets.all(kSpacingSmall),
                  decoration: BoxDecoration(
                    color: list.stickyColor,
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                  child: Text(
                    list.typeEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),

                const SizedBox(width: kSpacingSmall),

                // שם הרשימה ומידע
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: kFontSizeMedium,
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            '$itemCount פריטים',
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (checkedCount > 0) ...[
                            Text(
                              ' ($checkedCount)',
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: successColor,
                              ),
                            ),
                            const Text(' '),
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: successColor,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // חץ
                Icon(
                  Icons.chevron_left,
                  color: isEnabled
                      ? scheme.onSurfaceVariant
                      : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
