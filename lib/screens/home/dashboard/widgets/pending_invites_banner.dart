// lib/screens/home/dashboard/widgets/pending_invites_banner.dart — Pending invites banner — notification about received list/household invitations

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

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

class _PendingInviteBannerContent extends StatelessWidget {
  final List<PendingRequest> invites;

  const _PendingInviteBannerContent({super.key, required this.invites});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.pendingInviteBanner;
    final firstInvite = invites.first;
    final radius = BorderRadius.circular(kBorderRadius);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

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
                  // אייקון מעטפה עם shimmer עדין למשוך תשומת לב
                  ExcludeSemantics(
                    child: Container(
                      width: _kIconBoxSize,
                      height: _kIconBoxSize,
                      decoration: BoxDecoration(
                        color: cs.tertiary.withValues(alpha: _kIconBgAlpha),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      child: Icon(
                        Icons.mail_outline,
                        color: cs.tertiary,
                        size: kIconSizeSmallPlus,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(
                            delay: _kShimmerDelay,
                            duration: _kShimmerDuration,
                            color: cs.tertiary.withValues(alpha: _kShimmerAlpha),
                          ),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: kSpacingTiny,
                                    vertical: kSpacingXTiny / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.tertiary,
                                    borderRadius:
                                        BorderRadius.circular(kBorderRadiusSmall),
                                  ),
                                  child: Text(
                                    strings.moreCount(invites.length - 1),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: cs.onTertiary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: kSpacingXTiny / 2),
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
                  Icon(
                    isRtl ? Icons.chevron_left : Icons.chevron_right,
                    color: cs.onTertiaryContainer,
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
