// 📄 File: lib/widgets/home/smart_suggestions_card.dart
// Description: Smart suggestions carousel for home dashboard
//
// ✅ עדכון (26/10/2025) - Carousel UI:
// - PageView עם swipe ימינה/שמאלה
// - Dots indicator בתחתית
// - כרטיס ירוק, שם, מלאי, 3 כפתורים
// - Loading/Error/Empty states

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/shopping_list.dart';
import '../../models/smart_suggestion.dart';
import '../../models/unified_list_item.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/suggestions_provider.dart';

class SmartSuggestionsCard extends StatefulWidget {
  const SmartSuggestionsCard({super.key});

  @override
  State<SmartSuggestionsCard> createState() => _SmartSuggestionsCardState();
}

class _SmartSuggestionsCardState extends State<SmartSuggestionsCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// המרת urgency (string) לאמוג'י
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionsProvider>(
      builder: (context, provider, child) {
        // Loading state
        if (provider.isLoading) {
          return _buildLoadingCard(context);
        }

        // Error state
        if (provider.error != null) {
          return _buildErrorCard(context, provider.error!);
        }

        // Get all pending suggestions
        final suggestions = provider.suggestions.where((s) => s.isActive).toList();

        // Empty state
        if (suggestions.isEmpty) {
          return _buildEmptyCard(context);
        }

        // Content state - Carousel
        return Column(
          children: [
            // PageView
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: _pageController,
                itemCount: suggestions.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildSuggestionCard(
                    context,
                    suggestions[index],
                    provider,
                  );
                },
              ),
            ),
            // Dots indicator
            if (suggestions.length > 1) ...<Widget>[
              const SizedBox(height: kSpacingSmall),
              _buildDotsIndicator(suggestions.length),
            ],
          ],
        );
      },
    );
  }

  /// Dots indicator
  Widget _buildDotsIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? kStickyGreen : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // 🔄 Loading State
  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kSpacingMedium),
      padding: const EdgeInsets.all(kSpacingLarge),
      decoration: BoxDecoration(
        color: kStickyGreen.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: kStickyGreen),
          SizedBox(height: kSpacingMedium),
          Text('טוען המלצות...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // ❌ Error State
  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      margin: const EdgeInsets.all(kSpacingMedium),
      padding: const EdgeInsets.all(kSpacingLarge),
      decoration: BoxDecoration(
        color: kStickyPink.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: kStickyPink),
          const SizedBox(height: kSpacingMedium),
          const Text(
            'שגיאה בטעינת המלצות',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.grey),  
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kSpacingMedium),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SuggestionsProvider>().refreshSuggestions();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('נסה שוב'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kStickyGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 📭 Empty State
  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kSpacingMedium),
      padding: const EdgeInsets.all(kSpacingLarge),
      decoration: BoxDecoration(
        color: kStickyCyan.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 48, color: kStickyCyan),
          const SizedBox(height: kSpacingMedium),
          const Text(
            'המזווה מלא! 🎉',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'אין המלצות כרגע - כל המוצרים במלאי',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 💡 Suggestion Content
  Widget _buildSuggestionCard(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.all(kSpacingMedium),
      padding: const EdgeInsets.all(kSpacingLarge),
      decoration: BoxDecoration(
        color: kStickyGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                suggestion.isCriticallyLow ? Icons.warning_amber : Icons.lightbulb_outline,
                color: suggestion.isCriticallyLow ? kStickyOrange : Colors.white,
                size: 28,
              ),
              const SizedBox(width: kSpacingSmall),
              const Expanded(
                child: Text(
                  'המלצה חכמה',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Pending count badge
              if (provider.pendingSuggestionsCount > 1)
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
                    '+${provider.pendingSuggestionsCount - 1} נוספות',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: kSpacingMedium),

          // Product name
          Text(
            suggestion.productName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: kSpacingSmall),

          // Stock info
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: kSpacingSmall),
              Text(
                'במלאי: ${suggestion.currentStock} ${suggestion.unit}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(width: kSpacingMedium),
              Text(
                _getUrgencyEmoji(suggestion.urgency),
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),

          // Reason (if urgent)
          if (suggestion.isCriticallyLow) ...[
            const SizedBox(height: kSpacingSmall),
            Container(
              padding: const EdgeInsets.all(kSpacingSmall),
              decoration: BoxDecoration(
                color: kStickyOrange.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.priority_high, color: Colors.white, size: 16),
                  SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'דחוף - מלאי נמוך!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: kSpacingLarge),

          // Actions
          Row(
            children: [
              // Add button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onAddPressed(context, suggestion, provider),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('הוסף לרשימה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kStickyGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: kSpacingSmall),

              // Dismiss button
              IconButton(
                onPressed: () => _onDismissPressed(context, suggestion, provider),
                icon: const Icon(Icons.schedule),
                color: Colors.white70,
                tooltip: 'דחה לשבוע',
              ),

              // Delete button
              IconButton(
                onPressed: () => _onDeletePressed(context, suggestion, provider),
                icon: const Icon(Icons.delete_outline),
                color: Colors.white70,
                tooltip: 'מחק',
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

      // Get most recent list (or create "קניות כלליות")
      final lists = listsProvider.activeLists;
      ShoppingList? targetList;

      if (lists.isEmpty) {
        // TODO: Create default list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('אין רשימות פעילות - צור רשימה חדשה'),
            backgroundColor: kStickyOrange,
          ),
        );
        return;
      }

      targetList = lists.first;

      // Add to list
      final item = UnifiedListItem.product(
        id: suggestion.id,
        name: suggestion.productName,
        quantity: suggestion.quantityNeeded,
        unitPrice: 0.0,
        unit: suggestion.unit,
        category: suggestion.category,
      );

      await listsProvider.addUnifiedItem(targetList.id, item);

      // Mark suggestion as added
      await provider.addCurrentSuggestion(targetList.id);

      if (!context.mounted) return;

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('נוסף "${suggestion.productName}" לרשימה ✅'),
          backgroundColor: kStickyGreen,
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

  Future<void> _onDismissPressed(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) async {
    try {
      await provider.dismissCurrentSuggestion();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('דחיתי "${suggestion.productName}" לשבוע ⏰'),
          backgroundColor: kStickyCyan,
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

  Future<void> _onDeletePressed(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת המלצה'),
        content: Text('למחוק לצמיתות את "${suggestion.productName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kStickyPink),
            child: const Text('מחק'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await provider.deleteCurrentSuggestion(null);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('נמחק "${suggestion.productName}" 🗑️'),
          backgroundColor: kStickyPink,
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
