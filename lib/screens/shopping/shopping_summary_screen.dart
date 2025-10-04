// 📄 lib/screens/shopping/shopping_summary_screen.dart
//
// ✅ תיקון: המסך עכשיו מקבל listId ומושך נתונים מה-Provider
//
// 📌 מסך סיכום קנייה לאחר סיום רשימת הקניות.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shopping_lists_provider.dart';

class ShoppingSummaryScreen extends StatelessWidget {
  /// מזהה הרשימה
  final String listId;

  const ShoppingSummaryScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();
    final list = provider.getById(listId);

    if (list == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('שגיאה')),
        body: const Center(child: Text('הרשימה לא נמצאה')),
      );
    }

    final total = list.items.length;
    final purchased = list.items.where((item) => item.isChecked).length;
    final missing = total - purchased;
    final spentAmount = list.items
        .where((item) => item.isChecked)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
    final budget = list.budget ?? 0.0;
    final budgetDiff = budget - spentAmount;
    final successRate = total > 0 ? (purchased / total) * 100 : 0;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🎉 כותרת
              Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.orange,
                    child: Text("🎉", style: TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "קנייה הושלמה בהצלחה!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    list.name,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text("חזרה לדף הבית"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
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
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
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
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
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
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
