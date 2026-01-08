// 📄 lib/screens/home/dashboard/widgets/suggestions_today_card.dart
//
// כרטיס "הצעות להיום" - מציג עד 3 הצעות חכמות עם כפתורי Add/Not now.
// גרסה פשוטה יותר מהקרוסלה - מציג הכל ברשימה אחת.
//
// Version: 1.0 (08/01/2026)
// 🔗 Related: SmartSuggestion, SuggestionsProvider

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../models/shopping_list.dart';
import '../../../../models/smart_suggestion.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/suggestions_provider.dart';

/// כרטיס הצעות להיום - עד 3 הצעות עם Add/Not now
class SuggestionsTodayCard extends StatelessWidget {
  const SuggestionsTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionsProvider>(
      builder: (context, provider, child) {
        // Loading state
        if (provider.isLoading) {
          return const _LoadingState();
        }

        // Get active suggestions (max 3)
        final suggestions = provider.suggestions
            .where((s) => s.isActive)
            .take(3)
            .toList();

        // Empty state - don't show card
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return _SuggestionsCard(suggestions: suggestions);
      },
    );
  }
}

/// Loading state
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: kStickyGreen.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kStickyGreen.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: kSpacingMedium),
            Text(
              'טוען הצעות...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main suggestions card
class _SuggestionsCard extends StatelessWidget {
  final List<SmartSuggestion> suggestions;

  const _SuggestionsCard({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // כותרת
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, size: 20, color: kStickyGreen),
            const SizedBox(width: 8),
            Text(
              'הצעות להיום',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: kStickyGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${suggestions.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: kStickyGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),

        // רשימת הצעות
        Card(
          elevation: 0,
          color: kStickyGreen.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: kStickyGreen.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              ...suggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                return Column(
                  children: [
                    _SuggestionItem(suggestion: suggestion),
                    if (index < suggestions.length - 1)
                      Divider(
                        height: 1,
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

/// פריט הצעה בודד
class _SuggestionItem extends StatefulWidget {
  final SmartSuggestion suggestion;

  const _SuggestionItem({required this.suggestion});

  @override
  State<_SuggestionItem> createState() => _SuggestionItemState();
}

class _SuggestionItemState extends State<_SuggestionItem> {
  bool _isProcessing = false;

  String _getUrgencyEmoji(String urgency) {
    switch (urgency) {
      case 'critical':
        return '🚨';
      case 'high':
        return '⚠️';
      case 'medium':
        return '⚡';
      case 'low':
        return 'ℹ️';
      default:
        return '💡';
    }
  }

  Future<void> _onAdd(BuildContext context) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final messenger = ScaffoldMessenger.of(context);
    final listsProvider = context.read<ShoppingListsProvider>();
    final suggestionsProvider = context.read<SuggestionsProvider>();

    try {
      // מצא רשימה פעילה (הראשונה)
      final activeLists = listsProvider.lists
          .where((l) => l.status == ShoppingList.statusActive)
          .toList();

      if (activeLists.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('אין רשימות פעילות - צור רשימה חדשה'),
            backgroundColor: kStickyOrange,
          ),
        );
        return;
      }

      final targetList = activeLists.first;
      final item = widget.suggestion.toUnifiedListItem();

      await listsProvider.addUnifiedItem(targetList.id, item);
      await suggestionsProvider.addSuggestionById(
        widget.suggestion.id,
        targetList.id,
      );

      if (!mounted) return;

      await HapticFeedback.lightImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Text('נוסף "${widget.suggestion.productName}" לרשימה'),
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
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onDismiss(BuildContext context) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final messenger = ScaffoldMessenger.of(context);
    final suggestionsProvider = context.read<SuggestionsProvider>();

    try {
      await suggestionsProvider.dismissSuggestionById(widget.suggestion.id);

      if (!mounted) return;

      await HapticFeedback.lightImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Text('דחיתי "${widget.suggestion.productName}" לשבוע'),
          backgroundColor: kStickyCyan,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: kStickyPink,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final suggestion = widget.suggestion;

    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: Row(
        children: [
          // אמוג'י דחיפות
          Text(
            _getUrgencyEmoji(suggestion.urgency),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: kSpacingSmall),

          // פרטי המוצר
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.productName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'במלאי: ${suggestion.currentStock} ${suggestion.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // כפתורי פעולה
          if (_isProcessing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // כפתור הוסף
                IconButton(
                  onPressed: () => _onAdd(context),
                  icon: const Icon(Icons.add_circle_outline),
                  color: kStickyGreen,
                  tooltip: 'הוסף לרשימה',
                  visualDensity: VisualDensity.compact,
                ),
                // כפתור לא עכשיו
                IconButton(
                  onPressed: () => _onDismiss(context),
                  icon: const Icon(Icons.schedule),
                  color: cs.onSurfaceVariant,
                  tooltip: 'לא עכשיו',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
