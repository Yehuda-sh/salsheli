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
// Version: 6.0 - Hybrid Premium (Collaborative + Sensory)
// Last Updated: 22/02/2026

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kDebugMode;
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
import '../../services/template_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/inventory/pantry_empty_state.dart';
import '../../widgets/inventory/pantry_item_dialog.dart';
import '../../widgets/inventory/pantry_product_selection_sheet.dart';
import '../../widgets/common/add_location_dialog.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/inventory/pantry_suggestions.dart';

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
    if (kDebugMode) {
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (kDebugMode) {
        }
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

  /// 🏷️ מיקומים דינמיים - נגזרים מהפריטים בפועל
  List<String> _getAvailableLocations(List<InventoryItem> items) {
    final locations = items
        .map((item) => item.location)
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

  /// 🎯 אימוג'י לפי קטגוריית מוצר
  String _getCategoryEmoji(String category) {
    // נסה להמיר מעברית לאנגלית
    final englishKey = FiltersConfig.hebrewCategoryToEnglish(category);
    return FiltersConfig.getCategoryEmoji(englishKey);
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

      // סינון לפי מיקום
      if (_selectedLocation != null) {
        if (item.location != _selectedLocation) {
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
      String location = item.location;
      if (location.trim().isEmpty) {
        location = 'other'; // ברירת מחדל
      }
      grouped.putIfAbsent(location, () => []).add(item);
    }

    return grouped;
  }

  /// מציג bottom sheet לבחירת מוצר מהקטלוג
  void _addItemDialog() {
    if (kDebugMode) {
    }
    PantryProductSelectionSheet.show(context);
  }

  /// 🏺 מוסיף פריטי starter למזווה (Onboarding)
  Future<void> _addStarterItems() async {

    // ✅ Cache values before async gap
    final strings = AppStrings.pantry;
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<InventoryProvider>();

    try {
      if (kDebugMode) {
      }

      // טוען את הפריטים מהתבנית
      final items = await TemplateService.loadPantryStarterItems();

      if (items.isEmpty) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(strings.noStarterItemsFound)),
          );
        }
        return;
      }

      // מוסיף למזווה
      final count = await provider.addStarterItems(items);

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(strings.starterItemsAdded(count))),
        );
      }
    } catch (e) {
      if (kDebugMode) {
      }
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(strings.starterItemsError)),
        );
      }
    }
  }

  /// מציג דיאלוג לעריכת פרטי פריט קיים
  void _editItemDialog(InventoryItem item) {
    if (kDebugMode) {
    }
    PantryItemDialog.showEditDialog(context, item);
  }

  /// מוחק פריט מהמזווה
  Future<void> _deleteItem(InventoryItem item) async {

    // ✅ Cache values before async gap
    final strings = AppStrings.pantry;
    final messenger = ScaffoldMessenger.of(context);
    final inventoryProvider = context.read<InventoryProvider>();

    if (kDebugMode) {
    }
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
                  if (kDebugMode) {
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
      }
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

    if (kDebugMode) {
    }

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

      if (wasAboveMin && willBeLow) {
        await _sendLowStockNotification(updatedItem);
      }
    } catch (e) {
      if (kDebugMode) {
      }
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(strings.updateQuantityError)),
        );
      }
    }
  }

  /// שולח התראה על מלאי נמוך (placeholder - לשימוש עתידי עם household)
  Future<void> _sendLowStockNotification(InventoryItem item) async {
    // TODO: Implement household-based low stock notifications
    if (kDebugMode) {
    }
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: scheme.error),
                        const SizedBox(height: kSpacingMedium),
                        Text(
                          strings.loadingErrorTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: kSpacingSmall),
                        Text(
                          provider.errorMessage ?? strings.loadingErrorDefault,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: kSpacingLarge),
                        FilledButton.icon(
                          onPressed: () => provider.loadItems(),
                          icon: const Icon(Icons.refresh),
                          label: Text(strings.retryButton),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Semantics(
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
              ),
              body: provider.isLoading
                  ? SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: scheme.primary),
                            const SizedBox(height: kSpacingMedium),
                            Text(strings.loadingText, style: TextStyle(color: scheme.onSurface)),
                          ],
                        ),
                      ),
                    )
                  : allItems.isEmpty
                      ? SafeArea(
                          child: PantryEmptyState(
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
                                    onAddItem: (name, qty, unit) async {
                                      final provider =
                                          context.read<InventoryProvider>();
                                      await provider.createItem(
                                        productName: name,
                                        quantity: qty.toInt(),
                                        unit: unit,
                                        category: 'כללי',
                                        location: 'general',
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primaryContainer,
                ),
                child: const Center(
                  child: Text('📦', style: TextStyle(fontSize: kFontSizeTitle)),
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
                        '${provider.items.length} פריטים במזווה',
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
                    width: 36,
                    height: 36,
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
            label: 'פריטים',
            color: cs.primary,
            theme: theme,
          ),
          const SizedBox(width: kSpacingSmall),
          if (lowStockCount > 0) ...[
            _buildSummaryChip(
              emoji: '⚠️',
              value: '$lowStockCount',
              label: 'חסרים',
              color: brand?.warning ?? cs.error,
              theme: theme,
            ),
            const SizedBox(width: kSpacingSmall),
          ],
          _buildSummaryChip(
            emoji: '📍',
            value: '$locationsCount',
            label: 'מיקומים',
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
          padding: const EdgeInsets.symmetric(vertical: kSpacingSmall, horizontal: kSpacingSmall),
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
              Text(emoji, style: const TextStyle(fontSize: kFontSizeTitle)),
              const SizedBox(height: 2),
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
                height: 48,
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
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            tooltip: AppStrings.pantry.clearSearchTooltip,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
            height: 40,
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
        padding: const EdgeInsets.only(left: 8.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }).toList();

    // ➕ כפתור הוספת מיקום חדש (Shimmer כשיש מעט מיקומים)
    final showShimmer = locations.length <= 1;
    Widget addChip = Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ActionChip(
        avatar: Icon(Icons.add_location_alt, size: 18, color: scheme.primary),
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
        padding: const EdgeInsets.symmetric(horizontal: 4),
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
          bottom: 100,
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
          bottom: 100,
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
                padding: EdgeInsets.only(top: isFirstSection ? 0 : 12, bottom: 2),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    right: kSpacingMedium,
                    top: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    color: highlightColor,
                    border: Border(
                      right: BorderSide(color: scheme.outline.withValues(alpha: 0.3), width: 4),
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: kSpacingLarge),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: cs.onErrorContainer),
            const SizedBox(width: 8),
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
        margin: const EdgeInsets.only(bottom: 6),
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
                  width: 4,
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
                      horizontal: kSpacingMedium,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // 🏷️ אמוג'י בעיגול
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _buildCategoryEmoji(item, isCritical),
                          ),
                        ),

                        const SizedBox(width: kSpacingSmall),

                        // 📝 שם + קטגוריה + recurring
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  if (item.isRecurring)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Text('⭐', style: TextStyle(fontSize: kFontSizeSmall)),
                                    ),
                                  Flexible(
                                    child: Text(
                                      item.productName,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    item.category,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: kFontSizeTiny,
                                    ),
                                  ),
                                  if (item.expiryDate != null) ...[
                                    const SizedBox(width: kSpacingSmall),
                                    _buildExpiryBadge(item, cs),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: kSpacingSmall),

                        // 🔢 כמות — כפתורי +/- מהירים
                        Row(
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
                                constraints: const BoxConstraints(minWidth: 48),
                                padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingSmall),
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
                              onTap: item.quantity < 99
                                  ? () => _updateQuantity(item, item.quantity + 1)
                                  : null,
                            ),
                          ],
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 20,
            color: onTap != null ? color : color.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  /// 🎨 צבע לפי קטגוריה — נותן צבעוניות ייחודית לכל סוג מוצר
  Color _getCategoryColor(String category) {
    final key = FiltersConfig.hebrewCategoryToEnglish(category);
    return switch (key) {
      'dairy' => const Color(0xFF42A5F5),        // כחול — חלב
      'vegetables' || 'fruits' || 'fresh_herbs' => kStickyGreen,  // ירוק — ירקות/פירות
      'meat' || 'poultry' || 'deli' => const Color(0xFFEF5350),   // אדום — בשר
      'fish' || 'seafood' => const Color(0xFF26C6DA),              // תכלת — דגים
      'bakery' || 'bread' => const Color(0xFFFFB74D),              // כתום — מאפים
      'frozen' => const Color(0xFF78909C),                          // אפור-כחול — קפואים
      'drinks' || 'alcohol' || 'wine' => kStickyPurple,            // סגול — משקאות
      'snacks' || 'sweets' || 'chocolate' => const Color(0xFFFF7043), // כתום-אדום — חטיפים
      'cleaning' || 'laundry' => const Color(0xFF66BB6A),          // ירוק בהיר — ניקיון
      'hygiene' || 'beauty' => kStickyPink,                        // ורוד — טיפוח
      'spices' || 'condiments' => const Color(0xFFFFA726),         // כתום — תבלינים
      'grains' || 'pasta' || 'rice' => const Color(0xFFD4A373),    // חום — דגנים
      'canned' || 'preserved' => const Color(0xFF8D6E63),          // חום כהה — שימורים
      'baby' => const Color(0xFFF8BBD0),                           // ורוד בהיר — תינוקות
      'oils' => const Color(0xFFCDDC39),                           // ליים — שמנים
      _ => kStickyCyan,                                            // ברירת מחדל — תכלת
    };
  }

  /// 🏷️ אמוג'י קטגוריה עם Pulse לפריטים קריטיים
  Widget _buildCategoryEmoji(InventoryItem item, bool isCritical) {
    final emoji = Text(
      _getCategoryEmoji(item.category),
      style: const TextStyle(fontSize: kFontSizeTitle),
    );

    if (!isCritical) return emoji;

    // 🔴 Pulse animation לפריטים קריטיים
    return emoji
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.15,
          duration: 800.ms,
          curve: Curves.easeInOut,
        );
  }

  /// 🔢 Badge כמות עם חיווי סטטוס
  /// 📅 Badge תאריך תפוגה
  Widget _buildExpiryBadge(InventoryItem item, ColorScheme _) {
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
                      icon: Icon(Icons.remove),
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
                      onPressed: quantity < 99 ? () => setDialogState(() => quantity++) : null,
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
                        SizedBox(width: kSpacingTiny),
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

