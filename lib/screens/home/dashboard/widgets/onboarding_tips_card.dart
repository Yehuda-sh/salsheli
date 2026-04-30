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
// Sticky-note tilt — fixed per kind (not per row index) so the card
// doesn't flip rotation direction when its sibling is dismissed.
const double _kPantryRotation = 0.01;
const double _kListsRotation = -0.01;
// Sticky-note gradient depth — high enough to read as "folded paper",
// low enough not to muddy the brand color.
const double _kStickyGradientBlend = 0.08;
// Sticky-note ink — alphas tuned as a unit to read as "ink on yellow paper".
// 0.6 / 0.7 are softer than kOpacityMedium (0.5) and intentionally distinct.
const double _kSubtleTextAlpha = 0.6;
const double _kIconTintAlpha = 0.7;
// Drop shadow for the sticky note. Soft and offset slightly down/right
// so the cards feel "pinned" to the page.
const double _kShadowBlur = 4.0;
const Offset _kShadowOffset = Offset(1, 2);
// Entry animation tuning. Stagger keeps the second tip from arriving
// at exactly the same instant as the first.
const Duration _kEnterDuration = Duration(milliseconds: 400);
const int _kEnterStaggerMs = 100;
const double _kEnterSlideOffset = 0.1;
// Persisted dismiss flags — once a user closes a tip we remember it forever.
const String _kPrefDismissedPantry = 'onboarding_dismissed_pantry_tip';
const String _kPrefDismissedLists = 'onboarding_dismissed_lists_tip';

/// Stable identifier for each tip — used as the dismiss-key and as the
/// per-tip widget key so animations don't get confused when one disappears.
enum _TipKind {
  pantry(_kPantryRotation),
  lists(_kListsRotation);

  final double rotation;
  const _TipKind(this.rotation);
}

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
    // Targeted selectors — only rebuild on count changes, not on every
    // list/inventory mutation.
    final isLoggedIn = context.select<UserContext, bool>((u) => u.isLoggedIn);
    if (!isLoggedIn) return const SizedBox.shrink();

    // Hide while we're still loading dismiss flags.
    final pantryDismissed = _pantryDismissed;
    final listsDismissed = _listsDismissed;
    if (pantryDismissed == null || listsDismissed == null) {
      return const SizedBox.shrink();
    }

    final pantryCount =
        context.select<InventoryProvider, int>((p) => p.items.length);
    final listCount =
        context.select<ShoppingListsProvider, int>((p) => p.lists.length);
    final brand = Theme.of(context).extension<AppBrand>();
    final strings = AppStrings.onboardingTips;

    final tips = <_TipData>[];

    if (pantryCount < _kPantryTipTarget && !pantryDismissed) {
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

    if (listCount < _kListsTipTarget && !listsDismissed) {
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

    // Slide-in direction follows reading direction — same precedent as
    // welcome_screen's locale-aware parallax.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final slideBegin = _kEnterSlideOffset * (isRtl ? -1 : 1);

    // Sticky Notes אנכיים — כל כרטיס שורה מלאה. The bottom padding lives
    // here (not on the parent) so when there are no tips the dashboard
    // doesn't end up with an empty gap where this card would have been.
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingMedium),
      child: Column(
        children: [
          for (var i = 0; i < tips.length; i++)
            Padding(
              key: ValueKey(tips[i].kind),
              padding: const EdgeInsets.only(bottom: kSpacingSmall),
              child: _StickyNoteTip(
                tip: tips[i],
                onDismiss: () => _dismiss(tips[i].kind),
              )
                  .animate()
                  .fadeIn(
                    duration: _kEnterDuration,
                    delay: Duration(milliseconds: _kEnterStaggerMs * i),
                  )
                  .slideX(
                    begin: slideBegin,
                    end: 0,
                    duration: _kEnterDuration,
                    delay: Duration(milliseconds: _kEnterStaggerMs * i),
                  ),
            ),
        ],
      ),
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
  final VoidCallback onDismiss;

  const _StickyNoteTip({
    required this.tip,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shadowColor = Theme.of(context).shadowColor;

    final subtleText = cs.onSurface.withValues(alpha: _kSubtleTextAlpha);
    final accentBg = cs.scrim.withValues(alpha: kOpacitySubtle);
    final radius = BorderRadius.circular(kBorderRadiusSmall);

    return Transform.rotate(
      angle: tip.kind.rotation,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        // Clip the InkWell ripple to the rounded corners — without this
        // it bleeds out the edges, especially on the rotated card.
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tip.color,
                Color.lerp(tip.color, shadowColor, _kStickyGradientBlend) ??
                    tip.color,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: kOpacitySubtle),
                blurRadius: _kShadowBlur,
                offset: _kShadowOffset,
              ),
            ],
          ),
          child: Semantics(
            // The card itself is the primary button (opens pantry / lists).
            // explicitChildNodes lets the dismiss IconButton remain its own
            // accessibility node, while the inner text is collapsed into
            // the card's label via ExcludeSemantics below.
            explicitChildNodes: true,
            button: true,
            label: '${tip.title}, ${tip.subtitle}, ${tip.progress}',
            child: InkWell(
              onTap: tip.onAction,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingMedium,
                  vertical: kSpacingSmallPlus,
                ),
                child: Row(
                  children: [
                    // Decorative content — already represented in the
                    // card-level Semantics label, so don't read it twice.
                    ExcludeSemantics(
                      child: Container(
                        width: kIconSizeXLarge,
                        height: kIconSizeXLarge,
                        decoration: BoxDecoration(
                          color: accentBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tip.icon,
                          size: kIconSizeMedium,
                          color: cs.onSurface.withValues(alpha: _kIconTintAlpha),
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingMedium),

                    Expanded(
                      child: ExcludeSemantics(
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
                                color: subtleText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: kSpacingXTiny),
                            // Progress label gives the user a sense of
                            // how close they are to the tip going away.
                            Text(
                              tip.progress,
                              style: TextStyle(
                                fontSize: kFontSizeTiny,
                                fontWeight: FontWeight.w600,
                                color: subtleText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),

                    // CTA — visual only; the InkWell wrapping the whole
                    // card is the actual tap target.
                    ExcludeSemantics(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSpacingMedium,
                          vertical: kSpacingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: accentBg,
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
                    ),
                    // Dismiss — separate tap target. IconButton brings its
                    // own Semantics(button) + tooltip; explicitChildNodes
                    // on the parent keeps it as its own a11y node.
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
