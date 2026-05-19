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
import '../../../../services/prefs_cache.dart';
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
// Celebration: tip persists for this long after the user crosses the
// threshold, giving the "🎉" moment a beat before the tip vanishes.
const Duration _kCelebrationDuration = Duration(milliseconds: 1500);
// Undo: tapping × hides the tip immediately, but the prefs save is
// deferred for this long so the user can revert via snackbar.
const Duration _kDismissUndoWindow = Duration(seconds: 5);
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

  // Previous counts used to detect threshold crossings. null on first
  // build (no comparison possible yet).
  int? _prevPantryCount;
  int? _prevListCount;

  // Active celebration — which tip is currently in its 1.5s "🎉" window
  // before vanishing. Cleared by _celebrationTimer.
  _TipKind? _celebratingKind;
  Timer? _celebrationTimer;

  // Gmail-style undo for ×: when the user dismisses, the tip is hidden
  // locally and the prefs save is deferred. If the user taps "Undo" in
  // the snackbar, _dismissTimer is cancelled and nothing persists.
  _TipKind? _pendingDismissKind;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // Fast path: prefs were pre-warmed by `PrefsCache.init()` in main(),
    // so we can read synchronously and avoid the layout-flash that an
    // async wait would cause on first build. Fallback to async load
    // covers test setups and any path that skips main()'s bootstrap.
    final cached = PrefsCache.instance;
    if (cached != null) {
      _pantryDismissed = cached.getBool(_kPrefDismissedPantry) ?? false;
      _listsDismissed = cached.getBool(_kPrefDismissedLists) ?? false;
    } else {
      unawaited(_loadDismissed());
    }
  }

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
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

  /// Detect threshold crossings (prev < target → curr >= target) and
  /// schedule the post-frame celebration. Called from build with the
  /// fresh counts — uses addPostFrameCallback to avoid setState-in-build.
  void _maybeCelebrate(_TipKind kind, int? prev, int curr, int target,
      bool dismissed) {
    if (prev == null || dismissed) return;
    if (prev >= target || curr < target) return;
    if (_celebratingKind == kind) return; // already celebrating

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _celebrationTimer?.cancel();
      setState(() => _celebratingKind = kind);
      _celebrationTimer = Timer(_kCelebrationDuration, () {
        if (!mounted) return;
        setState(() => _celebratingKind = null);
      });
    });
  }

  /// × tap → hide the tip immediately + show snackbar with "Undo". The
  /// actual prefs save fires only after the snackbar's window elapses,
  /// matching the pattern used in `pending_invites_banner`.
  void _dismiss(_TipKind kind) {
    if (_pendingDismissKind != null) return;

    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.onboardingTips;

    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _pendingDismissKind = kind;
      switch (kind) {
        case _TipKind.pantry:
          _pantryDismissed = true;
        case _TipKind.lists:
          _listsDismissed = true;
      }
    });

    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(strings.dismissedSnackbar),
        duration: _kDismissUndoWindow,
        action: SnackBarAction(
          label: strings.undoLabel,
          onPressed: () {
            _dismissTimer?.cancel();
            if (!mounted) return;
            setState(() {
              _pendingDismissKind = null;
              switch (kind) {
                case _TipKind.pantry:
                  _pantryDismissed = false;
                case _TipKind.lists:
                  _listsDismissed = false;
              }
            });
          },
        ),
      ));

    _dismissTimer = Timer(_kDismissUndoWindow, () async {
      if (!mounted || _pendingDismissKind != kind) return;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
          kind == _TipKind.pantry ? _kPrefDismissedPantry : _kPrefDismissedLists,
          true,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ OnboardingTips: prefs save failed: $e');
      }
      if (mounted) setState(() => _pendingDismissKind = null);
    });
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

    // Detect threshold crossings against the previous build's counts.
    // Triggers the celebration window (post-frame) before the tip
    // naturally drops out at the next count change.
    _maybeCelebrate(
        _TipKind.pantry, _prevPantryCount, pantryCount, _kPantryTipTarget,
        pantryDismissed);
    _maybeCelebrate(
        _TipKind.lists, _prevListCount, listCount, _kListsTipTarget,
        listsDismissed);
    _prevPantryCount = pantryCount;
    _prevListCount = listCount;

    final tips = <_TipData>[];

    // A tip stays visible while either:
    //  - the user hasn't crossed the threshold yet, OR
    //  - they JUST crossed it and we're in the celebration window.
    final pantryCelebrating = _celebratingKind == _TipKind.pantry;
    final listsCelebrating = _celebratingKind == _TipKind.lists;
    final showPantry =
        !pantryDismissed && (pantryCount < _kPantryTipTarget || pantryCelebrating);
    final showLists =
        !listsDismissed && (listCount < _kListsTipTarget || listsCelebrating);

    if (showPantry) {
      tips.add(_TipData(
        kind: _TipKind.pantry,
        icon: Icons.inventory_2_outlined,
        color: brand?.stickyYellow ?? kStickyYellow,
        title: pantryCelebrating
            ? strings.celebrationPantryTitle
            : strings.fillPantryTitle,
        subtitle: pantryCelebrating
            ? strings.celebrationPantrySubtitle
            : strings.fillPantrySubtitle,
        progress: strings.fillPantryProgress(pantryCount, _kPantryTipTarget),
        isCelebrating: pantryCelebrating,
        onAction: () {
          unawaited(HapticFeedback.lightImpact());
          widget.onNavigateToPantry?.call();
        },
      ));
    }

    if (showLists) {
      tips.add(_TipData(
        kind: _TipKind.lists,
        icon: Icons.playlist_add,
        color: brand?.stickyGreen ?? kStickyGreen,
        title: listsCelebrating
            ? strings.celebrationListsTitle
            : strings.createListsTitle,
        subtitle: listsCelebrating
            ? strings.celebrationListsSubtitle
            : strings.createListsSubtitle,
        progress: strings.createListsProgress(listCount, _kListsTipTarget),
        isCelebrating: listsCelebrating,
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
  final bool isCelebrating;
  final VoidCallback onAction;

  const _TipData({
    required this.kind,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.isCelebrating,
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
    // Forward chevron flips with locale: arrow_back is the "forward"
    // arrow in Hebrew RTL, arrow_forward in English LTR.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final forwardArrow =
        isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded;

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
                    // During the celebration window, the icon container
                    // pulses (scale+rotate) and a 🎉 emoji bursts inside
                    // it before the tip vanishes — turns "feature done"
                    // from anticlimactic to a small premium moment.
                    ExcludeSemantics(
                      child: _CelebratableIcon(
                        icon: tip.icon,
                        iconColor:
                            cs.onSurface.withValues(alpha: _kIconTintAlpha),
                        background: accentBg,
                        isCelebrating: tip.isCelebrating,
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

                    // Affordance: a small RTL-aware arrow. Previously a
                    // text pill ("התחל" / "צור") that *looked* like a
                    // standalone button but did exactly the same thing
                    // as tapping the card — a visual lie. The arrow
                    // signals "tap to continue" without pretending to be
                    // its own button. Hidden during celebration (the
                    // tip is about to vanish — no action to invite).
                    //
                    // Background uses the tip's own sticky color (full
                    // saturation) — the card's background blends the
                    // same hue at 25%, so the arrow circle reads as a
                    // brighter "echo" that stands out. Previously both
                    // → and × shared a gray scrim tint, leaving the
                    // primary action visually indistinguishable from
                    // dismiss.
                    if (!tip.isCelebrating)
                      ExcludeSemantics(
                        child: Container(
                          width: kIconSizeLarge,
                          height: kIconSizeLarge,
                          decoration: BoxDecoration(
                            color: tip.color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            forwardArrow,
                            size: kIconSizeSmall,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    // Dismiss — separate tap target. IconButton brings
                    // its own Semantics(button) + tooltip;
                    // explicitChildNodes on the parent keeps it as its
                    // own a11y node. Hidden during celebration: the tip
                    // is about to vanish naturally, no need to offer
                    // explicit dismiss.
                    if (!tip.isCelebrating)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: kIconSizeSmall,
                          color:
                              cs.onSurface.withValues(alpha: kOpacityMedium),
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

/// Icon container that pulses + bursts a 🎉 emoji when [isCelebrating]
/// is true. Otherwise renders as a plain circular icon, identical to the
/// previous inline implementation. Extracted so the celebration animation
/// has stable widget identity across rebuilds.
class _CelebratableIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color background;
  final bool isCelebrating;

  const _CelebratableIcon({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.isCelebrating,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: kIconSizeXLarge,
      height: kIconSizeXLarge,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: kIconSizeMedium, color: iconColor),
    );

    if (!isCelebrating) return container;

    // Pulse the container + burst a 🎉 emoji overlay. The emoji uses
    // elasticOut for a "spring out" feel and fades out toward the end of
    // the celebration window so it never feels stuck.
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        container
            .animate()
            .scaleXY(
              begin: 1,
              end: 1.15,
              duration: 300.ms,
              curve: Curves.easeOut,
            )
            .then()
            .scaleXY(
              begin: 1.15,
              end: 1,
              duration: 300.ms,
              curve: Curves.easeIn,
            ),
        const IgnorePointer(
          child: Text(
            '🎉',
            style: TextStyle(fontSize: kFontSizeLarge),
          ),
        )
            .animate()
            .scaleXY(
              begin: 0,
              end: 1.4,
              duration: 600.ms,
              curve: Curves.elasticOut,
            )
            .fadeOut(delay: 900.ms, duration: 500.ms),
      ],
    );
  }
}
