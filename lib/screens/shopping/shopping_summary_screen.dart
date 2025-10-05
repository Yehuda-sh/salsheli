// 📄 File: lib/screens/shopping/shopping_summary_screen.dart
//
// 🎯 Purpose: מסך סיכום קנייה לאחר סיום רשימת קניות
//
// 📦 Dependencies:
// - ShoppingListsProvider: שליפת נתוני הרשימה
//
// ✨ Features:
// - 📊 סטטיסטיקות: תקציב, אחוז הצלחה, פירוט פריטים
// - 🎉 UI חגיגי לסיום קנייה מוצלח
// - 📱 Navigation חזרה לדף הבית
// - 🎨 Theme-aware colors
// - 🔄 Empty states (loading, error, not found)
//
// 📝 Usage:
// ```dart
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => ShoppingSummaryScreen(listId: 'list_123'),
//   ),
// );
// ```

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shopping_lists_provider.dart';

class ShoppingSummaryScreen extends StatelessWidget {
  /// מזהה הרשימה
  final String listId;

  const ShoppingSummaryScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    debugPrint('🎉 ShoppingSummaryScreen.build: listId=$listId');

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Consumer<ShoppingListsProvider>(
          builder: (context, provider, _) {
            // 1️⃣ Loading State
            if (provider.isLoading) {
              debugPrint('   ⏳ Loading...');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: cs.primary),
                    const SizedBox(height: 16),
                    Text(
                      'טוען סיכום...',
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 2️⃣ Error State
            if (provider.errorMessage != null) {
              debugPrint('   ❌ Error: ${provider.errorMessage}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: 16),
                    Text(
                      'שגיאה בטעינת הסיכום',
                      style: TextStyle(fontSize: 18, color: cs.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage ?? 'שגיאה לא ידועה',
                      style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('חזור'),
                    ),
                  ],
                ),
              );
            }

            // 3️⃣ Not Found State
            final list = provider.getById(listId);
            if (list == null) {
              debugPrint('   ⚠️ List not found: $listId');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'הרשימה לא נמצאה',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ייתכן שהרשימה נמחקה',
                      style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        debugPrint('   🏠 ניווט חזרה לדף הבית');
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('חזרה לדף הבית'),
                    ),
                  ],
                ),
              );
            }

            // 4️⃣ Content - חישוב סטטיסטיקות
            debugPrint('   ✅ מציג סיכום: ${list.name}');
            final total = list.items.length;
            final purchased = list.items.where((item) => item.isChecked).length;
            final missing = total - purchased;
            final spentAmount = list.items
                .where((item) => item.isChecked)
                .fold(0.0, (sum, item) => sum + item.totalPrice);
            final budget = list.budget ?? 0.0;
            final budgetDiff = budget - spentAmount;
            final successRate = total > 0 ? (purchased / total) * 100 : 0;

            debugPrint('   📊 נקנו: $purchased/$total');
            debugPrint('   💰 הוצאו: ₪${spentAmount.toStringAsFixed(2)}');
            debugPrint('   📈 אחוז הצלחה: ${successRate.toStringAsFixed(1)}%');

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🎉 כותרת
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: cs.primaryContainer,
                        child: Text(
                          "🎉",
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "קנייה הושלמה בהצלחה!",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        list.name,
                        style: TextStyle(
                          fontSize: 18,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 💰 תקציב
                  _SummaryCard(
                    icon: Icons.account_balance_wallet,
                    title: "תקציב",
                    value: "₪${spentAmount.toStringAsFixed(2)}",
                    subtitle: budget > 0
                        ? "${budgetDiff >= 0 ? 'נשאר' : 'חריגה'}: ₪${budgetDiff.abs().toStringAsFixed(2)}"
                        : null,
                    color: budgetDiff >= 0 ? Colors.green : Colors.red,
                  ),

                  const SizedBox(height: 16),

                  // ✅ הצלחה
                  _SummaryCard(
                    icon: Icons.trending_up,
                    title: "אחוז הצלחה",
                    value: "${successRate.toStringAsFixed(1)}%",
                    subtitle: "$purchased מתוך $total פריטים נרכשו",
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 16),

                  // 📊 פירוט פריטים
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: Icons.check_circle,
                          label: "נרכשו",
                          value: "$purchased",
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          icon: Icons.cancel,
                          label: "חסרו",
                          value: "$missing",
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 🔙 כפתור חזרה
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        debugPrint('   🏠 לחיצה על כפתור חזרה - popUntil');
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text("חזרה לדף הבית"),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ========================================
// Widget: כרטיס סיכום
// ========================================

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: תיבת סטטיסטיקה
// ========================================

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
