// 📄 File: lib/widgets/create_list_dialog_usage_example.dart
//
// 🎯 Purpose: דוגמה לשימוש ב-CreateListDialog המשופר
//
// ⚠️ IMPORTANT: זה קובץ דוגמה בלבד - לא לשימוש ישיר!
// קובץ זה מראה איך להשתמש ב-CreateListDialog עם כל התכונות החדשות.
//
// Version: 1.0
// Created: 14/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_lists_provider.dart';
import '../models/receipt.dart';
import 'create_list_dialog.dart';

/// דוגמה לשימוש ב-CreateListDialog - קריאה פשוטה
void showCreateListDialogExample(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => CreateListDialog(
      onCreateList: (data) async {
        // 📝 המפה data יכולה להכיל:
        // - name: String (חובה)
        // - type: String (ברירת מחדל: "super")
        // - status: String (תמיד "active")
        // - budget: double? (אופציונלי)
        // - eventDate: DateTime? (אופציונלי)
        // - items: List<Map<String, dynamic>>? (🆕 פריטים מתבנית)
        // - templateId: String? (🆕 מזהה תבנית)

        // המרת פריטים ממפות לאובייקטים
        List<ReceiptItem>? items;
        if (data['items'] != null) {
          items = (data['items'] as List)
              .map((itemMap) => ReceiptItem.fromJson(itemMap as Map<String, dynamic>))
              .toList();
        }

        // יצירת הרשימה עם כל הפרמטרים
        await context.read<ShoppingListsProvider>().createList(
              name: data['name'] as String,
              type: data['type'] as String? ?? 'super',
              budget: data['budget'] as double?,
              eventDate: data['eventDate'] as DateTime?,
              items: items,
              templateId: data['templateId'] as String?,
              isShared: true,
            );
      },
    ),
  );
}

/// דוגמה מורחבת - עם טיפול בשגיאות והודעות
void showCreateListDialogWithErrorHandling(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => CreateListDialog(
      onCreateList: (data) async {
        try {
          // המרת פריטים
          List<ReceiptItem>? items;
          if (data['items'] != null) {
            items = (data['items'] as List)
                .map((itemMap) => ReceiptItem.fromJson(itemMap as Map<String, dynamic>))
                .toList();
          }

          // יצירת הרשימה
          final newList = await context.read<ShoppingListsProvider>().createList(
                name: data['name'] as String,
                type: data['type'] as String? ?? 'super',
                budget: data['budget'] as double?,
                eventDate: data['eventDate'] as DateTime?,
                items: items,
                templateId: data['templateId'] as String?,
                isShared: true,
              );

          // הודעת הצלחה מותאמת
          if (!context.mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                items != null && items.isNotEmpty
                    ? 'הרשימה "${newList.name}" נוצרה עם ${items.length} פריטים! 🎉'
                    : 'הרשימה "${newList.name}" נוצרה בהצלחה! 🎉',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          
          // הודעת שגיאה
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('שגיאה ביצירת רשימה: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    ),
  );
}

/// דוגמה לשימוש בתוך FloatingActionButton
class HomeScreenExample extends StatelessWidget {
  const HomeScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('רשימות הקניות שלי')),
      body: const Center(child: const Text('תוכן המסך')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CreateListDialog(
        onCreateList: (data) async {
          // המרת פריטים
          List<ReceiptItem>? items;
          if (data['items'] != null) {
            items = (data['items'] as List)
                .map((itemMap) => ReceiptItem.fromJson(itemMap as Map<String, dynamic>))
                .toList();
          }

          // יצירה
          await context.read<ShoppingListsProvider>().createList(
                name: data['name'] as String,
                type: data['type'] as String? ?? 'super',
                budget: data['budget'] as double?,
                eventDate: data['eventDate'] as DateTime?,
                items: items,
                templateId: data['templateId'] as String?,
                isShared: true,
              );
        },
      ),
    );
  }
}

// ========================================
// 📋 הערות חשובות לשימוש
// ========================================
//
// 1. **המרת פריטים:**
//    - הפריטים חוזרים כ-List<Map<String, dynamic>>
//    - חייבים להמיר אותם ל-List<ReceiptItem>
//    - השתמש ב-ReceiptItem.fromJson()
//
// 2. **טיפול בשגיאות:**
//    - תמיד עטוף ב-try-catch
//    - בדוק if (!context.mounted) לפני ScaffoldMessenger
//
// 3. **תבניות:**
//    - אם המשתמש בחר תבנית, data['items'] יהיה מלא
//    - data['templateId'] יכיל את מזהה התבנית
//
// 4. **תאריך אירוע:**
//    - data['eventDate'] יהיה DateTime? או null
//    - שימושי לרשימות של אירועים מיוחדים
//
// 5. **תקציב:**
//    - data['budget'] יהיה double? או null
//    - המשתמש יכול להשאיר ריק
