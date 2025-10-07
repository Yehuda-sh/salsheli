// 📄 File: lib/widgets/storage_location_manager.dart
// תיאור: ווידג'ט לניהול ותצוגה של פריטים לפי מיקומי אחסון
//
// ✅ תיקונים גרסה 2.0:
// 1. תיקון keys של מיקומים (refrigerator במקום fridge)
// 2. מיפוי אמוג'י קטגוריות - תמיכה בעברית
// 3. Undo למחיקת מיקום
// 4. Cache לביצועים
// 5. עריכת מיקומים מותאמים
// 6. שמירת gridMode
// 7. סטטיסטיקות משופרות
// 8. בחירת אמוג'י בעת הוספה

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/inventory_item.dart';
import '../models/custom_location.dart';
import '../providers/locations_provider.dart';
import '../core/constants.dart';

class StorageLocationManager extends StatefulWidget {
  final List<InventoryItem> inventory;
  final Function(InventoryItem)? onEditItem;

  const StorageLocationManager({
    super.key,
    required this.inventory,
    this.onEditItem,
  });

  @override
  State<StorageLocationManager> createState() => _StorageLocationManagerState();
}

class _StorageLocationManagerState extends State<StorageLocationManager> {
  String selectedLocation = "all";
  String searchQuery = "";
  bool gridMode = true;
  String sortBy = "name"; // name, quantity, category

  final TextEditingController newLocationController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Cache לביצועים
  List<InventoryItem> _cachedFilteredItems = [];
  String _lastCacheKey = "";

  // מיפוי קטגוריות עברית -> אמוג'י
  final Map<String, String> _hebrewCategoryEmojis = {
    "חלבי": "🥛",
    "ירקות": "🥬",
    "פירות": "🍎",
    "בשר": "🥩",
    "עוף": "🍗",
    "דגים": "🐟",
    "לחם": "🍞",
    "חטיפים": "🍿",
    "משקאות": "🥤",
    "ניקיון": "🧼",
    "שימורים": "🥫",
    "קפואים": "🧊",
    "תבלינים": "🧂",
    "אחר": "📦",
  };

  // רשימת אמוג'י לבחירה
  final List<String> _availableEmojis = [
    "📍", "🏠", "❄️", "🧊", "📦", "🛁", "🧺", "🚗", "🧼", "🧂",
    "🍹", "🍕", "🎁", "🎒", "🧰", "🎨", "📚", "🔧", "🏺", "🗄️"
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('🏗️ StorageLocationManager.initState()');
    _loadGridMode();
  }

  @override
  void dispose() {
    debugPrint('🗑️ StorageLocationManager.dispose()');
    newLocationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// טעינת העדפת תצוגה
  Future<void> _loadGridMode() async {
    debugPrint('📥 StorageLocationManager._loadGridMode()');
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getBool('storage_grid_mode') ?? true;
      debugPrint('   ✅ gridMode: $savedMode');
      setState(() {
        gridMode = savedMode;
      });
    } catch (e) {
      debugPrint('❌ StorageLocationManager._loadGridMode: שגיאה - $e');
      // ברירת מחדל
      setState(() {
        gridMode = true;
      });
    }
  }

  /// שמירת העדפת תצוגה
  Future<void> _saveGridMode(bool value) async {
    debugPrint('💾 StorageLocationManager._saveGridMode($value)');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('storage_grid_mode', value);
      debugPrint('   ✅ שמור בהצלחה');
    } catch (e) {
      debugPrint('❌ StorageLocationManager._saveGridMode: שגיאה - $e');
    }
  }

  /// סינון מלאי לפי מיקום וחיפוש עם Cache
  List<InventoryItem> get filteredInventory {
    final cacheKey = "$selectedLocation|$searchQuery|$sortBy";
    
    if (cacheKey == _lastCacheKey && _cachedFilteredItems.isNotEmpty) {
      debugPrint('⚡ StorageLocationManager.filteredInventory: Cache HIT');
      return _cachedFilteredItems;
    }
    
    debugPrint('🔄 StorageLocationManager.filteredInventory: Cache MISS - מחשב מחדש');
    debugPrint('   📍 מיקום: $selectedLocation | 🔍 חיפוש: "$searchQuery" | 🔀 מיון: $sortBy');

    var items = widget.inventory;

    // סינון לפי מיקום
    if (selectedLocation != "all") {
      items = items.where((i) => i.location == selectedLocation).toList();
    }

    // סינון לפי חיפוש - לא רגיש לאותיות גדולות/קטנות
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      items = items
          .where(
            (i) =>
                i.productName.toLowerCase().contains(query) ||
                i.category.toLowerCase().contains(query) ||
                i.location.toLowerCase().contains(query),
          )
          .toList();
    }

    // מיון
    switch (sortBy) {
      case "quantity":
        items.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case "category":
        items.sort((a, b) => a.category.compareTo(b.category));
        break;
      case "name":
      default:
        items.sort((a, b) => a.productName.compareTo(b.productName));
    }

    _cachedFilteredItems = items;
    _lastCacheKey = cacheKey;
    debugPrint('   ✅ תוצאה: ${items.length} פריטים');

    return items;
  }

  /// קבלת אמוג'י לפי קטגוריה (תמיכה בעברית)
  String _getProductEmoji(String category) {
    // חיפוש קודם בעברית
    if (_hebrewCategoryEmojis.containsKey(category)) {
      return _hebrewCategoryEmojis[category]!;
    }
    
    // נסיון בקטגוריות אנגלית
    if (kCategoryEmojis.containsKey(category)) {
      return kCategoryEmojis[category]!;
    }
    
    return "📦";
  }

  /// הצגת דיאלוג להוספת מיקום חדש
  void _showAddLocationDialog() {
    debugPrint('➕ StorageLocationManager._showAddLocationDialog()');
    newLocationController.clear();
    String selectedEmoji = "📍";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text("הוספת מיקום חדש"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // בחירת אמוג'י
                    const Text("בחר אמוג'י:", style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableEmojis.map((emoji) {
                        final isSelected = emoji == selectedEmoji;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedEmoji = emoji;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.indigo.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.indigo
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // שם המיקום
                    TextField(
                      controller: newLocationController,
                      decoration: const InputDecoration(
                        labelText: "שם המיקום",
                        hintText: 'לדוגמה: "מקרר קטן"',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("ביטול"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final name = newLocationController.text.trim();
                      if (name.isEmpty) {
                        debugPrint('   ⚠️ שם ריק - מבטל');
                        return;
                      }

                      debugPrint('   💾 מוסיף מיקום: "$name" $selectedEmoji');
                      final provider = context.read<LocationsProvider>();
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(dialogContext);

                      final success = await provider.addLocation(
                        name,
                        emoji: selectedEmoji,
                      );

                      if (mounted) {
                        navigator.pop();

                        if (success) {
                          debugPrint('   ✅ מיקום נוסף בהצלחה');
                          messenger.showSnackBar(
                            SnackBar(content: Text("נוסף מיקום חדש: $name")),
                          );
                        } else {
                          debugPrint('   ❌ מיקום כבר קיים');
                          messenger.showSnackBar(
                            const SnackBar(content: Text("מיקום זה כבר קיים")),
                          );
                        }
                      }
                    },
                    child: const Text("הוסף"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// עריכת מיקום מותאם
  void _showEditLocationDialog(CustomLocation loc) {
    debugPrint('✏️ StorageLocationManager._showEditLocationDialog("${loc.name}")');
    newLocationController.text = loc.name;
    String selectedEmoji = loc.emoji;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text("עריכת מיקום"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // בחירת אמוג'י
                    const Text("בחר אמוג'י:", style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableEmojis.map((emoji) {
                        final isSelected = emoji == selectedEmoji;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedEmoji = emoji;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.indigo.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.indigo
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newLocationController,
                      decoration: const InputDecoration(
                        labelText: "שם המיקום",
                        border: OutlineInputBorder(),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("ביטול"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final name = newLocationController.text.trim();
                      if (name.isEmpty) {
                        debugPrint('   ⚠️ שם ריק - מבטל');
                        return;
                      }

                      debugPrint('   💾 מעדכן מיקום: "${loc.name}" → "$name" $selectedEmoji');
                      final provider = context.read<LocationsProvider>();
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(dialogContext);

                      // מחק את הישן והוסף חדש
                      await provider.deleteLocation(loc.key);
                      await provider.addLocation(name, emoji: selectedEmoji);

                      if (mounted) {
                        navigator.pop();
                        debugPrint('   ✅ מיקום עודכן בהצלחה');
                        messenger.showSnackBar(
                          const SnackBar(content: Text("המיקום עודכן")),
                        );
                      }
                    },
                    child: const Text("שמור"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// מחיקת מיקום מותאם עם אישור + Undo
  void _deleteCustomLocation(String key, String name, String emoji) {
    debugPrint('🗑️ StorageLocationManager._deleteCustomLocation("$name")');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text("מחיקת מיקום"),
            content: Text('האם למחוק את "$name"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("ביטול"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  debugPrint('   ⚠️ מאשר מחיקה...');
                  final provider = context.read<LocationsProvider>();
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(dialogContext);

                  await provider.deleteLocation(key);
                  debugPrint('   ✅ מיקום נמחק');

                  if (mounted) {
                    navigator.pop();
                    
                    // הצג Snackbar עם Undo
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text("המיקום נמחק"),
                        action: SnackBarAction(
                          label: "בטל",
                          onPressed: () async {
                            debugPrint('   🔄 Undo: משחזר מיקום "$name"');
                            await provider.addLocation(name, emoji: emoji);
                          },
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                },
                child: const Text("מחק"),
              ),
            ],
          ),
        );
      },
    );
  }

  /// עריכת פריט
  void _editItem(InventoryItem item) {
    if (widget.onEditItem != null) {
      widget.onEditItem!(item);
    }
  }

  /// בניית כרטיס מיקום
  Widget _buildLocationCard({
    required String key,
    required String name,
    required String emoji,
    required int count,
    required List<CustomLocation> customLocations,
    bool isCustom = false,
  }) {
    final isSelected = selectedLocation == key;
    final lowStockCount = widget.inventory
        .where((i) => i.location == key && i.quantity <= 2)
        .length;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLocation = key;
          _lastCacheKey = ""; // נקה cache
        });
      },
      onLongPress: isCustom
          ? () => _deleteCustomLocation(key, name, emoji)
          : null,
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? Colors.indigo.shade50 : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const Spacer(),
                  if (isCustom)
                    Tooltip(
                      message: "לחץ לעריכה, לחץ ארוכה למחיקה",
                      child: GestureDetector(
                        onTap: () {
                          try {
                            final loc = customLocations.firstWhere(
                              (l) => l.key == key,
                            );
                            _showEditLocationDialog(loc);
                          } catch (e) {
                            // מיקום לא נמצא
                          }
                        },
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.indigo : null,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    count == 0 ? "ריק" : "$count",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: count == 0 ? Colors.grey : Colors.indigo,
                    ),
                  ),
                  if (lowStockCount > 0) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.warning,
                      size: 14,
                      color: Colors.orange.shade700,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // יצירת עותק modifiable של הרשימה
    final customLocations = List<CustomLocation>.from(
      context.watch<LocationsProvider>().customLocations,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          /// 🔝 כותרת וכפתורים
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.indigo),
                  const SizedBox(width: 8),
                  const Text(
                    "ניהול אזורי אחסון",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  // מיון
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    tooltip: "מיון",
                    onSelected: (value) {
                      setState(() {
                        sortBy = value;
                        _lastCacheKey = ""; // נקה cache
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "name",
                        child: Row(
                          children: [
                            Icon(Icons.sort_by_alpha),
                            SizedBox(width: 8),
                            Text("לפי שם"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "quantity",
                        child: Row(
                          children: [
                            Icon(Icons.numbers),
                            SizedBox(width: 8),
                            Text("לפי כמות"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "category",
                        child: Row(
                          children: [
                            Icon(Icons.category),
                            SizedBox(width: 8),
                            Text("לפי קטגוריה"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // תצוגה
                  IconButton(
                    icon: Icon(gridMode ? Icons.list : Icons.grid_view),
                    tooltip: gridMode ? "תצוגת רשימה" : "תצוגת רשת",
                    onPressed: () {
                      setState(() {
                        gridMode = !gridMode;
                      });
                      _saveGridMode(gridMode);
                    },
                  ),
                  // הוספה
                  IconButton(
                    icon: const Icon(Icons.add_location),
                    tooltip: "הוסף מיקום חדש",
                    onPressed: _showAddLocationDialog,
                  ),
                ],
              ),
            ),
          ),

          /// 🔍 שדה חיפוש
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "חיפוש פריט",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = "";
                            _lastCacheKey = "";
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _lastCacheKey = "";
                });
              },
            ),
          ),

          /// תוכן מרכזי
          Expanded(
            child: Column(
              children: [
                /// 📦 רשימת מיקומים
                SizedBox(
                  height: gridMode ? 200 : 150,
                  child: GridView.count(
                    crossAxisCount: gridMode ? 3 : 1,
                    childAspectRatio: gridMode ? 1.2 : 5,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      // כרטיס "הכל"
                      _buildLocationCard(
                        key: "all",
                        name: "הכל",
                        emoji: "🏪",
                        count: widget.inventory.length,
                        customLocations: customLocations,
                      ),

                      // מיקומי ברירת מחדל
                      ...kStorageLocations.entries.map((entry) {
                        final key = entry.key;
                        final config = entry.value;
                        final count = widget.inventory
                            .where((i) => i.location == key)
                            .length;
                        return _buildLocationCard(
                          key: key,
                          name: config["name"] ?? "",
                          emoji: config["emoji"] ?? "📍",
                          count: count,
                          customLocations: customLocations,
                        );
                      }),

                      // מיקומים מותאמים
                      ...customLocations.map((loc) {
                        final count = widget.inventory
                            .where((i) => i.location == loc.key)
                            .length;
                        return _buildLocationCard(
                          key: loc.key,
                          name: loc.name,
                          emoji: loc.emoji,
                          count: count,
                          customLocations: customLocations,
                          isCustom: true,
                        );
                      }),
                    ],
                  ),
                ),

                const Divider(),

                /// 📋 פריטים
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // כותרת
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                color: Colors.indigo.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getLocationTitle(customLocations),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${filteredInventory.length} פריטים",
                                style: TextStyle(
                                  color: Colors.indigo.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // רשימה
                        Expanded(
                          child: filteredInventory.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        searchQuery.isNotEmpty
                                            ? Icons.search_off
                                            : Icons.inventory_2_outlined,
                                        size: 64,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        searchQuery.isNotEmpty
                                            ? "לא נמצאו פריטים"
                                            : "אין פריטים במיקום זה",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredInventory.length,
                                  itemBuilder: (_, index) {
                                    final item = filteredInventory[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.indigo.shade50,
                                        child: Text(
                                          _getProductEmoji(item.category),
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      title: Text(
                                        item.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Icon(
                                            Icons.inventory,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text("${item.quantity} ${item.unit}"),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.category,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(item.category),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (item.quantity <= 2)
                                            Icon(
                                              Icons.warning,
                                              color: Colors.orange.shade700,
                                              size: 20,
                                            ),
                                          if (widget.onEditItem != null)
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () => _editItem(item),
                                              tooltip: "ערוך פריט",
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
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
    );
  }

  String _getLocationTitle(List<CustomLocation> customLocations) {
    if (selectedLocation == "all") return "כל הפריטים";

    if (kStorageLocations.containsKey(selectedLocation)) {
      return kStorageLocations[selectedLocation]!["name"]!;
    }

    try {
      final custom = customLocations.firstWhere(
        (loc) => loc.key == selectedLocation,
      );
      return custom.name;
    } catch (e) {
      return selectedLocation;
    }
  }
}
