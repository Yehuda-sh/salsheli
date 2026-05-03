// lib/screens/pantry/my_pantry_screen.dart — Pantry screen — inventory management with location grouping, search, barcode scan

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/filters_config.dart';
import '../../config/storage_locations_config.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/locations_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/user_context.dart';
import '../../services/notifications_service.dart';
import '../../services/template_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/add_location_dialog.dart';
import '../../widgets/common/app_error_state.dart';
import '../../widgets/common/app_loading_skeleton.dart';
import '../../widgets/common/barcode_helpers.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../widgets/inventory/pantry_empty_state.dart';
import '../../widgets/inventory/pantry_item_dialog.dart';
import '../../widgets/inventory/pantry_product_selection_sheet.dart';
import '../../widgets/inventory/pantry_starter_preview_dialog.dart';
import '../../widgets/inventory/pantry_suggestions.dart';


/// Stock-level filter that the pantry can be opened with.
///
/// `outOfStock` shows only items with `quantity == 0`; `lowStock` shows
/// items below their per-item minimum (i.e. `isLowStock`); `all` is the
/// default no-op.
enum PantryStockFilter { all, outOfStock, lowStock }

class MyPantryScreen extends StatefulWidget {
  const MyPantryScreen({super.key});

  /// Set this from another screen (e.g. the dashboard's "out of stock"
  /// chip) BEFORE switching to the pantry tab. The pantry consumes the
  /// value on next build and resets it back to null. Static is OK here
  /// because the pantry tab is a singleton inside MainNavigationScreen.
  static PantryStockFilter? pendingStockFilter;

  @override
  State<MyPantryScreen> createState() => _MyPantryScreenState();
}

class _MyPantryScreenState extends State<MyPantryScreen> {
  // 🔍 חיפוש וסינון
  String _searchQuery = '';
  String? _selectedLocation; // מיקום נבחר לסינון (null = הכל)
  PantryStockFilter _stockFilter = PantryStockFilter.all;
  final Set<String> _collapsedLocations = {};

  // 🔍 Search-mode toggle: when true, the title bar morphs into a search field
  bool _isSearchMode = false;
  final _searchFocusNode = FocusNode();

  // 🖼️ View mode — list (rich rows) vs grid (large image, less detail).
  // Persisted per-user via SharedPreferences so the choice is sticky
  // across launches.
  static const _kViewModePrefKey = 'pantry_view_mode_grid';
  bool _gridMode = false;

  // 💨 Speed-dial FAB — one main button that expands into the 3 quick
  // actions (manual add, scan-to-add, scan-to-decrement). Replaces the
  // older always-visible 3-FAB column which crowded the bottom-left of
  // the screen and overlapped list/grid content during scroll.
  bool _fabExpanded = false;

  // ⏱️ Debounce לחיפוש
  Timer? _searchDebounce;
  final _searchController = TextEditingController();
  static const _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _loadViewModePref();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InventoryProvider>().loadItems();
      }
    });
  }

  Future<void> _loadViewModePref() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_kViewModePrefKey) ?? false;
    if (mounted && saved != _gridMode) {
      setState(() => _gridMode = saved);
    }
  }

  Future<void> _toggleViewMode() async {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _gridMode = !_gridMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kViewModePrefKey, _gridMode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Consume any "open with this filter" intent set by another screen
    // (e.g. the dashboard's out-of-stock chip). One-shot — clear it so
    // the next visit to the pantry tab doesn't re-apply the filter.
    final pending = MyPantryScreen.pendingStockFilter;
    if (pending != null && pending != _stockFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _stockFilter = pending);
        }
      });
      MyPantryScreen.pendingStockFilter = null;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
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

  /// 🔍 Toggle search mode: title ⇄ search field
  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        // Leaving search mode — clear the query
        _searchController.clear();
        _searchDebounce?.cancel();
        _searchQuery = '';
      }
    });
    if (_isSearchMode) {
      // Delay focus until after the morph animation settles
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    } else {
      _searchFocusNode.unfocus();
    }
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

      // סינון לפי כמות במלאי
      switch (_stockFilter) {
        case PantryStockFilter.outOfStock:
          if (item.quantity > 0) return false;
          break;
        case PantryStockFilter.lowStock:
          if (!item.isLowStock) return false;
          break;
        case PantryStockFilter.all:
          break;
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
    final scannedBarcode = product['barcode'] as String?;

    // 🔍 בדיקת כפילויות — barcode first, then name similarity
    final inventoryProvider = context.read<InventoryProvider>();
    final similar = _findSimilarItem(name, inventoryProvider.items, barcode: scannedBarcode);

    if (similar != null && mounted) {
      final action = await _showDuplicateDialog(name, similar);
      if (!mounted) return;

      switch (action) {
        case _DuplicateAction.updateQuantity:
          // עדכון כמות +1, שם לא משתנה
          await inventoryProvider.addStock(similar.productName, 1);
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
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
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
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
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
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
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
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
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
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
  InventoryItem? _findSimilarItem(String scannedName, List<InventoryItem> items, {String? barcode}) {
    if (items.isEmpty) return null;

    // 0. Match by barcode first — most reliable identifier
    // (prevents duplicates when catalog returns slightly different names)
    if (barcode != null && barcode.isNotEmpty) {
      final byBarcode = items.where((i) => i.barcode == barcode).firstOrNull;
      if (byBarcode != null) return byBarcode;
    }

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
      final itemInScanned = itemWords.where(scannedWords.contains).length;
      final scannedInItem = scannedWords.where(itemWords.contains).length;

      // כל מילות הפריט הקצר חייבות להופיע בארוך
      final shorter = itemWords.length <= scannedWords.length ? itemWords : scannedWords;
      final longer = itemWords.length <= scannedWords.length ? scannedWords : itemWords;
      final allShorterInLonger = shorter.every(longer.contains);

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
                  color: cs.primaryContainer.withValues(alpha: kOpacityLight),
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
        unawaited(PantryProductSelectionSheet.show(
          context,
          initialCategories: PantryProductSelectionSheet.basicCategories,
        ));
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
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(strings.starterItemsAdded(count))),
        );
    } catch (e) {
      if (!mounted) return;
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(strings.starterItemsError)),
        );
    }
  }

  /// מציג דיאלוג לעריכת פרטי פריט קיים.
  ///
  /// Dialog return values:
  ///   `true`  → item saved, no further action needed (provider stream
  ///             refreshes the list).
  ///   `false` → user cancelled.
  ///   `null`  → user deleted from inside the dialog. The provider call
  ///             already happened there; we surface the same toast +
  ///             undo affordance the swipe-delete gives, so users can
  ///             still recover from a misclick.
  Future<void> _editItemDialog(InventoryItem item) async {
    final result = await PantryItemDialog.showEditDialog(context, item);
    if (!mounted) return;
    if (result == null) {
      _showDeletedSnackBar(item);
    }
  }

  /// Shared "deleted with undo" toast used by both swipe-to-delete and
  /// the dialog's delete button.
  void _showDeletedSnackBar(InventoryItem deletedItem) {
    final strings = AppStrings.pantry;
    final messenger = ScaffoldMessenger.of(context);
    final inventoryProvider = context.read<InventoryProvider>();
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(strings.itemDeleted(deletedItem.productName)),
          action: SnackBarAction(
            label: AppStrings.common.cancel,
            onPressed: () async {
              try {
                await inventoryProvider.updateItem(deletedItem);
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(AppStrings.inventory.updateError),
                    ));
                }
              }
            },
          ),
        ),
      );
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
        messenger
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(strings.itemDeleted(item.productName)),
              action: SnackBarAction(
                label: AppStrings.common.cancel,
                onPressed: () async {
                  try {
                    await inventoryProvider.updateItem(item);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
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
        messenger
          ..removeCurrentSnackBar()
          ..showSnackBar(
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
        messenger
          ..removeCurrentSnackBar()
          ..showSnackBar(
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
    final brand = theme.extension<AppBrand>();

    final primaryColor = scheme.primaryContainer;

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
              floatingActionButton: _buildSpeedDialFab(
                brand: brand,
                scheme: scheme,
                primaryColor: primaryColor,
                hasItems: allItems.isNotEmpty,
                strings: strings,
              ),
              body: provider.isLoading
                  ? const SafeArea(
                      child: AppLoadingSkeleton(sectionCount: 5),
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
                                  // (Offline banner is mounted once at
                                  // main_navigation_screen — adding another
                                  // here would stack two identical bars.)

                                  // 🏷️ כותרת המזווה (Collaborative Immersive)
                                  // כוללת ספירה אינליין (📦 + ⚠️) וכפתור חיפוש.
                                  _buildInlineTitle(context, provider, scheme, allItems),

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
                                  _buildStockFilterBanner(),
                                  _buildFiltersSection(allItems),

                                  // 📋 תוכן — pull-to-refresh wraps the list
                                  Expanded(
                                    child: RefreshIndicator(
                                      onRefresh: () => provider.loadItems(),
                                      color: scheme.primary,
                                      child: filteredItems.isEmpty && allItems.isNotEmpty
                                        ? ListView(
                                            children: [
                                              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                              Center(
                                                child: Column(
                                                  children: [
                                                    Text(strings.noItemsFound, style: TextStyle(color: scheme.onSurface)),
                                                    TextButton(
                                                      onPressed: () {
                                                        _searchController.clear();
                                                        setState(() {
                                                          _searchQuery = '';
                                                          _selectedLocation = null;
                                                          _isSearchMode = false;
                                                        });
                                                      },
                                                      child: Text(strings.clearFilters),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : _gridMode
                                            ? _buildGridList(filteredItems)
                                            : filteredItems.length >= 5
                                                ? _buildGroupedList(filteredItems)
                                                : _buildFlatList(filteredItems),
                                    ),
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

  /// Speed-dial FAB. The main "+" button toggles `_fabExpanded`; the
  /// 3 quick actions (manual add, scan-to-add, scan-to-decrement) only
  /// render when expanded so they stop crowding the screen during scroll.
  /// Each sub-action collapses the dial after firing.
  Widget _buildSpeedDialFab({
    required AppBrand? brand,
    required ColorScheme scheme,
    required Color primaryColor,
    required bool hasItems,
    required PantryStrings strings,
  }) {
    void closeAndRun(VoidCallback action) {
      setState(() => _fabExpanded = false);
      action();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: kSpacingMedium,
        bottom: kSpacingMedium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuart,
            child: _fabExpanded
                ? Padding(
                    padding: const EdgeInsets.only(bottom: kSpacingSmallPlus),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Manual add — appears first so it lines up
                        // closest to the main FAB (most-likely action).
                        _buildSubFab(
                          tag: 'pantry_add_sub',
                          icon: Icons.edit_outlined,
                          backgroundColor: primaryColor,
                          foregroundColor: scheme.onPrimaryContainer,
                          tooltip: strings.addItemTooltip,
                          onPressed: () => closeAndRun(_addItemDialog),
                        ),
                        const SizedBox(height: kSpacingSmallPlus),
                        // Scan-to-add (always available)
                        _buildSubFab(
                          tag: 'pantry_scan_sub',
                          icon: Icons.qr_code_scanner,
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.onSecondaryContainer,
                          tooltip: AppStrings.inventory.scanToAddTooltip,
                          onPressed: () => closeAndRun(_scanBarcodeAndAddToPantry),
                        ),
                        // Scan-to-decrement only when there is stock to
                        // remove — same gating logic the old fixed FAB
                        // column used.
                        if (hasItems) ...[
                          const SizedBox(height: kSpacingSmallPlus),
                          _buildSubFab(
                            tag: 'pantry_quick_scan_sub',
                            icon: Icons.remove_shopping_cart,
                            backgroundColor: brand?.stickyOrange ?? kStickyOrange,
                            foregroundColor: scheme.onSurface,
                            tooltip: AppStrings.inventory.quickScanTooltip,
                            onPressed: () => closeAndRun(_quickScanToDecrement),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Main FAB — toggles expand/collapse. + rotates to × when open.
          Semantics(
            button: true,
            label: _fabExpanded
                ? AppStrings.common.cancel
                : strings.addItemLabel,
            child: FloatingActionButton(
              heroTag: 'pantry_speed_dial',
              onPressed: () {
                unawaited(HapticFeedback.selectionClick());
                setState(() => _fabExpanded = !_fabExpanded);
              },
              backgroundColor: _fabExpanded
                  ? scheme.surfaceContainerHigh
                  : primaryColor,
              tooltip: _fabExpanded
                  ? AppStrings.common.cancel
                  : strings.addItemTooltip,
              child: AnimatedRotation(
                turns: _fabExpanded ? 0.125 : 0, // 45° → looks like ×
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.add,
                  color: _fabExpanded
                      ? scheme.onSurface
                      : scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One row in the speed-dial column. Wraps a small FAB in a fade+scale
  /// animation so it pops in nicely when the dial expands.
  Widget _buildSubFab({
    required String tag,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton.small(
      heroTag: tag,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
      child: Icon(icon, color: foregroundColor, size: kIconSizeSmallPlus),
    )
        .animate()
        .scaleXY(begin: 0.7, end: 1.0, duration: 150.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 150.ms);
  }

  /// 🏷️ כותרת המזווה - Collaborative Immersive (Glassmorphic + Avatars)
  ///
  /// שני מצבים:
  /// 1) מצב רגיל: אייקון + שם המזווה + ספירה אינליין (📦 / ⚠️) + חיפוש + אווטר
  /// 2) מצב חיפוש: אייקון חזרה + TextField + כפתור ניקוי
  // The `context` parameter is the Consumer<InventoryProvider>'s build
  // context — needed because `context.select` requires a context that is
  // actively building. Using `this.context` (State's context) would only
  // work on the very first render; subsequent Consumer-driven rebuilds
  // would assert "context.select outside of build".
  Widget _buildInlineTitle(
    BuildContext context,
    InventoryProvider provider,
    ColorScheme scheme,
    List<InventoryItem> allItems,
  ) {
    final theme = Theme.of(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: kGlassBlurMedium, sigmaY: kGlassBlurMedium),
        child: Container(
          color: scheme.surface.withValues(alpha: kOpacityStrong),
          padding: const EdgeInsets.only(
            right: kSpacingMedium,
            left: kSpacingMedium,
            top: kSpacingSmall,
            bottom: kSpacingTiny,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            ),
            child: _isSearchMode
                ? _buildTitleSearchRow(theme, scheme)
                : _buildTitleContentRow(
                    theme: theme,
                    scheme: scheme,
                    provider: provider,
                  ),
          ),
        ),
      ),
    );
  }

  /// כותרת במצב רגיל — אייקון + שם + ספירה + חיפוש + אווטר
  Widget _buildTitleContentRow({
    required ThemeData theme,
    required ColorScheme scheme,
    required InventoryProvider provider,
  }) {
    // Local "אב" gradient avatar removed — the global avatar already lives
    // in the top app bar, so showing a second tiny copy here just doubled
    // the same identity without adding meaning.
    return Row(
      key: const ValueKey('pantry_title_content'),
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
          // Inline stats ("📦 21 · ⚠️ 2") removed — the low-stock count is
          // already surfaced as the bottom-nav badge on the מזווה tab and
          // showing it twice (header + nav) was duplicate. The total count
          // (21) was just informational noise; users who want a count can
          // read the section headers ("מטבח 2", "מזווה 15").
          child: Text(
            provider.inventoryTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),

        // 🔍 Search trigger (WhatsApp/Gmail style)
        IconButton(
          tooltip: AppStrings.pantry.searchHint,
          onPressed: _toggleSearchMode,
          icon: Icon(Icons.search, color: scheme.onSurfaceVariant),
          visualDensity: VisualDensity.compact,
        ),
        // ⊞↔☰ View-mode toggle. Single icon swaps based on mode — the
        // shown icon represents what tap will activate (list when in
        // grid, grid when in list), matching how iOS / Material toggles
        // typically read.
        IconButton(
          tooltip: _gridMode
              ? AppStrings.pantry.switchToListView
              : AppStrings.pantry.switchToGridView,
          onPressed: _toggleViewMode,
          icon: Icon(
            _gridMode ? Icons.view_list_outlined : Icons.grid_view_outlined,
            color: scheme.onSurfaceVariant,
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  /// כותרת במצב חיפוש — חזרה + TextField + ניקוי
  Widget _buildTitleSearchRow(ThemeData theme, ColorScheme scheme) {
    return Row(
      key: const ValueKey('pantry_title_search'),
      children: [
        IconButton(
          tooltip: AppStrings.common.cancel,
          onPressed: _toggleSearchMode,
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            style: theme.textTheme.titleMedium,
            decoration: InputDecoration(
              hintText: AppStrings.pantry.searchHint,
              hintStyle: TextStyle(color: scheme.onSurfaceVariant),
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        if (_searchQuery.isNotEmpty || _searchController.text.isNotEmpty)
          IconButton(
            tooltip: AppStrings.pantry.clearFilters,
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  /// 🔍 סעיף סינון — רק שורת מיקומים אופקית.
  /// החיפוש עבר לכותרת (toggle morph) כדי לחסוך מקום במסך.
  /// Banner shown above the filter row when the user opened the pantry
  /// with a stock-level filter (e.g. via the dashboard "out of stock"
  /// chip). Surfaces the filter state explicitly and gives the user a
  /// one-tap way to clear it — otherwise filtered results look like
  /// "the pantry has shrunk" with no obvious cause.
  Widget _buildStockFilterBanner() {
    if (_stockFilter == PantryStockFilter.all) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final strings = AppStrings.pantry;
    final isOut = _stockFilter == PantryStockFilter.outOfStock;
    final accent = isOut
        ? cs.error
        : (brand?.stickyOrange ?? cs.tertiary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingXTiny),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingSmall),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: kOpacitySubtle),
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(color: accent.withValues(alpha: kOpacityLight)),
        ),
        child: Row(
          children: [
            Icon(
              isOut ? Icons.error_outline : Icons.warning_amber_rounded,
              size: kIconSizeSmallPlus,
              color: accent,
            ),
            const SizedBox(width: kSpacingSmall),
            Expanded(
              child: Text(
                isOut
                    ? strings.filterOutOfStockLabel
                    : strings.filterLowStockLabel,
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            IconButton(
              tooltip: strings.clearFilters,
              icon: const Icon(Icons.close, size: kIconSizeSmall),
              onPressed: () {
                unawaited(HapticFeedback.selectionClick());
                setState(() => _stockFilter = PantryStockFilter.all);
              },
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(List<InventoryItem> allItems) {
    if (allItems.isEmpty) return const SizedBox.shrink();

    final availableLocations = _getAvailableLocations(allItems);
    if (availableLocations.isEmpty) return const SizedBox.shrink();

    // Low-stock count drives a standalone status banner above the location
    // chips. Status (⚠️ low stock) and location are two different filter
    // axes — separating them visually communicates that and frees the
    // location row from a chip that doesn't fit there semantically.
    final lowStockCount = allItems.where((i) => i.isLowStock).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kSpacingMedium, kSpacingSmall, kSpacingMedium, kSpacingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lowStockCount > 0) ...[
            _buildLowStockBanner(lowStockCount),
            const SizedBox(height: kSpacingSmall),
          ],
          // Wrap (multi-line) instead of horizontal ListView — long
          // location names (e.g. "מרפסת שירות") used to clip mid-word at
          // the edge of the scroll viewport. Wrap lets a chip overflow to
          // a second row, so every chip stays fully readable regardless
          // of available width.
          Wrap(
            spacing: kSpacingSmall,
            runSpacing: kSpacingXTiny,
            children: _buildLocationChips(availableLocations),
          ),
        ],
      ),
    );
  }

  /// Full-width status banner showing "⚠️ N פריטים נמוכים מהמינימום" with
  /// tap-to-toggle the low-stock filter. Lives above the location chips
  /// — status and location filter on different axes, so separating
  /// visually keeps each row's purpose clear (D pattern). Selected state
  /// fills with the warning palette; unselected is outlined-only so the
  /// banner doesn't shout when the user isn't filtering.
  Widget _buildLowStockBanner(int count) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final isActive = _stockFilter == PantryStockFilter.lowStock;
    final accent = brand?.warning ?? scheme.error;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(kBorderRadius),
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          setState(() {
            _stockFilter = isActive
                ? PantryStockFilter.all
                : PantryStockFilter.lowStock;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingSmallPlus,
            vertical: kSpacingSmall,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? accent.withValues(alpha: kOpacityLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(
              color: accent.withValues(
                alpha: isActive ? kOpacityMedium : kOpacityLight,
              ),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: kIconSizeSmallPlus,
                color: accent,
              ),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(
                  AppStrings.pantry.filterLowStockChip(count),
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    color: scheme.onSurface,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  Icons.close,
                  size: kIconSizeSmall,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏷️ יצירת צ'יפים של מיקומים
  /// A-style chips: selected = solid primary fill with bold text + 1.5px
  /// border. Default = transparent with outlined-only border. The
  /// difference is intentional and large — earlier the two states were
  /// almost identical and users couldn't tell which filter was active.
  List<Widget> _buildLocationChips(List<String> locations) {
    final allLocations = [null, ...locations]; // null = "הכל"
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textColorMuted = scheme.onSurfaceVariant;

    final chips = allLocations.map<Widget>((location) {
      final isAll = location == null;
      final isSelected = _selectedLocation == location;
      final emoji = isAll ? '🏪' : _getLocationEmoji(location);
      final name = isAll ? AppStrings.pantry.allLocations : _getLocationName(location);

      return AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: FilterChip(
            showCheckmark: false,
            label: Text(
              '$emoji $name',
              style: TextStyle(
                fontSize: kFontSizeMedium,
                color: isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
            // Transparent default fill so the chip reads as "outlined
            // only" when not selected. Selected gets the brand container.
            backgroundColor: Colors.transparent,
            selectedColor: scheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              side: BorderSide(
                color: isSelected
                    ? scheme.primary
                    : scheme.outlineVariant.withValues(alpha: kOpacityMedium),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
            visualDensity: VisualDensity.compact,
          ),
        );
    }).toList();

    // ➕ כפתור הוספת מיקום חדש (Shimmer כשיש מעט מיקומים)
    final showShimmer = locations.length <= 1;
    Widget addChip = ActionChip(
      avatar: Icon(Icons.add_location_alt, size: kIconSizeSmallPlus, color: scheme.primary),
      label: Text(
        AppStrings.inventory.addLocationButton,
        style: TextStyle(fontSize: kFontSizeMedium, color: textColorMuted),
      ),
      onPressed: () async {
        final newKey = await showAddLocationDialog(context);
        if (newKey != null && mounted) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(AppStrings.inventory.locationAdded),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
        }
      },
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        // Dashed-feeling border via stronger, primary-tinted outline so
        // "הוסף" reads as a CTA distinct from the regular filter chips.
        side: BorderSide(color: scheme.primary, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
      visualDensity: VisualDensity.compact,
    );

    if (showShimmer) {
      addChip = addChip
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 1800.ms,
            color: scheme.primary.withValues(alpha: kOpacitySoft),
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
            scheme.primaryContainer.withValues(alpha: kOpacitySoft),
            scheme.secondaryContainer.withValues(alpha: kOpacitySoft),
            scheme.tertiaryContainer.withValues(alpha: kOpacitySoft),
            scheme.surfaceContainerHighest.withValues(alpha: kOpacityLow),
          ]
        : [
            scheme.secondaryContainer.withValues(alpha: kOpacityLight),
            scheme.tertiaryContainer.withValues(alpha: kOpacityLight),
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
              // === כותרת סקשן — tap to collapse/expand ===
              Padding(
                padding: EdgeInsets.only(top: isFirstSection ? 0 : kSpacingSmallPlus, bottom: 2),
                child: GestureDetector(
                  onTap: () {
                    unawaited(HapticFeedback.selectionClick());
                    setState(() {
                      if (_collapsedLocations.contains(location)) {
                        _collapsedLocations.remove(location);
                      } else {
                        _collapsedLocations.add(location);
                      }
                    });
                  },
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
                        right: BorderSide(color: scheme.outline.withValues(alpha: kOpacityLight), width: kSpacingXTiny),
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
                        const Spacer(),
                        AnimatedRotation(
                          turns: _collapsedLocations.contains(location) ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.expand_more, size: kIconSizeSmallPlus, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // === פריטים במיקום — animated collapse/expand ===
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _collapsedLocations.contains(location)
                    ? const SizedBox.shrink()
                    : Column(
                        children: locationItems.map((item) {
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
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🖼️ Grid view — sections preserved (header still groups by location),
  /// but items render as 2-column tiles with a large product image and
  /// minimal text. Trades quick +/- access for visual scan-ability;
  /// users who want to update quantity tap a tile to open the dialog.
  Widget _buildGridList(List<InventoryItem> items) {
    final grouped = _groupItemsByLocation(items);
    final locations = grouped.keys.toList()..sort();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return RepaintBoundary(
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          top: kSpacingSmall,
          left: kSpacingMedium,
          right: kSpacingMedium,
          bottom: 100, // FAB clearance
        ),
        itemCount: locations.length,
        itemBuilder: (context, locIndex) {
          final location = locations[locIndex];
          final locationItems = grouped[location]!;
          final isCollapsed = _collapsedLocations.contains(location);
          final isFirstSection = locIndex == 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header — same shape as list mode for consistency.
              Padding(
                padding: EdgeInsets.only(
                  top: isFirstSection ? 0 : kSpacingSmallPlus,
                  bottom: kSpacingSmall,
                ),
                child: GestureDetector(
                  onTap: () {
                    unawaited(HapticFeedback.selectionClick());
                    setState(() {
                      if (isCollapsed) {
                        _collapsedLocations.remove(location);
                      } else {
                        _collapsedLocations.add(location);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        '${_getLocationEmoji(location)} ${_getLocationName(location)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                          fontSize: kFontSizeBody,
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withValues(alpha: kOpacityLight),
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
                      const Spacer(),
                      AnimatedRotation(
                        turns: isCollapsed ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.expand_more, size: kIconSizeSmallPlus, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              // Grid of items — collapses to nothing when section closed.
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: isCollapsed
                    ? const SizedBox.shrink()
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: kSpacingSmall,
                          mainAxisSpacing: kSpacingSmall,
                          // Tile a touch taller than wide so the image
                          // stays generous and the name has 2 lines.
                          childAspectRatio: 0.78,
                        ),
                        itemCount: locationItems.length,
                        itemBuilder: (_, i) =>
                            _buildGridCell(locationItems[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Single tile in the grid view. Tap = open edit dialog (we deliberately
  /// don't ship inline ± buttons here — the grid is for visual scan, not
  /// fast quantity edits; that's what list mode is for).
  Widget _buildGridCell(InventoryItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final isCritical = item.needsUrgentAttention;
    final isWarning = item.isLowStock;
    final Color statusColor = isCritical
        ? cs.error
        : isWarning
            ? (brand?.warning ?? cs.error)
            : _getCategoryColor(item.category);

    // surfaceContainer (Material 3 surface tier) is fully opaque, unlike
    // `cs.surface` which can render slightly translucent with dynamic
    // color schemes — that's why the notebook background's red margin
    // line was visibly cutting through cells. Using a higher tier hides
    // the lines under each cell and keeps the notebook texture in the
    // gutters between cells (where it actually belongs visually).
    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _editItemDialog(item),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            border: Border.all(
              color: isWarning || isCritical
                  ? statusColor.withValues(alpha: kOpacityLight)
                  : cs.outlineVariant.withValues(alpha: kOpacitySubtle),
            ),
          ),
          padding: const EdgeInsets.all(kSpacingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero image — fills most of the tile. Stack lets us add a
              // top-right warning badge for low-stock items so the user
              // can spot them without reading every quantity.
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: ProductThumbnail(
                        barcode: item.barcode,
                        category: item.category,
                        productName: item.productName,
                        size: kIconSizeXLarge + kSpacingXLarge, // 80px
                        tintColor: statusColor,
                      ),
                    ),
                    if (isWarning || isCritical)
                      PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: Container(
                          width: kIconSizeSmallPlus,
                          height: kIconSizeSmallPlus,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.surfaceContainer,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isCritical
                                ? Icons.priority_high
                                : Icons.warning_amber_rounded,
                            color: cs.onError,
                            size: kIconSizeSmall - 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: kSpacingTiny),
              // Recurring star + product name.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.isRecurring)
                    Padding(
                      padding: const EdgeInsets.only(left: kSpacingXTiny, top: 2),
                      child: Icon(
                        Icons.star,
                        color: brand?.warning ?? cs.tertiary,
                        size: kIconSizeSmall,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      item.productName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingXTiny),
              // Inline ± stepper — same direct manipulation as list mode.
              // LTR forced so − stays left, + stays right regardless of
              // surrounding RTL paragraph direction.
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      color: item.quantity <= 1 ? cs.error : cs.onSurfaceVariant,
                      onTap: item.quantity > 0
                          ? () => _updateQuantity(item, item.quantity - 1)
                          : null,
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSpacingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isWarning || isCritical
                              ? statusColor.withValues(alpha: kOpacitySubtle)
                              : cs.primaryContainer.withValues(alpha: kOpacityLight),
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: Directionality(
                          // Re-anchor to the locale direction so Hebrew
                          // unit suffixes ("יח'", "ק"ג") read correctly.
                          textDirection: Directionality.of(context),
                          child: Text(
                            '${item.quantity} ${item.unit}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isWarning || isCritical ? statusColor : cs.primary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
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
    );
  }

  /// 🎴 שורת פריט — Card מקצועי עם Swipe, Tap, וחיווי סטטוס
  Widget _buildItemRow(InventoryItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final strings = AppStrings.pantry;
    final isCritical = item.needsUrgentAttention;
    final isWarning = item.isLowStock;

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
        margin: const EdgeInsets.only(bottom: kSpacingSmall),
        elevation: isCritical ? 2 : 0,
        shadowColor: isCritical ? cs.error.withValues(alpha: kOpacityLight) : null,
        // Opaque surface tier so the notebook background's red margin
        // line doesn't appear to cut through rows — the notebook texture
        // stays visible in the gutters between cards instead.
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          side: BorderSide(
            color: isWarning || isCritical
                ? statusColor.withValues(alpha: kOpacityLight)
                : cs.outlineVariant.withValues(alpha: kOpacitySubtle),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _editItemDialog(item),
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          // Per-row colored side stripe removed — too many colors competing
          // for attention with no legend explaining what each one means.
          // The card's outlined border (cs.error / statusColor when warning
          // or critical, neutral otherwise) is now the only stock-status
          // signal — single, consistent cue.
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 📦 תוכן — padding הוגדל לתמונה 72px ולטיפוגרפיה חדשה
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingSmallPlus,
                      vertical: kSpacingSmall,
                    ),
                    child: Row(
                      children: [
                        // 🏷️ תמונת מוצר — Hero 72px
                        _buildProductThumbnail(item, isCritical, statusColor),

                        const SizedBox(width: kSpacingSmallPlus),

                        // 📝 Two-tier column: name (full width) → badges → qty row
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tier 1: name (+ recurring icon + notes icon)
                              Row(
                                children: [
                                  // Star = "recurring product" — same glyph
                                  // the edit dialog uses, so the row's mark
                                  // and the dialog's toggle stay in sync.
                                  // Uses the brand warning/orange so it
                                  // visually separates from the muted notes
                                  // icon — at a glance the user can tell
                                  // "marked-as-staple" from "has notes".
                                  if (item.isRecurring)
                                    Padding(
                                      padding: const EdgeInsets.only(left: kSpacingXTiny),
                                      child: Icon(
                                        Icons.star,
                                        color: brand?.warning ?? theme.colorScheme.tertiary,
                                        size: kIconSizeSmallPlus,
                                      ),
                                    ),
                                  if (item.notes != null && item.notes!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: kSpacingXTiny),
                                      child: Tooltip(
                                        message: item.notes!,
                                        child: Icon(
                                          Icons.sticky_note_2_outlined,
                                          color: cs.onSurfaceVariant,
                                          size: kIconSizeSmall,
                                        ),
                                      ),
                                    ),
                                  // Expanded (not Flexible) forces wrapping.
                                  Expanded(
                                    child: Text(
                                      fixBidiNumbers(item.productName),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              // Tier 2: expiry badge (only when present)
                              if (item.expiryDate != null) ...[
                                const SizedBox(height: kSpacingXTiny),
                                _buildExpiryBadge(item),
                              ],

                              // Tier 3: quantity controls, pushed to trailing edge.
                              // Moving this here instead of sitting beside the name
                              // gives the name the full column width — essential for
                              // long Hebrew product names. Tight gap (XTiny) so
                              // the controls read as part of the same "group" as
                              // the name, not as a separate section.
                              const SizedBox(height: kSpacingXTiny),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Directionality(
                                  // Force LTR so the +/- visual order is consistent
                                  // regardless of the surrounding text direction.
                                  textDirection: TextDirection.ltr,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildQuantityButton(
                                        icon: Icons.remove,
                                        color: item.quantity <= 1 ? cs.error : cs.onSurfaceVariant,
                                        onTap: item.quantity > 0
                                            ? () => _updateQuantity(item, item.quantity - 1)
                                            : null,
                                      ),
                                      GestureDetector(
                                        onTap: () => _showQuickQuantityDialog(item),
                                        child: Container(
                                          constraints: const BoxConstraints(minWidth: kMinTapTarget),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: kSpacingSmall,
                                            vertical: kSpacingTiny,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isWarning || isCritical
                                                ? statusColor.withValues(alpha: kOpacitySubtle)
                                                : cs.primaryContainer.withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(kBorderRadius),
                                            border: Border.all(
                                              color: isWarning || isCritical
                                                  ? statusColor.withValues(alpha: kOpacityLight)
                                                  : cs.primary.withValues(alpha: kOpacitySoft),
                                            ),
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 150),
                                            transitionBuilder: (child, animation) =>
                                                ScaleTransition(scale: animation, child: child),
                                            // The parent Directionality forces LTR for the
                                            // -/+ button layout, but that flips the chip's
                                            // text into "unit number" instead of "number unit"
                                            // and pushes the geresh in '\u05D9\u05D7'' to the wrong side.
                                            // Re-anchor to the locale's natural direction here
                                            // so Hebrew reads "3 \u05D9\u05D7'" and English reads "3 pcs".
                                            child: Directionality(
                                              textDirection: isRtl
                                                  ? TextDirection.rtl
                                                  : TextDirection.ltr,
                                              child: Text(
                                                '${item.quantity} ${item.unit}',
                                                key: ValueKey(item.quantity),
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isWarning || isCritical ? statusColor : cs.primary,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
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
            color: onTap != null ? color : color.withValues(alpha: kOpacityLight),
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
      productName: item.productName,
      // 72px hero image — up from 56. Gives brand logos/shape room to read
      // without crowding the product name.
      size: kIconSizeXLarge + kSpacingLarge,
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
    IconData iconData;

    if (isExpired) {
      bgColor = cs.errorContainer;
      textColor = cs.error;
      iconData = Icons.warning_amber_rounded;
    } else if (isExpiringSoon) {
      // ✅ Warning colors from Theme/AppBrand
      bgColor = brand?.warningContainer ?? cs.tertiaryContainer;
      textColor = brand?.warning ?? cs.tertiary;
      iconData = Icons.schedule;
    } else {
      // ✅ Success colors from Theme/AppBrand
      bgColor = brand?.successContainer ?? cs.primaryContainer;
      textColor = brand?.success ?? cs.primary;
      iconData = Icons.check_circle_outline;
    }

    final dateStr = DateFormat('dd/MM').format(item.expiryDate!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingTiny, vertical: kSpacingXTiny / 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Was a text emoji (⚠️/⏰/✓) — Material icon for theme/dark-mode
          // consistency with the rest of the inventory rows.
          Icon(iconData, size: kFontSizeTiny, color: textColor),
          const SizedBox(width: kSpacingXTiny / 2),
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
      barrierColor: cs.scrim.withValues(alpha: kOpacityLight),
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

