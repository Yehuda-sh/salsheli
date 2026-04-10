// 📄 File: lib/screens/shopping/create/template_preview_dialog.dart
//
// Purpose: דיאלוג תצוגה מקדימה של פריטי תבנית עם אפשרות לבחירה
//
// מאפשר למשתמש לסמן אילו פריטים מהתבנית להכניס לרשימה.
// כולל "בחר הכל" / "בטל הכל" + כפתור אישור עם מונה פריטים.
//
// Version: 1.0
// Last Updated: 09/04/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/unified_list_item.dart';
import '../../../services/template_service.dart';

/// דיאלוג תצוגה מקדימה של פריטי תבנית
///
/// מציג את כל הפריטים מהתבנית עם checkboxes.
/// המשתמש יכול לבחור אילו פריטים להכניס לרשימה.
/// מחזיר את הפריטים שנבחרו, או null אם בוטל.
class TemplatePreviewDialog extends StatefulWidget {
  final TemplateInfo template;
  final List<UnifiedListItem> items;

  const TemplatePreviewDialog({
    super.key,
    required this.template,
    required this.items,
  });

  @override
  State<TemplatePreviewDialog> createState() => _TemplatePreviewDialogState();
}

class _TemplatePreviewDialogState extends State<TemplatePreviewDialog> {
  late final List<bool> _selected;

  @override
  void initState() {
    super.initState();
    // כל הפריטים מסומנים כברירת מחדל
    _selected = List.filled(widget.items.length, true);
  }

  int get _selectedCount => _selected.where((s) => s).length;
  bool get _allSelected => _selected.every((s) => s);

  void _toggleAll() {
    unawaited(HapticFeedback.selectionClick());
    final newValue = !_allSelected;
    setState(() {
      for (var i = 0; i < _selected.length; i++) {
        _selected[i] = newValue;
      }
    });
  }

  void _toggleItem(int index) {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _selected[index] = !_selected[index]);
  }

  void _confirm() {
    unawaited(HapticFeedback.mediumImpact());
    final selectedItems = <UnifiedListItem>[];
    for (var i = 0; i < widget.items.length; i++) {
      if (_selected[i]) selectedItems.add(widget.items[i]);
    }
    Navigator.pop(context, selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.createListDialog;
    final total = widget.items.length;
    final selected = _selectedCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        // ── Header ──
        title: Row(
          children: [
            Text(
              widget.template.icon,
              style: const TextStyle(fontSize: kFontSizeTitle),
            ),
            const SizedBox(width: kSpacingSmall),
            Expanded(
              child: Text(
                widget.template.name,
                style: const TextStyle(
                  fontSize: kFontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        // ── Content ──
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Select All / Counter Row ──
              Row(
                children: [
                  // Select all / deselect all
                  TextButton.icon(
                    onPressed: _toggleAll,
                    icon: Icon(
                      _allSelected
                          ? Icons.deselect
                          : Icons.select_all,
                      size: kIconSizeSmallPlus,
                    ),
                    label: Text(
                      _allSelected
                          ? strings.previewDeselectAll
                          : strings.previewSelectAll,
                      style: const TextStyle(fontSize: kFontSizeSmall),
                    ),
                  ),
                  const Spacer(),
                  // Counter badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingSmallPlus,
                      vertical: kSpacingXTiny,
                    ),
                    decoration: BoxDecoration(
                      color: selected > 0
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      strings.previewItemsSelected(selected, total),
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        fontWeight: FontWeight.w600,
                        color: selected > 0
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: kSpacingSmall),

              // ── Items List ──
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = _selected[index];

                    return _TemplateItemTile(
                      item: item,
                      isSelected: isSelected,
                      onToggle: () => _toggleItem(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Actions ──
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancelButton),
          ),
          FilledButton.icon(
            onPressed: selected > 0 ? _confirm : null,
            icon: const Icon(Icons.check, size: kIconSizeSmallPlus),
            label: Text(
              strings.previewConfirmButton(selected),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Item Tile
// ═══════════════════════════════════════════════════════════════════

class _TemplateItemTile extends StatelessWidget {
  final UnifiedListItem item;
  final bool isSelected;
  final VoidCallback onToggle;

  const _TemplateItemTile({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isSelected ? 1.0 : 0.5,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: kSpacingTiny,
            horizontal: kSpacingXTiny,
          ),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: kIconSizeMediumPlus,
                height: kIconSizeMediumPlus,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: kSpacingSmall),

              // Item details
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: kFontSizeBody,
                    decoration: isSelected ? null : TextDecoration.lineThrough,
                    color: isSelected ? cs.onSurface : cs.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Quantity + Unit
              if (item.quantity != null)
                Text(
                  '${item.quantity} ${item.unit}',
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
