// 📄 File: lib/screens/pantry/my_pantry_screen.dart
//
// 🎯 מטרה: מסך ניהול מזווה - ניהול פריטי מלאי לפי מיקומים
//
// 📋 כולל:
// - תצוגת פריטים לפי מיקומי אחסון
// - חיפוש וסינון (Frosted Glass design)
// - CRUD מלא: הוספה, עריכה, מחיקה, עדכון כמות
// - עיצוב "Clean Notebook" - תואם ל-ShoppingListDetailsScreen
// - ללא AppBar - כותרת inline עם SafeArea
//
// ✨ Features:
// - שילוב Collaborative Avatars ב-Header
// - מערכת חיווי חזותי מבוססת LimitStatus
// - משוב Haptic דינמי לניהול כמויות
// - אנימציות Pulse לפריטים קריטיים
//
// ✅ תיקונים:
//    - _isProcessing flag למניעת double-tap
//    - Debounce לחיפוש (300ms)
//    - Dark Mode - צבעים מה-Theme
//    - Semantics לנגישות
//    - Error state עם Retry
//
// 🔗 Dependencies:
// - InventoryProvider: ניהול state
// - StorageLocationsConfig: תצורת מיקומים
// - LocationsProvider: מיקומים מותאמים
// - UserContext: אווטארים שיתופיים
//
// Version: 6.1 - Design tokens compliance (hardcoded sizes → constants)
// Last Updated: 24/03/2026

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../config/filters_config.dart';
import '../../config/storage_locations_config.dart';
import '../../core/constants.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/locations_provider.dart';
import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../widgets/inventory/pantry_empty_state.dart';
import '../../widgets/inventory/pantry_item_dialog.dart';
import '../../widgets/inventory/pantry_product_selection_sheet.dart';
import '../../providers/products_provider.dart';
import '../../widgets/common/add_location_dialog.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../widgets/common/app_error_state.dart';
import '../../widgets/common/app_loading_skeleton.dart';
import '../../widgets/common/barcode_helpers.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/inventory/pantry_starter_preview_dialog.dart';
import '../../widgets/inventory/pantry_suggestions.dart';
import '../../services/notifications_service.dart';
import '../../services/template_service.dart';

class MyPantryScreen extends StatefulWidget {
  const MyPantryScreen({super.key});

  @override
  State<MyPantryScreen> createState() => _MyPantryScreenState();
}

class _MyPantryScreenState extends State<MyPantryScreen> {
  // 🔍 חיפוש וסינון
  String _searchQuery = '';
  String? _selectedLocation; // מיקום נבחר לסינון (null = הכל)

  // ⏱️ Debounce לחיפוש
  Timer? _searchDebounce;
  final _searchController = TextEditingController();
  static const _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InventoryProvider>().loadItems();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// 🔍 עדכון חיפוש עם debounce
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_debounceDuration, () {
      if (mounted) {
        setState(() => _searchQuery = value);
      }
    });
  }

  /// Backward compat: שמות עבריים ישנים → IDs חדשים
  static const _legacyLocationMap = {
    'מזווה': 'main_pantry', 'מקרר': 'refrigerator', 'מקפיא': 'freezer',
    'מטבח': 'kitchen', 'אמבטיה': 'bathroom', 'מחסן': 'storage',
    'מרפסת שירות': 'service_porch', 'כללי': 'other',
  };

  String _normalizeLocation(String loc) => _legacyLocationMap[loc] ?? loc;

  /// 🏷️ מיקומים דינמיים - נגזרים מהפריטים בפועל (עם נרמול legacy)
  List<String> _getAvailableLocations(List<InventoryItem> items) {
    final locations = items
        .map((item) => _normalizeLocation(item.location))
        .where((loc) => loc.isNotEmpty)
        .toSet()
        .toList();
    locations.sort();
    return locations;
  }

  /// 🎯 אימוג'י לפי מיקום אחסון
  String _getLocationEmoji(String locationKey) {
    // מיקומי ברירת מחדל
    if (StorageLocationsConfig.isValidLocation(locationKey)) {
      return StorageLocationsConfig.getLocationInfo(locationKey).emoji;
    }

    // מיקומים מותאמים
    final customLocations = context.read<LocationsProvider>().customLocations;
    final custom = customLocations.where((loc) => loc.key == locationKey).firstOrNull;
    if (custom != null) {
      return custom.emoji;
    }

    return '📍'; // ברירת מחדל
  }

  /// 🎯 שם מיקום בעברית
  String _getLocationName(String locationKey) {
    // מיקומי ברירת מחדל
    if (StorageLocationsConfig.isValidLocation(locationKey)) {
      return StorageLocationsConfig.getName(locationKey);
    }

    // מיקומים מותאמים
    final customLocations = context.read<LocationsProvider>().customLocations;
    final custom = customLocations.where((loc) => loc.key == locationKey).firstOrNull;
    if (custom != null) {
      return custom.name;
    }

    return locationKey; // fallback
  }

  /// 🔍 סינון פריטים
  List<InventoryItem> _getFilteredItems(List<InventoryItem> items) {
    final filtered = items.where((item) {
      // סינון לפי חיפוש
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = item.productName.toLowerCase();
        final category = item.category.toLowerCase();
        if (!name.contains(query) && !category.contains(query)) {
          return false;
        }
      }

      // סינון לפי מיקום (עם נרמול legacy)
      if (_selectedLocation != null) {
        if (_normalizeLocation(item.location) != _selectedLocation) {
          return false;
        }
      }

      return true;
    }).toList();

    // מיון לפי שם
    filtered.sort((a, b) => a.productName.compareTo(b.productName));

    return filtered;
  }

  /// 🏷️ קיבוץ לפי מיקום אחסון
  Map<String, List<InventoryItem>> _groupItemsByLocation(List<InventoryItem> items) {
    final grouped = <String, List<InventoryItem>>{};

    for (var item in items) {
      String location = _normalizeLocation(item.location);
      if (location.trim().isEmpty) {
        location = 'other'; // ברירת מחדל
      }
      grouped.putIfAbsent(location, () => []).add(item);
    }

    return grouped;
  }

  /// מציג bottom sheet לבחירת מוצר מהקטלוג
  void _addItemDialog() {
    PantryProductSelectionSheet.show(context);
  }

  /// 📷 סריקת ברקוד — בודק כפילויות ואז פותח pantry dialog
  Future<void> _scanBarcodeAndAddToPantry() async {
    final productsProvider = context.read<ProductsProvider>();
    final product = await scanAndLookupProduct(context, productsProvider);
    if (product == null || !mounted) return;

    final name = product['name'] as String? ?? '';
    final category = product['category'] as String?;

    // 🔍 בדיקת כפילויות — חיפוש מוצר דומה במזווה
    final inventoryProvider = context.read<InventoryProvider>();
    final similar = _findSimilarItem(name, inventoryProvider.items);

    if (similar != null && mounted) {
      final action = await _showDuplicateDialog(name, similar);
      if (!mounted) return;

      switch (action) {
        case _DuplicateAction.updateQuantity:
          // עדכון כמות +1, שם לא משתנה
          await inventoryProvider.addStock(similar.productName, 1);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${similar.productName} (+1) ✅'),
                duration: kSnackBarDuration,
              ),
            );
          }
          return;
        case _DuplicateAction.replaceProduct:
          // החלפת מוצר — כל הפרטים משתנים, כמות = 1
          final updatedItem = similar.copyWith(
            productName: name,
            category: category ?? similar.category,
            quantity: 1,
          );
          await inventoryProvider.updateItem(updatedItem);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${similar.productName} → $name'),
                duration: kSnackBarDuration,
              ),
            );
          }
          return;
        case _DuplicateAction.addSeparate:
          break; // ממשיך לפתיחת dialog רגיל
        case null:
          return; // ביטול
      }
    }

    if (!mounted) return;
    unawaited(showDialog(
      context: context,
      builder: (ctx) => PantryItemDialog(
        mode: PantryItemDialogMode.add,
        initialName: name,
        initialCategory: category,
      ),
    ));
  }

  /// 📷⬇️ סריקה מהירה להורדת מלאי — זרק אריזה? סרוק והמלאי יתעדכן
  Future<void> _quickScanToDecrement() async {
    final productsProvider = context.read<ProductsProvider>();
    final product = await scanAndLookupProduct(context, productsProvider);
    if (product == null || !mounted) return;

    final name = product['name'] as String? ?? '';
    final inventoryProvider = context.read<InventoryProvider>();
    final strings = AppStrings.inventory;

    // חפש במזווה
    final existingItem = inventoryProvider.items.where(
      (i) => i.productName.trim().toLowerCase() == name.trim().toLowerCase(),
    ).firstOrNull;

    // גם חיפוש fuzzy אם לא נמצא exact
    final matchedItem = existingItem ?? _findSimilarItem(name, inventoryProvider.items);

    if (matchedItem == null) {
      if (mounted) {
        unawaited(HapticFeedback.heavyImpact());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(strings.quickScanNotInPantry),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
      return;
    }

    // הורד 1 מהמלאי
    final updated = await inventoryProvider.removeStock(matchedItem.productName);
    if (!mounted || updated == null) return;

    unawaited(HapticFeedback.mediumImpact());

    if (updated.quantity == 0) {
      // 🔴 נגמר לגמרי
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(strings.quickScanOutOfStock(matchedItem.productName)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: strings.quickScanUndo,
          onPressed: () {
            inventoryProvider.addStock(matchedItem.productName, 1);
          },
        ),
      ));
    } else {
      // ✅ הורד בהצלחה
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(strings.quickScanDecremented(
          matchedItem.productName,
          updated.quantity,
        )),
        duration: kSnackBarDuration,
        action: SnackBarAction(
          label: strings.quickScanUndo,
          onPressed: () {
            inventoryProvider.addStock(matchedItem.productName, 1);
          },
        ),
      ));
    }
  }

  /// 🔍 מחפש מוצר דומה במזווה לפי מילות מפתח
  InventoryItem? _findSimilarItem(String scannedName, List<InventoryItem> items) {
    if (items.isEmpty) return null;

    final scannedLower = scannedName.toLowerCase();

    // 1. התאמה מדויקת
    final exact = items.where((i) => i.productName.trim().toLowerCase() == scannedLower.trim()).firstOrNull;
    if (exact != null) return exact;

    // 2. התאמת מילות מפתח (מינימום 2 מילים משותפות)
    final scannedWords = _significantWords(scannedLower);
    if (scannedWords.length < 2) return null;

    InventoryItem? bestMatch;
    int bestScore = 0;

    for (final item in items) {
      final itemWords = _significantWords(item.productName.toLowerCase());
      if (itemWords.length < 2) continue;

      // בדיקה: כל מילות הפריט הקיים מופיעות בשם הסרוק (או להיפך)
      final itemInScanned = itemWords.where((w) => scannedWords.contains(w)).length;
      final scannedInItem = scannedWords.where((w) => itemWords.contains(w)).length;

      // כל מילות הפריט הקצר חייבות להופיע בארוך
      final shorter = itemWords.length <= scannedWords.length ? itemWords : scannedWords;
      final longer = itemWords.length <= scannedWords.length ? scannedWords : itemWords;
      final allShorterInLonger = shorter.every((w) => longer.contains(w));

      if (allShorterInLonger && shorter.length >= 2) {
        final score = itemInScanned + scannedInItem;
        if (score > bestScore) {
          bestScore = score;
          bestMatch = item;
        }
      }
    }

    return bestMatch;
  }

  /// מילים משמעותיות (מסנן מספרים, יחידות מידה, גדלים)
  static final _ignoreWords = {'גרם', 'ג', 'קג', 'מל', 'ליטר', 'ל', 'יח', 'מ"ל', 'ק"ג'};
  List<String> _significantWords(String text) {
    return text
        .split(RegExp(r'[\s,.*+/]+'))
        .where((w) => w.length > 1)
        .where((w) => !_ignoreWords.contains(w))
        .where((w) => int.tryParse(w) == null) // מסנן מספרים
        .where((w) => !RegExp(r'^\d+[גקמל]$').hasMatch(w)) // 500ג, 1ק
        .toList();
  }

  /// 🔔 דיאלוג כפילויות
  Future<_DuplicateAction?> _showDuplicateDialog(String scannedName, InventoryItem existing) {
    return showDialog<_DuplicateAction>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications_outlined, color: cs.primary, size: kIconSizeMedium),
              const SizedBox(width: kSpacingXTiny),
              Expanded(
                child: Text(
                  AppStrings.pantry.similarProductFound,
                  style: const TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.pantry.existingInPantry}:',
                style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: kSpacingXTiny),
              Container(
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: cs.onSurfaceVariant, size: kIconSizeMedium),
                    const SizedBox(width: kSpacingXTiny),
                    Expanded(
                      child: Text(
                        '${existing.productName} (${existing.quantity} ${existing.unit})',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kSpacingSmallPlus),
              Text(
                '${AppStrings.pantry.scannedProduct}:',
                style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: kSpacingXTiny),
              Container(
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(Icons.photo_camera_outlined, color: cs.onSurfaceVariant, size: kIconSizeMedium),
                    const SizedBox(width: kSpacingXTiny),
                    Expanded(
                      child: Text(
                        scannedName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // עדכן כמות
            TextButton.icon(
              onPressed: () => Navigator.pop(ctx, _DuplicateAction.updateQuantity),
              icon: const Icon(Icons.add_circle_outline, size: kIconSizeSmallPlus),
              label: Text(AppStrings.pantry.updateQuantity),
            ),
            // החלף מוצר
            TextButton.icon(
              onPressed: () => Navigator.pop(ctx, _DuplicateAction.replaceProduct),
              icon: const Icon(Icons.swap_horiz, size: kIconSizeSmallPlus),
              label: Text(AppStrings.pantry.replaceProduct),
            ),
            // הוסף בנפרד
            TextButton.icon(
              onPressed: () => Navigator.pop(ctx, _DuplicateAction.addSeparate),
              icon: const Icon(Icons.add, size: kIconSizeSmallPlus),
              label: Text(AppStrings.pantry.addSeparately),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }

  /// 🏺 מוסיף פריטי starter למזווה (Onboarding)
  Future<void> _addStarterItems() async {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.pantry;

    try {
      // 1. טעינת פריטי starter מהתבנית
      final allItems = await TemplateService.loadPantryStarterItems();
      if (!mounted) return;

      if (allItems.isEmpty) {
        // fallback — אם אין פריטים, פתח קטלוג מסונן
        PantryProductSelectionSheet.show(
          context,
          initialCategories: PantryProductSelectionSheet.basicCategories,
        );
        return;
      }

      // 2. הצגת preview — המשתמש בוחר מה להוסיף
      final selectedItems = await showDialog<List<InventoryItem>>(
        context: context,
        builder: (context) => PantryStarterPreviewDialog(items: allItems),
      );

      if (!mounted) return;
      if (selectedItems == null || selectedItems.isEmpty) return;

      // 3. הוספה בבת אחת
      final provider = context.read<InventoryProvider>();
      final count = await provider.addStarterItems(selectedItems);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(strings.starterItemsAdded(count))),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(strings.starterItemsError)),
      );
    }
  }

  /// מציג דיאלוג לעריכת פרטי פריט קיים
  void _editItemDialog(InventoryItem item) {
    PantryItemDialog.showEditDialog(context, item);
  }

  /// מוחק פריט מהמזווה
  Future<void> _deleteItem(InventoryItem item) async {

    // ✅ Cache values before async gap
    final strings = AppStrings.pantry;
    final messenger = ScaffoldMessenger.of(context);
    final inventoryProvider = context.read<InventoryProvider>();

    try {
      await inventoryProvider.deleteItem(item.id);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(strings.itemDeleted(item.productName)),
            action: SnackBarAction(
              label: AppStrings.common.cancel,
              onPressed: () async {
                try {
                  await inventoryProvider.updateItem(item);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.inventory.updateError)),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(strings.deleteItemError)),
        );
      }
    }
  }

  /// מעדכן כמות פריט במזווה
  Future<void> _updateQuantity(InventoryItem item, int newQuantity) async {
    // ✅ Cache values before async gap
    final strings = AppStrings.pantry;
    final messenger = ScaffoldMessenger.of(context);
    final inventoryProvider = context.read<InventoryProvider>();


    // 📳 Haptic דינמי לפי כיוון
    if (newQuantity > item.quantity) {
      unawaited(HapticFeedback.lightImpact());
    } else if (newQuantity < item.quantity) {
      unawaited(HapticFeedback.mediumImpact());
    }

    try {
      final wasAboveMin = item.quantity > item.minQuantity;
      final willBeLow = newQuantity <= item.minQuantity;

      final updatedItem = item.copyWith(quantity: newQuantity);
      await inventoryProvider.updateItem(updatedItem);

      if (wasAboveMin && willBeLow && mounted) {
        await _sendLowStockNotification(updatedItem);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(strings.updateQuantityError)),
        );
      }
    }
  }

  /// שולח התראה על מלאי נמוך לחברי הבית
  Future<void> _sendLowStockNotification(InventoryItem item) async {
    final userContext = context.read<UserContext>();
    final householdId = userContext.householdId;
    final currentUserId = userContext.userId;
    if (householdId == null || currentUserId == null) return;

    final service = context.read<NotificationsService>();
    // שלח התראה לכל חברי הבית (חוץ מהמשתמש הנוכחי)
    // כרגע שולח רק למשתמש הנוכחי — כשיהיה FCM, זה ירחיב לכולם
    unawaited(service.createLowStockNotification(
      userId: currentUserId,
      householdId: householdId,
      productName: item.productName,
      currentStock: item.quantity,
      minStock: item.minQuantity,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final primaryColor = scheme.primaryContainer;
    // final backgroundColor = scheme.surface;

    final strings = AppStrings.pantry;

    return Stack(
      children: [
        const NotebookBackground(),
        Semantics(
      label: strings.screenLabel,
      container: true,
      child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            final allItems = provider.items;
            final filteredItems = _getFilteredItems(allItems);

            // ✅ Error state with Retry
            if (provider.hasError) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: AppErrorState(
                    title: strings.loadingErrorTitle,
                    message: provider.errorMessage ?? strings.loadingErrorDefault,
                    onAction: () => provider.loadItems(),
                    actionLabel: strings.retryButton,
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: Padding(
                padding: const EdgeInsetsDirectional.only(start: kSpacingMedium, bottom: kSpacingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 📷⬇️ סריקה מהירה להורדת מלאי
                    FloatingActionButton.small(
                      heroTag: 'pantry_quick_scan_btn',
                      onPressed: _quickScanToDecrement,
                      backgroundColor: scheme.errorContainer,
                      tooltip: AppStrings.inventory.quickScanTooltip,
                      child: Icon(Icons.remove_shopping_cart, color: scheme.onErrorContainer, size: kIconSizeSmallPlus),
                    ),
                    const SizedBox(height: kSpacingSmall),
                    // 📷⬆️ סריקת ברקוד להוספה
                    FloatingActionButton.small(
                      heroTag: 'pantry_scan_btn',
                      onPressed: _scanBarcodeAndAddToPantry,
                      backgroundColor: scheme.secondaryContainer,
                      tooltip: AppStrings.shopping.scanBarcode,
                      child: Icon(Icons.qr_code_scanner, color: scheme.onSecondaryContainer, size: kIconSizeSmallPlus),
                    ),
                    const SizedBox(height: kSpacingSmall),
                    // הוספה ידנית
                    Semantics(
                      button: true,
                      label: strings.addItemLabel,
                      child: FloatingActionButton(
                        heroTag: 'pantry_add_btn',
                        onPressed: _addItemDialog,
                        backgroundColor: primaryColor,
                        tooltip: strings.addItemTooltip,
                        child: Icon(Icons.add, color: scheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
              body: provider.isLoading
                  ? const SafeArea(
                      child: AppLoadingSkeleton(sectionCount: 5, showHero: false),
                    )
                  : allItems.isEmpty
                      ? SafeArea(
                          child: PantryEmptyState(
                            isGroupMode: context.read<UserContext>().householdId != null,
                            groupName: context.read<UserContext>().householdName,
                            onAddItem: _addItemDialog,
                            onAddStarterItems: _addStarterItems,
                          ),
                        )
                      : SafeArea(
                          child: Column(
                                children: [
                                  // 🏷️ כותרת המזווה (Collaborative Immersive)
                                  _buildInlineTitle(provider, scheme),

                                  // 📊 סיכום מזווה
                                  _buildSummaryStrip(allItems),

                                  // 💡 הצעות חכמות
                                  PantrySuggestions(
                                    currentItemCount: allItems.length,
                                    existingProductNames: allItems
                                        .map((i) => i.productName.toLowerCase())
                                        .toSet(),
                                    productsProvider: context.read<ProductsProvider>(),
                                    onAddItem: (name, category, qty, unit) async {
                                      final provider =
                                          context.read<InventoryProvider>();
                                      await provider.createItem(
                                        productName: name,
                                        quantity: qty.toInt(),
                                        unit: unit,
                                        category: category,
                                        location: StorageLocationsConfig.mainPantry,
                                      );
                                    },
                                  ),

                                  // 🔍 חיפוש וסינון
                                  _buildFiltersSection(allItems),

                                  // 📋 תוכן
                                  Expanded(
                                    child: filteredItems.isEmpty && allItems.isNotEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(strings.noItemsFound, style: TextStyle(color: scheme.onSurface)),
                                                TextButton(
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {
                                                      _searchQuery = '';
                                                      _selectedLocation = null;
                                                    });
                                                  },
                                                  child: Text(strings.clearFilters),
                                                ),
                                              ],
                                            ),
                                          )
                                        : filteredItems.length >= 5
                                            ? _buildGroupedList(filteredItems)
                                            : _buildFlatList(filteredItems),
                                  ),
                                ],
                              ),
                            ),
            );
          },
        ),
      ),
      ],
    );
  }

  /// 🏷️ כותרת המזווה - Collaborative Immersive (Glassmorphic + Avatars)
  Widget _buildInlineTitle(InventoryProvider provider, ColorScheme scheme) {
    final theme = Theme.of(context);
    final userContext = context.watch<UserContext>();
    final displayName = userContext.displayName ?? '';
    final initials = displayName.isNotEmpty
        ? displayName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .map((p) => p[0])
            .take(2)
            .join()
        : '?';

    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: kGlassBlurMedium, sigmaY: kGlassBlurMedium),
        child: Container(
          color: scheme.surface.withValues(alpha: 0.7),
          padding: const EdgeInsets.only(
            right: kSpacingMedium,
            left: kSpacingMedium,
            top: kSpacingSmall,
            bottom: kSpacingTiny,
          ),
          child: Row(
            children: [
              // 📦 Emoji in colored circle (like Dashboard)
              Container(
                width: kSpacingXLarge + kSpacingSmallPlus,
                height: kSpacingXLarge + kSpacingSmallPlus,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primaryContainer,
                ),
                child: Center(
                  child: Icon(Icons.inventory_2_outlined, color: scheme.primary, size: kIconSizeMedium),
                ),
              ),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.inventoryTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (provider.items.isNotEmpty)
                      Text(
                        // TODO(l10n): Extract to AppStrings.pantry.itemCountInPantry(count)
                        '${provider.items.length} ${AppStrings.settings.statsPantryItems}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),

              // 👤 Avatar with gradient ring (like Dashboard)
              if (displayName.isNotEmpty)
                Tooltip(
                  message: displayName,
                  child: Container(
                    width: kIconSizeLarge,
                    height: kIconSizeLarge,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [scheme.primary, scheme.tertiary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primaryContainer,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: kFontSizeTiny,
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📊 פס סיכום מזווה — פריטים, מלאי נמוך, מיקומים
  Widget _buildSummaryStrip(List<InventoryItem> items) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();

    final totalItems = items.length;
    final lowStockCount = items.where((i) => i.isLowStock).length;
    final locationsCount = items.map((i) => i.location).where((l) => l.isNotEmpty).toSet().length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      child: Row(
        children: [
          _buildSummaryChip(
            emoji: '📦',
            value: '$totalItems',
            label: AppStrings.pantry.tabItems,
            color: cs.primary,
            theme: theme,
          ),
          const SizedBox(width: kSpacingSmall),
          if (lowStockCount > 0) ...[
            _buildSummaryChip(
              emoji: '⚠️',
              value: '$lowStockCount',
              label: AppStrings.pantry.tabMissing,
              color: brand?.warning ?? cs.error,
              theme: theme,
            ),
            const SizedBox(width: kSpacingSmall),
          ],
          _buildSummaryChip(
            emoji: '📍',
            value: '$locationsCount',
            label: AppStrings.pantry.tabLocations,
            color: cs.tertiary,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required String emoji,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: kSpacingXTiny, horizontal: kSpacingSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kBorderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.04),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: kFontSizeBody)),
              const SizedBox(height: 1), // intentional 1px separator
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                  fontSize: kFontSizeTiny,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔍 סעיף חיפוש וסינון - Frosted Glass design
  Widget _buildFiltersSection(List<InventoryItem> allItems) {
    if (allItems.isEmpty) return const SizedBox.shrink();

    final availableLocations = _getAvailableLocations(allItems);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // ✅ Dark Mode colors - theme-aware
    final glassBgColor = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.8)
        : scheme.surface.withValues(alpha: 0.6);
    final shadowColor = isDark
        ? theme.shadowColor.withValues(alpha: 0.2)
        : theme.shadowColor.withValues(alpha: 0.05);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. שורת חיפוש (Frosted Glass)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: kGlassBlurSigma, sigmaY: kGlassBlurSigma),
              child: Container(
                height: kButtonHeight,
                decoration: BoxDecoration(
                  color: glassBgColor,
                  borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: AppStrings.pantry.searchHint,
                    hintStyle: const TextStyle(fontSize: kFontSizeMedium),
                    prefixIcon: const Icon(Icons.search, size: kIconSizeSmallPlus),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: kIconSizeSmallPlus),
                            tooltip: AppStrings.pantry.clearSearchTooltip,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                    isDense: true,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
          ),
        ),

        // 2. רשימת מיקומים נגללת אופקית
        if (availableLocations.isNotEmpty)
          SizedBox(
            height: kButtonHeightSmall + kSpacingXTiny,
            child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
              children: _buildLocationChips(availableLocations),
            ),
          ),

        const SizedBox(height: kSpacingSmall),
      ],
    );
  }

  /// 🏷️ יצירת צ'יפים של מיקומים
  List<Widget> _buildLocationChips(List<String> locations) {
    final allLocations = [null, ...locations]; // null = "הכל"
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // ✅ Dark Mode colors - theme-aware
    final chipBgColor = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.8)
        : scheme.surface.withValues(alpha: 0.8);
    final chipSelectedColor = scheme.primaryContainer;
    final textColor = scheme.onSurface;
    final textColorMuted = scheme.onSurfaceVariant;

    final chips = allLocations.map<Widget>((location) {
      final isAll = location == null;
      final isSelected = _selectedLocation == location;
      final emoji = isAll ? '🏪' : _getLocationEmoji(location);
      final name = isAll ? AppStrings.pantry.allLocations : _getLocationName(location);

      return Padding(
        padding: const EdgeInsets.only(left: kSpacingSmall),
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: FilterChip(
            showCheckmark: false,
            label: Text(
              '$emoji $name',
              style: TextStyle(
                fontSize: kFontSizeMedium,
                color: isSelected ? textColor : textColorMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              // 📳 Haptic בכל החלפת מיקום
              unawaited(HapticFeedback.selectionClick());
              setState(() {
                _selectedLocation = isAll ? null : location;
              });
            },
            backgroundColor: chipBgColor,
            selectedColor: chipSelectedColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              side: BorderSide(
                color: isSelected ? scheme.outline.withValues(alpha: 0.3) : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }).toList();

    // ➕ כפתור הוספת מיקום חדש (Shimmer כשיש מעט מיקומים)
    final showShimmer = locations.length <= 1;
    Widget addChip = Padding(
      padding: const EdgeInsets.only(left: kSpacingSmall),
      child: ActionChip(
        avatar: Icon(Icons.add_location_alt, size: kIconSizeSmallPlus, color: scheme.primary),
        label: Text(
          AppStrings.inventory.addLocationButton,
          style: TextStyle(fontSize: kFontSizeMedium, color: textColorMuted),
        ),
        onPressed: () async {
          final newKey = await showAddLocationDialog(context);
          if (newKey != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.inventory.locationAdded),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
          }
        },
        backgroundColor: chipBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          side: BorderSide(color: scheme.primary, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
        visualDensity: VisualDensity.compact,
      ),
    );

    if (showShimmer) {
      addChip = addChip
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 1800.ms,
            color: scheme.primary.withValues(alpha: 0.15),
          );
    }

    chips.add(addChip);

    return chips;
  }

  /// 📋 רשימה שטוחה (flutter_animate staggered)
  Widget _buildFlatList(List<InventoryItem> items) {
    return RepaintBoundary(
      child: ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          top: kSpacingSmall,
          left: kSpacingMedium,
          right: kSpacingMedium,
          bottom: 100, // FAB clearance — no exact design-token match
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return RepaintBoundary(
            child: _buildItemRow(item)
                .animate()
                .fadeIn(
                  duration: 350.ms,
                  delay: (index * 30).ms,
                  curve: Curves.easeOutQuart,
                )
                .slideX(
                  begin: 0.15,
                  duration: 350.ms,
                  delay: (index * 30).ms,
                  curve: Curves.easeOutQuart,
                ),
          );
        },
      ),
    );
  }

  /// 🏷️ רשימה מקובצת - עיצוב "מרקר" (Highlighter)
  Widget _buildGroupedList(List<InventoryItem> items) {
    final grouped = _groupItemsByLocation(items);
    final locations = grouped.keys.toList()..sort();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Dark Mode-aware highlight colors
    final highlightColors = isDark
        ? [
            scheme.primaryContainer.withValues(alpha: 0.15),
            scheme.secondaryContainer.withValues(alpha: 0.15),
            scheme.tertiaryContainer.withValues(alpha: 0.15),
            scheme.surfaceContainerHighest.withValues(alpha: 0.2),
          ]
        : [
            scheme.secondaryContainer.withValues(alpha: 0.3),
            scheme.tertiaryContainer.withValues(alpha: 0.3),
            scheme.tertiary.withValues(alpha: 0.1),
            scheme.primary.withValues(alpha: 0.1),
          ];

    // מונה גלובלי לאנימציות staggered
    int globalItemIndex = 0;

    return RepaintBoundary(
      child: ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          top: kSpacingSmall,
          left: kSpacingMedium,
          right: kSpacingMedium,
          bottom: 100, // FAB clearance — no exact design-token match
        ),
        itemCount: locations.length,
        itemBuilder: (context, locIndex) {
          final location = locations[locIndex];
          final locationItems = grouped[location]!;
          final highlightColor = highlightColors[locIndex % highlightColors.length];

          // ✅ רווח מותאם: סקשן ראשון ללא top, שאר הסקשנים עם top: 12
          final isFirstSection = locIndex == 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === כותרת סקשן (עיצוב מרקר רחב) ===
              Padding(
                padding: EdgeInsets.only(top: isFirstSection ? 0 : kSpacingSmallPlus, bottom: 2),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    right: kSpacingMedium,
                    top: kSpacingXTiny,
                    bottom: kSpacingXTiny,
                  ),
                  decoration: BoxDecoration(
                    color: highlightColor,
                    border: Border(
                      right: BorderSide(color: scheme.outline.withValues(alpha: 0.3), width: kSpacingXTiny),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_getLocationEmoji(location)} ${_getLocationName(location)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                              fontSize: kFontSizeBody,
                            ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.surfaceContainerHighest.withValues(alpha: 0.6)
                              : scheme.surface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: Text(
                          '${locationItems.length}',
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === פריטים במיקום (staggered animate) ===
              ...locationItems.map((item) {
                final itemIndex = globalItemIndex++;
                return RepaintBoundary(
                  child: _buildItemRow(item)
                      .animate()
                      .fadeIn(
                        duration: 350.ms,
                        delay: (itemIndex * 30).ms,
                        curve: Curves.easeOutQuart,
                      )
                      .slideX(
                        begin: 0.15,
                        duration: 350.ms,
                        delay: (itemIndex * 30).ms,
                        curve: Curves.easeOutQuart,
                      ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  /// 🎴 שורת פריט — Card מקצועי עם Swipe, Tap, וחיווי סטטוס
  Widget _buildItemRow(InventoryItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final strings = AppStrings.pantry;
    final isCritical = item.status == LimitStatus.critical || item.needsUrgentAttention;
    final isWarning = item.status == LimitStatus.warning || item.isLowStock;

    // 🎨 צבע פס צד לפי סטטוס (קריטי/אזהרה) או קטגוריה
    final Color statusColor;
    if (isCritical) {
      statusColor = cs.error;
    } else if (isWarning) {
      statusColor = brand?.warning ?? kStickyOrange;
    } else {
      statusColor = _getCategoryColor(item.category);
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: kSpacingLarge),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: cs.onErrorContainer),
            const SizedBox(width: kSpacingSmall),
            Text(strings.swipeDelete, style: TextStyle(color: cs.onErrorContainer, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.deleteDialogTitle),
            content: Text(strings.deleteDialogContent(item.productName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppStrings.common.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                ),
                child: Text(AppStrings.common.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteItem(item),
      child: Card(
        margin: const EdgeInsets.only(bottom: kSpacingTiny),
        elevation: isCritical ? 2 : 0.5,
        shadowColor: isCritical ? cs.error.withValues(alpha: 0.3) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          side: BorderSide(
            color: isWarning || isCritical
                ? statusColor.withValues(alpha: 0.3)
                : cs.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _editItemDialog(item),
          borderRadius: BorderRadius.circular(kBorderRadius),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 🎨 פס צד צבעוני (כמו ברשימות בדף הבית)
                Container(
                  width: kSpacingXTiny,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: isRtl
                        ? const BorderRadius.only(
                            topRight: Radius.circular(kBorderRadius),
                            bottomRight: Radius.circular(kBorderRadius),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(kBorderRadius),
                            bottomLeft: Radius.circular(kBorderRadius),
                          ),
                  ),
                ),

                // 📦 תוכן
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingSmall,
                      vertical: kSpacingSmall,
                    ),
                    child: Row(
                      children: [
                        // 🏷️ תמונת מוצר / אמוג'י בעיגול
                        _buildProductThumbnail(item, isCritical, statusColor),

                        const SizedBox(width: kSpacingTiny),

                        // 📝 שם + קטגוריה + recurring
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  if (item.isRecurring)
                                    Padding(
                                      padding: const EdgeInsets.only(left: kSpacingXTiny),
                                      child: Icon(Icons.star_rounded, color: theme.colorScheme.tertiary, size: kIconSizeSmall),
                                    ),
                                  Flexible(
                                    child: Text(
                                      item.productName,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    FiltersConfig.getCategoryInfo(
                                      FiltersConfig.resolveCategory(item.category),
                                    ).label,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: kFontSizeTiny,
                                    ),
                                  ),
                                  if (item.expiryDate != null) ...[
                                    const SizedBox(width: kSpacingSmall),
                                    _buildExpiryBadge(item),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: kSpacingSmall),

                        // 🔢 כמות — כפתורי +/- מהירים
                        // Force LTR so +/- buttons stay in consistent visual order
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // כפתור מינוס
                              _buildQuantityButton(
                                icon: Icons.remove,
                                color: item.quantity <= 1 ? cs.error : cs.onSurfaceVariant,
                                onTap: item.quantity > 0
                                    ? () => _updateQuantity(item, item.quantity - 1)
                                    : null,
                              ),

                              // מספר כמות
                              GestureDetector(
                                onTap: () => _showQuickQuantityDialog(item),
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 40),
                                  padding: const EdgeInsets.symmetric(horizontal: kSpacingTiny, vertical: kSpacingTiny),
                                  decoration: BoxDecoration(
                                    color: isWarning || isCritical
                                        ? statusColor.withValues(alpha: 0.12)
                                        : cs.primaryContainer.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(kBorderRadius),
                                    border: Border.all(
                                      color: isWarning || isCritical
                                          ? statusColor.withValues(alpha: 0.3)
                                          : cs.primary.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${item.quantity}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isWarning || isCritical ? statusColor : cs.primary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        item.unit,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontSize: kFontSizeTiny,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // כפתור פלוס
                              _buildQuantityButton(
                                icon: Icons.add,
                                color: cs.primary,
                                onTap: item.quantity < kMaxPantryQuantity
                                    ? () => _updateQuantity(item, item.quantity + 1)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// כפתור +/- עגול לכמות
  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () {
                unawaited(HapticFeedback.selectionClick());
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
        child: Padding(
          padding: const EdgeInsets.all(kSpacingTiny),
          child: Icon(
            icon,
            size: kIconSizeSmallPlus,
            color: onTap != null ? color : color.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  /// 🎨 צבע לפי קטגוריה — Dark Mode aware via Theme colorScheme
  Color _getCategoryColor(String category) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final key = FiltersConfig.hebrewCategoryToEnglish(category);

    // Light mode: vibrant colors. Dark mode: desaturated via Color.lerp
    Color base = switch (key) {
      'dairy' => const Color(0xFF42A5F5),
      'vegetables' || 'fruits' || 'fresh_herbs' => brand?.stickyGreen ?? kStickyGreen,
      'meat' || 'poultry' || 'deli' || 'meat_fish' || 'beef' || 'chicken' || 'turkey' || 'lamb' => const Color(0xFFEF5350),
      'fish' => const Color(0xFF26C6DA),
      'bakery' || 'bread' || 'bread_bakery' => const Color(0xFFFFB74D),
      'frozen' => const Color(0xFF78909C),
      'drinks' || 'alcohol' || 'wine' || 'beverages' || 'coffee_tea' => brand?.stickyPurple ?? kStickyPurple,
      'snacks' || 'sweets' || 'chocolate' || 'sweets_snacks' || 'cookies_sweets' => const Color(0xFFFF7043),
      'cleaning' || 'laundry' => const Color(0xFF66BB6A),
      'hygiene' || 'beauty' || 'cosmetics' => brand?.stickyPink ?? kStickyPink,
      'spices' || 'condiments' => const Color(0xFFFFA726),
      'grains' || 'pasta' || 'rice' || 'rice_pasta' || 'legumes_grains' || 'cereals' => const Color(0xFFD4A373),
      'canned' || 'preserved' => const Color(0xFF8D6E63),
      'baby' || 'baby_products' => const Color(0xFFF8BBD0),
      'oils' || 'oils_sauces' => const Color(0xFFCDDC39),
      _ => brand?.stickyCyan ?? kStickyCyan,
    };

    // ✅ Dark Mode: desaturate by blending with surface color
    if (isDark) {
      base = Color.lerp(base, cs.surface, 0.3)!;
    }
    return base;
  }

  /// 📸 Thumbnail: תמונת מוצר מ-CDN עם fallback לאמוג'י
  Widget _buildProductThumbnail(
    InventoryItem item,
    bool isCritical,
    Color statusColor,
  ) {
    final thumbnail = ProductThumbnail(
      barcode: item.barcode,
      category: item.category,
      size: kIconSizeXLarge,
      tintColor: statusColor,
    );

    if (!isCritical) return thumbnail;

    return thumbnail
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.1,
          duration: 800.ms,
          curve: Curves.easeInOut,
        );
  }

  /// 🔢 Badge כמות עם חיווי סטטוס
  /// 📅 Badge תאריך תפוגה
  Widget _buildExpiryBadge(InventoryItem item) {
    final cs = Theme.of(context).colorScheme;
    final isExpired = item.isExpired;
    final isExpiringSoon = item.isExpiringSoon;
    final brand = Theme.of(context).extension<AppBrand>();

    Color bgColor;
    Color textColor;
    String icon;

    if (isExpired) {
      bgColor = cs.errorContainer;
      textColor = cs.error;
      icon = '⚠️';
    } else if (isExpiringSoon) {
      // ✅ Warning colors from Theme/AppBrand
      bgColor = brand?.warningContainer ?? cs.tertiaryContainer;
      textColor = brand?.warning ?? cs.tertiary;
      icon = '⏰';
    } else {
      // ✅ Success colors from Theme/AppBrand
      bgColor = brand?.successContainer ?? cs.primaryContainer;
      textColor = brand?.success ?? cs.primary;
      icon = '✓';
    }

    final dateStr = DateFormat('dd/MM').format(item.expiryDate!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingTiny, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: kFontSizeTiny)),
          const SizedBox(width: 2),
          Text(
            dateStr,
            style: TextStyle(
              color: textColor,
              fontSize: kFontSizeTiny,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔢 דיאלוג מהיר לשינוי כמות (Glassmorphic backdrop)
  void _showQuickQuantityDialog(InventoryItem item) {
    final cs = Theme.of(context).colorScheme;
    int quantity = item.quantity;

    final strings = AppStrings.pantry;

    showDialog(
      context: context,
      barrierColor: cs.scrim.withValues(alpha: 0.3),
      builder: (dialogContext) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: kGlassBlurLow, sigmaY: kGlassBlurLow),
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(
              item.productName,
              style: TextStyle(fontSize: kFontSizeMedium, color: cs.primary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.updateQuantityTitle),
                const SizedBox(height: kSpacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.remove),
                      onPressed: quantity > 0 ? () => setDialogState(() => quantity--) : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge),
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: quantity <= item.minQuantity ? cs.error : cs.onSurface,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.add),
                      onPressed: quantity < kMaxPantryQuantity ? () => setDialogState(() => quantity++) : null,
                    ),
                  ],
                ),
                if (quantity <= item.minQuantity)
                  Padding(
                    padding: const EdgeInsets.only(top: kSpacingSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: cs.error, size: kIconSizeSmall),
                        const SizedBox(width: kSpacingTiny),
                        Text(
                          strings.lowStockWarning(item.minQuantity),
                          style: TextStyle(color: cs.error, fontSize: kFontSizeTiny),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(strings.cancelButton),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (quantity != item.quantity) {
                    _updateQuantity(item, quantity);
                  }
                },
                child: Text(strings.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// פעולות אפשריות כשמוצר דומה נמצא במזווה
enum _DuplicateAction { updateQuantity, replaceProduct, addSeparate }

