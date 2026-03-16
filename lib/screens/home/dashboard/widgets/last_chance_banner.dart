// 📄 lib/screens/home/dashboard/widgets/last_chance_banner.dart
//
// בנר "הזדמנות אחרונה" — תצוגה אופקית מרווחת בזמן קנייה פעילה.
// מציג המלצות ככרטיס קומפקטי (אמוג'י מוגדל, טקסט ב-2 שורות) + כפתורי פעולה תקניים.
//
// Version: 5.1 (16/03/2026) — Compact Card Layout

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/smart_suggestion.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/suggestions_provider.dart';
import '../../../../theme/app_theme.dart';

/// בנר אזהרה אחרונה — Compact Card
class LastChanceBanner extends StatelessWidget {
  final String activeListId;

  const LastChanceBanner({super.key, required this.activeListId});

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionsProvider>(
      builder: (context, provider, _) {
        final suggestion = provider.currentSuggestion;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: suggestion == null
              ? const SizedBox.shrink()
              : RepaintBoundary(
                  key: ValueKey(suggestion.id),
                  child: _LastChanceCard(suggestion: suggestion, activeListId: activeListId),
                ),
        );
      },
    );
  }
}

/// כרטיס המלצה קומפקטי ומרווח יותר
class _LastChanceCard extends StatefulWidget {
  final SmartSuggestion suggestion;
  final String activeListId;

  const _LastChanceCard({required this.suggestion, required this.activeListId});

  @override
  State<_LastChanceCard> createState() => _LastChanceCardState();
}

class _LastChanceCardState extends State<_LastChanceCard> {
  bool _isProcessing = false;

  String _getUrgencyEmoji(String urgency) {
    switch (urgency) {
      case 'critical':
        return '🚨';
      case 'high':
        return '⚠️';
      case 'medium':
        return '⚡';
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
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;
    final isCritical = suggestion.urgency == 'critical' || suggestion.urgency == 'high';

    // Urgency-based border color
    final borderColor = isCritical ? cs.error.withValues(alpha: 0.4) : cs.outline.withValues(alpha: 0.2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingSmall),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      decoration: BoxDecoration(
        color: isCritical
            ? cs.errorContainer.withValues(alpha: 0.3)
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // 🏷️ Urgency emoji
          Text(
            _getUrgencyEmoji(suggestion.urgency),
            style: const TextStyle(fontSize: 24), // הוגדל מעט
          ),
          const SizedBox(width: kSpacingMedium),

          // שם המוצר ומצב המלאי (2 שורות)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  suggestion.productName,
                  style: TextStyle(
                    fontSize: kFontSizeBody,
                    fontWeight: FontWeight.bold,
                    color: isCritical ? cs.error : cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  strings.stockText(suggestion.currentStock),
                  style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action buttons
          if (!_isProcessing) ...[
            // ✅ Add button
            FilledButton.tonal(
              onPressed: () => _onAddPressed(context, successColor),
              style: FilledButton.styleFrom(
                backgroundColor: successColor.withValues(alpha: 0.2),
                foregroundColor: successColor,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36), // גודל תקני ונוח
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
              ),
              child: const Icon(Icons.add, size: 20),
            ),
            const SizedBox(width: 4),
            // ⏭️ Next button
            IconButton(
              onPressed: () => _onNextPressed(context),
              icon: const Icon(Icons.skip_next, size: 22),
              style: IconButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
              tooltip: strings.nextTooltip,
            ),
            // ❌ Skip session (הוחלף מאייקון סגירה לאייקון השתקה ברור יותר)
            IconButton(
              onPressed: () => _onSkipSessionPressed(context),
              icon: const Icon(Icons.notifications_off_outlined, size: 20),
              style: IconButton.styleFrom(foregroundColor: cs.onSurfaceVariant.withValues(alpha: 0.6)),
              tooltip: strings.skipSessionTooltip,
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
    );
  }

  Future<void> _onAddPressed(BuildContext context, Color successColor) async {
    if (_isProcessing) return;

    unawaited(HapticFeedback.mediumImpact());
    setState(() => _isProcessing = true);

    final strings = AppStrings.lastChanceBanner;
    final cs = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final suggestion = widget.suggestion;
      final listsProvider = Provider.of<ShoppingListsProvider>(context, listen: false);
      final suggestionsProvider = Provider.of<SuggestionsProvider>(context, listen: false);

      final item = suggestion.toUnifiedListItem();
      await listsProvider.addUnifiedItem(widget.activeListId, item);
      await suggestionsProvider.addCurrentSuggestion(widget.activeListId);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.addedSuccess(suggestion.productName)),
          backgroundColor: successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(strings.addError), backgroundColor: cs.error));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onNextPressed(BuildContext context) async {
    if (_isProcessing) return;
    unawaited(HapticFeedback.lightImpact());

    final strings = AppStrings.lastChanceBanner;
    final cs = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final suggestionsProvider = Provider.of<SuggestionsProvider>(context, listen: false);
      await suggestionsProvider.moveToNext();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(strings.genericError), backgroundColor: cs.error));
    }
  }

  Future<void> _onSkipSessionPressed(BuildContext context) async {
    if (_isProcessing) return;
    unawaited(HapticFeedback.lightImpact());

    final strings = AppStrings.lastChanceBanner;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accentColor = theme.extension<AppBrand>()?.accent ?? cs.tertiary;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final suggestionsProvider = Provider.of<SuggestionsProvider>(context, listen: false);
      await suggestionsProvider.skipForSession();

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.skippedForSession),
          backgroundColor: accentColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(strings.genericError), backgroundColor: cs.error));
    }
  }
}
