// lib/screens/home/dashboard/widgets/onboarding_tips_card.dart — Onboarding tips — pantry & lists reminders for new users

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../providers/inventory_provider.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../../theme/app_theme.dart';

// Trigger thresholds — tips disappear once the user passes them.
const int _kPantryTipTarget = 3;
const int _kListsTipTarget = 3;
// Sticky-note tilt — alternates direction per index for a "pinned" feel.
const double _kTipRotation = 0.01;
// Persisted dismiss flags — once a user closes a tip we remember it forever.
const String _kPrefDismissedPantry = 'onboarding_dismissed_pantry_tip';
const String _kPrefDismissedLists = 'onboarding_dismissed_lists_tip';

/// Stable identifier for each tip — used as the dismiss-key and as the
/// per-tip widget key so animations don't get confused when one disappears.
enum _TipKind { pantry, lists }

class OnboardingTipsCard extends StatefulWidget {
  final VoidCallback? onNavigateToPantry;
  final VoidCallback? onNavigateToCreateList;

  const OnboardingTipsCard({
    super.key,
    this.onNavigateToPantry,
    this.onNavigateToCreateList,
  });

  @override
  State<OnboardingTipsCard> createState() => _OnboardingTipsCardState();
}

class _OnboardingTipsCardState extends State<OnboardingTipsCard> {
  // null while we're still loading prefs — keeps the card hidden so it
  // doesn't flash on, then off, when the user has already dismissed it.
  bool? _pantryDismissed;
  bool? _listsDismissed;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDismissed());
  }

  Future<void> _loadDismissed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _pantryDismissed = prefs.getBool(_kPrefDismissedPantry) ?? false;
        _listsDismissed = prefs.getBool(_kPrefDismissedLists) ?? false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ OnboardingTips: prefs load failed: $e');
      // Fall back to "not dismissed" so the user can still see the tips.
      if (mounted) {
        setState(() {
          _pantryDismissed = false;
          _listsDismissed = false;
        });
      }
    }
  }

  Future<void> _dismiss(_TipKind kind) async {
    setState(() {
      switch (kind) {
        case _TipKind.pantry:
          _pantryDismissed = true;
        case _TipKind.lists:
          _listsDismissed = true;
      }
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        kind == _TipKind.pantry ? _kPrefDismissedPantry : _kPrefDismissedLists,
        true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ OnboardingTips: prefs save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();
    final listsProvider = context.watch<ShoppingListsProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final brand = Theme.of(context).extension<AppBrand>();

    if (!userContext.isLoggedIn) return const SizedBox.shrink();
    // Hide while we're still loading dismiss flags.
    if (_pantryDismissed == null || _listsDismissed == null) {
      return const SizedBox.shrink();
    }

    final listCount = listsProvider.lists.length;
    final pantryCount = inventoryProvider.items.length;
    final strings = AppStrings.onboardingTips;

    final tips = <_TipData>[];

    if (pantryCount < _kPantryTipTarget && _pantryDismissed == false) {
      tips.add(_TipData(
        kind: _TipKind.pantry,
        icon: Icons.inventory_2_outlined,
        color: brand?.stickyYellow ?? kStickyYellow,
        title: strings.fillPantryTitle,
        subtitle: strings.fillPantrySubtitle,
        progress: strings.fillPantryProgress(pantryCount, _kPantryTipTarget),
        actionLabel: strings.fillPantryAction,
        onAction: () {
          unawaited(HapticFeedback.lightImpact());
          widget.onNavigateToPantry?.call();
        },
      ));
    }

    if (listCount < _kListsTipTarget && _listsDismissed == false) {
      tips.add(_TipData(
        kind: _TipKind.lists,
        icon: Icons.playlist_add,
        color: brand?.stickyGreen ?? kStickyGreen,
        title: strings.createListsTitle,
        subtitle: strings.createListsSubtitle,
        progress: strings.createListsProgress(listCount, _kListsTipTarget),
        actionLabel: strings.createListsAction,
        onAction: () {
          unawaited(HapticFeedback.lightImpact());
          widget.onNavigateToCreateList?.call();
        },
      ));
    }

    if (tips.isEmpty) return const SizedBox.shrink();

    // Sticky Notes אנכיים — כל כרטיס שורה מלאה.
    return Column(
      children: [
        for (var i = 0; i < tips.length; i++)
          Padding(
            key: ValueKey(tips[i].kind),
            padding: const EdgeInsets.only(bottom: kSpacingSmall),
            child: _StickyNoteTip(
              tip: tips[i],
              rotation: (i.isEven ? 1 : -1) * _kTipRotation,
              onDismiss: () => _dismiss(tips[i].kind),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: (100 * i).ms)
                .slideX(begin: 0.1, end: 0, duration: 400.ms, delay: (100 * i).ms),
          ),
      ],
    );
  }
}

class _TipData {
  final _TipKind kind;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String progress;
  final String actionLabel;
  final VoidCallback onAction;

  const _TipData({
    required this.kind,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.actionLabel,
    required this.onAction,
  });
}

/// Sticky Note tip — עיצוב פתקית צבעונית עם צל וסיבוב
class _StickyNoteTip extends StatelessWidget {
  final _TipData tip;
  final double rotation;
  final VoidCallback onDismiss;

  const _StickyNoteTip({
    required this.tip,
    required this.rotation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shadowColor = Theme.of(context).shadowColor;

    return Transform.rotate(
      angle: rotation,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tip.color,
                Color.lerp(tip.color, shadowColor, 0.04) ?? tip.color,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: kOpacitySubtle),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Semantics(
            // Keep the dismiss button as its own accessibility node.
            explicitChildNodes: true,
            button: true,
            label: '${tip.title}, ${tip.subtitle}, ${tip.progress}',
            child: InkWell(
              onTap: tip.onAction,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingMedium,
                  vertical: kSpacingSmallPlus,
                ),
                child: Row(
                  children: [
                    // אייקון בעיגול
                    Container(
                      width: kIconSizeXLarge,
                      height: kIconSizeXLarge,
                      decoration: BoxDecoration(
                        color: cs.scrim.withValues(alpha: kOpacitySubtle),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tip.icon,
                        size: kIconSizeMedium,
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: kSpacingMedium),

                    // טקסט
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tip.title,
                            style: TextStyle(
                              fontSize: kFontSizeBody,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: kSpacingXTiny),
                          Text(
                            tip.subtitle,
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: kSpacingXTiny),
                          // Progress label gives the user a sense of how
                          // close they are to the tip going away.
                          Text(
                            tip.progress,
                            style: TextStyle(
                              fontSize: kFontSizeTiny,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),

                    // כפתור CTA
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingMedium,
                        vertical: kSpacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: cs.scrim.withValues(alpha: kOpacitySubtle),
                        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                      ),
                      child: Text(
                        tip.actionLabel,
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    // Dismiss button — separate tap target so the X can't
                    // be hit while reaching for the CTA. IconButton brings
                    // its own Semantics(button) + tooltip semantics.
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: kIconSizeSmall,
                        color: cs.onSurface.withValues(alpha: kOpacityMedium),
                      ),
                      onPressed: () {
                        unawaited(HapticFeedback.selectionClick());
                        onDismiss();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: kIconSizeLarge,
                        minHeight: kIconSizeLarge,
                      ),
                      tooltip: AppStrings.onboardingTips.dismissTooltip,
                      splashRadius: kIconSizeMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
