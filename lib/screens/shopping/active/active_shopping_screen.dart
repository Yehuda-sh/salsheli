// 📄 File: lib/screens/shopping/active_shopping_screen.dart
//
// Version 4.0 - Hybrid Premium: Responsive + Collaborative
// Last Updated: 22/02/2026
//
// 🎯 Purpose: מסך קנייה פעילה - המשתמש בחנות וקונה מוצרים
//
// ✨ Features:
// - ⏱️ טיימר - מודד כמה זמן עובר מתחילת הקנייה
// - 📊 מונים - כמה נקנה / כמה נשאר / כמה לא היה
// - 🗂️ סידור לפי קטגוריות + מיון דינמי (checked → bottom)
// - ✅ סימון מוצרים: נקנה / לא במלאי / לא צריך
// - 📱 כפתורי פעולה מהירה
// - 🏁 סיכום מפורט בסיום
// - 🎨 Skeleton Screen & Error Handling
// - 💫 Micro Animations (flutter_animate fadeIn/slideX)
// - 📝 Sticky Notes Design System
// - 🧊 Glassmorphic stats header (BackdropFilter)
// - 👥 Collaborative AppBar with active shopper avatars
// - ⚡ RepaintBoundary per item row
//
// 🎨 UI:
// - Header עם טיימר וסטטיסטיקות (glassmorphic)
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
import 'dart:ui';

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
import '../../home/dashboard/widgets/last_chance_banner.dart';
import 'widgets/active_shopping_item_tile.dart';
import 'widgets/active_shopping_states.dart';
import 'widgets/shopping_summary_dialog.dart';

class ActiveShoppingScreen extends StatefulWidget {
  final ShoppingList list;
  final bool readOnly;

  const ActiveShoppingScreen({super.key, required this.list, this.readOnly = false});

  @override
  State<ActiveShoppingScreen> createState() => _ActiveShoppingScreenState();
}

class _ActiveShoppingScreenState extends State<ActiveShoppingScreen> {
  // 📊 מצבי פריטים (item.id → status)
  final Map<String, ShoppingItemStatus> _itemStatuses = {};

  // 🗂️ קטגוריות מקופלות
  final Set<String> _collapsedCategories = {};

  // 🔄 Loading/Error States
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaving = false;

  // 🔄 Sync status - מצב סנכרון עם השרת
  bool _hasSyncError = false;
  int _failedSyncCount = 0; // 🔧 ספירת כשלונות סנכרון רצופים

  // 🧑 UserContext Listener
  late UserContext _userContext;
  bool _listenerAdded = false; // 🔧 עוקב אחרי הוספת listener
  String? _lastUserId; // 🔧 שמירת userId אחרון לזיהוי שינוי אמיתי
  String? _lastHouseholdId; // 🔧 שמירת householdId אחרון

  // ⏱️ Debounce למניעת הצפת שמירות
  final Map<String, Timer> _saveTimers = {}; // item.id → Timer
  static const Duration _saveDebounce = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    // ✅ UserContext Listener - לאזור לשינויים בנתוני המשתמש
    _userContext = context.read<UserContext>();

    // 🔧 שמירת ערכים התחלתיים לזיהוי שינויים אמיתיים
    _lastUserId = _userContext.userId;
    _lastHouseholdId = _userContext.householdId;

    _userContext.addListener(_onUserContextChanged);
    _listenerAdded = true; // 🔧 מסמן שהוספנו listener

    // ⚠️ עטיפה ב-microtask למניעת setState במהלך build
    Future.microtask(_initializeScreen);
  }

  /// אתחול המסך - טעינת נתונים
  Future<void> _initializeScreen() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });


      // 🔐 בדיקת הרשאות - צופה לא יכול להשתתף בקנייה!
      final userId = _userContext.userId;
      if (userId != null) {
        final userRole = widget.list.getUserRole(userId);
        if (userRole != null && !userRole.canShop) {
          if (mounted) {
            // הצג הודעה וחזור למסך הקודם
            final brand = Theme.of(context).extension<AppBrand>();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.shopping.viewerCannotShop),
                backgroundColor: brand?.warning ?? StatusColors.pending,
              ),
            );
            Navigator.of(context).pop();
          }
          return;
        }
      }

      // 🔧 ניקוי מפה קודמת למניעת "זבל" מפריטים ישנים
      _itemStatuses.clear();

      // 🔧 שחזור סטטוס קיים מהמודל
      // הערה: המודל תומך רק ב-isChecked (בוליאני), לכן:
      // - isChecked=true → purchased
      // - isChecked=false → pending
      // ⚠️ סטטוסים כמו outOfStock/notNeeded לא נשמרים כרגע במודל
      for (final item in widget.list.items) {
        if (item.isChecked) {
          _itemStatuses[item.id] = ShoppingItemStatus.purchased;
        } else {
          _itemStatuses[item.id] = ShoppingItemStatus.pending;
        }
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppStrings.shopping.loadingDataError;
        });
      }
    }
  }

  /// 🔄 בעת שינוי household_id או משתמש
  /// 🔧 FIX: רק אם השתנה userId או householdId - לא בכל שינוי!
  /// זה מונע איבוד סטטוסים (outOfStock/notNeeded) באמצע קנייה
  void _onUserContextChanged() {
    final newUserId = _userContext.userId;
    final newHouseholdId = _userContext.householdId;

    // ✅ בדוק אם באמת השתנה משהו רלוונטי
    if (newUserId == _lastUserId && newHouseholdId == _lastHouseholdId) {
      // אין שינוי אמיתי - התעלם (למשל: שינוי שם, אווטר וכו')
      return;
    }


    // עדכן את הערכים השמורים
    _lastUserId = newUserId;
    _lastHouseholdId = newHouseholdId;

    if (mounted) {
      _initializeScreen();
    }
  }

  @override
  void dispose() {

    // ✅ ניקוי listener - רק אם הוסף
    if (_listenerAdded) {
      _userContext.removeListener(_onUserContextChanged);
    }

    // 🔧 ביטול כל הטיימרים של debounce
    for (final timer in _saveTimers.values) {
      timer.cancel();
    }
    _saveTimers.clear();

    super.dispose();
  }

  /// עדכון סטטוס פריט + שמירה אוטומטית עם debounce
  /// 🔢 עדכון כמות פריט
  void _updateItemQuantity(UnifiedListItem item, int newQuantity) {

    final provider = context.read<ShoppingListsProvider>();
    // quantity נמצא בתוך productData
    final updatedProductData = Map<String, dynamic>.from(item.productData ?? {});
    updatedProductData['quantity'] = newQuantity;
    final updatedItem = item.copyWith(productData: updatedProductData);
    provider.updateItemById(widget.list.id, updatedItem);
  }

  void _updateItemStatus(UnifiedListItem item, ShoppingItemStatus newStatus) {

    // 🔄 עדכון מיידי ב-UI (optimistic update)
    setState(() {
      _itemStatuses[item.id] = newStatus;
    });

    // ⏱️ Debounce: בטל טיימר קודם אם קיים
    _saveTimers[item.id]?.cancel();

    // 💾 תזמן שמירה אחרי debounce
    _saveTimers[item.id] = Timer(_saveDebounce, () {
      _saveItemStatus(item.id, newStatus);
    });
  }

  /// 💾 שמירת סטטוס פריט ל-Firebase (נקרא אחרי debounce)
  Future<void> _saveItemStatus(String itemId, ShoppingItemStatus status) async {
    try {
      final provider = context.read<ShoppingListsProvider>();
      await provider.updateItemStatus(widget.list.id, itemId, status);

      // ✅ סנכרון הצליח - נקה שגיאה קודמת אם הייתה
      if (mounted) {
        setState(() {
          _hasSyncError = false;
          _failedSyncCount = 0;
        });
      }
    } catch (e) {

      // ⚠️ הצג אינדיקציה למשתמש שיש בעיית סנכרון
      if (mounted) {
        setState(() {
          _failedSyncCount++;
          _hasSyncError = true;
        });
      }
    }
  }

  /// 🔧 בטל את כל טיימרי ה-debounce
  void _cancelAllSaveTimers() {
    for (final timer in _saveTimers.values) {
      timer.cancel();
    }
    _saveTimers.clear();
  }

  /// 🔧 Flush: שמור מיידית את כל הסטטוסים הממתינים
  /// נקרא לפני סיום קנייה כדי להבטיח שהכל מסונכרן
  ///
  /// [provider] - ה-provider לשימוש (נשמר לפני await כדי להימנע מ-context across async gap)
  Future<void> _flushPendingSaves(ShoppingListsProvider provider) async {
    if (!mounted) return;

    int failedCount = 0;

    // סנכרון כל הסטטוסים לשרת
    for (final entry in _itemStatuses.entries) {
      try {
        await provider.updateItemStatus(widget.list.id, entry.key, entry.value);
      } catch (e) {
        failedCount++;
        // ממשיך למרות שגיאה - כדי לסנכרן כמה שיותר
      }
    }

    // ✅ עדכן מצב שגיאה אם היו כישלונות
    if (mounted && failedCount > 0) {
      setState(() {
        _hasSyncError = true;
        _failedSyncCount = failedCount;
      });
    }

  }

  /// 🔄 ניסיון חוזר לסנכרון כל הפריטים שנכשלו
  Future<void> _retrySyncAll() async {
    final cs = Theme.of(context).colorScheme;

    // ✅ Cache before async
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<ShoppingListsProvider>();
    bool anyFailed = false;

    for (final entry in _itemStatuses.entries) {
      try {
        await provider.updateItemStatus(widget.list.id, entry.key, entry.value);
      } catch (e) {
        anyFailed = true;
      }
    }

    if (mounted) {
      setState(() {
        _hasSyncError = anyFailed;
        if (!anyFailed) _failedSyncCount = 0;
      });

      if (!anyFailed) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: cs.onPrimary, size: 20),
                const SizedBox(width: kSpacingSmall),
                Text(AppStrings.shopping.syncSuccess),
              ],
            ),
            backgroundColor: StatusColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// סיום קנייה - מעבר למסך סיכום
  Future<void> _finishShopping() async {

    // ✨ Haptic feedback למשוב מישוש
    unawaited(HapticFeedback.mediumImpact());

    // 🔧 ספור לפי widget.list.items כדי לכלול גם פריטים שלא במפה (null = pending)
    final purchased = widget.list.items.where((item) =>
        _itemStatuses[item.id] == ShoppingItemStatus.purchased).length;
    final outOfStock = widget.list.items.where((item) =>
        _itemStatuses[item.id] == ShoppingItemStatus.outOfStock).length;
    final notNeeded = widget.list.items.where((item) =>
        _itemStatuses[item.id] == ShoppingItemStatus.notNeeded).length;
    // pending כולל גם פריטים שלא במפה (null)
    final pending = widget.list.items.where((item) {
      final status = _itemStatuses[item.id];
      return status == null || status == ShoppingItemStatus.pending;
    }).length;

    final result = await showDialog<ShoppingSummaryResult>(
      context: context,
      // ✅ Issue #4: מניעת סגירה בלחיצה מחוץ לדיאלוג
      barrierDismissible: false,
      builder: (context) => ShoppingSummaryDialog(
        listName: widget.list.name,
        total: widget.list.items.length,
        purchased: purchased,
        outOfStock: outOfStock,
        notNeeded: notNeeded,
        pending: pending,
      ),
    );

    if (result != null && result != ShoppingSummaryResult.cancel && mounted) {
      await _saveAndFinish(pendingAction: result);
    } else {
    }
  }

  /// שמירה וסיום - עם עדכון מלאי אוטומטי
  ///
  /// [pendingAction] - מה לעשות עם פריטים ב-pending:
  /// - finishAndTransferPending: העבר לרשימה הבאה
  /// - finishAndLeavePending: השאר ברשימה (הרשימה תישאר פעילה)
  /// - finishAndDeletePending: מחק (סמן כ-notNeeded)
  /// - finishNoPending: אין פריטים ב-pending
  Future<void> _saveAndFinish({
    ShoppingSummaryResult pendingAction = ShoppingSummaryResult.finishNoPending,
  }) async {
    final cs = Theme.of(context).colorScheme;
    // ✅ תפוס context לפני await
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // 🔧 מנקה SnackBar קודם אם קיים (מונע duplicates)
    messenger.clearSnackBars();

    // 🔧 שמור providers לפני כל await
    final inventoryProvider = context.read<InventoryProvider>();
    final shoppingProvider = context.read<ShoppingListsProvider>();
    final receiptProvider = context.read<ReceiptProvider>();

    setState(() {
      _isSaving = true;
    });

    try {

      // 1️⃣ בטל טיימרים כדי למנוע writes נוספים
      _cancelAllSaveTimers();

      // 2️⃣ זהה פריטים לפי סטטוס נוכחי
      final purchasedItems = widget.list.items.where((item) {
        final status = _itemStatuses[item.id];
        return status == ShoppingItemStatus.purchased;
      }).toList();

      final outOfStockItems = widget.list.items.where((item) {
        final status = _itemStatuses[item.id];
        return status == ShoppingItemStatus.outOfStock;
      }).toList();

      final pendingItems = widget.list.items.where((item) {
        final status = _itemStatuses[item.id];
        return status == null || status == ShoppingItemStatus.pending;
      }).toList();

      // ✅ רשימת פריטים שיועברו לרשימה הבאה - ריקה בהתחלה
      final List<UnifiedListItem> itemsToTransfer = [];

      // 3️⃣ טפל ב-pending לפי בחירת המשתמש (לפני ה-flush!)
      switch (pendingAction) {
        case ShoppingSummaryResult.finishAndTransferPending:
          // העבר pending + outOfStock לרשימה הבאה (מסיימים את הרשימה)
          itemsToTransfer.addAll(outOfStockItems);
          itemsToTransfer.addAll(pendingItems);
          break;

        case ShoppingSummaryResult.finishAndDeletePending:
          // ✅ סמן pending כ-notNeeded (לפני ה-flush כדי שיסונכרן!)
          itemsToTransfer.addAll(outOfStockItems);
          for (final item in pendingItems) {
            _itemStatuses[item.id] = ShoppingItemStatus.notNeeded;
          }
          break;

        case ShoppingSummaryResult.finishAndLeavePending:
          // ✅ השאר ברשימה - לא מעבירים כלום! (גם לא outOfStock)
          // הרשימה נשארת פעילה עם כל הפריטים שלא נקנו
          break;

        case ShoppingSummaryResult.finishNoPending:
          // אין pending - העבר רק outOfStock (מסיימים את הרשימה)
          itemsToTransfer.addAll(outOfStockItems);
          break;

        case ShoppingSummaryResult.cancel:
          // ביטול - לא עושים כלום
          break;
      }

      // 4️⃣ Flush: סנכרן את כל הסטטוסים (כולל השינויים מלמעלה!)
      await _flushPendingSaves(shoppingProvider);

      // 5️⃣ עדכן מזווה ודפוסים - רק לרשימות משותפות (לא אירועים ולא אישיות)
      if (purchasedItems.isNotEmpty &&
          ShoppingList.shouldUpdatePantry(widget.list.type, isPrivate: widget.list.isPrivate)) {
        await inventoryProvider.updateStockAfterPurchase(purchasedItems);

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
        } catch (e) {
        }
      } else if (purchasedItems.isNotEmpty) {
      }

      // 6️⃣ העבר פריטים לרשימה הבאה (רק אם מסיימים את הרשימה)
      if (itemsToTransfer.isNotEmpty) {
        await shoppingProvider.addToNextList(itemsToTransfer);
      }

      // 5️⃣ קבע אם הרשימה הושלמה
      // הרשימה הושלמה אם:
      // - אין pending, או
      // - המשתמש בחר להעביר/למחוק את ה-pending
      final shouldCompleteList = pendingAction != ShoppingSummaryResult.finishAndLeavePending;

      if (shouldCompleteList) {
        await shoppingProvider.updateListStatus(widget.list.id, ShoppingList.statusCompleted);
      } else {
      }

      // 6️⃣ צור קבלה וירטואלית מהפריטים שנקנו
      if (purchasedItems.isNotEmpty) {
        try {
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
        } catch (e) {
        }
      }

      // ✅ בדוק אם עדיין mounted לפני שימוש ב-context
      if (!mounted) return;

      // הצג הודעת הצלחה עם פרטים
      String message = shouldCompleteList
          ? AppStrings.shopping.shoppingCompletedSuccess
          : AppStrings.shopping.shoppingSaved;

      if (purchasedItems.isNotEmpty) {
        message += '\n${AppStrings.shopping.pantryUpdated(purchasedItems.length)}';
      }
      if (itemsToTransfer.isNotEmpty) {
        message += '\n${AppStrings.shopping.itemsMovedToNext(itemsToTransfer.length)}';
      }
      if (!shouldCompleteList && pendingItems.isNotEmpty) {
        message += '\n${AppStrings.shopping.pendingItemsLeftWarning(pendingItems.length)}';
      }

        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: cs.onPrimary),
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

        // 🔧 FIX: איפוס _isSaving לפני ניווט למקרה שנכשל
        setState(() => _isSaving = false);

        unawaited(navigator.pushReplacementNamed('/shopping-summary', arguments: widget.list.id));
    } catch (e) {

      if (mounted) {
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
          await _saveAndFinish(pendingAction: pendingAction); // Retry with same action
        }
      }
    } finally {
      // 🔧 FIX: תמיד איפוס _isSaving בסיום (finally)
      if (mounted && _isSaving) {
        setState(() => _isSaving = false);
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
      return Stack(
        children: [
          NotebookBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart, size: 24, color: cs.primary),
                  const SizedBox(width: kSpacingSmall),
                  Flexible(
                    child: Text(
                      widget.list.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: ActiveShoppingLoadingSkeleton(accentColor: accent),
          ),
        ],
      );
    }

    // ❌ Error State
    if (_errorMessage != null) {
      return Stack(
        children: [
          NotebookBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart, size: 24, color: cs.primary),
                  const SizedBox(width: kSpacingSmall),
                  Flexible(
                    child: Text(
                      widget.list.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: ActiveShoppingErrorState(errorMessage: _errorMessage!, onRetry: _initializeScreen),
          ),
        ],
      );
    }

    // 📭 Empty State - אם אין פריטים
    if (widget.list.items.isEmpty) {
      return Stack(
        children: [
          NotebookBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart, size: 24, color: cs.primary),
                  const SizedBox(width: kSpacingSmall),
                  Flexible(
                    child: Text(
                      widget.list.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: ActiveShoppingEmptyState(accentColor: accent),
          ),
        ],
      );
    }

    // חשב סטטיסטיקות
    // 🔧 ספור לפי widget.list.items כדי לכלול גם פריטים שלא במפה (null = pending)
    final purchased = widget.list.items.where((item) =>
        _itemStatuses[item.id] == ShoppingItemStatus.purchased).length;
    final notNeeded = widget.list.items.where((item) =>
        _itemStatuses[item.id] == ShoppingItemStatus.notNeeded).length;
    final outOfStock = widget.list.items.where((item) =>
        _itemStatuses[item.id] == ShoppingItemStatus.outOfStock).length;
    // 🔧 outOfStock נחשב כ"טופל" - המשתמש טיפל בפריט (סימן שאין במלאי)
    final completed = purchased + notNeeded + outOfStock;
    final total = widget.list.items.length;


    // קבץ לפי קטגוריה
    final productsProvider = context.watch<ProductsProvider>();
    final itemsByCategory = <String, List<UnifiedListItem>>{};
    for (final item in widget.list.items) {
      final category = item.category
          ?? (productsProvider.getByName(item.name)?['category'] as String?)
          ?? AppStrings.shopping.categoryGeneral;
      itemsByCategory.putIfAbsent(category, () => []).add(item);
    }

    // 🔄 מיון דינמי: מבוטל — פריטים נשארים במיקום המקורי
    // (מיון לתחתית מבלבל בזמן קנייה פעילה)

    return Stack(
      children: [
        // 📓 Sticky Notes Background
        const NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          // 🏁 FAB הוסר — כפתור סיום עבר ל-AppBar leading
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart, size: 24, color: cs.primary),
                    const SizedBox(width: kSpacingSmall),
                    Flexible(
                      child: Text(
                        widget.list.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // 👥 קונים פעילים - אווטרים עם הילה פועמת
                if (widget.list.currentShoppers.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...widget.list.currentShoppers.take(4).map((shopper) {
                          final name = widget.list.sharedUsers[shopper.userId]?.userName;
                          final initial = (name != null && name.isNotEmpty)
                              ? name.characters.first
                              : '?';
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ShopperAvatar(
                              initial: initial,
                              isStarter: shopper.isStarter,
                              accentColor: accent,
                            ),
                          );
                        }),
                        if (widget.list.currentShoppers.length > 4)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              '+${widget.list.currentShoppers.length - 4}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: kFontSizeSmall,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            centerTitle: true,
            actions: [
              // ⚠️ אינדיקציה לבעיית סנכרון - לחיץ לניסיון חוזר
              if (_hasSyncError)
                IconButton(
                  onPressed: _retrySyncAll,
                  tooltip: AppStrings.shopping.syncErrorTooltip,
                  icon: Badge(
                    label: Text('$_failedSyncCount'),
                    isLabelVisible: _failedSyncCount > 1,
                    backgroundColor: StatusColors.error,
                    child: const Icon(
                      Icons.cloud_off,
                      size: 22,
                    ),
                  ),
                ),
              // 🏁 כפתור סיום קנייה — מלבן מעוגל קטן
              if (!_isSaving)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: TextButton.icon(
                    onPressed: _finishShopping,
                    style: TextButton.styleFrom(
                      backgroundColor: StatusColors.success.withValues(alpha: 0.15),
                      foregroundColor: StatusColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('סיימתי', style: TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 📊 Header קומפקטי — פס התקדמות + סטטיסטיקות
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXTiny),
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingTiny),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // פס התקדמות דק עם צבעים לפי סטטוס
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                        child: SizedBox(
                          height: 6,
                          child: Row(
                            children: [
                              if (purchased > 0)
                                Expanded(
                                  flex: purchased,
                                  child: Container(color: StatusColors.success),
                                ),
                              if (outOfStock > 0)
                                Expanded(
                                  flex: outOfStock,
                                  child: Container(color: StatusColors.error.withValues(alpha: 0.7)),
                                ),
                              if (notNeeded > 0)
                                Expanded(
                                  flex: notNeeded,
                                  child: Container(color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                                ),
                              if (total - completed > 0)
                                Expanded(
                                  flex: total - completed,
                                  child: Container(color: cs.outline.withValues(alpha: 0.15)),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      // סטטיסטיקות + מקרא בשורה אחת קומפקטית
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: StatusColors.success, size: 14),
                          SizedBox(width: 2),
                          Text('$purchased/$total', style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)),
                          if (outOfStock > 0) ...[
                            SizedBox(width: 10),
                            Icon(Icons.remove_shopping_cart, color: StatusColors.error, size: 14),
                            SizedBox(width: 2),
                            Text('$outOfStock', style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant)),
                          ],
                          if (notNeeded > 0) ...[
                            SizedBox(width: 10),
                            Icon(Icons.block, color: cs.onSurfaceVariant, size: 14),
                            SizedBox(width: 2),
                            Text('$notNeeded', style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant)),
                          ],
                          SizedBox(width: 10),
                          Icon(Icons.shopping_cart, color: cs.primary, size: 14),
                          SizedBox(width: 2),
                          Text('${total - completed}', style: TextStyle(fontSize: kFontSizeSmall, color: cs.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: kSpacingXTiny),

              // ⚠️ הזדמנות אחרונה - באנר המלצות
              LastChanceBanner(activeListId: widget.list.id),

              // 🗂️ רשימת מוצרים לפי קטגוריות
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                  itemCount: itemsByCategory.length,
                  itemBuilder: (context, index) {
                    final category = itemsByCategory.keys.elementAt(index);
                    final items = itemsByCategory[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📌 כותרת קטגוריה - Highlighter style + קיפול
                        // ✅ RTL-aware: EdgeInsetsDirectional + BorderDirectional
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_collapsedCategories.contains(category)) {
                                _collapsedCategories.remove(category);
                              } else {
                                _collapsedCategories.add(category);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                            padding: const EdgeInsets.symmetric(
                              horizontal: kSpacingSmall,
                              vertical: kSpacingXTiny,
                            ),
                            decoration: BoxDecoration(
                              color: kStickyCyan.withValues(alpha: kHighlightOpacity),
                              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  getCategoryEmoji(hebrewCategoryToEnglish(category) ?? 'other'),
                                  style: TextStyle(fontSize: kFontSizeLarge),
                                ),
                                SizedBox(width: kSpacingSmall),
                                Expanded(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: kFontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurface,
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
                                    color: cs.onSurface.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(kBorderRadius),
                                  ),
                                  child: Text(
                                    '${items.length}',
                                    style: TextStyle(
                                      fontSize: kFontSizeSmall,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                SizedBox(width: kSpacingXTiny),
                                // ▼/▲ חץ קיפול
                                AnimatedRotation(
                                  turns: _collapsedCategories.contains(category) ? 0.5 : 0.0,
                                  duration: kAnimationDurationShort,
                                  child: Icon(
                                    Icons.expand_more,
                                    size: 24,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: kSpacingSmall),

                        // פריטים בקטגוריה (מוסתרים כשמקופל)
                        if (!_collapsedCategories.contains(category))
                          ...items.map<Widget>(
                            (item) => ActiveShoppingItemTile(
                              item: item,
                              // 🔧 Fallback ל-pending אם פריט לא קיים במפה (הגנה מקריסה)
                              status: _itemStatuses[item.id] ?? ShoppingItemStatus.pending,
                              onStatusChanged: (newStatus) => _updateItemStatus(item, newStatus),
                              onQuantityChanged: (newQty) => _updateItemQuantity(item, newQty),
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
        ),

        // 💾 Saving Overlay
        if (_isSaving)
          Container(
            color: cs.scrim.withValues(alpha: 0.5),
            child: Center(
              child: Card(
                color: brand?.stickyYellow ?? kStickyYellow,
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

