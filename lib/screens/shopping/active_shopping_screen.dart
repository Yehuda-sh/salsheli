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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../models/enums/shopping_item_status.dart';
import '../../models/shopping_list.dart';
import '../../models/unified_list_item.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/shopping/last_chance_banner.dart';

class ActiveShoppingScreen extends StatefulWidget {
  final ShoppingList list;

  const ActiveShoppingScreen({super.key, required this.list});

  @override
  State<ActiveShoppingScreen> createState() => _ActiveShoppingScreenState();
}

class _ActiveShoppingScreenState extends State<ActiveShoppingScreen> with SingleTickerProviderStateMixin {
  // ⏱️ טיימר
  late DateTime _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // 📊 מצבי פריטים (item.id → status)
  final Map<String, ShoppingItemStatus> _itemStatuses = {};

  // 🔄 Loading/Error States
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaving = false;

  // 💫 Animation Controller
  late AnimationController _animationController;

  // 🧑 UserContext Listener
  late UserContext _userContext;

  @override
  void initState() {
    super.initState();
    debugPrint('🛒 ActiveShoppingScreen.initState: התחלה');

    // Animation Controller for micro-animations
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    // ✅ UserContext Listener - לאזור לשינויים בנתוני המשתמש
    _userContext = context.read<UserContext>();
    _userContext.addListener(_onUserContextChanged);

    _startTime = DateTime.now();
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

      // התחל טיימר שמתעדכן כל שנייה
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _elapsed = DateTime.now().difference(_startTime);
          });
        }
      });

      // אתחל את כל הפריטים כ-pending
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
          _errorMessage = 'שגיאה בטעינת הנתונים';
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
    _timer?.cancel();
    _animationController.dispose();
    _userContext.removeListener(_onUserContextChanged); // ✅ חובה!
    super.dispose();
  }

  /// עדכון סטטוס פריט עם Animation
  void _updateItemStatus(UnifiedListItem item, ShoppingItemStatus newStatus) {
    debugPrint('📝 _updateItemStatus: ${item.name} → ${newStatus.label}');

    // Animation קלה
    _animationController.forward(from: 0.0);

    setState(() {
      _itemStatuses[item.id] = newStatus;
    });
    debugPrint('✅ _updateItemStatus: עודכן בהצלחה');
  }

  /// סיום קנייה - מעבר למסך סיכום
  Future<void> _finishShopping() async {
    debugPrint('🏁 _finishShopping: מתחיל סיכום');

    final purchased = _itemStatuses.values.where((s) => s == ShoppingItemStatus.purchased).length;
    final outOfStock = _itemStatuses.values.where((s) => s == ShoppingItemStatus.outOfStock).length;
    final deferred = _itemStatuses.values.where((s) => s == ShoppingItemStatus.deferred).length;
    final notNeeded = _itemStatuses.values.where((s) => s == ShoppingItemStatus.notNeeded).length;
    final pending = _itemStatuses.values.where((s) => s == ShoppingItemStatus.pending).length;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ShoppingSummaryDialog(
        listName: widget.list.name,
        duration: _elapsed,
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
    setState(() {
      _isSaving = true;
    });

    try {
      debugPrint('💾 _saveAndFinish: מתחיל תהליך סיום קנייה');

      // 1️⃣ עדכן מלאי - רק פריטים שנקנו ✅
      final purchasedItems = widget.list.items.where((item) {
        final status = _itemStatuses[item.id];
        return status == ShoppingItemStatus.purchased;
      }).toList();

      if (purchasedItems.isNotEmpty) {
        debugPrint('📦 מעדכן מלאי: ${purchasedItems.length} פריטים');
        final inventoryProvider = context.read<InventoryProvider>();
        await inventoryProvider.updateStockAfterPurchase(purchasedItems);
        debugPrint('✅ מלאי עודכן בהצלחה');
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
        final provider = context.read<ShoppingListsProvider>();
        await provider.addToNextList(unpurchasedItems);
        debugPrint('✅ פריטים הועברו לרשימה הבאה');
      }

      // 3️⃣ סמן רשימה כהושלמה
      debugPrint('🏁 מסמן רשימה כהושלמה');
      final provider = context.read<ShoppingListsProvider>();
      await provider.updateListStatus(widget.list.id, ShoppingList.statusCompleted);
      debugPrint('✅ רשימה הושלמה!');

      if (mounted) {
        // הצג הודעת הצלחה עם פרטים
        String message = 'הקנייה הושלמה בהצלחה! 🎉';
        if (purchasedItems.isNotEmpty) {
          message += '\n📦 ${purchasedItems.length} מוצרים עודכנו במזווה';
        }
        if (unpurchasedItems.isNotEmpty) {
          message += '\n🔄 ${unpurchasedItems.length} פריטים הועברו לרשימה הבאה';
        }

        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        
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

        debugPrint('🚪 _saveAndFinish: חוזר למסך קודם');
        navigator.pop();
      }
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
                const Text('שגיאה בשמירה'),
              ],
            ),
            content: Text('לא הצלחנו לשמור את הנתונים.\nנסה שוב?', style: TextStyle(fontSize: kFontSizeBody)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.refresh),
                label: const Text('נסה שוב'),
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
      final category = product?['category'] as String? ?? 'כללי';
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.list.name,
                  style: const TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text('⏱️ ${_formatDuration(_elapsed)}', style: const TextStyle(fontSize: kFontSizeSmall)),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: _isSaving ? null : _finishShopping,
                icon: const Icon(Icons.check, color: Colors.white),
                label: Text(
                  _isSaving ? 'שומר...' : 'סיום',
                  style: TextStyle(color: _isSaving ? Colors.white.withValues(alpha: 0.5) : Colors.white),
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
                          label: 'קנוי',
                          value: '$purchased',
                          color: StatusColors.success,
                        ),
                        _StatCard(
                          icon: Icons.block,
                          label: 'לא צריך',
                          value: '$notNeeded',
                          color: Colors.grey.shade600,
                        ),
                        _StatCard(
                          icon: Icons.shopping_cart,
                          label: 'נותרו',
                          value: '${total - completed}',
                          color: StatusColors.info,
                        ),
                        _StatCard(icon: Icons.inventory_2, label: 'סה״כ', value: '$total', color: StatusColors.pending),
                      ],
                    ),
                  ),
                ),
              ),

              // ⚠️ הזדמנות אחרונה - באנר המלצות
              LastChanceBanner(listId: widget.list.id),

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
                            animationController: _animationController,
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
                        'שומר את הנתונים...',
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

  /// פורמט משך זמן (HH:MM:SS)
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

// ========================================
// Widget: Loading Skeleton Screen
// ========================================

class _LoadingSkeletonScreen extends StatefulWidget {
  final Color accentColor;

  const _LoadingSkeletonScreen({required this.accentColor});

  @override
  State<_LoadingSkeletonScreen> createState() => _LoadingSkeletonScreenState();
}

class _LoadingSkeletonScreenState extends State<_LoadingSkeletonScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

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
                colors: [widget.accentColor.withValues(alpha: 0.1), cs.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) => _ShimmerBox(width: 60, height: 80, animation: _shimmerAnimation)),
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
                        _ShimmerBox(width: 40, height: 40, animation: _shimmerAnimation, borderRadius: 20),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(child: _ShimmerBox(height: 20, animation: _shimmerAnimation)),
                        const SizedBox(width: kSpacingSmall),
                        _ShimmerBox(width: 60, height: 30, animation: _shimmerAnimation),
                      ],
                    ),
                    const SizedBox(height: kSpacingSmall),
                    Row(
                      children: [
                        Expanded(
                          child: _ShimmerBox(height: kButtonHeight, animation: _shimmerAnimation),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: _ShimmerBox(height: kButtonHeight, animation: _shimmerAnimation),
                        ),
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
// Widget: Shimmer Box
// ========================================

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Animation<double> animation;

  const _ShimmerBox({this.width, required this.height, this.borderRadius = kBorderRadius, required this.animation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surfaceContainerHighest.withValues(alpha: 0.3),
                cs.surfaceContainerHighest.withValues(alpha: 0.1),
                cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
              stops: [0.0, animation.value.clamp(0.0, 1.0), 1.0],
            ),
          ),
        );
      },
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
              'אופס! משהו השתבש',
              style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              errorMessage,
              style: TextStyle(fontSize: kFontSizeBody, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            StickyButton(label: 'נסה שוב', icon: Icons.refresh, onPressed: onRetry, color: StatusColors.info),
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
            'הרשימה ריקה',
            style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'אין פריטים לקנייה',
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
    return Column(
      children: [
        Icon(icon, color: color, size: kIconSizeLarge),
        const SizedBox(height: kSpacingTiny),
        Text(
          value,
          style: TextStyle(fontSize: kFontSizeXLarge, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: kFontSizeSmall, color: color.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

// ========================================
// Widget: פריט בקנייה פעילה - Sticky Note Style
// ========================================

class _ActiveShoppingItemTile extends StatelessWidget {
  final UnifiedListItem item;
  final ShoppingItemStatus status;
  final Function(ShoppingItemStatus) onStatusChanged;
  final AnimationController animationController;

  const _ActiveShoppingItemTile({
    required this.item,
    required this.status,
    required this.onStatusChanged,
    required this.animationController,
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

    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.0,
        end: 0.98,
      ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut)),
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
                        '${item.quantity ?? 1}×',
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: status == ShoppingItemStatus.pending
                              ? cs.onSurfaceVariant
                              : cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        realPrice > 0 ? '₪${realPrice.toStringAsFixed(2)}' : 'אין מחיר',
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

              // שורה תחתונה: 4 כפתורי פעולה
              Column(
                children: [
                  // שורה 1: קנוי + אזל
                  Row(
                  children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.check_circle,
                          label: 'קנוי',
                          color: StatusColors.success,
                          isSelected: status == ShoppingItemStatus.purchased,
                          onTap: () => onStatusChanged(ShoppingItemStatus.purchased),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.remove_shopping_cart,
                          label: 'אזל',
                          color: StatusColors.error,
                          isSelected: status == ShoppingItemStatus.outOfStock,
                          onTap: () => onStatusChanged(ShoppingItemStatus.outOfStock),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpacingSmall),
                  // שורה 2: דחה לאחר כך + לא צריך
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.schedule,
                          label: 'דחה לאחר כך',
                          color: StatusColors.warning,
                          isSelected: status == ShoppingItemStatus.deferred,
                          onTap: () => onStatusChanged(ShoppingItemStatus.deferred),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.block,
                          label: 'לא צריך',
                          color: Colors.grey.shade700,
                          isSelected: status == ShoppingItemStatus.notNeeded,
                          onTap: () => onStatusChanged(ShoppingItemStatus.notNeeded),
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
// Widget: כפתור פעולה - Sticky Button Style
// ========================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sticky Button style with proper colors
    final buttonColor = isSelected ? color : Colors.white;
    final textColor = isSelected ? Colors.white : color;

    return Transform.scale(
      scale: isSelected ? 1.02 : 1.0,
      child: StickyButton(
        label: label,
        icon: icon,
        color: buttonColor,
        textColor: textColor,
        height: 44, // Compact height
        onPressed: onTap,
      ),
    );
  }
}

// ========================================
// Dialog: סיכום קנייה
// ========================================

class _ShoppingSummaryDialog extends StatelessWidget {
  final String listName;
  final Duration duration;
  final int total;
  final int purchased;
  final int outOfStock;
  final int deferred;
  final int notNeeded;
  final int pending;

  const _ShoppingSummaryDialog({
    required this.listName,
    required this.duration,
    required this.total,
    required this.purchased,
    required this.outOfStock,
    required this.deferred,
    required this.notNeeded,
    required this.pending,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes דק\' $seconds שנ\'';
  }

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
              'סיכום קנייה',
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

            // ⏱️ זמן קנייה
            _SummaryRow(
              icon: Icons.timer,
              label: 'זמן קנייה',
              value: _formatDuration(duration),
              color: StatusColors.info,
            ),

            const Divider(height: kSpacingLarge),

            // ✅ קנוי
            _SummaryRow(
              icon: Icons.check_circle,
              label: 'קנוי',
              value: '$purchased מתוך $total',
              color: StatusColors.success,
            ),

            // 🚫 לא צריך
            if (notNeeded > 0)
              _SummaryRow(icon: Icons.block, label: 'לא צריך', value: '$notNeeded', color: Colors.grey.shade700),

            // ❌ אזלו
            if (outOfStock > 0)
              _SummaryRow(
                icon: Icons.remove_shopping_cart,
                label: 'אזלו בחנות',
                value: '$outOfStock',
                color: StatusColors.error,
              ),

            // ⏭️ נדחו
            if (deferred > 0)
              _SummaryRow(
                icon: Icons.schedule,
                label: 'נדחו לפעם הבאה',
                value: '$deferred',
                color: StatusColors.warning,
              ),

            // ⏸️ לא סומנו
            if (pending > 0)
              _SummaryRow(
                icon: Icons.radio_button_unchecked,
                label: 'לא סומנו',
                value: '$pending',
                color: StatusColors.pending,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('חזור')),
        StickyButton(
          label: 'סיים קנייה',
          icon: Icons.check,
          onPressed: () => Navigator.pop(context, true),
          color: StatusColors.success,
          textColor: Colors.white,
          height: 44,
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
