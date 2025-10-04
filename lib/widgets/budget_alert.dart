// lib/widgets/budget_alert.dart
import 'package:flutter/material.dart';

class BudgetAlert extends StatelessWidget {
  final double totalBudget;
  final double spentAmount;
  final List<dynamic> completedItems;
  final List<dynamic> pendingItems;

  const BudgetAlert({
    super.key,
    required this.totalBudget,
    required this.spentAmount,
    this.completedItems = const [],
    this.pendingItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (totalBudget <= 0) return const SizedBox.shrink();

    final totalItems = completedItems.length + pendingItems.length;
    final spentPercentage = (spentAmount / totalBudget) * 100;
    final remainingBudget = totalBudget - spentAmount;

    // תחזית
    final avgPricePerCompletedItem = completedItems.isNotEmpty
        ? spentAmount / completedItems.length
        : 0.0;
    final projectedTotalSpend = totalItems > 0
        ? avgPricePerCompletedItem * totalItems
        : 0.0;
    final projectedOverrun = projectedTotalSpend - totalBudget;
    final projectedPercentage = totalBudget > 0
        ? (projectedTotalSpend / totalBudget) * 100
        : 0.0;

    // 🔎 סוג ההתראה
    String alertType;
    if (spentPercentage >= 100) {
      alertType = "exceeded";
    } else if (spentPercentage >= 85) {
      alertType = "critical";
    } else if (projectedPercentage >= 100) {
      alertType = "warning";
    } else if (spentPercentage >= 50) {
      alertType = "moderate";
    } else {
      alertType = "good";
    }

    final config = _alertConfig(
      alertType,
      spentAmount,
      totalBudget,
      remainingBudget,
      projectedOverrun.toDouble(),
    );

    return Card(
      color: config["bgColor"],
      shape: RoundedRectangleBorder(
        side: BorderSide(color: config["borderColor"], width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔔 כותרת + אייקון
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(config["icon"], color: config["color"]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config["title"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: config["color"],
                        ),
                      ),
                      Text(
                        config["description"],
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📊 Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "הוצאות נוכחיות",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      "₪${spentAmount.toStringAsFixed(0)} / ₪${totalBudget.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (spentPercentage / 100).clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(config["color"]),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${spentPercentage.toStringAsFixed(1)}% מהתקציב",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      "${completedItems.length}/$totalItems פריטים",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            // 🔮 תחזית
            if (avgPricePerCompletedItem > 0 && pendingItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    "תחזית",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "מחיר ממוצע לפריט:",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    "₪${avgPricePerCompletedItem.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "תחזית סה\"כ:",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    "₪${projectedTotalSpend.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: projectedOverrun > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],

            // 💡 טיפים
            if (alertType == "warning")
              _tipBox(
                "💡 טיפ: נסו לחפש חלופות זולות יותר או להסיר פריטים לא חיוניים",
              ),
            if (alertType == "critical")
              _tipBox("⚡ עצירה! בדקו מחירים לפני הוספת פריטים נוספים"),
            if (alertType == "good" && totalItems > 0)
              _tipBox("🎯 כל הכבוד! אתם בדרך לסיים בתקציב"),
          ],
        ),
      ),
    );
  }

  Widget _tipBox(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.6 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      ),
    );
  }

  Map<String, dynamic> _alertConfig(
    String type,
    double spentAmount,
    double totalBudget,
    double remainingBudget,
    double projectedOverrun,
  ) {
    return {
      "exceeded": {
        "icon": Icons.warning_amber_rounded,
        "color": Colors.red.shade700,
        "bgColor": Colors.red.shade50,
        "borderColor": Colors.red.shade200,
        "title": "חרגתם מהתקציב! 🚨",
        "description":
            "חרגתם ב-₪${(spentAmount - totalBudget).toStringAsFixed(0)}",
      },
      "critical": {
        "icon": Icons.error_outline,
        "color": Colors.orange.shade700,
        "bgColor": Colors.orange.shade50,
        "borderColor": Colors.orange.shade200,
        "title": "התקציב כמעט נגמר! ⚠️",
        "description": "נותרו רק ₪${remainingBudget.toStringAsFixed(0)}",
      },
      "warning": {
        "icon": Icons.trending_up,
        "color": Colors.yellow.shade800,
        "bgColor": Colors.yellow.shade50,
        "borderColor": Colors.yellow.shade200,
        "title": "תחזית: חריגה מהתקציב 📈",
        "description": "צפויה חריגה של ₪${projectedOverrun.toStringAsFixed(0)}",
      },
      "moderate": {
        "icon": Icons.adjust,
        "color": Colors.blue.shade700,
        "bgColor": Colors.blue.shade50,
        "borderColor": Colors.blue.shade200,
        "title": "תקציב תקין 👍",
        "description": "נותרו ₪${remainingBudget.toStringAsFixed(0)}",
      },
      "good": {
        "icon": Icons.check_circle,
        "color": Colors.green.shade700,
        "bgColor": Colors.green.shade50,
        "borderColor": Colors.green.shade200,
        "title": "תקציב מצוין! ✅",
        "description": "נותרו ₪${remainingBudget.toStringAsFixed(0)}",
      },
    }[type]!;
  }
}
