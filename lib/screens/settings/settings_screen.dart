// 📄 File: lib/screens/settings/settings_screen.dart
//
// 🎯 תיאור: מסך הגדרות ופרופיל משולב - ניהול פרופיל אישי, הגדרות קבוצה, והעדפות
//
// 🔧 תכונות:
// ✅ פרופיל אישי מחובר ל-UserContext (שם, אימייל, תמונה)
// ✅ הגדרות התראות עם שמירה ב-SharedPreferences
// ✅ ערכת נושא (בהיר/כהה/מערכת)
// ✅ קישורים מהירים למסכים נוספים
// ✅ התנתקות בטוחה
// ✅ Logging מפורט
// ✅ Visual Feedback
// ✅ i18n ready (AppStrings)
// ✅ 🎬 Modern UI/UX: Animations + Skeleton + AnimatedCounter ⭐
// ✅ ♿ Accessibility מלא
//
// 🎬 Animations (v3.0):
// - AnimatedCounter על סטטיסטיקות (0 → value)
// - SimpleTappableCard על כרטיסי סטטיסטיקות (scale + haptic)
// - Skeleton Screen ל-Loading State
//
// 🔗 תלויות:
// - UserContext (Provider)
// - AuthService (Provider)
// - SharedPreferences (שמירת הגדרות מקומית)
// - TutorialService
//
// 📊 Flow:
// 1. טעינת הגדרות התראות מ-SharedPreferences
// 2. הצגת פרופיל + הגדרות
// 3. עריכת הגדרות → שמירה אוטומטית
// 4. התנתקות → ניקוי + חזרה ל-login
//
// Version: 3.5 - Clean Material Design (no Sticky Notes)
// Last Updated: 27/01/2026

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/l10n/locale_manager.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/widgets/common/skeleton_loader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/settings/household_members_screen.dart';
import '../../services/auth_service.dart';
import '../../services/pending_invites_service.dart';
import '../../services/tutorial_service.dart';
import '../../widgets/dialogs/legal_content_dialog.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 7;
  // Keys לשמירה מקומית - התראות
  static const _kNotifyShopping = 'settings.notify.shopping';
  static const _kNotifyGroup = 'settings.notify.group';
  static const _kNotifyReminders = 'settings.notify.reminders';
  static const _kNotifyListUpdates = 'settings.notify.listUpdates';

  // מצב UI - התראות
  bool _notifyShopping = true;
  bool _notifyGroup = true;
  bool _notifyReminders = true;
  bool _notifyListUpdates = false; // כבוי כברירת מחדל — יכול להציף

  // הרשאות משפחה
  bool _isHouseholdAdmin = false;

  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(parent: _animController, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });
    _loadSettings();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// טעינת הגדרות מ-SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // ✅ Guard: וידוא שהמסך עדיין קיים לפני setState
      if (!mounted) return;
      // בדיקת הרשאת admin ב-household
      final userContext = context.read<UserContext>();
      final householdId = userContext.householdId;
      final userId = userContext.userId;
      bool isAdmin = false;
      if (householdId != null && userId != null) {
        try {
          final memberDoc = await FirebaseFirestore.instance
              .collection('households')
              .doc(householdId)
              .collection('members')
              .doc(userId)
              .get();
          isAdmin = memberDoc.exists &&
              (memberDoc.data()?['role'] == 'admin' || memberDoc.data()?['role'] == 'owner');
        } catch (_) {
          // Silent — default to non-admin
        }
      }

      if (!mounted) return;
      setState(() {
        _notifyShopping = prefs.getBool(_kNotifyShopping) ?? true;
        _notifyGroup = prefs.getBool(_kNotifyGroup) ?? true;
        _notifyReminders = prefs.getBool(_kNotifyReminders) ?? true;
        _notifyListUpdates = prefs.getBool(_kNotifyListUpdates) ?? false;
        _isHouseholdAdmin = isAdmin;
        _loading = false;
        _errorMessage = null;
      });
      unawaited(_animController.forward());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppStrings.settings.loadError(e.toString());
        _loading = false;
      });
    }
  }

  /// שמירת הגדרת התראה
  Future<void> _saveNotificationSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
    }
  }

  /// התנתקות רגילה (שומר seenOnboarding)
  Future<void> _logout() async {
    final cs = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.settings.logoutTitle),
        content: Text(AppStrings.settings.logoutMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.settings.logoutCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.settings.logoutConfirm,
              style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {

      try {
        if (!mounted) return;
        unawaited(showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PopScope(
            canPop: false,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(kSpacingLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: kSpacingMedium),
                      Text('מתנתק...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));

        // ✅ signOut() שומר seenOnboarding (לפי Guardrails)
        await context.read<UserContext>().signOut();


        if (!mounted) return;
        Navigator.of(context).pop();
        unawaited(Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false));
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה בהתנתקות: $e'), backgroundColor: cs.error, duration: kSnackBarDurationLong),
        );
      }
    } else {
    }
  }

  /// 🔧 DEBUG ONLY: מחיקת כל הנתונים (כולל seenOnboarding)
  Future<void> _debugClearAllData() async {
    final cs = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔧 DEBUG: מחיקת כל הנתונים'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('פעולה זו תמחק הכל כולל seenOnboarding.\nתחזור למסך Welcome.'),
            SizedBox(height: kSpacingMedium),
            Container(
              padding: const EdgeInsets.all(kSpacingSmall),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(kBorderRadius),
                border: Border.all(color: cs.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.bug_report, color: cs.error, size: kIconSizeMedium),
                  SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'זמין רק ב-Debug Mode',
                      style: TextStyle(fontSize: kFontSizeSmall, color: cs.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ביטול')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('מחק הכל', style: TextStyle(color: cs.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {

      try {
        if (!mounted) return;
        unawaited(showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PopScope(
            canPop: false,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(kSpacingLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: kSpacingMedium),
                      Text('מוחק נתונים...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));

        await context.read<UserContext>().signOutAndClearAllData();


        if (!mounted) return;
        Navigator.of(context).pop();
        // ✅ ניווט ל-/ (IndexScreen) - יזרום אוטומטית ל-Welcome כי seenOnboarding=false
        unawaited(Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false));
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה במחיקה: $e'), backgroundColor: cs.error, duration: kSnackBarDurationLong),
        );
      }
    }
  }

  /// retry אחרי שגיאה
  void _retry() {
    setState(() {
      _errorMessage = null;
      _loading = true;
    });
    _loadSettings();
  }

  /// 🗑️ דיאלוג מחיקת חשבון (GDPR)
  Future<void> _showDeleteAccountDialog() async {
    final cs = Theme.of(context).colorScheme;
    final confirmController = TextEditingController();
    bool isDeleting = false;

    // שומרים הפניות לפני פתיחת הדיאלוג (נמנע מבעיות async context)
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authService = context.read<AuthService>();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final isConfirmValid = confirmController.text == AppStrings.settings.deleteAccountConfirmText;

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: cs.error, size: 28),
                SizedBox(width: kSpacingSmall),
                Text(
                  AppStrings.settings.deleteAccountTitle,
                  style: TextStyle(color: cs.error),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      border: Border.all(color: cs.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      AppStrings.settings.deleteAccountWarning,
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),
                  Text(
                    AppStrings.settings.deleteAccountConfirmLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kSpacingSmall),
                  TextField(
                    controller: confirmController,
                    decoration: InputDecoration(
                      hintText: AppStrings.settings.deleteAccountConfirmText,
                      border: const OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(dialogCtx, false),
                child: Text(AppStrings.settings.logoutCancel),
              ),
              FilledButton(
                onPressed: isDeleting || !isConfirmValid
                    ? null
                    : () async {
                        setDialogState(() => isDeleting = true);
                        final navigator = Navigator.of(dialogCtx);

                        try {
                          await authService.deleteAccount();

                          if (!mounted) return;
                          navigator.pop(true);
                        } on AuthException catch (e) {
                          setDialogState(() => isDeleting = false);

                          if (e.code == AuthErrorCode.requiresRecentLogin) {
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.settings.deleteAccountRequiresReauth),
                                backgroundColor: cs.tertiary,
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.settings.deleteAccountError(e.message)),
                                backgroundColor: cs.error,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isDeleting = false);
                          if (!mounted) return;
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(AppStrings.settings.deleteAccountError(e.toString())),
                              backgroundColor: cs.error,
                            ),
                          );
                        }
                      },
                style: FilledButton.styleFrom(backgroundColor: cs.error),
                child: isDeleting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                      )
                    : Text(AppStrings.settings.deleteAccountButton),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.settings.deleteAccountSuccess),
          backgroundColor: cs.primary,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        // ✅ ניווט ל-/ (IndexScreen) - יזרום אוטומטית ל-Welcome (חשבון נמחק = משתמש חדש)
        unawaited(Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false));
      }
    }
  }

  /// רשימת אווטארים לבחירה
  static const List<String> _avatarOptions = [
    '👤', '👩', '👨', '👧', '👦', '👴', '👵',
    '🧑‍🍳', '🛒', '🏠', '👨‍👩‍👧', '👨‍👩‍👧‍👦',
    '🌟', '💜', '💚', '🧡', '💙', '❤️',
  ];

  /// דיאלוג לעריכת שם קבוצה
  Future<void> _showEditHouseholdNameDialog(UserContext userContext) async {
    final controller =
        TextEditingController(text: userContext.householdName ?? '');
    bool isSaving = false;
    String? errorText;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(AppStrings.settings.householdName),
            content: TextField(
              controller: controller,
              maxLength: 40,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: AppStrings.settings.householdNameHint,
                border: const OutlineInputBorder(),
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppStrings.common.cancel),
              ),
              TextButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await userContext
                              .updateHouseholdName(controller.text.trim());
                          if (ctx.mounted) Navigator.pop(dialogContext);
                        } catch (e) {
                          setDialogState(() {
                            isSaving = false;
                            errorText = e.toString();
                          });
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppStrings.settings.editHouseholdNameSave),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🏠 דיאלוג הזמנה לבית
  Future<void> _showInviteToHouseholdDialog(UserContext userContext) async {
    final emailController = TextEditingController();
    bool isSending = false;
    String? errorText;
    String? successText;

    // וודא שיש שם לבית
    if (userContext.householdName == null ||
        userContext.householdName!.trim().isEmpty) {
      await _showEditHouseholdNameDialog(userContext);
      if (userContext.householdName == null ||
          userContext.householdName!.trim().isEmpty) {
        return; // ביטל בלי לבחור שם
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(AppStrings.settings.inviteToHouseholdTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: AppStrings.settings.inviteToHouseholdHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: errorText,
                  ),
                ),
                if (successText != null) ...[
                  const SizedBox(height: kSpacingSmall),
                  Text(
                    successText!,
                    style: TextStyle(
                      color: kStickyGreen,
                      fontSize: kFontSizeSmall,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppStrings.common.cancel),
              ),
              ElevatedButton.icon(
                icon: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send, size: kIconSizeSmall),
                label: Text(AppStrings.settings.inviteToHouseholdButton),
                onPressed: isSending
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          setDialogState(() => errorText = 'אימייל לא תקין');
                          return;
                        }

                        setDialogState(() {
                          isSending = true;
                          errorText = null;
                          successText = null;
                        });

                        final service = PendingInvitesService();
                        final userId = userContext.userId!;
                        final userName =
                            userContext.user?.name ?? 'משתמש';
                        final householdId = userContext.householdId!;
                        final householdName =
                            userContext.householdName ?? 'הבית שלי';

                        // חפש אם המשתמש קיים
                        String? invitedUserId;
                        try {
                          final usersQuery = await FirebaseFirestore.instance
                              .collection('users')
                              .where('email',
                                  isEqualTo: email.toLowerCase())
                              .limit(1)
                              .get();
                          if (usersQuery.docs.isNotEmpty) {
                            invitedUserId = usersQuery.docs.first.id;
                          }
                        } catch (_) {}

                        final result =
                            await service.createHouseholdInvite(
                          inviterId: userId,
                          inviterName: userName,
                          invitedUserEmail: email,
                          invitedUserId: invitedUserId,
                          householdId: householdId,
                          householdName: householdName,
                        );

                        if (!ctx.mounted) return;

                        if (result.isSuccess) {
                          setDialogState(() {
                            isSending = false;
                            successText = AppStrings
                                .settings.inviteToHouseholdSuccess;
                            emailController.clear();
                          });
                        } else if (result.type ==
                            InviteResultType.inviteAlreadyPending) {
                          setDialogState(() {
                            isSending = false;
                            errorText = AppStrings
                                .settings.inviteToHouseholdAlreadyPending;
                          });
                        } else {
                          setDialogState(() {
                            isSending = false;
                            errorText =
                                result.errorMessage ?? 'שגיאה בשליחת ההזמנה';
                          });
                        }
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Bottom Sheet לעריכת פרופיל
  Future<void> _showEditProfileBottomSheet() async {
    final userContext = context.read<UserContext>();
    final currentName = userContext.user?.name ?? '';
    final currentAvatar = userContext.user?.profileImageUrl ?? '👤';

    final nameController = TextEditingController(text: currentName);
    String selectedAvatar = _avatarOptions.contains(currentAvatar) ? currentAvatar : '👤';
    bool isSaving = false;

    // שומרים הפניות לפני פתיחת ה-bottom sheet (נמנע מבעיות async context)
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (sheetCtx, setBottomSheetState) {
          final cs = Theme.of(sheetCtx).colorScheme;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                    ),
                  ),
                  SizedBox(height: kSpacingMedium),

                  // כותרת
                  Text(
                    'עריכת פרופיל',
                    style: TextStyle(
                      fontSize: kFontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: kSpacingLarge),

                  // בחירת אווטאר
                  Text(
                    'בחר אווטאר:',
                    style: TextStyle(
                      fontSize: kFontSizeBody,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  Wrap(
                    spacing: kSpacingSmall,
                    runSpacing: kSpacingSmall,
                    alignment: WrapAlignment.center,
                    children: _avatarOptions.map((avatar) {
                      final isSelected = avatar == selectedAvatar;
                      return GestureDetector(
                        onTap: () {
                          setBottomSheetState(() => selectedAvatar = avatar);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primary.withValues(alpha: 0.2)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(kBorderRadius),
                            border: isSelected
                                ? Border.all(color: cs.primary, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              avatar,
                              style: const TextStyle(fontSize: kFontSizeTitle),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: kSpacingLarge),

                  // שדה שם
                  Text(
                    'שם תצוגה:',
                    style: TextStyle(
                      fontSize: kFontSizeBody,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'הכנס את שמך',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    maxLength: 30,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: kSpacingLarge),

                  // כפתורים
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.pop(sheetCtx),
                          child: const Text('ביטול'),
                        ),
                      ),
                      const SizedBox(width: kSpacingMedium),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: isSaving ? null : () async {
                            final newName = nameController.text.trim();
                            if (newName.isEmpty) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text('נא להזין שם')),
                              );
                              return;
                            }

                            setBottomSheetState(() => isSaving = true);
                            final navigator = Navigator.of(sheetCtx);

                            try {
                              await userContext.updateUserProfile(
                                name: newName,
                                avatar: selectedAvatar,
                              );

                              if (mounted) {
                                navigator.pop();
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('הפרופיל עודכן בהצלחה'),
                                    backgroundColor: cs.primary,
                                  ),
                                );
                              }
                            } catch (e) {
                              setBottomSheetState(() => isSaving = false);
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('שגיאה בעדכון: $e'),
                                    backgroundColor: cs.error,
                                  ),
                                );
                              }
                            }
                          },
                          child: isSaving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onPrimary,
                                  ),
                                )
                              : const Text('שמור'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpacingSmall),
                ],
              ),
            ),
          );
        },
      ),
    );

    nameController.dispose();
  }

  /// עוטף section באנימציית fade+slide
  Widget _animatedSection(int index, Widget child) {
    return SlideTransition(
      position: _slideAnims[index],
      child: FadeTransition(opacity: _fadeAnims[index], child: child),
    );
  }

  /// Skeleton Screen ל-Loading State
  Widget _buildLoadingSkeleton(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(kSpacingMedium),
      children: const [
        SkeletonBox(width: double.infinity, height: 100),
        SizedBox(height: kSpacingMedium),
        Row(
          children: [
            Expanded(child: SkeletonBox(width: double.infinity, height: 80)),
            SizedBox(width: kSpacingSmallPlus),
            Expanded(child: SkeletonBox(width: double.infinity, height: 80)),
          ],
        ),
        SizedBox(height: kSpacingSmallPlus),
        SkeletonBox(width: double.infinity, height: 80),
        SizedBox(height: kSpacingLarge),
        SkeletonBox(width: double.infinity, height: 200),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userContext = context.watch<UserContext>();

    // ✅ FIX: אם אין משתמש - מעבירים ל-Login (מסך הגדרות מוגן)
    if (userContext.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // פרטי משתמש - תמיד יש user בשלב זה
    final userName = userContext.user!.name;
    final userEmail = userContext.user!.email;

    // Loading State
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: _buildLoadingSkeleton(cs)),
      );
    }

    // Error State
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: cs.error),
              SizedBox(height: kSpacingMedium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.error),
                ),
              ),
              const SizedBox(height: kSpacingMedium),
              FilledButton.icon(
                onPressed: _retry,
                icon: Icon(Icons.refresh),
                label: Text(AppStrings.priceComparison.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        const NotebookBackground(),
        Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
              padding: const EdgeInsets.all(kSpacingMedium),
              children: [
                // 🏷️ כותרת inline
                Padding(
                  padding: const EdgeInsets.only(bottom: kSpacingMedium),
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, size: 24, color: cs.primary),
                      SizedBox(width: kSpacingSmall),
                      Text(
                        AppStrings.settings.title,
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 פרופיל אישי — Premium gradient ring
                _animatedSection(0, Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingLarge),
                    child: Column(
                      children: [
                        // Avatar with gradient ring
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.tertiary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: cs.surface,
                            child: _avatarOptions.contains(userContext.user?.profileImageUrl)
                                ? Text(
                                    userContext.user!.profileImageUrl!,
                                    style: const TextStyle(fontSize: kFontSizeDisplay),
                                  )
                                : Text(
                                    userName.isNotEmpty ? userName[0] : '?',
                                    style: TextStyle(fontSize: kFontSizeTitle, fontWeight: FontWeight.bold, color: cs.primary),
                                  ),
                          ),
                        ),
                        const SizedBox(height: kSpacingSmallPlus),
                        Text(
                          userName,
                          style: TextStyle(fontSize: kFontSizeTitle, fontWeight: FontWeight.bold, color: cs.onSurface),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: kSpacingXTiny),
                        Text(
                          userEmail,
                          style: TextStyle(fontSize: kFontSizeMedium, color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: kSpacingSmallPlus),
                        OutlinedButton.icon(
                          onPressed: _showEditProfileBottomSheet,
                          icon: const Icon(Icons.edit_outlined, size: kIconSizeSmall),
                          label: Text(AppStrings.settings.editProfile),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: kSpacingMedium),

                // 🔹 התראות
                _animatedSection(1, Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          leading: Icon(Icons.notifications_outlined, color: cs.primary, size: kIconSizeMedium),
                          title: AppStrings.settings.notificationsSectionTitle,
                        ),
                        const SizedBox(height: kSpacingSmall),
                        _NotificationToggle(
                          title: AppStrings.settings.notifyShoppingTitle,
                          subtitle: AppStrings.settings.notifyShoppingSubtitle,
                          value: _notifyShopping,
                          onChanged: (val) {
                            setState(() => _notifyShopping = val);
                            _saveNotificationSetting(_kNotifyShopping, val);
                          },
                        ),
                        _NotificationToggle(
                          title: AppStrings.settings.notifyGroupTitle,
                          subtitle: AppStrings.settings.notifyGroupSubtitle,
                          value: _notifyGroup,
                          onChanged: (val) {
                            setState(() => _notifyGroup = val);
                            _saveNotificationSetting(_kNotifyGroup, val);
                          },
                        ),
                        _NotificationToggle(
                          title: AppStrings.settings.notifyRemindersTitle,
                          subtitle: AppStrings.settings.notifyRemindersSubtitle,
                          value: _notifyReminders,
                          onChanged: (val) {
                            setState(() => _notifyReminders = val);
                            _saveNotificationSetting(_kNotifyReminders, val);
                          },
                        ),
                        _NotificationToggle(
                          title: AppStrings.settings.notifyListUpdatesTitle,
                          subtitle: AppStrings.settings.notifyListUpdatesSubtitle,
                          value: _notifyListUpdates,
                          onChanged: (val) {
                            setState(() => _notifyListUpdates = val);
                            _saveNotificationSetting(_kNotifyListUpdates, val);
                          },
                        ),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: kSpacingMedium),

                // 🔹 הגדרות כלליות — Theme cards
                _animatedSection(2, Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          leading: Icon(Icons.palette_outlined, color: cs.primary, size: kIconSizeMedium),
                          title: AppStrings.settings.generalSettingsSectionTitle,
                        ),
                        const SizedBox(height: kSpacingMedium),
                        Row(
                          children: [
                            _ThemeCard(
                              icon: '☀️',
                              label: AppStrings.settings.themeLight,
                              isSelected: userContext.themeMode == ThemeMode.light,
                              onTap: () => userContext.setThemeMode(ThemeMode.light),
                            ),
                            const SizedBox(width: kSpacingSmall),
                            _ThemeCard(
                              icon: '🌙',
                              label: AppStrings.settings.themeDark,
                              isSelected: userContext.themeMode == ThemeMode.dark,
                              onTap: () => userContext.setThemeMode(ThemeMode.dark),
                            ),
                            const SizedBox(width: kSpacingSmall),
                            _ThemeCard(
                              icon: '📱',
                              label: AppStrings.settings.themeSystem,
                              isSelected: userContext.themeMode == ThemeMode.system,
                              onTap: () => userContext.setThemeMode(ThemeMode.system),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpacingMedium),
                        // 🌐 Language selection
                        ListenableBuilder(
                          listenable: LocaleManager.instance,
                          builder: (context, _) => Row(
                            children: [
                              _ThemeCard(
                                icon: '🇮🇱',
                                label: 'עברית',
                                isSelected: LocaleManager.instance.isHebrew,
                                onTap: () => LocaleManager.instance.setLocale(AppLocale.he),
                              ),
                              const SizedBox(width: kSpacingSmall),
                              _ThemeCard(
                                icon: '🇺🇸',
                                label: 'English',
                                isSelected: LocaleManager.instance.isEnglish,
                                onTap: () => LocaleManager.instance.setLocale(AppLocale.en),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: kSpacingMedium),

                // 🔹 ניהול משפחה
                _animatedSection(3, Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          leading: Icon(Icons.home_outlined, color: cs.primary, size: kIconSizeMedium),
                          title: AppStrings.settings.householdManagementTitle,
                        ),
                        const SizedBox(height: kSpacingSmall),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.people_outline),
                          title: Text(AppStrings.settings.householdMembersTitle),
                          subtitle: Text(AppStrings.settings.householdMembersSubtitle),
                          trailing: Icon(Icons.chevron_left),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const HouseholdMembersScreen(),
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.person_add_outlined),
                          title: Text(AppStrings.settings.inviteToHouseholdTitle),
                          subtitle: Text(AppStrings.settings.inviteToHouseholdSubtitle),
                          trailing: Icon(Icons.chevron_left),
                          onTap: () => _showInviteToHouseholdDialog(userContext),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.label_outline),
                          title: Text(AppStrings.settings.householdName),
                          subtitle: Text(
                            userContext.householdName?.isNotEmpty == true
                                ? userContext.householdName!
                                : AppStrings.settings.householdNameHint,
                          ),
                          trailing: _isHouseholdAdmin
                              ? TextButton(
                                  onPressed: () =>
                                      _showEditHouseholdNameDialog(userContext),
                                  child: Text(AppStrings.settings.editHouseholdNameEdit),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                )),

                SizedBox(height: kSpacingMedium),

                // 🔹 קישורים מהירים
                _animatedSection(4, Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.mail_outline, color: cs.primary),
                        title: Text('הזמנות ממתינות'),
                        subtitle: Text('הזמנות שקיבלת לרשימות'),
                        trailing: Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.pushNamed(context, '/pending-invites');
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.school_outlined, color: cs.primary),
                        title: Text('הצג הדרכה מחדש'),
                        subtitle: Text('צפה שוב בהדרכת האפליקציה'),
                        trailing: Icon(Icons.chevron_left),
                        onTap: () async {
                          await TutorialService.resetTutorial(context);
                          if (!mounted) return;
                          // הצג את ההדרכה מיידית
                          await TutorialService.showHomeTutorialIfNeeded(context);
                        },
                      ),
                    ],
                  ),
                )),

                SizedBox(height: kSpacingMedium),

                // 🔹 מידע
                _animatedSection(5, Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.info_outline, color: cs.primary),
                        title: const Text('אודות'),
                        subtitle: const Text('גרסה 1.0.0'), // TODO: package_info_plus
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'MemoZap',
                            applicationVersion: '1.0.0',
                            applicationIcon: ClipRRect(
                              borderRadius: BorderRadius.circular(kBorderRadius),
                              child: Image.asset(
                                'assets/images/app_icon.png',
                                width: 48,
                                height: 48,
                                errorBuilder: (_, __, ___) => Text('📝', style: TextStyle(fontSize: kFontSizeDisplay)),
                              ),
                            ),
                            children: [
                              Text('אפליקציה חכמה לניהול קניות ומזווה ביתי'),
                            ],
                          );
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.description_outlined, color: cs.primary),
                        title: Text('תנאי שימוש'),
                        trailing: Icon(Icons.chevron_left),
                        onTap: () => showTermsOfServiceDialog(context),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.privacy_tip_outlined, color: cs.primary),
                        title: const Text('מדיניות פרטיות'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => showPrivacyPolicyDialog(context),
                      ),
                    ],
                  ),
                )),

                SizedBox(height: kSpacingMedium),

                // 🔹 התנתקות
                _animatedSection(6, Card(
                  elevation: 1,
                  child: ListTile(
                    leading: Icon(Icons.logout, color: cs.error),
                    title: Text(AppStrings.settings.logoutTitle, style: TextStyle(color: cs.error)),
                    subtitle: Text(AppStrings.settings.logoutSubtitle),
                    trailing: Icon(Icons.chevron_left, color: cs.error),
                    onTap: _logout,
                  ),
                )),

                // 🔧 DEBUG ONLY: מחיקת כל הנתונים
                if (kDebugMode) ...[
                  SizedBox(height: kSpacingSmall),
                  Card(
                    elevation: 1,
                    color: cs.tertiaryContainer,
                    child: ListTile(
                      leading: Icon(Icons.bug_report, color: cs.tertiary),
                      title: Text('🔧 DEBUG: מחק הכל', style: TextStyle(color: cs.tertiary)),
                      subtitle: const Text('מוחק seenOnboarding - חוזר ל-Welcome'),
                      onTap: _debugClearAllData,
                    ),
                  ),
                ],

                SizedBox(height: kSpacingMedium),

                // 🔹 מחיקת חשבון (GDPR)
                Card(
                  elevation: 1,
                  color: cs.errorContainer,
                  child: ListTile(
                    leading: Icon(Icons.delete_forever, color: cs.error),
                    title: Text(
                      AppStrings.settings.deleteAccountTitle,
                      style: TextStyle(color: cs.error),
                    ),
                    subtitle: Text(
                      AppStrings.settings.deleteAccountSubtitle,
                      style: TextStyle(color: cs.error.withValues(alpha: 0.6)),
                    ),
                    trailing: Icon(Icons.chevron_left, color: cs.error),
                    onTap: _showDeleteAccountDialog,
                  ),
                ),

                const SizedBox(height: kSpacingLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 🔔 Toggle להגדרות התראות — themed accent
class _NotificationToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: kFontSizeBody),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: kFontSizeSmall,
          color: cs.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: cs.primary,
      activeTrackColor: cs.primary.withValues(alpha: 0.3),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// 🎨 כרטיס בחירת ערכת נושא
class _ThemeCard extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: kSpacingSmallPlus, horizontal: kSpacingSmall),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary.withValues(alpha: 0.12) : cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: kFontSizeXLarge)),
              const SizedBox(height: kSpacingXTiny),
              Text(
                label,
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? cs.primary : cs.onSurface,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: kSpacingXTiny),
                Icon(Icons.check_circle, size: kIconSizeSmall, color: cs.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
