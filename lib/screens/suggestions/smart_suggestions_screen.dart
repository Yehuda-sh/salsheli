// lib/screens/suggestions/smart_suggestions_screen.dart
import 'package:flutter/material.dart';

class SmartSuggestionsScreen extends StatefulWidget {
  const SmartSuggestionsScreen({super.key});

  @override
  State<SmartSuggestionsScreen> createState() => _SmartSuggestionsScreenState();
}

class _SmartSuggestionsScreenState extends State<SmartSuggestionsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> activeLists = [];

  @override
  void initState() {
    super.initState();
    _loadActiveLists();
  }

  Future<void> _loadActiveLists() async {
    await Future.delayed(const Duration(seconds: 2)); // סימולציה לטעינה
    if (!mounted) return;
    setState(() {
      isLoading = false;
      activeLists = [
        {"id": "1", "name": "קנייה לסופ״ש", "updated_date": DateTime.now()},
      ];
    });
  }

  Map<String, dynamic>? get mostRecentList {
    if (activeLists.isEmpty) return null;
    activeLists.sort(
      (a, b) => (b["updated_date"] as DateTime).compareTo(
        a["updated_date"] as DateTime,
      ),
    );
    return activeLists.first;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface, // במקום צבע קשיח
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(cs),
                const SizedBox(height: 24),
                if (isLoading)
                  _buildLoadingState(cs)
                else if (mostRecentList == null)
                  _buildEmptyState(context, cs)
                else
                  _buildSuggestions(context, mostRecentList!, cs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🧠 Header
  Widget _buildHeader(ColorScheme cs) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1), // ✅
                blurRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "הצעות קנייה חכמות",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "בינה מלאכותית מציעה מוצרים מותאמים להרגלי הקנייה שלך",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ⏳ מצב טעינה
  Widget _buildLoadingState(ColorScheme cs) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 12,
                    color: cs.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 6),
                  Container(width: 160, height: 10, color: cs.surfaceContainer),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const CircularProgressIndicator(),
      ],
    );
  }

  /// 📭 מצב ריק
  Widget _buildEmptyState(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // ✅
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.lightbulb, size: 64, color: cs.primary),
          const SizedBox(height: 16),
          Text(
            "אין רשימת קניות פעילה",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "כדי לקבל הצעות חכמות, צריכה להיות לפחות רשימת קניות פעילה אחת.",
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              // ✅ תקן נתיב ל-router הקיים בפרויקט
              Navigator.pushNamed(context, "/shopping-lists");
            },
            icon: const Icon(Icons.add),
            label: const Text("צור רשימה חדשה"),
          ),
        ],
      ),
    );
  }

  /// 📦 תצוגת הצעות לפי רשימה אחרונה
  Widget _buildSuggestions(
    BuildContext context,
    Map<String, dynamic> list,
    ColorScheme cs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "מבוסס על הרשימה '${list["name"]}'",
          style: TextStyle(fontSize: 16, color: cs.onSurface),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (_, i) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.trending_up, color: cs.primary),
              title: Text("מוצר מומלץ ${i + 1}"),
              subtitle: const Text("מבוסס על הקניות האחרונות שלך"),
              trailing: IconButton(
                icon: Icon(Icons.add_circle, color: cs.tertiary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("המוצר נוסף לרשימה '${list["name"]}'"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
