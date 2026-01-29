// 📄 lib/screens/home/dashboard/widgets/smart_suggestions_card.dart
//
// קרוסלת המלצות חכמות בדשבורד - מציג מוצרים שכדאי לקנות.
// כולל PageView עם swipe, dots indicator, ו-3 כפתורים (הוסף/דחה/מחק).
//
// ✅ Features:
//    - Theme-aware colors (Dark Mode support)
//    - Accessibility labels (Semantics)
//    - Optimized with RepaintBoundary
//    - Double-tap protection (_isProcessing)
//    - Hebrew RTL support
//
// 🔗 Related: SmartSuggestion, SuggestionsProvider
//
// ----------------------------------------------------------------------------
// The SmartSuggestionsCard widget displays product recommendations carousel.
// Appears on the Home Dashboard with swipe navigation and action buttons.
//
// Features:
// • PageView with smooth swipe navigation
// • Dots indicator for pagination
// • Add/Dismiss/Delete actions
// • Theme-aware with Dark Mode support
// • Accessibility with Semantics labels
// ----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/enums/suggestion_status.dart';
import '../../../../models/shopping_list.dart';
import '../../../../models/smart_suggestion.dart';
import '../../../../models/unified_list_item.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/suggestions_provider.dart';

class SmartSuggestionsCard extends StatefulWidget {
  const SmartSuggestionsCard({super.key});

  @override
  State<SmartSuggestionsCard> createState() => _SmartSuggestionsCardState();
}

class _SmartSuggestionsCardState extends State<SmartSuggestionsCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isProcessing = false;

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
              _buildDotsIndicator(context, suggestions.length),
            ],
          ],
        );
      },
    );
  }

  /// Dots indicator
  Widget _buildDotsIndicator(BuildContext context, int count) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.smartSuggestions;

    return Semantics(
      label: strings.pageIndicator(_currentPage + 1, count),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              // ✅ Theme-aware colors
              color: isActive ? kStickyGreen : cs.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // 🔄 Loading State
  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.smartSuggestions;

    return Semantics(
      label: strings.loadingLabel,
      child: Container(
        margin: const EdgeInsets.all(kSpacingMedium),
        padding: const EdgeInsets.all(kSpacingLarge),
        decoration: BoxDecoration(
          color: kStickyGreen.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ✅ Theme-aware shadow
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(color: kStickyGreen),
            const SizedBox(height: kSpacingMedium),
            Text(
              strings.loadingMessage,
              style: TextStyle(fontSize: 16, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  // ❌ Error State
  Widget _buildErrorCard(BuildContext context, String error) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.smartSuggestions;

    return Semantics(
      label: strings.errorLabel(error),
      child: Container(
        margin: const EdgeInsets.all(kSpacingMedium),
        padding: const EdgeInsets.all(kSpacingLarge),
        decoration: BoxDecoration(
          color: kStickyPink.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ✅ Theme-aware shadow
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: kStickyPink),
            const SizedBox(height: kSpacingMedium),
            Text(
              strings.errorTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              error,
              // ✅ Theme-aware secondary text
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingMedium),
            Tooltip(
              message: strings.retryTooltip,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<SuggestionsProvider>().refreshSuggestions();
                },
                icon: const Icon(Icons.refresh),
                label: Text(strings.retryButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kStickyGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📭 Empty State
  Widget _buildEmptyCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.smartSuggestions;

    return Semantics(
      label: strings.emptyLabel,
      child: Container(
        margin: const EdgeInsets.all(kSpacingMedium),
        padding: const EdgeInsets.all(kSpacingLarge),
        decoration: BoxDecoration(
          color: kStickyCyan.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ✅ Theme-aware shadow
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, size: 48, color: kStickyCyan),
            const SizedBox(height: kSpacingMedium),
            Text(
              strings.emptyTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              strings.emptySubtitle,
              // ✅ Theme-aware secondary text
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 💡 Suggestion Content
  Widget _buildSuggestionCard(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) {
    final theme = Theme.of(context);
    final strings = AppStrings.smartSuggestions;
    final inventoryStrings = AppStrings.inventory;
    final isUnknownStatus = suggestion.status == SuggestionStatus.unknown;

    // ✅ Semantics עם תיאור טבעי בעברית
    return Semantics(
      label: strings.suggestionLabel(
        suggestion.productName,
        suggestion.currentStock,
        suggestion.unit,
      ),
      child: RepaintBoundary(
        child: Container(
          margin: const EdgeInsets.all(kSpacingMedium),
          padding: const EdgeInsets.all(kSpacingLarge),
          decoration: BoxDecoration(
            // ⚠️ Grey color for unknown status
            color: isUnknownStatus ? Colors.grey.shade400 : kStickyGreen,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ✅ Theme-aware shadow
                color: theme.shadowColor.withValues(alpha: 0.15),
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
                  Expanded(
                    child: Text(
                      strings.cardTitle,
                      style: const TextStyle(
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
                        strings.moreSuggestions(provider.pendingSuggestionsCount - 1),
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
                    strings.stockInfo(suggestion.currentStock, suggestion.unit),
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
                  child: Row(
                    children: [
                      const Icon(Icons.priority_high, color: Colors.white, size: 16),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Text(
                          strings.urgentWarning,
                          style: const TextStyle(
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

              // ⚠️ Warning banner for unknown status
              if (isUnknownStatus) ...[
                Container(
                  padding: const EdgeInsets.all(kSpacingSmall),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.white, size: 16),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Text(
                          inventoryStrings.unknownSuggestionWarning,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: kSpacingSmall),
              ],

              // Actions
              if (!_isProcessing)
                Row(
                  children: [
                    // ✅ Add button עם Tooltip (always enabled - safe operation)
                    Expanded(
                      child: Tooltip(
                        message: strings.addTooltip(suggestion.productName),
                        child: ElevatedButton.icon(
                          onPressed: () => _onAddPressed(context, suggestion, provider),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: Text(strings.addButton),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: isUnknownStatus ? Colors.grey : kStickyGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),

                    // Dismiss button - disabled for unknown
                    IconButton(
                      onPressed: isUnknownStatus
                          ? null
                          : () => _onDismissPressed(context, suggestion, provider),
                      icon: const Icon(Icons.schedule),
                      color: Colors.white70,
                      disabledColor: Colors.white30,
                      tooltip: isUnknownStatus
                          ? inventoryStrings.unknownSuggestionCannotDelete
                          : strings.dismissTooltip,
                    ),

                    // Delete button - disabled for unknown
                    IconButton(
                      onPressed: isUnknownStatus
                          ? null
                          : () => _onDeletePressed(context, suggestion, provider),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.white70,
                      disabledColor: Colors.white30,
                      tooltip: isUnknownStatus
                          ? inventoryStrings.unknownSuggestionCannotDelete
                          : strings.deleteTooltip,
                    ),
                  ],
                ),

              // ✅ Loading indicator בזמן עיבוד
              if (_isProcessing)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(kSpacingSmall),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎬 Actions

  Future<void> _onAddPressed(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) async {
    // ✅ מניעת לחיצה כפולה
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // ✅ Capture messenger and strings before await
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.smartSuggestions;

    try {
      // Get shopping lists provider
      final listsProvider = context.read<ShoppingListsProvider>();

      // Get most recent list (or create "קניות כלליות")
      final lists = listsProvider.activeLists;
      ShoppingList? targetList;

      if (lists.isEmpty) {
        // TODO: Create default list
        messenger.showSnackBar(
          SnackBar(
            content: Text(strings.noActiveListMessage),
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

      if (!mounted) return;

      // Show success
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.addedSuccess(suggestion.productName)),
          backgroundColor: kStickyGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.addError),
          backgroundColor: kStickyPink,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onDismissPressed(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) async {
    // ✅ מניעת לחיצה כפולה
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // ✅ Capture messenger and strings before await
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.smartSuggestions;

    try {
      await provider.dismissCurrentSuggestion();

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.dismissedSuccess(suggestion.productName)),
          backgroundColor: kStickyCyan,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.genericError),
          backgroundColor: kStickyPink,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onDeletePressed(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider provider,
  ) async {
    // ✅ Capture messenger and strings before any async operations
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.smartSuggestions;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.deleteDialogTitle),
        content: Text(strings.deleteDialogContent(suggestion.productName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: kStickyPink),
            child: Text(strings.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // ✅ מניעת לחיצה כפולה
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await provider.deleteCurrentSuggestion(null);

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.deletedSuccess(suggestion.productName)),
          backgroundColor: kStickyPink,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.genericError),
          backgroundColor: kStickyPink,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
