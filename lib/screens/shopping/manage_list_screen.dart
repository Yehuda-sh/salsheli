// 📄 File: lib/screens/shopping/manage_list_screen.dart
//
// 🎯 Purpose: מסך ניהול רשימת קניות - עריכת פריטים, מחיקה, סימון
//
// ✨ Features:
// - 📊 סטטיסטיקות: פריטים, סה"כ, כמות
// - ➕ הוספת פריטים ידנית (שם, כמות, מחיר)
// - ✏️ עריכת פריטים: סימון/ביטול סימון
// - 🗑️ מחיקה עם אישור (Dismissible + Dialog)
// - 🎯 ניווט לקנייה פעילה
// - 📱 3 Empty States: Loading/Error/Empty
// - 💀 Skeleton Screens: loading מודרני
// - ✨ Micro Animations: UI חי ומגיב
//
// 📦 Dependencies:
// - ShoppingListsProvider: CRUD על רשימות
// - ShoppingList model: מבנה הרשימה
// - ReceiptItem model: מבנה פריט
//
// 🎨 UI:
// - Header: סטטיסטיקות בכרטיס כחול
// - ListView: רשימת פריטים עם Dismissible + Animations
// - FAB: הוספת פריט חדש עם Animation
// - Empty State: אייקון + טקסט מעוצב
// - Error State: retry button
// - Loading State: Skeleton Screen במקום spinner
//
// 📝 Usage:
// ```dart
// Navigator.pushNamed(
//   context,
//   '/manage-list',
//   arguments: {
//     'list': myShoppingList,
//   },
// );
// ```
//
// 🔗 Related:
// - active_shopping_screen.dart - מסך קנייה פעילה
// - shopping_lists_screen.dart - רשימת כל הרשימות
// - populate_list_screen.dart - מילוי רשימה ממקורות
//
// Version: 3.0 - Modern UI/UX (Skeleton + Animations)
// Last Updated: 14/10/2025
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';

// Widgets - Sticky Notes Design
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/notebook_background.dart';

// Animation constants
const Duration _kItemAnimationBaseDuration = Duration(milliseconds: 300);
const Duration _kItemAnimationStaggerDelay = Duration(milliseconds: 50);

class ManageListScreen extends StatefulWidget {
  final String listName;
  final String listId;

  const ManageListScreen({
    super.key,
    required this.listName,
    required this.listId,
  });

  @override
  State<ManageListScreen> createState() => _ManageListScreenState();
}

class _ManageListScreenState extends State<ManageListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    debugPrint('📋 ManageListScreen.initState() | listId: ${widget.listId}');
    
    // FAB Animation Controller
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    debugPrint('🗑️ ManageListScreen.dispose()');
    _fabController.dispose();
    super.dispose();
  }

  /// דיאלוג הוספת פריט ידני
  Future<void> _showAddCustomItemDialog(ShoppingListsProvider provider) async {
    debugPrint('➕ _showAddCustomItemDialog()');
    
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: '0');

    // Cleanup function
    void disposeControllers() {
      nameController.dispose();
      qtyController.dispose();
      priceController.dispose();
    }

    // שמירת messenger לפני async
    final messenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            child: StickyNote(
              color: kStickyYellow,
              rotation: -0.015,
              child: Padding(
                padding: EdgeInsets.all(kSpacingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_shopping_cart, color: Colors.green.shade700),
                        const SizedBox(width: kSpacingSmall),
                        const Text(
                          'הוסף פריט חדש',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingMedium),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StickyNote(
                          color: kStickyCyan,
                          rotation: 0.01,
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'שם המוצר',
                              border: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: kSpacingSmall),
                        Row(
                          children: [
                            Expanded(
                              child: StickyNote(
                                color: kStickyGreen,
                                rotation: -0.008,
                                child: TextField(
                                  controller: qtyController,
                                  decoration: const InputDecoration(
                                    labelText: 'כמות',
                                    border: InputBorder.none,
                                    filled: false,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                            const SizedBox(width: kSpacingSmall),
                            Expanded(
                              child: StickyNote(
                                color: kStickyPink,
                                rotation: 0.008,
                                child: TextField(
                                  controller: priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'מחיר',
                                    border: InputBorder.none,
                                    filled: false,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpacingLarge),
                        Row(
                          children: [
                            Expanded(
                              child: StickyButton(
                                label: 'ביטול',
                                icon: Icons.close,
                                color: Colors.white,
                                textColor: Colors.red.shade700,
                                onPressed: () {
                                  debugPrint('❌ ביטול הוספת פריט');
                                  disposeControllers();
                                  Navigator.pop(ctx);
                                },
                              ),
                            ),
                            const SizedBox(width: kSpacingSmall),
                            Expanded(
                              child: StickyButton(
                                label: 'הוסף',
                                icon: Icons.add,
                                color: Colors.green.shade400,
                                onPressed: () async {
                  final name = nameController.text.trim();
                  
                  // Validation
                  if (name.isEmpty) {
                    debugPrint('⚠️ שם פריט ריק');
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ נא להזין שם מוצר'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final qty = int.tryParse(qtyController.text.trim()) ?? 1;
                  if (qty <= 0) {
                    debugPrint('⚠️ כמות לא תקינה: $qty');
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ כמות חייבת להיות גדולה מ-0'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                  if (price < 0) {
                    debugPrint('⚠️ מחיר שלילי: $price');
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ מחיר לא יכול להיות שלילי'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  debugPrint('➕ מוסיף פריט: "$name" x$qty = ₪$price');

                  final newItem = ReceiptItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    quantity: qty,
                    unitPrice: price,
                    isChecked: false,
                  );

                  try {
                    await provider.addItemToList(
                      widget.listId, 
                      newItem.name ?? 'מוצר ללא שם', 
                      newItem.quantity, 
                      newItem.unit ?? "יח'"
                    );
                    debugPrint('✅ פריט "$name" נוסף בהצלחה');

                    disposeControllers();
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: kSpacingSmall),
                              Text('✅ $name נוסף לרשימה'),
                            ],
                          ),
                          duration: kSnackBarDuration,
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('❌ שגיאה בהוספת פריט: $e');
                    disposeControllers();
                    if (ctx.mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: kSpacingSmall),
                              Text('❌ שגיאה: ${e.toString()}'),
                            ],
                          ),
                          duration: kSnackBarDurationLong,
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
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
          ),
        );
      },
    ).whenComplete(() {
      // Cleanup if dialog was closed without pressing buttons
      disposeControllers();
    });
  }

  /// מחיקת פריט עם אישור
  Future<void> _deleteItem(
    BuildContext context,
    ShoppingListsProvider provider,
    int index,
    ReceiptItem item,
  ) async {
    debugPrint('🗑️ _deleteItem() | index: $index, item: ${item.name}');

    // שמירת messenger לפני async
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.removeItemFromList(widget.listId, index);
      debugPrint('✅ פריט "${item.name}" נמחק');

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white),
                const SizedBox(width: kSpacingSmall),
                Text('"${item.name ?? 'ללא שם'}" הוסר'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: kSnackBarDuration,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ שגיאה במחיקת פריט: $e');
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: kSpacingSmall),
                Text('❌ שגיאה: ${e.toString()}'),
              ],
            ),
            duration: kSnackBarDurationLong,
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// סימון/ביטול סימון פריט
  Future<void> _toggleItem(
    ShoppingListsProvider provider,
    int index,
    ReceiptItem item,
  ) async {
    debugPrint('✔️ _toggleItem() | index: $index, current: ${item.isChecked}');

    try {
      await provider.updateItemAt(
        widget.listId,
        index,
        (currentItem) => currentItem.copyWith(
          isChecked: !currentItem.isChecked,
        ),
      );
      debugPrint('✅ פריט "${item.name}" עודכן');
    } catch (e) {
      debugPrint('❌ שגיאה בעדכון פריט: $e');
      if (!mounted) return;
      
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: kSpacingSmall),
              Text('❌ שגיאה: ${e.toString()}'),
            ],
          ),
          duration: kSnackBarDuration,
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 💀 Skeleton Box - קופסה מהבהבת בסיסית
  Widget _buildSkeletonBox({
    required double width,
    required double height,
    BorderRadius? borderRadius,
    required ColorScheme cs,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest.withValues(alpha: 0.3),
            cs.surfaceContainerHighest.withValues(alpha: 0.1),
            cs.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(kBorderRadiusSmall),
      ),
    );
  }

  /// 💀 Skeleton של פריט בודד ברשימה
  Widget _buildItemSkeleton(ColorScheme cs) {
    return Card(
      margin: EdgeInsets.only(bottom: kSpacingSmall),
      child: Padding(
        padding: EdgeInsets.all(kSpacingMedium),
        child: Row(
          children: [
            // Checkbox skeleton
            _buildSkeletonBox(
              width: 24,
              height: 24,
              borderRadius: BorderRadius.circular(4),
              cs: cs,
            ),
            SizedBox(width: kSpacingMedium),
            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // שם המוצר
                  _buildSkeletonBox(
                    width: double.infinity,
                    height: 16,
                    cs: cs,
                  ),
                  const SizedBox(height: kSpacingSmall),
                  // פרטי מחיר
                  _buildSkeletonBox(
                    width: 120,
                    height: 12,
                    cs: cs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💀 Skeleton של סטטיסטיקות Header
  Widget _buildStatsSkeleton(ColorScheme cs) {
    return Container(
      padding: EdgeInsets.all(kSpacingMedium),
      margin: EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < 3; i++)
            Column(
              children: [
                _buildSkeletonBox(
                  width: 32,
                  height: 32,
                  borderRadius: BorderRadius.circular(16),
                  cs: cs,
                ),
                const SizedBox(height: kSpacingTiny),
                _buildSkeletonBox(
                  width: 50,
                  height: 20,
                  cs: cs,
                ),
                const SizedBox(height: kSpacingTiny),
                _buildSkeletonBox(
                  width: 40,
                  height: 14,
                  cs: cs,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Loading State - עם Skeleton Screen
  Widget _buildLoading(ColorScheme cs) {
    debugPrint('⏳ _buildLoading()');
    return Scaffold(
      backgroundColor: kPaperBackground,
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: kPaperBackground,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const NotebookBackground(),
          Column(
            children: [
              // Skeleton של סטטיסטיקות
              _buildStatsSkeleton(cs),
              
              // Skeleton של 5 פריטים
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  itemCount: 5,
                  itemBuilder: (context, index) => _buildItemSkeleton(cs),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Error State - משופר עם אייקון מונפש
  Widget _buildError(ColorScheme cs, ShoppingListsProvider provider) {
    debugPrint('❌ _buildError()');
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: cs.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: EdgeInsets.all(kSpacingLarge),
                    decoration: BoxDecoration(
                      color: cs.errorContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: kIconSizeXLarge,
                      color: cs.error,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: kSpacingLarge),
            Text(
              'שגיאה בטעינת הרשימה',
              style: TextStyle(
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: kSpacingSmall),
            Text(
              'משהו השתבש... בואו ננסה שוב',
              style: TextStyle(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: kSpacingLarge),
            ElevatedButton.icon(
              onPressed: () {
                debugPrint('🔄 retry - טוען מחדש');
                provider.retry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('נסה שוב'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: kSpacingLarge,
                  vertical: kSpacingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State - משופר עם אנימציה
  Widget _buildEmpty(ColorScheme cs) {
    debugPrint('📭 _buildEmpty()');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Container(
                    padding: EdgeInsets.all(kSpacingLarge),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primaryContainer.withValues(alpha: 0.3),
                          cs.secondaryContainer.withValues(alpha: 0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_basket_outlined,
                      size: kIconSizeXLarge,
                      color: cs.primary,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: kSpacingLarge),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Column(
                  children: [
                    Text(
                      'הרשימה ריקה',
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: kSpacingSmall),
                    Text(
                      'לחץ על כפתור + להוספת פריטים',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// סטטיסטיקות Header - עם אנימציית מספרים
  Widget _buildStatsHeader(ShoppingList list, ColorScheme cs) {
    // חישוב סטטיסטיקות
    final totalAmount = list.items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    final totalQuantity = list.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    debugPrint('📊 סטטיסטיקות: ${list.items.length} פריטים, ₪$totalAmount, כמות: $totalQuantity');

    return StickyNote(
      color: kStickyYellow,
      rotation: -0.015,
      child: Container(
        padding: EdgeInsets.all(kSpacingMedium),
        margin: EdgeInsets.all(kSpacingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'פריטים',
              list.items.length,
              Icons.shopping_cart,
              cs,
            ),
            _buildStatItem(
              'סה"כ',
              totalAmount.toInt(),
              Icons.account_balance_wallet,
              cs,
              prefix: '₪',
            ),
            _buildStatItem(
              'כמות',
              totalQuantity,
              Icons.format_list_numbered,
              cs,
            ),
          ],
        ),
      ),
    );
  }

  /// פריט סטטיסטיקה בודד - עם אנימציית מספרים
  Widget _buildStatItem(
    String label,
    int value,
    IconData icon,
    ColorScheme cs, {
    String? prefix,
  }) {
    return Column(
      children: [
        Icon(icon, color: cs.onPrimaryContainer, size: kIconSize),
        SizedBox(height: kSpacingTiny),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, animatedValue, child) {
            return Text(
              prefix != null ? '$prefix$animatedValue' : '$animatedValue',
              style: TextStyle(
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            );
          },
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: kFontSizeSmall,
            color: cs.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  /// פריט ברשימה - עם אנימציה
  Widget _buildListItem(
    BuildContext context,
    ShoppingListsProvider provider,
    int index,
    ReceiptItem item,
    ColorScheme cs,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: _kItemAnimationBaseDuration + (_kItemAnimationStaggerDelay * index),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: kSpacingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.errorContainer,
                cs.error,
              ],
            ),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          ),
          child: Icon(
            Icons.delete,
            color: cs.onError,
          ),
        ),
        confirmDismiss: (direction) async {
          debugPrint('❓ confirmDismiss | פריט: ${item.name}');
          return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('אישור מחיקה'),
                  content: Text('למחוק את "${item.name ?? 'ללא שם'}"?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        debugPrint('❌ ביטול מחיקה');
                        Navigator.pop(ctx, false);
                      },
                      child: const Text('ביטול'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        debugPrint('✅ אישור מחיקה');
                        Navigator.pop(ctx, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                      ),
                      child: const Text('מחק'),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) async {
          await _deleteItem(
            context,
            provider,
            index,
            item,
          );
        },
        child: StickyNote(
          color: item.isChecked ? Colors.grey.shade200 : kStickyCyan,
          rotation: (index % 2 == 0) ? 0.008 : -0.008,
          child: GestureDetector(
            onTap: () async {
              await _toggleItem(provider, index, item);
            },
            child: Padding(
              padding: EdgeInsets.all(kSpacingMedium),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Checkbox(
                      value: item.isChecked,
                      onChanged: (_) async {
                        await _toggleItem(provider, index, item);
                      },
                    ),
                  ),
                  SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? 'ללא שם',
                          style: TextStyle(
                            fontSize: kFontSizeMedium,
                            fontWeight: FontWeight.w500,
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isChecked
                                ? cs.onSurfaceVariant
                                : cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: kSpacingTiny),
                        Text(
                          "${item.quantity} × ₪${item.unitPrice.toStringAsFixed(2)} = ₪${item.totalPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            color: cs.onSurfaceVariant,
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

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 ManageListScreen.build()');
    
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final provider = context.watch<ShoppingListsProvider>();
    final list = provider.getById(widget.listId);

    // Loading State - Skeleton Screen
    if (provider.isLoading && list == null) {
      return _buildLoading(cs);
    }

    // Error State
    if (provider.hasError) {
      return _buildError(cs, provider);
    }

    // List not found
    if (list == null) {
      debugPrint('❌ רשימה ${widget.listId} לא נמצאה');
      return Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: const Text('שגיאה'),
          backgroundColor: kPaperBackground,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: kIconSizeXLarge,
                color: cs.error,
              ),
              SizedBox(height: kSpacingMedium),
              Text(
                'רשימה לא נמצאה',
                style: TextStyle(
                  fontSize: kFontSizeMedium,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Content
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: Text(widget.listName),
          backgroundColor: kPaperBackground,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'התחל קניה',
              onPressed: () {
                debugPrint('▶️ ניווט לקנייה פעילה');
                Navigator.pushNamed(
                  context,
                  '/active-shopping',
                  arguments: list,
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            Column(
              children: [
                // Header - סטטיסטיקות
                _buildStatsHeader(list, cs),

                // רשימת פריטים
                Expanded(
                  child: list.items.isEmpty
                      ? _buildEmpty(cs)
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: kSpacingMedium),
                          itemCount: list.items.length,
                          itemBuilder: (context, index) {
                            final item = list.items[index];
                            return _buildListItem(
                              context,
                              provider,
                              index,
                              item,
                              cs,
                            );
                          },
                        ),
                ),
              ],
            ),
          ],
        ),

        floatingActionButton: ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabController,
            curve: Curves.easeInOut,
          ),
          child: StickyButton(
            label: 'הוסף פריט',
            icon: Icons.add,
            color: accent,
            onPressed: () {
              _fabController.forward().then((_) => _fabController.reverse());
              _showAddCustomItemDialog(provider);
            },
          ),
        ),
      ),
    );
  }
}
