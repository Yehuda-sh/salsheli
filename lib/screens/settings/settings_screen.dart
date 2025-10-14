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
// 🎬 Animations (חדש! v3.0):
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
// Version: 3.0 - Modern UI/UX Complete ⭐
// Last Updated: 14/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salsheli/providers/user_context.dart';
import 'package:salsheli/providers/shopping_lists_provider.dart';
import 'package:salsheli/providers/receipt_provider.dart';
import 'package:salsheli/providers/inventory_provider.dart';
import 'package:salsheli/providers/products_provider.dart';
import 'package:salsheli/models/shopping_list.dart';
import 'package:salsheli/l10n/app_strings.dart';
import 'package:salsheli/core/ui_constants.dart';
import 'package:salsheli/config/household_config.dart';

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

  // טעינת הגדרות מ-SharedPreferences
  Future<void> _loadSettings() async {
    debugPrint('📥 _loadSettings: מתחיל טעינה');
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
      debugPrint('✅ _loadSettings: נטען בהצלחה');
    } catch (e) {
      debugPrint('❌ _loadSettings: שגיאה - $e');
      setState(() {
        _errorMessage = AppStrings.settings.loadError(e.toString());
        _loading = false;
      });
    }
  }

  // שמירת הגדרות ב-SharedPreferences
  Future<void> _saveSettings() async {
    debugPrint('💾 _saveSettings: שומר הגדרות');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kHouseholdName, _householdName);
      await prefs.setString(_kHouseholdType, _householdType);
      await prefs.setInt(_kFamilySize, _familySize);
      await prefs.setBool(_kWeeklyReminders, _weeklyReminders);
      await prefs.setBool(_kHabitsAnalysis, _habitsAnalysis);
      await prefs.setString(_kPreferredStores, _preferredStores.join(','));
      debugPrint('✅ _saveSettings: נשמר בהצלחה');
      
      // Visual feedback - שמור messenger לפני async
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

  // עריכת שם הקבוצה
  void _toggleEditHousehold() {
    debugPrint('✏️ _toggleEditHousehold: ${_isEditingHouseholdName ? "שומר" : "עורך"}');
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

  // הוספת חנות מועדפת
  void _addStore() {
    final text = _storeController.text.trim();
    debugPrint('➕ _addStore: "$text"');
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

  // הסרת חנות
  void _removeStore(int index) {
    debugPrint('🗑️ _removeStore: מוחק index $index');
    setState(() => _preferredStores.removeAt(index));
    _saveSettings();
  }

  // שינוי סוג הקבוצה
  void _changeHouseholdType(String? newType) {
    if (newType != null) {
      debugPrint('🔄 _changeHouseholdType: $newType');
      setState(() => _householdType = newType);
      _saveSettings();
    }
  }

  // עדכון גודל משפחה
  void _updateFamilySize() {
    final newSize = int.tryParse(_familySizeController.text);
    debugPrint('🔄 _updateFamilySize: $newSize');
    if (newSize != null && newSize > 0 && newSize <= 20) {
      setState(() => _familySize = newSize);
      _saveSettings();
      debugPrint('✅ _updateFamilySize: עודכן ל-$newSize');
    } else {
      debugPrint('❌ _updateFamilySize: ערך לא תקין');
    }
  }

  // עדכון מחירים ידני
  Future<void> _updatePrices(BuildContext context) async {
    debugPrint('💰 _updatePrices: מתחיל עדכון');
    final productsProvider = context.read<ProductsProvider>();
    
    // שמור messenger לפני async
    final messenger = ScaffoldMessenger.of(context);
    
    // הצגת SnackBar עם loading
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ),
            const SizedBox(width: kSpacingMedium),
            Text(AppStrings.settings.updatingPrices),
          ],
        ),
        duration: const Duration(minutes: 5), // זמן ארוך לעדכון
      ),
    );

    try {
      // קריאה ל-refreshProducts עם force=true
      await productsProvider.refreshProducts(force: true);

      // סגירת SnackBar הקודם
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      
      // הצגת תוצאה
      final withPrice = productsProvider.productsWithPrice;
      final total = productsProvider.totalProducts;
      
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.settings.pricesUpdated(withPrice, total),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      debugPrint('✅ _updatePrices: הצליח - $withPrice/$total');
    } catch (e) {
      debugPrint('❌ _updatePrices: שגיאה - $e');
      // שגיאה
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.settings.pricesUpdateError(e.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // התנתקות
  Future<void> _logout() async {
    debugPrint('🔓 _logout: מתחיל התנתקות');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.settings.logoutTitle),
        content: Text(AppStrings.settings.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.settings.logoutCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.settings.logoutConfirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      debugPrint('✅ _logout: אושר - מנקה נתונים');
      // ניקוי UserContext
      await context.read<UserContext>().logout();

      // ניקוי SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // חזרה למסך התחברות
      if (!mounted) return;
      debugPrint('🚪 _logout: מעביר ל-login');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    } else {
      debugPrint('❌ _logout: בוטל');
    }
  }

  // retry אחרי שגיאה
  void _retry() {
    debugPrint('🔄 _retry: מנסה שוב');
    setState(() {
      _errorMessage = null;
      _loading = true;
    });
    _loadSettings();
  }

  // 💀 Skeleton Screen ל-Loading State
  Widget _buildLoadingSkeleton(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(kSpacingMedium),
      children: [
        // פרופיל skeleton
        _SkeletonBox(
          width: double.infinity,
          height: 100,
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
        const SizedBox(height: kSpacingMedium),

        // סטטיסטיקות skeleton
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
        _SkeletonBox(
          width: double.infinity,
          height: 80,
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        const SizedBox(height: kSpacingLarge),

        // קבוצה skeleton
        _SkeletonBox(
          width: double.infinity,
          height: 200,
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
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
    final activeLists = listsProvider.lists
        .where((l) => l.status != ShoppingList.statusCompleted)
        .length;
    final totalReceipts = receiptsProvider.receipts.length;
    final pantryItems = inventoryProvider.items.length;

    // פרטי משתמש
    final userName = userContext.user?.name ?? AppStrings.home.guestUser;
    final userEmail = userContext.user?.email ?? "email@example.com";

    // 💀 Loading State - Skeleton!
    if (_loading) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(AppStrings.settings.title),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
        ),
        body: SafeArea(
          child: _buildLoadingSkeleton(cs),
        ),
      );
    }

    // Error State
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
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
              ElevatedButton(
                onPressed: _retry,
                child: Text(AppStrings.priceComparison.retry),
              ),
            ],
          ),
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(kSpacingMedium),
          children: [
            // 🔹 פרופיל אישי
            Card(
              color: cs.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Row(
                  children: [
                    // תמונת פרופיל
                    CircleAvatar(
                      radius: kAvatarRadius,
                      backgroundColor: cs.primary.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person,
                        color: cs.primary,
                        size: kIconSizeProfile,
                      ),
                    ),
                    const SizedBox(width: kSpacingMedium),

                    // פרטים
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: kFontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: kSpacingTiny),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              color: cs.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),

                    // כפתור עריכה
                    _AnimatedButton(
                      onPressed: () {
                        debugPrint('✏️ Edit Profile: clicked');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.settings.editProfileButton),
                          ),
                        );
                      },
                      child: FilledButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.edit, size: kIconSizeSmall + 2),
                        label: Text(AppStrings.settings.editProfile),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpacingSmallPlus,
                            vertical: kSpacingSmall,
                          ),
                          minimumSize: const Size(kButtonHeight, kButtonHeight),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: kSpacingMedium),

            // 🔹 סטטיסטיקות מהירות - עם AnimatedCounter!
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

            const SizedBox(height: kSpacingLarge),

            // 🔹 ניהול קבוצה
            Card(
              color: cs.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.settings.householdTitle,
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // שם הקבוצה
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
                                  style: const TextStyle(
                                    fontSize: kFontSizeBody,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        IconButton(
                          onPressed: _toggleEditHousehold,
                          icon: Icon(
                            _isEditingHouseholdName ? Icons.check : Icons.edit,
                            color: cs.primary,
                          ),
                          tooltip: _isEditingHouseholdName
                              ? AppStrings.settings.editHouseholdNameSave
                              : AppStrings.settings.editHouseholdNameEdit,
                        ),
                      ],
                    ),

                    const SizedBox(height: kSpacingSmallPlus),

                    // סוג הקבוצה
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.settings.householdType,
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _householdType,
                          items: HouseholdConfig.allTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(
                                        HouseholdConfig.getIcon(type),
                                        size: kIconSizeSmall,
                                      ),
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

                    // חברי הקבוצה
                    Text(
                      AppStrings.settings.membersCount(_members.length),
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: kSpacingSmall),

                    // רשימת חברים
                    ..._members.map(
                      (member) => ListTile(
                        leading: CircleAvatar(
                          radius: kAvatarRadiusSmall,
                          backgroundColor: cs.primary.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.person,
                            color: cs.primary,
                            size: kIconSizeMedium,
                          ),
                        ),
                        title: Text(member['name']!),
                        subtitle: Text(
                          _getRoleLabel(member['role']!),
                          style: TextStyle(
                            fontSize: kFontSizeSmall - 2,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: kSpacingSmall),

                    // כפתור ניהול חברים (עתידי)
                    _AnimatedButton(
                      onPressed: () {
                        debugPrint('👥 Manage Members: clicked');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.settings.manageMembersComingSoon,
                            ),
                            duration: kSnackBarDuration,
                          ),
                        );
                      },
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.group_add, size: kIconSizeMedium),
                        label: Text(AppStrings.settings.manageMembersButton),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 42),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: kSpacingMedium),

            // 🔹 חנויות מועדפות
            Card(
              color: cs.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.settings.storesTitle,
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: kSpacingSmallPlus),

                    // רשימת חנויות
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

                    // הוספת חנות
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _storeController,
                            decoration: InputDecoration(
                              hintText: AppStrings.settings.addStoreHint,
                              isDense: true,
                            ),
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
            Card(
              color: cs.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.settings.personalSettingsTitle,
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: kSpacingSmallPlus),

                    // גודל קבוצה - תוקן! kFieldWidthNarrow במקום kQuantityFieldWidth
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.settings.familySizeLabel),
                        SizedBox(
                          width: kFieldWidthNarrow, // ✅ תוקן!
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

                    // תזכורות שבועיות
                    SwitchListTile(
                      title: Text(AppStrings.settings.weeklyRemindersLabel),
                      subtitle: Text(AppStrings.settings.weeklyRemindersSubtitle),
                      value: _weeklyReminders,
                      onChanged: (val) {
                        debugPrint('🔔 weeklyReminders: $val');
                        setState(() => _weeklyReminders = val);
                        _saveSettings();
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    // ניתוח הרגלים
                    SwitchListTile(
                      title: Text(AppStrings.settings.habitsAnalysisLabel),
                      subtitle: Text(AppStrings.settings.habitsAnalysisSubtitle),
                      value: _habitsAnalysis,
                      onChanged: (val) {
                        debugPrint('📊 habitsAnalysis: $val');
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
            Card(
              color: cs.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.receipt_long, color: cs.primary),
                    title: Text(AppStrings.settings.myReceipts),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      debugPrint('🧾 Navigating to receipts');
                      Navigator.pushNamed(context, '/receipts');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.inventory_2_outlined, color: cs.primary),
                    title: Text(AppStrings.settings.myPantry),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      debugPrint('📦 Navigating to inventory');
                      Navigator.pushNamed(context, '/inventory');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.price_change_outlined, color: cs.primary),
                    title: Text(AppStrings.settings.priceComparison),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      debugPrint('💰 Navigating to price compare');
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
            Card(
              color: cs.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  AppStrings.settings.logoutTitle,
                  style: const TextStyle(color: Colors.red),
                ),
                subtitle: Text(AppStrings.settings.logoutSubtitle),
                onTap: _logout,
              ),
            ),

            const SizedBox(height: kSpacingLarge),
          ],
        ),
      ),
    );
  }

  // Helper: תרגום role
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

  const _StatCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
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
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: kIconSizeMedium + 2,
                    ),
                  ),
                  const SizedBox(width: kSpacingSmallPlus),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: kFontSizeTiny,
                            color: Colors.grey,
                          ),
                        ),
                        // 🎬 AnimatedCounter!
                        _AnimatedCounter(
                          value: widget.value,
                          style: TextStyle(
                            fontSize: kFontSizeLarge,
                            color: widget.color,
                            fontWeight: FontWeight.bold,
                          ),
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

  const _AnimatedCounter({
    required this.value,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Text(
          '$value',
          style: style,
        );
      },
    );
  }
}

// 🎬 AnimatedButton - Wrapper לכל הכפתורים
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _AnimatedButton({
    required this.child,
    required this.onPressed,
  });

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

  const _SkeletonBox({
    this.width,
    this.height,
    this.borderRadius,
  });

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
