// 📄 File: lib/screens/pantry/my_pantry_screen.dart
//
// 🎯 מטרה: מסך ניהול מזווה - ניהול פריטי מלאי
//
// 📋 כולל:
// - 2 טאבים: תצוגת רשימה + ניהול מיקומים
// - סינון לפי קטגוריה + חיפוש טקסט
// - CRUD מלא: הוספה, עריכה, מחיקה, עדכון כמות
// - קיבוץ לפי מיקומי אחסון
// - סטטיסטיקות: סה"כ פריטים, כמות נמוכה, מספר מיקומים
//
// 🔗 Dependencies:
// - InventoryProvider: ניהול state
// - StorageLocationsConfig: תצורת מיקומים
// - PantryFilters: widget סינון
// - StorageLocationManager: widget ניהול מיקומים
//
// 🎯 שימוש:
// ```dart
// Navigator.push(context, MaterialPageRoute(
//   builder: (_) => const MyPantryScreen(),
// ));
// ```
//
// 📝 הערות:
// - כל הconstants מ-ui_constants.dart
// - Theme-aware (ColorScheme)
// - RTL support מלא
// - Logging מפורט לכל פעולה
// - Touch targets 48x48
//
// Version: 3.0
// Last Updated: 10/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/storage_location_manager.dart';
import '../../widgets/pantry_filters.dart';
import '../../config/storage_locations_config.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class MyPantryScreen extends StatefulWidget {
  const MyPantryScreen({super.key});

  @override
  State<MyPantryScreen> createState() => _MyPantryScreenState();
}

class _MyPantryScreenState extends State<MyPantryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchTerm = "";
  String _selectedCategory = 'all';
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    debugPrint('📦 MyPantryScreen: initState');
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('🔄 MyPantryScreen: טעינת פריטים');
        context.read<InventoryProvider>().loadItems();
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🗑️ MyPantryScreen: dispose');
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ========================================
  // Actions
  // ========================================

  void _updateQuantity(String itemId, int delta) async {
    try {
      final provider = context.read<InventoryProvider>();
      final item = provider.items.firstWhere((i) => i.id == itemId);

      final newQuantity = (item.quantity + delta).clamp(0, 99);
      debugPrint('🔢 MyPantryScreen: עדכון כמות - ${item.productName}: ${item.quantity} → $newQuantity');

      if (newQuantity == 0) {
        debugPrint('⚠️ MyPantryScreen: כמות 0 - מציג אישור מחיקה');
        _confirmRemoveItem(itemId);
        return;
      }

      final updatedItem = item.copyWith(quantity: newQuantity);
      await provider.updateItem(updatedItem);
      debugPrint('✅ MyPantryScreen: כמות עודכנה');
    } catch (e) {
      debugPrint('❌ MyPantryScreen: שגיאה בעדכון כמות - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בעדכון כמות: $e'),
            backgroundColor: Colors.red,
            duration: kSnackBarDuration,
          ),
        );
      }
    }
  }

  void _confirmRemoveItem(String itemId) {
    debugPrint('🗑️ MyPantryScreen: _confirmRemoveItem - $itemId');
    final provider = context.read<InventoryProvider>();
    final item = provider.items.firstWhere((i) => i.id == itemId);
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('הסרת פריט', style: TextStyle(color: cs.primary)),
        content: Text(
          'להסיר את ${item.productName} מהמזווה?',
          style: TextStyle(color: cs.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('❌ MyPantryScreen: מחיקה בוטלה');
              Navigator.pop(dialogContext);
            },
            child: Text(AppStrings.common.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(kButtonHeight, kButtonHeight),
            ),
            onPressed: () async {
              debugPrint('✅ MyPantryScreen: מאשר מחיקה - ${item.productName}');
              Navigator.pop(dialogContext);
              try {
                await provider.deleteItem(itemId);
                debugPrint('✅ MyPantryScreen: פריט נמחק');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('הפריט הוסר מהמזווה'),
                      duration: kSnackBarDuration,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('❌ MyPantryScreen: שגיאה במחיקה - $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה בהסרת פריט: $e'),
                      backgroundColor: Colors.red,
                      duration: kSnackBarDuration,
                    ),
                  );
                }
              }
            },
            child: const Text('הסר'),
          ),
        ],
      ),
    );
  }

  void _addItemDialog() {
    debugPrint('➕ MyPantryScreen: פתיחת דיאלוג הוספת פריט');
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: "1");
    final unitController = TextEditingController(text: "יח'");
    final categoryController = TextEditingController();
    String selectedLocation = StorageLocationsConfig.mainPantry;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cs.surface,
          title: Text(
            'הוספת פריט',
            style: TextStyle(color: accent),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: "שם הפריט",
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: kSpacingMedium),
                TextField(
                  controller: categoryController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: "קטגוריה",
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    hintText: "לדוגמה: חלבי",
                    hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                  ),
                ),
                const SizedBox(height: kSpacingMedium),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: cs.onSurface),
                        decoration: InputDecoration(
                          labelText: "כמות",
                          labelStyle: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingMedium),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        style: TextStyle(color: cs.onSurface),
                        decoration: InputDecoration(
                          labelText: "יחידה",
                          labelStyle: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingMedium),
                DropdownButtonFormField<String>(
                  value: selectedLocation,
                  dropdownColor: cs.surface,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: "מיקום",
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  items: StorageLocationsConfig.primaryLocations.map((locationId) {
                    final info = StorageLocationsConfig.getLocationInfo(locationId);
                    return DropdownMenuItem(
                      value: locationId,
                      child: Row(
                        children: [
                          Text(info.emoji),
                          const SizedBox(width: kSpacingSmall),
                          Text(info.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedLocation = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('❌ MyPantryScreen: הוספה בוטלה');
                Navigator.pop(dialogContext);
              },
              child: Text(AppStrings.common.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(kButtonHeight, kButtonHeight),
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('נא להזין שם פריט'),
                      duration: kSnackBarDuration,
                    ),
                  );
                  return;
                }

                if (categoryController.text.trim().isEmpty) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('נא להזין קטגוריה'),
                      duration: kSnackBarDuration,
                    ),
                  );
                  return;
                }

                final quantity = int.tryParse(quantityController.text) ?? 1;
                final productName = nameController.text.trim();
                final category = categoryController.text.trim();
                final unit = unitController.text.trim();

                debugPrint('➕ MyPantryScreen: יוצר פריט - $productName (x$quantity $unit)');
                Navigator.pop(dialogContext);

                try {
                  final provider = context.read<InventoryProvider>();
                  await provider.createItem(
                    productName: productName,
                    category: category,
                    location: selectedLocation,
                    quantity: quantity,
                    unit: unit,
                  );
                  debugPrint('✅ MyPantryScreen: פריט נוצר');

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('הפריט נוסף בהצלחה'),
                      duration: kSnackBarDuration,
                    ),
                  );
                } catch (e) {
                  debugPrint('❌ MyPantryScreen: שגיאה ביצירה - $e');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה בהוספת פריט: $e'),
                      backgroundColor: Colors.red,
                      duration: kSnackBarDuration,
                    ),
                  );
                }
              },
              child: const Text('הוסף'),
            ),
          ],
        ),
      ),
    );
  }

  void _editItemDialog(InventoryItem item) {
    debugPrint('✏️ MyPantryScreen: עריכת פריט - ${item.id}');
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final nameController = TextEditingController(text: item.productName);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final unitController = TextEditingController(text: item.unit);
    final categoryController = TextEditingController(text: item.category);
    String selectedLocation = item.location;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cs.surface,
          title: Text(
            'עריכת פריט',
            style: TextStyle(color: accent),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: "שם הפריט",
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: kSpacingMedium),
                TextField(
                  controller: categoryController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: "קטגוריה",
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: kSpacingMedium),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: cs.onSurface),
                        decoration: InputDecoration(
                          labelText: "כמות",
                          labelStyle: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingMedium),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        style: TextStyle(color: cs.onSurface),
                        decoration: InputDecoration(
                          labelText: "יחידה",
                          labelStyle: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingMedium),
                DropdownButtonFormField<String>(
                  value: selectedLocation,
                  dropdownColor: cs.surface,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: "מיקום",
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  items: StorageLocationsConfig.allLocationIds.map((locationId) {
                    final info = StorageLocationsConfig.getLocationInfo(locationId);
                    return DropdownMenuItem(
                      value: locationId,
                      child: Row(
                        children: [
                          Text(info.emoji),
                          const SizedBox(width: kSpacingSmall),
                          Text(info.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedLocation = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('❌ MyPantryScreen: עריכה בוטלה');
                Navigator.pop(dialogContext);
              },
              child: Text(AppStrings.common.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(kButtonHeight, kButtonHeight),
              ),
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text) ?? item.quantity;
                
                debugPrint('✏️ MyPantryScreen: שומר שינויים - ${item.id}');
                Navigator.pop(dialogContext);

                try {
                  final provider = context.read<InventoryProvider>();
                  final updatedItem = item.copyWith(
                    productName: nameController.text.trim(),
                    category: categoryController.text.trim(),
                    location: selectedLocation,
                    quantity: quantity,
                    unit: unitController.text.trim(),
                  );
                  
                  await provider.updateItem(updatedItem);
                  debugPrint('✅ MyPantryScreen: פריט עודכן');

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('הפריט עודכן בהצלחה'),
                      duration: kSnackBarDuration,
                    ),
                  );
                } catch (e) {
                  debugPrint('❌ MyPantryScreen: שגיאה בעדכון - $e');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה בעדכון פריט: $e'),
                      backgroundColor: Colors.red,
                      duration: kSnackBarDuration,
                    ),
                  );
                }
              },
              child: const Text('שמור'),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // UI Helpers
  // ========================================

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: kIconSizeMedium),
        const SizedBox(width: kSpacingXTiny),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: kFontSizeTiny,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: kFontSizeBody,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListView(List<InventoryItem> items) {
    final cs = Theme.of(context).colorScheme;
    
    final filteredItems = items.where((item) {
      // סינון לפי קטגוריה
      if (_selectedCategory != 'all') {
        final categoryLower = item.category.toLowerCase();
        final selectedLower = _selectedCategory.toLowerCase();
        
        if (!categoryLower.contains(selectedLower) && 
            categoryLower != selectedLower) {
          return false;
        }
      }
      
      // סינון לפי חיפוש טקסט
      if (searchTerm.isEmpty) return true;
      final searchLower = searchTerm.toLowerCase();
      final locationName = StorageLocationsConfig.getName(item.location);
      return item.productName.toLowerCase().contains(searchLower) ||
          locationName.toLowerCase().contains(searchLower);
    }).toList();

    final Map<String, List<InventoryItem>> grouped = {};
    for (var item in filteredItems) {
      final key = StorageLocationsConfig.isValidLocation(item.location)
          ? item.location
          : StorageLocationsConfig.other;
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return Column(
      children: [
        // סינון קטגוריה
        Container(
          padding: const EdgeInsets.fromLTRB(
            kSpacingMedium,
            kSpacingMedium,
            kSpacingMedium,
            kSpacingSmall,
          ),
          color: cs.surfaceContainerLow,
          child: PantryFilters(
            currentCategory: _selectedCategory,
            onCategoryChanged: (category) {
              debugPrint('🔄 MyPantryScreen: Category changed: $category');
              setState(() => _selectedCategory = category);
            },
          ),
        ),
        
        // Search bar
        Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          color: cs.surfaceContainerLow,
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              debugPrint('🔍 MyPantryScreen: חיפוש - "$val"');
              setState(() => searchTerm = val);
            },
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: "חיפוש פריט או מיקום...",
              hintStyle: TextStyle(color: cs.onSurfaceVariant),
              prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
              suffixIcon: searchTerm.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: cs.onSurfaceVariant),
                      onPressed: () {
                        debugPrint('❌ MyPantryScreen: ניקוי חיפוש');
                        _searchController.clear();
                        setState(() => searchTerm = "");
                      },
                    )
                  : null,
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kBorderRadiusFull),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Stats bar
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingMedium,
            vertical: kSpacingSmallPlus,
          ),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
            border: Border(
              bottom: BorderSide(color: cs.outlineVariant),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip(
                icon: Icons.inventory,
                label: "סה״כ",
                value: items.length.toString(),
                color: cs.primary,
              ),
              _buildStatChip(
                icon: Icons.warning,
                label: "כמות נמוכה",
                value: items.where((i) => i.quantity <= 1).length.toString(),
                color: Colors.orange,
              ),
              _buildStatChip(
                icon: Icons.location_on,
                label: "מיקומים",
                value: grouped.length.toString(),
                color: Colors.blue,
              ),
            ],
          ),
        ),

        // Items list
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        searchTerm.isNotEmpty
                            ? Icons.search_off
                            : Icons.inventory_2_outlined,
                        size: kIconSizeXLarge,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: kSpacingMedium),
                      Text(
                        searchTerm.isNotEmpty
                            ? "לא נמצאו פריטים"
                            : "המזווה ריק - הוסיפו פריטים!",
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    final location = entry.key;
                    final locationItems = entry.value;
                    final locationInfo = StorageLocationsConfig.getLocationInfo(location);

                    return Card(
                      color: cs.surfaceContainer,
                      margin: const EdgeInsets.only(bottom: kSpacingMedium),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(kSpacingSmallPlus),
                            decoration: BoxDecoration(
                              color: locationInfo.color.withValues(alpha: 0.2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(kBorderRadius),
                                topRight: Radius.circular(kBorderRadius),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  locationInfo.emoji,
                                  style: const TextStyle(fontSize: kFontSizeLarge),
                                ),
                                const SizedBox(width: kSpacingSmall),
                                Text(
                                  locationInfo.name,
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: kFontSizeBody,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${locationItems.length} פריטים",
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: kFontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...locationItems.map((item) {
                            return ListTile(
                              title: Text(
                                item.productName,
                                style: TextStyle(color: cs.onSurface),
                              ),
                              subtitle: Text(
                                "${item.quantity} ${item.unit}",
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: kMinTouchTarget,
                                    height: kMinTouchTarget,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _updateQuantity(item.id, -1),
                                    ),
                                  ),
                                  SizedBox(
                                    width: kMinTouchTarget,
                                    height: kMinTouchTarget,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => _updateQuantity(item.id, 1),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ========================================
  // Build
  // ========================================

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          final items = provider.items;

          return Scaffold(
            backgroundColor: cs.surface,
            appBar: AppBar(
              backgroundColor: cs.surfaceContainer,
              title: const Text('המזווה שלי'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItemDialog,
                  tooltip: "הוסף פריט",
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.list), text: "רשימה"),
                  Tab(icon: Icon(Icons.location_on), text: "מיקומים"),
                ],
              ),
            ),
            body: provider.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: cs.primary),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // טאב 1: תצוגת רשימה
                      _buildListView(items),
                      
                      // טאב 2: ניהול מיקומים
                      StorageLocationManager(
                        inventory: items,
                        onEditItem: _editItemDialog,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
