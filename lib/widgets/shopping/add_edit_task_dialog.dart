// 📄 lib/widgets/shopping/add_edit_task_dialog.dart
//
// דיאלוג הוספה/עריכה של משימה - שם, הערות, תאריך יעד ועדיפות.
// כולל validation, אנימציות fade+scale, haptic feedback ותמיכה בנגישות.
//
// 🔗 Related: UnifiedListItem, AppStrings, showGeneralDialog

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/unified_list_item.dart';

class AddEditTaskDialog extends StatefulWidget {
  final UnifiedListItem? item;
  final void Function(UnifiedListItem item) onSave;

  const AddEditTaskDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  DateTime? _selectedDueDate;
  String _selectedPriority = 'medium';
  bool _isSaving = false; // 🛡️ מניעת שמירה כפולה
  bool _hasChanges = false; // 🛡️ מעקב אחר שינויים לאישור יציאה

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _selectedDueDate = widget.item?.dueDate;
    _selectedPriority = widget.item?.priority ?? 'medium';

    // 🛡️ Track changes for exit confirmation
    _nameController.addListener(_markChanged);
    _notesController.addListener(_markChanged);

    if (kDebugMode) {
      debugPrint(
        widget.item == null
            ? '➕ AddEditTaskDialog: פתיחת דיאלוג הוספת משימה'
            : '✏️ AddEditTaskDialog: פתיחת דיאלוג עריכת "${widget.item!.name}"',
      );
    }
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    if (kDebugMode) {
      debugPrint('🗑️ AddEditTaskDialog: Controllers disposed');
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    unawaited(HapticFeedback.selectionClick());

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 🛡️ תיקון: אם יש תאריך ישן בעבר, מאפשרים firstDate מוקדם יותר
    // אחרת initialDate חייב להיות בטווח ו-Flutter יקרוס
    final hasOldDate = _selectedDueDate != null && _selectedDueDate!.isBefore(today);
    final firstDate = hasOldDate ? _selectedDueDate! : today;
    final initialDate = _selectedDueDate ?? today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      unawaited(HapticFeedback.lightImpact());
      setState(() {
        _selectedDueDate = picked;
        _hasChanges = true; // 🛡️ Track change
      });
    }
  }

  void _showErrorSnackBar(String message) {
    unawaited(HapticFeedback.heavyImpact());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: kSpacingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: StatusColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ✅ Exit confirmation when form has unsaved changes
  Future<bool> _confirmExit() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.common.unsavedChangesTitle),
        content: Text(AppStrings.common.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.common.stayHere),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.common.exitWithoutSaving),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleCancel() async {
    if (await _confirmExit()) {
      unawaited(HapticFeedback.lightImpact());
      if (kDebugMode) {
        debugPrint('❌ AddEditTaskDialog: ביטול דיאלוג');
      }
      if (mounted) Navigator.pop(context);
    }
  }

  void _handleSave() {
    // 🛡️ מניעת לחיצה כפולה
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();

    // ✅ Validation מלא
    if (name.isEmpty) {
      _showErrorSnackBar(AppStrings.listDetails.taskNameEmpty);
      return;
    }

    setState(() => _isSaving = true);

    // ✨ Haptic feedback להצלחה
    unawaited(HapticFeedback.mediumImpact());

    final newItem = UnifiedListItem.task(
      id: widget.item?.id ?? const Uuid().v4(),
      name: name,
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      notes: notes.isNotEmpty ? notes : null,
    );

    // ✅ Safe save with error handling
    try {
      widget.onSave(newItem);
      if (mounted) {
        Navigator.pop(context);
        if (kDebugMode) {
          debugPrint(
            widget.item == null
                ? '✅ AddEditTaskDialog: הוסף משימה "$name"'
                : '✅ AddEditTaskDialog: עדכן משימה "$name"',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showErrorSnackBar(AppStrings.common.saveFailed);
        if (kDebugMode) {
          debugPrint('❌ AddEditTaskDialog: שגיאה בשמירה: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      title: Text(
        widget.item == null
            ? AppStrings.listDetails.addTaskTitle
            : AppStrings.listDetails.editTaskTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.listDetails.taskNameLabel,
              ),
              textDirection: ui.TextDirection.rtl,
              textInputAction: TextInputAction.next,
              autofocus: true,
            ),
            const SizedBox(height: kSpacingSmall),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppStrings.listDetails.notesLabel,
              ),
              textDirection: ui.TextDirection.rtl,
              textInputAction: TextInputAction.done,
              maxLines: 3,
            ),
            const SizedBox(height: kSpacingMedium),
            // תאריך יעד
            Semantics(
              label: AppStrings.listDetails.dueDateLabel,
              button: true,
              child: ListTile(
                title: Text(
                  _selectedDueDate != null
                      ? AppStrings.listDetails.dueDateSelected(
                          DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
                        )
                      : AppStrings.listDetails.dueDateLabel,
                  style: TextStyle(
                    color: _selectedDueDate != null
                        ? StatusColors.getStatusColor('success', context)
                        : cs.onSurfaceVariant,
                  ),
                ),
                leading: Icon(Icons.calendar_today, color: cs.primary),
                onTap: _selectDate,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            // עדיפות
            DropdownButtonFormField<String>(
              initialValue: _selectedPriority,
              decoration: InputDecoration(
                labelText: AppStrings.listDetails.priorityLabel,
              ),
              items: [
                DropdownMenuItem(
                  value: 'low',
                  child: Text(AppStrings.listDetails.priorityLow),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text(AppStrings.listDetails.priorityMedium),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text(AppStrings.listDetails.priorityHigh),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  unawaited(HapticFeedback.selectionClick());
                  setState(() {
                    _selectedPriority = value;
                    _hasChanges = true; // 🛡️ Track change
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        Semantics(
          label: AppStrings.common.cancel,
          button: true,
          child: TextButton(
            // ✅ Use _handleCancel for exit confirmation
            onPressed: _handleCancel,
            child: Text(AppStrings.common.cancel),
          ),
        ),
        Semantics(
          label: AppStrings.common.save,
          button: true,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppStrings.common.save),
          ),
        ),
      ],
    );
  }
}

/// 🎬 פונקציית עזר להצגת הדיאלוג עם אנימציה
Future<void> showAddEditTaskDialog(
  BuildContext context, {
  UnifiedListItem? item,
  required void Function(UnifiedListItem item) onSave,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false, // 🛡️ מונע סגירה בטעות ואיבוד נתונים
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 200), // ignore: avoid_redundant_argument_values
    pageBuilder: (context, animation, secondaryAnimation) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: animation,
          child: AddEditTaskDialog(
            item: item,
            onSave: onSave,
          ),
        ),
      );
    },
  );
}
