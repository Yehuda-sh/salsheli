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
// - שימוש ב-PantryItemDialog מאוחד (חיסכון ~335 שורות קוד)
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
// Version: 3.1
// Last Updated: 26/10/2025
// Changes: Refactored to use unified PantryItemDialog

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/storage_locations_config.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/inventory/pantry_filters.dart';
import '../../widgets/inventory/pantry_item_dialog.dart';
import '../../widgets/inventory/storage_location_manager.dart';

class MyPantryScreen extends StatefulWidget {
  const MyPantryScreen({super.key});

  @override
  State<MyPantryScreen> createState() => _MyPantryScreenState();
}

class _MyPantryScreenState extends State<MyPantryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchTerm = '';
  String _selectedCategory = 'all';
  Timer? _debounceTimer;
  
  late TabController _tabController;
  final Set<String> _selectedItemIds = {}; // פריטים מסומנים להוספה לרשימה

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
    _debounceTimer?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ========================================
  // Actions
  // ========================================

  /// מעדכן את כמות הפריט - מוסיף או מוריד delta
  /// אם הכמות מגיעה ל-0, מציג דיאלוג אישור מחיקה
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
          const SnackBar(
            content: Text('שגיאה בעדכון כמות'),
            backgroundColor: Colors.red,
            duration: kSnackBarDuration,
          ),
        );
      }
    }
  }

  /// מציג דיאלוג אישור להסרת פריט מהמזווה
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
              if (!context.mounted) return;
              try {
                await provider.deleteItem(itemId);
                debugPrint('✅ MyPantryScreen: פריט נמחק');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('הפריט הוסר מהמזווה'),
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

  /// מציג דיאלוג להוספת פריט חדש למזווה
  void _addItemDialog() {
    debugPrint('➕ MyPantryScreen: פתיחת דיאלוג הוספת פריט');
    PantryItemDialog.showAddDialog(context);
  }

  /// מציג דיאלוג לעריכת פרטי פריט קיים
  void _editItemDialog(InventoryItem item) {
    debugPrint('✏️ MyPantryScreen: עריכת פריט - ${item.id}');
    PantryItemDialog.showEditDialog(context, item);
  }

  // ========================================
  // UI Helpers
  // ========================================

  /// בונה chip סטטיסטיקה קטן עם אייקון, תווית וערך
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color stickyColor,
  }) {
    return StickyNote(
      color: stickyColor,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: kIconSizeMedium),
            const SizedBox(height: kSpacingXTiny),
            Text(
              label,
              style: const TextStyle(
                fontSize: kFontSizeTiny,
                color: Colors.black87,
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
      ),
    );
  }

  /// מוסיף פריטים מסומנים לרשימת קניות
  Future<void> _addSelectedToShoppingList() async {
    if (_selectedItemIds.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אנא בחר פריטים להוספה'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final provider = context.read<InventoryProvider>();
    final listsProvider = context.read<ShoppingListsProvider>();
    
    // קבל את הרשימה הפעילה הראשונה או צור חדשה
    String? targetListId;
    final activeLists = listsProvider.lists
        .where((l) => l.status == 'active')
        .toList();
    
    if (activeLists.isNotEmpty) {
      // יש רשימה פעילה - הוסף אליה
      targetListId = activeLists.first.id;
    } else {
      // צור רשימה חדשה
      try {
        final newList = await listsProvider.createList(
          name: 'רשימת קניות חדשה',
          type: 'grocery',
        );
        targetListId = newList.id;
      } catch (e) {
        debugPrint('❌ שגיאה ביצירת רשימה: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה ביצירת רשימה: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    // הוסף את הפריטים המסומנים לרשימה
    int addedCount = 0;
    for (var itemId in _selectedItemIds) {
      final item = provider.items.firstWhere((i) => i.id == itemId);
      
      try {
        await listsProvider.addItemToList(
          targetListId,
          item.productName,
          1, // כמות ברירת מחדל
          item.unit,
        );
        addedCount++;
      } catch (e) {
        debugPrint('❌ שגיאה בהוספת ${item.productName}: $e');
      }
    }
    
    setState(() {
      _selectedItemIds.clear();
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ נוספו $addedCount פריטים לרשימת הקניות'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'צפה ברשימה',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(
            context,
            '/manage-list',
            arguments: {'listId': targetListId},
          ),
        ),
      ),
    );
  }
  
  /// בונה את תצוגת הרשימה המלאה עם סינון וקיבוץ לפי מיקומים
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
          color: kPaperBackground,
          child: StickyNote(
            color: kStickyYellow,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingSmall),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  // Debounce: המתן 300ms לפני חיפוש
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      debugPrint('🔍 MyPantryScreen: חיפוש - "$val"');
                      setState(() => searchTerm = val);
                    }
                  });
                },
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'חיפוש פריט או מיקום...',
                  hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.search, color: Colors.black.withValues(alpha: 0.5)),
                  suffixIcon: searchTerm.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.black54),
                          onPressed: () {
                            debugPrint('❌ MyPantryScreen: ניקוי חיפוש');
                            _searchController.clear();
                            setState(() => searchTerm = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium,
                    vertical: kSpacingSmall,
                  ),
                ),
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
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip(
                icon: Icons.inventory,
                label: 'סה״כ',
                value: items.length.toString(),
                color: Colors.blue,
                stickyColor: kStickyCyan,
              ),
              _buildStatChip(
                icon: Icons.warning,
                label: 'כמות נמוכה',
                value: items.where((i) => i.quantity <= 1).length.toString(),
                color: Colors.orange,
                stickyColor: kStickyOrange,
              ),
              _buildStatChip(
                icon: Icons.location_on,
                label: 'מיקומים',
                value: grouped.length.toString(),
                color: Colors.purple,
                stickyColor: kStickyPurple,
              ),
            ],
          ),
        ),

        // Items list
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingXLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchTerm.isNotEmpty
                              ? Icons.search_off
                              : Icons.kitchen_outlined,
                          size: 120,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: kSpacingLarge),
                        Text(
                          searchTerm.isNotEmpty
                              ? 'לא נמצאו פריטים'
                              : 'המזווה שלך ריקה 🎉',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: kSpacingSmall),
                        Text(
                          searchTerm.isNotEmpty
                              ? 'נסה לחפש משהו אחר'
                              : 'התחל לנהל את המלאי שלך',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (searchTerm.isEmpty) ...[
                          const SizedBox(height: kSpacingXLarge),
                          StickyButton(
                            label: 'הוסף פריט ראשון',
                            color: kStickyGreen,
                            onPressed: _addItemDialog,
                            icon: Icons.add,
                          ),
                          const SizedBox(height: kSpacingMedium),
                          Text(
                            'טיפ: תוכל גם להוסיף פריטים בסיום קנייה',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
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

                    final stickyColors = [kStickyYellow, kStickyCyan, kStickyGreen, kStickyPurple, kStickyOrange];
                    final stickyColor = stickyColors[index % stickyColors.length];
                    final rotation = (index % 3 - 1) * 0.01; // -0.01, 0, 0.01
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: kSpacingMedium),
                      child: StickyNote(
                        color: stickyColor,
                        rotation: rotation,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(kSpacingSmallPlus),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.05),
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
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: kFontSizeBody,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${locationItems.length} פריטים',
                                    style: TextStyle(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      fontSize: kFontSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...locationItems.map((item) {
                              final isSelected = _selectedItemIds.contains(item.id);
                              final needsRefill = item.quantity <= 1;
                              
                              return ListTile(
                                tileColor: isSelected 
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : null,
                                leading: Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedItemIds.add(item.id);
                                    } else {
                                      _selectedItemIds.remove(item.id);
                                    }
                                  });
                                },
                                activeColor: kStickyGreen,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                        item.productName,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          decoration: needsRefill 
                                              ? TextDecoration.lineThrough 
                                              : null,
                                        ),
                                      ),
                                  ),
                                  if (needsRefill)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'חסר',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                                subtitle: Text(
                                  '${item.quantity} ${item.unit}',
                                  style: TextStyle(
                                    color: item.quantity == 0 
                                        ? Colors.red 
                                        : Colors.black54,
                                    fontWeight: item.quantity == 0 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: SizedBox(
                                  width: kMinTouchTarget * 2,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _updateQuantity(item.id, -1),
                                        ),
                                      ),
                                      Expanded(
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
                                ),
                              );
                            }),
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

  // ========================================
  // Build
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          final items = provider.items;

          return Scaffold(
            backgroundColor: kPaperBackground,
            appBar: AppBar(
              backgroundColor: kStickyCyan,
              title: Text(_selectedItemIds.isEmpty 
                  ? 'המזווה שלי' 
                  : '${_selectedItemIds.length} נבחרו'),
              actions: [
                if (_selectedItemIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: _addSelectedToShoppingList,
                    tooltip: 'הוסף לרשימת קניות',
                    color: Colors.green,
                  ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItemDialog,
                  tooltip: 'הוסף פריט',
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.list), text: 'רשימה'),
                  Tab(icon: Icon(Icons.location_on), text: 'מיקומים'),
                ],
              ),
            ),
            body: provider.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: kStickyCyan),
                        const SizedBox(height: kSpacingMedium),
                        const Text('טוען...'),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      const NotebookBackground(),
                      TabBarView(
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
                    ],
                  ),
          );
        },
      ),
    );
  }
}
