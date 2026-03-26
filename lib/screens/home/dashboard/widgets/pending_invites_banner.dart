// 📄 lib/screens/home/dashboard/widgets/pending_invites_banner.dart
//
// באנר הזמנות ממתינות - מוצג כשיש הזמנות שטרם טופלו
// ✨ v2.1: Shimmer מהיר יותר, ספירת תגית מדויקת, ללא התנגשות אנימציות, ותיקוני const
//
// Version: 2.1 (22/02/2026)
// 🔗 Related: PendingInvitesService, UserContext

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/pending_request.dart';
import '../../../../providers/user_context.dart';
import '../../../../services/pending_invites_service.dart';

/// באנר הזמנות ממתינות - מציג כשיש הזמנות לרשימות/קבוצות
class PendingInvitesBanner extends StatelessWidget {
  const PendingInvitesBanner({super.key});

  /// Cached service — avoid creating new instance per build
  static final _service = PendingInvitesService();

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();
    final userId = userContext.userId;

    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<List<PendingRequest>>(
      stream: _service.watchPendingInvitesForUser(userId),
      initialData: const [],
      builder: (context, snapshot) {
        final invites = snapshot.data ?? [];
        if (invites.isEmpty) return const SizedBox.shrink();

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _PendingInviteBannerContent(key: ValueKey(invites.first.id), invites: invites),
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

    final inviterName = firstInvite.requesterName ?? firstInvite.requesterId;

    // טיפול חכם בשם חסר (Empty State Fallbacks)
    final groupName =
        firstInvite.requestData['list_name'] as String? ?? firstInvite.requestData['group_name'] as String? ?? AppStrings.pendingInvitesScreen.listFallback;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: cs.tertiary.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            unawaited(HapticFeedback.lightImpact());
            Navigator.pushNamed(context, '/pending-invites');
          },
          borderRadius: BorderRadius.circular(kBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Row(
              children: [
                // אייקון
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Icon(Icons.mail_outline, color: cs.tertiary, size: 22)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(
                        // קיצור זמני אנימציה ל-1000ms
                        delay: 1000.ms,
                        duration: 1200.ms,
                        color: cs.tertiary.withValues(alpha: 0.3),
                      ),
                ),
                const SizedBox(width: kSpacingMedium),
                // טקסט
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            strings.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: cs.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (invites.length > 1) ...[
                            // תיקון Const לביצועים
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.tertiary,
                                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                              ),
                              child: Text(
                                // מספר ההזמנות - שארית בלבד
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
                      // תיקון Const לביצועים
                      const SizedBox(height: 2),
                      Text(
                        strings.inviteMessage(inviterName, groupName),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onTertiaryContainer.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // חץ
                Icon(
                  Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right,
                  color: cs.onTertiaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
