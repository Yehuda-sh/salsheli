// lib/screens/home/dashboard/widgets/pending_actions_card.dart — Unified pending actions card — replaces 3 separate banners (invite / email verify / invite family) with a single uniform card

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/error_utils.dart';
import '../../../../core/status_colors.dart';
import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/enums/request_type.dart';
import '../../../../models/pending_request.dart';
import '../../../../providers/user_context.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/pending_invites_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/common/household_invite_dialog.dart';

/// 🎯 כרטיס "פעולות ממתינות" — מאחד 3 הבאנרים השונים שהיו במסך הבית:
///
/// 1. **הזמנות ממתינות** (היו ב-`PendingInvitesBanner`) — stream של
///    invites נכנסים. עדיפות בינונית — סטיקי-גרין.
/// 2. **אימות אימייל** (היה ב-`EmailVerificationBanner`) — אם המשתמש לא
///    אימת אימייל. עדיפות גבוהה — סטיקי-פינק (קריטי = חוסם הזמנות).
/// 3. **הזמן את הבית** (היה inline ב-`_buildInviteFamilyBanner`) — אם
///    המשתמש solo. עדיפות נמוכה — סטיקי-יילו (אופציונלי).
///
/// העיצוב: כרטיס יחיד עם header צבעוני, שורות אחידות עם
/// `_ActionRow` (אייקון בעיגול → כותרת → תת-כותרת → chevron). Swipe-to-
/// dismiss בכיוון RTL → ימני-לשמאלי (DismissDirection.endToStart).
///
/// כל ה-3 הבאנרים הקודמים הוסרו ממסך הבית בעת ההטמעה.
class PendingActionsCard extends StatefulWidget {
  const PendingActionsCard({super.key});

  @override
  State<PendingActionsCard> createState() => _PendingActionsCardState();
}

class _PendingActionsCardState extends State<PendingActionsCard>
    with WidgetsBindingObserver {
  // Cached service — single instance for the lifetime of the widget.
  final _invitesService = PendingInvitesService();

  // In-memory dismissals — reset on cold start so an accidental swipe
  // doesn't permanently bury a real action.
  bool _emailVerifyDismissed = false;
  bool _inviteFamilyDismissed = false;
  // Email-send state (existing UX from EmailVerificationBanner)
  bool _isSending = false;

  // Pending decline (Gmail-style 5-second undo)
  String? _pendingDeclineId;
  Timer? _declineTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _declineTimer?.cancel();
    super.dispose();
  }

  /// כשהאפליקציה חוזרת מ-background — לבדוק אם המשתמש אימת בינתיים.
  /// (פטרן מה-EmailVerificationBanner המקורי.)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_emailVerifyDismissed) {
      _checkEmailVerified();
    }
  }

  Future<void> _checkEmailVerified() async {
    if (!mounted) return;
    if (context.read<UserContext>().isEmailVerified) return;
    try {
      await context.read<AuthService>().reloadUser();
      if (!mounted) return;
      if (context.read<UserContext>().isEmailVerified) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(AppStrings.auth.emailVerifiedSuccess)),
          );
      }
      // Force rebuild so the row disappears.
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PendingActionsCard.reloadUser failed: $e');
      }
    }
  }

  Future<void> _sendVerification() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    unawaited(HapticFeedback.lightImpact());
    try {
      await context.read<AuthService>().sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppStrings.auth.verificationEmailSent)),
        );
      setState(() => _emailVerifyDismissed = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(userFriendlyError(e, context: 'sendEmailVerification')),
          ),
        );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// Gmail-style decline (5-sec undo). Lifted from `PendingInvitesBanner`.
  void _declineInvite(PendingRequest invite) {
    if (_pendingDeclineId != null) return;

    final messenger = ScaffoldMessenger.of(context);
    final bannerStrings = AppStrings.pendingInviteBanner;
    final screenStrings = AppStrings.pendingInvitesScreen;
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
      final result = await _invitesService.declineInviteResult(
        inviteId: invite.id,
        decliningUserId: userId,
      );
      if (!mounted) return;
      setState(() => _pendingDeclineId = null);
      if (!result.isSuccess) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(screenStrings.declineError(result.errorMessage ?? '')),
            backgroundColor:
                StatusColors.getContainer(StatusType.error, context),
          ));
      }
    });
  }

  /// Resolve title + subtitle for an invite, mirroring the logic that used
  /// to live in `PendingInvitesBanner._build`.
  ({String title, String subtitle}) _inviteCopy(PendingRequest invite) {
    final strings = AppStrings.pendingInviteBanner;
    final screenStrings = AppStrings.pendingInvitesScreen;
    final isHousehold = invite.type == RequestType.inviteToHousehold;
    final title = isHousehold
        ? strings.titleHouseholdInvite
        : strings.titleListInvite;
    final inviterName = invite.requesterName ?? invite.requesterId;
    final groupName = isHousehold
        ? (invite.requestData['household_name'] as String? ??
            invite.requestData['group_name'] as String? ??
            invite.requestData['list_name'] as String? ??
            screenStrings.householdFallback)
        : (invite.requestData['list_name'] as String? ??
            invite.requestData['group_name'] as String? ??
            screenStrings.listFallback);
    return (title: title, subtitle: strings.inviteMessage(inviterName, groupName));
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();
    final userId = userContext.userId;

    if (userId == null || !userContext.isLoggedIn) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<PendingRequest>>(
      stream: _invitesService.watchPendingInvitesForUser(userId),
      initialData: const [],
      builder: (context, snapshot) {
        if (snapshot.hasError && kDebugMode) {
          debugPrint('PendingActionsCard: invites stream error: ${snapshot.error}');
        }
        final invites = (snapshot.data ?? const [])
            .where((i) => i.id != _pendingDeclineId)
            .toList(growable: false);

        final showEmailVerify =
            !userContext.isEmailVerified && !_emailVerifyDismissed;
        final isSolo = userContext.user?.isSolo ?? false;
        // Hide invite-family while there are pending invites OR while email
        // verify is still showing — keeps the card focused on critical
        // actions first.
        final showInviteFamily =
            isSolo && !_inviteFamilyDismissed && invites.isEmpty;

        if (!showEmailVerify && invites.isEmpty && !showInviteFamily) {
          return const SizedBox.shrink();
        }

        final actions = <_ActionData>[];

        // Priority 1: email verification (critical — blocks invite flow)
        if (showEmailVerify) {
          actions.add(_ActionData(
            id: 'email_verify',
            priorityColor: _Priority.critical,
            // shield = "verify your identity" semantic — distinct from the
            // person/group icons below which represent people-related actions.
            icon: Icons.verified_user_outlined,
            title: AppStrings.pendingActions.emailVerifyTitle,
            subtitle: AppStrings.pendingActions.emailVerifySubtitle,
            isLoading: _isSending,
            onTap: _sendVerification,
            onDismiss: () => setState(() => _emailVerifyDismissed = true),
          ));
        }

        // Priority 2: pending invites (positive action available)
        for (final invite in invites) {
          final copy = _inviteCopy(invite);
          actions.add(_ActionData(
            id: 'invite_${invite.id}',
            priorityColor: _Priority.positive,
            // person_add = "someone wants to add YOU" — semantically the
            // opposite of group_add (used below for "YOU should invite").
            icon: Icons.person_add_alt_1_outlined,
            title: copy.title,
            subtitle: copy.subtitle,
            onTap: () {
              unawaited(HapticFeedback.lightImpact());
              Navigator.pushNamed(context, '/pending-invites');
            },
            onDismiss: () => _declineInvite(invite),
          ));
        }

        // Priority 3: invite family (optional — only when above are clear)
        if (showInviteFamily) {
          actions.add(_ActionData(
            id: 'invite_family',
            priorityColor: _Priority.optional,
            icon: Icons.group_add_outlined,
            title: AppStrings.homeDashboard.inviteFamilyTitle,
            subtitle: AppStrings.pendingActions.inviteFamilyShortSubtitle,
            onTap: () {
              unawaited(HapticFeedback.lightImpact());
              showHouseholdInviteDialog(context);
            },
            onDismiss: () => setState(() => _inviteFamilyDismissed = true),
          ));
        }

        return _buildCard(context, actions);
      },
    );
  }

  Widget _buildCard(BuildContext context, List<_ActionData> actions) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final stickyYellow = brand?.stickyYellow ?? kStickyYellow;
    final stickyPink = brand?.stickyPink ?? kStickyPink;

    // Subtle -0.5° tilt — same family as the suggestion cards below
    // (which rotate ±1°). Without it the card reads as a Material
    // rectangle disconnected from the surrounding sticky-note language.
    return Transform.rotate(
      angle: -0.008,
      child: Container(
        margin: const EdgeInsets.only(bottom: kSpacingSmall),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: kOpacityHigh),
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          border: Border.all(
            color: cs.outline.withValues(alpha: kOpacityLight),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: kOpacitySubtle),
              blurRadius: 8,
              offset: const Offset(1, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ⚡ Header — sticky-yellow band with a pink "washi-tape" strip
            // peeking from the trailing corner. The tape ties the card to
            // the scrapbook personality of the rest of the home screen.
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium,
                    vertical: kSpacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: stickyYellow.withValues(alpha: kOpacityStrong),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(kBorderRadiusLarge),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bolt, size: kIconSizeSmallPlus, color: cs.onSurface),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        AppStrings.pendingActions.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSpacingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: kOpacityLight),
                          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                        ),
                        child: Text(
                          '${actions.length}',
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Pink washi-tape strip — angled, peeks above the header to
                // suggest a card "taped down" to the notebook page.
                PositionedDirectional(
                  top: -4,
                  start: kSpacingLarge,
                  child: Transform.rotate(
                    angle: -0.12,
                    child: Container(
                      width: kSpacingXLarge,
                      height: kSpacingSmallPlus,
                      decoration: BoxDecoration(
                        color: stickyPink.withValues(alpha: kOpacityStrong),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: kOpacitySubtle),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          // Rows separated by hairline dividers.
          ...actions.asMap().entries.map((entry) {
            final i = entry.key;
            final action = entry.value;
            return Column(
              key: ValueKey(action.id),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: kSpacingMedium,
                    endIndent: kSpacingMedium,
                    color: cs.outline.withValues(alpha: kOpacityLow),
                  ),
                _ActionRow(action: action),
              ],
            );
          }),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Internal: action data + row widget
// ════════════════════════════════════════════════════════════════════════

/// Visual priority — drives the icon-circle color. Maps to the sticky-note
/// palette so the card stays in the app's design language.
enum _Priority { critical, positive, optional }

class _ActionData {
  final String id;
  final _Priority priorityColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  _ActionData({
    required this.id,
    required this.priorityColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onDismiss,
    this.isLoading = false,
  });
}

class _ActionRow extends StatelessWidget {
  final _ActionData action;
  const _ActionRow({required this.action});

  Color _resolvePriorityColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    switch (action.priorityColor) {
      case _Priority.critical:
        return brand?.stickyPink ?? kStickyPink;
      case _Priority.positive:
        return brand?.stickyGreen ?? kStickyGreen;
      case _Priority.optional:
        // Yellow on yellow header would clash — use cyan as a calm
        // "optional / info" tone instead.
        return brand?.stickyCyan ?? cs.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final priorityColor = _resolvePriorityColor(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    // iOS-style thin chevrons — visually distinct from the title text
    // weight, unlike the chunkier Icons.chevron_*. In Hebrew RTL the
    // "forward / continue" direction is leftward, so arrow_back_ios_new
    // (which is a left-pointing arrow) is the correct "go ahead" cue;
    // in LTR we flip to arrow_forward_ios.
    final forwardChevron =
        isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios;

    final content = InkWell(
      onTap: action.isLoading
          ? null
          : () {
              unawaited(HapticFeedback.lightImpact());
              action.onTap();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingMedium,
          vertical: kSpacingSmallPlus,
        ),
        child: Row(
          children: [
            // Icon circle — priority color at sticky-note strength
            // (kOpacityStrong, matches the vibrancy of the suggestion
            // cards below; kOpacityMedium read as washed-out).
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: kOpacityStrong),
                shape: BoxShape.circle,
              ),
              child: action.isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(kSpacingSmall),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: priorityColor,
                      ),
                    )
                  : Icon(
                      action.icon,
                      color: priorityColor,
                      size: kIconSizeSmallPlus,
                    ),
            ),
            const SizedBox(width: kSpacingMedium),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: kSpacingSmall),
            Icon(forwardChevron, size: kIconSizeSmall, color: cs.outline),
          ],
        ),
      ),
    );

    if (action.onDismiss == null) return content;

    // Swipe-to-dismiss — endToStart works for both RTL and LTR because
    // Dismissible interprets "end" via the parent Directionality.
    return Dismissible(
      key: ValueKey(action.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: cs.errorContainer.withValues(alpha: kOpacityLight),
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: kSpacingMedium),
        child: Icon(Icons.close, color: cs.error, size: kIconSizeSmallPlus),
      ),
      onDismissed: (_) => action.onDismiss!(),
      child: content,
    );
  }
}
