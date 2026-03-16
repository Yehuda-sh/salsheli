// 📄 lib/screens/home/dashboard/widgets/last_chance_banner.dart
//
// בנר "הזדמנות אחרונה" — תצוגה אופקית קומפקטית בזמן קנייה פעילה.
// מציג המלצות כצ'יפים קטנים (אמוג'י + שם קצר) + כפתורי הוספה/דילוג.
//
// Version: 5.0 (16/03/2026) — Horizontal chip layout

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

/// בנר אזהרה אחרונה — compact horizontal chips
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
                  key: ValueKey(suggestion.id),
                  child: _LastChanceChipRow(
                    suggestion: suggestion,
                    activeListId: activeListId,
                  ),
                ),
        );
      },
    );
  }
}

/// שורת צ'יפים אופקית קומפקטית
class _LastChanceChipRow extends StatefulWidget {
  final SmartSuggestion suggestion;
  final String activeListId;

  const _LastChanceChipRow({required this.suggestion, required this.activeListId});

  @override
  State<_LastChanceChipRow> createState() => _LastChanceChipRowState();
}

class _LastChanceChipRowState extends State<_LastChanceChipRow> {
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
    final borderColor = isCritical
        ? cs.error.withValues(alpha: 0.4)
        : cs.outline.withValues(alpha: 0.2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXTiny),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingTiny),
      decoration: BoxDecoration(
        color: isCritical
            ? cs.errorContainer.withValues(alpha: 0.3)
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // 🏷️ Urgency emoji + product name chip
          Text(
            _getUrgencyEmoji(suggestion.urgency),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${suggestion.productName} (${strings.stockText(suggestion.currentStock)})',
              style: TextStyle(
                fontSize: kFontSizeSmall,
                fontWeight: FontWeight.w600,
                color: isCritical ? cs.error : cs.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Action buttons
          if (!_isProcessing) ...[
            // ✅ Add button
            SizedBox(
              height: 28,
              child: FilledButton.tonal(
                onPressed: () => _onAddPressed(context, successColor),
                style: FilledButton.styleFrom(
                  backgroundColor: successColor.withValues(alpha: 0.2),
                  foregroundColor: successColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
                ),
                child: Icon(Icons.add, size: 18),
              ),
            ),
            const SizedBox(width: 4),
            // ⏭️ Next button
            SizedBox(
              height: 28,
              child: IconButton(
                onPressed: () => _onNextPressed(context),
                icon: Icon(Icons.skip_next, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                style: IconButton.styleFrom(
                  foregroundColor: cs.onSurfaceVariant,
                ),
                tooltip: strings.nextTooltip,
              ),
            ),
            // ❌ Skip session
            SizedBox(
              height: 28,
              child: IconButton(
                onPressed: () => _onSkipSessionPressed(context),
                icon: Icon(Icons.close, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                style: IconButton.styleFrom(
                  foregroundColor: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                tooltip: strings.skipSessionTooltip,
              ),
            ),
          ] else
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
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
      messenger.showSnackBar(SnackBar(
        content: Text(strings.addError),
        backgroundColor: cs.error,
      ));
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
      messenger.showSnackBar(SnackBar(
        content: Text(strings.genericError),
        backgroundColor: cs.error,
      ));
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
      messenger.showSnackBar(SnackBar(
        content: Text(strings.genericError),
        backgroundColor: cs.error,
      ));
    }
  }
}
