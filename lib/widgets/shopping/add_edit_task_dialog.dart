// 📄 lib/widgets/shopping/add_edit_task_dialog.dart
//
// דיאלוג הוספה/עריכה של משימה - שם, הערות, תאריך יעד ועדיפות.
// כולל validation, אנימציות, haptic feedback ותמיכה בנגישות.
//
// Features:
//   - עיצוב Sticky Note פיזי (ורוד - מובחן ממוצרים)
//   - אנימציית שדות מדורגת (Staggered)
//   - ניהול Focus Shadows
//   - חתימות Haptic מותאמות
//
// ✅ אבטחות:
//    - מניעת שמירה כפולה (_isSaving flag)
//    - אישור יציאה כשיש שינויים לא שמורים
//    - firstDate מותאם לתאריכי עבר (מניעת קריסה)
//
// 🔗 Related: UnifiedListItem, StickyNote, StickyButton, AppBrand

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/unified_list_item.dart';
import '../../theme/app_theme.dart';
import '../common/sticky_button.dart';
import '../common/app_dialog.dart';
import '../common/sticky_note.dart';

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

  // FocusNodes — Focus Shadow + haptic מעבר שדות
  late final FocusNode _nameFocus;
  late final FocusNode _notesFocus;

  DateTime? _selectedDueDate;
  String _selectedPriority = 'medium';
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _selectedDueDate = widget.item?.dueDate;
    _selectedPriority = widget.item?.priority ?? 'medium';

    _nameFocus = FocusNode()..addListener(_onFocusChange);
    _notesFocus = FocusNode()..addListener(_onFocusChange);

    _nameController.addListener(_markChanged);
    _notesController.addListener(_markChanged);
  }

  /// 📳 Haptic: selectionClick במעבר בין שדות
  void _onFocusChange() {
    if (_nameFocus.hasFocus || _notesFocus.hasFocus) {
      unawaited(HapticFeedback.selectionClick());
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
    _nameFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 Focus Shadow Wrapper
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _withFocusShadow({required Widget child, required FocusNode focusNode}) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: focusNode.hasFocus
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: child,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📅 Date Picker
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _selectDate() async {
    unawaited(HapticFeedback.selectionClick());

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 🛡️ אם יש תאריך ישן בעבר - firstDate מוקדם יותר למניעת קריסה
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
      // 📳 Haptic: lightImpact לבחירת תאריך
      unawaited(HapticFeedback.lightImpact());
      setState(() {
        _selectedDueDate = picked;
        _hasChanges = true;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ❌ Error / Validation
  // ═══════════════════════════════════════════════════════════════════════════

  void _showErrorSnackBar(String message) {
    // 📳 Haptic: heavyImpact לשגיאה
    unawaited(HapticFeedback.heavyImpact());
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: cs.onError),
            const Gap(kSpacingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: cs.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚪 Exit Confirmation
  // ═══════════════════════════════════════════════════════════════════════════

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

  Future<void> _handleCancel() async {
    if (await _confirmExit()) {
      unawaited(HapticFeedback.lightImpact());
      if (mounted) Navigator.pop(context);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 Save
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleSave() {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackBar(AppStrings.listDetails.taskNameEmpty);
      return;
    }

    setState(() => _isSaving = true);

    // 📳 Haptic: mediumImpact לשמירה מוצלחת
    unawaited(HapticFeedback.mediumImpact());

    final newItem = UnifiedListItem.task(
      id: widget.item?.id ?? const Uuid().v4(),
      name: name,
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      notes: notes.isNotEmpty ? notes : null,
    );

    try {
      widget.onSave(newItem);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showErrorSnackBar(AppStrings.common.saveFailed);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ Build
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final isEditMode = widget.item != null;

    // 🩷 ורוד — מבחין משימות ממוצרים (צהוב)
    final stickyColor = brand?.stickyPink ?? kStickyPink;

    // Glassmorphic fill
    final inputFillColor = cs.surfaceContainerHighest.withValues(alpha: 0.55);
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      borderSide: BorderSide(color: cs.primary, width: 1.5),
    );
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
    );

    InputDecoration fieldDecoration({required String label, required IconData icon}) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: focusedBorder,
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kSpacingSmall,
          vertical: kSpacingSmallPlus,
        ),
      );
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final shouldExit = await _confirmExit();
        if (shouldExit && mounted) nav.pop();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(kSpacingMedium),
        child: StickyNote(
        color: stickyColor,
        rotation: -0.01,
        padding: 0,
        // 🎨 RepaintBoundary — מבודד אנימציות שדות ממסך שמתחת
        child: RepaintBoundary(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🏷️ כותרת
                  Row(
                    children: [
                      Icon(
                        isEditMode ? Icons.edit_note : Icons.add_task,
                        color: cs.primary,
                        size: kIconSizeLarge,
                      ),
                      const Gap(kSpacingSmall),
                      Text(
                        isEditMode
                            ? AppStrings.listDetails.editTaskTitle
                            : AppStrings.listDetails.addTaskTitle,
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const Gap(kSpacingMedium),
                  const Divider(),
                  const Gap(kSpacingSmall),

                  // 📝 שם המשימה
                  _withFocusShadow(
                    focusNode: _nameFocus,
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      autofocus: true,
                      decoration: fieldDecoration(
                        label: AppStrings.listDetails.taskNameLabel,
                        icon: Icons.task_alt,
                      ),
                      textDirection: ui.TextDirection.rtl,
                      textInputAction: TextInputAction.next,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0),

                  const Gap(kSpacingSmall),

                  // 📄 הערות
                  _withFocusShadow(
                    focusNode: _notesFocus,
                    child: TextField(
                      controller: _notesController,
                      focusNode: _notesFocus,
                      decoration: fieldDecoration(
                        label: AppStrings.listDetails.notesLabel,
                        icon: Icons.notes,
                      ),
                      textDirection: ui.TextDirection.rtl,
                      textInputAction: TextInputAction.done,
                      maxLines: 3,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideX(begin: 0.05, end: 0, delay: 50.ms),

                  const Gap(kSpacingMedium),

                  // 📅 בחירת תאריך — Glassmorphic tile
                  _buildDateTile(context, cs, inputFillColor)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideX(begin: 0.05, end: 0, delay: 100.ms),

                  const Gap(kSpacingSmall),

                  // ⚡ עדיפות — Dropdown עם אימוג'י
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPriority,
                    decoration: fieldDecoration(
                      label: AppStrings.listDetails.priorityLabel,
                      icon: Icons.flag_outlined,
                    ),
                    icon: Icon(
                      Icons.expand_more,
                      size: kIconSizeMedium,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    dropdownColor: cs.surfaceContainer,
                    items: [
                      DropdownMenuItem(
                        value: 'low',
                        child: Row(
                          children: [
                            Container(
                              width: kIconSizeSmall,
                              height: kIconSizeSmall,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: kSpacingSmall),
                            Text(AppStrings.listDetails.priorityLow),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Row(
                          children: [
                            Container(
                              width: kIconSizeSmall,
                              height: kIconSizeSmall,
                              decoration: BoxDecoration(
                                color: cs.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: kSpacingSmall),
                            Text(AppStrings.listDetails.priorityMedium),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'high',
                        child: Row(
                          children: [
                            Container(
                              width: kIconSizeSmall,
                              height: kIconSizeSmall,
                              decoration: BoxDecoration(
                                color: cs.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: kSpacingSmall),
                            Text(AppStrings.listDetails.priorityHigh),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        unawaited(HapticFeedback.selectionClick());
                        setState(() {
                          _selectedPriority = value;
                          _hasChanges = true;
                        });
                      }
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideX(begin: 0.05, end: 0, delay: 150.ms),

                  const Gap(kSpacingMedium),

                  // 🔘 כפתורי פעולה
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: AppStrings.common.cancel,
                          button: true,
                          child: StickyButton(
                            label: AppStrings.common.cancel,
                            icon: Icons.close,
                            color: cs.surfaceContainerHighest,
                            onPressed: _handleCancel,
                          ),
                        ),
                      ),
                      const Gap(kSpacingSmall),
                      Expanded(
                        child: Semantics(
                          label: AppStrings.common.save,
                          button: true,
                          child: StickyButton(
                            label: _isSaving
                                ? AppStrings.common.loading
                                : AppStrings.common.save,
                            icon: _isSaving ? Icons.hourglass_empty : Icons.check,
                            color: brand?.success ?? const Color(0xFF388E3C),
                            onPressed: _isSaving ? null : _handleSave,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: 0.05, end: 0, delay: 200.ms),

                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom > 0
                        ? kSpacingMedium
                        : 0,
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📅 Glassmorphic Date Tile
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDateTile(BuildContext context, ColorScheme cs, Color fillColor) {
    final hasDate = _selectedDueDate != null;
    final dateColor = hasDate
        ? StatusColors.getColor(StatusType.success, context)
        : cs.onSurfaceVariant;
    final dateText = hasDate
        ? AppStrings.listDetails.dueDateSelected(
            DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
          )
        : AppStrings.listDetails.dueDateLabel;

    return Semantics(
      label: AppStrings.listDetails.dueDateLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmall,
              vertical: kSpacingSmall,
            ),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              border: Border.all(
                color: cs.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: cs.primary, size: kIconSizeMedium),
                const Gap(kSpacingSmall),
                Expanded(
                  child: Text(
                    dateText,
                    style: TextStyle(color: dateColor, fontSize: kFontSizeMedium),
                  ),
                ),
                if (hasDate)
                  IconButton(
                    onPressed: () {
                      unawaited(HapticFeedback.selectionClick());
                      setState(() {
                        _selectedDueDate = null;
                        _hasChanges = true;
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      size: kIconSizeSmall,
                      color: cs.onSurfaceVariant,
                    ),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎬 פונקציית עזר להצגת הדיאלוג עם אנימציה
Future<void> showAddEditTaskDialog(
  BuildContext context, {
  UnifiedListItem? item,
  required void Function(UnifiedListItem item) onSave,
}) {
  return AppDialog.show(
    context: context,
    child: AddEditTaskDialog(
      item: item,
      onSave: onSave,
    ),
  );
}
