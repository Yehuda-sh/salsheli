// 📄 File: lib/widgets/home/smart_suggestions_card.dart
// 🎯 Purpose: כרטיס המלצות חכמות במסך הבית
//
// ✅ עדכונים (12/10/2025):
// 1. השלמת תצוגת המלצות - 3 המלצות עליונות
// 2. כפתורי פעולה - הוספה לרשימה + הסרה
// 3. Logging מלא + Visual Feedback
// 4. Touch Targets 48x48 (Accessibility)
//
// ✅ עדכונים קודמים (08/10/2025):
// - Empty State משופר - CTA + הסבר מפורט
// - Elevation משופר
// - Visual hierarchy טוב יותר

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../models/suggestion.dart';
import '../../providers/suggestions_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../core/ui_constants.dart';

class SmartSuggestionsCard extends StatelessWidget {
  final ShoppingList? mostRecentList;
  static final Uuid _uuid = Uuid();

  const SmartSuggestionsCard({super.key, this.mostRecentList});

  Future<void> _handleAddToList(
    BuildContext context,
    Suggestion suggestion,
  ) async {
    debugPrint('➡️ SmartSuggestionsCard: מנסה להוסיף "${suggestion.productName}" לרשימה');
    
    final listsProvider = context.read<ShoppingListsProvider>();
    final list = mostRecentList;

    if (list == null) {
      debugPrint('⚠️ SmartSuggestionsCard: אין רשימה פעילה');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אין רשימה פעילה להוסיף אליה'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final newItem = ReceiptItem(
        id: _uuid.v4(),
        name: suggestion.productName,
        quantity: suggestion.suggestedQuantity,
      );

      await listsProvider.addItemToList(list.id, newItem);
      debugPrint('✅ SmartSuggestionsCard: הוסף "${suggestion.productName}" בהצלחה');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('נוסף "${suggestion.productName}" לרשימה'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ SmartSuggestionsCard: שגיאה בהוספה - $e');
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
    debugPrint('➖ SmartSuggestionsCard: מסיר המלצה $suggestionId');
    
    final suggestionsProvider = context.read<SuggestionsProvider>();
    suggestionsProvider.removeSuggestion(suggestionId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ההמלצה הוסרה'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    Navigator.pushNamed(context, '/shopping-lists');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Consumer<SuggestionsProvider>(
      builder: (context, suggestionsProvider, child) {
        // 1️⃣ Loading State
        if (suggestionsProvider.isLoading) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: cs.primary),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        'המלצות חכמות',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpacingMedium),
                  const CircularProgressIndicator(),
                  const SizedBox(height: kSpacingSmall),
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

        // 2️⃣ Empty State - משופר!
        if (suggestions.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // כותרת
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_outlined, color: cs.outline),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        'המלצות חכמות',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpacingMedium),

                  // אייקון מרכזי
                  Container(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      size: kSpacingLarge * 2, // 48px
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),

                  // כותרת משנה
                  Text(
                    'אין המלצות זמינות',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // הסבר מפורט
                  Text(
                    'צור רשימות קניות וסרוק קבלות\nכדי לקבל המלצות מותאמות אישית',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpacingMedium + kSpacingSmall),

                  // 🆕 כפתורי CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // כפתור ראשי
                      ElevatedButton.icon(
                        onPressed: () => _showCreateListDialog(context),
                        icon: const Icon(Icons.add, size: kIconSizeSmall),
                        label: const Text('צור רשימה'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primaryContainer,
                          foregroundColor: cs.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpacingMedium,
                            vertical: kSpacingSmallPlus,
                          ),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),

                      // כפתור משני
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/receipts');
                        },
                        icon: const Icon(
                          Icons.receipt_long,
                          size: kIconSizeSmall,
                        ),
                        label: const Text('סרוק קבלה'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpacingMedium,
                            vertical: kSpacingSmallPlus,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // 3️⃣ Content State - יש המלצות
        final topSuggestions = suggestions.take(3).toList();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          ),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // כותרת
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: cs.primary),
                    const SizedBox(width: kSpacingSmall),
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
                const SizedBox(height: kSpacingMedium),

                // 🆕 רשימת 3 ההמלצות העליונות
                ...topSuggestions.map((suggestion) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: kSpacingSmall),
                    padding: const EdgeInsets.all(kSpacingSmall),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                    child: Row(
                      children: [
                        // אייקון
                        Container(
                          padding: const EdgeInsets.all(kSpacingSmall),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_basket_outlined,
                            size: kIconSizeSmall,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: kSpacingSmall),

                        // פרטי המלצה
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion.productName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'כמות מוצעת: ${suggestion.suggestedQuantity}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // כפתורי פעולה
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // כפתור הוספה
                            IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: kIconSizeMedium,
                              ),
                              color: cs.primary,
                              onPressed: () => _handleAddToList(
                                context,
                                suggestion,
                              ),
                              tooltip: 'הוסף לרשימה',
                              constraints: const BoxConstraints(
                                minWidth: kMinTouchTarget,
                                minHeight: kMinTouchTarget,
                              ),
                            ),
                            // כפתור הסרה
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: kIconSizeSmall,
                              ),
                              color: cs.error,
                              onPressed: () => _handleRemove(
                                context,
                                suggestion.id,
                              ),
                              tooltip: 'הסר המלצה',
                              constraints: const BoxConstraints(
                                minWidth: kMinTouchTarget,
                                minHeight: kMinTouchTarget,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                // כפתור לכל ההמלצות
                if (suggestions.length > 3) ...[
                  const SizedBox(height: kSpacingSmall),
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
