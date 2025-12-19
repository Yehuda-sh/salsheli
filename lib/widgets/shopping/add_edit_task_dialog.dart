// 📄 File: lib/widgets/shopping/add_edit_task_dialog.dart
// 🎯 דיאלוג הוספה/עריכה של משימה
//
// תכונות:
// - אנימציות fade + scale
// - DatePicker לתאריך יעד
// - Dropdown לעדיפות
// - Validation מלא
// - RTL Support
// - Controllers cleanup אוטומטי
// - Haptic Feedback
// - Semantics לנגישות

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _selectedDueDate = widget.item?.dueDate;
    _selectedPriority = widget.item?.priority ?? 'medium';

    if (kDebugMode) {
      debugPrint(
        widget.item == null
            ? '➕ AddEditTaskDialog: פתיחת דיאלוג הוספת משימה'
            : '✏️ AddEditTaskDialog: פתיחת דיאלוג עריכת "${widget.item!.name}"',
      );
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      unawaited(HapticFeedback.lightImpact());
      setState(() => _selectedDueDate = picked);
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

  void _handleSave() {
    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();

    // ✅ Validation מלא
    if (name.isEmpty) {
      _showErrorSnackBar(AppStrings.listDetails.taskNameEmpty);
      return;
    }

    // ✨ Haptic feedback להצלחה
    unawaited(HapticFeedback.mediumImpact());

    final newItem = UnifiedListItem.task(
      id: widget.item?.id ?? const Uuid().v4(),
      name: name,
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      notes: notes.isNotEmpty ? notes : null,
    );

    widget.onSave(newItem);
    Navigator.pop(context);

    if (kDebugMode) {
      debugPrint(
        widget.item == null
            ? '✅ AddEditTaskDialog: הוסף משימה "$name"'
            : '✅ AddEditTaskDialog: עדכן משימה "$name"',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ),
            const SizedBox(height: kSpacingSmall),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppStrings.listDetails.notesLabel,
              ),
              textDirection: ui.TextDirection.rtl,
              maxLines: 3,
            ),
            const SizedBox(height: kSpacingMedium),
            // תאריך יעד
            ListTile(
              title: Text(
                _selectedDueDate != null
                    ? AppStrings.listDetails.dueDateSelected(
                        DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
                      )
                    : AppStrings.listDetails.dueDateLabel,
                style: TextStyle(
                  color: _selectedDueDate != null ? Colors.green : Colors.grey,
                ),
              ),
              leading: const Icon(Icons.calendar_today),
              onTap: _selectDate,
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
                  setState(() => _selectedPriority = value);
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
            onPressed: () {
              unawaited(HapticFeedback.lightImpact());
              if (kDebugMode) {
                debugPrint('❌ AddEditTaskDialog: ביטול דיאלוג');
              }
              Navigator.pop(context);
            },
            child: Text(AppStrings.common.cancel),
          ),
        ),
        Semantics(
          label: AppStrings.common.save,
          button: true,
          child: ElevatedButton(
            onPressed: _handleSave,
            child: Text(AppStrings.common.save),
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
    barrierDismissible: true,
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
