// 📄 File: lib/screens/shopping/shopping_list_details_screen.dart
// 📦 Helper File: shopping_list_details_screen_ux.dart (skeleton & states)
//
// Version 4.0 - Hybrid: NotebookBackground + AppBar
// Last Updated: 13/01/2026
//
// ✨ שיפורים חדשים (v3.2):
// 1. 🎨 No AppBar - Immersive design with inline title
// 2. 💀 Skeleton Screen: הועבר לקובץ _ux נפרד (1258 → 1088 שורות)
// 3. 🎬 Staggered Animations: פריטים מופיעים אחד אחד
// 4. 🎯 Micro Animations: כל כפתור מגיב ללחיצה
// 5. 🎨 Empty/Error States: הועברו לקובץ _ux
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

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/enums/item_type.dart';
import '../../../models/enums/request_type.dart';
import '../../../models/shopping_list.dart';
import '../../../models/unified_list_item.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/user_context.dart';
import '../../../repositories/shopping_lists_repository.dart';
import '../../../services/pending_requests_service.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/pending_requests_section.dart';
import '../../../widgets/shopping/add_edit_product_dialog.dart';
import '../../../widgets/shopping/add_edit_task_dialog.dart';
import '../../../widgets/shopping/product_selection_bottom_sheet.dart';
import '../../settings/manage_users_screen.dart';
import '../../sharing/pending_requests_screen.dart';
import '../../../config/filters_config.dart';
import '../active/active_shopping_screen.dart';
import '../checklist/checklist_screen.dart';
import '../who_brings/who_brings_screen.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  final ShoppingList list;

  const ShoppingListDetailsScreen({super.key, required this.list});

  @override
  State<ShoppingListDetailsScreen> createState() => _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> with TickerProviderStateMixin {
  // 🔍 חיפוש וסינון
  String _searchQuery = '';
  String? _selectedCategory; // קטגוריה נבחרת לסינון

  // 📦 Memoization - מונע חישוב סינון מיותר בכל build
  List<UnifiedListItem>? _cachedFilteredItems;
  String? _lastSearchQuery;
  String? _lastSelectedCategory;
  int _lastItemsCount = -1;
  // 🔧 FIX: הוספת hash לזיהוי שינויים בתוכן הפריטים (לא רק באורך)
  int _lastItemsHash = 0;

  // 🏷️ קטגוריות דינמיות - נגזרות מהפריטים ברשימה
  // 🔧 FIX: קבלת list כפרמטר במקום widget.list
  List<String> _getAvailableCategories(ShoppingList list) {
    final categories = list.items
        .map((item) => item.category)
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  /// 🎯 אימוג'י לפי קטגוריה - תואם לקטלוג המוצרים
  /// 🔧 FIX: קבלת listType כפרמטר במקום widget.list.type
  String _getCategoryEmoji(String category, String listType) {
    final englishKey = hebrewCategoryToEnglish(category);
    return getCategoryEmoji(englishKey ?? category);
  }

  // 🎬 Animation Controllers
  late AnimationController _fabController;
  late AnimationController _listController;

  // 📊 State Management
  bool _isLoading = true;
  String? _errorMessage;

  // 🎬 דגל למניעת אנימציות חוזרות אחרי הטעינה הראשונית
  bool _animationsDone = false;

  @override
  void initState() {
    super.initState();

    // 🎬 Initialize Animation Controllers
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    // 🚀 Start animations
    _fabController.forward();
    _loadData();
    _checkEditorNotifications();
  }

  @override
  void didUpdateWidget(ShoppingListDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 📦 ניקוי cache כאשר הרשימה משתנה
    // 🔧 FIX: נקה cache גם כשהתוכן משתנה (לא רק אורך) - שימוש ב-updatedDate
    if (widget.list.id != oldWidget.list.id ||
        widget.list.items.length != oldWidget.list.items.length ||
        widget.list.updatedDate != oldWidget.list.updatedDate) {
      _cachedFilteredItems = null;
    }
  }

  /// 🔔 A1a: בדיקת בקשות Editor שאושרו/נדחו לאחרונה
  Future<void> _checkEditorNotifications() async {
    final cs = Theme.of(context).colorScheme;
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

      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(seconds: 5),
            backgroundColor: approved > 0 ? cs.primary : cs.tertiary,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  /// 🛒 פתיחת Bottom Sheet לבחירת מוצרים
  /// 🔧 FIX: שימוש ב-currentList מה-provider במקום widget.list
  Future<void> _navigateToPopulateScreen() async {

    final provider = context.read<ShoppingListsProvider>();
    final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id, orElse: () => widget.list);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductSelectionBottomSheet(list: currentList),
    );

    // רענון הרשימה אחרי סגירה
    if (mounted) {
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
        unawaited(_listController.forward());

        // 🎬 סימון שהאנימציות הסתיימו אחרי זמן מספיק
        // מונע אנימציות חוזרות בעת checkbox/סינון/חיפוש
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && !_animationsDone) {
            setState(() => _animationsDone = true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppStrings.listDetails.loadingError;
        });
      }
    }
  }

  /// === מחיקת פריט עם אנימציה ===
  void _deleteItem(BuildContext context, UnifiedListItem removed) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<ShoppingListsProvider>();

    // מצא את האינדקס המקורי ברשימה (לא אחרי סינון)
    final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id);
    final originalIndex = currentList.items.indexWhere((item) => item.id == removed.id);

    if (originalIndex == -1) {
      return;
    }

    provider.removeItemFromList(widget.list.id, originalIndex);


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.listDetails.itemDeleted(removed.name)),
        duration: Duration(seconds: 5),
        backgroundColor: cs.error,
        action: SnackBarAction(
          label: AppStrings.common.cancel,
          textColor: cs.onPrimary,
          onPressed: () {
            provider.addItemToList(widget.list.id, removed.name, removed.quantity ?? 1, removed.unit);
          },
        ),
      ),
    );
  }

  /// 🛒 הוספת מוצר חדש - פותח את הקטלוג
  Future<void> _handleAddProduct() async {
    await _navigateToPopulateScreen();
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
        }
      },
    );
  }

  /// 📋 הוספת משימה חדשה
  Future<void> _handleAddTask() async {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<ShoppingListsProvider>();
    final userContext = context.read<UserContext>();
    final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id);

    // 🔒 בדיקה: האם המשתמש הוא Editor (צריך לשלוח בקשה)?
    final isEditor = currentList.currentUserRole?.canRequest == true;

    await showAddEditTaskDialog(
      context,
      onSave: (item) async {
        if (isEditor) {
          // 📝 Editor - שלח בקשה לאישור
          try {
            final repository = context.read<ShoppingListsRepository>();
            final service = PendingRequestsService(repository, userContext);
            await service.createRequest(
              list: currentList,
              type: RequestType.addItem,
              requestData: {
                'name': item.name,
                'quantity': item.quantity ?? 1,
                'notes': item.notes,
                'type': 'task',
              },
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: cs.onPrimary),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(child: Text(AppStrings.sharing.requestCreated)),
                    ],
                  ),
                  backgroundColor: kStickyOrange,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('שגיאה: $e'), backgroundColor: cs.error),
              );
            }
          }
        } else {
          // ✅ Owner/Admin - הוסף ישירות
          unawaited(provider.addUnifiedItem(widget.list.id, item));
        }
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
        }
      },
    );
  }

  /// 🔍 סינון פריטים - דינמי לפי קטגוריות הפריטים בפועל
  List<UnifiedListItem> _getFilteredAndSortedItems(List<UnifiedListItem> items) {
    // 🔧 FIX: חישוב hash של תוכן הפריטים לזיהוי שינויים
    final itemsHash = Object.hashAll(items.map((i) => Object.hash(i.id, i.name, i.category, i.isChecked)));

    // 📦 Memoization - החזר cache אם לא השתנה כלום (כולל תוכן!)
    if (_cachedFilteredItems != null &&
        _lastSearchQuery == _searchQuery &&
        _lastSelectedCategory == _selectedCategory &&
        _lastItemsCount == items.length &&
        _lastItemsHash == itemsHash) {
      return _cachedFilteredItems!;
    }

    final filtered = items.where((item) {
      // סינון לפי חיפוש
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = item.name.toLowerCase();
        if (!name.contains(query)) return false;
      }

      // סינון לפי קטגוריה (דינמי - השוואה ישירה)
      if (_selectedCategory != null && _selectedCategory != AppStrings.listDetails.categoryAll) {
        final itemCategory = item.category;

        // מוצרים ללא קטגוריה - לא מתאימים לאף קטגוריה ספציפית
        if (itemCategory == null || itemCategory.isEmpty) {
          return false;
        }

        // השוואה ישירה - הקטגוריות עכשיו דינמיות ותואמות את המוצרים
        if (itemCategory != _selectedCategory) {
          return false;
        }
      }

      return true;
    }).toList();

    // 📦 עדכון cache (כולל hash לזיהוי שינויים בתוכן)
    _cachedFilteredItems = filtered;
    _lastSearchQuery = _searchQuery;
    _lastSelectedCategory = _selectedCategory;
    _lastItemsCount = items.length;
    _lastItemsHash = itemsHash;

    return filtered;
  }

  /// 🏷️ קיבוץ לפי קטגוריה (מתוקן - מונע כותרות ריקות)
  Map<String, List<UnifiedListItem>> _groupItemsByCategory(List<UnifiedListItem> items) {
    final grouped = <String, List<UnifiedListItem>>{};

    for (var item in items) {
      // בדיקה קפדנית: אם הקטגוריה היא null או ריקה (או רק רווחים) -> "אחר"
      String category = item.category ?? '';
      if (category.trim().isEmpty) {
        category = AppStrings.listDetails.categoryOther; // ברירת מחדל: "אחר"
      }

      grouped.putIfAbsent(category, () => []).add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();
    final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id, orElse: () => widget.list);

    final theme = Theme.of(context);
    final allItems = currentList.items;
    final filteredItems = _getFilteredAndSortedItems(allItems);

    final cs = theme.colorScheme;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Stack(
        children: [
          const NotebookBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            // 🛒 כפתור "התחל קנייה" בתחתית — רק לרשימות פעילות עם פריטים
            bottomNavigationBar: currentList.status == ShoppingList.statusActive && currentList.items.isNotEmpty
                ? SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
                      child: FilledButton.icon(
                        onPressed: () {
                          unawaited(HapticFeedback.mediumImpact());
                          final Widget screen;
                          if (currentList.type == ShoppingList.typeEvent &&
                              currentList.eventMode == ShoppingList.eventModeWhoBrings) {
                            screen = WhoBringsScreen(list: currentList);
                          } else if (currentList.type == ShoppingList.typeEvent &&
                              currentList.eventMode == ShoppingList.eventModeTasks) {
                            screen = ChecklistScreen(list: currentList);
                          } else {
                            screen = ActiveShoppingScreen(list: currentList);
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
                        },
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: Text(
                          AppStrings.shopping.startShoppingButton,
                          style: const TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: kSpacingMedium),
                          backgroundColor: cs.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: currentList.canCurrentUserEdit
                ? Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // כפתור משני: הוסף משימה
                        FloatingActionButton.small(
                          heroTag: 'add_task_btn',
                          backgroundColor: kStickyCyan,
                          tooltip: AppStrings.listDetails.addTaskButton,
                          onPressed: _handleAddTask,
                          child: Icon(Icons.assignment_add, color: cs.onSurface),
                        ),
                        const SizedBox(height: 16),
                        // כפתור ראשי: הוסף מוצר (גדול יותר)
                        SizedBox(
                          height: 64,
                          width: 64,
                          child: FloatingActionButton(
                            heroTag: 'add_product_btn',
                            backgroundColor: kStickyYellow,
                            tooltip: AppStrings.listDetails.addProductButton,
                            elevation: 4,
                            onPressed: _handleAddProduct,
                            child: Icon(Icons.add_shopping_cart, size: 30, color: cs.onSurface),
                          ),
                        ),
                      ],
                    ),
                  )
                : null, // 🔒 Viewer בלבד אינו רשאי להוסיף (Editor יכול דרך בקשות)
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list_alt, size: 24, color: cs.primary),
                  const SizedBox(width: kSpacingSmall),
                  Flexible(
                    child: Text(
                      currentList.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                // 🔔 Badge בקשות ממתינות
                if (currentList.pendingRequestsForReview.isNotEmpty && currentList.canCurrentUserApprove)
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          tooltip: 'בקשות ממתינות',
                          onPressed: () {
                            unawaited(HapticFeedback.lightImpact());
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => PendingRequestsScreen(list: currentList)),
                            );
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: kStickyPink, shape: BoxShape.circle),
                            constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${currentList.pendingRequestsForReview.length}',
                              style: TextStyle(color: cs.onPrimary, fontSize: kFontSizeTiny, fontWeight: FontWeight.bold),
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
                    scale: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)),
                    child: IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: AppStrings.listDetails.shareListTooltip,
                      onPressed: () {
                        unawaited(HapticFeedback.lightImpact());
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ManageUsersScreen(list: currentList)),
                        );
                      },
                    ),
                  ),
                // כפתור הוספה מהקטלוג - 🔒 רק Owner/Admin/Editor
                if (currentList.canCurrentUserEdit)
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)),
                    child: IconButton(
                      icon: const Icon(Icons.library_add),
                      tooltip: AppStrings.listDetails.addFromCatalogTooltip,
                      onPressed: () {
                        unawaited(HapticFeedback.lightImpact());
                        _navigateToPopulateScreen();
                      },
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // 🔍 חיפוש וסינון
                  _buildFiltersSection(allItems, currentList),

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
                                Text(AppStrings.listDetails.noSearchResultsTitle),
                                TextButton(
                                  onPressed: () {
                                    setState(() => _searchQuery = '');
                                  },
                                  child: Text(AppStrings.listDetails.clearSearchButton),
                                ),
                              ],
                            ),
                          )
                        : filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppStrings.listDetails.emptyListTitle),
                                TextButton(
                                  onPressed: _navigateToPopulateScreen,
                                  child: Text(AppStrings.listDetails.populateFromCatalog),
                                ),
                              ],
                            ),
                          )
                        // 🏷️ קיבוץ אוטומטי מעל 10 פריטים
                        : filteredItems.length >= 10
                        ? _buildGroupedList(filteredItems, theme, currentList)
                        : _buildFlatList(filteredItems, theme, currentList),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 סעיף חיפוש וסינון - גרסה קומפקטית (חוסכת מקום!)
  /// 🔧 FIX: קבלת currentList כפרמטר במקום שימוש ב-widget.list
  Widget _buildFiltersSection(List<UnifiedListItem> allItems, ShoppingList currentList) {
    final cs = Theme.of(context).colorScheme;
    // אם אין פריטים בכלל, אין טעם להציג פילטרים
    if (allItems.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. שורת חיפוש (קומפקטית וצפה עם טשטוש רקע)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: kGlassBlurSigma, sigmaY: kGlassBlurSigma), // טשטוש הרקע
              child: Container(
                height: 48, // גובה קבוע וקטן יותר
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.6), // שקוף למחצה
                  borderRadius: BorderRadius.circular(kBorderRadiusXLarge), // עיגול מלא (Capsule)
                  boxShadow: [
                    BoxShadow(
                      color: cs.scrim.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: AppStrings.listDetails.searchHint,
                    hintStyle: const TextStyle(fontSize: kFontSizeMedium),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),
          ),
        ),

        // 2. רשימת קטגוריות נגללת אופקית (כמו ב-YouTube/Spotify)
        // מוצג לכל סוגי הרשימות (סופרמרקט, אטליז וכו') - רק אם יש קטגוריות
        if (_getAvailableCategories(currentList).isNotEmpty)
          SizedBox(
            height: 40, // גובה קבוע לשורת הקטגוריות
            child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
              children: _buildCategoryChipsCompact(currentList),
            ),
          ),

        // קו הפרדה עדין מהרשימה
        const SizedBox(height: kSpacingSmall),
      ],
    );
  }

  /// 🏷️ יצירת צ'יפים של קטגוריות (לגלילה אופקית) - דינמי!
  /// 🔧 FIX: קבלת currentList כפרמטר
  List<Widget> _buildCategoryChipsCompact(ShoppingList currentList) {
    final cs = Theme.of(context).colorScheme;
    final categories = _getAvailableCategories(currentList);

    // אם אין קטגוריות, לא מציגים כלום
    if (categories.isEmpty) return [];

    // יוצרים רשימה עם "הכל" בהתחלה + כל הקטגוריות
    final allCategories = [AppStrings.listDetails.categoryAll, ...categories];

    return allCategories.map((category) {
      final isAll = category == AppStrings.listDetails.categoryAll;
      final isSelected = _selectedCategory == category || (_selectedCategory == null && isAll);
      final emoji = isAll ? '📦' : _getCategoryEmoji(category, currentList.type);

      return Padding(
        padding: const EdgeInsets.only(left: 8.0), // ריווח בין צ'יפים
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: Duration(milliseconds: 150),
          child: FilterChip(
            showCheckmark: false, // חוסך מקום
            label: Text(
              '$emoji $category',
              style: TextStyle(
                fontSize: kFontSizeMedium,
                color: isSelected ? cs.onSurface : cs.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = isAll ? null : category;
              });
            },
            backgroundColor: cs.surface.withValues(alpha: 0.8),
            selectedColor: kStickyCyan, // צבע המותג (תכלת) להדגשה
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              side: BorderSide(
                color: isSelected ? cs.onSurface.withValues(alpha: 0.12) : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact, // מצמצם רווחים פנימיים
          ),
        ),
      );
    }).toList();
  }


  /// 📋 רשימה שטוחה (flat) עם Staggered Animation - מסונכרן עם שורות המחברת
  /// 🔧 FIX: קבלת currentList כפרמטר
  Widget _buildFlatList(List<UnifiedListItem> items, ThemeData theme, ShoppingList currentList) {
    // 🎬 הגבלת אנימציות - רק 8 פריטים ראשונים ורק בטעינה ראשונית
    const maxAnimatedItems = 8;

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
        final originalIndex = currentList.items.indexOf(item);

        final cardWidget = _buildItemCard(
          item,
          originalIndex,
          theme,
          currentList,
        );

        // 🎬 אנימציה רק בטעינה ראשונית ורק לפריטים הראשונים
        if (!_animationsDone && index < maxAnimatedItems) {
          return TweenAnimationBuilder<double>(
            key: ValueKey('anim_${item.id}'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset((1 - value) * 50, 0),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: cardWidget,
          );
        }

        return cardWidget;
      },
    );
  }

  /// 🏷️ רשימה מקובצת - עיצוב "מרקר" (Highlighter) רחב
  /// 🔧 FIX: קבלת currentList כפרמטר
  Widget _buildGroupedList(List<UnifiedListItem> items, ThemeData theme, ShoppingList currentList) {
    final cs = Theme.of(context).colorScheme;
    final grouped = _groupItemsByCategory(items);
    final categories = grouped.keys.toList()..sort();

    // צבעים עדינים למרקרים
    final highlightColors = [
      cs.tertiaryContainer.withValues(alpha: 0.3),
      cs.tertiary.withValues(alpha: 0.1),
      cs.primaryContainer.withValues(alpha: 0.3),
      cs.primary.withValues(alpha: 0.1),
    ];

    return ListView.builder(
      // ריווח תחתון כדי שהכפתורים לא יסתירו את הסוף
      padding: const EdgeInsets.only(
        top: kNotebookLineSpacing,
        bottom: 100,
      ),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        final categoryItems = grouped[category]!;
        final highlightColor = highlightColors[catIndex % highlightColors.length];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === כותרת סקשן (עיצוב מרקר רחב) ===
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 8,
              ),
              child: Container(
                width: double.infinity, // לוקח את כל הרוחב
                padding: const EdgeInsets.only(
                  right: kSpacingMedium, // ריווח מימין לטקסט
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color: highlightColor, // רקע שקוף "מרקר"
                  border: Border(
                    // פס דק בצד ימין לחיזוק
                    right: BorderSide(color: cs.onSurface.withValues(alpha: 0.12), width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    // רווח קטן מההתחלה
                    SizedBox(width: kNotebookRedLineOffset),

                    Text(
                      '${_getCategoryEmoji(category, currentList.type)} $category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        fontSize: kFontSizeBody,
                      ),
                    ),
                    SizedBox(width: 8),
                    // עיגול קטן עם המספר
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      child: Text(
                        '${categoryItems.length}',
                        style: const TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // === פריטים בקטגוריה ===
            ...categoryItems.map((item) {
              final originalIndex = currentList.items.indexOf(item);
              return _buildItemCard(
                item,
                originalIndex,
                theme,
                currentList,
              );
            }),
          ],
        );
      },
    );
  }

  /// 🎴 כרטיס פריט נקי - ללא כפתורי רעש (Swipe למחיקה, Tap לעריכה)
  /// 🔧 FIX: קבלת currentList כפרמטר + הסרת פרמטרים שלא בשימוש (stickyColor, rotation)
  Widget _buildItemCard(UnifiedListItem item, int index, ThemeData theme, ShoppingList currentList) {
    final cs = Theme.of(context).colorScheme;
    final isProduct = item.type == ItemType.product;
    final canManage = currentList.canCurrentUserManage; // Owner/Admin
    final canEdit = currentList.canCurrentUserEdit; // Owner/Admin/Editor

    return Dismissible(
      key: Key(item.id),
      direction: canManage ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: kSpacingLarge),
        color: cs.error.withValues(alpha: 0.7),
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: cs.onPrimary),
            SizedBox(width: 8),
            Text(AppStrings.common.delete, style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.listDetails.deleteTitle),
            content: Text(AppStrings.listDetails.deleteMessage(item.name)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.common.cancel)),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onPrimary),
                child: Text(AppStrings.common.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteItem(context, item),
      child: SizedBox(
        height: kNotebookLineSpacing,
        child: Row(
          children: [
            // רווח התחלתי
            const SizedBox(width: kSpacingMedium),

            // ✅ Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: item.isChecked,
                shape: const CircleBorder(),
                activeColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.onSurfaceVariant, width: 2),
                onChanged: (val) {
                  // 🔧 FIX: שימוש ב-currentList שהתקבל כפרמטר
                  final provider = context.read<ShoppingListsProvider>();
                  final originalIndex = currentList.items.indexWhere((i) => i.id == item.id);
                  if (originalIndex != -1) {
                    provider.updateItemAt(currentList.id, originalIndex, (c) => c.copyWith(isChecked: val));
                  }
                },
              ),
            ),

            const SizedBox(width: kSpacingMedium),

            // 📝 שם המוצר + כמות (לחיץ לעריכה!)
            Expanded(
              child: InkWell(
                onTap: canEdit
                    ? () {
                        if (isProduct) {
                          _handleEditProduct(item);
                        } else {
                          _handleEditTask(item);
                        }
                      }
                    : null,
                child: Row(
                  children: [
                    // כמות (Badge) - רק אם יותר מ-1
                    if ((item.quantity ?? 1) > 1) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],

                    // שם המוצר
                    Flexible(
                      child: Text(
                        item.name,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          color: item.isChecked ? cs.outline : cs.onSurface,
                          fontSize: kFontSizeBody,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
