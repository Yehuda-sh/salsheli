// 📄 File: lib/widgets/home/smart_suggestions_card.dart
// תיאור: כרטיס המלצות חכמות במסך הבית - מחובר ל-SuggestionsProvider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../models/suggestion.dart';
import '../../providers/suggestions_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../actionable_recommendation.dart';

class SmartSuggestionsCard extends StatelessWidget {
  final ShoppingList? mostRecentList;
  static final Uuid _uuid = Uuid();

  const SmartSuggestionsCard({super.key, this.mostRecentList});

  Future<void> _handleAddToList(
    BuildContext context,
    Suggestion suggestion,
  ) async {
    final listsProvider = context.read<ShoppingListsProvider>();
    final list = mostRecentList;

    if (list == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אין רשימה פעילה להוסיף אליה'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // יצירת פריט חדש מההמלצה
      final newItem = ReceiptItem(
        id: _uuid.v4(),
        name: suggestion.productName,
        quantity: suggestion.suggestedQuantity,
      );

      // הוספה לרשימה
      await listsProvider.addItemToList(list.id, newItem);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בהוספה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleRemove(BuildContext context, String suggestionId) {
    final suggestionsProvider = context.read<SuggestionsProvider>();
    suggestionsProvider.removeSuggestion(suggestionId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Consumer<SuggestionsProvider>(
      builder: (context, suggestionsProvider, child) {
        if (suggestionsProvider.isLoading) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        'המלצות חכמות',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                  Text(
                    'מחשב המלצות...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final suggestions = suggestionsProvider.suggestions;

        if (suggestions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_outlined, color: cs.outline),
                      const SizedBox(width: 8),
                      Text(
                        'המלצות חכמות',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Icon(Icons.lightbulb_outline, size: 48, color: cs.outline),
                  const SizedBox(height: 8),
                  Text('אין המלצות כרגע', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    'הוסף פריטים למזווה או צור רשימות קניות',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // הצגת עד 3 המלצות בעדיפות גבוהה/בינונית
        final topSuggestions = suggestions.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // כותרת
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'המלצות חכמות',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (suggestions.length > 3)
                      Chip(
                        label: Text(
                          '+${suggestions.length - 3} נוספות',
                          style: theme.textTheme.labelSmall,
                        ),
                        backgroundColor: cs.secondaryContainer,
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // רשימת המלצות
                ...topSuggestions.map((suggestion) {
                  return ActionableRecommendation(
                    suggestion: suggestion,
                    onAddToList: () => _handleAddToList(context, suggestion),
                    onRemove: () => _handleRemove(context, suggestion.id),
                    showPantryButton: false,
                  );
                }),

                // כפתור לכל ההמלצות
                if (suggestions.length > 3) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('מסך המלצות מלא יתווסף בקרוב'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('צפה בכל ההמלצות'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
