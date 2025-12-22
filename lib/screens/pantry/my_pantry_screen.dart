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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/inventory_item.dart';
import '../../providers/groups_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/user_context.dart';
import '../../services/notifications_service.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/inventory/pantry_empty_state.dart';
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
    _searchController.dispose();
    super.dispose();
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
    if (kDebugMode) {
      debugPrint('🗑️ MyPantryScreen: מחיקת פריט - ${item.id}');
    }
    try {
      await context.read<InventoryProvider>().deleteItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.productName} נמחק')),
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
    }
  }

  /// מעדכן כמות פריט במזווה
  Future<void> _updateQuantity(InventoryItem item, int newQuantity) async {
    if (kDebugMode) {
      debugPrint('📦 MyPantryScreen: עדכון כמות - ${item.id} -> $newQuantity');
    }
    try {
      // בדוק אם הפריט עובר למלאי נמוך (לפני שהיה מעל הסף)
      final wasAboveMin = item.quantity > item.minQuantity;
      final willBeLow = newQuantity <= item.minQuantity;

      final updatedItem = item.copyWith(quantity: newQuantity);
      await context.read<InventoryProvider>().updateItem(updatedItem);

      // שלח התראות אם הפריט הפך למלאי נמוך
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
    }
  }

  /// שולח התראה על מלאי נמוך לכל חברי הקבוצה (מזווה משותף)
  Future<void> _sendLowStockNotification(InventoryItem item) async {
    try {
      final inventoryProvider = context.read<InventoryProvider>();
      final userContext = context.read<UserContext>();
      final groupsProvider = context.read<GroupsProvider>();

      // אם זה מזווה קבוצתי - שלח התראה לכל החברים
      if (inventoryProvider.isGroupMode && inventoryProvider.currentGroupId != null) {
        final groupId = inventoryProvider.currentGroupId!;
        final group = groupsProvider.groups.where((g) => g.id == groupId).firstOrNull;

        if (group != null) {
          final notificationsService = NotificationsService(FirebaseFirestore.instance);
          final currentUserId = userContext.userId;

          // שלח לכל חברי הקבוצה (חוץ מהמשתמש הנוכחי)
          for (final member in group.membersList) {
            if (member.userId != currentUserId) {
              await notificationsService.createLowStockNotification(
                userId: member.userId,
                householdId: group.id, // Group ID serves as householdId for family groups
                productName: item.productName,
                currentStock: item.quantity,
                minStock: item.minQuantity,
              );
            }
          }

          if (kDebugMode) {
            debugPrint('📬 נשלחו התראות מלאי נמוך לחברי הקבוצה: ${item.productName}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ שגיאה בשליחת התראת מלאי נמוך: $e');
      }
      // לא מפריע למשתמש - התראה היא nice-to-have
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
                : items.isEmpty && !_isSearching
                    // מסך ריק כשאין פריטים בכלל
                    ? Stack(
                        children: [
                          const NotebookBackground(),
                          PantryEmptyState(
                            isGroupMode: provider.isGroupMode,
                            groupName: provider.isGroupMode
                                ? provider.inventoryTitle
                                : null,
                            onAddItem: _addItemDialog,
                          ),
                        ],
                      )
                    // תצוגה רגילה
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
