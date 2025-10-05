// 📄 File: lib/screens/shopping/shopping_lists_screen.dart - UPDATED
//
// ✅ עודכן:
// 1. העברת type ו-budget ל-Provider
// 2. שיפור טיפול ב-context אחרי async
// 3. הוספת תיעוד
//
// 🇮🇱 מסך רשימות קניות:
//     - מציג את כל הרשימות של המשתמש.
//     - תומך ביצירה, מחיקה ופתיחה של רשימה.
//     - כולל מצב טעינה, שגיאה ומצב ריק.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../widgets/create_list_dialog.dart';
import '../../widgets/shopping_list_tile.dart';
import './active_shopping_screen.dart'; // ⭐ חדש!

class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();

    // ✅ טעינה ראשונית - רק בפעם הראשונה שהמסך נבנה
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!provider.isLoading &&
          provider.lists.isEmpty &&
          provider.errorMessage == null &&
          provider.lastUpdated == null) {
        provider.loadLists();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('רשימות קניות'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "רענן",
            onPressed: () => provider.loadLists(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("מסך הגדרות יתווסף בקרוב")),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadLists,
          child: _buildBody(context, provider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 📌 מציג דיאלוג ליצירת רשימה חדשה
  void _showCreateListDialog(
    BuildContext context,
    ShoppingListsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => CreateListDialog(
        onCreateList: (listData) async {
          debugPrint('🔵 shopping_lists_screen: קיבל נתונים מהדיאלוג');
          
          // ✅ קבל את כל הנתונים מהדיאלוג
          final name = listData['name'] as String?;
          final type = listData['type'] as String? ?? 'super';
          final budget = listData['budget'] as double?;

          debugPrint('   name: $name, type: $type, budget: $budget');

          if (name != null && name.isNotEmpty) {
            try {
              // ✅ העבר הכל ל-Provider
              final newList = await provider.createList(
                name: name,
                type: type,
                budget: budget,
              );

              debugPrint('   ✅ רשימה נוצרה: ${newList.id}');

              // ✅ בדיקת context לפני ניווט
              if (!context.mounted) {
                debugPrint('   ⚠️ context לא mounted - מדלג על ניווט');
                return;
              }

              debugPrint('   ➡️ ניווט ל-populate-list');
              // ✅ נווט למסך הבא
              Navigator.pushNamed(
                context,
                '/populate-list',
                arguments: newList,
              );
            } catch (e) {
              debugPrint('   ❌ שגיאה ביצירת רשימה: $e');
              // השגיאה תוצג ב-Dialog עצמו ב-SnackBar
              rethrow; // העבר הלאה ל-Dialog לטיפול
            }
          }
        },
      ),
    );
  }

  /// 📌 בונה את גוף המסך לפי מצב הטעינה / שגיאה / נתונים
  Widget _buildBody(BuildContext context, ShoppingListsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              "שגיאה בטעינת הרשימות",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadLists(),
              icon: const Icon(Icons.refresh),
              label: const Text('נסה שוב'),
            ),
          ],
        ),
      );
    }
    if (provider.lists.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return _buildListsView(provider);
  }

  /// 📌 מציג את כל הרשימות
  Widget _buildListsView(ShoppingListsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.lists.length,
      itemBuilder: (context, index) {
        final list = provider.lists[index];
        return ShoppingListTile(
          list: list,
          onTap: () {
            Navigator.pushNamed(context, '/populate-list', arguments: list);
          },
          onDelete: () => provider.deleteList(list.id),
          onRestore: (deletedList) => provider.restoreList(deletedList),
          // ⭐ התחל קנייה
          onStartShopping: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActiveShoppingScreen(list: list),
              ),
            );
          },
        );
      },
    ).animate().fadeIn(duration: 300.ms);
  }

  /// 📌 דיאלוג מחיקה (לא בשימוש - משתמשים ב-Dismissible של ShoppingListTile)
  // ignore: unused_element
  Future<void> _confirmDelete(
    BuildContext context,
    ShoppingListsProvider provider,
    ShoppingList list,
  ) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("אישור מחיקה"),
        content: Text("למחוק את הרשימה '${list.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("ביטול"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("מחק"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.deleteList(list.id);

        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('הרשימה "${list.name}" נמחקה')));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה במחיקת רשימה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 📌 מצב ריק – אין רשימות להצגה
  Widget _buildEmptyState(
    BuildContext context,
    ShoppingListsProvider provider,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt_rounded, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "אין רשימות להצגה",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "לחץ על כפתור הפלוס כדי ליצור את הרשימה הראשונה שלך!",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateListDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text("צור רשימה חדשה"),
          ),
        ],
      ),
    );
  }
}
