// 📄 File: lib/screens/pantry/my_pantry_screen.dart
// Description: מסך ניהול מזווה - מחובר ל-InventoryProvider
//
// ✅ שיפורים גרסה 2.0:
// 1. הוספת 2 טאבים: תצוגת רשימה + ניהול מיקומים
// 2. שילוב StorageLocationManager
// 3. תיקון withValues ל-withOpacity
// 4. הוספת עריכת פריטים

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models & Providers
import '../../models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/storage_location_manager.dart';
import '../../widgets/pantry_filters.dart';

class MyPantryScreen extends StatefulWidget {
  const MyPantryScreen({super.key});

  @override
  State<MyPantryScreen> createState() => _MyPantryScreenState();
}

class _MyPantryScreenState extends State<MyPantryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchTerm = "";
  String _selectedCategory = 'all'; // סינון קטגוריה
  
  late TabController _tabController;

  final Map<String, Map<String, dynamic>> locationConfig = {
    "refrigerator": {"name": "מקרר", "emoji": "❄️", "color": Colors.blue},
    "freezer": {"name": "מקפיא", "emoji": "🧊", "color": Colors.cyan},
    "main_pantry": {"name": "מזווה ראשי", "emoji": "🏠", "color": Colors.amber},
    "secondary_storage": {"name": "מחסן", "emoji": "📦", "color": Colors.brown},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InventoryProvider>().loadItems();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateQuantity(String itemId, int delta) async {
    try {
      final provider = context.read<InventoryProvider>();
      final item = provider.items.firstWhere((i) => i.id == itemId);

      final newQuantity = (item.quantity + delta).clamp(0, 99);

      if (newQuantity == 0) {
        _confirmRemoveItem(itemId);
        return;
      }

      final updatedItem = item.copyWith(quantity: newQuantity);
      await provider.updateItem(updatedItem);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בעדכון כמות: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmRemoveItem(String itemId) {
    final provider = context.read<InventoryProvider>();
    final item = provider.items.firstWhere((i) => i.id == itemId);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('הסרת פריט', style: TextStyle(color: Colors.amber)),
        content: Text(
          'להסיר את ${item.productName} מהמזווה?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await provider.deleteItem(itemId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('הפריט הוסר מהמזווה')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה בהסרת פריט: $e'),
                      backgroundColor: Colors.red,
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
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: "1");
    final unitController = TextEditingController(text: "יח'");
    final categoryController = TextEditingController();
    String selectedLocation = "main_pantry";

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'הוספת פריט',
            style: TextStyle(color: Colors.amber),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "שם הפריט",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "קטגוריה",
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: "לדוגמה: חלבי",
                    hintStyle: TextStyle(color: Colors.white30),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "כמות",
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "יחידה",
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedLocation,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "מיקום",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  items: locationConfig.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Text(entry.value["emoji"]),
                          const SizedBox(width: 8),
                          Text(entry.value["name"]),
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('נא להזין שם פריט')),
                  );
                  return;
                }

                if (categoryController.text.trim().isEmpty) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('נא להזין קטגוריה')),
                  );
                  return;
                }

                final quantity = int.tryParse(quantityController.text) ?? 1;
                final productName = nameController.text.trim();
                final category = categoryController.text.trim();
                final unit = unitController.text.trim();

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

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('הפריט נוסף בהצלחה')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה בהוספת פריט: $e'),
                      backgroundColor: Colors.red,
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
    final nameController = TextEditingController(text: item.productName);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final unitController = TextEditingController(text: item.unit);
    final categoryController = TextEditingController(text: item.category);
    String selectedLocation = item.location;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'עריכת פריט',
            style: TextStyle(color: Colors.amber),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "שם הפריט",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "קטגוריה",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "כמות",
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "יחידה",
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedLocation,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "מיקום",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  items: locationConfig.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Text(entry.value["emoji"]),
                          const SizedBox(width: 8),
                          Text(entry.value["name"]),
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text) ?? item.quantity;
                
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

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('הפריט עודכן בהצלחה')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה בעדכון פריט: $e'),
                      backgroundColor: Colors.red,
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

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListView(List<InventoryItem> items) {
    final filteredItems = items.where((item) {
      // סינון לפי קטגוריה
      if (_selectedCategory != 'all') {
        // השוואה רגישה למקרה (case-insensitive) כי הקטגוריות במודל בעברית
        final categoryLower = item.category.toLowerCase();
        final selectedLower = _selectedCategory.toLowerCase();
        
        // אם הקטגוריה לא תואמת, סנן החוצה
        if (!categoryLower.contains(selectedLower) && 
            categoryLower != selectedLower) {
          return false;
        }
      }
      
      // סינון לפי חיפוש טקסט
      if (searchTerm.isEmpty) return true;
      final searchLower = searchTerm.toLowerCase();
      final locationName = locationConfig[item.location]?["name"] ?? "";
      return item.productName.toLowerCase().contains(searchLower) ||
          locationName.toLowerCase().contains(searchLower);
    }).toList();

    final Map<String, List<InventoryItem>> grouped = {};
    for (var item in filteredItems) {
      final key = locationConfig.containsKey(item.location)
          ? item.location
          : 'other';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return Column(
      children: [
        // סינון קטגוריה
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          color: const Color(0xFF1E293B),
          child: PantryFilters(
            currentCategory: _selectedCategory,
            onCategoryChanged: (category) {
              debugPrint('🔄 Category changed: $category');
              setState(() => _selectedCategory = category);
            },
          ),
        ),
        
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1E293B),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => searchTerm = val),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "חיפוש פריט או מיקום...",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: searchTerm.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => searchTerm = "");
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Stats bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade800.withValues(alpha: 0.5),
            border: Border(
              bottom: BorderSide(color: Colors.blueGrey.shade700),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip(
                icon: Icons.inventory,
                label: "סה״כ",
                value: items.length.toString(),
                color: Colors.amber,
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
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchTerm.isNotEmpty
                            ? "לא נמצאו פריטים"
                            : "המזווה ריק - הוסיפו פריטים!",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    final location = entry.key;
                    final locationItems = entry.value;
                    final config = locationConfig[location];

                    return Card(
                      color: Colors.blueGrey.shade800.withValues(alpha: 0.8),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (config?["color"] as Color?)
                                  ?.withValues(alpha: 0.2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  config?["emoji"] ?? "📍",
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  config?["name"] ?? "אחר",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${locationItems.length} פריטים",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...locationItems.map((item) {
                            return ListTile(
                              title: Text(
                                item.productName,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "${item.quantity} ${item.unit}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _updateQuantity(item.id, -1),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                    ),
                                    onPressed: () => _updateQuantity(item.id, 1),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final items = provider.items;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
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
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
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
    );
  }
}
