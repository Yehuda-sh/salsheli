// 📄 lib/screens/home/dashboard/widgets/last_chance_banner.dart
//
// בנר "הזדמנות אחרונה" - תזכורת חכמה בזמן קנייה פעילה.
// מציג המלצה נוכחית עם מלאי, כפתור הוספה וכפתור "הבא".
//
// ✅ Features:
//    - Theme-aware warning colors (Dark Mode support)
//    - Accessibility labels and tooltips
//    - Optimized with RepaintBoundary
//    - AnimatedSwitcher for smooth transitions
//    - Hebrew RTL support
//
// 🔗 Related: SmartSuggestion, SuggestionsProvider
//
// ----------------------------------------------------------------------------
// The LastChanceBanner widget displays time-sensitive product alerts.
// Appears on the Home Dashboard when products are near expiry or low stock.
//
// Features:
// • Theme-aware warning colors
// • Accessibility labels and tooltips
// • Optimized with RepaintBoundary
// • Supports Dark Mode and Hebrew RTL
// ----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../models/smart_suggestion.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/suggestions_provider.dart';

/// בנר אזהרה אחרונה - מוצג בזמן קנייה פעילה
/// מראה המלצה נוכחית עם stock info ואפשרות להוסיף/לדחות
class LastChanceBanner extends StatelessWidget {
  final String activeListId;

  const LastChanceBanner({super.key, required this.activeListId});

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionsProvider>(
      builder: (context, provider, _) {
        final suggestion = provider.currentSuggestion;

        // ✅ AnimatedSwitcher להופעה חלקה + RepaintBoundary לביצועים
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: suggestion == null
              ? const SizedBox.shrink()
              : RepaintBoundary(
                  key: ValueKey(suggestion.productName),
                  child: _LastChanceBannerContent(
                    suggestion: suggestion,
                    activeListId: activeListId,
                  ),
                ),
        );
      },
    );
  }
}

/// תוכן הבנר - מופרד לנוחות
class _LastChanceBannerContent extends StatefulWidget {
  final SmartSuggestion suggestion;
  final String activeListId;

  const _LastChanceBannerContent({required this.suggestion, required this.activeListId});

  @override
  State<_LastChanceBannerContent> createState() => _LastChanceBannerContentState();
}

class _LastChanceBannerContentState extends State<_LastChanceBannerContent> {
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
  Widget build(BuildContext context) {
    final suggestion = widget.suggestion;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // ✅ Theme-aware colors - רכים יותר ב-Dark Mode
    // משתמש ב-errorContainer לאור רך יותר
    final bannerBg = Color.alphaBlend(
      cs.errorContainer.withValues(alpha: 0.65),
      cs.surface,
    );
    final onBannerColor = cs.onErrorContainer;
    final highlightBg = cs.error.withValues(alpha: 0.1);

    // ✅ Semantics - שפה טבעית וידידותית
    return Semantics(
      label: 'המוצר ${suggestion.productName} עומד להיגמר. נותרו ${suggestion.currentStock} יחידות במלאי.',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
        padding: const EdgeInsets.all(kSpacingMedium),
        decoration: BoxDecoration(
          color: bannerBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // כותרת
            Row(
              children: [
                Icon(Icons.warning_amber, color: onBannerColor, size: 24),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    'רגע! שכחת משהו?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onBannerColor,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),

            const SizedBox(height: kSpacingSmall),

            // פרטי מוצר
            Container(
              padding: const EdgeInsets.all(kSpacingSmall),
              decoration: BoxDecoration(
                color: highlightBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // אמוג'י דחיפות
                  Text(_getUrgencyEmoji(suggestion.urgency), style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: kSpacingSmall),

                  // פרטים
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.productName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: onBannerColor,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'נותרו: ${suggestion.currentStock} יחידות במלאי',
                          style: TextStyle(
                            fontSize: 14,
                            color: onBannerColor.withValues(alpha: 0.9),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: kSpacingMedium),

            // כפתורי פעולה
            if (!_isProcessing)
              Row(
                children: [
                  // ✅ כפתור הוסף עם Tooltip
                  Expanded(
                    child: Tooltip(
                      message: 'הוסף "${suggestion.productName}" לרשימת הקניות',
                      child: ElevatedButton.icon(
                        onPressed: () => _onAddPressed(context),
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        label: const Text('הוסף לרשימה'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kStickyGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: kSpacingSmall),

                  // ✅ כפתור דחה עם Tooltip
                  Expanded(
                    child: Tooltip(
                      message: 'דלג והמשך להמלצה הבאה',
                      child: OutlinedButton.icon(
                        onPressed: () => _onSkipPressed(context),
                        icon: Icon(Icons.skip_next, size: 20, color: onBannerColor),
                        label: Text('הבא', style: TextStyle(color: onBannerColor)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: onBannerColor, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // אינדיקטור loading
            if (_isProcessing)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingSmall),
                  child: CircularProgressIndicator(color: onBannerColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddPressed(BuildContext context) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final suggestion = widget.suggestion;
      final listsProvider = Provider.of<ShoppingListsProvider>(context, listen: false);
      final suggestionsProvider = Provider.of<SuggestionsProvider>(context, listen: false);

      // יצירת פריט מההמלצה (השתמש במתודה המוכנה)
      final item = suggestion.toUnifiedListItem();

      // הוספה לרשימה
      await listsProvider.addUnifiedItem(widget.activeListId, item);

      // סימון כנוסף (צריך listId)
      await suggestionsProvider.addCurrentSuggestion(widget.activeListId);

      // הודעת הצלחה
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('נוסף "${suggestion.productName}" לרשימה ✅'),
          backgroundColor: kStickyGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('שגיאה בהוספה: $e'), backgroundColor: kStickyPink));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onSkipPressed(BuildContext context) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final suggestionsProvider = Provider.of<SuggestionsProvider>(context, listen: false);

      // דחייה (המתודה משתמשת ב-Duration קבוע של 7 ימים)
      await suggestionsProvider.dismissCurrentSuggestion();

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('עברנו להמלצה הבאה 👍'),
          backgroundColor: kStickyCyan,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('שגיאה: $e'), backgroundColor: kStickyPink));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
