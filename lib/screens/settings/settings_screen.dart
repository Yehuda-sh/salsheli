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
// - HouseholdConfig (סוגי קבוצות)
//
// 📊 Flow:
// 1. טעינת הגדרות מ-SharedPreferences
// 2. הצגת פרופיל + סטטיסטיקות (עם animations!)
// 3. עריכת הגדרות → שמירה אוטומטית
// 4. עדכון מחירים ידני (ProductsProvider.refreshProducts)
// 5. התנתקות → ניקוי + חזרה ל-login
//
// Version: 3.3 - SimpleTappableCard refactor
// Last Updated: 2/11/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/providers/products_provider.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/config/household_config.dart';
import 'package:memozap/widgets/common/notebook_background.dart';
import 'package:memozap/widgets/common/sticky_note.dart';
import 'package:memozap/widgets/common/sticky_button.dart';
import 'package:memozap/widgets/common/skeleton_loading.dart';
import 'package:memozap/screens/settings/manage_users_screen.dart';
import 'package:memozap/tools/load_demo_data_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Keys לשמירה מקומית
  static const _kHouseholdName = 'settings.householdName';
  static const _kHouseholdType = 'settings.householdType';
  static const _kPreferredStores = 'settings.preferredStores';
  static const _kFamilySize = 'settings.familySize';
  static const _kWeeklyReminders = 'settings.weeklyReminders';
  static const _kHabitsAnalysis = 'settings.habitsAnalysis';

  // מצב UI
  String _householdName = "הקבוצה שלי";
  String _householdType = HouseholdConfig.family; // default
  bool _isEditingHouseholdName = false;
  final TextEditingController _householdNameController = TextEditingController();



  // חנויות מועדפות
  final List<String> _preferredStores = ["שופרסל", "רמי לוי"];
  final TextEditingController _storeController = TextEditingController();

  // הגדרות
  int _familySize = 3;
  late final TextEditingController _familySizeController;
  bool _weeklyReminders = true;
  bool _habitsAnalysis = true;

  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('⚙️ SettingsScreen: initState');
    _householdNameController.text = _householdName;
    _familySizeController = TextEditingController(text: _familySize.toString());
    _loadSettings();
  }

  @override
  void dispose() {
    debugPrint('🗑️ SettingsScreen: dispose');
    _householdNameController.dispose();
    _storeController.dispose();
    _familySizeController.dispose();
    super.dispose();
  }

  /// טעינת הגדרות מ-SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _householdName = prefs.getString(_kHouseholdName) ?? _householdName;
        _householdType = prefs.getString(_kHouseholdType) ?? _householdType;
        _familySize = prefs.getInt(_kFamilySize) ?? _familySize;
        _weeklyReminders = prefs.getBool(_kWeeklyReminders) ?? true;
        _habitsAnalysis = prefs.getBool(_kHabitsAnalysis) ?? true;

        // טעינת רשימת חנויות - עם fallback אם הפורמט ישן
        _preferredStores.clear();
        try {
          final storesList = prefs.getStringList(_kPreferredStores);
          if (storesList != null) {
            _preferredStores.addAll(storesList);
          }
        } catch (e) {
          // אם היה שמור כ-String (גרסה ישנה), נקה אותו
          debugPrint('⚠️ _loadSettings: _kPreferredStores בפורמט ישן, מנקה');
          prefs.remove(_kPreferredStores);
        }

        _householdNameController.text = _householdName;
        _familySizeController.text = _familySize.toString();
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

  /// שמירת הגדרות ב-SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kHouseholdName, _householdName);
      await prefs.setString(_kHouseholdType, _householdType);
      await prefs.setInt(_kFamilySize, _familySize);
      await prefs.setBool(_kWeeklyReminders, _weeklyReminders);
      await prefs.setBool(_kHabitsAnalysis, _habitsAnalysis);
      await prefs.setStringList(_kPreferredStores, _preferredStores);

      final messenger = ScaffoldMessenger.of(context);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppStrings.common.success),
            backgroundColor: Colors.green,
            duration: kSnackBarDuration,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ _saveSettings: שגיאה - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.settings.saveError(e.toString())),
            backgroundColor: Colors.red,
            duration: kSnackBarDuration,
          ),
        );
      }
    }
  }

  /// עריכת שם הקבוצה
  void _toggleEditHousehold() {
    if (_isEditingHouseholdName) {
      setState(() {
        _householdName = _householdNameController.text.trim();
        _isEditingHouseholdName = false;
      });
      _saveSettings();
    } else {
      setState(() => _isEditingHouseholdName = true);
    }
  }

  /// הוספת חנות מועדפת
  void _addStore() {
    final text = _storeController.text.trim();
    if (text.isNotEmpty && !_preferredStores.contains(text)) {
      setState(() {
        _preferredStores.add(text);
        _storeController.clear();
      });
      _saveSettings();
      debugPrint('✅ _addStore: הוספה הצליחה');
    } else {
      debugPrint('⚠️ _addStore: חנות קיימת או ריקה');
    }
  }

  /// הסרת חנות
  void _removeStore(int index) {
    setState(() => _preferredStores.removeAt(index));
    _saveSettings();
  }

  /// שינוי סוג הקבוצה
  void _changeHouseholdType(String? newType) {
    if (newType != null) {
      setState(() => _householdType = newType);
      _saveSettings();
    }
  }

  /// עדכון גודל משפחה
  void _updateFamilySize() {
    final newSize = int.tryParse(_familySizeController.text);
    if (newSize != null && newSize > 0 && newSize <= 20) {
      setState(() => _familySize = newSize);
      _saveSettings();
    } else {
      debugPrint('❌ _updateFamilySize: ערך לא תקין');
    }
  }

  /// עדכון מחירים ידני
  Future<void> _updatePrices(BuildContext context) async {
    debugPrint('💰 _updatePrices: מתחיל עדכון');
    final productsProvider = context.read<ProductsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
            const SizedBox(width: kSpacingMedium),
            Text(AppStrings.settings.updatingPrices),
          ],
        ),
        duration: const Duration(minutes: 5),
      ),
    );

    try {
      await productsProvider.refreshProducts(force: true);

      if (!mounted) return;
      messenger.hideCurrentSnackBar();

      final withPrice = productsProvider.productsWithPrice;
      final total = productsProvider.totalProducts;

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.settings.pricesUpdated(withPrice, total)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      debugPrint('✅ _updatePrices: הצליח - $withPrice/$total');
    } catch (e) {
      debugPrint('❌ _updatePrices: שגיאה - $e');
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.settings.pricesUpdateError(e.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
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
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: kIconSizeMedium),
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
        showDialog(
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
                      const SizedBox(height: kSpacingMedium),
                      const Text('ממחק נתונים...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await context.read<UserContext>().signOutAndClearAllData();

        debugPrint('🎉 _logout: הושלם בהצלחה');

        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
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

  /// ניהול חברים - מציג בחירת רשימה או ניווט ישיר
  Future<void> _manageMembers(BuildContext context) async {
    final listsProvider = context.read<ShoppingListsProvider>();
    final userContext = context.read<UserContext>();
    final currentUserId = userContext.userId;

    // מציאת רשימות שהמשתמש הוא Owner שלהן
    final myOwnedLists = listsProvider.lists
        .where((list) => list.createdBy == currentUserId)
        .toList();

    if (myOwnedLists.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אין לך רשימות שאתה בעלים שלהן'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // אם יש רק רשימה אחת - ניווט ישיר
    if (myOwnedLists.length == 1) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ManageUsersScreen(list: myOwnedLists.first),
        ),
      );
      return;
    }

    // אם יש יותר מרשימה אחת - תן למשתמש לבחור
    final selectedList = await showDialog<ShoppingList>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בחר רשימה לניהול'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: myOwnedLists.length,
            itemBuilder: (context, index) {
              final list = myOwnedLists[index];
              return ListTile(
                leading: const Icon(Icons.list),
                title: Text(list.name),
                subtitle: Text(
                  'חברים: ${list.sharedUsers.length}',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () => Navigator.of(context).pop(list),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
        ],
      ),
    );

    if (selectedList != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ManageUsersScreen(list: selectedList),
        ),
      );
    }
  }

  /// Skeleton Screen ל-Loading State
  Widget _buildLoadingSkeleton(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(kSpacingMedium),
      children: [
        const SkeletonBox(width: double.infinity, height: 100),
        const SizedBox(height: kSpacingMedium),
        const Row(
          children: [
            Expanded(child: SkeletonBox(width: double.infinity, height: 80)),
            SizedBox(width: kSpacingSmallPlus),
            Expanded(child: SkeletonBox(width: double.infinity, height: 80)),
          ],
        ),
        const SizedBox(height: kSpacingSmallPlus),
        const SkeletonBox(width: double.infinity, height: 80),
        const SizedBox(height: kSpacingLarge),
        const SkeletonBox(width: double.infinity, height: 200),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userContext = context.watch<UserContext>();
    final listsProvider = context.watch<ShoppingListsProvider>();

    // פרטי משתמש
    final userName = userContext.user?.name ?? AppStrings.home.guestUser;
    final userEmail = userContext.user?.email ?? "email@example.com";

    // Loading State
    if (_loading) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(AppStrings.settings.title),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
        ),
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
      appBar: AppBar(
        title: Text(AppStrings.settings.title),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(kSpacingMedium),
              children: [
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

                // 🔹 ניהול קבוצה
                StickyNote(
                  color: kStickyPink,
                  rotation: 0.015,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.settings.householdTitle,
                          style: TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold, color: cs.primary),
                        ),
                        const SizedBox(height: kSpacingMedium),
                        Row(
                          children: [
                            Expanded(
                              child: _isEditingHouseholdName
                                  ? TextField(
                                      controller: _householdNameController,
                                      decoration: InputDecoration(
                                        hintText: AppStrings.settings.householdNameHint,
                                        isDense: true,
                                      ),
                                      maxLength: 30,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _toggleEditHousehold(),
                                    )
                                  : Text(
                                      _householdName,
                                      style: const TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.w600),
                                    ),
                            ),
                            IconButton(
                              onPressed: _toggleEditHousehold,
                              icon: Icon(_isEditingHouseholdName ? Icons.check : Icons.edit, color: cs.primary),
                              tooltip: _isEditingHouseholdName
                                  ? AppStrings.settings.editHouseholdNameSave
                                  : AppStrings.settings.editHouseholdNameEdit,
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpacingSmallPlus),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.settings.householdType,
                              style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
                            ),
                            DropdownButton<String>(
                              value: _householdType,
                              items: HouseholdConfig.allTypes
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Row(
                                        children: [
                                          Icon(HouseholdConfig.getIcon(type), size: kIconSizeSmall),
                                          const SizedBox(width: kSpacingSmall),
                                          Text(HouseholdConfig.getLabel(type)),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _changeHouseholdType,
                              underline: Container(),
                            ),
                          ],
                        ),
                        const Divider(height: kSpacingLarge),
                        Text(
                          _getTotalSharedUsersText(listsProvider),
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: kSpacingSmall),
                        SizedBox(
                          width: double.infinity,
                          child: StickyButton(
                            label: AppStrings.settings.manageMembersButton,
                            icon: Icons.group_add,
                            color: Colors.white,
                            textColor: cs.primary,
                            height: 44,
                            onPressed: () => _manageMembers(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 חנויות מועדפות
                StickyNote(
                  color: kStickyGreen,
                  rotation: -0.01,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.settings.storesTitle,
                          style: TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold, color: cs.primary),
                        ),
                        const SizedBox(height: kSpacingSmallPlus),
                        Wrap(
                          spacing: kSpacingSmall,
                          runSpacing: kSpacingSmall,
                          children: List.generate(
                            _preferredStores.length,
                            (index) => Chip(
                              label: Text(_preferredStores[index]),
                              deleteIcon: const Icon(Icons.close, size: kIconSizeSmall + 2),
                              onDeleted: () => _removeStore(index),
                            ),
                          ),
                        ),
                        const SizedBox(height: kSpacingSmallPlus),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _storeController,
                                decoration: InputDecoration(hintText: AppStrings.settings.addStoreHint, isDense: true),
                                maxLength: 25,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _addStore(),
                              ),
                            ),
                            const SizedBox(width: kSpacingSmall),
                            IconButton(
                              onPressed: _addStore,
                              icon: Icon(Icons.add, color: cs.primary),
                              tooltip: AppStrings.settings.addStoreTooltip,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 הגדרות אישיות
                StickyNote(
                  color: kStickyCyan,
                  rotation: 0.01,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.settings.personalSettingsTitle,
                          style: TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold, color: cs.primary),
                        ),
                        const SizedBox(height: kSpacingSmallPlus),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppStrings.settings.familySizeLabel),
                            SizedBox(
                              width: kFieldWidthNarrow,
                              child: TextField(
                                controller: _familySizeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: kSpacingSmall,
                                    vertical: kSpacingSmall,
                                  ),
                                ),
                                onSubmitted: (_) => _updateFamilySize(),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: kSpacingLarge),
                        SwitchListTile(
                          title: Text(AppStrings.settings.weeklyRemindersLabel),
                          subtitle: Text(AppStrings.settings.weeklyRemindersSubtitle),
                          value: _weeklyReminders,
                          onChanged: (val) {
                            setState(() => _weeklyReminders = val);
                            _saveSettings();
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: Text(AppStrings.settings.habitsAnalysisLabel),
                          subtitle: Text(AppStrings.settings.habitsAnalysisSubtitle),
                          value: _habitsAnalysis,
                          onChanged: (val) {
                            setState(() => _habitsAnalysis = val);
                            _saveSettings();
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 קישורים מהירים
                StickyNote(
                  color: kStickyPurple,
                  rotation: -0.015,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.receipt_long, color: Colors.grey),
                        title: Text(AppStrings.settings.myReceipts, style: const TextStyle(color: Colors.grey)),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: null,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.psychology, color: Colors.grey),
                        title: const Text('הרגלי קנייה שלי', style: TextStyle(color: Colors.grey)),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: null,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.inventory_2_outlined, color: cs.primary),
                        title: Text(AppStrings.settings.myPantry),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.pushNamed(context, '/inventory');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.price_change_outlined, color: Colors.grey),
                        title: Text(AppStrings.settings.priceComparison, style: const TextStyle(color: Colors.grey)),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: null,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.sync, color: cs.primary),
                        title: Text(AppStrings.settings.updatePricesTitle),
                        subtitle: Text(AppStrings.settings.updatePricesSubtitle),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => _updatePrices(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 טעינת נתוני דמו (Developer Tools)
                StickyNote(
                  color: Colors.deepPurple.shade50,
                  rotation: -0.01,
                  child: ListTile(
                    leading: const Icon(Icons.science, color: Colors.deepPurple),
                    title: const Text('🧪 טעינת נתוני דמו', style: TextStyle(color: Colors.deepPurple)),
                    subtitle: const Text('טען 5 משתמשי דמו ל-Firebase'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoadDemoDataScreen()),
                      );
                    },
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

                const SizedBox(height: kSpacingLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// סטטיסטיקה אמיתית של משתמשים משותפים
  String _getTotalSharedUsersText(ShoppingListsProvider listsProvider) {
    final userContext = context.read<UserContext>();
    final currentUserId = userContext.userId;

    // מציאת רשימות שהמשתמש הוא Owner שלהן
    final myOwnedLists = listsProvider.lists
        .where((list) => list.createdBy == currentUserId)
        .toList();

    if (myOwnedLists.isEmpty) {
      return 'אין רשימות משותפות';
    }

    // חישוב סה"כ משתמשים ייחודיים
    final Set<String> uniqueUsers = {};
    for (final list in myOwnedLists) {
      uniqueUsers.add(list.createdBy); // Owner
      for (final sharedUser in list.sharedUsers) {
        uniqueUsers.add(sharedUser.userId);
      }
    }

    final totalUsers = uniqueUsers.length;
    final totalShared = totalUsers - 1; // בלי ה-Owner

    if (totalShared == 0) {
      return 'אין חברים משותפים';
    }

    return 'חברים: $totalShared ברשימות שלך';
  }
}
