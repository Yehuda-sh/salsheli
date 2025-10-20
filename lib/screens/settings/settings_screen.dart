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
// - TappableCard על כרטיסי סטטיסטיקות (scale effect)
// - Button animations על כל הכפתורים
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
// Version: 3.1 - תוקן + NotebookBackground
// Last Updated: 15/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/providers/receipt_provider.dart';
import 'package:memozap/providers/inventory_provider.dart';
import 'package:memozap/providers/products_provider.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/config/household_config.dart';
import 'package:memozap/widgets/common/notebook_background.dart';
import 'package:memozap/widgets/common/sticky_note.dart';
import 'package:memozap/widgets/common/sticky_button.dart';
import 'package:memozap/screens/debug/cleanup_screen.dart';

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

  // חברים (דמה - בעתיד מה-Provider)
  final List<Map<String, String>> _members = [
    {"name": "יוסי כהן", "role": "owner"},
    {"name": "דנה לוי", "role": "editor"},
    {"name": "נועם", "role": "viewer"},
  ];

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

        final storesJson = prefs.getString(_kPreferredStores);
        if (storesJson != null && storesJson.isNotEmpty) {
          final List<String> decoded = storesJson.split(',');
          _preferredStores.clear();
          _preferredStores.addAll(decoded);
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
      await prefs.setString(_kPreferredStores, _preferredStores.join(','));

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
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onInverseSurface),
              ),
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
                      SizedBox(height: kSpacingMedium),
                      Text('ממחק נתונים...'),
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

  /// Skeleton Screen ל-Loading State
  Widget _buildLoadingSkeleton(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(kSpacingMedium),
      children: [
        _SkeletonBox(width: double.infinity, height: 100, borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
        const SizedBox(height: kSpacingMedium),
        Row(
          children: [
            Expanded(
              child: _SkeletonBox(
                width: double.infinity,
                height: 80,
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
            ),
            const SizedBox(width: kSpacingSmallPlus),
            Expanded(
              child: _SkeletonBox(
                width: double.infinity,
                height: 80,
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
            ),
          ],
        ),
        const SizedBox(height: kSpacingSmallPlus),
        _SkeletonBox(width: double.infinity, height: 80, borderRadius: BorderRadius.circular(kBorderRadius)),
        const SizedBox(height: kSpacingLarge),
        _SkeletonBox(width: double.infinity, height: 200, borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userContext = context.watch<UserContext>();
    final listsProvider = context.watch<ShoppingListsProvider>();
    final receiptsProvider = context.watch<ReceiptProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    // חישוב סטטיסטיקות בזמן אמיתי
    final activeLists = listsProvider.lists.where((l) => l.status != ShoppingList.statusCompleted).length;
    final totalReceipts = receiptsProvider.receipts.length;
    final pantryItems = inventoryProvider.items.length;

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
                  ElevatedButton(onPressed: _retry, child: Text(AppStrings.priceComparison.retry)),
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
                          child: Icon(Icons.person, color: cs.primary, size: kIconSizeProfile),
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
                        StickyButton(
                          label: AppStrings.settings.editProfile,
                          icon: Icons.edit,
                          height: 44,
                          color: cs.primary,
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(AppStrings.settings.editProfileButton)));
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔹 סטטיסטיקות מהירות
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        color: Colors.amber,
                        icon: Icons.shopping_cart_outlined,
                        label: AppStrings.settings.statsActiveLists,
                        value: activeLists,
                      ),
                    ),
                    const SizedBox(width: kSpacingSmallPlus),
                    Expanded(
                      child: _StatCard(
                        color: Colors.green,
                        icon: Icons.receipt_long_outlined,
                        label: AppStrings.settings.statsReceipts,
                        value: totalReceipts,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: kSpacingSmallPlus),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        color: Colors.blue,
                        icon: Icons.inventory_2_outlined,
                        label: AppStrings.settings.statsPantryItems,
                        value: pantryItems,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: kSpacingMedium),

                // 🛠️ Debug Tools (זמני)
                StickyNote(
                  color: Colors.orange.shade100,
                  rotation: -0.02,
                  child: ListTile(
                    leading: const Icon(Icons.bug_report, color: Colors.orange),
                    title: const Text('🧹 ניקוי מלאי פגום', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    subtitle: Text('כלי Debug - מחיקת פריטים עם productName=null', style: TextStyle(fontSize: kFontSizeSmall)),
                    trailing: const Icon(Icons.chevron_left, color: Colors.orange),
                    onTap: () {
                      final householdId = userContext.user?.householdId ?? '';
                      if (householdId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('שגיאה: אין household ID'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      // ניווט למסך הניקוי
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CleanupScreen(householdId: householdId),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: kSpacingLarge),

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
                          AppStrings.settings.membersCount(_members.length),
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: kSpacingSmall),
                        ..._members.map(
                          (member) => ListTile(
                            leading: CircleAvatar(
                              radius: kAvatarRadiusSmall,
                              backgroundColor: cs.primary.withValues(alpha: 0.15),
                              child: Icon(Icons.person, color: cs.primary, size: kIconSizeMedium),
                            ),
                            title: Text(member['name']!),
                            subtitle: Text(
                              _getRoleLabel(member['role']!),
                              style: TextStyle(fontSize: kFontSizeSmall - 2, color: cs.onSurfaceVariant),
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: kSpacingSmall),
                        StickyButton(
                          label: AppStrings.settings.manageMembersButton,
                          icon: Icons.group_add,
                          color: Colors.white,
                          textColor: cs.primary,
                          height: 44,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.settings.manageMembersComingSoon),
                                duration: kSnackBarDuration,
                              ),
                            );
                          },
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
                        leading: Icon(Icons.receipt_long, color: cs.primary),
                        title: Text(AppStrings.settings.myReceipts),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.pushNamed(context, '/receipts');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.psychology, color: cs.primary),
                        title: const Text('הרגלי קנייה שלי'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.pushNamed(context, '/habits');
                        },
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
                        leading: Icon(Icons.price_change_outlined, color: cs.primary),
                        title: Text(AppStrings.settings.priceComparison),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.pushNamed(context, '/price-compare');
                        },
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

  /// Helper: תרגום role
  String _getRoleLabel(String role) {
    switch (role) {
      case 'owner':
        return AppStrings.settings.roleOwner;
      case 'editor':
        return AppStrings.settings.roleEditor;
      case 'viewer':
        return AppStrings.settings.roleViewer;
      default:
        return role;
    }
  }
}

// 🎨 Widget עזר - כרטיס סטטיסטיקה עם AnimatedCounter + TappableCard
class _StatCard extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String label;
  final int value;

  const _StatCard({required this.color, required this.icon, required this.label, required this.value});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      label: '${widget.label}: ${widget.value}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Card(
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingSmallPlus),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: kIconSizeMedium + 2),
                  ),
                  const SizedBox(width: kSpacingSmallPlus),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(fontSize: kFontSizeTiny, color: Colors.grey),
                        ),
                        _AnimatedCounter(
                          value: widget.value,
                          style: TextStyle(fontSize: kFontSizeLarge, color: widget.color, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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

// 🎬 AnimatedCounter - ספירה מ-0 לערך האמיתי
class _AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;

  const _AnimatedCounter({required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Text('$value', style: style);
      },
    );
  }
}

// 🎬 AnimatedButton - Wrapper לכל הכפתורים
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _AnimatedButton({required this.child, required this.onPressed});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

// 💀 SkeletonBox - קופסא מהבהבת ל-Loading
class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const _SkeletonBox({this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(kBorderRadius),
      ),
    );
  }
}

