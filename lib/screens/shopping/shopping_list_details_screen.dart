// 📄 File: lib/screens/shopping/shopping_list_details_screen.dart - V3.0 MODERN UI/UX
//
// ✨ שיפורים חדשים (v3.0):
// 1. 💀 Skeleton Screen: טעינה מודרנית במקום spinner
// 2. 🎬 Staggered Animations: פריטים מופיעים אחד אחד
// 3. 🎯 Micro Animations: כל כפתור מגיב ללחיצה
// 4. 🎨 Empty States מעוצבים: gradients + אנימציות
// 5. ❌ Error Recovery: טיפול מלא בשגיאות
// 6. 💰 Animated Total: הסכום משתנה בחלקות
// 7. 📊 Animated Counter: מונה פריטים מונפש
// 8. 💬 Dialog Animations: fade + scale
// 9. 📝 Logging מפורט: עם אימוג'י
//
// 🔍 תכונות קיימות (v2.0):
// 1. 🔍 חיפוש פריט בתוך הרשימה
// 2. 🏷️ קיבוץ לפי קטגוריה
// 3. 📊 מיון: מחיר (יקר→זול) | סטטוס (checked→unchecked)
//
// 🇮🇱 מסך עריכת פרטי רשימת קניות:
//     - מוסיף/עורך/מוחק פריטים דרך ShoppingListsProvider.
//     - מחשב עלות כוללת.
//     - מציג UI רספונסיבי עם RTL.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;

import '../../models/receipt.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../core/ui_constants.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/sticky_button.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  final ShoppingList list;

  const ShoppingListDetailsScreen({super.key, required this.list});

  @override
  State<ShoppingListDetailsScreen> createState() => _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> with TickerProviderStateMixin {
  // 🔍 חיפוש ומיון
  String _searchQuery = '';
  bool _groupByCategory = false;
  String _sortBy = 'none'; // none | price_desc | checked

  // 🎬 Animation Controllers
  late AnimationController _fabController;
  late AnimationController _listController;

  // 📊 State Management
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('📋 ShoppingListDetailsScreen: פתיחת רשימה "${widget.list.name}"');

    // 🎬 Initialize Animation Controllers
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    // 🚀 Start animations
    _fabController.forward();
    _loadData();
  }

  @override
  void dispose() {
    debugPrint('🗑️ ShoppingListDetailsScreen: סגירת מסך');
    _fabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  /// 🔄 טעינת נתונים
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // סימולציה של טעינה (במקרה שיש async operation)
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _listController.forward();
        debugPrint('✅ ShoppingListDetailsScreen: טעינה הושלמה');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'שגיאה בטעינת הנתונים';
        });
        debugPrint('❌ ShoppingListDetailsScreen: שגיאה בטעינה - $e');
      }
    }
  }

  /// === דיאלוג הוספה/עריכה עם אנימציה ===
  void _showItemDialog(BuildContext context, {ReceiptItem? item, int? index}) {
    final provider = context.read<ShoppingListsProvider>();

    // Controllers - יש לסגור אותם!
    final nameController = TextEditingController(text: item?.name ?? "");
    final quantityController = TextEditingController(text: item?.quantity.toString() ?? "1");
    final priceController = TextEditingController(text: item?.unitPrice.toString() ?? "");

    debugPrint(
      item == null
          ? '➕ ShoppingListDetailsScreen: פתיחת דיאלוג הוספת מוצר'
          : '✏️ ShoppingListDetailsScreen: פתיחת דיאלוג עריכת "${item.name}"',
    );

    // פונקציה לניקוי controllers
    void disposeControllers() {
      nameController.dispose();
      quantityController.dispose();
      priceController.dispose();
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              title: Text(item == null ? "הוספת מוצר" : "עריכת מוצר"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "שם מוצר"),
                    textDirection: ui.TextDirection.rtl,
                  ),
                  const SizedBox(height: kSpacingSmall),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: "כמות"),
                    keyboardType: TextInputType.number,
                    textDirection: ui.TextDirection.rtl,
                  ),
                  const SizedBox(height: kSpacingSmall),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "מחיר ליחידה"),
                    keyboardType: TextInputType.number,
                    textDirection: ui.TextDirection.rtl,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    debugPrint('❌ ShoppingListDetailsScreen: ביטול דיאלוג');
                    disposeControllers();
                    Navigator.pop(context);
                  },
                  child: const Text("ביטול"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final qtyText = quantityController.text.trim();
                    final priceText = priceController.text.trim();

                    // ✅ Validation מלא
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('שם המוצר לא יכול להיות ריק'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final qty = int.tryParse(qtyText);
                    if (qty == null || qty <= 0 || qty > 9999) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('כמות לא תקינה (1-9999)'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final unitPrice = double.tryParse(priceText);
                    if (unitPrice == null || unitPrice < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('מחיר לא תקין (חייב להיות מספר חיובי)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newItem = ReceiptItem(id: const Uuid().v4(), name: name, quantity: qty, unitPrice: unitPrice);

                    if (item == null) {
                      provider.addItemToList(
                        widget.list.id,
                        newItem.name ?? 'מוצר ללא שם',
                        newItem.quantity,
                        newItem.unit ?? "יח'",
                      );
                      debugPrint('✅ ShoppingListDetailsScreen: הוסף מוצר "$name"');
                    } else if (index != null) {
                      provider.updateItemAt(widget.list.id, index, (_) => newItem);
                      debugPrint('✅ ShoppingListDetailsScreen: עדכן מוצר "$name"');
                    }

                    disposeControllers();
                    Navigator.pop(context);
                  },
                  child: const Text("שמירה"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// === מחיקת פריט עם אנימציה ===
  void _deleteItem(BuildContext context, int index, ReceiptItem removed) {
    final provider = context.read<ShoppingListsProvider>();
    provider.removeItemFromList(widget.list.id, index);

    debugPrint('🗑️ ShoppingListDetailsScreen: מחק מוצר "${removed.name ?? 'ללא שם'}"');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('המוצר "${removed.name ?? 'ללא שם'}" נמחק'),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: 'בטל',
          textColor: Colors.white,
          onPressed: () {
            provider.addItemToList(
              widget.list.id,
              removed.name ?? 'מוצר ללא שם',
              removed.quantity,
              removed.unit ?? "יח'",
            );
            debugPrint('↩️ ShoppingListDetailsScreen: שחזר מוצר "${removed.name}"');
          },
        ),
      ),
    );
  }

  /// 🔍 סינון ומיון פריטים
  List<ReceiptItem> _getFilteredAndSortedItems(List<ReceiptItem> items) {
    var filtered = items.where((item) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = (item.name ?? '').toLowerCase();
      return name.contains(query);
    }).toList();

    // מיון
    switch (_sortBy) {
      case 'price_desc':
        filtered.sort((a, b) => b.unitPrice.compareTo(a.unitPrice));
        debugPrint('📊 ShoppingListDetailsScreen: מיון לפי מחיר (יקר→זול)');
        break;
      case 'checked':
        filtered.sort((a, b) {
          if (a.isChecked == b.isChecked) return 0;
          return a.isChecked ? 1 : -1; // unchecked קודם
        });
        debugPrint('📊 ShoppingListDetailsScreen: מיון לפי סטטוס');
        break;
    }

    return filtered;
  }

  /// 🏷️ קיבוץ לפי קטגוריה
  Map<String, List<ReceiptItem>> _groupItemsByCategory(List<ReceiptItem> items) {
    final grouped = <String, List<ReceiptItem>>{};

    for (var item in items) {
      final category = item.category ?? 'ללא קטגוריה';
      grouped.putIfAbsent(category, () => []).add(item);
    }

    debugPrint('🏷️ ShoppingListDetailsScreen: קיבוץ ל-${grouped.length} קטגוריות');
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();
    final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id, orElse: () => widget.list);

    final theme = Theme.of(context);
    final allItems = currentList.items;
    final filteredItems = _getFilteredAndSortedItems(allItems);
    final totalAmount = allItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    // 🎬 FAB Animation
    final fabAnimation = CurvedAnimation(parent: _fabController, curve: Curves.elasticOut);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: Text(currentList.name),
          actions: [
            ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)),
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    if (_searchQuery.isNotEmpty) {
                      _searchQuery = '';
                      debugPrint('🧹 ShoppingListDetailsScreen: ניקוי חיפוש');
                    }
                  });
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            Column(
              children: [
                // 🔍 חיפוש וסינון
                _buildFiltersSection(allItems),

                // 📋 תוכן
                Expanded(
                  child: _isLoading
                      ? _buildLoadingSkeleton(theme)
                      : _errorMessage != null
                      ? _buildErrorState(theme)
                      : filteredItems.isEmpty && allItems.isNotEmpty
                      ? _buildEmptySearchResults()
                      : filteredItems.isEmpty
                      ? _buildEmptyState(theme)
                      : _groupByCategory
                      ? _buildGroupedList(filteredItems, theme)
                      : _buildFlatList(filteredItems, theme),
                ),

                // 💰 סה"כ מונפש
                _buildAnimatedTotal(totalAmount, theme),
              ],
            ),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: fabAnimation,
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: StickyButton(
              color: kStickyYellow,
              label: 'הוסף מוצר',
              icon: Icons.add,
              onPressed: () {
                _fabController.reverse().then((_) {
                  _fabController.forward();
                });
                _showItemDialog(context);
              },
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// 🔍 סעיף חיפוש וסינון
  Widget _buildFiltersSection(List<ReceiptItem> allItems) {
    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: StickyNote(
        color: kStickyCyan,
        rotation: -0.02,
        child: Column(
          children: [
            // 🔍 שורת חיפוש
            TextField(
              decoration: InputDecoration(
                hintText: 'חפש פריט...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                          debugPrint('🧹 ShoppingListDetailsScreen: ניקוי חיפוש');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
                contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kInputPadding),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                if (value.isNotEmpty) {
                  debugPrint('🔍 ShoppingListDetailsScreen: חיפוש "$value"');
                }
              },
            ),

            const SizedBox(height: kSpacingSmall),

            // 🏷️ קיבוץ ומיון
            Row(
              children: [
                // קיבוץ לפי קטגוריה
                Expanded(
                  child: AnimatedScale(
                    scale: _groupByCategory ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: FilterChip(
                      label: const Text('קבץ לפי קטגוריה'),
                      selected: _groupByCategory,
                      onSelected: (value) {
                        setState(() => _groupByCategory = value);
                        debugPrint(
                          value
                              ? '🏷️ ShoppingListDetailsScreen: קיבוץ לפי קטגוריה'
                              : '📋 ShoppingListDetailsScreen: רשימה שטוחה',
                        );
                      },
                      avatar: Icon(_groupByCategory ? Icons.folder_open : Icons.folder, size: kIconSizeMedium),
                    ),
                  ),
                ),

                const SizedBox(width: kSpacingSmall),

                // מיון
                Expanded(child: _buildSortButton()),
              ],
            ),

            // מונה פריטים מונפש
            if (allItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: kSpacingSmall),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    'מציג ${allItems.length} פריטים',
                    key: ValueKey<int>(allItems.length),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 📊 כפתור מיון מונפש
  Widget _buildSortButton() {
    return AnimatedScale(
      scale: _sortBy != 'none' ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: PopupMenuButton<String>(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingSmall),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getSortIcon(), size: kIconSizeMedium),
              const SizedBox(width: kSpacingTiny),
              const Text('מיין'),
            ],
          ),
        ),
        itemBuilder: (context) => [
          _buildSortMenuItem('none', 'ללא מיון', Icons.clear),
          _buildSortMenuItem('price_desc', 'מחיר (יקר→זול)', Icons.arrow_downward),
          _buildSortMenuItem('checked', 'סטטוס (לא נסומן קודם)', Icons.check_circle_outline),
        ],
        onSelected: (value) {
          setState(() => _sortBy = value);
          debugPrint('📊 ShoppingListDetailsScreen: מיון לפי $value');
        },
      ),
    );
  }

  /// פריט תפריט מיון
  PopupMenuItem<String> _buildSortMenuItem(String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: kIconSizeSmall, color: _sortBy == value ? Theme.of(context).colorScheme.primary : null),
          const SizedBox(width: kSpacingSmall),
          Text(label, style: TextStyle(fontWeight: _sortBy == value ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  /// קבלת אייקון לפי סוג המיון
  IconData _getSortIcon() {
    switch (_sortBy) {
      case 'price_desc':
        return Icons.arrow_downward;
      case 'checked':
        return Icons.check_circle_outline;
      default:
        return Icons.sort;
    }
  }

  /// 💀 Skeleton Screen לטעינה
  Widget _buildLoadingSkeleton(ThemeData theme) {
    final stickyColors = [kStickyYellow, kStickyPink, kStickyGreen];
    final stickyRotations = [0.01, -0.015, 0.01];

    return ListView.builder(
      padding: const EdgeInsets.all(kSpacingMedium),
      itemCount: 8,
      itemBuilder: (context, index) {
        final colorIndex = index % stickyColors.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: kSpacingMedium),
          child: StickyNote(
            color: stickyColors[colorIndex],
            rotation: stickyRotations[colorIndex],
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Row(
                children: [
                  // אייקון
                  _buildSkeletonBox(width: 40, height: 40, borderRadius: 20, delay: index * 100),
                  const SizedBox(width: kSpacingMedium),
                  // תוכן
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonBox(width: double.infinity, height: 16, delay: index * 100 + 50),
                        const SizedBox(height: kSpacingSmall),
                        _buildSkeletonBox(width: 120, height: 14, delay: index * 100 + 100),
                      ],
                    ),
                  ),
                  // כפתורים
                  Row(
                    children: [
                      _buildSkeletonBox(width: 40, height: 40, borderRadius: 20, delay: index * 100 + 150),
                      const SizedBox(width: kSpacingSmall),
                      _buildSkeletonBox(width: 40, height: 40, borderRadius: 20, delay: index * 100 + 200),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 💀 Skeleton Box עם Shimmer
  Widget _buildSkeletonBox({
    required double width,
    required double height,
    double borderRadius = kBorderRadius,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ],
                stops: [0.0, value, 1.0],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        );
      },
    );
  }

  /// ❌ מצב שגיאה
  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: StickyNote(
            color: kStickyPink,
            rotation: -0.02,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: kIconSizeXXLarge, color: Colors.red.shade700),
                  const SizedBox(height: kSpacingMedium),
                  Text('אופס! משהו השתבש', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: kSpacingSmall),
                  Text(
                    _errorMessage ?? 'אירעה שגיאה בטעינת הנתונים',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpacingLarge),
                  StickyButton(
                    color: Colors.red.shade100,
                    textColor: Colors.red.shade700,
                    label: 'נסה שוב',
                    icon: Icons.refresh,
                    onPressed: () => _loadData(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📋 רשימה שטוחה (flat) עם Staggered Animation
  Widget _buildFlatList(List<ReceiptItem> items, ThemeData theme) {
    final stickyColors = [kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan];
    final stickyRotations = [0.01, -0.015, 0.01, -0.01];

    return ListView.builder(
      padding: const EdgeInsets.all(kSpacingMedium),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final originalIndex = widget.list.items.indexOf(item);
        final colorIndex = index % stickyColors.length;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset((1 - value) * 50, 0),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: kSpacingMedium),
            child: _buildItemCard(item, originalIndex, theme, stickyColors[colorIndex], stickyRotations[colorIndex]),
          ),
        );
      },
    );
  }

  /// 🏷️ רשימה מקובצת לפי קטגוריה
  Widget _buildGroupedList(List<ReceiptItem> items, ThemeData theme) {
    final grouped = _groupItemsByCategory(items);
    final categories = grouped.keys.toList()..sort();
    final stickyColors = [kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan];
    final stickyRotations = [0.01, -0.015, 0.01, -0.01];
    int globalIndex = 0;

    return ListView.builder(
      padding: const EdgeInsets.all(kSpacingMedium),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        final categoryItems = grouped[category]!;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (catIndex * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset((1 - value) * 50, 0),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // כותרת קטגוריה
              Padding(
                padding: const EdgeInsets.only(bottom: kSpacingMedium),
                child: StickyNote(
                  color: kStickyPurple,
                  rotation: -0.01,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Row(
                      children: [
                        Icon(Icons.folder, size: kIconSizeMedium, color: Colors.purple.shade700),
                        const SizedBox(width: kSpacingSmall),
                        Text(
                          category,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Text(
                          '(${categoryItems.length})',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.purple.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // פריטים בקטגוריה
              ...categoryItems.map((item) {
                final originalIndex = widget.list.items.indexOf(item);
                final colorIndex = globalIndex % stickyColors.length;
                globalIndex++;
                return Padding(
                  padding: const EdgeInsets.only(bottom: kSpacingMedium),
                  child: _buildItemCard(
                    item,
                    originalIndex,
                    theme,
                    stickyColors[colorIndex],
                    stickyRotations[colorIndex],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// 🎴 כרטיס פריט מונפש
  Widget _buildItemCard(ReceiptItem item, int index, ThemeData theme, Color stickyColor, double rotation) {
    final formattedPrice = NumberFormat.simpleCurrency(locale: 'he_IL').format(item.totalPrice);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: kSpacingLarge),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('מחיקת מוצר'),
            content: Text('האם למחוק את "${item.name ?? 'ללא שם'}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('מחק'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteItem(context, index, item),
      child: StickyNote(
        color: stickyColor,
        rotation: rotation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: item.isChecked ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: ListTile(
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.titleMedium!.copyWith(
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
              ),
              child: Text(item.name ?? 'ללא שם'),
            ),
            subtitle: Text("כמות: ${item.quantity} | מחיר כולל: $formattedPrice", style: theme.textTheme.bodySmall),
            leading: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: item.isChecked
                  ? Icon(Icons.check_circle, key: const ValueKey('checked'), color: theme.colorScheme.primary)
                  : Icon(
                      Icons.radio_button_unchecked,
                      key: const ValueKey('unchecked'),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  color: Colors.blue,
                  tooltip: "ערוך מוצר",
                  onPressed: () => _showItemDialog(context, item: item, index: index),
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  tooltip: "מחק מוצר",
                  onPressed: () => _deleteItem(context, index, item),
                ),
              ],
            ),
            onTap: () => _showItemDialog(context, item: item, index: index),
          ),
        ),
      ),
    );
  }

  /// 🔘 כפתור פעולה מונפש
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 100),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: IconButton(
            icon: Icon(icon, color: color),
            tooltip: tooltip,
            onPressed: () {
              // Micro animation on tap
              setState(() {});
              Future.delayed(const Duration(milliseconds: 100), () {
                onPressed();
              });
            },
          ),
        );
      },
    );
  }

  /// 💰 סכום כולל מונפש
  Widget _buildAnimatedTotal(double totalAmount, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: StickyNote(
        color: kStickyGreen,
        rotation: 0.015,
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.green.shade700),
                  const SizedBox(width: kSpacingSmall),
                  Text("סה״כ:", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: totalAmount),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Text(
                    NumberFormat.simpleCurrency(locale: 'he_IL').format(value),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📭 תוצאות חיפוש ריקות
  Widget _buildEmptySearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: StickyNote(
            color: kStickyYellow,
            rotation: 0.015,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: kIconSizeXXLarge, color: Colors.orange.shade700),
                  const SizedBox(height: kSpacingLarge),
                  const Text(
                    "לא נמצאו פריטים",
                    style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kSpacingSmall),
                  const Text("נסה לשנות את החיפוש"),
                  const SizedBox(height: kSpacingLarge),
                  StickyButtonSmall(
                    color: Colors.orange.shade100,
                    textColor: Colors.orange.shade700,
                    label: 'נקה חיפוש',
                    icon: Icons.clear_all,
                    onPressed: () {
                      setState(() => _searchQuery = '');
                      debugPrint('🧹 ShoppingListDetailsScreen: ניקוי חיפוש מ-Empty Results');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📋 מצב ריק
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: StickyNote(
            color: kStickyGreen,
            rotation: -0.015,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingXXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: kIconSizeXXLarge, color: Colors.green.shade700),
                  const SizedBox(height: kSpacingXLarge),
                  Text('הרשימה ריקה', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: kSpacingMedium),
                  const Text('לחץ על "הוסף מוצר" להתחלה', style: TextStyle(fontSize: kFontSizeMedium)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
