// 📄 File: lib/screens/sharing/pending_invites_screen.dart
//
// 🎯 Purpose: מסך הזמנות ממתינות - לאישור או דחיית הזמנות לרשימות
//
// 📋 Features:
// - תצוגת הזמנות ממתינות
// - אישור הזמנה (הצטרפות לרשימה)
// - דחיית הזמנה
// - Real-time updates
//
// 🔗 Related:
// - pending_invites_service.dart - שירות ניהול הזמנות
// - invite_users_screen.dart - מסך שליחת הזמנות
//
// Version 3.0 - Hybrid: NotebookBackground + AppBar
// Last Updated: 13/01/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../models/enums/user_role.dart';
import '../../models/pending_request.dart';
import '../../providers/user_context.dart';
import '../../services/pending_invites_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';

class PendingInvitesScreen extends StatefulWidget {
  const PendingInvitesScreen({super.key});

  @override
  State<PendingInvitesScreen> createState() => _PendingInvitesScreenState();
}

class _PendingInvitesScreenState extends State<PendingInvitesScreen> {
  late final PendingInvitesService _invitesService;
  List<PendingRequest> _pendingInvites = [];
  bool _isInitialLoading = true; // רק לטעינה ראשונית
  String? _processingInviteId; // ID של ההזמנה שבעיבוד (null = אף אחת)
  String? _error;
  Timer? _refreshTimer;

  // 🔄 רענון אוטומטי כל 30 שניות (כמעט real-time)
  static const Duration _refreshInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _invitesService = PendingInvitesService();
    _loadInvites();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted && _processingInviteId == null) {
        _loadInvites(silent: true); // רענון שקט ללא spinner
      }
    });
  }

  Future<void> _loadInvites({bool silent = false}) async {
    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final userEmail = userContext.user?.email;

    // ✅ FIX: אם אין משתמש - מעבירים ל-Login (לא מציגים הודעת שגיאה)
    if (userId == null) {
      if (mounted) {
        unawaited(Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false));
      }
      return;
    }

    try {
      // 🔍 חיפוש לפי UID ואימייל (למקרה שהוזמן לפני הרשמה)
      final invites = await _invitesService.getPendingInvitesForUser(
        userId,
        userEmail: userEmail,
      );
      if (mounted) {
        setState(() {
          _pendingInvites = invites;
          _isInitialLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _isInitialLoading = false;
          _error = 'שגיאה בטעינת הזמנות';
        });
      }
    }
  }

  Future<void> _acceptInvite(PendingRequest invite) async {
    if (_processingInviteId != null) return; // כבר מעבד הזמנה אחרת

    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final userName = userContext.user?.name;

    if (userId == null) return;

    setState(() => _processingInviteId = invite.id);

    try {
      await _invitesService.acceptInvite(
        inviteId: invite.id,
        acceptingUserId: userId,
        acceptingUserName: userName,
      );

      if (mounted) {
        final listName = _safeString(invite.requestData['list_name']) ?? 'רשימה';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('הצטרפת לרשימה "$listName"'),
            // ✅ Theme-aware: StatusColors API
            backgroundColor: StatusColors.getStatusContainer('success', context),
          ),
        );
        setState(() => _processingInviteId = null);
        unawaited(_loadInvites()); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processingInviteId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה באישור ההזמנה: $e'),
            // ✅ Theme-aware: StatusColors API
            backgroundColor: StatusColors.getStatusContainer('error', context),
          ),
        );
      }
    }
  }

  Future<void> _declineInvite(PendingRequest invite) async {
    if (_processingInviteId != null) return; // כבר מעבד הזמנה אחרת

    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final userName = userContext.user?.name;

    if (userId == null) return;

    final cs = Theme.of(context).colorScheme;
    final listName = _safeString(invite.requestData['list_name']) ?? 'רשימה';

    // שאלת אישור
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('דחיית הזמנה'),
        content: Text('לדחות את ההזמנה לרשימה "$listName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            // ✅ Theme-aware: צבע שגיאה
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('דחה'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _processingInviteId = invite.id);

    try {
      await _invitesService.declineInvite(
        inviteId: invite.id,
        decliningUserId: userId,
        decliningUserName: userName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ההזמנה נדחתה'),
            // ✅ Theme-aware: StatusColors API
            backgroundColor: StatusColors.getStatusContainer('warning', context),
          ),
        );
        setState(() => _processingInviteId = null);
        unawaited(_loadInvites()); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processingInviteId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בדחיית ההזמנה: $e'),
            // ✅ Theme-aware: StatusColors API
            backgroundColor: StatusColors.getStatusContainer('error', context),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          const NotebookBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('הזמנות ממתינות'),
              centerTitle: true,
            ),
            body: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    // 🔄 טעינה ראשונית - spinner במרכז
    if (_isInitialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: brand?.stickyCyan ?? cs.primary),
            const SizedBox(height: kSpacingMedium),
            const Text('טוען הזמנות...'),
          ],
        ),
      );
    }

    // ❌ שגיאה - עם Pull-to-Refresh
    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _loadInvites,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(kSpacingLarge),
                padding: const EdgeInsets.all(kSpacingXLarge),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(kSpacingLarge),
                      decoration: BoxDecoration(
                        color: cs.errorContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.error_outline, size: 64, color: cs.error),
                    ),
                    const SizedBox(height: kSpacingLarge),
                    Text(_error!, style: TextStyle(color: cs.error, fontWeight: FontWeight.bold)),
                    const SizedBox(height: kSpacingMedium),
                    ElevatedButton.icon(
                      onPressed: _loadInvites,
                      icon: const Icon(Icons.refresh),
                      label: const Text('נסה שוב'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 📭 אין הזמנות - עם Pull-to-Refresh ובועה לבנה
    if (_pendingInvites.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadInvites,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(kSpacingLarge),
                padding: const EdgeInsets.all(kSpacingXLarge),
                decoration: BoxDecoration(
                  // 🎨 בועה לבנה שקופה - נקי וקריא על רקע מחברת
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(kSpacingLarge),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mail_outline, size: 64, color: cs.primary),
                    ),
                    const SizedBox(height: kSpacingLarge),
                    Text(
                      'אין הזמנות ממתינות',
                      style: TextStyle(
                        fontSize: kFontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: kSpacingSmall),
                    Text(
                      'כאשר מישהו יזמין אותך לרשימה,\nההזמנה תופיע כאן',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: kSpacingLarge),
                    Text(
                      '↓ משוך לרענון',
                      style: TextStyle(fontSize: kFontSizeTiny, color: cs.outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 📋 יש הזמנות - רשימה עם Pull-to-Refresh
    return RefreshIndicator(
      onRefresh: _loadInvites,
      child: ListView.builder(
        padding: const EdgeInsets.all(kSpacingMedium),
        itemCount: _pendingInvites.length,
        itemBuilder: (context, index) {
          final invite = _pendingInvites[index];
          return _buildInviteCard(invite);
        },
      ),
    );
  }

  Widget _buildInviteCard(PendingRequest invite) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    // ✅ null safety - גישה בטוחה ל-requestData
    final listName = _safeString(invite.requestData['list_name']) ?? 'רשימה';
    final inviterName = invite.requesterName ?? 'משתמש';
    final roleName = _safeString(invite.requestData['role']) ?? 'editor';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => UserRole.editor,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingMedium),
      child: StickyNote(
        // ✅ Theme-aware: צבע פתק מ-AppBrand
        color: brand?.stickyYellow ?? kStickyYellow,
        rotation: 0.01,
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // כותרת
              Row(
                children: [
                  const Text('👥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'הזמנה לרשימה "$listName"',
                      style: const TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: kSpacingSmall),

              // פרטי ההזמנה
              Text(
                '$inviterName מזמין אותך להצטרף',
                style: const TextStyle(fontSize: kFontSizeSmall),
              ),

              const SizedBox(height: kSpacingTiny),

              // תפקיד
              Row(
                children: [
                  Text(
                    'תפקיד: ',
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingSmall,
                      vertical: kSpacingXTiny,
                    ),
                    decoration: BoxDecoration(
                      // ✅ Theme-aware: צבע תפקיד
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      '${role.emoji} ${role.hebrewName}',
                      style: TextStyle(
                        fontSize: kFontSizeTiny,
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: kSpacingTiny),

              // זמן
              Text(
                invite.timeAgoText,
                style: TextStyle(
                  fontSize: kFontSizeTiny,
                  color: cs.outline,
                ),
              ),

              const SizedBox(height: kSpacingMedium),

              // כפתורי פעולה או spinner
              if (_processingInviteId == invite.id)
                // 🔄 מעבד הזמנה זו
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: kSpacingSmall),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    // דחה
                    Expanded(
                      child: OutlinedButton.icon(
                        // נעול אם מעבדים הזמנה אחרת
                        onPressed: _processingInviteId != null ? null : () => _declineInvite(invite),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('דחה'),
                        style: OutlinedButton.styleFrom(
                          // ✅ Theme-aware: צבע שגיאה
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.error),
                        ),
                      ),
                    ),

                    const SizedBox(width: kSpacingSmall),

                    // אשר
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        // נעול אם מעבדים הזמנה אחרת
                        onPressed: _processingInviteId != null ? null : () => _acceptInvite(invite),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('הצטרף'),
                        style: ElevatedButton.styleFrom(
                          // ✅ Theme-aware: צבע הצלחה מ-AppBrand
                          backgroundColor: brand?.stickyGreen ?? StatusColors.success,
                          foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Helper: גישה בטוחה ל-String מ-dynamic
  String? _safeString(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return null;
  }
}
