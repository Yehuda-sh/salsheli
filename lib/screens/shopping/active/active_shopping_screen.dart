// 📄 File: lib/screens/shopping/active_shopping_screen.dart
//
// 🎯 Purpose: מסך קנייה פעילה - המשתמש בחנות וקונה מוצרים
//
// ✨ Features:
// - ⏱️ טיימר - מודד כמה זמן עובר מתחילת הקנייה
// - 📊 מונים - כמה נקנה / כמה נשאר / כמה לא היה
// - 🗂️ סידור לפי קטגוריות
// - ✅ סימון מוצרים: נקנה / לא במלאי / דחוי
// - 📱 כפתורי פעולה מהירה
// - 🏁 סיכום מפורט בסיום
// - 🎨 Skeleton Screen & Error Handling
// - 💫 Micro Animations
// - 📝 Sticky Notes Design System
//
// 🎨 UI:
// - Header עם טיימר וסטטיסטיקות
// - רשימת מוצרים לפי קטגוריות עם StickyNote
// - כפתורים בסגנון StickyButton
// - מסך סיכום בסוף
// - 4 Empty States: Loading/Error/Empty/Initial
//
// Usage:
// ```dart
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => ActiveShoppingScreen(list: shoppingList),
//   ),
// );
// ```

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/enums/shopping_item_status.dart';
import '../../models/shopping_list.dart';
import '../../models/unified_list_item.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../../services/shopping_patterns_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/skeleton_loading.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/tappable_card.dart';
import '../../widgets/home/last_chance_banner.dart';

class ActiveShoppingScreen extends StatefulWidget {
  final ShoppingList list;

  const ActiveShoppingScreen({super.key, required this.list});

  @override
  State<ActiveShoppingScreen> createState() => _ActiveShoppingScreenState();
}

class _ActiveShoppingScreenState extends State<ActiveShoppingScreen> with SingleTickerProviderStateMixin {
  // 📊 מצבי פריטים (item.id → status)
  final Map<String, ShoppingItemStatus> _itemStatuses = {};

  // 🔄 Loading/Error States
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaving = false;

  // 🧑 UserContext Listener
  late UserContext _userContext;
  bool _listenerAdded = false; // 🔧 עוקב אחרי הוספת listener

  @override
  void initState() {
    super.initState();
    debugPrint('🛒 ActiveShoppingScreen.initState: התחלה');

    // ✅ UserContext Listener - לאזור לשינויים בנתוני המשתמש
    _userContext = context.read<UserContext>();
    _userContext.addListener(_onUserContextChanged);
    _listenerAdded = true; // 🔧 מסמן שהוספנו listener

    _initializeScreen();
  }

  /// אתחול המסך - טעינת נתונים
  Future<void> _initializeScreen() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      debugPrint('🔄 _initializeScreen: מתחיל טעינה');

      // סימולציה של delay קל (במקרה הזה זה מיידי אבל מוכן לעתיד)
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // אתחל את כל הפריטים כ-pending (או טען drafts אם קיימים)
      for (final item in widget.list.items) {
        _itemStatuses[item.id] = ShoppingItemStatus.pending;
      }

      debugPrint('✅ _initializeScreen: ${widget.list.items.length} פריטים');

      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ _initializeScreen Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppStrings.shopping.loadingDataError;
        });
      }
    }
  }

  /// 🔄 בעת שינוי household_id או משתמש
  void _onUserContextChanged() {
    debugPrint('🔄 _onUserContextChanged: שינוי בהקשר המשתמש');
    if (mounted) {
      _initializeScreen();
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ ActiveShoppingScreen.dispose');

    // ✅ ניקוי listener - רק אם הוסף
    if (_listenerAdded) {
      _userContext.removeListener(_onUserContextChanged);
    }

    super.dispose();
  }

  /// עדכון סטטוס פריט + שמירה אוטומטית
  Future<void> _updateItemStatus(UnifiedListItem item, ShoppingItemStatus newStatus) async {
    debugPrint('📝 _updateItemStatus: ${item.name} → ${newStatus.label}');

    setState(() {
      _itemStatuses[item.id] = newStatus;
    });

    // 💾 Auto-save - שמור מיידית ל-Firebase
    try {
      final provider = context.read<ShoppingListsProvider>();
      await provider.updateItemStatus(widget.list.id, item.id, newStatus);
      debugPrint('✅ _updateItemStatus: נשמר אוטומטית');
    } catch (e) {
      debugPrint('❌ _updateItemStatus Auto-save Error: $e');
      // לא מציג שגיאה למשתמש - נשמר בזיכרון מקומי
    }
  }

  /// סיום קנייה - מעבר למסך סיכום
  Future<void> _finishShopping() async {
    debugPrint('🏁 _finishShopping: מתחיל סיכום');

    // ✨ Haptic feedback למשוב מישוש
    unawaited(HapticFeedback.mediumImpact());

    final purchased = _itemStatuses.values.where((s) => s == ShoppingItemStatus.purchased).length;
    final outOfStock = _itemStatuses.values.where((s) => s == ShoppingItemStatus.outOfStock).length;
    final deferred = _itemStatuses.values.where((s) => s == ShoppingItemStatus.deferred).length;
    final notNeeded = _itemStatuses.values.where((s) => s == ShoppingItemStatus.notNeeded).length;
    final pending = _itemStatuses.values.where((s) => s == ShoppingItemStatus.pending).length;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ShoppingSummaryDialog(
        listName: widget.list.name,
        total: widget.list.items.length,
        purchased: purchased,
        outOfStock: outOfStock,
        deferred: deferred,
        notNeeded: notNeeded,
        pending: pending,
      ),
    );

    if (result == true && mounted) {
      debugPrint('✅ _finishShopping: משתמש אישר סיום');
      await _saveAndFinish();
    } else {
      debugPrint('❌ _finishShopping: משתמש ביטל');
    }
  }

  /// שמירה וסיום - עם עדכון מלאי אוטומטי
  Future<void> _saveAndFinish() async {
    // ✅ תפוס context לפני await
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // 🔧 מנקה SnackBar קודם אם קיים (מונע duplicates)
    messenger.clearSnackBars();

    setState(() {
      _isSaving = true;
    });

    try {
      debugPrint('💾 _saveAndFinish: מתחיל תהליך סיום קנייה');

      // 🔧 שמור providers לפני כל await
      final inventoryProvider = context.read<InventoryProvider>();
      final shoppingProvider = context.read<ShoppingListsProvider>();

      // 1️⃣ עדכן מלאי - רק פריטים שנקנו ✅
      final purchasedItems = widget.list.items.where((item) {
        final status = _itemStatuses[item.id];
        return status == ShoppingItemStatus.purchased;
      }).toList();

      if (purchasedItems.isNotEmpty) {
        debugPrint('📦 מעדכן מלאי: ${purchasedItems.length} פריטים');
        await inventoryProvider.updateStockAfterPurchase(purchasedItems);
        debugPrint('✅ מלאי עודכן בהצלחה');

        // 📊 שמור דפוס קנייה (מערכת למידה)
        try {
          final patternsService = ShoppingPatternsService(
            firestore: FirebaseFirestore.instance,
            userContext: _userContext,
          );
          
          // שמור את סדר הקנייה
          final purchasedNames = purchasedItems.map((item) => item.name).toList();
          await patternsService.saveShoppingPattern(
            listType: widget.list.type,
            purchasedItems: purchasedNames,
          );
          debugPrint('✅ דפוס קנייה נשמר בהצלחה');
        } catch (e) {
          debugPrint('⚠️ שמירת דפוס נכשלה (לא קריטי): $e');
        }
      }

      // 2️⃣ העבר פריטים שלא נקנו לרשימה הבאה
      final unpurchasedItems = widget.list.items.where((item) {
        final status = _itemStatuses[item.id];
        return status == ShoppingItemStatus.pending ||
               status == ShoppingItemStatus.deferred ||
               status == ShoppingItemStatus.outOfStock;
      }).toList();

      if (unpurchasedItems.isNotEmpty) {
        debugPrint('🔄 מעביר ${unpurchasedItems.length} פריטים לרשימה הבאה');
        await shoppingProvider.addToNextList(unpurchasedItems);
        debugPrint('✅ פריטים הועברו לרשימה הבאה');
      }

      // 3️⃣ בדוק אם יש פריטים שלא טופלו (נשארו במצב pending)
      final pendingItems = widget.list.items.where((item) {
        final status = _itemStatuses[item.id];
        return status == ShoppingItemStatus.pending;
      }).toList();

      // סמן רשימה כהושלמה רק אם אין פריטים ב-pending
      if (pendingItems.isEmpty) {
        debugPrint('🏁 מסמן רשימה כהושלמה - כל הפריטים סומנו');
        await shoppingProvider.updateListStatus(widget.list.id, ShoppingList.statusCompleted);
        debugPrint('✅ רשימה הושלמה!');
      } else {
        debugPrint('🔄 הרשימה נשארת פעילה - ${pendingItems.length} פריטים לא סומנו');
        debugPrint('   פריטים שלא סומנו: ${pendingItems.map((i) => i.name).join(", ")}');
      }

      // ✅ בדוק אם עדיין mounted לפני שימוש ב-context
      if (!mounted) return;
      
      // הצג הודעת הצלחה עם פרטים
      String message = pendingItems.isEmpty 
          ? AppStrings.shopping.shoppingCompletedSuccess
          : 'הקנייה נשמרה';
          
      if (purchasedItems.isNotEmpty) {
        message += '\n${AppStrings.shopping.pantryUpdated(purchasedItems.length)}';
      }
      if (unpurchasedItems.isNotEmpty) {
        message += '\n${AppStrings.shopping.itemsMovedToNext(unpurchasedItems.length)}';
      }
      if (pendingItems.isNotEmpty) {
        message += '\n⚠️ ${pendingItems.length} פריטים לא סומנו והרשימה נשארת פעילה';
      }
        
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: kSpacingSmall),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: StatusColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // המתן קצת להודעה ואז חזור
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;

        debugPrint('🚪 _saveAndFinish: מעבר למסך סיכום');
        unawaited(navigator.pushReplacementNamed('/shopping-summary', arguments: widget.list.id));
    } catch (e) {
      debugPrint('❌ _saveAndFinish Error: $e');

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        // הצג הודעת שגיאה עם אפשרות retry
        final shouldRetry = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: StatusColors.error),
                const SizedBox(width: kSpacingSmall),
                Text(AppStrings.shopping.saveError),
              ],
            ),
            content: Text(AppStrings.shopping.saveErrorMessage, style: const TextStyle(fontSize: kFontSizeBody)),
            actions: [
              TextButton(
                onPressed: () {
                  unawaited(HapticFeedback.lightImpact());
                  Navigator.pop(context, false);
                },
                child: Text(AppStrings.common.cancel),
              ),
              FilledButton.icon(
                onPressed: () {
                  unawaited(HapticFeedback.mediumImpact());
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppStrings.common.retry),
              ),
            ],
          ),
        );

        if (shouldRetry == true && mounted) {
          await _saveAndFinish(); // Retry
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // 🔐 Prevent build during saving
    if (_isSaving && !mounted) return const SizedBox.shrink();

    // 🔄 Loading State
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(backgroundColor: accent, foregroundColor: Colors.white, title: Text(widget.list.name)),
        body: _LoadingSkeletonScreen(accentColor: accent),
      );
    }

    // ❌ Error State
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(backgroundColor: accent, foregroundColor: Colors.white, title: Text(widget.list.name)),
        body: _ErrorStateScreen(errorMessage: _errorMessage!, onRetry: _initializeScreen),
      );
    }

    // 📭 Empty State - אם אין פריטים
    if (widget.list.items.isEmpty) {
      return Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          title: Text(widget.list.name, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
        body: _EmptyStateScreen(accentColor: accent),
      );
    }

    // חשב סטטיסטיקות
    final purchased = _itemStatuses.values.where((s) => s == ShoppingItemStatus.purchased).length;
    final notNeeded = _itemStatuses.values.where((s) => s == ShoppingItemStatus.notNeeded).length;
    final completed = purchased + notNeeded;
    final total = widget.list.items.length;

    // קבץ לפי קטגוריה
    final productsProvider = context.watch<ProductsProvider>();
    final itemsByCategory = <String, List<UnifiedListItem>>{};
    for (final item in widget.list.items) {
      final product = productsProvider.getByName(item.name);
      final category = product?['category'] as String? ?? AppStrings.shopping.categoryGeneral;
      itemsByCategory.putIfAbsent(category, () => []).add(item);
    }

    return Stack(
      children: [
        // 📓 Sticky Notes Background
        const NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            title: Text(
              widget.list.name,
              style: const TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            actions: [
              Semantics(
                label: _isSaving ? 'שומר נתונים' : 'סיים קנייה',
                button: true,
                enabled: !_isSaving,
                child: TextButton.icon(
                  onPressed: _isSaving ? null : _finishShopping,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: Text(
                    _isSaving ? AppStrings.shopping.activeSaving : AppStrings.shopping.activeFinish,
                    style: TextStyle(color: _isSaving ? Colors.white.withValues(alpha: 0.5) : Colors.white),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // 📊 Header - סטטיסטיקות בתוך StickyNote
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: StickyNote(
                  color: kStickyYellow,
                  rotation: -0.01,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          icon: Icons.check_circle,
                          label: AppStrings.shopping.activePurchased,
                          value: '$purchased',
                          color: StatusColors.success,
                        ),
                        _StatCard(
                          icon: Icons.block,
                          label: AppStrings.shopping.activeNotNeeded,
                          value: '$notNeeded',
                          color: Colors.grey.shade600,
                        ),
                        _StatCard(
                          icon: Icons.shopping_cart,
                          label: AppStrings.shopping.activeRemaining,
                          value: '${total - completed}',
                          color: StatusColors.info,
                        ),
                        _StatCard(icon: Icons.inventory_2, label: AppStrings.shopping.activeTotal, value: '$total', color: StatusColors.pending),
                      ],
                    ),
                  ),
                ),
              ),

              // ⚠️ הזדמנות אחרונה - באנר המלצות
              LastChanceBanner(activeListId: widget.list.id),

              // 🗂️ רשימת מוצרים לפי קטגוריות
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  itemCount: itemsByCategory.length,
                  itemBuilder: (context, index) {
                    final category = itemsByCategory.keys.elementAt(index);
                    final items = itemsByCategory[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // כותרת קטגוריה - בתוך StickyNote
                        StickyNote(
                          color: kStickyCyan,
                          rotation: 0.01,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingTiny),
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: kSpacingSmall),

                        // פריטים בקטגוריה
                        ...items.map<Widget>(
                          (item) => _ActiveShoppingItemTile(
                            item: item,
                            status: _itemStatuses[item.id]!,
                            onStatusChanged: (newStatus) => _updateItemStatus(item, newStatus),
                          ),
                        ),

                        const SizedBox(height: kSpacingMedium),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 💾 Saving Overlay
        if (_isSaving)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: StickyNote(
                color: kStickyYellow,
                rotation: 0.01,
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: accent),
                      const SizedBox(height: kSpacingMedium),
                      Text(
                        AppStrings.shopping.activeSavingData,
                        style: const TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }


}

// ========================================
// Widget: Loading Skeleton Screen
// ========================================

class _LoadingSkeletonScreen extends StatelessWidget {
  final Color accentColor;

  const _LoadingSkeletonScreen({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Stats Header Skeleton
        Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor.withValues(alpha: 0.1), cs.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (index) => const SkeletonBox(width: 60, height: 80),
            ),
          ),
        ),

        // Items List Skeleton
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(kSpacingMedium),
            itemCount: 5,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.only(bottom: kSpacingSmall),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingSmallPlus),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SkeletonBox(
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: kSpacingSmall),
                        const Expanded(child: SkeletonBox(height: 20)),
                        const SizedBox(width: kSpacingSmall),
                        const SkeletonBox(width: 60, height: 30),
                      ],
                    ),
                    const SizedBox(height: kSpacingSmall),
                    const Row(
                      children: [
                        Expanded(child: SkeletonBox(height: kButtonHeight)),
                        SizedBox(width: kSpacingSmall),
                        Expanded(child: SkeletonBox(height: kButtonHeight)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: Error State Screen
// ========================================

class _ErrorStateScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorStateScreen({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: kIconSizeXLarge * 2, color: StatusColors.error),
            const SizedBox(height: kSpacingMedium),
            Text(
              AppStrings.shopping.oopsError,
              style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              errorMessage,
              style: TextStyle(fontSize: kFontSizeBody, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            Semantics(
              label: 'נסה לטעון שוב',
              button: true,
              child: StickyButton(label: AppStrings.common.retry, icon: Icons.refresh, onPressed: onRetry, color: StatusColors.info),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Widget: Empty State Screen
// ========================================

class _EmptyStateScreen extends StatelessWidget {
  final Color accentColor;

  const _EmptyStateScreen({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: kIconSizeXLarge * 2, color: cs.onSurfaceVariant),
          const SizedBox(height: kSpacingMedium),
          Text(
            AppStrings.shopping.listEmpty,
            style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            AppStrings.shopping.noItemsToBuy,
            style: TextStyle(fontSize: kFontSizeBody, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: כרטיס סטטיסטיקה
// ========================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmall,
        vertical: kSpacingTiny,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: kIconSizeLarge),
          const SizedBox(height: kSpacingTiny),
          Text(
            value,
            style: TextStyle(
              fontSize: kFontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: פריט בקנייה פעילה - Checkbox Style
// ========================================

class _ActiveShoppingItemTile extends StatelessWidget {
  final UnifiedListItem item;
  final ShoppingItemStatus status;
  final Future<void> Function(ShoppingItemStatus) onStatusChanged;

  const _ActiveShoppingItemTile({
    required this.item,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 💰 שליפת מחיר אמיתי מ-ProductsProvider
    final productsProvider = context.watch<ProductsProvider>();
    final product = productsProvider.getByName(item.name);
    final realPrice = product?['price'] as double? ?? (item.unitPrice ?? 0.0);

    // 🎨 צבע StickyNote לפי סטטוס
    Color stickyColor;
    double rotation;
    switch (status) {
      case ShoppingItemStatus.purchased:
        stickyColor = kStickyGreen;
        rotation = 0.01;
        break;
      case ShoppingItemStatus.outOfStock:
        stickyColor = kStickyPink;
        rotation = -0.015;
        break;
      case ShoppingItemStatus.deferred:
        stickyColor = kStickyPurple;
        rotation = 0.02;
        break;
      case ShoppingItemStatus.notNeeded:
        stickyColor = Colors.grey.shade200;
        rotation = -0.01;
        break;
      default:
        stickyColor = Colors.white;
        rotation = 0.005;
    }

    return SimpleTappableCard(
      // לא צריך onTap - הכפתורים בפנים מטפלים
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: kSpacingSmall),
        child: StickyNote(
          color: stickyColor,
          rotation: rotation,
          child: Column(
            children: [
              // שורה עליונה: שם + מחיר
              Row(
                children: [
                  // אייקון סטטוס
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      status.icon,
                      key: ValueKey(status),
                      color: status.color,
                      size: status == ShoppingItemStatus.pending ? kIconSizeMedium + 4 : kIconSizeLarge,
                    ),
                  ),
                  const SizedBox(width: kSpacingSmallPlus),

                  // שם המוצר
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: kFontSizeBody,
                        fontWeight: FontWeight.w600,
                        decoration: status == ShoppingItemStatus.purchased ? TextDecoration.lineThrough : null,
                        color: status == ShoppingItemStatus.pending
                            ? cs.onSurface
                            : cs.onSurface.withValues(alpha: 0.7),
                      ),
                      child: Text(item.name, overflow: TextOverflow.ellipsis, maxLines: 2),
                    ),
                  ),

                  // כמות × מחיר אמיתי
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppStrings.shopping.quantityMultiplier(item.quantity ?? 1),
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: status == ShoppingItemStatus.pending
                              ? cs.onSurfaceVariant
                              : cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        realPrice > 0 ? AppStrings.shopping.priceFormat(realPrice) : AppStrings.shopping.noPrice,
                        style: TextStyle(
                          fontSize: kFontSizeBody,
                          fontWeight: FontWeight.bold,
                          color: realPrice > 0
                              ? (status == ShoppingItemStatus.pending
                                    ? status.color
                                    : status.color.withValues(alpha: 0.8))
                              : cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: kSpacingSmallPlus),

              // שורה תחתונה: Checkbox + תפריט
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ Checkbox = קנוי
                  CheckboxListTile(
                    value: status == ShoppingItemStatus.purchased,
                    onChanged: (checked) {
                      // ✨ Haptic feedback למשוב מישוש
                      unawaited(HapticFeedback.selectionClick());

                      if (checked == true) {
                        onStatusChanged(ShoppingItemStatus.purchased);
                      } else {
                        onStatusChanged(ShoppingItemStatus.pending);
                      }
                    },
                    title: Text(
                      AppStrings.shopping.activePurchased,
                      style: const TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.w600),
                    ),
                    activeColor: StatusColors.success,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),

                  const SizedBox(height: kSpacingSmall),

                  // שורת כפתורים: אין בחנות + מוצר חלופי
                  Row(
                    children: [
                      // ❌ כפתור "אין בחנות"
                      Expanded(
                        child: StickyButton(
                          label: 'אין בחנות',
                          icon: Icons.remove_shopping_cart,
                          color: status == ShoppingItemStatus.outOfStock ? StatusColors.error : Colors.white,
                          textColor: status == ShoppingItemStatus.outOfStock ? Colors.white : StatusColors.error,
                          height: 40,
                          onPressed: () {
                            // ✨ Haptic feedback למשוב מישוש
                            unawaited(HapticFeedback.lightImpact());
                            onStatusChanged(ShoppingItemStatus.outOfStock);
                          },
                        ),
                      ),

                      const SizedBox(width: kSpacingSmall),

                      // 🔄 כפתור "מוצר חלופי"
                      Expanded(
                        child: StickyButton(
                          label: 'מוצר חלופי',
                          icon: Icons.swap_horiz,
                          color: kStickyPurple,
                          textColor: Colors.white,
                          height: 40,
                          onPressed: () {
                            // ✨ Haptic feedback למשוב מישוש
                            unawaited(HapticFeedback.lightImpact());

                            // TODO: פתח דיאלוג בחירת מוצר חלופי
                            // לעת עתה - סמן כנקנה
                            onStatusChanged(ShoppingItemStatus.purchased);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// ========================================
// Dialog: סיכום קנייה
// ========================================

class _ShoppingSummaryDialog extends StatelessWidget {
  final String listName;
  final int total;
  final int purchased;
  final int outOfStock;
  final int deferred;
  final int notNeeded;
  final int pending;

  const _ShoppingSummaryDialog({
    required this.listName,
    required this.total,
    required this.purchased,
    required this.outOfStock,
    required this.deferred,
    required this.notNeeded,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: StatusColors.success, size: kIconSizeLarge),
          const SizedBox(width: kSpacingSmallPlus),
          Expanded(
            child: Text(
              AppStrings.shopping.summaryTitle,
              style: TextStyle(fontSize: kFontSizeLarge + 4, fontWeight: FontWeight.bold, color: cs.onSurface),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listName,
              style: TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold, color: cs.primary),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: kSpacingMedium),

            const Divider(height: kSpacingLarge),

            // ✅ קנוי
            _SummaryRow(
              icon: Icons.check_circle,
              label: AppStrings.shopping.activePurchased,
              value: AppStrings.shopping.summaryPurchased(purchased, total),
              color: StatusColors.success,
            ),

            // 🚫 לא צריך
            if (notNeeded > 0)
              _SummaryRow(icon: Icons.block, label: AppStrings.shopping.activeNotNeeded, value: '$notNeeded', color: Colors.grey.shade700),

            // ❌ אזלו
            if (outOfStock > 0)
              _SummaryRow(
                icon: Icons.remove_shopping_cart,
                label: AppStrings.shopping.summaryOutOfStock,
                value: '$outOfStock',
                color: StatusColors.error,
              ),

            // ⏭️ נדחו
            if (deferred > 0)
              _SummaryRow(
                icon: Icons.schedule,
                label: AppStrings.shopping.summaryDeferred,
                value: '$deferred',
                color: StatusColors.warning,
              ),

            // ⏸️ לא סומנו
            if (pending > 0)
              _SummaryRow(
                icon: Icons.radio_button_unchecked,
                label: AppStrings.shopping.summaryNotMarked,
                value: '$pending',
                color: StatusColors.pending,
              ),
          ],
        ),
      ),
      actions: [
        Semantics(
          label: 'חזור לרשימה',
          button: true,
          child: TextButton(
            onPressed: () {
              unawaited(HapticFeedback.lightImpact());
              Navigator.pop(context, false);
            },
            child: Text(AppStrings.shopping.summaryBack),
          ),
        ),
        Semantics(
          label: 'סיים קנייה ושמור',
          button: true,
          child: StickyButton(
            label: AppStrings.shopping.summaryFinishShopping,
            icon: Icons.check,
            onPressed: () {
              unawaited(HapticFeedback.mediumImpact());
              Navigator.pop(context, true);
            },
            color: StatusColors.success,
            textColor: Colors.white,
            height: 44,
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: שורת סיכום
// ========================================

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      child: Row(
        children: [
          Icon(icon, color: color, size: kIconSizeMedium + 2),
          const SizedBox(width: kSpacingSmallPlus),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: kFontSizeBody)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
