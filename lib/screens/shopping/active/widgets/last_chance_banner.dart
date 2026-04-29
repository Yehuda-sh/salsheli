// lib/screens/shopping/active/widgets/last_chance_banner.dart — Last chance banner — restock suggestion during active shopping session

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

// Switcher / entry animation tuning.
const Duration _kSwitcherDuration = Duration(milliseconds: 400);
const Offset _kSwitcherSlideBegin = Offset(0, -0.1);

// Card surface — alphas tuned for "soft inline alert".
const double _kCriticalBgAlpha = 0.3;
const double _kRegularBgAlpha = 0.5;
const double _kCriticalBorderAlpha = 0.4;
const double _kRegularBorderAlpha = 0.2;

// Add CTA — tonal background depth.
const double _kAddBgAlpha = 0.2;
// Skip icon button — slightly dimmed.
const double _kSkipFgAlpha = 0.6;

// SnackBar duration for transient feedback. Shorter than the global
// kSnackBarDuration (3s) — these toasts are non-critical confirmations
// during an active shopping flow and shouldn't linger.
const Duration _kSnackBarDuration = Duration(seconds: 2);

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
          duration: _kSwitcherDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: _kSwitcherSlideBegin,
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: suggestion == null
              ? const SizedBox.shrink()
              : RepaintBoundary(
                  key: ValueKey(suggestion.id),
                  child: _LastChanceCard(
                    suggestion: suggestion,
                    activeListId: activeListId,
                  ),
                ),
        );
      },
    );
  }
}

/// Visual coding for an urgency level — icon + tint chosen to match the
/// rest of the dashboard (Material icons, not emoji).
({IconData icon, Color color}) _urgencyVisual(
  String urgency,
  ColorScheme cs,
  AppBrand? brand,
) {
  switch (urgency) {
    case 'critical':
      return (icon: Icons.error_rounded, color: cs.error);
    case 'high':
      return (
        icon: Icons.warning_amber_rounded,
        color: brand?.warning ?? cs.error,
      );
    case 'medium':
      return (icon: Icons.bolt, color: brand?.warning ?? cs.tertiary);
    default:
      return (
        icon: Icons.tips_and_updates_outlined,
        color: brand?.accent ?? cs.primary,
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

  @override
  Widget build(BuildContext context) {
    final suggestion = widget.suggestion;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final strings = AppStrings.lastChanceBanner;
    final successColor = brand?.success ?? kStickyGreen;
    final isCritical =
        suggestion.urgency == 'critical' || suggestion.urgency == 'high';
    final visual = _urgencyVisual(suggestion.urgency, cs, brand);

    final borderColor = isCritical
        ? cs.error.withValues(alpha: _kCriticalBorderAlpha)
        : cs.outline.withValues(alpha: _kRegularBorderAlpha);

    return Semantics(
      // Card-level label so screen readers announce the suggestion as
      // a single unit. explicitChildNodes keeps the action buttons
      // (Add / Next / Skip) as their own a11y nodes underneath.
      explicitChildNodes: true,
      label:
          '${suggestion.productName}, ${strings.stockText(suggestion.currentStock)}',
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: kSpacingSmall,
          vertical: kSpacingSmall,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingMedium,
          vertical: kSpacingSmall,
        ),
        decoration: BoxDecoration(
          color: isCritical
              ? cs.errorContainer.withValues(alpha: _kCriticalBgAlpha)
              : cs.surfaceContainerHighest.withValues(alpha: _kRegularBgAlpha),
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Urgency icon (replaces hardcoded emoji 🚨/⚠️/⚡/💡).
            ExcludeSemantics(
              child: Icon(visual.icon, size: kIconSizeMediumPlus, color: visual.color),
            ),
            const SizedBox(width: kSpacingMedium),

            // שם המוצר ומצב המלאי (2 שורות) — already announced by the
            // card-level Semantics label above.
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fixBidiNumbers(suggestion.productName),
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
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            if (!_isProcessing) ...[
              // ✅ Add button
              FilledButton.tonal(
                onPressed: _onAddPressed,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      successColor.withValues(alpha: _kAddBgAlpha),
                  foregroundColor: successColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingSmallPlus,
                  ),
                  minimumSize: const Size(0, kMinTapTarget),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                ),
                child: const Icon(Icons.add, size: kIconSizeSmallPlus),
              ),
              const SizedBox(width: kSpacingXTiny),
              // ⏭️ Next button
              IconButton(
                onPressed: _onNextPressed,
                icon: const Icon(Icons.skip_next, size: kIconSizeSmallPlus),
                style: IconButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
                tooltip: strings.nextTooltip,
              ),
              // 🔕 Skip session — silenced bell instead of close (×)
              // makes the "we'll stop nagging" semantics clearer.
              IconButton(
                onPressed: _onSkipSessionPressed,
                icon: const Icon(
                  Icons.notifications_off_outlined,
                  size: kIconSizeSmallPlus,
                ),
                style: IconButton.styleFrom(
                  foregroundColor:
                      cs.onSurfaceVariant.withValues(alpha: _kSkipFgAlpha),
                ),
                tooltip: strings.skipSessionTooltip,
              ),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: kSpacingMedium),
                child: SizedBox(
                  width: kIconSizeMedium,
                  height: kIconSizeMedium,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddPressed() async {
    if (_isProcessing) return;

    unawaited(HapticFeedback.mediumImpact());
    setState(() => _isProcessing = true);

    final strings = AppStrings.lastChanceBanner;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;
    final messenger = ScaffoldMessenger.of(context);
    final listsProvider = context.read<ShoppingListsProvider>();
    final suggestionsProvider = context.read<SuggestionsProvider>();
    final suggestion = widget.suggestion;

    try {
      final item = suggestion.toUnifiedListItem();
      await listsProvider.addUnifiedItem(widget.activeListId, item);
      await suggestionsProvider.addCurrentSuggestion(widget.activeListId);

      if (!mounted) return;
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(strings.addedSuccess(suggestion.productName)),
            backgroundColor: successColor,
            duration: _kSnackBarDuration,
          ),
        );
    } catch (e) {
      if (!mounted) return;
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(strings.addError), backgroundColor: cs.error),
        );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onNextPressed() async {
    if (_isProcessing) return;
    unawaited(HapticFeedback.lightImpact());

    final strings = AppStrings.lastChanceBanner;
    final cs = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    final suggestionsProvider = context.read<SuggestionsProvider>();

    try {
      await suggestionsProvider.moveToNext();
    } catch (e) {
      if (!mounted) return;
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(strings.genericError), backgroundColor: cs.error),
        );
    }
  }

  Future<void> _onSkipSessionPressed() async {
    if (_isProcessing) return;
    unawaited(HapticFeedback.lightImpact());

    final strings = AppStrings.lastChanceBanner;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accentColor = theme.extension<AppBrand>()?.accent ?? cs.tertiary;
    final messenger = ScaffoldMessenger.of(context);
    final suggestionsProvider = context.read<SuggestionsProvider>();

    try {
      await suggestionsProvider.skipForSession();

      if (!mounted) return;
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(strings.skippedForSession),
            backgroundColor: accentColor,
            duration: _kSnackBarDuration,
          ),
        );
    } catch (e) {
      if (!mounted) return;
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(strings.genericError), backgroundColor: cs.error),
        );
    }
  }
}
