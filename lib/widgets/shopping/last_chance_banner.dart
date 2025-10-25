// 📄 File: lib/widgets/shopping/last_chance_banner.dart
// Description: Last chance banner for active shopping - urgent suggestions
//
// ✅ Features:
// - Shows urgent suggestion during active shopping
// - Sticky Notes design (kStickyOrange - warning)
// - 2 actions: Add now, Ignore
// - Shows remaining suggestions count
// - Dismissible with animation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/smart_suggestion.dart';
import '../../models/unified_list_item.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/suggestions_provider.dart';

class LastChanceBanner extends StatelessWidget {
  final String listId;

  const LastChanceBanner({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionsProvider>(
      builder: (context, provider, child) {
        // Get current suggestion
        final suggestion = provider.currentSuggestion;

        // Don't show if no suggestions
        if (suggestion == null) {
          return const SizedBox.shrink();
        }

        // Only show urgent suggestions during shopping
        if (!suggestion.isUrgent) {
          return const SizedBox.shrink();
        }

        return _buildBanner(context, suggestion, provider);
      },
    );
  }

  Widget _buildBanner(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) {
    final remainingCount = provider.pendingSuggestionsCount - 1;

    return Container(
      margin: const EdgeInsets.all(kSpacingMedium),
      padding: const EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: kStickyOrange,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: kSpacingSmall),
              const Expanded(
                child: Text(
                  'רגע! שכחת משהו? 🛒',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (remainingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+$remainingCount נוספים',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),

          // Product info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Text(
                          'נותרו ${suggestion.currentStock} במלאי',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingMedium),

          // Actions
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _onAddPressed(context, suggestion, provider),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('הוסף עכשיו'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kStickyOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _onIgnorePressed(context, suggestion, provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('התעלם'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎬 Actions

  Future<void> _onAddPressed(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) async {
    try {
      // Get shopping lists provider
      final listsProvider = context.read<ShoppingListsProvider>();

      // Create unified item
      final item = UnifiedListItem.product(
        id: suggestion.id,
        name: suggestion.productName,
        quantity: suggestion.neededQuantity,
        unit: suggestion.category ?? "יח'",
        category: suggestion.category,
      );

      // Add to current list
      await listsProvider.addUnifiedItem(listId, item);

      // Mark suggestion as added
      await provider.addCurrentSuggestion();

      if (!context.mounted) return;

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('נוסף "${suggestion.productName}" לרשימה ✅'),
          backgroundColor: kStickyGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בהוספה: $e'),
          backgroundColor: kStickyPink,
        ),
      );
    }
  }

  Future<void> _onIgnorePressed(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) async {
    try {
      // Dismiss for this shopping session (1 day)
      await provider.dismissCurrentSuggestion(
        duration: const Duration(days: 1),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('התעלמתי מ-"${suggestion.productName}" 👍'),
          backgroundColor: kStickyCyan,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: kStickyPink,
        ),
      );
    }
  }
}
