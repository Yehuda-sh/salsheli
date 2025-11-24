// 📄 File: lib/screens/shopping/shopping_list_details_screen.dart - V3.1 MODERN UI/UX
// 📦 Helper File: shopping_list_details_screen_ux.dart (skeleton & states)
//
// ✨ שיפורים חדשים (v3.1):
// 1. 💀 Skeleton Screen: הועבר לקובץ _ux נפרד (1258 → 1088 שורות)
// 2. 🎬 Staggered Animations: פריטים מופיעים אחד אחד
// 3. 🎯 Micro Animations: כל כפתור מגיב ללחיצה
// 4. 🎨 Empty/Error States: הועברו לקובץ _ux
// 5. 💰 Animated Total: הסכום משתנה בחלקות
// 6. 📊 Animated Counter: מונה פריטים מונפש
// 7. 💬 Dialog Animations: fade + scale
// 8. 📝 Logging מפורט: עם אימוג'י
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

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../models/shopping_list.dart';
import '../../../models/unified_list_item.dart';
import '../../../models/enums/item_type.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/user_context.dart';

import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../widgets/common/animated_button.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/pending_requests_section.dart';
import '../../../widgets/common/sticky_button.dart';
import '../../../widgets/common/sticky_note.dart';
import '../../../widgets/shopping/product_selection_bottom_sheet.dart';
import '../../../widgets/shopping/add_edit_product_dialog.dart';
import '../../../widgets/shopping/add_edit_task_dialog.dart';
import '../../../services/pending_requests_service.dart';
import '../../settings/manage_users_screen.dart';
import '../../sharing/pending_requests_screen.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  final ShoppingList list;

  const ShoppingListDetailsScreen({super.key, required this.list});

  @override
  State<ShoppingListDetailsScreen> createState() => _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> with TickerProviderStateMixin {
  // 🔍 חיפוש וסינון
  String _searchQuery = '';
  final bool _groupByCategory = false;
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
    _checkEditorNotifications();
  }

  /// 🔔 A1a: בדיקת בקשות Editor שאושרו/נדחו לאחרונה
  Future<void> _checkEditorNotifications() async {
    final provider = context.read<ShoppingListsProvider>();
    final userContext = context.read<UserContext>();
    final requestsService = PendingRequestsService(provider.repository, userContext);

    final currentUserId = userContext.userId;
    if (currentUserId == null) return;

    // בדיקה אם המשתמש הוא Editor (לא Owner/Admin)
    if (widget.list.canCurrentUserManage) {
      // Owner/Admin - אין צורך בהודעה
      return;
    }

    // שליפת בקשות של המשתמש
    final myRequests = requestsService.getRequestsByUser(widget.list, currentUserId);

    // סינון: רק בקשות שאושרו/נדחו ב-24 שעות האחרונות
    final now = DateTime.now();
    final recentApproved = myRequests.where((r) {
      if (!r.isApproved && !r.isRejected) return false;
      final reviewedAt = r.reviewedAt;
      if (reviewedAt == null) return false;
      return now.difference(reviewedAt).inHours <= 24;
    }).toList();

    if (recentApproved.isEmpty) return;

    // הודעה למשתמש
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final approved = recentApproved.where((r) => r.isApproved).length;
      final rejected = recentApproved.where((r) => r.isRejected).length;

      String message;
      if (approved > 0 && rejected > 0) {
        message = '✅ $approved בקשות אושרו | ❌ $rejected נדחו';
      } else if (approved > 0) {
        message = '✅ $approved מהבקשות שלך אושרו!';
      } else {
        message = '❌ $rejected מהבקשות שלך נדחו';
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 5),
            backgroundColor: approved > 0 ? Colors.green.shade700 : Colors.orange.shade700,
          ),
        );
      }
    }
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

  /// === מחיקת פריט עם אנימציה ===
  void _deleteItem(BuildContext context, UnifiedListItem removed) {
    final provider = context.read<ShoppingListsProvider>();

    // מצא את האינדקס המקורי ברשימה (לא אחרי סינון)
    final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id);
    final originalIndex = currentList.items.indexWhere((item) => item.id == removed.id);

    if (originalIndex == -1) {
      debugPrint('❌ ShoppingListDetailsScreen: לא נמצא פריט עם id ${removed.id}');
      return;
    }

    provider.removeItemFromList(widget.list.id, originalIndex);

    debugPrint('🗑️ ShoppingListDetailsScreen: מחק מוצר "${removed.name ?? 'ללא שם'}" (index: $originalIndex)');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.listDetails.itemDeleted(removed.name ?? 'ללא שם')),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: AppStrings.common.cancel,
          textColor: Colors.white,
          onPressed: () {
            provider.addItemToList(widget.list.id, removed.name ?? '', removed.quantity ?? 1, removed.unit ?? 'יח\'');
            debugPrint('↩️ ShoppingListDetailsScreen: שחזר מוצר "${removed.name}"');
          },
        ),
      ),
    );
  }

  /// 🛒 הוספת מוצר חדש
  Future<void> _handleAddProduct() async {
    final provider = context.read<ShoppingListsProvider>();

    await showAddEditProductDialog(
      context,
      onSave: (item) {
        provider.addUnifiedItem(widget.list.id, item);
        debugPrint('✅ ShoppingListDetailsScreen: הוסף מוצר "${item.name}"');
      },
    );
  }

  /// ✏️ עריכת מוצר קיים
  Future<void> _handleEditProduct(UnifiedListItem item) async {
    final provider = context.read<ShoppingListsProvider>();

    await showAddEditProductDialog(
      context,
      item: item,
      onSave: (updatedItem) {
        final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id);
        final originalIndex = currentList.items.indexWhere((i) => i.id == item.id);

        if (originalIndex != -1) {
          provider.updateItemAt(widget.list.id, originalIndex, (_) => updatedItem);
          debugPrint('✅ ShoppingListDetailsScreen: עדכן מוצר "${updatedItem.name}" (index: $originalIndex)');
        }
      },
    );
  }

  /// 📋 הוספת משימה חדשה
  Future<void> _handleAddTask() async {
    final provider = context.read<ShoppingListsProvider>();

    await showAddEditTaskDialog(
      context,
      onSave: (item) {
        provider.addUnifiedItem(widget.list.id, item);
        debugPrint('✅ ShoppingListDetailsScreen: הוסף משימה "${item.name}"');
      },
    );
  }

  /// ✏️ עריכת משימה קיימת
  Future<void> _handleEditTask(UnifiedListItem item) async {
    final provider = context.read<ShoppingListsProvider>();

    await showAddEditTaskDialog(
      context,
      item: item,
      onSave: (updatedItem) {
        final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id);
        final originalIndex = currentList.items.indexWhere((i) => i.id == item.id);

        if (originalIndex != -1) {
          provider.updateItemAt(widget.list.id, originalIndex, (_) => updatedItem);
          debugPrint('✅ ShoppingListDetailsScreen: עדכן משימה "${updatedItem.name}" (index: $originalIndex)');
        }
      },
    );
  }

  /// 🔍 סינון פריטים
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
        final itemCategory = item.category;

        // מוצרים ללא קטגוריה - מופיעים רק ב"אחר"
        if (itemCategory == null || itemCategory.isEmpty) {
          return _selectedCategory == AppStrings.listDetails.categoryOther;
        }

        // מיפוי בין קטגוריות UI לקטגוריות המוצרים
        final matches = _categoryMatches(_selectedCategory!, itemCategory);
        if (!matches) {
          return false;
        }
      }

      return true;
    }).toList();

    debugPrint('🔍 סינון: ${items.length} → ${filtered.length} פריטים (קטגוריה: "$_selectedCategory")');
    return filtered;
  }

  /// בדיקה אם קטגוריית מוצר תואמת לקטגוריית UI
  bool _categoryMatches(String uiCategory, String itemCategory) {
    // "ירקות ופירות" תואם גם "ירקות" וגם "פירות"
    if (uiCategory == AppStrings.listDetails.categoryVegetables) {
      return itemCategory == 'ירקות' || itemCategory == 'פירות';
    }

    // "בשר ודגים" תואם "בשר ודגים"
    if (uiCategory == AppStrings.listDetails.categoryMeat) {
      return itemCategory == 'בשר ודגים';
    }

    // "חלב וביצים" תואם "מוצרי חלב" או "חלב וביצים"
    if (uiCategory == AppStrings.listDetails.categoryDairy) {
      return itemCategory == 'מוצרי חלב' || itemCategory == 'חלב וביצים';
    }

    // "לחם ומאפים" תואם "מאפים" או "לחמים" או "לחם ומאפים"
    if (uiCategory == AppStrings.listDetails.categoryBakery) {
      return itemCategory == 'מאפים' || itemCategory == 'לחמים' || itemCategory == 'לחם ומאפים';
    }

    // "שימורים" תואם "שימורים"
    if (uiCategory == AppStrings.listDetails.categoryCanned) {
      return itemCategory == 'שימורים';
    }

    // "קפואים" תואם "קפואים"
    if (uiCategory == AppStrings.listDetails.categoryFrozen) {
      return itemCategory == 'קפואים';
    }

    // "ניקיון" תואם "מוצרי ניקיון" או "חומרי ניקיון"
    if (uiCategory == AppStrings.listDetails.categoryCleaning) {
      return itemCategory == 'מוצרי ניקיון' || itemCategory == 'חומרי ניקיון';
    }

    // "היגיינה" תואם "היגיינה אישית" או "היגיינה"
    if (uiCategory == AppStrings.listDetails.categoryHygiene) {
      return itemCategory == 'היגיינה אישית' || itemCategory == 'היגיינה';
    }

    // "אחר" תואם "אחר"
    if (uiCategory == AppStrings.listDetails.categoryOther) {
      return itemCategory == 'אחר';
    }

    // התאמה מדויקת אם לא נמצא מיפוי
    return uiCategory == itemCategory;
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
            // 🔔 Badge בקשות ממתינות
            if (currentList.pendingRequestsForReview.isNotEmpty && currentList.canCurrentUserApprove)
              ScaleTransition(
                scale: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      tooltip: 'בקשות ממתינות',
                      onPressed: () {
                        // ✨ Haptic feedback למשוב מישוש
                        unawaited(HapticFeedback.lightImpact());

                        final navigator = Navigator.of(context);
                        navigator.push(
                          MaterialPageRoute(builder: (context) => PendingRequestsScreen(list: currentList)),
                        );
                      },
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: kStickyPink, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${currentList.pendingRequestsForReview.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // כפתור שיתוף - 🔒 רק Owner/Admin
            if (currentList.canCurrentUserManage)
              ScaleTransition(
                scale: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)),
                child: IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: AppStrings.listDetails.shareListTooltip,
                  onPressed: () {
                    // ✨ Haptic feedback למשוב מישוש
                    unawaited(HapticFeedback.lightImpact());

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
                onPressed: () {
                  // ✨ Haptic feedback למשוב מישוש
                  unawaited(HapticFeedback.lightImpact());

                  _navigateToPopulateScreen();
                },
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
                  // ✨ Haptic feedback למשוב מישוש
                  unawaited(HapticFeedback.lightImpact());

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
                  PendingRequestsSection(
                    listId: currentList.id,
                    pendingRequests: currentList.pendingRequestsForReview,
                    canApprove: currentList.canCurrentUserApprove,
                  ),

                // 📋 תוכן
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(child: Text('שגיאה: $_errorMessage'))
                      : filteredItems.isEmpty && allItems.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('לא נמצאו פריטים'),
                              TextButton(
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                  debugPrint('🧹 ShoppingListDetailsScreen: ניקוי חיפוש מ-Empty Search');
                                },
                                child: const Text('נקה חיפוש'),
                              ),
                            ],
                          ),
                        )
                      : filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('הרשימה ריקה'),
                              TextButton(
                                onPressed: _navigateToPopulateScreen,
                                child: const Text('הוסף פריטים'),
                              ),
                            ],
                          ),
                        )
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
        floatingActionButton: currentList.canCurrentUserEdit
            ? ScaleTransition(
                scale: fabAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: kSpacingMedium, // שמאל המסך
                    bottom: kSpacingMedium,
                  ),
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
                            _handleAddTask();
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
                            _handleAddProduct();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null, // 🔒 Viewer/Editor אין רשאים להוסיף
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
                          // ✨ Haptic feedback למשוב מישוש
                          unawaited(HapticFeedback.lightImpact());

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

            // 📊 מונה פריטים
            if (allItems.isNotEmpty)
              AnimatedSwitcher(
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


  /// 📋 רשימה שטוחה (flat) עם Staggered Animation - מסונכרן עם שורות המחברת
  Widget _buildFlatList(List<UnifiedListItem> items, ThemeData theme) {
    final stickyColors = [kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan];

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: kNotebookLineSpacing - 8, // מעט לפני השורה הראשונה
        left: kNotebookRedLineOffset + kSpacingSmall, // אחרי הקו האדום
        right: kSpacingMedium,
        bottom: kSpacingMedium,
      ),
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
          child: _buildItemCard(item, originalIndex, theme, stickyColors[colorIndex], 0.0), // rotation = 0
        );
      },
    );
  }

  /// 🏷️ רשימה מקובצת לפי קטגוריה - מסונכרן עם שורות המחברת
  Widget _buildGroupedList(List<UnifiedListItem> items, ThemeData theme) {
    final grouped = _groupItemsByCategory(items);
    final categories = grouped.keys.toList()..sort();
    final stickyColors = [kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan];
    int globalIndex = 0;

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: kNotebookLineSpacing - 8, // מעט לפני השורה הראשונה
        left: kNotebookRedLineOffset + kSpacingSmall, // אחרי הקו האדום
        right: kSpacingMedium,
        bottom: kSpacingMedium,
      ),
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
                padding: const EdgeInsets.only(bottom: kNotebookLineSpacing),
                child: StickyNote(
                  color: kStickyPurple,
                  rotation: 0.0, // ישר כמו כתיבה במחברת
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
                return _buildItemCard(
                  item,
                  originalIndex,
                  theme,
                  stickyColors[colorIndex],
                  0.0, // rotation = 0
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// 🎴 כרטיס פריט מונפש - עם תמונה - ישירות על שורות המחברת (minimal)
  Widget _buildItemCard(UnifiedListItem item, int index, ThemeData theme, Color stickyColor, double rotation) {
    // 🎯 איקונים וצבעים לפי סוג
    final isProduct = item.type == ItemType.product;

    // קטגוריה עם אימוג'י
    final category = item.category ?? AppStrings.listDetails.categoryOther;

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
      onDismissed: (_) => _deleteItem(context, item),
      child: Container(
        height: kNotebookLineSpacing, // 40px = שורה אחת במחברת (סינכרון!)
        decoration: !isProduct
            ? BoxDecoration(
                color: kStickyPurple.withValues(alpha: 0.3), // רקע סגול בולט (כמו highlighter!)
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: Row(
          children: [
            // ✅ Checkbox - שמאל
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: AnimatedButton(
                onPressed: () {
                  final provider = context.read<ShoppingListsProvider>();
                  final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id);
                  final originalIndex = currentList.items.indexWhere((i) => i.id == item.id);

                  if (originalIndex != -1) {
                    provider.updateItemAt(
                      widget.list.id,
                      originalIndex,
                      (current) => current.copyWith(isChecked: !current.isChecked),
                    );
                  }
                },
                child: Icon(
                  item.isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                  key: ValueKey(item.isChecked),
                  color: item.isChecked ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(width: kSpacingSmall),

            // 📝 שם + קטגוריה - במרכז (פונט גדול ובולט)
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: theme.textTheme.bodyLarge!.copyWith(
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                  color: item.isChecked
                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // יישור לשמאל (לא צמוד ל-checkbox)
                  children: [
                    Flexible(
                      child: Text(
                        item.name ?? 'ללא שם',
                        maxLines: 1,
                        overflow: TextOverflow.clip, // חיתוך ללא נקודות
                        textAlign: TextAlign.start,
                      ),
                    ),
                    if (isProduct) ...[
                      const SizedBox(width: 8),
                      // 🔢 תג כמות מעוצב
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Text(
                          '×${item.quantity}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(width: kSpacingSmall),

            // 🖼️ תמונת מוצר - מוסתרת כרגע
            // Container(
            //   width: 48,
            //   height: 48,
            //   decoration: BoxDecoration(
            //     color: theme.colorScheme.surfaceContainerHighest,
            //     borderRadius: BorderRadius.circular(6),
            //     border: Border.all(
            //       color: theme.colorScheme.outline.withValues(alpha: 0.2),
            //       width: 1,
            //     ),
            //   ),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(5),
            //     child: item.imageUrl != null && item.imageUrl!.isNotEmpty
            //         ? Image.network(
            //             item.imageUrl!,
            //             fit: BoxFit.cover,
            //             errorBuilder: (_, __, ___) => Icon(
            //               isProduct ? Icons.shopping_bag : Icons.task_alt,
            //               size: 24,
            //               color: theme.colorScheme.onSurfaceVariant,
            //             ),
            //           )
            //         : Icon(
            //             isProduct ? Icons.shopping_bag : Icons.task_alt,
            //             size: 24,
            //             color: theme.colorScheme.onSurfaceVariant,
            //           ),
            //   ),
            // ),
            const SizedBox(width: kSpacingSmall),

            // ✏️ כפתור עריכה - צמוד למחיקה - 🔒 רק Owner/Admin/Editor
            if (widget.list.canCurrentUserEdit)
              Transform.translate(
                offset: const Offset(-56, 0), // צמוד למחיקה (אותו offset)
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: theme.colorScheme.primary,
                  tooltip: AppStrings.listDetails.editTooltip,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    if (isProduct) {
                      _handleEditProduct(item);
                    } else {
                      _handleEditTask(item);
                    }
                  },
                ),
              ),

            const SizedBox(width: kSpacingSmall),

            // 🗑️ כפתור מחיקה - ימין ממש (מעבר לפס האדום!) - 🔒 רק Owner/Admin
            if (widget.list.canCurrentUserManage)
              Transform.translate(
                offset: const Offset(-56, 0), // דוחף הרבה יותר ימינה (56px)
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: theme.colorScheme.error,
                  tooltip: AppStrings.listDetails.deleteTooltip,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => _deleteItem(context, item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
