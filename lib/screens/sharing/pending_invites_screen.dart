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
// Version 3.1 - Emoji icons → Material Icons
// Last Updated: 24/03/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/enums/request_type.dart';
import '../../models/enums/user_role.dart';
import '../../models/pending_request.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/user_context.dart';
import '../../services/pending_invites_service.dart';
import '../../widgets/dialogs/pantry_merge_dialog.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_error_state.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/app_loading_skeleton.dart';

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

    final result = await _invitesService.getPendingInvitesForUserResult(
      userId,
      userEmail: userEmail,
    );
    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _pendingInvites = result.invites ?? [];
        _isInitialLoading = false;
        _error = null;
      });
    } else if (!silent) {
      setState(() {
        _isInitialLoading = false;
        _error = AppStrings.pendingInvitesScreen.loadError;
      });
    }
  }

  Future<void> _acceptInvite(PendingRequest invite) async {
    if (_processingInviteId != null) return; // כבר מעבד הזמנה אחרת

    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final userName = userContext.user?.name;
    final userEmail = userContext.userEmail;
    // ✅ Cache before async
    final messenger = ScaffoldMessenger.of(context);
    final successBg = StatusColors.getContainer(StatusType.success, context);
    final errorBg = StatusColors.getContainer(StatusType.error, context);
    final strings = AppStrings.pendingInvitesScreen;

    if (userId == null) return;

    setState(() => _processingInviteId = invite.id);

    final result = await _invitesService.acceptInviteResult(
      inviteId: invite.id,
      acceptingUserId: userId,
      acceptingUserName: userName,
      acceptingUserEmail: userEmail,
    );

    if (!mounted) return;
    setState(() => _processingInviteId = null);

    if (result.isSuccess) {
      final isHousehold = invite.type == RequestType.inviteToHousehold;
      final successMsg = isHousehold
          ? AppStrings.settings.householdJoinedSuccess
          : strings.acceptSuccess(
              _safeString(invite.requestData['list_name']) ??
                  strings.listFallback);
      messenger.showSnackBar(
        SnackBar(content: Text(successMsg), backgroundColor: successBg),
      );
      if (isHousehold) {
        unawaited(userContext.refreshUser());
        // בדיקה אם יש מזווה אישי למיזוג
        if (mounted) {
          final inventoryProvider = context.read<InventoryProvider>();
          final hasPersonal = await inventoryProvider.hasPersonalInventory();
          if (hasPersonal && mounted) {
            final count = await inventoryProvider.getPersonalInventoryCount();
            if (count > 0 && mounted) {
              await showPantryMergeDialog(
                context: context,
                personalItemCount: count,
              );
              // TODO: implement actual merge logic when user confirms
            }
          }
        }
      }
      unawaited(_loadInvites());
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.acceptError(result.errorMessage ?? '')),
          backgroundColor: errorBg,
        ),
      );
    }
  }

  Future<void> _declineInvite(PendingRequest invite) async {
    if (_processingInviteId != null) return; // כבר מעבד הזמנה אחרת

    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final userName = userContext.user?.name;

    if (userId == null) return;

    // ✅ Cache before async
    final cs = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    final warningBg = StatusColors.getContainer(StatusType.warning, context);
    final errorBg = StatusColors.getContainer(StatusType.error, context);
    final strings = AppStrings.pendingInvitesScreen;
    final listName = _safeString(invite.requestData['list_name']) ?? strings.listFallback;

    // שאלת אישור
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.declineDialogTitle),
        content: Text(strings.declineDialogMessage(listName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            // ✅ Theme-aware: צבע שגיאה
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: Text(strings.declineConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _processingInviteId = invite.id);

    final result = await _invitesService.declineInviteResult(
      inviteId: invite.id,
      decliningUserId: userId,
      decliningUserName: userName,
    );

    if (!mounted) return;
    setState(() => _processingInviteId = null);

    if (result.isSuccess) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.declineSuccess), backgroundColor: warningBg),
      );
      unawaited(_loadInvites());
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.declineError(result.errorMessage ?? '')),
          backgroundColor: errorBg,
        ),
      );
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
            body: SafeArea(
              child: Column(
                children: [
                  // 📩 Inline header
                  Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(kBorderRadius),
                          child: Container(
                            padding: const EdgeInsets.all(kSpacingSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(kBorderRadius),
                            ),
                            child: Icon(Icons.arrow_forward_ios,
                                size: kIconSizeSmall,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Center(
                            child: Icon(Icons.mark_email_unread_outlined, color: Theme.of(context).colorScheme.primary, size: kIconSizeMedium),
                          ),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.pendingInvitesScreen.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_pendingInvites.isNotEmpty)
                                Text(
                                  '${_pendingInvites.length} ממתינות',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final cs = Theme.of(context).colorScheme;

    // 🔄 טעינה ראשונית - spinner במרכז
    if (_isInitialLoading) {
      return const AppLoadingSkeleton(sectionCount: 3, showHero: false);
    }

    // ❌ שגיאה - עם Pull-to-Refresh
    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _loadInvites,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: AppErrorState(
              message: _error!,
              onAction: _loadInvites,
              actionLabel: AppStrings.pendingInvitesScreen.retryButton,
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
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(kSpacingLarge),
                padding: const EdgeInsets.all(kSpacingXLarge),
                decoration: BoxDecoration(
                  // 🎨 בועה לבנה שקופה - נקי וקריא על רקע מחברת
                  color: cs.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: cs.scrim.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
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
                      child: Icon(Icons.mail_outline, size: kIconSizeXXLarge, color: cs.primary),
                    ),
                    SizedBox(height: kSpacingLarge),
                    Text(
                      AppStrings.pendingInvitesScreen.emptyTitle,
                      style: TextStyle(
                        fontSize: kFontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: kSpacingSmall),
                    Text(
                      AppStrings.pendingInvitesScreen.emptySubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    SizedBox(height: kSpacingLarge),
                    Text(
                      AppStrings.pendingInvitesScreen.pullToRefresh,
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
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
    final strings = AppStrings.pendingInvitesScreen;
    final isHouseholdInvite = invite.type == RequestType.inviteToHousehold;
    final listName = isHouseholdInvite
        ? (_safeString(invite.requestData['household_name']) ?? 'הבית')
        : (_safeString(invite.requestData['list_name']) ?? strings.listFallback);
    final inviterName = invite.requesterName ?? strings.userFallback;
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
                  Text(isHouseholdInvite ? '🏠' : '👥',
                      style: const TextStyle(fontSize: kFontSizeTitle)),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      isHouseholdInvite
                          ? 'הזמנה להצטרף ל$listName'
                          : strings.inviteToList(listName),
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
                strings.inviterMessage(inviterName),
                style: const TextStyle(fontSize: kFontSizeSmall),
              ),

              SizedBox(height: kSpacingTiny),

              // תפקיד
              Row(
                children: [
                  Text(
                    strings.roleLabel,
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

              SizedBox(height: kSpacingTiny),

              // זמן
              Text(
                timeago.format(invite.createdAt, locale: 'he'),
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
                        icon: const Icon(Icons.close, size: kFontSizeLarge),
                        label: Text(strings.declineButton),
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
                        icon: const Icon(Icons.check, size: kFontSizeLarge),
                        label: Text(strings.acceptButton),
                        style: ElevatedButton.styleFrom(
                          // ✅ Theme-aware: צבע הצלחה מ-AppBrand
                          backgroundColor: brand?.stickyGreen ?? kStickyGreen,
                          foregroundColor: cs.onSurface,
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
