// 📄 File: lib/screens/shopping/checklist/checklist_screen.dart
//
// 🎯 Purpose: מסך צ'קליסט פשוט - סימון V פשוט
//
// ✨ Features:
// - ✅ סימון פריטים פשוט (optimistic update)
// - 📊 מונה התקדמות
// - 🎨 עיצוב Sticky Note
// - ⚠️ אינדיקציית שגיאת סנכרון
//
// 🔗 Related:
// - unified_list_item.dart - מודל פריט
// - shopping_lists_provider.dart - עדכון סימון
//
// Version: 1.0
// Created: 16/12/2025

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/shopping_list.dart';
import '../../../models/unified_list_item.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../widgets/common/notebook_background.dart';

class ChecklistScreen extends StatefulWidget {
  final ShoppingList list;

  const ChecklistScreen({super.key, required this.list});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late ShoppingList _list;
  bool _hasSyncError = false;

  @override
  void initState() {
    super.initState();
    _list = widget.list;
  }

  /// סימון/ביטול סימון פריט
  Future<void> _toggleItem(UnifiedListItem item) async {
    unawaited(HapticFeedback.selectionClick());

    final newChecked = !item.isChecked;

    // עדכון מקומי מיידי (optimistic update)
    final updatedItem = item.copyWith(isChecked: newChecked);
    _updateLocalList(updatedItem);

    try {
      final provider = context.read<ShoppingListsProvider>();
      await provider.updateItemById(_list.id, updatedItem);

      // ✅ הצלחה - נקה שגיאת סנכרון
      if (_hasSyncError && mounted) {
        setState(() => _hasSyncError = false);
      }
    } catch (e) {
      debugPrint('❌ Error toggling item: $e');
      // החזר למצב הקודם
      _updateLocalList(item);
      if (mounted) {
        setState(() => _hasSyncError = true);
      }
    }
  }

  /// עדכון הרשימה המקומית
  void _updateLocalList(UnifiedListItem updatedItem) {
    final updatedItems = _list.items.map((item) {
      if (item.id == updatedItem.id) {
        return updatedItem;
      }
      return item;
    }).toList();

    setState(() {
      _list = _list.copyWith(items: updatedItems);
    });
  }

  /// סמן הכל / בטל הכל (optimistic update)
  Future<void> _toggleAll(bool checked) async {
    unawaited(HapticFeedback.mediumImpact());

    // 🔄 שמור מצב קודם ל-rollback
    final previousItems = List<UnifiedListItem>.from(_list.items);

    // ⚡ עדכון אופטימיסטי מיידי
    final updatedItems = _list.items.map((item) {
      return item.copyWith(isChecked: checked);
    }).toList();

    setState(() {
      _list = _list.copyWith(items: updatedItems);
    });

    try {
      final provider = context.read<ShoppingListsProvider>();
      await provider.toggleAllItemsChecked(_list.id, checked);

      // ✅ הצלחה - נקה שגיאת סנכרון
      if (_hasSyncError && mounted) {
        setState(() => _hasSyncError = false);
      }
    } catch (e) {
      debugPrint('❌ Error toggling all: $e');
      // ↩️ Rollback למצב הקודם
      if (mounted) {
        setState(() {
          _list = _list.copyWith(items: previousItems);
          _hasSyncError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // חשב סטטיסטיקות
    final totalItems = _list.items.length;
    final checkedItems = _list.items.where((i) => i.isChecked).length;
    final progress = totalItems > 0 ? checkedItems / totalItems : 0.0;
    final allChecked = totalItems > 0 && checkedItems == totalItems;

    return Stack(
      children: [
        const NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _list.name,
                  style: const TextStyle(
                      fontSize: kFontSizeMedium, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'צ\'קליסט ✓',
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            actions: [
              // ⚠️ אינדיקציית שגיאת סנכרון
              if (_hasSyncError)
                Tooltip(
                  message: AppStrings.common.syncError,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: kSpacingSmall),
                    child: Icon(Icons.cloud_off, color: Colors.amber, size: 20),
                  ),
                ),
              // כפתור סמן/בטל הכל
              PopupMenuButton<bool>(
                icon: const Icon(Icons.more_vert),
                onSelected: _toggleAll,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: true,
                    child: Row(
                      children: [
                        Icon(Icons.check_box, color: Colors.green),
                        SizedBox(width: kSpacingSmall),
                        Text('סמן הכל'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: false,
                    child: Row(
                      children: [
                        Icon(Icons.check_box_outline_blank, color: Colors.grey),
                        SizedBox(width: kSpacingSmall),
                        Text('בטל הכל'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // 📊 Header עם התקדמות
              Container(
                margin: const EdgeInsets.all(kSpacingMedium),
                padding: const EdgeInsets.all(kSpacingMedium),
                decoration: BoxDecoration(
                  color: kStickyYellow.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // מספרים
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$checkedItems',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: allChecked ? Colors.green : cs.primary,
                          ),
                        ),
                        Text(
                          ' / $totalItems',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (allChecked) ...[
                          const SizedBox(width: kSpacingSmall),
                          const Icon(Icons.celebration,
                              color: Colors.amber, size: 28),
                        ],
                      ],
                    ),

                    const SizedBox(height: kSpacingSmall),

                    // בר התקדמות
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          allChecked ? Colors.green : cs.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),

                    const SizedBox(height: kSpacingTiny),

                    // אחוזים
                    Text(
                      '${(progress * 100).toInt()}% הושלם',
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // 📋 רשימת פריטים
              Expanded(
                child: _list.items.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kSpacingMedium),
                        itemCount: _list.items.length,
                        itemBuilder: (context, index) {
                          final item = _list.items[index];
                          return KeyedSubtree(
                            key: ValueKey(item.id),
                            child: _ChecklistItemTile(
                              item: item,
                              onToggle: () => _toggleItem(item),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: פריט צ'קליסט
// ========================================

class _ChecklistItemTile extends StatelessWidget {
  final UnifiedListItem item;
  final VoidCallback onToggle;

  const _ChecklistItemTile({
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isChecked = item.isChecked;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(kBorderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(kSpacingMedium),
            decoration: BoxDecoration(
              color: isChecked
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(kBorderRadius),
              border: Border.all(
                color: isChecked
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox מונפש
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isChecked ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),

                const SizedBox(width: kSpacingMedium),

                // שם הפריט
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.w500,
                      decoration:
                          isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked
                          ? cs.onSurface.withValues(alpha: 0.5)
                          : cs.onSurface,
                    ),
                    child: Text(item.name),
                  ),
                ),

                // הערות אם יש
                if (item.notes != null && item.notes!.isNotEmpty)
                  Tooltip(
                    message: item.notes!,
                    child: Icon(
                      Icons.notes,
                      size: 18,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// Widget: Empty State
// ========================================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'הרשימה ריקה',
            style: TextStyle(
              fontSize: kFontSizeMedium,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'הוסף פריטים לצ\'קליסט',
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
