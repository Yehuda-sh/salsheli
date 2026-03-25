// 📄 lib/screens/shopping/details/shopping_list_details_screen.dart
//
// מסך תכנון רשימת קניות — הוספת מוצרים מהירה לפני הקנייה.
// Version: 5.0 — Planning-first redesign
// Last Updated: 16/03/2026

import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../config/filters_config.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/enums/item_type.dart';
import '../../../models/enums/request_type.dart';
import '../../../models/shopping_list.dart';
import '../../../models/unified_list_item.dart';
import '../../../providers/products_provider.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/user_context.dart';
import '../../../repositories/shopping_lists_repository.dart';
import '../../../services/category_detection_service.dart';
import '../../../services/pending_requests_service.dart';
import '../../../services/shopping_patterns_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/barcode_helpers.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/painters/perforation_painter.dart';
import '../../../widgets/common/pending_requests_section.dart';
import '../../../widgets/shopping/add_edit_product_dialog.dart';
import '../../../widgets/shopping/add_edit_task_dialog.dart';
import '../../../widgets/shopping/product_selection_bottom_sheet.dart';
import '../../settings/manage_users_screen.dart';
import '../../sharing/pending_requests_screen.dart';
import '../active/active_shopping_screen.dart';
import '../checklist/checklist_screen.dart';
import '../who_brings/who_brings_screen.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  final ShoppingList list;

  const ShoppingListDetailsScreen({super.key, required this.list});

  @override
  State<ShoppingListDetailsScreen> createState() => _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Map<String, dynamic>> _searchResults = [];
  Timer? _searchDebounce;
  bool _isSearching = false;
  bool _editorNotificationsChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_editorNotificationsChecked) {
      _editorNotificationsChecked = true;
      _checkEditorNotifications();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ===== חיפוש בקטלוג =====

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      final provider = context.read<ProductsProvider>();
      final results = await provider.searchProducts(query.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  /// ניקוי שדה חיפוש
  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
  }

  /// 📷 סריקת ברקוד והוספה לרשימה
  Future<void> _scanBarcodeAndAdd(ShoppingList currentList) async {
    final productsProvider = context.read<ProductsProvider>();
    final product = await scanAndLookupProduct(context, productsProvider);
    if (product == null || !mounted) return;

    final name = product['name'] as String? ?? '';
    final category = product['category'] as String?;
    await _addProductToList(name: name, currentList: currentList, category: category);
  }

  /// הוספת מוצר (מקטלוג או חופשי) — מכבד הרשאות Editor
  Future<void> _addProductToList({
    required String name,
    required ShoppingList currentList,
    int quantity = 1,
    String? category,
  }) async {
    final provider = context.read<ShoppingListsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final cs = Theme.of(context).colorScheme;
    final successColor = Theme.of(context).extension<AppBrand>()?.success ?? kStickyGreen;
    final needsApproval = currentList.shouldCurrentUserRequest;

    try {
      if (needsApproval) {
        // 🔒 Editor — שלח בקשה לאישור
        final userContext = context.read<UserContext>();
        final repository = context.read<ShoppingListsRepository>();
        final service = PendingRequestsService(repository, userContext);
        await service.createRequest(
          list: currentList,
          type: RequestType.addItem,
          requestData: {
            'name': name,
            'quantity': quantity,
            'unit': AppStrings.pantry.unitAbbreviation,
            'category': category,
            'type': 'product',
          },
        );

        unawaited(HapticFeedback.lightImpact());
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(
          content: Row(children: [
            Icon(Icons.hourglass_empty, color: cs.onPrimary),
            const SizedBox(width: kSpacingSmall),
            Expanded(child: Text(AppStrings.sharing.requestCreated)),
          ]),
          backgroundColor: kStickyOrange,
        ));
      } else {
        // ✅ Owner/Admin — הוסף ישירות
        await provider.addItemToList(
          currentList.id,
          name,
          quantity,
          AppStrings.pantry.unitAbbreviation,
          category: category,
        );

        unawaited(HapticFeedback.mediumImpact());
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(
          content: Text(AppStrings.shopping.productAddedToList(name)),
          backgroundColor: successColor,
          duration: const Duration(seconds: 2),
        ));
      }

      _clearSearch();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(AppStrings.shopping.addProductError(e.toString())),
        backgroundColor: cs.error,
      ));
    }
  }

  /// הוספת מוצר מהקטלוג לרשימה
  Future<void> _quickAddProduct(Map<String, dynamic> product, ShoppingList currentList) async {
    final name = product['name']?.toString() ?? '?';
    final category = CategoryDetectionService.detectFromProductJson(product);
    await _addProductToList(name: name, currentList: currentList, category: category);
  }

  /// הוספת מוצר חופשי (לא מהקטלוג)
  Future<void> _addFreeTextProduct(String name, ShoppingList currentList) async {
    if (name.trim().isEmpty) return;
    await _addProductToList(name: name.trim(), currentList: currentList);
  }

  // ===== עריכה/מחיקה =====

  void _deleteItem(BuildContext context, UnifiedListItem removed, ShoppingList currentList) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<ShoppingListsProvider>();
    final originalIndex = currentList.items.indexWhere((item) => item.id == removed.id);
    if (originalIndex == -1) return;

    provider.removeItemFromList(currentList.id, originalIndex);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.listDetails.itemDeleted(removed.name)),
        duration: const Duration(seconds: 5),
        backgroundColor: cs.error,
        action: SnackBarAction(
          label: AppStrings.common.cancel,
          textColor: cs.onPrimary,
          onPressed: () {
            provider.addItemToList(currentList.id, removed.name, removed.quantity ?? 1, removed.unit);
          },
        ),
      ),
    );
  }

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

  Future<void> _handleAddTask(ShoppingList currentList) async {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<ShoppingListsProvider>();
    final userContext = context.read<UserContext>();
    final needsApproval = currentList.shouldCurrentUserRequest;

    await showAddEditTaskDialog(
      context,
      onSave: (item) async {
        if (needsApproval) {
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
                  content: Row(children: [
                    Icon(Icons.hourglass_empty, color: cs.onPrimary),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(child: Text(AppStrings.sharing.requestCreated)),
                  ]),
                  backgroundColor: kStickyOrange,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.common.unknownError(e.toString())), backgroundColor: cs.error),
              );
            }
          }
        } else {
          unawaited(provider.addUnifiedItem(currentList.id, item));
        }
      },
    );
  }

  Future<void> _navigateToPopulateScreen(ShoppingList currentList) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: cs.scrim.withValues(alpha: kDialogBarrierAlpha),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: kDialogBlurSigma, sigmaY: kDialogBlurSigma),
        child: ProductSelectionBottomSheet(list: currentList),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _startShopping(ShoppingList currentList) async {
    unawaited(HapticFeedback.mediumImpact());
    final Widget screen;
    if (currentList.type == ShoppingList.typeEvent &&
        currentList.eventMode == ShoppingList.eventModeWhoBrings) {
      screen = WhoBringsScreen(list: currentList);
    } else if (currentList.type == ShoppingList.typeEvent &&
        currentList.eventMode == ShoppingList.eventModeTasks) {
      screen = ChecklistScreen(list: currentList);
    } else {
      // מיון חכם לפי דפוס קנייה נלמד
      final patternsService = ShoppingPatternsService(
        firestore: FirebaseFirestore.instance,
        userContext: context.read<UserContext>(),
      );
      final sortedList = await patternsService.sortListByPattern(
        shoppingList: currentList,
      );
      screen = ActiveShoppingScreen(list: sortedList);
    }
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  /// 🔔 בדיקת בקשות Editor שאושרו/נדחו
  Future<void> _checkEditorNotifications() async {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<ShoppingListsProvider>();
    final userContext = context.read<UserContext>();
    final requestsService = PendingRequestsService(provider.repository, userContext);

    final currentUserId = userContext.userId;
    if (currentUserId == null) return;
    if (widget.list.canCurrentUserManage) return;

    final myRequests = requestsService.getRequestsByUser(widget.list, currentUserId);
    final now = DateTime.now();
    final recentApproved = myRequests.where((r) {
      if (!r.isApproved && !r.isRejected) return false;
      final reviewedAt = r.reviewedAt;
      if (reviewedAt == null) return false;
      return now.difference(reviewedAt).inHours <= 24;
    }).toList();

    if (recentApproved.isEmpty) return;

    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final approved = recentApproved.where((r) => r.isApproved).length;
      final rejected = recentApproved.where((r) => r.isRejected).length;

      String message;
      if (approved > 0 && rejected > 0) {
        message = AppStrings.sharing.editorRequestsMixed(approved, rejected);
      } else if (approved > 0) {
        message = AppStrings.sharing.editorRequestsApproved(approved);
      } else {
        message = AppStrings.sharing.editorRequestsRejected(rejected);
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          backgroundColor: approved > 0 ? cs.primary : cs.tertiary,
        ));
      }
    }
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();
    final currentList = provider.lists.firstWhere((l) => l.id == widget.list.id, orElse: () => widget.list);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final canEdit = currentList.canCurrentUserEdit;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Stack(
        children: [
          const NotebookBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,

            // 🛒 כפתור "התחל קנייה"
            bottomNavigationBar: currentList.status == ShoppingList.statusActive && currentList.items.isNotEmpty
                ? SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FilledButton.icon(
                          onPressed: () => _startShopping(currentList),
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: Text(
                            AppStrings.shopping.startShoppingButton,
                            style: const TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: kSpacingMedium),
                            backgroundColor: cs.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,

            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'list_hero_${currentList.id}',
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: currentList.stickyColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      child: Center(
                        child: Text(currentList.typeEmoji, style: const TextStyle(fontSize: kFontSizeTitle)),
                      ),
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  // Highlighter effect — כאילו הודגש במרקר
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
                      decoration: BoxDecoration(
                        color: currentList.stickyColor.withValues(alpha: 0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          topRight: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(2),
                        ),
                      ),
                      child: Text(
                        currentList.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                // 🔔 בקשות ממתינות
                if (currentList.pendingRequestsForReview.isNotEmpty && currentList.canCurrentUserApprove)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        tooltip: AppStrings.listDetails.pendingRequestsTooltip,
                        onPressed: () {
                          unawaited(HapticFeedback.lightImpact());
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => PendingRequestsScreen(list: currentList)),
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
                            style: TextStyle(color: cs.onPrimary, fontSize: kFontSizeTiny, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                // שיתוף
                if (currentList.canCurrentUserManage)
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: AppStrings.listDetails.shareListTooltip,
                    onPressed: () {
                      unawaited(HapticFeedback.lightImpact());
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ManageUsersScreen(list: currentList)),
                      );
                    },
                  ),
                // סריקת ברקוד
                if (canEdit)
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: AppStrings.shopping.scanBarcode,
                    onPressed: () => _scanBarcodeAndAdd(currentList),
                  ),
                // קטלוג מלא
                if (canEdit)
                  IconButton(
                    icon: const Icon(Icons.library_add),
                    tooltip: AppStrings.listDetails.addFromCatalogTooltip,
                    onPressed: () {
                      unawaited(HapticFeedback.lightImpact());
                      _navigateToPopulateScreen(currentList);
                    },
                  ),
              ],
            ),

            body: SafeArea(
              child: Column(
                children: [
                  // 📝 בקשות ממתינות
                  if (currentList.pendingRequestsForReview.isNotEmpty && currentList.canCurrentUserApprove)
                    PendingRequestsSection(
                      listId: currentList.id,
                      pendingRequests: currentList.pendingRequestsForReview,
                      canApprove: currentList.canCurrentUserApprove,
                    ),

                  // 🔍 שורת חיפוש + הוספה מהירה
                  if (canEdit) _buildSearchSection(currentList, cs),

                  // 📊 סיכום רשימה
                  if (currentList.items.isNotEmpty)
                    _buildListSummary(currentList, cs),

                  // 📋 תוכן הרשימה
                  Expanded(
                    child: currentList.items.isEmpty
                        ? _buildEmptyState(cs, currentList)
                        : _buildItemsList(currentList, theme),
                  ),
                ],
              ),
            ),

            // FAB: הוספה — לחיצה קצרה = מוצר, ארוכה = משימה
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: canEdit
                ? Padding(
                    padding: EdgeInsets.only(bottom: currentList.status == ShoppingList.statusActive && currentList.items.isNotEmpty ? 60 : 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // משימה — FAB קטן
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kStickyCyan.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: FloatingActionButton.small(
                            heroTag: 'add_task_btn',
                            backgroundColor: kStickyCyan,
                            elevation: 0,
                            tooltip: AppStrings.listDetails.addTaskButton,
                            onPressed: () {
                              unawaited(HapticFeedback.lightImpact());
                              _handleAddTask(currentList);
                            },
                            child: Icon(Icons.assignment_add, color: cs.onSurface, size: kIconSizeMedium),
                          ),
                        ),
                        const SizedBox(height: kSpacingSmall),
                        // מוצר — FAB ראשי עם glow
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kStickyYellow.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FloatingActionButton(
                            heroTag: 'add_product_btn',
                            backgroundColor: kStickyYellow,
                            elevation: 0,
                            tooltip: AppStrings.listDetails.addProductButton,
                            onPressed: () {
                              unawaited(HapticFeedback.lightImpact());
                              _navigateToPopulateScreen(currentList);
                            },
                            child: Icon(Icons.add_shopping_cart, size: kIconSizeLarge, color: cs.onSurface),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  // ===== SEARCH SECTION =====

  Widget _buildSearchSection(ShoppingList currentList, ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // שורת חיפוש
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
              border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: AppStrings.listDetails.quickSearchHint,
                hintStyle: TextStyle(fontSize: kFontSizeMedium, color: cs.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search, size: kIconSizeMedium),
                suffixIcon: _searchController.text.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // כפתור הוספה חופשית (טקסט שהוקלד)
                          IconButton(
                            icon: Icon(Icons.add_circle, color: cs.primary, size: kIconSizeMedium),
                            tooltip: AppStrings.listDetails.addFreeText,
                            onPressed: () => _addFreeTextProduct(_searchController.text, currentList),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: kIconSizeSmall + 2),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                        ],
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _addFreeTextProduct(value, currentList);
                }
              },
            ),
          ),
        ),

        // 🔎 תוצאות חיפוש
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(kSpacingSmall),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_searchResults.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
              itemCount: _searchResults.length.clamp(0, 8),
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                final name = product['name']?.toString() ?? '?';
                final category = product['category']?.toString() ?? '';
                final emoji = FiltersConfig.getCategoryEmoji(
                  FiltersConfig.hebrewCategoryToEnglish(category),
                );
                final price = (product['price'] as num?)?.toDouble();

                // בדוק אם כבר ברשימה
                final isInList = currentList.items.any(
                  (item) => item.name.toLowerCase() == name.toLowerCase(),
                );

                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: Text(emoji, style: const TextStyle(fontSize: kFontSizeLarge)),
                  title: Text(name, style: const TextStyle(fontSize: kFontSizeMedium)),
                  subtitle: price != null && price > 0
                      ? Text('₪${price.toStringAsFixed(2)}', style: TextStyle(fontSize: kFontSizeSmall, color: cs.primary))
                      : null,
                  trailing: isInList
                      ? Icon(Icons.check_circle, color: cs.primary, size: kIconSizeMedium)
                      : IconButton(
                          icon: Icon(Icons.add_circle_outline, color: cs.primary),
                          onPressed: () => _quickAddProduct(product, currentList),
                        ),
                );
              },
            ),
          ),

        if (_searchResults.isNotEmpty || _isSearching)
          Divider(height: 1, color: cs.outline.withValues(alpha: 0.1)),
      ],
    );
  }

  // ===== LIST SUMMARY =====

  Widget _buildListSummary(ShoppingList currentList, ColorScheme cs) {
    final itemCount = currentList.items.length;
    final categoryCount = currentList.items
        .map((i) => i.category)
        .where((c) => c != null && c.isNotEmpty)
        .toSet()
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingTiny),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus - 2, vertical: kSpacingXTiny),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Text(
              AppStrings.listDetails.itemsCount(itemCount),
              style: TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.w600, color: cs.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          if (categoryCount > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus - 2, vertical: kSpacingXTiny),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              child: Text(
                AppStrings.listDetails.categoriesCount(categoryCount),
                style: TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.w600, color: cs.onTertiaryContainer),
              ),
            ),
          const Spacer(),
          // סיכום מחיר אם יש
          if (_totalEstimatedPrice(currentList) > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(30, 1),
                  painter: PerforationPainter(color: cs.outline.withValues(alpha: 0.3)),
                ),
                const SizedBox(width: kSpacingSmall),
                Text(
                  '₪${_totalEstimatedPrice(currentList).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  double _totalEstimatedPrice(ShoppingList list) {
    return list.items.fold(0.0, (sum, item) {
      final price = item.unitPrice ?? 0.0;
      final qty = item.quantity ?? 1;
      return sum + (price * qty);
    });
  }

  // ===== ITEMS LIST =====

  Widget _buildItemsList(ShoppingList currentList, ThemeData theme) {
    final items = currentList.items;
    final canManage = currentList.canCurrentUserManage;
    final canEdit = currentList.canCurrentUserEdit;

    // קיבוץ לפי קטגוריה אם מעל 3 פריטים
    if (items.length >= 3) {
      return _buildGroupedItems(items, currentList, theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: kSpacingSmall,
        left: kNotebookRedLineOffset + kSpacingSmall,
        right: kSpacingMedium,
        bottom: 100,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildPlanningCard(item, index, currentList, theme, canManage, canEdit);
      },
    );
  }

  Widget _buildGroupedItems(List<UnifiedListItem> items, ShoppingList currentList, ThemeData theme) {
    final cs = theme.colorScheme;
    final canManage = currentList.canCurrentUserManage;
    final canEdit = currentList.canCurrentUserEdit;

    final grouped = <String, List<UnifiedListItem>>{};
    for (final item in items) {
      final cat = (item.category != null && item.category!.trim().isNotEmpty)
          ? item.category!
          : AppStrings.listDetails.categoryOther;
      grouped.putIfAbsent(cat, () => []).add(item);
    }
    final categories = grouped.keys.toList()..sort();

    final highlightColors = [
      cs.tertiaryContainer.withValues(alpha: 0.3),
      cs.tertiary.withValues(alpha: 0.1),
      cs.primaryContainer.withValues(alpha: 0.3),
      cs.primary.withValues(alpha: 0.1),
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: kSpacingSmall, bottom: 100),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        final categoryItems = grouped[category]!;
        final highlightColor = highlightColors[catIndex % highlightColors.length];
        final emoji = FiltersConfig.getCategoryEmoji(
          FiltersConfig.hebrewCategoryToEnglish(category),
        );

        final allChecked = categoryItems.every((i) => i.isChecked);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת קטגוריה — מרקר
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(right: kSpacingMedium, top: 4, bottom: 4),
              margin: const EdgeInsets.only(top: kSpacingMedium),
              decoration: BoxDecoration(
                color: allChecked ? kStickyGreen.withValues(alpha: 0.1) : highlightColor,
                border: BorderDirectional(start: BorderSide(color: highlightColors[catIndex % highlightColors.length], width: 4)),
              ),
              child: Row(
                children: [
                  SizedBox(width: kNotebookRedLineOffset),
                  Text(
                    '$emoji $category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: kFontSizeBody,
                      color: allChecked ? cs.onSurface.withValues(alpha: 0.5) : null,
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  // ✅ badge או count
                  if (allChecked)
                    Icon(Icons.check_circle, size: kIconSizeSmall, color: kStickyGreen)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      child: Text('${categoryItems.length}', style: const TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            // פריטים עם side strip + opacity
            ...categoryItems.map((item) {
              final originalIndex = currentList.items.indexOf(item);
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: item.isChecked ? 0.5 : 1.0,
                child: Container(
                  margin: EdgeInsets.only(left: kNotebookRedLineOffset + kSpacingSmall, right: kSpacingMedium),
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      start: BorderSide(
                        color: highlightColors[catIndex % highlightColors.length],
                        width: 3,
                      ),
                    ),
                  ),
                  child: _buildPlanningCard(item, originalIndex, currentList, theme, canManage, canEdit),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  /// 🎴 כרטיס תכנון — ללא checkbox, עם כמות ומחיר
  Widget _buildPlanningCard(
    UnifiedListItem item,
    int index,
    ShoppingList currentList,
    ThemeData theme,
    bool canManage,
    bool canEdit,
  ) {
    final cs = theme.colorScheme;
    final isProduct = item.type == ItemType.product;
    final emoji = isProduct
        ? FiltersConfig.getCategoryEmoji(FiltersConfig.hebrewCategoryToEnglish(item.category ?? ''))
        : '📋';

    return Dismissible(
      key: Key(item.id),
      direction: canManage ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: kSpacingLarge),
        color: cs.error.withValues(alpha: 0.7),
        child: Row(children: [
          Icon(Icons.delete_outline, color: cs.onPrimary),
          const SizedBox(width: kSpacingSmall),
          Text(AppStrings.common.delete, style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
        ]),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppStrings.listDetails.deleteTitle),
            content: Text(AppStrings.listDetails.deleteMessage(item.name)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.common.cancel)),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onPrimary),
                child: Text(AppStrings.common.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteItem(context, item, currentList),
      child: Card(
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: cs.surface.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
        child: InkWell(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          onTap: canEdit
              ? () => isProduct ? _handleEditProduct(item) : _handleEditTask(item)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingSmallPlus),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: kFontSizeTitle)),
                  const SizedBox(width: kSpacingSmall),
                  // שם + הערות + כמות/מחיר (2 שורות)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontSize: kFontSizeBody,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // שורת meta: כמות + מחיר + הערה
                        if (isProduct || (item.notes != null && item.notes!.isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.only(top: kSpacingXTiny),
                            child: Row(
                              children: [
                                if (isProduct)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: cs.primaryContainer.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                                    ),
                                    child: Text(
                                      '${item.quantity ?? 1} ${item.unit ?? "יח\'"}',
                                      style: TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.bold, color: cs.onPrimaryContainer),
                                    ),
                                  ),
                                if (isProduct && item.unitPrice != null && item.unitPrice! > 0) ...[
                                  const SizedBox(width: kSpacingSmall),
                                  Text(
                                    '₪${item.unitPrice!.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.w600, color: cs.primary),
                                  ),
                                ],
                                if (item.notes != null && item.notes!.isNotEmpty) ...[
                                  const SizedBox(width: kSpacingSmall),
                                  Expanded(
                                    child: Text(
                                      '✏️ ${item.notes!}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                                        fontSize: kFontSizeTiny,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // עריכה
                  if (canEdit)
                    Icon(Icons.chevron_left, color: cs.onSurfaceVariant.withValues(alpha: 0.4), size: kIconSizeMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== EMPTY STATE =====

  Widget _buildEmptyState(ColorScheme cs, ShoppingList currentList) {
    final canEdit = currentList.canCurrentUserEdit;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, color: cs.onSurfaceVariant, size: kIconSizeXXLarge),
            const SizedBox(height: kSpacingMedium),
            Text(
              AppStrings.listDetails.emptyListTitle,
              style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              AppStrings.listDetails.emptyListSubtitle,
              style: TextStyle(fontSize: kFontSizeBody, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (canEdit) ...[
              const SizedBox(height: kSpacingLarge),
              FilledButton.icon(
                onPressed: () => _navigateToPopulateScreen(currentList),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(AppStrings.listDetails.populateFromCatalog),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
