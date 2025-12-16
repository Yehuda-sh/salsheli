// 📄 File: lib/widgets/dialogs/select_list_dialog.dart
// 🎯 Purpose: דיאלוג בחירת רשימה להוספת פריט
//
// 📋 Features:
// - הצגת רשימות פעילות לבחירה
// - אפשרות ליצור רשימה חדשה
// - עיצוב sticky note
// - תמיכה בהוספה מהמזווה
//
// 🔗 Related:
// - shopping_lists_provider.dart - ניהול רשימות
// - inventory_provider.dart - הוספה מהמזווה
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
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

class _SelectListDialog extends StatelessWidget {
  final String title;
  final String? itemName;
  final String? subtitle;

  const _SelectListDialog({
    required this.title,
    this.itemName,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<ShoppingListsProvider>(
      builder: (context, listsProvider, _) {
        final activeLists = listsProvider.activeLists;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
              child: StickyNote(
                color: kStickyYellow,
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // === כותרת ===
                      Row(
                        children: [
                          Icon(Icons.playlist_add, color: cs.primary),
                          const SizedBox(width: kSpacingSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: kFontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (itemName != null)
                                  Text(
                                    'מוסיף: $itemName',
                                    style: TextStyle(
                                      fontSize: kFontSizeSmall,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (subtitle != null) ...[
                        const SizedBox(height: kSpacingSmall),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],

                      const SizedBox(height: kSpacingMedium),
                      const Divider(),

                      // === רשימת רשימות פעילות ===
                      if (listsProvider.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(kSpacingLarge),
                          child: Center(
                            child: CircularProgressIndicator(),
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
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: kSpacingSmall),
                              Text(
                                'אין רשימות פעילות',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: kSpacingSmall),
                              Text(
                                'צור רשימה חדשה כדי להוסיף פריטים',
                                style: TextStyle(
                                  fontSize: kFontSizeSmall,
                                  color: Colors.grey.shade500,
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
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  Navigator.of(context).pop(
                                    SelectListResult.selected(list),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                      const Divider(),
                      const SizedBox(height: kSpacingSmall),

                      // === כפתור יצירת רשימה חדשה ===
                      OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop(
                            SelectListResult.newList(),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('צור רשימה חדשה'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.primary,
                          side: BorderSide(color: cs.primary),
                          padding: const EdgeInsets.symmetric(
                            vertical: kSpacingSmall,
                          ),
                        ),
                      ),

                      const SizedBox(height: kSpacingSmall),

                      // === כפתור ביטול ===
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('ביטול'),
                      ),
                    ],
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
class _ListTile extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onTap;

  const _ListTile({
    required this.list,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final itemCount = list.items.length;
    final checkedCount = list.items.where((i) => i.isChecked).length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: kSpacingTiny),
      color: list.stickyColor.withValues(alpha: 0.3),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: kFontSizeMedium,
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
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (checkedCount > 0) ...[
                          Text(
                            ' ($checkedCount)',
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              color: Colors.green.shade600,
                            ),
                          ),
                          const Text(' '),
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.green.shade600,
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
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
