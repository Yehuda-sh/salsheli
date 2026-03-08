// 📄 lib/screens/home/dashboard/widgets/last_chance_banner.dart
//
// בנר "הזדמנות אחרונה" - תזכורת חכמה בזמן קנייה פעילה.
// מציג המלצה נוכחית עם מלאי, כפתור הוספה וכפתור "הבא".
//
// ✅ Features:
//    - עיצוב מבוסס דחיפות (Urgency-based styling)
//    - Haptic feedback באינטראקציות
//    - אנימציית כניסה מודגשת (shake for critical)
//    - Theme-aware warning colors (Dark Mode support)
//    - Accessibility labels and tooltips
//    - Optimized with RepaintBoundary
//    - AnimatedSwitcher for smooth transitions
//    - Hebrew RTL support
//
// 🔗 Related: SmartSuggestion, SuggestionsProvider
//
// Version: 4.0 (22/02/2026)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/smart_suggestion.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/suggestions_provider.dart';
import '../../../../theme/app_theme.dart';

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
                  // ✅ FIX: Use unique ID instead of productName (could have duplicates)
                  key: ValueKey(suggestion.id),
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
    final strings = AppStrings.lastChanceBanner;
    final urgency = suggestion.urgency;
    final isCritical = urgency == 'critical' || urgency == 'high';

    // 🎨 Urgency-based dynamic styling
    final Color bannerBg;
    final Color onBannerColor;
    final Color highlightBg;
    final Color borderColor;

    switch (urgency) {
      case 'critical':
      case 'high':
        // 🔴 דחיפות גבוהה - גווני שגיאה/אזהרה
        bannerBg = Color.alphaBlend(
          cs.errorContainer.withValues(alpha: 0.65),
          cs.surface,
        );
        onBannerColor = cs.onErrorContainer;
        highlightBg = cs.error.withValues(alpha: 0.1);
        borderColor = cs.onErrorContainer.withValues(alpha: 0.2);
      case 'medium':
        // 🟡 דחיפות בינונית - גווני אזהרה (כתום/צהוב)
        bannerBg = Color.alphaBlend(
          cs.tertiaryContainer.withValues(alpha: 0.65),
          cs.surface,
        );
        onBannerColor = cs.onTertiaryContainer;
        highlightBg = cs.tertiary.withValues(alpha: 0.1);
        borderColor = cs.onTertiaryContainer.withValues(alpha: 0.2);
      default:
        // 🔵 דחיפות נמוכה - גווני מידע (כחול/תכלת)
        bannerBg = Color.alphaBlend(
          cs.secondaryContainer.withValues(alpha: 0.65),
          cs.surface,
        );
        onBannerColor = cs.onSecondaryContainer;
        highlightBg = cs.secondary.withValues(alpha: 0.1);
        borderColor = cs.onSecondaryContainer.withValues(alpha: 0.2);
    }

    // ✅ FIX: Theme-aware success color for buttons
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;

    // ✅ Semantics - שפה טבעית וידידותית
    Widget banner = Semantics(
      label: strings.semanticsLabel(suggestion.productName, suggestion.currentStock),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
        padding: const EdgeInsets.all(kSpacingMedium),
        decoration: BoxDecoration(
          color: bannerBg,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(color: borderColor),
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
                    strings.title,
                    style: TextStyle(
                      fontSize: kFontSizeTitle,
                      fontWeight: FontWeight.bold,
                      color: onBannerColor,
                    ),
                    // ✅ FIX: Removed forced RTL - rely on MaterialApp
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
              child: Row(
                children: [
                  // אמוג'י דחיפות
                  Text(_getUrgencyEmoji(suggestion.urgency), style: const TextStyle(fontSize: kFontSizeDisplay)),
                  const SizedBox(width: kSpacingSmall),

                  // פרטים
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.productName,
                          style: TextStyle(
                            fontSize: kFontSizeBody,
                            fontWeight: FontWeight.bold,
                            color: onBannerColor,
                          ),
                          // ✅ FIX: Removed forced RTL + overflow protection
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.stockText(suggestion.currentStock),
                          style: TextStyle(
                            fontSize: kFontSizeMedium,
                            color: onBannerColor.withValues(alpha: 0.9),
                          ),
                          // ✅ FIX: Removed forced RTL + overflow protection
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: kSpacingMedium),

            // כפתורי פעולה (3 כפתורים: הוסף, הבא, לא עכשיו)
            if (!_isProcessing)
              Column(
                children: [
                  // שורה עליונה: הוסף לרשימה
                  Tooltip(
                    message: strings.addTooltip(suggestion.productName),
                    child: SizedBox(
                      width: double.infinity,
                      child: Builder(
                        builder: (context) {
                          final button = ElevatedButton.icon(
                            onPressed: () => _onAddPressed(context),
                            icon: Icon(Icons.add_shopping_cart, size: 20),
                            label: Text(strings.addButton),
                            style: ElevatedButton.styleFrom(
                              // ✅ FIX: Theme-aware colors
                              backgroundColor: successColor,
                              foregroundColor: cs.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
                            ),
                          );
                          // 💫 Pulse עדין לכפתור כשהדחיפות קריטית
                          if (isCritical) {
                            return button
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scaleXY(begin: 1.0, end: 1.03, duration: 800.ms, curve: Curves.easeInOut);
                          }
                          return button;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: kSpacingSmall),

                  // שורה תחתונה: הבא + לא עכשיו
                  Row(
                    children: [
                      // ✅ כפתור הבא (קרוסלה - יחזור)
                      Expanded(
                        child: Tooltip(
                          message: strings.nextTooltip,
                          child: OutlinedButton.icon(
                            onPressed: () => _onNextPressed(context),
                            icon: Icon(Icons.skip_next, size: 20, color: onBannerColor),
                            label: Text(strings.nextButton, style: TextStyle(color: onBannerColor)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: onBannerColor, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: kSpacingSmall),

                      // ✅ כפתור לא עכשיו (דילוג לסשן בלבד)
                      Expanded(
                        child: Tooltip(
                          message: strings.skipSessionTooltip,
                          child: TextButton.icon(
                            onPressed: () => _onSkipSessionPressed(context),
                            icon: Icon(Icons.snooze, size: 18, color: onBannerColor.withValues(alpha: 0.7)),
                            label: Text(
                              strings.skipSessionButton,
                              style: TextStyle(color: onBannerColor.withValues(alpha: 0.7)),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
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

    // 🔔 Shake עדין להמלצות קריטיות - למשיכת תשומת לב
    if (isCritical) {
      banner = banner
          .animate()
          .shake(hz: 3, rotation: 0.01, duration: 600.ms);
    }

    return banner;
  }

  Future<void> _onAddPressed(BuildContext context) async {
    if (_isProcessing) return;

    unawaited(HapticFeedback.mediumImpact());
    setState(() => _isProcessing = true);

    // ✅ FIX: Cache strings, theme-aware colors, and messenger before async gap
    final strings = AppStrings.lastChanceBanner;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;
    final messenger = ScaffoldMessenger.of(context);

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
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.addedSuccess(suggestion.productName)),
          // ✅ FIX: Theme-aware colors
          backgroundColor: successColor,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // ✅ FIX: User-friendly error message (not raw exception)
      messenger.showSnackBar(SnackBar(
        content: Text(strings.addError),
        backgroundColor: cs.error,
      ));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// ⏭️ כפתור "הבא" - קרוסלה (עובר להמלצה הבאה, יחזור בסוף הסבב)
  Future<void> _onNextPressed(BuildContext context) async {
    if (_isProcessing) return;

    unawaited(HapticFeedback.lightImpact());

    // ✅ FIX: Cache theme-aware colors and messenger before async gap
    final strings = AppStrings.lastChanceBanner;
    final cs = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final suggestionsProvider = Provider.of<SuggestionsProvider>(context, listen: false);

      // עבור להמלצה הבאה (קרוסלה - לא מוחק, רק עובר)
      await suggestionsProvider.moveToNext();
    } catch (e) {
      if (!mounted) return;
      // ✅ FIX: User-friendly error message (not raw exception)
      messenger.showSnackBar(SnackBar(
        content: Text(strings.genericError),
        backgroundColor: cs.error,
      ));
    }
  }

  /// 🚫 כפתור "לא עכשיו" - דילוג לסשן הזה בלבד
  Future<void> _onSkipSessionPressed(BuildContext context) async {
    if (_isProcessing) return;

    unawaited(HapticFeedback.lightImpact());

    // ✅ FIX: Cache strings, theme-aware colors, and messenger before async gap
    final strings = AppStrings.lastChanceBanner;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // ✅ FIX: Theme-aware accent color for info snackbar
    final accentColor = theme.extension<AppBrand>()?.accent ?? cs.tertiary;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final suggestionsProvider = Provider.of<SuggestionsProvider>(context, listen: false);

      // דלג לסשן הזה בלבד (יופיע בקנייה הבאה)
      await suggestionsProvider.skipForSession();

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.skippedForSession),
          // ✅ FIX: Theme-aware color
          backgroundColor: accentColor,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // ✅ FIX: User-friendly error message (not raw exception)
      messenger.showSnackBar(SnackBar(
        content: Text(strings.genericError),
        backgroundColor: cs.error,
      ));
    }
  }
}
