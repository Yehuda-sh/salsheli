// 📄 File: lib/screens/pantry/my_pantry_screen.dart
//
// 🎯 מטרה: מסך ניהול מזווה - ניהול פריטי מלאי לפי מיקומים
//
// 📋 כולל:
// - תצוגת פריטים לפי מיקומי אחסון
// - חיפוש וסינון (Frosted Glass design)
// - CRUD מלא: הוספה, עריכה, מחיקה, עדכון כמות
// - עיצוב "Clean Notebook" - תואם ל-ShoppingListDetailsScreen
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
//
// Version: 5.1 - Dark Mode + Accessibility
// Last Updated: 05/01/2026

import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../config/filters_config.dart';
import '../../config/storage_locations_config.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/inventory_item.dart';
import '../../providers/groups_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/locations_provider.dart';
import '../../providers/user_context.dart';
import '../../services/notifications_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/inventory/pantry_empty_state.dart';
import '../../widgets/inventory/pantry_item_dialog.dart';
import '../../widgets/inventory/pantry_product_selection_sheet.dart';

class MyPantryScreen extends StatefulWidget {
  const MyPantryScreen({super.key});

  @override
  State<MyPantryScreen> createState() => _MyPantryScreenState();
}

class _MyPantryScreenState extends State<MyPantryScreen> {
  // 🔍 חיפוש וסינון
  String _searchQuery = '';
  String? _selectedLocation; // מיקום נבחר לסינון (null = הכל)

  // 🔄 State flags
  bool _isProcessing = false;

  // ⏱️ Debounce לחיפוש
  Timer? _searchDebounce;
  static const _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('📦 MyPantryScreen: initState');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (kDebugMode) {
          debugPrint('🔄 MyPantryScreen: טעינת פריטים');
        }
        context.read<InventoryProvider>().loadItems();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
    final englishKey = hebrewCategoryToEnglish(category);
    if (englishKey != null) {
      return getCategoryEmoji(englishKey);
    }
    return getCategoryEmoji(category);
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
      debugPrint('➕ MyPantryScreen: פתיחת בחירת מוצר מהקטלוג');
    }
    PantryProductSelectionSheet.show(context);
  }

  /// מציג דיאלוג לעריכת פרטי פריט קיים
  void _editItemDialog(InventoryItem item) {
    if (kDebugMode) {
      debugPrint('✏️ MyPantryScreen: עריכת פריט - ${item.id}');
    }
    PantryItemDialog.showEditDialog(context, item);
  }

  /// מוחק פריט מהמזווה
  Future<void> _deleteItem(InventoryItem item) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    if (kDebugMode) {
      debugPrint('🗑️ MyPantryScreen: מחיקת פריט - ${item.id}');
    }
    try {
      await context.read<InventoryProvider>().deleteItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.productName} נמחק'),
            action: SnackBarAction(
              label: AppStrings.common.cancel,
              onPressed: () {
                // TODO: Undo deletion
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ MyPantryScreen: שגיאה במחיקת פריט - $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה במחיקת פריט')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// מעדכן כמות פריט במזווה
  Future<void> _updateQuantity(InventoryItem item, int newQuantity) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    if (kDebugMode) {
      debugPrint('📦 MyPantryScreen: עדכון כמות - ${item.id} -> $newQuantity');
    }
    try {
      final wasAboveMin = item.quantity > item.minQuantity;
      final willBeLow = newQuantity <= item.minQuantity;

      final updatedItem = item.copyWith(quantity: newQuantity);
      await context.read<InventoryProvider>().updateItem(updatedItem);

      if (wasAboveMin && willBeLow) {
        await _sendLowStockNotification(updatedItem);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ MyPantryScreen: שגיאה בעדכון כמות - $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה בעדכון כמות')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// שולח התראה על מלאי נמוך
  Future<void> _sendLowStockNotification(InventoryItem item) async {
    try {
      final inventoryProvider = context.read<InventoryProvider>();
      final userContext = context.read<UserContext>();
      final groupsProvider = context.read<GroupsProvider>();

      if (inventoryProvider.isGroupMode && inventoryProvider.currentGroupId != null) {
        final groupId = inventoryProvider.currentGroupId!;
        final group = groupsProvider.groups.where((g) => g.id == groupId).firstOrNull;

        if (group != null) {
          final notificationsService = NotificationsService(FirebaseFirestore.instance);
          final currentUserId = userContext.userId;

          for (final member in group.membersList) {
            if (member.userId != currentUserId) {
              await notificationsService.createLowStockNotification(
                userId: member.userId,
                householdId: group.id,
                productName: item.productName,
                currentStock: item.quantity,
                minStock: item.minQuantity,
              );
            }
          }

          if (kDebugMode) {
            debugPrint('📬 נשלחו התראות מלאי נמוך: ${item.productName}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ שגיאה בשליחת התראת מלאי נמוך: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // ✅ צבעים מה-Theme + Dark Mode
    final primaryColor = scheme.primaryContainer;
    final backgroundColor = isDark ? scheme.surface : kPaperBackground;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Semantics(
        label: 'מסך המזווה שלי',
        container: true,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            final allItems = provider.items;
            final filteredItems = _getFilteredItems(allItems);

            // ✅ Error state with Retry
            if (provider.hasError) {
              return Scaffold(
                backgroundColor: backgroundColor,
                appBar: AppBar(
                  backgroundColor: primaryColor,
                  foregroundColor: scheme.onPrimaryContainer,
                  title: const Text('המזווה שלי'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: scheme.error),
                      const SizedBox(height: kSpacingMedium),
                      Text(
                        'שגיאה בטעינת המזווה',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        provider.errorMessage ?? 'נסה שוב מאוחר יותר',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: kSpacingLarge),
                      FilledButton.icon(
                        onPressed: () => provider.loadItems(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('נסה שוב'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? scheme.onSurface : scheme.onPrimaryContainer,
                title: const Text('המזווה שלי'),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Semantics(
                  button: true,
                  label: 'הוסף מוצר למזווה',
                  child: FloatingActionButton(
                    heroTag: 'pantry_add_btn',
                    onPressed: _isProcessing ? null : _addItemDialog,
                    backgroundColor: primaryColor,
                    tooltip: 'הוסף מוצר',
                    child: Icon(Icons.add, color: scheme.onPrimaryContainer),
                  ),
                ),
              ),
              body: provider.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: scheme.primary),
                          const SizedBox(height: kSpacingMedium),
                          Text('טוען...', style: TextStyle(color: scheme.onSurface)),
                        ],
                      ),
                    )
                  : allItems.isEmpty
                      ? Stack(
                          children: [
                            const NotebookBackground(),
                            PantryEmptyState(
                              isGroupMode: provider.isGroupMode,
                              groupName: provider.isGroupMode ? provider.inventoryTitle : null,
                              onAddItem: _addItemDialog,
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            const NotebookBackground(),
                            Column(
                              children: [
                                // 🔍 חיפוש וסינון
                                _buildFiltersSection(allItems),

                                // 📋 תוכן
                                Expanded(
                                  child: filteredItems.isEmpty && allItems.isNotEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('לא נמצאו פריטים', style: TextStyle(color: scheme.onSurface)),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _searchQuery = '';
                                                    _selectedLocation = null;
                                                  });
                                                },
                                                child: const Text('נקה סינון'),
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
                          ],
                        ),
            );
          },
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

    // ✅ Dark Mode colors
    final glassBgColor = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.6);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.05);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. שורת חיפוש (Frosted Glass)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: kGlassBlurSigma, sigmaY: kGlassBlurSigma),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: glassBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'חיפוש במזווה...',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            tooltip: 'נקה חיפוש',
                            onPressed: () {
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

    // ✅ Dark Mode colors
    final chipBgColor = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.8);
    final chipSelectedColor = scheme.primaryContainer;
    final textColor = scheme.onSurface;
    final textColorMuted = scheme.onSurfaceVariant;

    final chips = allLocations.map((location) {
      final isAll = location == null;
      final isSelected = _selectedLocation == location;
      final emoji = isAll ? '🏪' : _getLocationEmoji(location);
      final name = isAll ? 'הכל' : _getLocationName(location);

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
                fontSize: 13,
                color: isSelected ? textColor : textColorMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedLocation = isAll ? null : location;
              });
            },
            backgroundColor: chipBgColor,
            selectedColor: chipSelectedColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
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

    // ➕ כפתור הוספת מיקום חדש
    chips.add(
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: ActionChip(
          avatar: Icon(Icons.add_location_alt, size: 18, color: scheme.primary),
          label: Text(
            AppStrings.inventory.addLocationButton,
            style: TextStyle(fontSize: 13, color: textColorMuted),
          ),
          onPressed: _showAddLocationDialog,
          backgroundColor: chipBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: scheme.primary, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );

    return chips;
  }

  /// רשימת אמוג'י לבחירה במיקום חדש
  static const List<String> _availableEmojis = [
    '📍', '🏠', '❄️', '🧊', '📦', '🛁', '🧺', '🚗', '🧼', '🧂',
    '🍹', '🍕', '🎁', '🎒', '🧰', '🎨', '📚', '🔧', '🏺', '🗄️',
  ];

  /// מציג דיאלוג להוספת מיקום חדש
  Future<void> _showAddLocationDialog() async {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController();
    String selectedEmoji = '📍';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(AppStrings.inventory.addLocationTitle),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // בחירת אמוג'י
                    Text(AppStrings.inventory.selectEmojiLabel, style: const TextStyle(fontSize: kFontSizeTiny)),
                    const SizedBox(height: kSpacingSmall),
                    Wrap(
                      spacing: kSpacingSmall,
                      runSpacing: kSpacingSmall,
                      children: _availableEmojis.map((emoji) {
                        final isSelected = emoji == selectedEmoji;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedEmoji = emoji;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(kSpacingSmall),
                            decoration: BoxDecoration(
                              color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                              border: Border.all(
                                color: isSelected ? cs.primary : Colors.transparent,
                                width: kBorderWidthThick,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: kIconSize)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: kSpacingMedium),
                    // שם המיקום
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: AppStrings.inventory.locationNameLabel,
                        hintText: AppStrings.inventory.locationNameHint,
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(AppStrings.common.cancel),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_location_alt, size: kIconSizeSmall),
                    label: Text(AppStrings.inventory.addLocationButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primaryContainer,
                      foregroundColor: cs.onPrimaryContainer,
                    ),
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;

                      final provider = this.context.read<LocationsProvider>();
                      final navigator = Navigator.of(dialogContext);
                      final messenger = ScaffoldMessenger.of(this.context);

                      final success = await provider.addLocation(name, emoji: selectedEmoji);

                      if (success) {
                        navigator.pop(true);
                      } else {
                        messenger.showSnackBar(
                          SnackBar(content: Text(AppStrings.inventory.locationExists)),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      final successColor = Theme.of(context).colorScheme.primaryContainer;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.inventory.locationAdded),
          backgroundColor: successColor,
        ),
      );
    }
  }

  /// 📋 רשימה שטוחה
  Widget _buildFlatList(List<InventoryItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: kNotebookLineSpacing - 8,
        left: kNotebookRedLineOffset + kSpacingSmall,
        right: kSpacingMedium,
        bottom: 100,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
          child: _buildItemRow(item),
        );
      },
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
            Colors.cyan.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.1),
            Colors.green.withValues(alpha: 0.1),
          ];

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: kNotebookLineSpacing,
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
                    const SizedBox(width: kNotebookRedLineOffset),
                    Text(
                      '${_getLocationEmoji(location)} ${_getLocationName(location)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? scheme.surfaceContainerHighest.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${locationItems.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // === פריטים במיקום ===
            ...locationItems.map(_buildItemRow),
          ],
        );
      },
    );
  }

  /// 🎴 שורת פריט - Swipe למחיקה, Tap לעריכה
  Widget _buildItemRow(InventoryItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: kSpacingLarge),
        color: cs.errorContainer,
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: cs.onErrorContainer),
            const SizedBox(width: 8),
            Text('מחיקה', style: TextStyle(color: cs.onErrorContainer, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('מחיקת פריט'),
            content: Text('האם למחוק את "${item.productName}"?'),
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
      child: SizedBox(
        height: kNotebookLineSpacing,
        child: Row(
          children: [
            const SizedBox(width: kSpacingMedium),

            // 🏷️ אמוג'י קטגוריה
            Text(
              _getCategoryEmoji(item.category),
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(width: kSpacingSmall),

            // ⭐ מוצר קבוע
            if (item.isRecurring)
              const Padding(
                padding: EdgeInsets.only(left: kSpacingTiny),
                child: Text('⭐', style: TextStyle(fontSize: 12)),
              ),

            // 📝 שם המוצר (לחיץ לעריכה)
            Expanded(
              child: Semantics(
                button: true,
                label: '${item.productName}, לחץ לעריכה',
                child: InkWell(
                  onTap: () => _editItemDialog(item),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.productName,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 📅 תאריך תפוגה
            if (item.expiryDate != null)
              Padding(
                padding: const EdgeInsets.only(left: kSpacingSmall),
                child: _buildExpiryBadge(item, cs),
              ),

            // 🔢 כמות ביחידות (Badge)
            // ✅ מציג מספר יחידות (אריזות) ולא חוזר על יחידת המידה שכבר מופיעה בשם המוצר
            Semantics(
              button: true,
              label: '${item.quantity} יחידות${item.isLowStock ? ', מלאי נמוך' : ''}, לחץ לעדכון',
              child: GestureDetector(
                onTap: () => _showQuickQuantityDialog(item),
                child: Container(
                margin: const EdgeInsets.only(left: kSpacingSmall),
                padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXTiny),
                decoration: BoxDecoration(
                  color: item.isLowStock
                      ? cs.errorContainer.withValues(alpha: 0.3)
                      : cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        color: item.isLowStock ? cs.error : cs.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: kSpacingXTiny),
                    Text(
                      'יח׳', // יחידות - מספר אריזות/יחידות במלאי
                      style: TextStyle(
                        color: item.isLowStock ? cs.error : cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    if (item.isLowStock) ...[
                      const SizedBox(width: kSpacingTiny),
                      Icon(Icons.warning, color: cs.error, size: 14),
                    ],
                  ],
                ),
              ),
              ),
            ),

            const SizedBox(width: kSpacingSmall),
          ],
        ),
      ),
    );
  }

  /// 📅 Badge תאריך תפוגה
  Widget _buildExpiryBadge(InventoryItem item, ColorScheme cs) {
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
          Text(icon, style: const TextStyle(fontSize: 10)),
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

  /// 🔢 דיאלוג מהיר לשינוי כמות
  void _showQuickQuantityDialog(InventoryItem item) {
    final cs = Theme.of(context).colorScheme;
    int quantity = item.quantity;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: ui.TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              item.productName,
              style: TextStyle(fontSize: kFontSizeMedium, color: cs.primary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('עדכון כמות:'),
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
                        const SizedBox(width: kSpacingTiny),
                        Text(
                          'מלאי נמוך (מינימום: ${item.minQuantity})',
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
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (quantity != item.quantity) {
                    _updateQuantity(item, quantity);
                  }
                },
                child: const Text('שמור'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
