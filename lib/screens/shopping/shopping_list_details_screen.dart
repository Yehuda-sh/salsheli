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

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/shopping_list.dart';
import '../../models/unified_list_item.dart';
import '../../models/enums/item_type.dart';
import '../../providers/shopping_lists_provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../widgets/common/animated_button.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/pending_requests_section.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/shopping/product_selection_bottom_sheet.dart';
import '../settings/manage_users_screen.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  final ShoppingList list;

  const ShoppingListDetailsScreen({super.key, required this.list});

  @override
  State<ShoppingListDetailsScreen> createState() => _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> with TickerProviderStateMixin {
  // 🔍 חיפוש ומיון
  String _searchQuery = '';
  final bool _groupByCategory = false;
  String _sortBy = 'none'; // none | price_desc | checked
  String? _selectedCategory; // קטגוריה נבחרת לסינון

  // 🏷️ קטגוריות עם אימוג'י
  Map<String, String> get _categoryEmojis => {
    AppStrings.listDetails.categoryAll: '📦',
    AppStrings.listDetails.categoryVegetables: '🥬',
    AppStrings.listDetails.categoryMeat: '🍖',
    AppStrings.listDetails.categoryDairy: '🥛',
    AppStrings.listDetails.categoryBakery: '🍞',
    AppStrings.listDetails.categoryCanned: '🥫',
    AppStrings.listDetails.categoryFrozen: '❄️',
    AppStrings.listDetails.categoryCleaning: '🧽',
    AppStrings.listDetails.categoryHygiene: '🚿',
    AppStrings.listDetails.categoryOther: '📋',
  };

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

  /// 🛒 פתיחת Bottom Sheet לבחירת מוצרים
  Future<void> _navigateToPopulateScreen() async {
    debugPrint('🛒 ShoppingListDetailsScreen: פתיחת Bottom Sheet');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductSelectionBottomSheet(list: widget.list),
    );

    // רענון הרשימה אחרי סגירה
    if (mounted) {
      debugPrint('✅ ShoppingListDetailsScreen: חזרה מ-Bottom Sheet');
      setState(() {});
    }
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
          _errorMessage = AppStrings.listDetails.loadingError;
        });
        debugPrint('❌ ShoppingListDetailsScreen: שגיאה בטעינה - $e');
      }
    }
  }

  /// === דיאלוג הוספה/עריכה עם אנימציה ===
  void _showItemDialog(BuildContext context, {UnifiedListItem? item, int? index}) {
    final provider = context.read<ShoppingListsProvider>();

    // Controllers - יש לסגור אותם!
    final nameController = TextEditingController(text: item?.name ?? "");
    final quantityController = TextEditingController(text: item?.quantity?.toString() ?? "1");
    final priceController = TextEditingController(text: item?.unitPrice?.toString() ?? "");

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
              title: Text(item == null ? AppStrings.listDetails.addProductTitle : AppStrings.listDetails.editProductTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: AppStrings.listDetails.productNameLabel),
                    textDirection: ui.TextDirection.rtl,
                  ),
                  const SizedBox(height: kSpacingSmall),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: AppStrings.listDetails.quantityLabel),
                    keyboardType: TextInputType.number,
                    textDirection: ui.TextDirection.rtl,
                  ),
                  const SizedBox(height: kSpacingSmall),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: AppStrings.listDetails.priceLabel),
                    keyboardType: TextInputType.number,
                    textDirection: ui.TextDirection.rtl,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    debugPrint('❌ ShoppingListDetailsScreen: ביטול דיאלוג');
                    Navigator.pop(context);
                    // Dispose אחרי שהאנימציה נגמרת
                    Future.delayed(const Duration(milliseconds: 250), disposeControllers);
                  },
                  child: Text(AppStrings.common.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final qtyText = quantityController.text.trim();
                    final priceText = priceController.text.trim();

                    // ✅ Validation מלא
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.listDetails.productNameEmpty), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final qty = int.tryParse(qtyText);
                    if (qty == null || qty <= 0 || qty > 9999) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.listDetails.quantityInvalid), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final unitPrice = double.tryParse(priceText);
                    if (unitPrice == null || unitPrice < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.listDetails.priceInvalid),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newItem = UnifiedListItem.product(
                      id: const Uuid().v4(),
                      name: name,
                      quantity: qty ?? 1,
                      unitPrice: unitPrice,
                      unit: "יח'",
                    );

                    if (item == null) {
                      provider.addUnifiedItem(widget.list.id, newItem);
                      debugPrint('✅ ShoppingListDetailsScreen: הוסף מוצר "$name"');
                    } else if (index != null) {
                      provider.updateItemAt(widget.list.id, index, (_) => newItem);
                      debugPrint('✅ ShoppingListDetailsScreen: עדכן מוצר "$name"');
                    }

                    Navigator.pop(context);
                    // Dispose אחרי שהאנימציה נגמרת
                    Future.delayed(const Duration(milliseconds: 250), disposeControllers);
                  },
                  child: Text(AppStrings.common.save),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// === דיאלוג הוספת משימה עם אנימציה ===
  void _showTaskDialog(BuildContext context, {UnifiedListItem? item, int? index}) {
    final provider = context.read<ShoppingListsProvider>();

    // Controllers - יש לסגור אותם!
    final nameController = TextEditingController(text: item?.name ?? "");
    final notesController = TextEditingController(text: item?.notes ?? "");
    DateTime? selectedDueDate = item?.dueDate;
    String selectedPriority = item?.priority ?? 'medium';

    debugPrint(
      item == null
          ? '➕ ShoppingListDetailsScreen: פתיחת דיאלוג הוספת משימה'
          : '✏️ ShoppingListDetailsScreen: פתיחת דיאלוג עריכת "${item.name}"',
    );

    // פונקציה לניקוי controllers
    void disposeControllers() {
      nameController.dispose();
      notesController.dispose();
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              child: FadeTransition(
                opacity: animation,
                child: AlertDialog(
                  title: Text(item == null ? AppStrings.listDetails.addTaskTitle : AppStrings.listDetails.editTaskTitle),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: AppStrings.listDetails.taskNameLabel),
                          textDirection: ui.TextDirection.rtl,
                        ),
                        const SizedBox(height: kSpacingSmall),
                        TextField(
                          controller: notesController,
                          decoration: InputDecoration(labelText: AppStrings.listDetails.notesLabel),
                          textDirection: ui.TextDirection.rtl,
                          maxLines: 3,
                        ),
                        const SizedBox(height: kSpacingMedium),
                        // תאריך יעד
                        ListTile(
                          title: Text(
                            selectedDueDate != null
                                ? AppStrings.listDetails.dueDateSelected(DateFormat('dd/MM/yyyy').format(selectedDueDate!))
                                : AppStrings.listDetails.dueDateLabel,
                            style: TextStyle(color: selectedDueDate != null ? Colors.green : Colors.grey),
                          ),
                          leading: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => selectedDueDate = picked);
                            }
                          },
                        ),
                        const SizedBox(height: kSpacingSmall),
                        // עדיפות
                        DropdownButtonFormField<String>(
                          initialValue: selectedPriority,
                          decoration: InputDecoration(labelText: AppStrings.listDetails.priorityLabel),
                          items: [
                            DropdownMenuItem(value: 'low', child: Text(AppStrings.listDetails.priorityLow)),
                            DropdownMenuItem(value: 'medium', child: Text(AppStrings.listDetails.priorityMedium)),
                            DropdownMenuItem(value: 'high', child: Text(AppStrings.listDetails.priorityHigh)),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedPriority = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        debugPrint('❌ ShoppingListDetailsScreen: ביטול דיאלוג משימה');
                        Navigator.pop(context);
                        // Dispose אחרי שהאנימציה נגמרת
                        Future.delayed(const Duration(milliseconds: 250), disposeControllers);
                      },
                      child: Text(AppStrings.common.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final notes = notesController.text.trim();

                        // ✅ Validation מלא
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppStrings.listDetails.taskNameEmpty), backgroundColor: Colors.red),
                          );
                          return;
                        }

                        final newItem = UnifiedListItem.task(
                          id: item?.id ?? const Uuid().v4(),
                          name: name,
                          dueDate: selectedDueDate,
                          priority: selectedPriority,
                          notes: notes.isNotEmpty ? notes : null,
                        );

                        if (item == null) {
                          // הוספה - נשתמש ב-addUnifiedItem החדש!
                          provider.addUnifiedItem(widget.list.id, newItem);
                          debugPrint('✅ ShoppingListDetailsScreen: הוסף משימה "$name"');
                        } else if (index != null) {
                          provider.updateItemAt(widget.list.id, index, (_) => newItem);
                          debugPrint('✅ ShoppingListDetailsScreen: עדכן משימה "$name"');
                        }

                        Navigator.pop(context);
                        // Dispose אחרי שהאנימציה נגמרת
                        Future.delayed(const Duration(milliseconds: 250), disposeControllers);
                      },
                      child: Text(AppStrings.common.save),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// === מחיקת פריט עם אנימציה ===
  void _deleteItem(BuildContext context, int index, UnifiedListItem removed) {
    final provider = context.read<ShoppingListsProvider>();
    provider.removeItemFromList(widget.list.id, index);

    debugPrint('🗑️ ShoppingListDetailsScreen: מחק מוצר "${removed.name ?? 'ללא שם'}"');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.listDetails.itemDeleted(removed.name ?? 'ללא שם')),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: AppStrings.common.cancel,
          textColor: Colors.white,
          onPressed: () {
            provider.addItemToList(
              widget.list.id,
              removed.name ?? 'מוצר ללא שם',
              removed.quantity ?? 1,
              removed.unit ?? "יח'",
            );
            debugPrint('↩️ ShoppingListDetailsScreen: שחזר מוצר "${removed.name}"');
          },
        ),
      ),
    );
  }

  /// 🔍 סינון ומיון פריטים
  List<UnifiedListItem> _getFilteredAndSortedItems(List<UnifiedListItem> items) {
    final filtered = items.where((item) {
      // סינון לפי חיפוש
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (item.name ?? '').toLowerCase();
        if (!name.contains(query)) return false;
      }

      // סינון לפי קטגוריה
      if (_selectedCategory != null && _selectedCategory != AppStrings.listDetails.categoryAll) {
        final itemCategory = item.category ?? AppStrings.listDetails.categoryOther;
        if (itemCategory != _selectedCategory) return false;
      }

      return true;
    }).toList();

    // מיון
    switch (_sortBy) {
      case 'price_desc':
        filtered.sort((a, b) => (b.unitPrice ?? 0).compareTo(a.unitPrice ?? 0));
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
  Map<String, List<UnifiedListItem>> _groupItemsByCategory(List<UnifiedListItem> items) {
    final grouped = <String, List<UnifiedListItem>>{};

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

    // 🎬 FAB Animation
    final fabAnimation = CurvedAnimation(parent: _fabController, curve: Curves.elasticOut);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: Text(currentList.name),
          actions: [
            // כפתור שיתוף
            ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)),
              child: IconButton(
                icon: const Icon(Icons.share),
                tooltip: AppStrings.listDetails.shareListTooltip,
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.push(MaterialPageRoute(builder: (context) => ManageUsersScreen(list: currentList)));
                },
              ),
            ),
            // כפתור הוספה מהקטלוג
            ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)),
              child: IconButton(
                icon: const Icon(Icons.library_add),
                tooltip: AppStrings.listDetails.addFromCatalogTooltip,
                onPressed: () => _navigateToPopulateScreen(),
              ),
            ),
            // כפתור חיפוש
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

                // 📝 בקשות ממתינות
                if (currentList.pendingRequestsForReview.isNotEmpty && currentList.canCurrentUserApprove)
                  PendingRequestsSection(listId: currentList.id, canApprove: currentList.canCurrentUserApprove),

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

                // 💰 סה"כ מונפש - מוסתר כרגע
                // _buildAnimatedTotal(totalAmount, theme),
              ],
            ),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: fabAnimation,
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 📋 הוסף משימה
                Flexible(
                  child: StickyButton(
                    color: kStickyCyan,
                    label: AppStrings.listDetails.addTaskButton,
                    icon: Icons.task_alt,
                    onPressed: () {
                      _fabController.reverse().then((_) {
                        _fabController.forward();
                      });
                      _showTaskDialog(context);
                    },
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
                // 🛒 הוסף מוצר
                Flexible(
                  child: StickyButton(
                    color: kStickyYellow,
                    label: AppStrings.listDetails.addProductButton,
                    icon: Icons.shopping_basket,
                    onPressed: () {
                      _fabController.reverse().then((_) {
                        _fabController.forward();
                      });
                      _showItemDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// 🔍 סעיף חיפוש וסינון
  Widget _buildFiltersSection(List<UnifiedListItem> allItems) {
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
                hintText: AppStrings.listDetails.searchHint,
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

            const SizedBox(height: kSpacingMedium),

            // 🏷️ גריד קטגוריות - רק בסופרמרקט!
            if (widget.list.type == ShoppingList.typeSupermarket) ...[
              _buildCategoryGrid(),
              const SizedBox(height: kSpacingSmall),
            ],

            // 📊 שורת מיון ומונה
            Row(
              children: [
                Expanded(child: _buildSortButton()),
                if (allItems.isNotEmpty) ...[
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey<int>(allItems.length),
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingSmall),
                        decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: Text(
                        '📦 ${AppStrings.listDetails.itemsCount(allItems.length)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🏷️ גריד קטגוריות עם אימוג'י
  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: kSpacingTiny,
      runSpacing: kSpacingTiny,
      children: _categoryEmojis.entries.map((entry) {
        final isSelected = _selectedCategory == entry.key || (_selectedCategory == null && entry.key == 'הכל');
        return AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: FilterChip(
            label: Text('${entry.value} ${entry.key}'),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = entry.key == AppStrings.listDetails.categoryAll ? null : entry.key;
              });
              debugPrint('🏷️ ShoppingListDetailsScreen: סנן לפי "${entry.key}"');
            },
            backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }).toList(),
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
              Text(AppStrings.listDetails.sortButton),
            ],
          ),
        ),
        itemBuilder: (context) => [
          _buildSortMenuItem('none', AppStrings.listDetails.sortNone, Icons.clear),
          _buildSortMenuItem('price_desc', AppStrings.listDetails.sortPriceDesc, Icons.arrow_downward),
          _buildSortMenuItem('checked', AppStrings.listDetails.sortStatus, Icons.check_circle_outline),
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
                  Text(AppStrings.listDetails.errorTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: kSpacingSmall),
                  Text(
                    AppStrings.listDetails.errorMessage(_errorMessage),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpacingLarge),
                  StickyButton(
                    color: Colors.red.shade100,
                    textColor: Colors.red.shade700,
                    label: AppStrings.common.retry,
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
  Widget _buildFlatList(List<UnifiedListItem> items, ThemeData theme) {
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
  Widget _buildGroupedList(List<UnifiedListItem> items, ThemeData theme) {
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

  /// 🎴 כרטיס פריט מונפש - עם תמונה
  Widget _buildItemCard(UnifiedListItem item, int index, ThemeData theme, Color stickyColor, double rotation) {
    // 🎯 איקונים וצבעים לפי סוג
    final isProduct = item.type == ItemType.product;
    final actualColor = isProduct ? kStickyYellow : kStickyCyan;

    // קטגוריה עם אימוג'י
    final category = item.category ?? AppStrings.listDetails.categoryOther;
    final categoryEmoji = _categoryEmojis[category] ?? '📋';

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
          title: Text(AppStrings.listDetails.deleteTitle),
          content: Text(AppStrings.listDetails.deleteMessage(item.name ?? 'ללא שם')),
            actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.common.cancel)),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: Text(AppStrings.common.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteItem(context, index, item),
      child: StickyNote(
        color: actualColor,
        rotation: rotation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(kSpacingMedium),
          decoration: BoxDecoration(
            color: item.isChecked ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Row(
            children: [
              // 🖼️ תמונת מוצר
              _buildProductImage(item, theme),
              
              const SizedBox(width: kSpacingMedium),

              // ✅ Checkbox
              AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: AnimatedButton(
              onPressed: () {
                    final provider = context.read<ShoppingListsProvider>();
                    provider.updateItemAt(
                      widget.list.id,
                      index,
                      (current) => current.copyWith(isChecked: !current.isChecked),
                    );
                  },
                  child: item.isChecked
                      ? Icon(
                          Icons.check_circle,
                          key: const ValueKey('checked'),
                          color: theme.colorScheme.primary,
                          size: kIconSizeMedium,
                        )
                      : Icon(
                          Icons.radio_button_unchecked,
                          key: const ValueKey('unchecked'),
                          color: theme.colorScheme.onSurfaceVariant,
                          size: kIconSizeMedium,
                        ),
                ),
              ),

              const SizedBox(width: kSpacingSmall),

              // 📝 שם + קטגוריה + מחיר
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: theme.textTheme.titleSmall!.copyWith(
                        decoration: item.isChecked ? TextDecoration.lineThrough : null,
                        color: item.isChecked ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      child: Text(item.name ?? 'ללא שם', maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          categoryEmoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isProduct ? AppStrings.listDetails.quantityDisplay(item.quantity ?? 1) : AppStrings.listDetails.taskLabel,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        if (isProduct && item.unitPrice != null && item.unitPrice! > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₪${item.unitPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // 🔘 כפתורי פעולה
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: Colors.blue,
                  tooltip: AppStrings.listDetails.editTooltip,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () {
                      if (isProduct) {
                        _showItemDialog(context, item: item, index: index);
                      } else {
                        _showTaskDialog(context, item: item, index: index);
                      }
                    },
                  ),
                  IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  color: Colors.red,
                  tooltip: AppStrings.listDetails.deleteTooltip,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => _deleteItem(context, index, item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🖼️ בניית תמונת מוצר עם placeholder
  Widget _buildProductImage(UnifiedListItem item, ThemeData theme) {
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final isProduct = item.type == ItemType.product;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kBorderRadius - 1),
        child: hasImage
            ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderIcon(isProduct, theme);
                },
              )
            : _buildPlaceholderIcon(isProduct, theme),
      ),
    );
  }

  /// 🎨 אייקון placeholder כשאין תמונה
  Widget _buildPlaceholderIcon(bool isProduct, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isProduct
              ? [Colors.amber.shade100, Colors.amber.shade200]
              : [Colors.blue.shade100, Colors.blue.shade200],
        ),
      ),
      child: Icon(
        isProduct ? Icons.shopping_bag : Icons.task_alt,
        color: isProduct ? Colors.amber.shade700 : Colors.blue.shade700,
        size: 32,
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
                  Text(
                    AppStrings.listDetails.noSearchResultsTitle,
                    style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kSpacingSmall),
                  Text(AppStrings.listDetails.noSearchResultsMessage),
                  const SizedBox(height: kSpacingLarge),
                  StickyButtonSmall(
                    color: Colors.orange.shade100,
                    textColor: Colors.orange.shade700,
                    label: AppStrings.listDetails.clearSearchButton,
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
              padding: const EdgeInsets.all(kSpacingXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: kIconSizeXXLarge, color: Colors.green.shade700),
                  const SizedBox(height: kSpacingXLarge),
                  Text(AppStrings.listDetails.emptyListTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: kSpacingMedium),
                  Text(AppStrings.listDetails.emptyListMessage, style: const TextStyle(fontSize: kFontSizeMedium)),
                  const SizedBox(height: kSpacingSmall),
                  Text(AppStrings.listDetails.emptyListSubMessage, style: const TextStyle(fontSize: kFontSizeSmall)),
                  const SizedBox(height: kSpacingLarge),
                  StickyButton(
                    color: kStickyCyan,
                    label: AppStrings.listDetails.populateFromCatalog,
                    icon: Icons.library_add,
                    onPressed: () => _navigateToPopulateScreen(),
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
