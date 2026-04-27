// lib/screens/auth/post_auth_navigation.dart — Post-auth navigation helper — checks for pending invites before routing to home

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../providers/user_context.dart';
import '../../services/pending_invites_service.dart';

/// בדיקת הזמנות ממתינות אחרי הרשמה/התחברות (כולל Google/Apple).
///
/// מחפש ב-Firestore גם לפי UID וגם לפי email — כדי שהזמנות שנשלחו
/// לפני שהמשתמש נרשם (`invited_user_id` היה email) יזוהו עכשיו.
///
/// אם יש הזמנה ממתינה — מנווט ל-`/pending-invites` (replace stack).
/// אחרת — מנווט ל-`/` (IndexScreen → home).
///
/// **Guard:** אם למשתמש אין email — דולג על הבדיקה ועובר ישירות לבית
/// (אין דרך לחפש הזמנות לפני-signup ללא email).
///
/// אם הקריאה ל-Firestore נכשלת — לא חוסם, ממשיך לבית. ה-banner
/// בדאשבורד יטפל ברקע אם חוזר online.
Future<void> navigateAfterAuth(
  BuildContext context,
  UserContext userContext, {
  PendingInvitesService? service,
}) async {
  final navigator = Navigator.of(context);
  final userId = userContext.userId;
  final userEmail = userContext.userEmail;

  // Guard: אין email/uid → אי אפשר לחפש הזמנות → ישר לבית
  if (userId == null || userEmail == null || userEmail.trim().isEmpty) {
    await navigator.pushNamedAndRemoveUntil('/', (_) => false);
    return;
  }

  try {
    final svc = service ?? PendingInvitesService();
    final result = await svc.getPendingInvitesForUserResult(
      userId,
      userEmail: userEmail,
    );

    final invites = result.invites;
    if (result.isSuccess && invites != null && invites.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
            '📬 navigateAfterAuth | Found ${invites.length} pending invite(s) → /pending-invites');
      }
      await navigator.pushNamedAndRemoveUntil(
          '/pending-invites', (_) => false);
      return;
    }
  } catch (e) {
    // Non-fatal: log + continue to home
    if (kDebugMode) {
      debugPrint('⚠️ navigateAfterAuth | check failed: $e (continuing to /)');
    }
  }

  await navigator.pushNamedAndRemoveUntil('/', (_) => false);
}
