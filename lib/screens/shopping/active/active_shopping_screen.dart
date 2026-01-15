// 📄 File: lib/screens/shopping/active_shopping_screen.dart
//
// Version 2.0 - No AppBar (Immersive)
// Last Updated: 13/01/2026
//
// 🎯 Purpose: מסך קנייה פעילה - המשתמש בחנות וקונה מוצרים
//
// ✨ Features:
// - ⏱️ טיימר - מודד כמה זמן עובר מתחילת הקנייה
// - 📊 מונים - כמה נקנה / כמה נשאר / כמה לא היה
// - 🗂️ סידור לפי קטגוריות
// - ✅ סימון מוצרים: נקנה / לא במלאי / לא צריך
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
    debugPrint('🛒 ActiveShoppingScreen.initState: התחלה');

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

      debugPrint('🔄 _initializeScreen: מתחיל טעינה');

      // 🔐 בדיקת הרשאות - צופה לא יכול להשתתף בקנייה!
      final userId = _userContext.userId;
      if (userId != null) {
        final userRole = widget.list.getUserRole(userId);
        if (userRole != null && !userRole.canShop) {
          debugPrint('🚫 _initializeScreen: צופה לא יכול להשתתף בקנייה');
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
          debugPrint('  ✅ ${item.name}: שוחזר כ-purchased');
        } else {
          _itemStatuses[item.id] = ShoppingItemStatus.pending;
        }
      }

      final purchasedCount = _itemStatuses.values.where((s) => s == ShoppingItemStatus.purchased).length;
      debugPrint('✅ _initializeScreen: ${widget.list.items.length} פריטים, $purchasedCount כבר נקנו');

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

    debugPrint('🔄 _onUserContextChanged: שינוי אמיתי בהקשר המשתמש');
    debugPrint('   userId: $_lastUserId → $newUserId');
    debugPrint('   householdId: $_lastHouseholdId → $newHouseholdId');

    // עדכן את הערכים השמורים
    _lastUserId = newUserId;
    _lastHouseholdId = newHouseholdId;

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

    // 🔧 ביטול כל הטיימרים של debounce
    for (final timer in _saveTimers.values) {
      timer.cancel();
    }
    _saveTimers.clear();

    super.dispose();
  }

  /// עדכון סטטוס פריט + שמירה אוטומטית עם debounce
  void _updateItemStatus(UnifiedListItem item, ShoppingItemStatus newStatus) {
    debugPrint('📝 _updateItemStatus: ${item.name} → ${newStatus.name}');

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
      debugPrint('✅ _saveItemStatus: נשמר אוטומטית');

      // ✅ סנכרון הצליח - נקה שגיאה קודמת אם הייתה
      if (mounted) {
        setState(() {
          _hasSyncError = false;
          _failedSyncCount = 0;
        });
      }
    } catch (e) {
      debugPrint('❌ _saveItemStatus Auto-save Error: $e');

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
        debugPrint('⚠️ _flushPendingSaves: Failed to sync ${entry.key}: $e');
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

    debugPrint('✅ _flushPendingSaves: סיים סנכרון ${_itemStatuses.length} פריטים ($failedCount נכשלו)');
  }

  /// 🔄 ניסיון חוזר לסנכרון כל הפריטים שנכשלו
  Future<void> _retrySyncAll() async {
    debugPrint('🔄 _retrySyncAll: מנסה לסנכרן הכל...');

    final provider = context.read<ShoppingListsProvider>();
    bool anyFailed = false;

    for (final entry in _itemStatuses.entries) {
      try {
        await provider.updateItemStatus(widget.list.id, entry.key, entry.value);
      } catch (e) {
        anyFailed = true;
        debugPrint('❌ Failed to sync ${entry.key}: $e');
      }
    }

    if (mounted) {
      setState(() {
        _hasSyncError = anyFailed;
        if (!anyFailed) _failedSyncCount = 0;
      });

      if (!anyFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
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
    debugPrint('🏁 _finishShopping: מתחיל סיכום');

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
      builder: (context) => _ShoppingSummaryDialog(
        listName: widget.list.name,
        total: widget.list.items.length,
        purchased: purchased,
        outOfStock: outOfStock,
        notNeeded: notNeeded,
        pending: pending,
      ),
    );

    if (result != null && result != ShoppingSummaryResult.cancel && mounted) {
      debugPrint('✅ _finishShopping: משתמש אישר סיום עם אופציה: ${result.name}');
      await _saveAndFinish(pendingAction: result);
    } else {
      debugPrint('❌ _finishShopping: משתמש ביטל');
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
      debugPrint('💾 _saveAndFinish: מתחיל תהליך סיום קנייה (pendingAction: ${pendingAction.name})');

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
          debugPrint('🔄 מעביר ${pendingItems.length} פריטי pending + ${outOfStockItems.length} outOfStock לרשימה הבאה');
          break;

        case ShoppingSummaryResult.finishAndDeletePending:
          // ✅ סמן pending כ-notNeeded (לפני ה-flush כדי שיסונכרן!)
          itemsToTransfer.addAll(outOfStockItems);
          for (final item in pendingItems) {
            _itemStatuses[item.id] = ShoppingItemStatus.notNeeded;
          }
          debugPrint('🗑️ מסמן ${pendingItems.length} פריטי pending כ-notNeeded, מעביר ${outOfStockItems.length} outOfStock');
          break;

        case ShoppingSummaryResult.finishAndLeavePending:
          // ✅ השאר ברשימה - לא מעבירים כלום! (גם לא outOfStock)
          // הרשימה נשארת פעילה עם כל הפריטים שלא נקנו
          debugPrint('📌 משאיר ${pendingItems.length} פריטי pending + ${outOfStockItems.length} outOfStock ברשימה');
          break;

        case ShoppingSummaryResult.finishNoPending:
          // אין pending - העבר רק outOfStock (מסיימים את הרשימה)
          itemsToTransfer.addAll(outOfStockItems);
          debugPrint('🔄 מעביר ${outOfStockItems.length} outOfStock לרשימה הבאה');
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
      } else if (purchasedItems.isNotEmpty) {
        debugPrint('🔒 רשימה אישית/אירוע - דילוג על עדכון מזווה ודפוסי קנייה');
      }

      // 6️⃣ העבר פריטים לרשימה הבאה (רק אם מסיימים את הרשימה)
      if (itemsToTransfer.isNotEmpty) {
        debugPrint('🔄 מעביר ${itemsToTransfer.length} פריטים לרשימה הבאה');
        await shoppingProvider.addToNextList(itemsToTransfer);
        debugPrint('✅ פריטים הועברו לרשימה הבאה');
      }

      // 5️⃣ קבע אם הרשימה הושלמה
      // הרשימה הושלמה אם:
      // - אין pending, או
      // - המשתמש בחר להעביר/למחוק את ה-pending
      final shouldCompleteList = pendingAction != ShoppingSummaryResult.finishAndLeavePending;

      if (shouldCompleteList) {
        debugPrint('🏁 מסמן רשימה כהושלמה');
        await shoppingProvider.updateListStatus(widget.list.id, ShoppingList.statusCompleted);
        debugPrint('✅ רשימה הושלמה!');
      } else {
        debugPrint('🔄 הרשימה נשארת פעילה - ${pendingItems.length} פריטים נשארו');
      }

      // 6️⃣ צור קבלה וירטואלית מהפריטים שנקנו
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

        // 🔧 FIX: איפוס _isSaving לפני ניווט למקרה שנכשל
        setState(() => _isSaving = false);

        debugPrint('🚪 _saveAndFinish: מעבר למסך סיכום');
        unawaited(navigator.pushReplacementNamed('/shopping-summary', arguments: widget.list.id));
    } catch (e) {
      debugPrint('❌ _saveAndFinish Error: $e');

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
      return Scaffold(
        backgroundColor: kPaperBackground,
        body: SafeArea(
          child: Column(
            children: [
              // 🏷️ כותרת inline
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: cs.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Icon(Icons.shopping_cart, size: 24, color: cs.primary),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        widget.list.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _LoadingSkeletonScreen(accentColor: accent)),
            ],
          ),
        ),
      );
    }

    // ❌ Error State
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: kPaperBackground,
        body: SafeArea(
          child: Column(
            children: [
              // 🏷️ כותרת inline
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: cs.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Icon(Icons.shopping_cart, size: 24, color: cs.primary),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        widget.list.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _ErrorStateScreen(errorMessage: _errorMessage!, onRetry: _initializeScreen)),
            ],
          ),
        ),
      );
    }

    // 📭 Empty State - אם אין פריטים
    if (widget.list.items.isEmpty) {
      return Scaffold(
        backgroundColor: kPaperBackground,
        body: SafeArea(
          child: Column(
            children: [
              // 🏷️ כותרת inline
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: cs.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Icon(Icons.shopping_cart, size: 24, color: cs.primary),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        widget.list.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _EmptyStateScreen(accentColor: accent)),
            ],
          ),
        ),
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
          // 🏁 FAB - כפתור סיום קנייה
          floatingActionButton: _isSaving
              ? null
              : FloatingActionButton.large(
                  heroTag: 'active_shopping_fab',
                  onPressed: _finishShopping,
                  backgroundColor: StatusColors.success,
                  child: const Icon(Icons.check, color: Colors.white, size: 36),
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: Column(
              children: [
                // 🏷️ כותרת inline
                Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: cs.onSurface),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Icon(Icons.shopping_cart, size: 24, color: cs.primary),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Text(
                          widget.list.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                    ],
                  ),
                ),
                // 📊 Header קומפקטי - סטטיסטיקות (flat design)
                Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
                decoration: BoxDecoration(
                  color: (brand?.stickyYellow ?? kStickyYellow).withValues(alpha: kHighlightOpacity),
                  border: Border(
                    bottom: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
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
                    _buildDivider(cs.onSurfaceVariant),
                    // ❌ לא במלאי
                    if (outOfStock > 0)
                      _CompactStat(
                        icon: Icons.remove_shopping_cart,
                        value: outOfStock,
                        color: StatusColors.error,
                      ),
                    if (outOfStock > 0) _buildDivider(cs.onSurfaceVariant),
                    // 🚫 לא צריך
                    if (notNeeded > 0)
                      _CompactStat(
                        icon: Icons.block,
                        value: notNeeded,
                        color: cs.onSurfaceVariant,
                      ),
                    if (notNeeded > 0) _buildDivider(cs.onSurfaceVariant),
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
                        Text(AppStrings.shopping.legendPurchased, style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant)),
                      ],
                    ),
                    // 🛒❌ אין במלאי
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.remove_shopping_cart, color: StatusColors.error, size: 18),
                        const SizedBox(width: 4),
                        Text(AppStrings.shopping.legendOutOfStock, style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant)),
                      ],
                    ),
                    // 🚫 לא צריך
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.block, color: cs.onSurfaceVariant, size: 18),
                        const SizedBox(width: 4),
                        Text(AppStrings.shopping.legendNotNeeded, style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant)),
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
                        // ✅ RTL-aware: EdgeInsetsDirectional + BorderDirectional
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsetsDirectional.only(
                            end: kSpacingMedium,
                            top: kSpacingXTiny,
                            bottom: kSpacingXTiny,
                          ),
                          decoration: BoxDecoration(
                            color: kStickyCyan.withValues(alpha: kHighlightOpacity),
                            border: BorderDirectional(
                              end: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 4),
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
                                  borderRadius: BorderRadius.circular(12),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: kSpacingSmall),

                        // פריטים בקטגוריה
                        ...items.map<Widget>(
                          (item) => _ActiveShoppingItemTile(
                            item: item,
                            // 🔧 Fallback ל-pending אם פריט לא קיים במפה (הגנה מקריסה)
                            status: _itemStatuses[item.id] ?? ShoppingItemStatus.pending,
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

/// קו מפריד אנכי - מקבל צבע מה-Theme
Widget _buildDivider(Color color) {
  return Container(
    height: 24,
    width: 1,
    color: color.withValues(alpha: 0.3),
  );
}

// ========================================
// Widget: פריט בקנייה פעילה - שורה פשוטה על המחברת
// ========================================

class _ActiveShoppingItemTile extends StatelessWidget {
  final UnifiedListItem item;
  final ShoppingItemStatus status;
  final void Function(ShoppingItemStatus) onStatusChanged; // 🔧 Changed from Future<void>

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
        backgroundColor = cs.onSurfaceVariant.withValues(alpha: 0.2);
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
          // 🔧 FIX: אזור לחיץ גדול יותר (48x48 לפי Material guidelines)
          // ✅ נגישות: Semantics + Tooltip
          Semantics(
            button: true,
            label: AppStrings.shopping.purchasedToggleSemantics(
              item.name,
              status == ShoppingItemStatus.purchased,
            ),
            child: Tooltip(
              message: AppStrings.shopping.legendPurchased,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  unawaited(HapticFeedback.selectionClick());
                  if (status == ShoppingItemStatus.purchased) {
                    onStatusChanged(ShoppingItemStatus.pending);
                  } else {
                    onStatusChanged(ShoppingItemStatus.purchased);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
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

          // ❌ כפתור "אין במלאי"
          // 🔧 FIX: אזור לחיץ גדול יותר עם padding
          // ✅ נגישות: Semantics + Tooltip
          Semantics(
            button: true,
            label: AppStrings.shopping.outOfStockToggleSemantics(
              item.name,
              status == ShoppingItemStatus.outOfStock,
            ),
            child: Tooltip(
              message: AppStrings.shopping.legendOutOfStock,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  unawaited(HapticFeedback.lightImpact());
                  if (status == ShoppingItemStatus.outOfStock) {
                    onStatusChanged(ShoppingItemStatus.pending);
                  } else {
                    onStatusChanged(ShoppingItemStatus.outOfStock);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
              ),
            ),
          ),

          // 🚫 כפתור "לא צריך"
          // 🔧 FIX: אזור לחיץ גדול יותר עם padding
          // ✅ נגישות: Semantics + Tooltip
          Semantics(
            button: true,
            label: AppStrings.shopping.notNeededToggleSemantics(
              item.name,
              status == ShoppingItemStatus.notNeeded,
            ),
            child: Tooltip(
              message: AppStrings.shopping.legendNotNeeded,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  unawaited(HapticFeedback.lightImpact());
                  if (status == ShoppingItemStatus.notNeeded) {
                    onStatusChanged(ShoppingItemStatus.pending);
                  } else {
                    onStatusChanged(ShoppingItemStatus.notNeeded);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Icon(
                    Icons.block,
                    size: kIconSizeMedium,
                    color: cs.onSurfaceVariant.withValues(
                      alpha: status == ShoppingItemStatus.notNeeded ? 1.0 : 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/// תוצאת דיאלוג סיכום קנייה
enum ShoppingSummaryResult {
  cancel, // חזור לרשימה
  finishAndTransferPending, // סיים והעבר pending לרשימה הבאה
  finishAndLeavePending, // סיים והשאר pending ברשימה
  finishAndDeletePending, // סיים ומחק pending
  finishNoPending, // סיים (אין pending)
}

// ========================================
// Dialog: סיכום קנייה
// ========================================

class _ShoppingSummaryDialog extends StatefulWidget {
  final String listName;
  final int total;
  final int purchased;
  final int outOfStock;
  final int notNeeded;
  final int pending;

  const _ShoppingSummaryDialog({
    required this.listName,
    required this.total,
    required this.purchased,
    required this.outOfStock,
    required this.notNeeded,
    required this.pending,
  });

  @override
  State<_ShoppingSummaryDialog> createState() => _ShoppingSummaryDialogState();
}

class _ShoppingSummaryDialogState extends State<_ShoppingSummaryDialog> {
  // מצב: האם להציג את אפשרויות ה-pending
  bool _showPendingOptions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // אם יש pending ומציגים אפשרויות - הצג מסך בחירה
    if (_showPendingOptions && widget.pending > 0) {
      return _buildPendingOptionsDialog(cs);
    }

    // מסך סיכום רגיל
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
              widget.listName,
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
              value: AppStrings.shopping.summaryPurchased(widget.purchased, widget.total),
              color: StatusColors.success,
            ),

            // 🚫 לא צריך
            if (widget.notNeeded > 0)
              _SummaryRow(icon: Icons.block, label: AppStrings.shopping.activeNotNeeded, value: '${widget.notNeeded}', color: cs.onSurfaceVariant),

            // ❌ אזלו
            if (widget.outOfStock > 0)
              _SummaryRow(
                icon: Icons.remove_shopping_cart,
                label: AppStrings.shopping.summaryOutOfStock,
                value: '${widget.outOfStock}',
                color: StatusColors.error,
              ),

            // ⏸️ לא סומנו
            if (widget.pending > 0)
              _SummaryRow(
                icon: Icons.radio_button_unchecked,
                label: AppStrings.shopping.summaryNotMarked,
                value: '${widget.pending}',
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
              Navigator.pop(context, ShoppingSummaryResult.cancel);
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
              // אם יש pending - הצג אפשרויות, אחרת סיים ישר
              if (widget.pending > 0) {
                setState(() => _showPendingOptions = true);
              } else {
                Navigator.pop(context, ShoppingSummaryResult.finishNoPending);
              }
            },
            color: StatusColors.success,
            textColor: Colors.white,
            height: 44,
          ),
        ),
      ],
    );
  }

  /// דיאלוג בחירת אפשרות עבור פריטים ב-pending
  Widget _buildPendingOptionsDialog(ColorScheme cs) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.help_outline, color: StatusColors.pending, size: kIconSizeLarge),
          const SizedBox(width: kSpacingSmallPlus),
          Expanded(
            child: Text(
              AppStrings.shopping.summaryPendingQuestion(widget.pending),
              style: TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.shopping.summaryPendingSubtitle,
            style: TextStyle(fontSize: kFontSizeBody, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: kSpacingMedium),

          // ✅ אופציה 1: העבר לרשימה הבאה
          _PendingOptionTile(
            icon: Icons.arrow_forward,
            iconColor: StatusColors.info,
            title: AppStrings.shopping.summaryPendingTransfer,
            subtitle: AppStrings.shopping.summaryPendingTransferSubtitle,
            onTap: () {
              unawaited(HapticFeedback.mediumImpact());
              Navigator.pop(context, ShoppingSummaryResult.finishAndTransferPending);
            },
          ),

          const SizedBox(height: kSpacingSmall),

          // 📌 אופציה 2: השאר ברשימה
          _PendingOptionTile(
            icon: Icons.pause_circle_outline,
            iconColor: StatusColors.pending,
            title: AppStrings.shopping.summaryPendingLeave,
            subtitle: AppStrings.shopping.summaryPendingLeaveSubtitle,
            onTap: () {
              unawaited(HapticFeedback.mediumImpact());
              Navigator.pop(context, ShoppingSummaryResult.finishAndLeavePending);
            },
          ),

          const SizedBox(height: kSpacingSmall),

          // 🗑️ אופציה 3: מחק
          _PendingOptionTile(
            icon: Icons.delete_outline,
            iconColor: StatusColors.error,
            title: AppStrings.shopping.summaryPendingDelete,
            subtitle: AppStrings.shopping.summaryPendingDeleteSubtitle,
            onTap: () {
              unawaited(HapticFeedback.mediumImpact());
              Navigator.pop(context, ShoppingSummaryResult.finishAndDeletePending);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            unawaited(HapticFeedback.lightImpact());
            setState(() => _showPendingOptions = false);
          },
          child: Text(AppStrings.shopping.summaryBack),
        ),
      ],
    );
  }
}

/// כרטיס אפשרות עבור pending items
/// ✅ RTL-aware chevron + Semantics
class _PendingOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PendingOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ RTL-aware chevron: "קדימה" = שמאלה ב-RTL, ימינה ב-LTR
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final chevronIcon = isRtl ? Icons.chevron_left : Icons.chevron_right;

    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: Container(
          padding: const EdgeInsets.all(kSpacingSmall),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            border: Border.all(color: iconColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: kIconSizeMedium),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(chevronIcon, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
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
