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
// Version 2.0 - No AppBar (Immersive)
// Last Updated: 13/01/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/status_colors.dart';
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

  /// פריטים שנמצאים בעיבוד (מניעת race condition)
  final Set<String> _busyItems = {};

  /// האם מעבד toggleAll כרגע
  bool _isProcessingAll = false;

  @override
  void initState() {
    super.initState();
    _list = widget.list;
  }

  @override
  void didUpdateWidget(covariant ChecklistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // עדכון הרשימה אם ההורה שלח רשימה חדשה
    if (widget.list.id != oldWidget.list.id ||
        widget.list.updatedDate != oldWidget.list.updatedDate) {
      setState(() {
        _list = widget.list;
      });
    }
  }

  /// סימון/ביטול סימון פריט
  Future<void> _toggleItem(UnifiedListItem item) async {
    // 🛡️ מניעת race condition - אם הפריט או כל הרשימה בעיבוד, התעלם
    if (_busyItems.contains(item.id) || _isProcessingAll) {
      return;
    }

    unawaited(HapticFeedback.selectionClick());

    // סמן כעסוק
    _busyItems.add(item.id);

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
    } finally {
      // שחרר את הנעילה
      _busyItems.remove(item.id);
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

  /// הצגת Snackbar עם שגיאת סנכרון
  void _showSyncErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.common.syncError),
        backgroundColor: StatusColors.warning,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppStrings.checklist.gotItButton,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// סמן הכל / בטל הכל (optimistic update)
  Future<void> _toggleAll(bool checked) async {
    // 🛡️ מניעת התנגשויות - אם כבר מעבד או יש פריטים עסוקים
    if (_isProcessingAll || _busyItems.isNotEmpty) {
      return;
    }

    unawaited(HapticFeedback.mediumImpact());

    // נעל את כל הפעולות
    setState(() {
      _isProcessingAll = true;
    });

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
    } finally {
      // שחרר את הנעילה
      if (mounted) {
        setState(() {
          _isProcessingAll = false;
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
          body: SafeArea(
            child: Column(
              children: [
                // 🏷️ כותרת inline
                Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Row(
                    children: [
                      Icon(Icons.checklist, size: 24, color: cs.primary),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _list.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppStrings.checklist.subtitle,
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ⚠️ אינדיקציית שגיאת סנכרון - לחיץ להצגת הודעה
                      if (_hasSyncError)
                        IconButton(
                          icon: const Icon(Icons.cloud_off, color: StatusColors.warning, size: 20),
                          tooltip: AppStrings.common.syncError,
                          onPressed: _showSyncErrorSnackbar,
                        ),
                      // כפתור סמן/בטל הכל
                      PopupMenuButton<bool>(
                        icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                        onSelected: _toggleAll,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: true,
                            child: Row(
                              children: [
                                const Icon(Icons.check_box, color: StatusColors.success),
                                const SizedBox(width: kSpacingSmall),
                                Text(AppStrings.checklist.checkAll),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: false,
                            child: Row(
                              children: [
                                Icon(Icons.check_box_outline_blank, color: cs.onSurfaceVariant),
                                const SizedBox(width: kSpacingSmall),
                                Text(AppStrings.checklist.uncheckAll),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 📊 Header עם התקדמות
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
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
                              color: allChecked ? StatusColors.success : cs.primary,
                            ),
                          ),
                          Text(
                            ' / $totalItems',
                            style: TextStyle(
                              fontSize: 24,
                              color: cs.onSurfaceVariant,
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
                            allChecked ? StatusColors.success : cs.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),

                      const SizedBox(height: kSpacingTiny),

                      // אחוזים
                      Text(
                        AppStrings.checklist.percentComplete((progress * 100).toInt()),
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: cs.onSurfaceVariant,
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
                  ? StatusColors.success.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(kBorderRadius),
              border: Border.all(
                color: isChecked
                    ? StatusColors.success.withValues(alpha: 0.3)
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
                    color: isChecked ? StatusColors.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked ? StatusColors.success : Colors.grey,
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
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
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
            AppStrings.checklist.emptyTitle,
            style: TextStyle(
              fontSize: kFontSizeMedium,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            AppStrings.checklist.emptySubtitle,
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
