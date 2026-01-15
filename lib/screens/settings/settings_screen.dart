// ignore_for_file: use_build_context_synchronously

// 📄 File: lib/screens/settings/settings_screen.dart
//
// 🎯 תיאור: מסך הגדרות ופרופיל משולב - ניהול פרופיל אישי, הגדרות קבוצה, והעדפות
//
// 🔧 תכונות:
// ✅ פרופיל אישי מחובר ל-UserContext (שם, אימייל, תמונה)
// ✅ סטטיסטיקות בזמן אמת (רשימות, קבלות, פריטים במזווה)
// ✅ ניהול קבוצה/משק בית (תמיכה במשפחה, ועד בית, ועד גן)
// ✅ הכנה לניהול חברים עתידי
// ✅ הגדרות אישיות עם שמירה ב-SharedPreferences
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
// - StickyButton animations
// - Skeleton Screen ל-Loading State
//
// 🔗 תלויות:
// - UserContext (Provider)
// - ShoppingListsProvider (סטטיסטיקות)
// - ReceiptProvider (סטטיסטיקות)
// - InventoryProvider (סטטיסטיקות)
// - ProductsProvider (עדכון מחירים)
// - SharedPreferences (שמירת הגדרות מקומית)
// - Household types: 'family' (inline constant)
//
// 📊 Flow:
// 1. טעינת הגדרות מ-SharedPreferences
// 2. הצגת פרופיל + סטטיסטיקות (עם animations!)
// 3. עריכת הגדרות → שמירה אוטומטית
// 4. עדכון מחירים ידני (ProductsProvider.refreshProducts)
// 5. התנתקות → ניקוי + חזרה ל-login
//
// Version: 3.4 - No AppBar (Immersive)
// Last Updated: 13/01/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/widgets/common/notebook_background.dart';
import 'package:memozap/widgets/common/skeleton_loader.dart';
import 'package:memozap/widgets/common/sticky_button.dart';
import 'package:memozap/widgets/common/sticky_note.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../services/tutorial_service.dart';
import '../../widgets/dialogs/legal_content_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Keys לשמירה מקומית
  static const _kHouseholdName = 'settings.householdName';
  static const _kHouseholdType = 'settings.householdType';

  // מצב UI
  String _householdName = 'הקבוצה שלי';
  String _householdType = 'family'; // default household type

  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('⚙️ SettingsScreen: initState');
    _loadSettings();
  }

  @override
  void dispose() {
    debugPrint('🗑️ SettingsScreen: dispose');
    super.dispose();
  }

  /// טעינת הגדרות מ-SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _householdName = prefs.getString(_kHouseholdName) ?? _householdName;
        _householdType = prefs.getString(_kHouseholdType) ?? _householdType;
        _loading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('❌ _loadSettings: שגיאה - $e');
      setState(() {
        _errorMessage = AppStrings.settings.loadError(e.toString());
        _loading = false;
      });
    }
  }

  /// התנתקות
  Future<void> _logout() async {
    debugPrint('🔥 _logout: מתחיל התנתקות מלאה');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.settings.logoutTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.settings.logoutMessage),
            const SizedBox(height: kSpacingMedium),
            Container(
              padding: const EdgeInsets.all(kSpacingSmall),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(kBorderRadius),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: kIconSizeMedium),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'כל הנתונים המקומיים יימחקו!\n(מוצרים, העדפות, cache)',
                      style: TextStyle(fontSize: kFontSizeSmall, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.settings.logoutCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.settings.logoutConfirm,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      debugPrint('🔥 _logout: אושר - מתחיל מחיקת נתונים מלאה');

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
                      Text('ממחק נתונים...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));

        await context.read<UserContext>().signOutAndClearAllData();

        debugPrint('🎉 _logout: הושלם בהצלחה');

        if (!mounted) return;
        Navigator.of(context).pop();
        unawaited(Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false));
      } catch (e) {
        debugPrint('❌ _logout: שגיאה - $e');
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה בהתנתקות: $e'), backgroundColor: Colors.red, duration: kSnackBarDurationLong),
        );
      }
    } else {
      debugPrint('❌ _logout: בוטל');
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
    final confirmController = TextEditingController();
    bool isDeleting = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isConfirmValid = confirmController.text == AppStrings.settings.deleteAccountConfirmText;

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                const SizedBox(width: kSpacingSmall),
                Text(
                  AppStrings.settings.deleteAccountTitle,
                  style: const TextStyle(color: Colors.red),
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
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      AppStrings.settings.deleteAccountWarning,
                      style: TextStyle(color: Colors.red[900]),
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
                onPressed: isDeleting ? null : () => Navigator.pop(context, false),
                child: Text(AppStrings.settings.logoutCancel),
              ),
              FilledButton(
                onPressed: isDeleting || !isConfirmValid
                    ? null
                    : () async {
                        setDialogState(() => isDeleting = true);

                        try {
                          final authService = AuthService();
                          await authService.deleteAccount();

                          if (!mounted) return;
                          Navigator.pop(context, true);
                        } on AuthException catch (e) {
                          setDialogState(() => isDeleting = false);

                          if (e.code == AuthErrorCode.requiresRecentLogin) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.settings.deleteAccountRequiresReauth),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.settings.deleteAccountError(e.message)),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isDeleting = false);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppStrings.settings.deleteAccountError(e.toString())),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        unawaited(Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false));
      }
    }
  }

  /// רשימת אווטארים לבחירה
  static const List<String> _avatarOptions = [
    '👤', '👩', '👨', '👧', '👦', '👴', '👵',
    '🧑‍🍳', '🛒', '🏠', '👨‍👩‍👧', '👨‍👩‍👧‍👦',
    '🌟', '💜', '💚', '🧡', '💙', '❤️',
  ];

  /// Bottom Sheet לעריכת פרופיל
  Future<void> _showEditProfileBottomSheet() async {
    final userContext = context.read<UserContext>();
    final currentName = userContext.user?.name ?? '';
    final currentAvatar = userContext.user?.profileImageUrl ?? '👤';

    final nameController = TextEditingController(text: currentName);
    String selectedAvatar = _avatarOptions.contains(currentAvatar) ? currentAvatar : '👤';
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setBottomSheetState) {
          final cs = Theme.of(context).colorScheme;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),

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
                  const SizedBox(height: kSpacingLarge),

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
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: cs.primary, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              avatar,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: kSpacingLarge),

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
                          onPressed: isSaving ? null : () => Navigator.pop(context),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('נא להזין שם')),
                              );
                              return;
                            }

                            setBottomSheetState(() => isSaving = true);

                            try {
                              await userContext.updateUserProfile(
                                name: newName,
                                avatar: selectedAvatar,
                              );

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('הפרופיל עודכן בהצלחה'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              setBottomSheetState(() => isSaving = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('שגיאה בעדכון: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // פרטי משתמש - תמיד יש user בשלב זה
    final userName = userContext.user!.name;
    final userEmail = userContext.user!.email;

    // Loading State
    if (_loading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(child: _buildLoadingSkeleton(cs)),
          ],
        ),
      );
    }

    // Error State
    if (_errorMessage != null) {
      return Scaffold(
        body: Stack(
          children: [
            const NotebookBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: cs.error),
                  const SizedBox(height: kSpacingMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),
                  StickyButton(label: AppStrings.priceComparison.retry, onPressed: _retry, color: kStickyCyan),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(kSpacingMedium),
              children: [
                // 🏷️ כותרת inline
                Padding(
                  padding: const EdgeInsets.only(bottom: kSpacingMedium),
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, size: 24, color: cs.primary),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        AppStrings.settings.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 פרופיל אישי
                StickyNote(
                  color: kStickyYellow,
                  rotation: -0.02,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: kAvatarRadius,
                          backgroundColor: cs.primary.withValues(alpha: 0.15),
                          child: _avatarOptions.contains(userContext.user?.profileImageUrl)
                              ? Text(
                                  userContext.user!.profileImageUrl!,
                                  style: const TextStyle(fontSize: 28),
                                )
                              : Icon(Icons.person, color: cs.primary, size: kIconSizeProfile),
                        ),
                        const SizedBox(width: kSpacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: kSpacingTiny),
                              Text(
                                userEmail,
                                style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Flexible(
                          child: StickyButton(
                            label: AppStrings.settings.editProfile,
                            icon: Icons.edit,
                            height: 44,
                            color: cs.primary,
                            textColor: Colors.white,
                            onPressed: _showEditProfileBottomSheet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 התראות
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notifications_outlined, color: cs.primary),
                            const SizedBox(width: kSpacingSmall),
                            Text(
                              'התראות',
                              style: TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold, color: cs.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpacingSmall),
                        _NotificationToggle(
                          title: 'התראות קנייה',
                          subtitle: 'כשמישהו מסיים קנייה',
                          value: true,
                          onChanged: (val) {
                            // TODO: שמירה ב-SharedPreferences
                          },
                        ),
                        _NotificationToggle(
                          title: 'התראות מלאי',
                          subtitle: 'כשמוצר במזווה אוזל',
                          value: true,
                          onChanged: (val) {
                            // TODO: שמירה ב-SharedPreferences
                          },
                        ),
                        _NotificationToggle(
                          title: 'התראות קבוצה',
                          subtitle: 'הזמנות וחברים חדשים',
                          value: true,
                          onChanged: (val) {
                            // TODO: שמירה ב-SharedPreferences
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 הגדרות כלליות
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings_outlined, color: cs.primary),
                            const SizedBox(width: kSpacingSmall),
                            Text(
                              'הגדרות כלליות',
                              style: TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold, color: cs.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpacingMedium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ערכת נושא'),
                            const SizedBox(width: kSpacingSmall),
                            Flexible(
                              child: SegmentedButton<ThemeMode>(
                                segments: const [
                                  ButtonSegment(value: ThemeMode.light, label: Text('בהיר')),
                                  ButtonSegment(value: ThemeMode.dark, label: Text('כהה')),
                                  ButtonSegment(value: ThemeMode.system, label: Text('מערכת')),
                                ],
                                selected: {userContext.themeMode},
                                onSelectionChanged: (selection) {
                                  userContext.setThemeMode(selection.first);
                                },
                                style: const ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 קישורים מהירים
                Card(
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.receipt_long_outlined, color: cs.primary),
                        title: const Text('הקבלות שלי'),
                        subtitle: const Text('היסטוריית קניות'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.pushNamed(context, '/receipts');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.mail_outline, color: cs.primary),
                        title: const Text('הזמנות ממתינות'),
                        subtitle: const Text('הזמנות שקיבלת לרשימות'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.pushNamed(context, '/pending-invites');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.school_outlined, color: cs.primary),
                        title: const Text('הצג הדרכה מחדש'),
                        subtitle: const Text('צפה שוב בהדרכת האפליקציה'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () async {
                          await TutorialService.resetTutorial(context);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ההדרכה תוצג בכניסה הבאה לדף הבית'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 מידע
                Card(
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.info_outline, color: cs.primary),
                        title: const Text('אודות'),
                        subtitle: const Text('גרסה 1.0.0'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'סל שלי',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Text('🛒', style: TextStyle(fontSize: 48)),
                            children: [
                              const Text('אפליקציה לניהול רשימות קניות משפחתיות'),
                            ],
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.description_outlined, color: cs.primary),
                        title: const Text('תנאי שימוש'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => showTermsOfServiceDialog(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.privacy_tip_outlined, color: cs.primary),
                        title: const Text('מדיניות פרטיות'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => showPrivacyPolicyDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 התנתקות
                StickyNote(
                  color: Colors.red.shade100,
                  rotation: 0.02,
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(AppStrings.settings.logoutTitle, style: const TextStyle(color: Colors.red)),
                    subtitle: Text(AppStrings.settings.logoutSubtitle),
                    onTap: _logout,
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 מחיקת חשבון (GDPR)
                Card(
                  elevation: 1,
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: Text(
                      AppStrings.settings.deleteAccountTitle,
                      style: const TextStyle(color: Colors.red),
                    ),
                    subtitle: Text(
                      AppStrings.settings.deleteAccountSubtitle,
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                    trailing: const Icon(Icons.chevron_left, color: Colors.red),
                    onTap: _showDeleteAccountDialog,
                  ),
                ),

                const SizedBox(height: kSpacingLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔔 Toggle להגדרות התראות
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
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: kFontSizeBody),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: kFontSizeSmall,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
