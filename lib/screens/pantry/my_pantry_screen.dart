// 📄 File: lib/screens/pantry/my_pantry_screen.dart
//
// 🎯 מטרה: מסך ניהול מזווה - ניהול פריטי מלאי לפי מיקומים
//
// 📋 כולל:
// - תצוגת פריטים לפי מיקומי אחסון
// - חיפוש וסינון
// - CRUD מלא: הוספה, עריכה, מחיקה, עדכון כמות
// - ניהול מיקומים מותאמים
//
// 🔗 Dependencies:
// - InventoryProvider: ניהול state
// - StorageLocationsConfig: תצורת מיקומים
// - StorageLocationManager: widget ניהול מיקומים
//
// Version: 4.0
// Last Updated: 30/11/2025
// Changes: Simplified to single view (locations only)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/inventory/pantry_item_dialog.dart';
import '../../widgets/inventory/pantry_product_selection_sheet.dart';
import '../../widgets/inventory/storage_location_manager.dart';

class MyPantryScreen extends StatefulWidget {
  const MyPantryScreen({super.key});

  @override
  State<MyPantryScreen> createState() => _MyPantryScreenState();
}

class _MyPantryScreenState extends State<MyPantryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    debugPrint('📦 MyPantryScreen: initState');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('🔄 MyPantryScreen: טעינת פריטים');
        context.read<InventoryProvider>().loadItems();
      }
    });
  }

  /// מציג bottom sheet לבחירת מוצר מהקטלוג
  void _addItemDialog() {
    debugPrint('➕ MyPantryScreen: פתיחת בחירת מוצר מהקטלוג');
    PantryProductSelectionSheet.show(context);
  }

  /// מציג דיאלוג לעריכת פרטי פריט קיים
  void _editItemDialog(InventoryItem item) {
    debugPrint('✏️ MyPantryScreen: עריכת פריט - ${item.id}');
    PantryItemDialog.showEditDialog(context, item);
  }

  /// מוחק פריט מהמזווה
  Future<void> _deleteItem(InventoryItem item) async {
    debugPrint('🗑️ MyPantryScreen: מחיקת פריט - ${item.id}');
    try {
      await context.read<InventoryProvider>().deleteItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.productName} נמחק')),
        );
      }
    } catch (e) {
      debugPrint('❌ MyPantryScreen: שגיאה במחיקת פריט - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה במחיקת פריט')),
        );
      }
    }
  }

  /// מעדכן כמות פריט במזווה
  Future<void> _updateQuantity(InventoryItem item, int newQuantity) async {
    debugPrint('📦 MyPantryScreen: עדכון כמות - ${item.id} -> $newQuantity');
    try {
      final updatedItem = item.copyWith(quantity: newQuantity);
      await context.read<InventoryProvider>().updateItem(updatedItem);
    } catch (e) {
      debugPrint('❌ MyPantryScreen: שגיאה בעדכון כמות - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה בעדכון כמות')),
        );
      }
    }
  }

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
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'חיפוש...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    )
                  : const Text('המזווה שלי'),
              actions: [
                // חיפוש
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    });
                  },
                  tooltip: _isSearching ? 'סגור חיפוש' : 'חיפוש',
                ),
              ],
            ),
            // כפתור צף להוספת מוצר - בצד שמאל למטה (כי RTL)
            floatingActionButton: FloatingActionButton(
              onPressed: _addItemDialog,
              backgroundColor: kStickyCyan,
              tooltip: 'הוסף מוצר',
              child: const Icon(Icons.add, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: provider.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: kStickyCyan),
                        SizedBox(height: kSpacingMedium),
                        Text('טוען...'),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      const NotebookBackground(),
                      StorageLocationManager(
                        inventory: items,
                        searchQuery: _searchQuery,
                        onEditItem: _editItemDialog,
                        onDeleteItem: _deleteItem,
                        onUpdateQuantity: _updateQuantity,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
