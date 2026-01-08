// 📄 lib/screens/home/dashboard/widgets/quick_add_field.dart
//
// שדה הוספה מהירה - מאפשר להוסיף פריט לרשימה האחרונה במהירות.
// מופיע בדשבורד הראשי.
//
// Version: 1.0 (08/01/2026)
// 🔗 Related: ShoppingListsProvider, UnifiedListItem

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../models/shopping_list.dart';
import '../../../../models/unified_list_item.dart';
import '../../../../providers/shopping_lists_provider.dart';

/// שדה הוספה מהירה - מוסיף פריט לרשימה הפעילה האחרונה
class QuickAddField extends StatefulWidget {
  const QuickAddField({super.key});

  @override
  State<QuickAddField> createState() => _QuickAddFieldState();
}

class _QuickAddFieldState extends State<QuickAddField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isExpanded = _focusNode.hasFocus;
    });
  }

  Future<void> _onSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final messenger = ScaffoldMessenger.of(context);
    final listsProvider = context.read<ShoppingListsProvider>();

    try {
      // מצא רשימה פעילה
      final activeLists = listsProvider.lists
          .where((l) => l.status == ShoppingList.statusActive)
          .toList();

      if (activeLists.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('אין רשימות פעילות - צור רשימה חדשה'),
            backgroundColor: kStickyOrange,
            action: SnackBarAction(
              label: 'צור',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/create-list');
              },
            ),
          ),
        );
        return;
      }

      final targetList = activeLists.first;

      // יצירת פריט חדש
      final item = UnifiedListItem.product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: text,
        quantity: 1,
        unitPrice: 0,
        unit: 'יח\'',
        category: 'כללי',
      );

      await listsProvider.addUnifiedItem(targetList.id, item);

      if (!mounted) return;

      // נקה את השדה
      _controller.clear();
      _focusNode.unfocus();

      await HapticFeedback.lightImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Text('נוסף "$text" ל"${targetList.name}"'),
          backgroundColor: kStickyGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('שגיאה בהוספה: $e'),
          backgroundColor: kStickyPink,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final listsProvider = context.watch<ShoppingListsProvider>();

    // מצא רשימה פעילה להצגת שם
    final activeLists = listsProvider.lists
        .where((l) => l.status == ShoppingList.statusActive)
        .toList();

    final hasActiveList = activeLists.isNotEmpty;
    final targetListName = hasActiveList ? activeLists.first.name : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _isExpanded
                ? cs.primary.withValues(alpha: 0.5)
                : cs.outline.withValues(alpha: 0.2),
            width: _isExpanded ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingMedium,
            vertical: kSpacingSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // שדה הקלט
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: _isExpanded ? cs.primary : cs.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: hasActiveList,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: hasActiveList
                            ? 'הוסף פריט מהיר...'
                            : 'צור רשימה להוספת פריטים',
                        hintStyle: TextStyle(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: theme.textTheme.bodyLarge,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onSubmit(),
                    ),
                  ),
                  if (_isSubmitting)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_controller.text.isNotEmpty && _isExpanded)
                    IconButton(
                      onPressed: _onSubmit,
                      icon: const Icon(Icons.send),
                      color: cs.primary,
                      tooltip: 'הוסף',
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),

              // הצג לאיזו רשימה יתווסף (כשמורחב)
              if (_isExpanded && targetListName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 32), // offset for icon
                    Icon(
                      Icons.arrow_back,
                      size: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'יתווסף ל"$targetListName"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
