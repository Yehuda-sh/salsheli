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

import '../../../config/filters_config.dart';
import '../../../core/status_colors.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/enums/shopping_item_status.dart';
import '../../../models/receipt.dart';
import '../../../models/shopping_list.dart';
import '../../../models/unified_list_item.dart';
import '../../../providers/inventory_provider.dart';
import '../../../providers/products_provider.dart';
import '../../../providers/receipt_provider.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/user_context.dart';
import '../../../services/shopping_patterns_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/sticky_button.dart';
import '../../home/dashboard/widgets/last_chance_banner.dart';

class ActiveShoppingScreen extends StatefulWidget {
  final ShoppingList list;

  const ActiveShoppingScreen({super.key, required this.list});

  @override
  State<ActiveShoppingScreen> createState() => _ActiveShoppingScreenState();
}

class _ActiveShoppingScreenState extends State<ActiveShoppingScreen> {
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
      final receiptProvider = context.read<ReceiptProvider>();

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

      // 4️⃣ צור קבלה וירטואלית מהפריטים שנקנו
      if (purchasedItems.isNotEmpty) {
        try {
          debugPrint('🧾 יוצר קבלה וירטואלית...');
          final userId = _userContext.user?.id;
          final listName = widget.list.name;

          // המר UnifiedListItem ל-ReceiptItem
          final receiptItems = purchasedItems.map((item) => ReceiptItem(
            id: item.id,
            name: item.name,
            quantity: item.quantity ?? 1,
            isChecked: true,
            category: item.category,
            checkedBy: userId,
            checkedAt: DateTime.now(),
          )).toList();

          await receiptProvider.createReceipt(
            storeName: listName,
            date: DateTime.now(),
            items: receiptItems,
          );
          debugPrint('✅ קבלה וירטואלית נוצרה בהצלחה');
        } catch (e) {
          debugPrint('⚠️ יצירת קבלה וירטואלית נכשלה (לא קריטי): $e');
        }
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
                const Icon(Icons.error_outline, color: StatusColors.error),
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
          ),
          // 🏁 FAB - כפתור סיום קנייה
          floatingActionButton: _isSaving
              ? null
              : FloatingActionButton.large(
                  onPressed: _finishShopping,
                  backgroundColor: StatusColors.success,
                  child: const Icon(Icons.check, color: Colors.white, size: 36),
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: Column(
            children: [
              // 📊 Header קומפקטי - סטטיסטיקות (flat design)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
                decoration: BoxDecoration(
                  color: kStickyYellow.withValues(alpha: kHighlightOpacity),
                  border: const Border(
                    bottom: BorderSide(color: Colors.black12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ✅ קניתי
                    _CompactStat(
                      icon: Icons.check_circle,
                      value: purchased,
                      total: total,
                      color: StatusColors.success,
                    ),
                    _buildDivider(),
                    // 🚫 לא צריך
                    _CompactStat(
                      icon: Icons.block,
                      value: notNeeded,
                      color: Colors.grey,
                    ),
                    _buildDivider(),
                    // 🛒 נותרו
                    _CompactStat(
                      icon: Icons.shopping_cart,
                      value: total - completed,
                      color: StatusColors.info,
                      highlight: true,
                    ),
                  ],
                ),
              ),

              // 📖 מדריך אייקונים (flat design)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingTiny),
                color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ✓ קניתי
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: StatusColors.success, size: 18),
                        const SizedBox(width: 4),
                        Text('קניתי', style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant)),
                      ],
                    ),
                    // 🛒❌ אין במלאי
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.remove_shopping_cart, color: StatusColors.error, size: 18),
                        const SizedBox(width: 4),
                        Text('אין במלאי', style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant)),
                      ],
                    ),
                    // 🚫 לא צריך
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.block, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text('לא צריך', style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kSpacingSmall),

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
                        // 📌 כותרת קטגוריה - Highlighter style
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            right: kSpacingMedium,
                            top: kSpacingXTiny,
                            bottom: kSpacingXTiny,
                          ),
                          decoration: BoxDecoration(
                            color: kStickyCyan.withValues(alpha: kHighlightOpacity),
                            border: const Border(
                              right: BorderSide(color: Colors.black12, width: 4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                getCategoryEmoji(hebrewCategoryToEnglish(category) ?? 'other'),
                                style: const TextStyle(fontSize: kFontSizeLarge),
                              ),
                              const SizedBox(width: kSpacingSmall),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: kFontSizeMedium,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              // 🔢 מספר פריטים בקטגוריה
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: kSpacingSmall,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${items.length}',
                                  style: const TextStyle(
                                    fontSize: kFontSizeSmall,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
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
              child: Card(
                color: kStickyYellow,
                elevation: kCardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                ),
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
            itemBuilder: (context, index) => const Card(
              margin: EdgeInsets.only(bottom: kSpacingSmall),
              child: Padding(
                padding: EdgeInsets.all(kSpacingSmallPlus),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(width: kSpacingSmall),
                        Expanded(child: SkeletonBox(width: double.infinity, height: 20)),
                        SizedBox(width: kSpacingSmall),
                        SkeletonBox(width: 60, height: 30),
                      ],
                    ),
                    SizedBox(height: kSpacingSmall),
                    Row(
                      children: [
                        Expanded(child: SkeletonBox(width: double.infinity, height: kButtonHeight)),
                        SizedBox(width: kSpacingSmall),
                        Expanded(child: SkeletonBox(width: double.infinity, height: kButtonHeight)),
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
            const Icon(Icons.error_outline, size: kIconSizeXLarge * 2, color: StatusColors.error),
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
// Widget: סטטיסטיקה קומפקטית
// ========================================

class _CompactStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final int? total;
  final Color color;
  final bool highlight;

  const _CompactStat({
    required this.icon,
    required this.value,
    this.total,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          total != null ? '$value/$total' : '$value',
          style: TextStyle(
            fontSize: highlight ? kFontSizeLarge : kFontSizeBody,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// קו מפריד אנכי
Widget _buildDivider() {
  return Container(
    height: 24,
    width: 1,
    color: Colors.black.withValues(alpha: 0.2),
  );
}

// ========================================
// Widget: פריט בקנייה פעילה - שורה פשוטה על המחברת
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

    // 🎨 צבע רקע לפי סטטוס
    Color? backgroundColor;
    switch (status) {
      case ShoppingItemStatus.purchased:
        backgroundColor = StatusColors.successOverlay;
        break;
      case ShoppingItemStatus.outOfStock:
        backgroundColor = StatusColors.errorOverlay;
        break;
      case ShoppingItemStatus.notNeeded:
        backgroundColor = Colors.grey.withValues(alpha: 0.2);
        break;
      default:
        backgroundColor = null;
    }

    return Container(
      height: kNotebookLineSpacing, // 48px = שורה אחת במחברת
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Row(
        children: [
          // ✅ Checkbox - סימון כנקנה
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () {
                unawaited(HapticFeedback.selectionClick());
                if (status == ShoppingItemStatus.purchased) {
                  onStatusChanged(ShoppingItemStatus.pending);
                } else {
                  onStatusChanged(ShoppingItemStatus.purchased);
                }
              },
              child: Icon(
                status == ShoppingItemStatus.purchased
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                key: ValueKey(status == ShoppingItemStatus.purchased),
                color: status == ShoppingItemStatus.purchased
                    ? StatusColors.success
                    : cs.onSurfaceVariant,
                size: 28,
              ),
            ),
          ),

          const SizedBox(width: kSpacingSmall),

          // 📝 שם המוצר
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.bodyLarge!.copyWith(
                decoration: status == ShoppingItemStatus.purchased
                    ? TextDecoration.lineThrough
                    : null,
                color: status == ShoppingItemStatus.purchased ||
                        status == ShoppingItemStatus.notNeeded
                    ? cs.onSurfaceVariant.withValues(alpha: 0.6)
                    : cs.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 🔢 תג כמות
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '×${item.quantity ?? 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: kSpacingXTiny),

          // ❌ כפתור "אין במלאי"
          GestureDetector(
            onTap: () {
              unawaited(HapticFeedback.lightImpact());
              if (status == ShoppingItemStatus.outOfStock) {
                onStatusChanged(ShoppingItemStatus.pending);
              } else {
                onStatusChanged(ShoppingItemStatus.outOfStock);
              }
            },
            child: Icon(
              status == ShoppingItemStatus.outOfStock
                  ? Icons.remove_shopping_cart
                  : Icons.remove_shopping_cart_outlined,
              size: kIconSizeMedium,
              color: StatusColors.error.withValues(
                alpha: status == ShoppingItemStatus.outOfStock ? 1.0 : 0.6,
              ),
            ),
          ),

          const SizedBox(width: kSpacingXTiny),

          // 🚫 כפתור "לא צריך"
          GestureDetector(
            onTap: () {
              unawaited(HapticFeedback.lightImpact());
              if (status == ShoppingItemStatus.notNeeded) {
                onStatusChanged(ShoppingItemStatus.pending);
              } else {
                onStatusChanged(ShoppingItemStatus.notNeeded);
              }
            },
            child: Icon(
              Icons.block,
              size: kIconSizeMedium,
              color: Colors.grey.withValues(
                alpha: status == ShoppingItemStatus.notNeeded ? 1.0 : 0.5,
              ),
            ),
          ),
        ],
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
