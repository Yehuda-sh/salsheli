// lib/screens/habits/my_habits_screen.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyHabitsScreen extends StatefulWidget {
  const MyHabitsScreen({super.key});

  @override
  State<MyHabitsScreen> createState() => _MyHabitsScreenState();
}

class _MyHabitsScreenState extends State<MyHabitsScreen> {
  bool _isLoading = true;
  String _query = '';
  int? _editingId;
  final TextEditingController _editController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // מודל קטן במקום Map
  final List<_HabitPref> _allPrefs = [];
  List<_HabitPref> _visiblePrefs = [];

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('he', timeago.HeMessages());
    _loadPreferences();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
      _applyFilter();
    });
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // סימולציה
    if (!mounted) return;

    _allPrefs
      ..clear()
      ..addAll([
        _HabitPref(
          id: 1,
          preferredProduct: "חלב תנובה",
          genericName: "חלב 3%",
          frequencyDays: 12,
          lastPurchased: DateTime.now().subtract(const Duration(days: 3)),
        ),
        _HabitPref(
          id: 2,
          preferredProduct: "לחם אנג'ל מלא",
          genericName: "לחם",
          frequencyDays: 7,
          lastPurchased: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ]);

    _applyFilter();
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    final q = _query.toLowerCase();
    _visiblePrefs =
        _allPrefs
            .where(
              (p) =>
                  q.isEmpty ||
                  p.preferredProduct.toLowerCase().contains(q) ||
                  p.genericName.toLowerCase().contains(q),
            )
            .toList()
          ..sort((a, b) => b.lastPurchased.compareTo(a.lastPurchased));
  }

  void _startEdit(_HabitPref pref) {
    setState(() {
      _editingId = pref.id;
      _editController.text = pref.preferredProduct;
    });
  }

  void _saveEdit(int id) {
    final newName = _editController.text.trim();
    if (newName.isEmpty) return;
    final idx = _allPrefs.indexWhere((p) => p.id == id);
    if (idx == -1) return;

    setState(() {
      _allPrefs[idx] = _allPrefs[idx].copyWith(preferredProduct: newName);
      _editingId = null;
      _applyFilter();
    });
  }

  void _deletePref(int id) {
    final idx = _allPrefs.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final removed = _allPrefs[idx];

    setState(() {
      _allPrefs.removeAt(idx);
      _applyFilter();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("הוסרה ההעדפה: ${removed.preferredProduct}"),
        action: SnackBarAction(
          label: 'בטל',
          onPressed: () {
            setState(() {
              _allPrefs.insert(idx, removed);
              _applyFilter();
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _editController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text("הרגלי הקנייה שלי"), centerTitle: true),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPreferences,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildSearchBar(context)),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_visiblePrefs.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState(context))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final item = _visiblePrefs[i];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i == _visiblePrefs.length - 1 ? 0 : 8,
                      ),
                      child: _buildPreferenceCard(context, item),
                    );
                  }, childCount: _visiblePrefs.length),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: cs.primary.withOpacity(0.12),
            child: Icon(Icons.psychology, size: 24, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ההעדפות שלך",
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "נהל מוצרים ומותגים שנרכשים לעיתים תכופות – עריכה/מחיקה/חיפוש",
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "חיפוש לפי מוצר/שם גנרי…",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'נקה חיפוש',
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.close),
                ),
          filled: true,
          fillColor: cs.surfaceContainerHighest.withOpacity(0.06),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: cs.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            children: [
              Icon(Icons.star_border, size: 48, color: cs.primary),
              const SizedBox(height: 12),
              Text(
                "אין עדיין העדפות שמורות",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "ככל שתשתמש, נלמד אוטומטית את ההרגלים ונציע התאמות.",
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(BuildContext context, _HabitPref pref) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = _editingId == pref.id;

    final predictedNext = pref.lastPurchased.add(
      Duration(days: pref.frequencyDays),
    );
    final daysLeft = predictedNext.difference(DateTime.now()).inDays;
    final predictionText = daysLeft >= 0
        ? "בעוד ~$daysLeft ימים"
        : "לפני ${daysLeft.abs()} ימים";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // שורה עליונה: שם/עריכה + אקשנים
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: isEditing
                      ? TextField(
                          controller: _editController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: "שם המוצר המועדף",
                            isDense: true,
                          ),
                          onSubmitted: (_) => _saveEdit(pref.id),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pref.preferredProduct,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (pref.genericName.isNotEmpty)
                              Text(
                                pref.genericName,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(width: 8),
                if (isEditing)
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'שמור',
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _saveEdit(pref.id),
                      ),
                      IconButton(
                        tooltip: 'בטל',
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => setState(() => _editingId = null),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'ערוך',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _startEdit(pref),
                      ),
                      IconButton(
                        tooltip: 'מחק',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _deletePref(pref.id),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // צ'יפים של סטטוס
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.repeat, size: 16),
                  label: Text("נקנה כל ${pref.frequencyDays} ימים"),
                ),
                Chip(
                  avatar: const Icon(Icons.schedule, size: 16),
                  label: Text(
                    "נרכש ${timeago.format(pref.lastPurchased, locale: 'he')}",
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.notifications_active, size: 16),
                  label: Text("הבא: $predictionText"),
                  backgroundColor: cs.tertiaryContainer.withOpacity(0.25),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// מודל קטן למסך (in-file)
// ---------------------------
class _HabitPref {
  final int id;
  final String preferredProduct;
  final String genericName;
  final int frequencyDays; // כמה ימים בין רכישות
  final DateTime lastPurchased;

  const _HabitPref({
    required this.id,
    required this.preferredProduct,
    required this.genericName,
    required this.frequencyDays,
    required this.lastPurchased,
  });

  _HabitPref copyWith({
    String? preferredProduct,
    String? genericName,
    int? frequencyDays,
    DateTime? lastPurchased,
  }) {
    return _HabitPref(
      id: id,
      preferredProduct: preferredProduct ?? this.preferredProduct,
      genericName: genericName ?? this.genericName,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      lastPurchased: lastPurchased ?? this.lastPurchased,
    );
  }
}
