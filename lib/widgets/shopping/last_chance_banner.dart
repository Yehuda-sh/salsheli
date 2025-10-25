import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/smart_suggestion.dart';
import '../../providers/suggestions_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';

/// באנר "הזדמנות אחרונה" שמציג המלצות שלא הוספו
/// מופיע רק במצב קנייה פעילה
class LastChanceBanner extends StatelessWidget {
  final String listId;

  const LastChanceBanner({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionsProvider>(
      builder: (context, suggestionsProvider, child) {
        final currentSuggestion = suggestionsProvider.currentSuggestion;

        // אם אין המלצה נוכחית, לא מציגים כלום
        if (currentSuggestion == null) {
          return const SizedBox.shrink();
        }

        return _buildBanner(context, currentSuggestion, suggestionsProvider);
      },
    );
  }

  Widget _buildBanner(
    BuildContext context,
    SmartSuggestion suggestion,
    SuggestionsProvider suggestionsProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kStickyOrange.withValues(alpha: 0.2),
            kStickyYellow.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kStickyOrange.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: kStickyOrange.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: kStickyOrange,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'עוד לא הוספת:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kStickyOrange,
                  ),
                ),
              ),
              // ספירת המלצות נוספות
              if (suggestionsProvider.pendingSuggestionsCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kStickyOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${suggestionsProvider.pendingSuggestionsCount}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kStickyOrange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // פרטי המוצר
          Row(
            children: [
              Icon(
                Icons.shopping_basket_outlined,
                color: colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'נשארו ${suggestion.currentStock} יחידות',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // כפתורי פעולה
          Row(
            children: [
              // כפתור "הבא"
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _onNext(context, suggestionsProvider),
                  icon: const Icon(Icons.skip_next, size: 20),
                  label: const Text('הבא'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    side: BorderSide(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // כפתור "הוסף"
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _onAdd(context, suggestionsProvider),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('הוסף לרשימה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kStickyOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: -0.2,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  /// טיפול בלחיצה על "הבא"
  Future<void> _onNext(
    BuildContext context,
    SuggestionsProvider suggestionsProvider,
  ) async {
    try {
      await suggestionsProvider.dismissCurrentSuggestion();

      if (context.mounted) {
        // הצגת הודעה
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('הדחיתי את ההמלצה'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// טיפול בלחיצה על "הוסף"
  Future<void> _onAdd(
    BuildContext context,
    SuggestionsProvider suggestionsProvider,
  ) async {
    try {
      final shoppingListsProvider = context.read<ShoppingListsProvider>();

      // הוספת המוצר ישירות לרשימה הנוכחית
      await shoppingListsProvider.addUnifiedItem(
        listId,
        suggestionsProvider.currentSuggestion!.toUnifiedListItem(),
      );

      // סימון ההמלצה כ"נוספה"
      await suggestionsProvider.addCurrentSuggestion(listId);

      if (context.mounted) {
        // הצגת הודעת הצלחה
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'הוספתי ${suggestionsProvider.currentSuggestion?.productName ?? "המוצר"} לרשימה',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
