// lib/screens/home/dashboard/widgets/pending_invites_banner.dart — Pending invites banner — notification about received list/household invitations

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/status_colors.dart';
import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/enums/request_type.dart';
import '../../../../models/pending_request.dart';
import '../../../../providers/user_context.dart';
import '../../../../services/pending_invites_service.dart';

// Banner appearance — alphas tuned to read as "soft tertiary alert".
const double _kBgAlpha = 0.9;
const double _kBorderAlpha = 0.3;
const double _kShadowAlpha = 0.08;
const double _kIconBgAlpha = 0.15;
const double _kShimmerAlpha = 0.3;
const double _kSubtitleAlpha = 0.8;

const double _kIconBoxSize = 40.0;

// Switcher / shimmer animation tuning.
const Duration _kSwitcherDuration = Duration(milliseconds: 300);
const Duration _kShimmerDelay = Duration(milliseconds: 1000);
const Duration _kShimmerDuration = Duration(milliseconds: 1200);

/// באנר הזמנות ממתינות - מציג כשיש הזמנות לרשימות/קבוצות.
///
/// Note: the underlying stream filters by `invited_user_id == userId`.
/// Invites that targeted an email (sent before the user registered) won't
/// surface here until they're re-resolved to a uid — that's an existing
/// limitation of `watchPendingInvitesForUser`, not something this widget
/// can fix.
class PendingInvitesBanner extends StatelessWidget {
  const PendingInvitesBanner({super.key});

  /// Cached service — avoid creating new instance per build.
  static final _service = PendingInvitesService();

  @override
  Widget build(BuildContext context) {
    // Only depend on userId — banner doesn't care about other UserContext
    // changes.
    final userId = context.select<UserContext, String?>((u) => u.userId);

    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<List<PendingRequest>>(
      stream: _service.watchPendingInvitesForUser(userId),
      initialData: const [],
      builder: (context, snapshot) {
        // Stream errors → hide silently. The pending-invites screen has a
        // proper error UI; the dashboard banner staying invisible is the
        // safer fallback than showing a stale or broken card.
        if (snapshot.hasError) {
          if (kDebugMode) {
            debugPrint('⚠️ PendingInvitesBanner: stream error: ${snapshot.error}');
          }
          return const SizedBox.shrink();
        }

        final invites = snapshot.data ?? const [];
        if (invites.isEmpty) return const SizedBox.shrink();

        return AnimatedSwitcher(
          duration: _kSwitcherDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _PendingInviteBannerContent(
            key: ValueKey(invites.first.id),
            invites: invites,
          ),
        );
      },
    );
  }
}

class _PendingInviteBannerContent extends StatefulWidget {
  final List<PendingRequest> invites;

  const _PendingInviteBannerContent({super.key, required this.invites});

  @override
  State<_PendingInviteBannerContent> createState() =>
      _PendingInviteBannerContentState();
}

class _PendingInviteBannerContentState
    extends State<_PendingInviteBannerContent> {
  // Reuse the parent's singleton — keeping a second `static final` here
  // would create a separate instance of the same service for no benefit.
  PendingInvitesService get _service => PendingInvitesBanner._service;

  /// Gmail-style undo: when the user taps ×, we hide the invite *locally*
  /// for 5 seconds and show a snackbar with "Undo". The actual decline
  /// API call only fires after the snackbar's duration elapses. This way
  /// an accidental decline is fully recoverable inside the undo window,
  /// without needing a service-level "undecline" operation.
  String? _pendingDeclineId;
  Timer? _declineTimer;

  @override
  void dispose() {
    _declineTimer?.cancel();
    super.dispose();
  }

  /// Hide the invite, schedule the decline, and show the undo snackbar.
  /// If the user taps "Undo" within the snackbar's 5-second window, the
  /// timer is cancelled and no API call is made.
  void _onDecline(PendingRequest invite) {
    if (_pendingDeclineId != null) return;

    final messenger = ScaffoldMessenger.of(context);
    final bannerStrings = AppStrings.pendingInviteBanner;
    final declineStrings = AppStrings.pendingInvitesScreen;
    final userId = context.read<UserContext>().userId;
    if (userId == null) return;

    unawaited(HapticFeedback.selectionClick());
    setState(() => _pendingDeclineId = invite.id);

    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(bannerStrings.declinePending),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: bannerStrings.undoLabel,
          onPressed: () {
            _declineTimer?.cancel();
            if (mounted) setState(() => _pendingDeclineId = null);
          },
        ),
      ));

    _declineTimer = Timer(const Duration(seconds: 5), () async {
      if (!mounted || _pendingDeclineId != invite.id) return;

      final result = await _service.declineInviteResult(
        inviteId: invite.id,
        decliningUserId: userId,
      );

      if (!mounted) return;
      setState(() => _pendingDeclineId = null);

      if (!result.isSuccess) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(declineStrings.declineError(result.errorMessage ?? '')),
            backgroundColor:
                StatusColors.getContainer(StatusType.error, context),
          ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter out any invite currently in its 5-second undo window so the
    // banner visually disappears the instant × is tapped. If every invite
    // is in that window, hide the whole banner.
    final invites = widget.invites
        .where((i) => i.id != _pendingDeclineId)
        .toList(growable: false);
    if (invites.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.pendingInviteBanner;
    // Accessibility label for the decline button — same string the
    // destination screen uses, so the affordance reads consistently.
    final inviteScreenStrings = AppStrings.pendingInvitesScreen;
    final firstInvite = invites.first;
    final radius = BorderRadius.circular(kBorderRadius);

    final inviterName = firstInvite.requesterName ?? firstInvite.requesterId;

    // Title + display-name pair adapt to the invite type:
    //  - inviteToList     → "Invitation to list" + the list's name
    //  - inviteToHousehold → "Invitation to household" + the household's name
    // Falls back through the legacy `group_name` key, then a generic
    // string. Without this the banner used to display "you were invited
    // to 'list'" (the literal fallback) on every household invite.
    final isHouseholdInvite =
        firstInvite.type == RequestType.inviteToHousehold;
    final title = isHouseholdInvite
        ? strings.titleHouseholdInvite
        : strings.titleListInvite;
    // Pick the right fallback string per type so that, when every
    // requestData key is missing, we don't say "you were invited to
    // 'list'" for a household invite (or vice versa).
    final groupName = isHouseholdInvite
        ? (firstInvite.requestData['household_name'] as String? ??
            firstInvite.requestData['group_name'] as String? ??
            firstInvite.requestData['list_name'] as String? ??
            AppStrings.pendingInvitesScreen.householdFallback)
        : (firstInvite.requestData['list_name'] as String? ??
            firstInvite.requestData['group_name'] as String? ??
            AppStrings.pendingInvitesScreen.listFallback);

    final subtitle = strings.inviteMessage(inviterName, groupName);

    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Container(
        margin: const EdgeInsets.only(bottom: kSpacingSmall),
        decoration: BoxDecoration(
          color: cs.tertiaryContainer.withValues(alpha: _kBgAlpha),
          borderRadius: radius,
          border: Border.all(
            color: cs.tertiary.withValues(alpha: _kBorderAlpha),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.tertiary.withValues(alpha: _kShadowAlpha),
              blurRadius: kSpacingSmall,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              unawaited(HapticFeedback.lightImpact());
              Navigator.pushNamed(context, '/pending-invites');
            },
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: _kIconBoxSize,
                      height: _kIconBoxSize,
                      decoration: BoxDecoration(
                        color: cs.tertiary.withValues(alpha: _kIconBgAlpha),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      child: _MailShimmerIcon(color: cs.tertiary),
                    ),
                  ),
                  const SizedBox(width: kSpacingMedium),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: cs.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (invites.length > 1) ...[
                                const SizedBox(width: kSpacingTiny),
                                _MoreInvitesBadge(
                                  remaining: invites.length - 1,
                                  label: strings.moreCount(invites.length - 1),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: kSpacingXTiny),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onTertiaryContainer
                                  .withValues(alpha: _kSubtitleAlpha),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Single inline action: decline. The banner itself is
                  // the "open & manage" target (its InkWell navigates to
                  // the dedicated screen) — a separate ✓ button used to
                  // duplicate that exact navigation, confusing users into
                  // thinking ✓ would accept inline. Now removed.
                  _DeclineButton(
                    label: inviteScreenStrings.declineLabel,
                    onTap: () => _onDecline(firstInvite),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Decline-only inline action. Tooltip was previously used as the visual
/// label, but per CLAUDE.md A11y policy "❌ לא — Tooltip על כל IconButton"
/// — Tooltip on mobile is invisible (no hover) and screen readers prefer
/// an explicit Semantics label. Same pattern fix applied earlier to
/// `household_activity_feed.dart`'s dismiss button.
class _DeclineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DeclineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(side: BorderSide(color: cs.outlineVariant)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(kSpacingSmall),
            child: Icon(
              Icons.close,
              color: cs.onSurfaceVariant,
              size: kIconSizeSmallPlus,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mail icon with a looping shimmer effect, extracted from the banner
/// build so its `Animate` widget keeps a stable element identity across
/// parent rebuilds. The previous inline version recreated the animation
/// chain on every rebuild — every Firestore stream event could leak a
/// fresh AnimationController.
class _MailShimmerIcon extends StatelessWidget {
  final Color color;

  const _MailShimmerIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.mail_outline,
      color: color,
      size: kIconSizeSmallPlus,
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          delay: _kShimmerDelay,
          duration: _kShimmerDuration,
          color: color.withValues(alpha: _kShimmerAlpha),
        );
  }
}

/// "+N" badge next to the title when there are extra invites. The badge
/// trails a small chevron so it visibly reads as "tap to see all" rather
/// than mere metadata. The whole banner is the actual tap target — this
/// widget is decoration that lives inside ExcludeSemantics.
class _MoreInvitesBadge extends StatelessWidget {
  final int remaining;
  final String label;

  const _MoreInvitesBadge({required this.remaining, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Chevron flips with locale: chevron_left is the "forward" arrow in
    // Hebrew RTL, chevron_right in English LTR.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final forwardChevron =
        isRtl ? Icons.chevron_left : Icons.chevron_right;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingTiny,
        vertical: kSpacingXTiny,
      ),
      decoration: BoxDecoration(
        color: cs.tertiary,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            forwardChevron,
            size: kFontSizeMedium,
            color: cs.onTertiary,
          ),
        ],
      ),
    );
  }
}
