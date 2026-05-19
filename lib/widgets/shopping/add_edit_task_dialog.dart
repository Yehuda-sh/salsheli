// lib/widgets/shopping/add_edit_task_dialog.dart — Add/edit task dialog — task form with name, notes, due date, priority

import 'dart:async';

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
import '../common/app_dialog.dart';
import '../common/sticky_button.dart';
import '../common/sticky_note.dart';

// Layout & validation tokens local to the dialog. Mirror the set in
// add_edit_product_dialog.dart so the two surfaces feel like one family.
const int _kMaxNameLength = 80;
const int _kCounterVisibleThreshold = 70;
const double _kStickyRotation = -0.01;
// Focus shadow tuning — kept inline because it's a single-purpose
// "subtle lift on focus" effect, not a reusable design token.
const double _kFocusShadowBlur = 8.0;
const Offset _kFocusShadowOffset = Offset(0, 2);
// Glassmorphic input fill — slightly translucent so the sticky-note
// background tint shows through.
const double _kInputFillAlpha = 0.55;
const double _kInputBorderAlpha = 0.5;
const double _kFocusedBorderWidth = 1.5;
// Entry animation stagger — each row appears 40ms after the previous.
const int _kStaggerStepMs = 40;
const Duration _kEntryAnimDuration = Duration(milliseconds: 300);

// Date-tile minimum height — matches a CTA-like row, not the smaller
// kMinTapTarget (44). The user reads a line of text here, so height
// should feel like a primary control.
const double _kDateTileMinHeight = kButtonHeight;

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

  // FocusNodes — per-node listeners so a Tab transition fires ONE haptic
  // (the gained-focus node), not two (gained + lost).
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

    _nameFocus = FocusNode()..addListener(() => _onFocusGained(_nameFocus));
    _notesFocus = FocusNode()..addListener(() => _onFocusGained(_notesFocus));

    _nameController.addListener(_markChanged);
    _notesController.addListener(_markChanged);
  }

  /// 📳 Haptic fires only when the given node *gains* focus (not loses).
  /// A Tab transition produces a single click, not two.
  void _onFocusGained(FocusNode node) {
    if (node.hasFocus) {
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
                      color: cs.primary.withValues(alpha: kOpacitySubtle),
                      blurRadius: _kFocusShadowBlur,
                      offset: _kFocusShadowOffset,
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
  // 📅 Date helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Today at 00:00 local time — used as the comparator for "today / tomorrow"
  /// labels and as the date-picker floor.
  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Friday this week. Weekday: Mon=1 ... Fri=5 ... Sun=7. If today is
  /// already past Friday (Sat/Sun) we roll to *next* Friday — "end of
  /// week" without a date is useless.
  DateTime _endOfWeek() {
    final today = _today();
    final weekday = today.weekday;
    final daysUntilFriday = (DateTime.friday - weekday + 7) % 7;
    final delta = daysUntilFriday == 0 ? 7 : daysUntilFriday;
    return today.add(Duration(days: delta));
  }

  /// Monday of next week — the "I'll deal with it after the weekend" bucket.
  DateTime _nextWeek() {
    final today = _today();
    final daysUntilMonday = (DateTime.monday - today.weekday + 7) % 7;
    final delta = daysUntilMonday == 0 ? 7 : daysUntilMonday;
    return today.add(Duration(days: delta));
  }

  /// Renders the selected due date as a short, human phrase:
  /// "היום" / "מחר" / "5/5/26". The full numeric form drops to two-digit
  /// year so it's narrower in the tile.
  String _formatDueDate(DateTime date) {
    final today = _today();
    if (_isSameDay(date, today)) {
      return AppStrings.listDetails.dueDateToday;
    }
    if (_isSameDay(date, today.add(const Duration(days: 1)))) {
      return AppStrings.listDetails.dueDateTomorrow;
    }
    return DateFormat('d/M/yy').format(date);
  }

  Future<void> _selectDate() async {
    unawaited(HapticFeedback.selectionClick());

    final today = _today();
    // 🛡️ If the existing date is already in the past, allow it as
    // firstDate so the picker doesn't throw an assertion.
    final hasOldDate = _selectedDueDate != null &&
        _selectedDueDate!.isBefore(today);
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
        _hasChanges = true;
      });
    }
  }

  void _setDueDate(DateTime date) {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _selectedDueDate = date;
      _hasChanges = true;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ❌ Error / Validation
  // ═══════════════════════════════════════════════════════════════════════════

  void _showErrorSnackBar(String message) {
    unawaited(HapticFeedback.heavyImpact());
    final cs = Theme.of(context).colorScheme;
    // removeCurrentSnackBar prevents stacking when the user retries
    // multiple times in a row.
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
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

    // 🩷 Pink sticky distinguishes tasks (pink) from products (yellow).
    final stickyColor = brand?.stickyPink ?? kStickyPink;

    final inputFillColor =
        cs.surfaceContainerHighest.withValues(alpha: _kInputFillAlpha);
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      borderSide: BorderSide(color: cs.primary, width: _kFocusedBorderWidth),
    );
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      borderSide:
          BorderSide(color: cs.outline.withValues(alpha: _kInputBorderAlpha)),
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
        // Hide the "0/80" counter — clutter on a dialog where users rarely
        // hit the cap. The cap still enforces.
        counterText: '',
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
          rotation: _kStickyRotation,
          padding: 0,
          // 🎨 RepaintBoundary isolates field animations from the screen below.
          child: RepaintBoundary(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🏷️ Title
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

                    // 📝 Task name. `textDirection` removed — Flutter auto-
                    // detects Hebrew vs Latin per content; the previous
                    // hardcoded RTL broke English entries. `onSubmitted`
                    // chains focus so the keyboard "next" arrow advances.
                    _withFocusShadow(
                      focusNode: _nameFocus,
                      child: TextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        autofocus: true,
                        maxLength: _kMaxNameLength,
                        // Counter only appears near the cap — clutter-free
                        // for short names.
                        buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                            currentLength >= _kCounterVisibleThreshold
                                ? Text(
                                    '$currentLength/$maxLength',
                                    style: TextStyle(
                                      fontSize: kFontSizeTiny,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  )
                                : null,
                        decoration: fieldDecoration(
                          label: AppStrings.listDetails.taskNameLabel,
                          icon: Icons.task_alt,
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _notesFocus.requestFocus(),
                      ),
                    ).animate().fadeIn(duration: _kEntryAnimDuration).slideX(begin: 0.05, end: 0),

                    const Gap(kSpacingSmall),

                    // 📄 Notes
                    _withFocusShadow(
                      focusNode: _notesFocus,
                      child: TextField(
                        controller: _notesController,
                        focusNode: _notesFocus,
                        decoration: fieldDecoration(
                          label: AppStrings.listDetails.notesLabel,
                          icon: Icons.notes,
                        ),
                        textInputAction: TextInputAction.done,
                        maxLines: 3,
                      ),
                    ).animate().fadeIn(duration: _kEntryAnimDuration, delay: const Duration(milliseconds: _kStaggerStepMs)).slideX(begin: 0.05, end: 0, delay: const Duration(milliseconds: _kStaggerStepMs)),

                    const Gap(kSpacingMedium),

                    // ⚡ Quick-pick chips — 80% of tasks fall into one of
                    // four buckets (today / tomorrow / end of week / next
                    // week). One tap beats opening a calendar picker.
                    _buildQuickPickRow(cs)
                        .animate()
                        .fadeIn(
                            duration: _kEntryAnimDuration,
                            delay: const Duration(
                                milliseconds: _kStaggerStepMs * 2))
                        .slideX(
                            begin: 0.05,
                            end: 0,
                            delay: const Duration(
                                milliseconds: _kStaggerStepMs * 2)),

                    const Gap(kSpacingXTiny),

                    // 📅 Calendar tile — kept as the "I need a specific
                    // date" escape hatch under the chips.
                    _buildDateTile(context, cs, inputFillColor)
                        .animate()
                        .fadeIn(
                            duration: _kEntryAnimDuration,
                            delay: const Duration(
                                milliseconds: _kStaggerStepMs * 3))
                        .slideX(
                            begin: 0.05,
                            end: 0,
                            delay: const Duration(
                                milliseconds: _kStaggerStepMs * 3)),

                    const Gap(kSpacingSmall),

                    // ⚡ Priority — single visual indicator (emoji in the
                    // string) rather than emoji + colored container which
                    // was double-encoding the same signal.
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPriority,
                      decoration: fieldDecoration(
                        label: AppStrings.listDetails.priorityLabel,
                        icon: Icons.flag_outlined,
                      ),
                      icon: Icon(
                        Icons.expand_more,
                        size: kIconSizeMedium,
                        color: cs.onSurface.withValues(alpha: kOpacityStrong),
                      ),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      dropdownColor: cs.surfaceContainer,
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
                            _hasChanges = true;
                          });
                        }
                      },
                    ).animate().fadeIn(duration: _kEntryAnimDuration, delay: const Duration(milliseconds: _kStaggerStepMs * 4)).slideX(begin: 0.05, end: 0, delay: const Duration(milliseconds: _kStaggerStepMs * 4)),

                    const Gap(kSpacingMedium),

                    // 🔘 Action buttons. StickyButton supplies its own
                    // Semantics — the outer Semantics wrappers used to
                    // cause a double-announce ("button cancel, button").
                    Row(
                      children: [
                        Expanded(
                          child: StickyButton(
                            label: AppStrings.common.cancel,
                            icon: Icons.close,
                            color: cs.surfaceContainerHighest,
                            onPressed: _handleCancel,
                          ),
                        ),
                        const Gap(kSpacingSmall),
                        Expanded(
                          child: StickyButton(
                            label: _isSaving
                                ? AppStrings.common.loading
                                : AppStrings.common.save,
                            icon: _isSaving ? Icons.hourglass_empty : Icons.check,
                            color: brand?.success ?? kStickyGreen,
                            onPressed: _isSaving ? null : _handleSave,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: _kEntryAnimDuration, delay: const Duration(milliseconds: _kStaggerStepMs * 5)).slideX(begin: 0.05, end: 0, delay: const Duration(milliseconds: _kStaggerStepMs * 5)),

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
  // 🚀 Quick-pick date chips
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickPickRow(ColorScheme cs) {
    final strings = AppStrings.listDetails;
    final today = _today();
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = _endOfWeek();
    final nextWeek = _nextWeek();

    final options = <_QuickPick>[
      _QuickPick(label: strings.dueChipToday, date: today),
      _QuickPick(label: strings.dueChipTomorrow, date: tomorrow),
      _QuickPick(label: strings.dueChipEndOfWeek, date: endOfWeek),
      _QuickPick(label: strings.dueChipNextWeek, date: nextWeek),
    ];

    return Wrap(
      spacing: kSpacingTiny,
      runSpacing: kSpacingTiny,
      children: [
        for (final opt in options)
          ChoiceChip(
            label: Text(
              opt.label,
              style: const TextStyle(fontSize: kFontSizeSmall),
            ),
            selected: _selectedDueDate != null &&
                _isSameDay(_selectedDueDate!, opt.date),
            onSelected: (_) => _setDueDate(opt.date),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📅 Glassmorphic Date Tile (escape hatch — pick any date)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDateTile(BuildContext context, ColorScheme cs, Color fillColor) {
    final hasDate = _selectedDueDate != null;
    final dateColor = hasDate
        ? StatusColors.getColor(StatusType.success, context)
        : cs.onSurfaceVariant;
    final dateText = hasDate
        ? AppStrings.listDetails
            .dueDateSelected(_formatDueDate(_selectedDueDate!))
        : AppStrings.listDetails.dueDateLabel;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: Container(
          constraints: const BoxConstraints(minHeight: _kDateTileMinHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingSmall,
            vertical: kSpacingSmall,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            border: Border.all(
              color: cs.outline.withValues(alpha: _kInputBorderAlpha),
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
                  constraints: const BoxConstraints(
                    minWidth: kMinTapTarget,
                    minHeight: kMinTapTarget,
                  ),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickPick {
  final String label;
  final DateTime date;
  const _QuickPick({required this.label, required this.date});
}

/// 🎬 Convenience wrapper that shows the dialog with the standard
/// `AppDialog` enter animation.
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
